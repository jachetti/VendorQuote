# VendorQuote Deployment Checklist

Use this checklist when deploying VendorQuote for lab environments.

## Pre-Deployment

- [ ] Amazon Linux host provisioned
- [ ] Docker installed and running
- [ ] CrowdStrike Falcon Sensor for Linux installed (optional but recommended)
- [ ] Port 80 available (no conflicting services)
- [ ] Kali Linux machine available (for C2 scenarios)
- [ ] Network connectivity between host, Kali, and Windows workstation
- [ ] AWS Security Group allows inbound HTTP (port 80)

## Deployment Steps

- [ ] Clone or copy VendorQuote files to lab host
- [ ] Verify all files present: `ls -R vendorquote/`
- [ ] Make scripts executable: `chmod +x vendorquote/*.sh`
- [ ] Build image: `cd vendorquote && ./build.sh`
- [ ] Verify image built: `docker images | grep vendorquote`
- [ ] Start container: `./run.sh`
- [ ] Verify container running: `docker ps | grep vendorquote`
- [ ] Test health endpoint: `curl http://127.0.0.1/healthz`
- [ ] Test vulnerable endpoint: See TESTING.md step 12

## Lab Environment Configuration

### On Windows 11 Workstation
- [ ] Browser access to `http://<HOST_IP>/`
- [ ] Falcon console access configured
- [ ] GitHub lab guide accessible

### On Amazon Linux Host
- [ ] SSH access working
- [ ] Docker commands work without sudo (or use sudo)
- [ ] Can curl localhost:80
- [ ] Falcon sensor running (if installed): `sudo /opt/CrowdStrike/falconctl -g --aid`

### On Kali Linux
- [ ] SSH access working
- [ ] Can reach VendorQuote on port 80
- [ ] Netcat available: `which nc`
- [ ] Python3 available for HTTP server: `which python3`

## Validation

- [ ] Landing page loads in browser
- [ ] All navigation links work (Dashboard, Quotes, Approvals, Support)
- [ ] Support diagnostic form submits and returns output
- [ ] Command injection works: `whoami` returns `root`
- [ ] Secrets accessible via injection: `cat /app/config/.env` works
- [ ] Tools present: `which bash curl wget nc` all return paths

## Optional: Falcon Integration Tests

- [ ] Safe test trigger works: `docker exec vendorquote bash -lc 'bash crowdstrike_test_high'`
- [ ] Detection appears in Falcon console
- [ ] Host group policy configured for lab
- [ ] Prevention mode settings confirmed

## Lab Scenario Preparation

### Attacker Setup (Kali)
- [ ] Create payloads directory: `mkdir -p payloads`
- [ ] Create fake healthcheck script (see lab guide)
- [ ] Test Python HTTP server: `python3 -m http.server 8000`

### Student Materials
- [ ] Lab guide accessible (GitHub or local)
- [ ] Cheat sheet available for instructors
- [ ] IP addresses documented and shared
- [ ] Credentials (SSH) distributed securely

## Common Issues & Solutions

### Image won't build
```bash
# Check Docker daemon
docker info

# Check disk space
df -h

# Clean Docker cache
docker system prune -a -f
```

### Container won't start
```bash
# Check logs
docker logs vendorquote

# Check port conflict
sudo lsof -i :80

# Remove old container
docker rm -f vendorquote
```

### Can't access from Windows
```bash
# Get public IP
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Check security group
# AWS Console > EC2 > Security Groups > Check Inbound Rules

# Test from host first
curl http://127.0.0.1/
```

### Falcon not detecting
```bash
# Check sensor status
sudo /opt/CrowdStrike/falconctl -g --rfm-state

# Check sensor running
ps aux | grep falcon

# Check prevention mode
# Falcon Console > Host Management > <HOST> > Policy
```

## Post-Lab Cleanup

- [ ] Stop container: `./stop.sh`
- [ ] Remove image (optional): `docker rmi vendorquote:worstcase`
- [ ] Stop Kali HTTP server (Ctrl+C)
- [ ] Close Kali netcat listeners
- [ ] Review Falcon detections for completeness
- [ ] Export detection data (if needed)
- [ ] Reset host to clean state (optional)

## Documentation Locations

- **README.md** - Full project documentation
- **TESTING.md** - Detailed testing procedures
- **vendorquote_lab_guide.md** - Student-facing lab instructions
- **vendorquote_demo_cheatsheet.md** - Instructor quick reference
- **vendorquote_claude_blueprint.md** - Original build specification

## Support Contacts

- Lab instructor: [Name/Contact]
- CrowdStrike SE: [Name/Contact]
- Technical issues: [Support channel]

## Timeline Estimate

| Phase | Duration |
|-------|----------|
| Pre-deployment setup | 15 minutes |
| Image build | 3-5 minutes |
| Container deploy & test | 5 minutes |
| Falcon validation | 5 minutes |
| Kali setup | 5 minutes |
| Student prep | 10 minutes |
| **Total** | **~45 minutes** |

## Lab Execution Estimate

| Section | Duration |
|---------|----------|
| Introduction | 10 minutes |
| Image assessment | 10 minutes |
| Runtime deployment | 5 minutes |
| Exploitation scenarios | 20 minutes |
| Drift & escape demos | 15 minutes |
| Prevention pivot | 10 minutes |
| ASPM walkthrough | 15 minutes |
| Q&A | 15 minutes |
| **Total** | **~100 minutes (1h 40m)** |

---

**Deployment Owner:** _______________
**Date Deployed:** _______________
**Lab Environment ID:** _______________
**Notes:**

