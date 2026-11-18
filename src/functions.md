# Functions

## Parameters and arguments

In `fn double(n: usize)`, `n` is the **parameter**: a name and a type in the definition. In `double(3)`, `3` is the **argument**: the value supplied at the call. The signature tells you what to pass. A parameter of type `String` takes ownership of a string passed by value; `&str` takes a shared view of text instead. If `word` is a `String`, pass `&word` to a `&str` parameter: Rust converts the reference to a view of the string’s contents. Calling `len()` on that view counts bytes, not characters.

## Tail expressions

Read `-> usize` as “returns a `usize`.” The body below ends in an expression; its value is the function's result. No `return` keyword is needed.

```rust
fn double(n: usize) -> usize {
    n * 2
}

fn main() {
    assert_eq!(double(3), 6);
}
```

Adding a semicolon after `n * 2` would discard the product. With no value left at the end, the body would yield `()` (unit), not the promised `usize`.
