# Contributing to Stock Tracker

Thank you for your interest in contributing to Stock Tracker. We welcome bug reports, feature requests, and pull requests from the community. This document explains the process we use to accept contributions and how to prepare a good submission.

## How to contribute

1. Fork the repository and create a branch for your change:
   ```bash
   git checkout -b feature/my-feature
   ```
2. Make changes in a small, well-scoped commit.
3. Run tests (if applicable) and ensure the app runs locally.
4. Push your branch and open a Pull Request against `main`.

## Pull Request Checklist

- [ ] The PR has a clear title and description of the change
- [ ] Linked issue (if applicable)
- [ ] Code follows existing style (see `assets/style.css` for UI guidance)
- [ ] No large, unrelated changes in the same PR
- [ ] All added functions include docstrings/comments where appropriate
- [ ] Any new R package dependencies are documented in `install_packages.R`
- [ ] Basic manual verification steps are provided in the PR description

## Branching and Commit Message Guidelines

- Use feature branches named `feature/<descriptive-name>` or `fix/<short-description>`.
- Keep commits small and focused.
- Use conventional commit style for commit messages, e.g.:
  - `feat: add regression model selection`
  - `fix: resolve plotly trace recycle error`
  - `docs: update README`

## Reporting Bugs

If you find a bug, please open an issue with the following details:
- Steps to reproduce the bug
- Expected behavior vs actual behavior
- Relevant logs or console output
- R session info (`sessionInfo()`)

## Feature Requests

Create an issue describing the feature, the motivation, and a proposed design or sketch where applicable.

## Tests and Quality

- Add tests under `tests/` for new features wherever practical.
- Keep unit tests deterministic when possible; avoid flaky network-dependent tests.

## Code Style

- Follow idiomatic R style (e.g., spacing, naming). We follow tidyverse conventions where practical.
- Prefer meaningful variable names. Avoid single-letter identifiers.

## Communication

- Be respectful and constructive in code reviews and issue discussions.
- Use the issue tracker to coordinate larger changes before implementation to avoid duplicate efforts.

Thank you for contributing! Your improvements help make Stock Tracker better for everyone.