# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 0.14.x  | ✅ Active |
| < 0.14  | ❌ No longer supported |

## Reporting a Vulnerability

**Please do NOT open a public issue** for security vulnerabilities.

### How to Report

Send an email to the project maintainers with:

1. **Description** of the vulnerability
2. **Steps to reproduce** (device, OS version, steps)
3. **Impact assessment** — what could an attacker achieve?
4. **Screenshots or logs** (if applicable)

### What to Expect

| Timeframe | Action |
|-----------|--------|
| **48 hours** | Acknowledgement of your report |
| **7 days** | Initial assessment and severity classification |
| **30 days** | Fix released or mitigation plan communicated |

### Scope

The following are considered in-scope:

- Authentication bypasses or token leakage
- Exposure of sensitive data stored in secure storage
- Insecure handling of API keys or secrets
- Man-in-the-middle vulnerabilities
- Unauthorized access to user data

### Out of Scope

- Vulnerabilities in third-party packages (report upstream)
- Issues requiring physical access to an unlocked device
- Social engineering attacks

## Security Measures

This application implements:

- **Secure Storage**: Sensitive data stored via `flutter_secure_storage`
- **Environment Variables**: API keys injected at build time via `--dart-define` (never in source code)
- **Firebase Auth**: Token-based authentication with automatic refresh
- **SonarCloud**: Static analysis on every push
- **Husky**: Pre-commit hooks for code quality enforcement
