# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.14.3] - 2026-05-22

### Changed
- Brand rename **MotoGo → MotosGo** across constants, UI labels, login form, and localized Spanish strings
- Comment out `kiwi_generator` in `pubspec.yaml` due to analyzer SDK conflict with Flutter 3.41 (`injector.g.dart` already committed, generator no longer required at install time)

### Security
- Remove revoked Mapbox access token from `secrets.dart` `defaultValue`; token must now come from `--dart-define=MAPBOX_ACCESS_TOKEN=...` or `.env` via `scripts/run_dev.sh`

### Fixed
- `splash_page_test` aligned with new brand text (`MOTOSGO`)
- `secrets_test` rewritten to validate the new "no embedded default" contract

## [0.14.0] - 2026-02-20

### Added
- Professional project documentation: README.md, CONTRIBUTING.md, SECURITY.md, CHANGELOG.md, LICENSE
- Service rating and review system (service_ratings feature)
- Completed service detail view with rating integration
- Splash screen with fade-in and slide-up animations
- Search bar with floating result cards for branch/service discovery

### Changed
- Motorcycle constants consolidated to eliminate duplicated string literals
- ServiceActionStatus refactored to reduce parameter count (SonarCloud compliance)
- Motorcycle history page reloads data after rating submission

### Fixed
- Branch profile image disappearing on update
- Navigation flow after rating submission in service detail page
- `const` keyword added to Text widget in legal page for performance

### Security
- Environment variables handled via `--dart-define` (no secrets in source)

---

_For versions prior to 0.14.0, see the [Git history](https://github.com/EstebanGitPro/motogo_frontend/commits/main)._
