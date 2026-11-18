# parijat-rust-refresher

A personal refresher for the Rust programming language and ecosystem. Start a session on **Quizzes**. Use the mixed diagnostic to pick lessons, then drill by topic. For a lookup, go straight to search or the syntax-to-concept index.

## Pre-requisites

The development and build environment is **macOS** with [Homebrew](https://brew.sh/) (`brew`) installed. Linux and Windows are not supported.

Install the tools:

```bash
brew install bash rustup graphviz shellcheck
rustup toolchain install stable --profile minimal
cargo +stable install mdbook --version 0.5.4 --locked
cargo +stable install mdbook-quiz --version 0.5.0 --locked
```

Homebrew's `rustup` is keg-only: put `$(brew --prefix rustup)/bin` and `~/.cargo/bin` on your `PATH`. The scripts run under `/usr/bin/env bash` and need Bash 5 or newer, so Homebrew's `bash` must precede `/bin/bash` (Bash 3.2) on your `PATH`.

Enable the repository's Git hooks once per clone, from the repository root:

```bash
git config core.hooksPath scripts/git-hooks
```

Every script checks for all of the following tools and fails if any is missing or has a different version:

| Tool          | Required version (in `<tool> --version` output)  |
| ------------- | ------------------------------------------------ |
| `mdbook`      | `mdbook v0.5.4`                                  |
| `mdbook-quiz` | `mdbook-quiz 0.5.0`                              |
| `dot`         | `graphviz version 16.1.1` (build number ignored) |
| `shellcheck`  | `version: 0.11.0`                                |
| `rustup`      | Any version that can run the `stable` toolchain  |

**Important:** If you install a different version of a pinned tool (for example, after `brew upgrade graphviz shellcheck`), update `TOOL_VERSIONS` at the top of `scripts/common.sh` and the table above.

## Build and check

All scripts live in `scripts/` and work from any directory.

| Command                          | Effect                                                                                                                                                                                                  |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `scripts/build.sh`               | Build `book/` with both quizzes and the checked-in SVGs. Leave the stdout fixtures alone.                                                                                                               |
| `scripts/build.sh check`         | Test the book’s Rust examples as edition 2024, run `cargo test` on the `examples/` workspace, then run each example package with an `output.txt` and diff its stdout against that file.                 |
| `scripts/build.sh update-output` | After an intentional example change, rerun each example package with an `output.txt` and replace that file only if the run succeeds. Review the diff.                                                   |
| `scripts/build_diagrams.sh`      | Render diagrams. Run if you added/changed something in the `diagrams/` directory.                                                                                                                       |
| `scripts/common.sh`              | Not run directly. Sourced by the other scripts: tool and version checks (`TOOL_VERSIONS`), Rust toolchain setup, temp-file cleanup. Changes the working directory to the repository root.               |
| `scripts/lint_scripts.sh`        | Run ShellCheck on every shell script in `scripts/`, including Git hooks. Fails on any finding. See [Edit a shell script](#edit-a-shell-script).                                                         |
| `scripts/git-hooks/pre-commit`   | Not run directly. Git runs it on `git commit` once `core.hooksPath` is set (see [Pre-requisites](#pre-requisites)). Runs `scripts/lint_scripts.sh` if the commit touches `scripts/` or `.shellcheckrc`. |

Open `book/index.html` in a browser (`open book/index.html`).

## Project structure

| Path                  | Purpose                                                                                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `book.toml`           | mdBook configuration: source directory, output directory, Rust edition for `mdbook test`, quiz preprocessor.                                                       |
| `rust-toolchain.toml` | Selects the `stable` Rust toolchain.                                                                                                                               |
| `.shellcheckrc`       | ShellCheck configuration, used by `scripts/lint_scripts.sh` and editor integrations.                                                                               |
| `src/`                | Book source. `SUMMARY.md` defines the table of contents; one Markdown file per lesson, plus `quizzes.md` and `syntax-to-concept.md`.                               |
| `src/images/`         | Rendered SVG diagrams, checked in. Generated from `diagrams/`; do not edit by hand.                                                                                |
| `diagrams/`           | Graphviz DOT sources for the SVGs in `src/images/`.                                                                                                                |
| `quizzes/`            | `mdbook-quiz` TOML files, included from `src/quizzes.md`.                                                                                                          |
| `examples/`           | Cargo workspace of example packages included in lessons. Add/remove packages in `members` of `examples/Cargo.toml`; `examples/Cargo.lock` is the shared lock file. |
| `examples/<package>/` | One example package. An optional `output.txt` holds its expected stdout, checked by `scripts/build.sh check`.                                                      |
| `scripts/`            | Build and check scripts (see [Build and check](#build-and-check)).                                                                                                 |
| `links.md`            | Reference links for further reading.                                                                                                                               |
| `book/`               | Build output (ignored by Git).                                                                                                                                     |

## Add an example package

1. From the repository root, run `cargo new --vcs none examples/my-demo`. Cargo adds `my-demo` to `members` in `examples/Cargo.toml` (tidy the formatting) and makes the package inherit `edition` and `publish` from the workspace.
2. Run `cargo build --manifest-path examples/Cargo.toml` to update `examples/Cargo.lock`. The scripts pass `--locked` and run offline, so they never update it. Repeat after changing dependencies.
3. Include the code in a lesson with `{{#include ../examples/my-demo/src/main.rs}}`.
4. If the lesson shows stdout, run `touch examples/my-demo/output.txt`, then `scripts/build.sh update-output` (it fills only existing `output.txt` files). Include it with `{{#include ../examples/my-demo/output.txt}}`.
5. Run `scripts/build.sh check`. Commit the package, `examples/Cargo.toml`, and `examples/Cargo.lock` together.

To remove a package: delete its directory, its entry in `members`, and its `{{#include}}` lines, then repeat step 2.

## Add a quiz

1. Put a TOML file under `quizzes/`. Use a `[[questions]]` entry per question. Copy a starter of the same type: `Tracing` for program behavior, `MultipleChoice` for distinctions, or `ShortAnswer` for an exact, unambiguous result. Explain the answer in `context`.
2. Preserve an existing question’s `id` when editing it. For a **new** question, delete any copied `id`; the plugin writes a new UUID on build. Commit newly generated IDs with the quiz. The starters already have IDs.
3. Include `{{#quiz ../quizzes/your-topic.toml}}` in `src/quizzes.md` and add visible review links to lesson sections. Keep lessons quiz-free. Use standalone, deterministic, edition-independent tracing programs: this plugin invokes `rustc` without an edition flag. Put edition-sensitive examples and open-ended repairs in Markdown instead. Hide sample solutions and rubrics in `<details>` and test the Rust fences with `scripts/build.sh check`.
4. Build, check, and try the quiz in a browser. Confirm you can find its review links before answering.

## Extend the syntax index

Edit the table in `src/syntax-to-concept.md` by hand. Put syntax in code spans, distinguish meanings by context (for example, `&` in an expression versus a type), and link to the lesson rather than duplicating its explanation. Browser Find handles literal symbols; book search needs no changes.

## Regenerate a diagram

Draft Graphviz DOT by hand or with an LLM. Keep files directly in `diagrams/` with topic-prefixed names, such as `ownership-shared-borrow.dot`. Use readable labels and clear arrows. Give the graph a light background if dark labels would disappear in a dark theme.

Edit the DOT, not the SVG. Run `scripts/build_diagrams.sh`: it matches stems in `src/images/`, replacing an SVG only after `dot -Tsvg` succeeds. It leaves unrelated SVGs alone. Freshness uses **file timestamps**, not Git status: `touch diagrams/ownership-shared-borrow.dot` to force a render on the next run.

Run `scripts/build.sh` and preview the chapter at reading width in both light and dark themes. Commit the changed DOT and regenerated SVG together.

## Edit a shell script

Keep shell scripts in `scripts/` (Git hooks in `scripts/git-hooks/`), and start each with `#!/usr/bin/env bash`, `set -euo pipefail`, and `source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"` (`../common.sh` from a hook).

After adding or changing a script, run `scripts/lint_scripts.sh` and fix every finding; the pre-commit hook enforces this, but `git commit --no-verify` skips it. Do not pass flags to `shellcheck` on the command line; put project-wide settings in `.shellcheckrc`. Suppress a finding only when it is a false positive, with `# shellcheck disable=SCxxxx` on the line above the offending command and a comment explaining why.

The hook lints the working tree, not the staged snapshot: stage all your script changes before committing, or the result may not match what you commit.
