# Ownership

## Borrow instead of moving

Suppose you want a second name to read some text, but still need the original `String`. Assignment by value does **not** make a second `String` with its own allocation:

```rust,compile_fail,E0382
let owned = String::from("rust");
let other = owned;
println!("{owned}");
```

`String` is not `Copy`. The assignment moves the value to `other`. The bytes still exist, but `owned` is no longer a valid way to reach them. Passing `owned` to a function with a `String` parameter has the same effect.

Use `&owned` instead. It creates a shared reference (`&String`) that lets `view` read the string without taking it or copying its bytes. `owned` remains responsible for the buffer. Rust prevents mutation of the string while the shared borrow is still in use and prevents the reference from outliving its referent.

![The shared reference view points to owned, the String that still owns the buffer containing rust.](diagrams/ownership-shared-borrow.svg)

```rust
{{#include ../examples/ownership-demo/src/main.rs}}
```

The print reads through `view`; the assertion then reads `owned` and produces no output on success. Run the example from the repository root:

```bash
cargo run --locked --quiet --manifest-path examples/ownership-demo/Cargo.toml
```

Stdout:

```text
{{#include ../examples/ownership-demo/expected/ownership-demo.stdout}}
```

For more on moves, references, and slices, see [Brown’s ownership chapter](https://rust-book.cs.brown.edu/ch04-00-understanding-ownership.html).
