# Hello, World!

{{#quiz ../quizzes/ch02-hello-world.toml}}

## Single File Programs

Rust source files always end with the `.rs` extension. All Rust programs have a
function named `main`. E.g.:

File: *main.rs*
```rust
fn main() {
  println!("Hello, World!");
}
```

We can build and run it like this:

```sh
$ rustc main.rs
$ ls
main.rs main
$ ./main
Hello, World!
```
