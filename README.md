# parijat-rust-refresher

A personal refresher for the Rust programming language and ecosystem. Start a session on **Quizzes**. Use the mixed diagnostic to pick lessons, then drill by topic. For a lookup, go straight to search or the syntax-to-concept index.

## Local setup (macOS or Linux, Bash)

Install [rustup](https://rustup.rs/) and run:

```bash
rustup toolchain install stable --profile minimal
cargo +stable install mdbook --version 0.5.4 --locked
```

From the [mdbook-quiz 0.5.0 release](https://github.com/cognitive-engineering-lab/mdbook-quiz/releases/tag/v0.5.0), download the **bare** archive for your OS and CPU, not the full archive. Extract the executable `mdbook-quiz` into a directory on `PATH` (for example, `~/.cargo/bin`, alongside `mdbook`). Check with `mdbook-quiz --version`.

Setup can require a network connection. Builds and checks use **locally installed stable**, with no network update or tool installation. Run `rustup update stable` explicitly when you want the current release.

## Build and check

| Command | Effect |
| --- | --- |
| `./build.sh` | Build `book/` with both quizzes and the checked-in SVGs. Leave the stdout fixture alone. |
| `./build.sh check` | Test the book’s Rust examples as edition 2024, run the locked demo, and diff its stdout against `examples/ownership-demo/output.txt`. |
| `./build.sh update-output` | After an intentional demo change, replace the fixture only if the demo succeeds. Review the diff. |
| `./build_diagrams.sh` | Render only missing or stale diagrams. Separate from all book commands. |

Open `book/index.html` in a browser (`open book/index.html` on macOS, `xdg-open book/index.html` on Linux), then select **Quizzes** in the sidebar. Both scripts also accept invocation by path from another working directory.

## Add a quiz

1. Put a TOML file under `quizzes/`. Use a `[[questions]]` entry per question. Copy a starter of the same type: `Tracing` for program behavior, `MultipleChoice` for distinctions, or `ShortAnswer` for an exact, unambiguous result. Explain the answer in `context`.
2. Preserve an existing question’s `id` when editing it. For a **new** question, delete any copied `id`; the plugin writes a new UUID on build. Commit newly generated IDs with the quiz. The starters already have IDs.
3. Include `{{#quiz ../quizzes/your-topic.toml}}` in `src/quizzes.md` and add visible review links to lesson sections. Keep lessons quiz-free. Use standalone, deterministic, edition-independent tracing programs: this plugin invokes `rustc` without an edition flag. Put edition-sensitive examples and open-ended repairs in Markdown instead. Hide sample solutions and rubrics in `<details>` and test the Rust fences with `./build.sh check`.
4. Build, check, and try the quiz in a browser. Confirm you can find its review links before answering.

## Extend the syntax index

Edit the table in `src/syntax-to-concept.md` by hand. Put syntax in code spans, distinguish meanings by context (for example, `&` in an expression versus a type), and link to the lesson rather than duplicating its explanation. Browser Find handles literal symbols; book search needs no changes.

## Regenerate a diagram

Draft Graphviz DOT by hand or with an LLM. Keep files directly in `diagrams/` with topic-prefixed names, such as `ownership-shared-borrow.dot`. Use readable labels and clear arrows. Give the graph a light background if dark labels would disappear in a dark theme.

Edit the DOT, not the SVG. Install Graphviz only if rendering is needed (`brew install graphviz` on macOS, or install your Linux distribution’s `graphviz` package). Run `./build_diagrams.sh`: it matches stems in `src/images/`, replacing an SVG only after `dot -Tsvg` succeeds. It leaves unrelated SVGs alone. Freshness uses **file timestamps**, not Git status: `touch diagrams/ownership-shared-borrow.dot` to force a render on the next run.

Run `./build.sh` and preview the chapter at reading width in both light and dark themes. Commit the changed DOT and regenerated SVG together. Readers need no Graphviz for book builds or checks.
