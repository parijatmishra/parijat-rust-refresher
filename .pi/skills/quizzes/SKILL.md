---
name: quizzes
description: Draft, revise, and verify inline mdbook-quiz quizzes for Rust Refresher lessons.
---

# Chapter quizzes

## Draft

- Read `README.md`, locate the chapter in `src/SUMMARY.md`, and read it and relevant included examples. Ask if the target is unclear.
- Propose numbered questions with answers and brief explanations. Refine in chat; write only when asked. Implement approved sets without adding questions. Flag unclear or incorrect lesson content instead of rewriting it or grading against it.
- Cover the entire chapter; test its main takeaways. Focus each question on one conceptual decision and name a distinct skill or misconception to review after a wrong answer; revise or cut vague or duplicate targets.
- Use direct recall or short answers for small, exact facts. For concepts, prefer a concrete scenario (code and an action) followed by a predicted outcome. Test the learner's mental model rather than command-sequence recognition, unless command syntax is the target.
- Make prompts self-contained, state assumptions, and accept valid answers. Use small variations from lesson examples to test understanding rather than copying, without introducing untaught concepts.
- Use plausible but clearly wrong distractors. For conceptual questions, each should expose a specific misconception (e.g. compilation versus execution or formatting), not merely malformed command syntax. Use syntax alternatives when syntax is the target.
- When the user says "short quiz" he means a few focused questions, not that the text of each question is short; do not strip useful scenario context just to shorten prompts. Prefer clarity over minimal word count.
- In `context`, briefly explain the reasoning and correct the central misconception. State the key distinction rather than repeating every prompt detail.

## Place and update

- Use `quizzes/<chapter-stem>.toml`. Put one standalone `{{#quiz ../quizzes/<stem>.toml}}` immediately after the chapter title, before prose, with blank lines around it. Resolve the path relative to the chapter. Reuse existing directives; add no quiz heading or TOC entry.
- Find the quiz via its directive. Review `git diff HEAD -- <chapter-path>` for local edits or `git diff <base> HEAD -- <chapter-path>` for committed edits against a known baseline. Otherwise compare the current chapter and quiz and report that fallback.
- Check affected prompts, answers, distractors, and feedback. Add useful coverage, revise stale questions, and cut material no longer taught. Preserve unaffected questions and order.
- Keep retained IDs, even when answers change. Omit `id` for new questions and replacements that test a different concept; keep IDs generated on build.
- Move or repair the directive only if needed. Ask before removing an empty quiz. Leave lesson prose and unrelated quizzes unchanged.

## TOML

All quizzes must be full-screen while in progress. Ensure `book.toml` has this global preprocessor setting (not in each quiz file):

```toml
[preprocessor.quiz]
fullscreen = true
```

Use one `[[questions]]` table per question. There are three types of questions.

### MultipleChoice

Can have exactly one, or several correct options.

```toml
[[questions]]
type = "MultipleChoice"
prompt.prompt = "Which command checks a package without building an executable?"
prompt.distractors = ["cargo build", "cargo run"]
answer.answer = "cargo check"
context = "`cargo check` checks the code without completing code generation."
```

Use an array in `answer.answer` for select-all: every correct choice and no distractors. True/false uses one distractor.

### ShortAnswer

Use must type verbatim text that matches `answer.answer`. Keep the expected text short with minimal punctuation---one to three words on a single line, or a few lines with one word per line are ideal.

```toml
[[questions]]
type = "ShortAnswer"
prompt.prompt = "What is the Cargo manifest filename? Type only the filename."
prompt.response = "short"
answer.answer = "Cargo.toml"
context = "Cargo reads package metadata and dependencies from `Cargo.toml`."
```

List other accepted strings in `answer.alternatives`. Use `short`, `long`, or `code` for single-line, multiline, or editor input. All match text; specify the expected format and use only when text matching is fair.

### Tracing

Use chooses from two options: (a) DOES compile (b) does NOT compile. If user chooses (a), he has to then supply what would be printed on stdout when the program is run.

```toml
[[questions]]
type = "Tracing"
prompt.program = '''
fn main() {
    println!("{}", 2 + 3);
}
'''
answer.doesCompile = true
answer.stdout = "5"
context = "The addition yields `5`, which `println!` writes to stdout."

[[questions]]
type = "Tracing"
prompt.program = '''
fn main() {
    let _: u8 = "5";
}
'''
answer.doesCompile = false
answer.lineNumber = 2
context = "A string slice cannot initialize a `u8`."
```

For compile errors, give the 1-based error line and omit `answer.stdout`. Use standalone, deterministic programs; the plugin invokes `rustc` without an edition flag.

For shared setup, define Markdown under a key in `[multipart]` and set `multipart` to that key on each question. `promptExplanation = true` asks for ungraded justification. Use Markdown exercises with hidden sample solutions for open-ended prompts or code repairs.

## Verify

Ensure the full-screen setting above is present, then run `scripts/build_book.sh` from the root to validate quizzes and generate IDs. Report the build result.
