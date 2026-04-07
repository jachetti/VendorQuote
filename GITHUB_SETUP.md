# GitHub Repository Setup Checklist

Use this checklist when setting up the VendorQuote repository on GitHub.

## Pre-Push Checklist

- [ ] Review all files for any real credentials or sensitive data
- [ ] Verify all fake data is clearly marked as "FAKE" or "training"
- [ ] Test the Docker build locally: `docker build -t vendorquote:worstcase .`
- [ ] Test the container runs: `docker run -d --name vendorquote -p 80:80 vendorquote:worstcase`
- [ ] Verify the vulnerability works: `curl -X POST http://localhost/api/support/diag -H 'Content-Type: application/json' -d '{"note":"whoami"}'`
- [ ] Stop test container: `docker rm -f vendorquote`

## Initial Repository Setup

### 1. Create GitHub Repository

Go to GitHub and create a new repository:
- **Repository name:** `vendorquote`
- **Description:** `⚠️ Intentionally vulnerable Node.js container for security training - NOT FOR PRODUCTION`
- **Visibility:** Public ✅
- **Initialize:** Do NOT add README, .gitignore, or license (we have them already)

### 2. Initialize and Push

From the `vendorquote/` directory:

```bash
# Run the setup script
./setup-repo.sh

# Or manually:
git init
git add .
git commit -m "Initial commit: VendorQuote deliberately insecure container for training"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/vendorquote.git
git push -u origin main
```

## Post-Push Configuration

### 3. Repository Settings

Navigate to: `Settings` tab

#### About Section (top right)
- [ ] Add description: `⚠️ Intentionally vulnerable Node.js container for security training - Educational use only`
- [ ] Add website: (Your lab guide URL if you have one)
- [ ] Add topics/tags:
  - `security`
  - `docker`
  - `container-security`
  - `training`
  - `educational`
  - `intentionally-vulnerable`
  - `nodejs`
  - `crowdstrike`
  - `cybersecurity-training`

#### General Settings
- [ ] Features:
  - ✅ Wikis (optional - for additional documentation)
  - ✅ Issues (for questions and discussions)
  - ✅ Discussions (optional - for community)
  - ❌ Projects (not needed)

### 4. Security Tab Configuration

Navigate to: `Security` tab

- [ ] Verify SECURITY.md is recognized
- [ ] Review security advisories settings
- [ ] Consider adding a security policy banner

#### Dependabot Alerts (Optional)
- [ ] Enable/Disable Dependabot alerts
  - **Note:** Since this is intentionally vulnerable, you may want to disable or acknowledge that alerts are expected

### 5. Add Repository Shields/Badges

Your README.md already includes these badges:
- [x] License badge
- [x] Docker badge
- [x] Node.js version badge
- [x] Security warning badge

### 6. Create Release (Optional)

Navigate to: `Releases` → `Create a new release`

- **Tag version:** `v1.0.0`
- **Release title:** `VendorQuote v1.0 - Initial Training Release`
- **Description:**
  ```markdown
  ## VendorQuote v1.0 - Deliberately Insecure Container for Training

  ⚠️ **WARNING: Intentionally vulnerable - Educational use only**

  ### What's Included
  - Node.js 16 containerized application
  - Command injection vulnerability for demonstration
  - Embedded fake credentials and sensitive data
  - Complete lab documentation and testing guides

  ### Quick Start
  ```bash
  docker run -d --name vendorquote -p 80:80 ghcr.io/YOUR_USERNAME/vendorquote:v1.0.0
  ```

  See [QUICKSTART.md](QUICKSTART.md) for full instructions.

  ### ⚠️ Security Warnings
  - This application is intentionally vulnerable
  - Never deploy in production
  - Contains fake credentials only
  - For educational purposes only

  See [SECURITY.md](SECURITY.md) for details on intentional vulnerabilities.
  ```

### 7. Add Topics and Labels

#### Repository Topics (Settings → About)
Suggested topics:
- `security`
- `docker`
- `container-security`
- `training`
- `educational`
- `intentionally-vulnerable`
- `vulnerable-by-design`
- `security-training`
- `ctf`
- `lab-environment`

#### Issue Labels (Issues → Labels)
Consider adding custom labels:
- `question` - Questions about usage
- `lab-scenario` - New lab scenario ideas
- `documentation` - Documentation improvements
- `enhancement` - Feature requests
- `bug` - Unintended bugs (not intentional vulnerabilities)

### 8. Repository Protection (Optional)

If you plan to accept contributions:

Navigate to: `Settings` → `Branches`

- [ ] Add branch protection rule for `main`:
  - ✅ Require pull request reviews before merging
  - ✅ Require status checks to pass (if you set up CI/CD)
  - ❌ Require signed commits (optional)

### 9. Add README Sections

Your README already includes:
- [x] Warning banner
- [x] Overview and purpose
- [x] Architecture documentation
- [x] Deployment instructions
- [x] Security issues list
- [x] Testing procedures
- [x] License information
- [x] Contributing guidelines

### 10. Optional Enhancements

Consider adding:

#### GitHub Actions (CI/CD)
Create `.github/workflows/docker-build.yml`:
- Automated Docker image builds
- Push to GitHub Container Registry
- Run basic tests

#### Pull Request Template
Create `.github/pull_request_template.md`:
- Checklist for contributors
- Reminder about intentional vulnerabilities

#### Issue Templates
Create `.github/ISSUE_TEMPLATE/`:
- Bug report template
- Feature request template
- Question template

## Final Verification

- [ ] Visit your repository URL
- [ ] Click through all main documentation files
- [ ] Verify badges render correctly
- [ ] Check security warnings are prominent
- [ ] Test clone and build from a fresh checkout
- [ ] Share with a colleague for review (optional)

## Promotion (Optional)

If you want to share this project:

- [ ] Post on LinkedIn/Twitter with appropriate warnings
- [ ] Share in container security communities
- [ ] Link from your training materials
- [ ] Add to awesome-* lists (e.g., awesome-security)

**Always emphasize the educational nature and security warnings!**

## Maintenance

Ongoing tasks:
- [ ] Monitor issues for questions
- [ ] Review pull requests
- [ ] Update documentation as needed
- [ ] Keep dependencies reasonably current (balance vulnerability vs. functionality)
- [ ] Respond to community feedback

---

## Quick Command Reference

```bash
# Clone your repo
git clone https://github.com/YOUR_USERNAME/vendorquote.git
cd vendorquote

# Build
docker build -t vendorquote:worstcase .

# Run
docker run -d --name vendorquote -p 80:80 vendorquote:worstcase

# Test
curl http://localhost/healthz

# Stop
docker rm -f vendorquote
```

---

✅ **Repository Ready!** Your VendorQuote training container is now publicly available for educational use.
