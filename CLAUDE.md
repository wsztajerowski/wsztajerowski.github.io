# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The Jekyll source of https://wsztajerowski.github.io/, a user site: three tabs (Talks, Projects,
About), each in Polish (default, `/<tab>/`) and English (`/<tab>/en/`), with a light/dark theme
switch. Built and deployed by GitHub Actions (`.github/workflows/pages.yml`),
not by GitHub's built-in Jekyll, so `_plugins/` runs and the Jekyll version is pinned in
`Gemfile.lock`.

## Data vs rendering

- **Data:** `_talks/*.md`, `_projects/*.md` (front matter only; every visitor-facing text is a
  `pl:`/`en:` map), `_data/profile.yml` (bio per language) and `_data/i18n.yml` (interface text,
  language list, tab order). README.md documents every field.
- **Rendering:** `_layouts/default.html` (top bar, switches, URLs), `_includes/tab-*.html`,
  `_includes/{talk-card,project-card,tags}.html`, `assets/`, and one-line pages per tab ×
  language (`talks/`, `talks/en/`, … and `index.html`, which renders Talks in Polish).
- Adding a language: add it to `i18n.languages` with its own section, add a stub page per tab
  under `<tab>/<lang>/`, and give every entry and the bio that language; the validator lists
  whatever is missing.
- A content change should never need a rendering change. If it does, the schema is missing a
  field: add it to `_plugins/validate_data.rb` (`SCHEMAS`), the include, and README.md together.

## Rules

- Talks sort by `order` ascending (1 = top); `order` is required and unique. The validator
  enforces this. Projects' `order` is optional; unordered ones sort last.
- Show the author any text you generate or translate before it is merged; they review wording.
- Colours are tokens in `assets/css/site.css` with a light and a dark set; never hard-code a
  colour in a rule.
- Talk URLs follow `https://wsztajerowski.github.io/<repo>/` and `/<repo>/slides.pdf`. Never
  create a top-level folder named like one of the author's repos (that repo's project site
  would take over the path), and `talks`, `projects`, `about` must never become repo names.

## Commands

```bash
bundle exec jekyll build     # also runs the data validation; fails with a list of problems
bundle exec jekyll serve     # http://localhost:4000
# no local Ruby 3 (macOS ships 2.6):
docker run --rm -v "$PWD":/site -w /site ruby:3.3 bash -c 'bundle install && bundle exec jekyll build'
# link check, as CI runs it:
docker run --rm -v "$PWD":/site -w /site lycheeverse/lychee --config lychee.toml --root-dir /site/_site '_site/**/*.html'
```
