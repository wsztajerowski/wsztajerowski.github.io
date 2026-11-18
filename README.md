# wsztajerowski.github.io

Source of <https://wsztajerowski.github.io/>: talks, projects and speaker bio,
in Polish and English, with a light and a dark theme.

## Pages

Three tabs, each in both languages. Polish is the default and has no language
suffix:

| Tab | Polish | English |
|---|---|---|
| Talks | `/talks/` (and `/`) | `/talks/en/` |
| Projects | `/projects/` | `/projects/en/` |
| About | `/about/` | `/about/en/` |

The PL | EN switch in the top bar keeps you on the same tab. The theme switch
follows the system setting until clicked, then remembers the choice in the
browser.

**Content and rendering are separate.** Content is YAML in `_data/`:
`talks.yml`, `projects.yml`, `profile.yml` and `i18n.yml` (interface text).
Rendering is `_layouts/`, `_includes/`, `assets/` and the one-line pages in
`talks/`, `projects/`, `about/` and `index.html`. Adding or editing content
never touches the rendering side.

## How to…

Every text a visitor reads exists in each language (`pl`, `en`). The build
fails if one is missing, so a half-translated entry can't be merged.

### Add a talk

Talks live in `_data/talks.yml`, one list entry each. **The Talks tab shows
them in the order they are listed**: paste the new entry where it should
appear, and move an entry to reorder. There is no numbering to keep up.

```yaml
- title:
    pl: Maszynka do Mielenia Złudzeń
    en: The Illusion Grinder
  subtitle:                                                     # optional
    pl: Cztery Kręgi Testowego Piekła dla Kodu Współbieżnego w Javie
    en: Four circles of testing hell for concurrent Java
  slides: https://wsztajerowski.github.io/illusion-grinder/    # optional
  pdf: https://wsztajerowski.github.io/illusion-grinder/slides.pdf  # optional
  repo: https://github.com/wsztajerowski/illusion-grinder       # optional
  recordings:                                                   # optional, one per event
    - event: JUG Łódź                                           # optional: where
      date: 2025-03-12                                          # optional: YYYY-MM-DD
      url: https://www.youtube.com/watch?v=…                    # required
  tags: [JUnit, Fray, jcstress, JMH]                            # optional
  abstract:                                                     # optional
    pl: |-
      Abstrakt po polsku, w Markdownie. Pusta linia zaczyna nowy akapit.
    en: |-
      The abstract in English, in Markdown. Blank lines make paragraphs.
```

Only `title` is required; every other part of the card appears only when the
entry has it, so a talk without published slides or a repo yet is fine.
`title` and `subtitle` may also be plain text when they stay the same in both
languages (as the SSI talk's original title does). Recordings are listed
under the buttons, one row per event (place, date, link), in the order
written. Quote a name that contains ` #` (`event: "Kielce JUG #7"`): in
YAML, unquoted, the rest of the line is a comment.

Open a PR. The check builds the site, validates the entry and tests every
link, including the new slides, PDF and repo, so **publish the talk's own
Pages site before merging the entry** (see below).

### Add a project

Projects live in `_data/projects.yml`, shown in the order listed, the same
way:

```yaml
- title: Benchmark as a Service (BaaS)     # or pl:/en: if it translates
  repo: https://github.com/wsztajerowski/benchmark-as-a-service
  homepage: https://…      # optional
  tags: [JMH, jcstress]    # optional
  description:
    pl: |-
      Jedno–dwa zdania o projekcie.
    en: |-
      One or two sentences on what it is.
```

### Change interface text

Buttons, tab names, the site name in the top bar and the footer are in
`_data/i18n.yml`, one section per language. Every language must have the same
keys.

### Update the bio or photo

Edit `_data/profile.yml`. `bio` has one entry per language (`lang`,
`tagline`, `text`); each language's About page shows its own. For the photo,
put the full-resolution original in `assets/img/` as `photo_download` (offered
to organisers) and a small web copy (~480 px) as `photo`:

```bash
sips -s format jpeg -s formatOptions 82 -Z 480 original.png --out assets/img/<name>-480.jpg
```

### Remove something

Delete its entry from the list.

## Validation

`_plugins/validate_data.rb` runs inside every build, locally and in CI, and
stops the build with a list of problems if:

* a required field is missing: talks need `title`; projects need `title`,
  `repo` and `description`;
* a translated field lacks a language, or names one the site doesn't speak;
* a field name is unknown (it's usually a typo, like `recoding`);
* a link isn't an `http(s)://` URL;
* a recording lacks an http(s) `url`, or its `date` isn't written YYYY-MM-DD;
* `_data/i18n.yml` languages don't all define the same interface keys;
* `_data/profile.yml` is missing its name or photo, a bio entry lacks its
  `lang`, `tagline` or `text`, a language has no bio or two, or a link lacks a
  label or URL.

## CI and publishing

[`.github/workflows/pages.yml`](.github/workflows/pages.yml):

| When | What |
|---|---|
| Pull request | Build + validate + link check. Nothing is published; the built site is attached to the run as the `github-pages` artifact. |
| Push to `main` | The same, then deploy. |
| Every Monday | The same, then deploy, to catch links that broke since (a renamed repo, a PDF no longer published). A failure emails you. |

The link checker is [lychee](https://lychee.cli.rs), configured in
`lychee.toml`.

## Convention for talk repos

Every talk repo publishes itself to GitHub Pages with a copy of
illusion-grinder's
[`publish-slides.yml`](https://github.com/wsztajerowski/illusion-grinder/blob/main/.github/workflows/publish-slides.yml),
so its URLs are always:

* slides: `https://wsztajerowski.github.io/<repo>/`
* PDF: `https://wsztajerowski.github.io/<repo>/slides.pdf`

**Never add a folder here named like a repo** (`illusion-grinder/`, …): the
project site of that repo would take over the path. The reverse holds too:
**never name a repo `talks`, `projects` or `about`**, or its project site
would replace that tab. Renaming a talk repo
changes both URLs, so update its entry in `_data/talks.yml` in the same breath; the
weekly link check exists to catch the case where that's forgotten.

## Run it locally

Needs Ruby 3.x (macOS's system Ruby 2.6 is too old):

```bash
bundle install
bundle exec jekyll serve      # http://localhost:4000
```

Or without a local Ruby:

```bash
docker run --rm -it -p 4000:4000 -v "$PWD":/site -w /site ruby:3.3 \
  bash -c 'bundle install && bundle exec jekyll serve --host 0.0.0.0'
```
