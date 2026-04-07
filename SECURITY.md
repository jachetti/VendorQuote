# Security Policy

## ⚠️ IMPORTANT: This is an Intentionally Vulnerable Application

**VendorQuote is deliberately designed with security vulnerabilities for educational purposes.**

This application is part of a CrowdStrike Cloud Security training lab and should **NEVER** be deployed in production environments or on systems containing real data.

## Known Intentional Vulnerabilities

This application contains the following **intentional** security issues:

### Image-Level Issues
- Running as root user (no USER instruction)
- Privileged port usage (port 80)
- Embedded fake credentials in image layers
- Use of ADD instead of COPY in Dockerfile
- Older base image with known CVEs
- Inherited SUID binaries

### Runtime Issues
- **Command Injection**: The `/api/support/diag` endpoint executes unsanitized user input
- Writable root filesystem
- No capability restrictions
- No AppArmor/SELinux profiles

### Data Security
- Fake credentials embedded in image
- Fake sensitive business data included
- No encryption at rest or in transit

## What This Means

**DO NOT report these vulnerabilities as security issues.**

They are intentional and documented. This application exists to:
- Teach container security concepts
- Demonstrate detection and prevention capabilities
- Provide hands-on training scenarios

## Safe Usage Guidelines

### ✅ Acceptable Use
- Running in isolated training environments
- Educational lab demonstrations
- Security research and testing (with proper authorization)
- Learning about container security

### ❌ Prohibited Use
- Production deployments
- Systems with real data or credentials
- Unsupervised or unauthorized environments
- Public internet exposure
- Networks containing sensitive systems

## Reporting Actual Issues

If you discover a **non-intentional** security issue (such as a way to escape the intended training scenarios or compromise the host system beyond the designed scope), please report it privately to:

**[Your Contact Email or GitHub Security Advisory]**

Do not open public issues for security-related discoveries that fall outside the intentional vulnerability scope.

## Questions?

For questions about proper usage or training scenarios, please open a GitHub issue or contact the repository maintainer.

---

**Remember:** This application is a teaching tool. Treat it like a loaded training weapon—powerful for education, dangerous if misused.
