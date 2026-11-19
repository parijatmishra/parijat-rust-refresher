# Introduction

Coming back to Rust after a while and need a refresher?


| Goal | Action |
| --- | --- |
| Unsure what a particular Rust syntax means? | See [Syntax Index](02-syntax.md) |
| Unsure if you know some Rust concept? | See the lessons below, and do the quizzes at the top |
| Want to practice writing Rust code? | Do some of the exercises from [100 Exercises To Learn Rust][100-ex-rs] or [rustlings][rustlings] |
| Want to find cheatsheets, manuals, books? | See [Resources](03-resources.md) |

[100-ex-rs]: <https://rust-exercises.com/100-exercises/>
[rustlings]: <https://rustlings.rust-lang.org/>

## Outline

The linked lessons exist now; the remaining entries are the plan. The sequence follows the [Brown Experimental Edition](https://rust-book.cs.brown.edu/); use the [Rust Reference](https://doc.rust-lang.org/reference/) to check language details and spot gaps.

1. Getting started and Cargo: packages, `check`, `build`, and `run`.
2. Syntax, [functions](functions.md), and control flow: bindings, expressions, branches, and loops.
3. [Ownership, moves, and borrows](ownership.md); then mutable borrows and slices.
4. Structs, enums, and pattern matching: represent data and take it apart.
5. Modules and crates: paths, visibility, and `use`.
6. Collections: vectors, strings, and hash maps.
7. Errors: `Option`, `Result`, propagation with `?`, and panics.
8. Generics, traits, and lifetimes: express what callers must guarantee.
9. Tests and I/O: check behavior and handle input that can fail.
10. Closures and iterators: capture values and transform sequences.
11. Cargo workspaces: share dependencies and test multiple packages.
12. Smart pointers: `Box`, `Rc`, and interior mutability.
13. Threads and async: transfer data, synchronize access, and await futures.
14. Trait objects: choose behavior at runtime with `dyn`.
15. Advanced types, unsafe Rust, and macros: newtypes, safety contracts, and generated code.
