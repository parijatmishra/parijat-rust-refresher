# parijat-rust-refresher

A personal refresher for the Rust programming language and ecosystem. Start a session on **Quizzes**. Use the mixed diagnostic to pick lessons, then drill by topic. For a lookup, go straight to search or the syntax-to-concept index.

## Pre-requisites

The development and build environment is **macOS** with [Homebrew](https://brew.sh/) (`brew`) installed. Linux and Windows are not supported. Homebrew requires the Xcode Command Line Tools, which provide `git`. The scripts assume the macOS versions of standard command-line utilities (`mktemp`, `diff`, `chmod`, …).

Install the tools. Use the mdbook and mdbook-quiz versions pinned in `TOOL_VERSIONS` at the top of `scripts/common.sh`:

```bash
brew install bash rustup graphviz shellcheck jq   # jq is also in macOS 15 and later
rustup toolchain install stable --profile minimal
cargo +stable install mdbook --version <version> --locked
cargo +stable install mdbook-quiz --version <version> --locked
```

Homebrew's `rustup` is keg-only: put `$(brew --prefix rustup)/bin` and `~/.cargo/bin` on your `PATH`. The scripts run under `/usr/bin/env bash` and need Bash 5 or newer, so Homebrew's `bash` must precede `/bin/bash` (Bash 3.2) on your `PATH`.

Enable the repository's Git hooks once per clone, from the repository root:

```bash
git config core.hooksPath scripts/git-hooks
```

Every script first checks the tools listed at the top of `scripts/common.sh`, the single source of truth: `TOOL_VERSIONS` (exact versions) and `REQUIRED_TOOLS` (any version). On failure it points here. After installing a different mdbook or mdbook-quiz version, update `TOOL_VERSIONS`; after upgrading mdbook, also recheck [how `build_book.sh` tests code blocks](#how-build_booksh-tests-code-blocks).

## Build and check

All scripts live in `scripts/`, work from any directory, and take no arguments: one script per use case.

| Script                              | Use when                                                                                                           | Effect                                                                                                                                                                                                                                                                              |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `scripts/build_book.sh`             | You edited lessons, quizzes, diagrams, or example code included in lessons                                         | Render `diagrams/` to `src/diagrams/`, build the `examples/` workspace (dev profile), test the book’s Rust code blocks (edition 2024) against it with `mdbook test`, then build `book/` only if the tests pass. Writes only `src/diagrams/`, `examples/target/`, and `book/`.       |
| `scripts/check_examples.sh`         | You added or changed code in `examples/`                                                                           | Build every target of the `examples/` workspace, run its tests, then run every binary and compare its exit status and stdout with its [expected files](#expected-output). Compiler warnings do not fail it.                                                                         |
| `scripts/update_example_outputs.sh` | You changed an example’s output on purpose, or added a binary                                                      | Run every binary and write its stdout to its expected file, if it exits with the expected status. Review the diff.                                                                                                                                                                  |
| `scripts/lint_scripts.sh`           | You added or changed a shell script                                                                                | Run ShellCheck on every shell script in `scripts/`, including Git hooks. Fails on any finding. See [Edit a shell script](#edit-a-shell-script).                                                                                                                                     |
| `scripts/check_all.sh`              | Before committing or pushing                                                                                       | Run `lint_scripts.sh`, `check_examples.sh`, and `build_book.sh`, stopping at the first failure.                                                                                                                                                                                     |
| `scripts/git-hooks/pre-commit`      | Not run directly: Git runs it on `git commit` once `core.hooksPath` is set (see [Pre-requisites](#pre-requisites)) | If the commit touches `scripts/` or `.shellcheckrc`, run `lint_scripts.sh`.                                                                                                                                                                                                         |
| `scripts/common.sh`                 | Not run directly: sourced by the other scripts                                                                     | Tool lists you edit by hand (`TOOL_VERSIONS`, `REQUIRED_TOOLS`), then shared setup: reject arguments, check tools, change to the repository root, create a temporary directory removed on exit. Also runs example binaries for `check_examples.sh` and `update_example_outputs.sh`. |

Build the book only with `scripts/build_book.sh`. Plain `mdbook build` or `mdbook serve` does not render `diagrams/`, so on a fresh clone the images are missing.

Open `book/index.html` in a browser (`open book/index.html`).

To preview while writing, run `mdbook serve --open`: it rebuilds and reloads on every save, and builds even while code blocks fail. It skips the tool checks, the diagrams, the examples build, and the tests: run `scripts/build_book.sh` once first (so `src/diagrams/` exists) and again after changing a diagram, and before committing.

## Project structure

| Path                           | Purpose                                                                                                                                                            |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `book.toml`                    | mdBook configuration: source directory, output directory, Rust edition for `mdbook test`, quiz preprocessor.                                                       |
| `rust-toolchain.toml`          | Selects the `stable` Rust toolchain.                                                                                                                               |
| `.shellcheckrc`                | ShellCheck configuration, used by `scripts/lint_scripts.sh` and editor integrations.                                                                               |
| `src/`                         | Book source. `SUMMARY.md` defines the table of contents; one Markdown file per lesson, plus `quizzes.md` and `syntax-to-concept.md`.                               |
| `diagrams/`                    | Graphviz DOT sources for the book’s diagrams.                                                                                                                      |
| `src/diagrams/`                | SVGs rendered from `diagrams/` by `scripts/build_book.sh` (ignored by Git). Lessons link to `diagrams/<stem>.svg`.                                                 |
| `quizzes/`                     | `mdbook-quiz` TOML files, included from `src/quizzes.md`.                                                                                                          |
| `examples/`                    | Cargo workspace of example packages included in lessons. Add/remove packages in `members` of `examples/Cargo.toml`; `examples/Cargo.lock` is the shared lock file. |
| `examples/<package>/expected/` | Expected stdout (and optionally exit status) of each binary in the package. See [Expected output](#expected-output).                                               |
| `scripts/`                     | Build and check scripts (see [Build and check](#build-and-check)).                                                                                                 |
| `links.md`                     | Reference links for further reading.                                                                                                                               |
| `book/`                        | Build output (ignored by Git).                                                                                                                                     |

## Add or change example code

Lessons include code from the `examples/` workspace. To add a package:

1. From the repository root, run `cargo new --vcs none examples/my-demo`. Cargo adds `my-demo` to `members` in `examples/Cargo.toml` (tidy the formatting) and makes the package inherit `edition` and `publish` from the workspace.
2. Run `cargo build --manifest-path examples/Cargo.toml` to update `examples/Cargo.lock`. The scripts pass `--locked`, so they never update it. Repeat after changing dependencies.
3. If a binary should exit with a non-zero status (for example, a demo that panics exits with `101`), write that number to `examples/my-demo/expected/<binary>.status`.
4. Run `scripts/update_example_outputs.sh` to create `examples/my-demo/expected/<binary>.stdout`, and check its content.
5. Include the code in a lesson (see below), and its output with `{{#include ../examples/my-demo/expected/my-demo.stdout}}` in a ` ```text ` block.
6. Run `scripts/check_examples.sh` and `scripts/build_book.sh`. Commit the package (including `expected/`), `examples/Cargo.toml`, and `examples/Cargo.lock` together.

To remove a package: delete its directory, its entry in `members`, and its `{{#include}}` lines, then repeat step 2.

After changing code in `examples/`, run `scripts/check_examples.sh`. If a lesson includes the changed code, also run `scripts/build_book.sh`.

### Expected output

The scripts find every binary in the workspace through `cargo metadata`; there is no list to maintain. Each binary runs without arguments, with stdin from `/dev/null`, and must terminate on its own. For a binary `<binary>` in package directory `<package>`:

| File                                          | Content                                                      | Required                                   |
| --------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------ |
| `examples/<package>/expected/<binary>.stdout` | Its expected stdout. Written by `update_example_outputs.sh`. | Yes: `check_examples.sh` fails without it. |
| `examples/<package>/expected/<binary>.status` | Its expected exit status, such as `101`.                     | No: the default is `0`.                    |

### Include example code in a lesson

Wrap `{{#include ../examples/my-demo/src/main.rs}}` in a plain ` ```rust ` block. The code may use workspace libraries and external crates; no hidden `extern crate` lines are needed. Rules:

- **One version per crate.** Use the same (current) version of an external crate in every package. A code block cannot name a crate that the `examples/` build contains more than once; see [Duplicate crates](#duplicate-crates).
- **Dev profile only.** All code in `examples/` and every ` ```rust ` block is built with the dev profile: debug assertions and overflow checks are on. To show release-only behavior (such as integer overflow wrapping), write the block inline with ` ```rust,ignore ` (or ` ```rust,should_panic ` to show the dev-profile panic), and paste the release output into the lesson by hand; no script reproduces it.
- **Single-file binaries.** `mdbook test` compiles the included text on its own, so an included `main.rs` cannot use `mod foo;` from another file.

### How `build_book.sh` tests code blocks

`mdbook test` runs `rustdoc` from `PATH` on each chapter and accepts only `-L` search directories. `-L examples/target/debug/deps` fails with `E0464` (multiple candidates for an `rlib`) once that directory holds several builds of a crate, which happens after dependency or feature changes. So `build_book.sh`:

1. Runs `cargo build --workspace` and reads, with `jq`, the exact file of every library in the current build from Cargo’s JSON messages.
2. Puts a temporary `rustdoc` wrapper first on `PATH` for `mdbook test`. It adds `--extern <crate>=<file>` for each library built exactly once, and `-L dependency=examples/target/debug/deps` for their dependencies.

This relies on mdbook (pinned at 0.5.4) running `rustdoc` by name; recheck after upgrading mdbook.

### Duplicate crates

`build_book.sh` prints this warning when the `examples/` build contains a crate more than once:

```text
Warning: Crate(s) built more than once in examples/: <names>. Code blocks cannot use them directly; see README.md (Duplicate crates).
```

Usually there are two versions of the crate, often pulled in indirectly by external crates; sometimes one version is built twice with different features (for example, once for a build script). `build_book.sh` passes no `--extern` for these crates and continues. Libraries that depend on them still work, so the warning is harmless unless a code block names one of them directly; that block fails with `E0433` (cannot find module or crate).

To find out which packages pull in each copy, run these from the repository root:

```bash
cargo tree --manifest-path examples/Cargo.toml --duplicates
cargo tree --manifest-path examples/Cargo.toml --invert <crate>@<version>
```

If `--duplicates` lists nothing for the crate, it is one version with two feature sets; `cargo tree --manifest-path examples/Cargo.toml --invert <crate> --edges features` shows which features each dependent enables.

To fix a failing code block:

- If your own packages require different versions, use the same requirement in each `Cargo.toml`, then run `cargo update --manifest-path examples/Cargo.toml -p <crate>` and commit `examples/Cargo.lock`.
- If an external crate pulls in another version that you cannot align, do not name the crate in the code block: use it through a workspace library that re-exports it (`pub use <crate>;`), or mark the block ` ```rust,ignore `.

## Add a quiz

1. Put a TOML file under `quizzes/`. Use a `[[questions]]` entry per question. Copy a starter of the same type: `Tracing` for program behavior, `MultipleChoice` for distinctions, or `ShortAnswer` for an exact, unambiguous result. Explain the answer in `context`.
2. Preserve an existing question’s `id` when editing it. For a **new** question, delete any copied `id`; the plugin writes a new UUID on build. Commit newly generated IDs with the quiz. The starters already have IDs.
3. Include `{{#quiz ../quizzes/your-topic.toml}}` in `src/quizzes.md` and add visible review links to lesson sections. Keep lessons quiz-free. Use standalone, deterministic, edition-independent tracing programs: this plugin invokes `rustc` without an edition flag. Put edition-sensitive examples and open-ended repairs in Markdown instead. Hide sample solutions and rubrics in `<details>` and test the Rust fences with `scripts/build_book.sh`.
4. Build, check, and try the quiz in a browser. Confirm you can find its review links before answering.

## Extend the syntax index

Edit the table in `src/syntax-to-concept.md` by hand. Put syntax in code spans, distinguish meanings by context (for example, `&` in an expression versus a type), and link to the lesson rather than duplicating its explanation. Browser Find handles literal symbols; book search needs no changes.

## Add or change a diagram

Draft Graphviz DOT by hand or with an LLM. Keep files directly in `diagrams/` with topic-prefixed names, such as `ownership-shared-borrow.dot`. Use readable labels and clear arrows. Give the graph a light background if dark labels would disappear in a dark theme.

In a lesson, link to the rendered SVG: `![Description](diagrams/ownership-shared-borrow.svg)`. Run `scripts/build_book.sh`: it renders every DOT file, then builds the book. Preview the chapter at reading width in both light and dark themes. Commit only the DOT file; the SVGs are generated.

## Edit a shell script

Keep shell scripts in `scripts/` (Git hooks in `scripts/git-hooks/`), and start each with:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"   # ../common.sh from a hook
```

`common.sh` rejects arguments, checks tools, changes to the repository root, and provides `TMP_DIR`; the script needs no setup of its own.

After adding or changing a script, run `scripts/lint_scripts.sh` and fix every finding; the pre-commit hook enforces this, but `git commit --no-verify` skips it. Do not pass flags to `shellcheck` on the command line; put project-wide settings in `.shellcheckrc`. Suppress a finding only when it is a false positive, with `# shellcheck disable=SCxxxx` on the line above the offending command and a comment explaining why.
