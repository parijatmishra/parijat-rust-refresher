# Resources

## Cheat Sheets

- [cheats.rs][cheats-rs]

[cheats-rs]: <https://cheats.rs/>

## Core Documentation

If you installed Rust using `rustup`, a lot of documentation is already installed. Open it in the browser with:

```sh
rustup doc
```

If you installed Rust with `rustup install --profile minimal`, then you can install the documentation with:

```sh
rustup component add rust-docs
```

You get:
- The Rust Programming Language (TRPL) aka "The Book" ([online][trpl])
- Rust By Example ([online][rust-by-example])
- Rust Standard Library Documentation ([online][rust-std])
- Rust Release Notes ([online][releases-rs])
- Rust Edition Guide ([online][rust-edition-guide])
- The `rustc` Book (local only)
- The Cargo Book ([online][cargo-book])
- The Rustdoc Book ([online][rustdoc-book])
- The Clippy Book ([online][clippy-book])
- `rustc` Error Codes (local only)
- The Rust Language Reference ([online][rust-reference])
- The Rust Style Guide ([online][rust-style-guide])
- The Rustonomicon ([online][rustonomicon])
- The Unstable Book (for unstable features) ([online][rust-unstable])
- The Embedded Rust Book ([online][rust-embedded])
- Rust Standard Library Documentation ([online][rust-std])

[trpl]: <https://doc.rust-lang.org/book/>
[rust-by-example]: <https://doc.rust-lang.org/rust-by-example/>
[rust-std]: <https://doc.rust-lang.org/std/>
[releases-rs]: <https://releases.rs>
[rust-edition-guide]: <https://doc.rust-lang.org/edition-guide/>
[cargo-book]: <https://doc.rust-lang.org/cargo/>
[rustdoc-book]: <https://doc.rust-lang.org/rustdoc/what-is-rustdoc.html>
[clippy-book]: <https://doc.rust-lang.org/stable/clippy/development/infrastructure/book.html>
[rust-reference]: <https://doc.rust-lang.org/reference/>
[rust-style-guide]: <https://doc.rust-lang.org/style-guide/>
[rustonomicon]: <https://doc.rust-lang.org/nomicon/>
[rust-unstable]: <https://doc.rust-lang.org/uns[table-book/the-unstable-book.html>
[rust-embedded]: <https://docs.rust-embedded.org/book/>

Online only:
- [The Rustup Book][rustup-book]

[rustup-book]: <https://rust-lang.github.io/rustup/>

## Third Party Crates Docs

The command `cargo doc --open` will generate documentation for your project *and* all its dependencies in their correct version, and open it in your browser.

Otherwise:
- [docs.rs][docs-rs]: searchable documentation for many Rust crates.

[docs-rs]: <https://docs.rs/>



## Crate Directories

- [blessed.rs][blessed-rs]: opinionated directory of recommended crates, grouped by purpose.
- [lib.rs][lib-rs]: collection of crates by purpose, less opinionated.
- [Awesome Rust][awesome-rust]: another curated collection of useful crates by purpose.
- [crates.io](https://crates.io): official Rust crates registry.

[blessed-rs]: <https://blessed.rs/crates>
[lib-rs]: <https://lib.rs/>
[awesome-rust]: <https://github.com/rust-unofficial/awesome-rust>

## News

- [This Week in Rust][this-week]: handpicked Rust updates.

[this-week]: <https://this-week-in-rust.org/>

## Books

- [The Rust Programming Language - Experimental Edition][trpl-b], like [The Rust Programming Language][trpl] aka "The Book", but with quizzes and explanatory diagrams.
- [Command Line Applications in Rust][cli-rs]: CLI tutorial.
- [Zero to Production in Rust][zero-to-prod-rs]: backend development tutorial.
- [The Async Book][async-book]: guide to async in Rust std (dated, incomplete).
- [Tokio Tutorial][tokio-tut]: tutorial/guide for the Tokio async runtime.
- [Effective Rust][effective-rs]: 35 ways to iprove your Rust code.
- [Rust for Rustaceans][rust4]: advanced Rust tutorial.

[trpl-b]: <https://rust-book.cs.brown.edu/title-page.html>
[cli-rs]: <https://rust-cli.github.io/book/>
[zero-to-prod-rs]: <https://www.zero2prod.com/index.html>
[async-book]: <https://rust-lang.github.io/async-book/>
[tokio-tut]: <https://tokio.rs/tokio/tutorial>
[effective-rs]: <https://effective-rust.com/title-page.html>
[rust4]: <https://rust-for-rustaceans.com/>
