# Security Policy

If you discover a security vulnerability in Stock Tracker, please follow these steps to report it responsibly.

## Reporting a Vulnerability

1. Do not post the vulnerability publicly (issues, PRs, or social media).
2. Email the maintainers with details: `security@localhost` (replace with the project owner's contact, e.g., Joseph Jonathan Fernandes).
3. Include:
   - Affected version(s)
   - Steps to reproduce
   - PoC or exploit code (if available)
   - Suggested mitigation

## Response Process

- The maintainers will acknowledge receipt within 3 business days.
- A fix or mitigation strategy will be proposed and coordinated; timelines depend on severity.
- Once fixed, the maintainers will publish a public advisory and update this document if appropriate.

## Security Best Practices for Deployers

- Keep R and packages up to date.
- Run the app behind a reverse proxy and enable HTTPS.
- Restrict access to data files and logs via file system ACLs.
- Do not store API keys or secrets in plaintext inside the repo. Use environment variables or a secrets manager.

## Contact

Primary contact: Joseph Jonathan Fernandes (project owner)

> Note: Please replace `security@localhost` with an appropriate contact email when deploying to production.