# Contributing to MotoGo Frontend

Thank you for considering contributing to MotoGo! This document outlines our development workflow and standards.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Commit Convention](#commit-convention)
- [Pull Request Process](#pull-request-process)
- [Testing Requirements](#testing-requirements)

---

## Getting Started

1. Fork and clone the repository
2. Follow the [Getting Started guide](README.md#-getting-started) to set up your environment
3. Install Husky pre-commit hooks:

```bash
npm install
```

---

## Development Workflow

We follow **Git Flow** with the following branch naming conventions:

| Branch Type | Pattern | Example |
|-------------|---------|---------|
| Feature | `feature/<description>` | `feature/service-ratings` |
| Bugfix | `fix/<description>` | `fix/splash-navigation` |
| Hotfix | `hotfix/<description>` | `hotfix/auth-token-refresh` |
| Release | `release/v<X.Y.Z>` | `release/v0.14.0` |

**Process:**

1. Create your branch from `develop`
2. Make your changes in focused, logical commits
3. Push and open a Pull Request to `develop`
4. Ensure CI checks pass (analyze, test, SonarCloud)
5. Request review

---

## Code Standards

### Architecture

Follow the **Feature-First Clean Architecture** pattern:

```
lib/src/features/<feature_name>/
├── data/
│   ├── datasources/          # Remote/local data sources
│   ├── models/               # Data models (JSON serialization)
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/             # Domain entities (business objects)
│   ├── repositories/         # Repository contracts (abstract classes)
│   └── usecases/             # Use cases (single responsibility)
└── presentation/
    ├── bloc/                 # BLoC (events + states + bloc)
    ├── pages/                # Screen widgets
    └── widgets/              # Feature-specific widgets
```

### Key Rules

- **Zero Hardcoding Policy**: Use feature-based constants from `core/constants/` — never hardcode strings
- **BLoC Pattern**: One event per user action, authoritative backend messages via Result Container Pattern
- **Kiwi DI**: All dependencies registered in `core/injector/` with code generation
- **Resilient Mapping**: Models must handle missing/null JSON fields gracefully
- **Input Validation**: Use validators from `core/validators/`
- **Trailing Commas**: Required on all multi-line parameter lists (`require_trailing_commas: true`)
- **Single Quotes**: Use single quotes for strings (`prefer_single_quotes: true`)

### Linting

The project uses a comprehensive lint ruleset (see `analysis_options.yaml`):

```bash
flutter analyze
```

All code must pass with **zero warnings** before merging.

---

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>
```

### Types

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code formatting (no logic changes) |
| `refactor` | Code restructuring (no feature/fix) |
| `test` | Adding or updating tests |
| `chore` | Build, CI, tooling changes |

### Examples

```
feat(ratings): add service review submission page
fix(branch): resolve image picker crash on iOS
test(login): add BLoC unit tests for authentication flow
refactor(core): extract shared validators to mixins
```

---

## Pull Request Process

1. **Title**: Use the conventional commit format
2. **Description**: Explain **what** and **why**, not just **how**
3. **Checklist** before opening:
   - [ ] Code compiles: `flutter analyze` returns zero issues
   - [ ] All tests pass: `flutter test`
   - [ ] Code generated: `dart run build_runner build --delete-conflicting-outputs`
   - [ ] No new SonarCloud issues introduced
   - [ ] Tested on at least one device/emulator

---

## Testing Requirements

### Testing Layers

| Layer | Framework | What to Test |
|-------|-----------|-------------|
| **BLoC** | `bloc_test` | Event → State transitions, error handling |
| **Use Cases** | `mockito` | Business logic with mocked repositories |
| **Repositories** | `mockito` | Data mapping from models to entities |
| **Models** | `flutter_test` | `fromJson`, `toJson`, `copyWith`, equality |
| **Entities** | `flutter_test` | `copyWith`, equality, props |

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific feature
flutter test test/features/login/
```

---

## Questions?

If you have questions about contributing, feel free to open an issue for discussion.
