# Changelog

All notable changes to the Jumbo Rails template are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-05-04

### Added
- Four optional add-on modules under the Operations feature, each shipping an
  `Application*` base class that subclasses extend:
  - `ApplicationPolicy` (`app/policies/`) — authorization objects.
  - `ApplicationValidator` (`app/validators/`) — input validation with error
    collection.
  - `ApplicationQuery` (`app/queries/`) — encapsulated database reads.
  - `ApplicationGateway` (`app/gateways/`) — external API wrappers that return
    a `Result` instead of raising.
- `--operations-include=policies,validators,queries,gateways` flag to pick the
  subset of add-on modules to install. Default is all when Operations is
  enabled.
- Sub-checkboxes on the website (`public/index.html`) for each add-on module so
  the generated command reflects the selection.
- `bin/claude` launcher script copied into generated apps under the Developer
  Tools group; the default Zellij layout now boots it in a `coder` tab.
- `CHANGELOG.md` (this file).

### Changed
- Replaced `trailblazer-rails` with a custom in-app Operations framework
  (`ApplicationOperation` + `Result`) installed under `app/core/`. The skip
  flag is renamed `--skip-trailblazer` → `--skip-operations`.
- `config/application.rb` autoload paths are computed dynamically from the
  selected Operation modules rather than hard-coding `app/core`.

### Notes
- `ApplicationPolicy` shares its name with Pundit's base class. If you later
  add `gem 'pundit'`, plan to keep one or the other — running both will
  collide.
- `app/validators/` is also where Rails projects conventionally place
  `ActiveModel::EachValidator` subclasses. Jumbo's `ApplicationValidator` is a
  different pattern (input validation with error collection). Both can live
  side-by-side in the directory, but readers may need a moment to tell them
  apart.

## [0.1.0] - 2026-04

### Added
- Initial public release with five selectable feature groups: Inertia Rails,
  Multi-staging, Authentication, Developer Tools, Trailblazer.
- Default behavior installs all features; per-feature `--skip-*` flags and an
  interactive `-i` mode were introduced for opt-out.
- `JUMBO_VERSION` constant printed at the end of template execution.
- `bin/ze` (Zellij launcher) and `bin/db-reset` copied into generated apps.
- Cross-platform fixes for `bin/ze` (Linux/Unix and bash 3.x compatibility).
- KDL syntax fixes for the default Zellij layout.
