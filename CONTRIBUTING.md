# Contributing to VendorQuote

Thank you for your interest in contributing to VendorQuote! This project is maintained as an educational tool for container security training.

## Important Notes

**This is an intentionally vulnerable application.** Before contributing, please read:
- [README.md](README.md) - Project overview
- [SECURITY.md](SECURITY.md) - Security policy and intentional vulnerabilities

## Types of Contributions Welcome

### ✅ We Welcome:
- **Documentation improvements** - Clarify usage, fix typos, improve examples
- **Lab scenario enhancements** - Additional training exercises or demonstration paths
- **Bug fixes** - Fix issues that break the intended training functionality
- **Compatibility updates** - Ensure it works across different environments
- **UI/UX improvements** - Make the app more realistic or easier to demonstrate
- **Additional fake data** - More realistic sample procurement data
- **Testing improvements** - Better validation scripts or test procedures

### ❌ Please Don't Submit:
- **Security "fixes"** for intentional vulnerabilities (they're supposed to be there!)
- **Production-readiness changes** (authentication, input validation, security hardening)
- **Real credentials or sensitive data** (everything must remain fake)
- **Overly complex features** (keep it simple for teaching purposes)

## How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/my-improvement`
3. **Make your changes** and test them locally
4. **Update documentation** if needed (README, TESTING, etc.)
5. **Commit with clear messages**: `git commit -m "Add: description of change"`
6. **Push to your fork**: `git push origin feature/my-improvement`
7. **Open a Pull Request** with a description of your changes

## Pull Request Guidelines

- **Describe the change**: What does it do and why is it useful?
- **Maintain the scope**: Remember this is a training tool, not a production app
- **Test locally**: Ensure the container builds and runs correctly
- **Keep it simple**: Prefer clarity and simplicity over complexity
- **Fake data only**: Never include real credentials, IPs, or sensitive information

## Code Style

- **Simplicity first** - Code should be easy to understand for training purposes
- **Comments for vulnerabilities** - Clearly mark intentional security issues
- **Consistent formatting** - Match the existing code style
- **Clear variable names** - Make the code readable for learners

## Testing

Before submitting, please:
- Build the Docker image successfully
- Run through the basic testing steps in [TESTING.md](TESTING.md)
- Verify all intentional vulnerabilities still work as expected
- Test on both macOS and Linux if possible

## Questions or Discussions

- **General questions**: Open a GitHub issue with the `question` label
- **Feature proposals**: Open an issue with the `enhancement` label
- **Bug reports**: Open an issue with the `bug` label (for unintended bugs only)

## Code of Conduct

Be respectful and professional. This project is for education, so:
- Help others learn
- Be patient with questions
- Assume good intentions
- Foster a welcoming environment

## License

By contributing, you agree that your contributions will be licensed under the MIT License (see [LICENSE](LICENSE)).

---

Thank you for helping make container security education more accessible! 🎓🔒
