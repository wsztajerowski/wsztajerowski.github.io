# wsztajerowski.github.io

Source of <https://wsztajerowski.github.io/>: talks, speaker bio and projects on
one page.

**Content and rendering are separate.** Content is Markdown/YAML under
`_talks/`, `_projects/` and `_data/profile.yml`. Rendering is `index.html`,
`_layouts/`, `_includes/` and `assets/`. Adding or editing content never touches
the rendering side.

## How to…

### Add a talk

Create `_talks/<repo-name>.md`:

```markdown
---
title: The Illusion Grinder
subtitle: Four circles of testing hell for concurrent Java   # optional
order: 1                                                      # required, unique
slides: https://wsztajerowski.github.io/illusion-grinder/
pdf: https://wsztajerowski.github.io/illusion-grinder/slides.pdf
repo: https://github.com/wsztajerowski/illusion-grinder
recording: https://www.youtube.com/watch?v=…                  # optional
tags: [JUnit, Fray, jcstress, JMH]                            # optional
---
The abstract, in Markdown. Blank lines make paragraphs.
```

**`order` decides where the talk appears: `1` is at the top.** It is required
and must be unique, so a new talk usually means bumping the others by one.

Open a PR. The check builds the site, validates the file and tests every
link, including the new slides, PDF and repo, so **publish the talk's own
Pages site before merging the entry** (see below).

### Add a project

Create `_projects/<repo-name>.md`:

```markdown
---
title: Benchmark as a Service (BaaS)
repo: https://github.com/wsztajerowski/benchmark-as-a-service
homepage: https://…      # optional
order: 1                 # optional; projects without one go last
tags: [JMH, jcstress]    # optional
---
One or two sentences on what it is.
```

### Update the bio or photo

Edit `_data/profile.yml`. `bio` has one entry per language (`lang`, `label`
for the switch button, `tagline`, `text`); the first entry is shown by default
and the page gets a language switch as soon as there are two. For the photo,
put the full-resolution original in `assets/img/` as `photo_download` (offered
to organisers) and a small web copy (~480 px) as `photo`:

```bash
sips -s format jpeg -s formatOptions 82 -Z 480 original.png --out assets/img/<name>-480.jpg
```

### Remove something

Delete its file.

## Validation

`_plugins/validate_data.rb` runs inside every build, locally and in CI, and
stops the build with a list of problems if:

* a required field is missing: talks need `title`, `order`, `slides`, `pdf`
  and `repo`; projects need `title` and `repo`;
* a field name is unknown (it's usually a typo, like `recoding`);
* a link isn't an `http(s)://` URL;
* two talks share an `order`, or `order` isn't a positive whole number;
* the abstract/description body is empty;
* `_data/profile.yml` is missing its name or photo, a bio entry lacks its
  `lang`, `label`, `tagline` or `text`, a language appears twice, or a link
  lacks a label or URL.

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
project site of that repo would take over the path. Renaming a talk repo
changes both URLs, so update its `_talks/` entry in the same breath; the
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
