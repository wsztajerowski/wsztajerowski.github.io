# Main page and talk publishing — design

Agreed on 2026-09-24. Covers the user site and the move of the
self-sovereign-identity talk to GitHub.

## Goals

1. `https://wsztajerowski.github.io/` shows one page: **Talks**, **About**
   (speaker kit), **Projects**.
2. Adding a talk or project is a PR that touches data only; rendering is
   automatic.
3. Every talk follows the same publishing setup: Slidev, `publish-slides.yml`,
   deck at `/<repo>/`, PDF at `/<repo>/slides.pdf`.
4. Broken data or links fail loudly (PR check + weekly run), not silently.

## Decisions

| Topic | Decision |
|---|---|
| Hosting | Public repo `wsztajerowski.github.io` (the only repo GitHub serves at the bare root). |
| Generator | Jekyll 4, built by GitHub Actions (pinned version, custom plugins allowed), not GitHub's built-in Jekyll. |
| Data layout | One file per entry: `_talks/*.md`, `_projects/*.md`; front matter for facts, body for the abstract. Profile in `_data/profile.yml`. |
| Talk fields | Required: `title`, `order` (unique, 1 = top), `slides`, `pdf`, `repo`. Optional: `subtitle`, `recording`, `tags`. No language field (every talk has EN and PL slides, presented in Polish). No event/date for now. |
| About | A section on the main page (not a separate page): photo (web copy) + full-resolution download, one bio per language (EN and PL, with a tagline each) behind a PL/EN switch, a copy button, links. Short bios were dropped at the author's request (2026-09-29). |
| Projects | benchmark-as-a-service, java-wonderland, lynx-journal. |
| Validation | `_plugins/validate_data.rb`, run on every build: required fields, unknown keys, URL shape, unique talk `order`, non-empty body, profile completeness. |
| Link check | lychee on the built site on every PR, push and weekly (Mondays). |
| Go-live | Site built in a PR against a stub `main`; the author merges once the real bio/photo are in. |
| SSI talk | Moved from Bitbucket (left untouched) to public GitHub `self-sovereign-identity`; ported 1:1 from AsciiDoc/reveal.js to Slidev, recreating the reveal.js *moon* look; draw.io diagrams become Mermaid; asciimath becomes KaTeX; print_pdf.py, the committed PDF and the AsciiDoc sources removed from `main`. |

## Out of scope for now

Event/date per talk, upcoming talks, a custom domain, per-talk pages, search or
filtering.

## Revision 2026-09-29 — tabs, languages, theme

| Topic | Decision |
|---|---|
| Structure | Three tabs instead of one long page: Talks (default), Projects, About. |
| Languages | Whole site in Polish (default) and English. URLs: `/<tab>/` (PL) and `/<tab>/en/` (EN), with `/` rendering Talks in Polish. Static pages, so every link opens in its language and works without JavaScript. |
| Switches | PL/EN and a light/dark theme toggle in the top-right corner. The theme follows the system until chosen, then is remembered (localStorage), applied before first paint. |
| Site name | "Wiktor Sztajerowski — prezentacje i projekty" / "Wiktor Sztajerowski — talks & code". |
| Data | Each talk/project stays one file, with `pl:`/`en:` maps for every visitor-facing text; interface text in `_data/i18n.yml`; bio per language in `_data/profile.yml`. The validator requires every language everywhere. |
| Projects | One card per row (a list), not a grid. |
