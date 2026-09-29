# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The Jekyll source of https://wsztajerowski.github.io/, a user site: one page with three sections
(Talks, About, Projects). Built and deployed by GitHub Actions (`.github/workflows/pages.yml`),
not by GitHub's built-in Jekyll, so `_plugins/` runs and the Jekyll version is pinned in
`Gemfile.lock`.

## Data vs rendering

- **Data:** `_talks/*.md`, `_projects/*.md` (front matter + Markdown body) and
  `_data/profile.yml`. README.md documents every field.
- **Rendering:** `index.html` (section order, sorting), `_layouts/default.html`,
  `_includes/{talk-card,project-card,about,tags}.html`, `assets/`.
- A content change should never need a rendering change. If it does, the schema is missing a
  field: add it to `_plugins/validate_data.rb` (`SCHEMAS`), the include, and README.md together.

## Rules

- Talks sort by `order` ascending (1 = top); `order` is required and unique. The validator
  enforces this. Projects' `order` is optional; unordered ones sort last.
- `draft: true` in front matter marks text written by Claude that the author hasn't reviewed.
  It has no effect on rendering; don't remove it unless the author has approved the text.
- Talk URLs follow `https://wsztajerowski.github.io/<repo>/` and `/<repo>/slides.pdf`. Never
  create a top-level folder named like one of the author's repos: that repo's project site
  would take over the path.

## Commands

```bash
bundle exec jekyll build     # also runs the data validation; fails with a list of problems
bundle exec jekyll serve     # http://localhost:4000
# no local Ruby 3 (macOS ships 2.6):
docker run --rm -v "$PWD":/site -w /site ruby:3.3 bash -c 'bundle install && bundle exec jekyll build'
# link check, as CI runs it:
docker run --rm -v "$PWD":/site -w /site lycheeverse/lychee --config lychee.toml --root-dir /site/_site '_site/**/*.html'
```
