# Quick Start Guide

Get VendorQuote running in under 5 minutes!

## Prerequisites

- Docker installed and running
- Port 80 available (or modify to use another port)

## Option 1: Quick Start (Fastest)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/vendorquote.git
cd vendorquote

# Build and run
./build.sh && ./run.sh

# Verify it's working
curl http://localhost/healthz
# Expected: "ok"

# Open in browser
open http://localhost
```

## Option 2: Manual Docker Commands

```bash
# Build the image
docker build -t vendorquote:worstcase .

# Run the container
docker run -d --name vendorquote -p 80:80 vendorquote:worstcase

# Check logs
docker logs vendorquote

# Stop when done
docker rm -f vendorquote
```

## Option 3: Docker Compose

```bash
# Start
docker-compose up -d

# Stop
docker-compose down
```

## Verify the Vulnerability

Test the intentional command injection:

```bash
curl -X POST http://localhost/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"whoami"}'
```

Expected response:
```json
{"status":"success","output":"root\n"}
```

## Access the Application

**Web Interface:** http://localhost

**Available Pages:**
- `/` - Dashboard
- `/quotes` - Vendor pricing table
- `/approvals` - Discount approvals
- `/support` - Vulnerable diagnostic form

## Test in Browser

1. Navigate to http://localhost/support
2. Enter: `hostname`
3. Click "Run Diagnostic"
4. See the container hostname appear!

## Troubleshooting

### Port 80 in use?

Use a different port:
```bash
docker run -d --name vendorquote -p 8080:80 vendorquote:worstcase
# Access at: http://localhost:8080
```

### Container won't start?

Check logs:
```bash
docker logs vendorquote
```

### Need to rebuild?

```bash
docker rm -f vendorquote
docker rmi vendorquote:worstcase
./build.sh
```

## Next Steps

- Read [TESTING.md](TESTING.md) for comprehensive testing procedures
- Review [README.md](README.md) for full documentation
- Check [SECURITY.md](SECURITY.md) for intentional vulnerabilities

---

⚠️ **Remember:** This is an intentionally vulnerable training application. Never deploy in production!
