# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Idioma

Responde siempre en español en este proyecto.

## Project

Rails 8.1 / Ruby 3.4.10 portfolio app. Public-facing project showcase (`Project` model, STAR-format
case studies) plus a password-authenticated `/ops` live operations dashboard for the app itself.

Per the README, this is deliberately a **pragmatic monolith**: SQLite (not Postgres/MySQL) even in
production, and Solid Queue/Solid Cache instead of Redis, to keep the app runnable on minimal
resources. Don't introduce Redis, Postgres, or a separate queue service without checking with the
user first — avoiding them is a stated design goal, not an oversight.

## Commands

```bash
bin/setup                 # bundle install, db:prepare, clear logs/tmp, then starts bin/dev
bin/setup --skip-server    # same, without starting the server
bin/dev                    # foreman: rails server + tailwindcss:watch + bin/jobs (Procfile.dev)

bin/rails test                                   # full test suite
bin/rails test test/models/project_test.rb       # single file
bin/rails test test/models/project_test.rb:10    # single test at line
bin/rails test:system                            # system tests (Capybara/Selenium)

bin/rubocop                # style lint (rubocop-rails-omakase)
bin/brakeman --no-pager    # static security analysis
bin/bundler-audit          # gem vulnerability audit
bin/importmap audit        # JS dependency vulnerability audit

bin/ci                      # runs the same steps as CI locally (config/ci.rb)
```

There is no `package.json`/npm — JS is served via importmap (`config/importmap.rb`,
`app/javascript/`), no bundler step required.

Local CI (`bin/ci` → `config/ci.rb`) and `.github/workflows/ci.yml` are two independent
definitions of the same pipeline (setup, rubocop, brakeman, bundler-audit, importmap audit,
tests, seed replant); keep both in sync if you change one.

## Architecture

**Data model**: SQLite with Rails 8's multi-database layout — separate physical databases for
`primary`, `cache`, `queue`, and `cable` (see `config/database.yml`, `db/{cache,queue,cable}_schema.rb`).
Background jobs run on Solid Queue, caching on Solid Cache, Action Cable on Solid Cable — no Redis.

**Auth**: Session-based, not Devise. `app/controllers/concerns/authentication.rb` provides
`allow_unauthenticated_access` (used per-controller to opt out of the `require_authentication`
`before_action`) and manages a signed, permanent `session_id` cookie backed by the `Session`
model (`belongs_to :user`). `Current.session`/`Current.user` (`app/models/current.rb`) hold the
per-request actor. `ProjectsController` opens `index`/`show` to the public; everything else
(create/update/destroy, the ops dashboard mutations) requires a session.

**Projects (case studies)**: `Project` stores STAR fields (`context`, `problem`, `solution`,
`outcome`, see `Project::STAR_FIELDS`) as GitHub-Flavored Markdown. Rendering goes through
`MarkdownHelper#markdown`, which calls Commonmarker with `render.unsafe: false` — raw HTML in
markdown is intentionally stripped, not sanitized, to prevent stored XSS. Don't flip `unsafe` to
true without adding a sanitizer.

**Ops dashboard (`/ops`)**: A live view of the running process, built from three pieces:
- `Telemetry` (`app/models/telemetry.rb`) — an in-memory, mutex-guarded ring buffer (max 200
  samples) of recent request timings. Per-process, resets on boot; this is intentional, not a bug.
- `config/initializers/telemetry.rb` — subscribes to `process_action.action_controller` via
  `ActiveSupport::Notifications` and feeds `Telemetry`, explicitly skipping `OpsController`'s own
  requests to avoid self-referential noise from the dashboard's polling.
- `Ops::MetricsCollector` (`app/services/ops/metrics_collector.rb`) — pulls together app info,
  per-database file sizes, Solid Queue counts/recent jobs, Solid Cache entry count, and
  `Telemetry.stats` into one snapshot for the view.

`OpsController#metrics` is polled by the frontend to refresh `app/views/ops/_metrics.html.erb`.
`OpsController#enqueue` posts a `DemoTelemetryJob` and responds with a Turbo Stream update so the
dashboard reflects new Solid Queue activity without a full page reload.

**Frontend**: Turbo + Stimulus (Hotwire), importmap-pinned JS (no build step), Tailwind CSS
(`bin/rails tailwindcss:watch` via Procfile.dev, output at `app/assets/builds/tailwind.css`).
`app/javascript/controllers/poll_controller.js` drives the ops dashboard polling.

**JSON API**: `projects#index`/`show` also respond to `.json` via jbuilder views
(`app/views/projects/*.json.jbuilder`).
