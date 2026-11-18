# Quizzes

## Mixed diagnostic

Try these cold. Put anything wrong, slow, or guessed on your own review list. Use the links below to revisit just those sections; then try a topic exercise.

{{#quiz ../quizzes/mixed.toml}}

**Review**

- Q1, trace `next_len`: [parameters and arguments](functions.md#parameters-and-arguments), [borrowing](ownership.md#borrow-instead-of-moving), and [tail expressions](functions.md#tail-expressions).
- Q2, repair the return value: [tail expressions](functions.md#tail-expressions).

## By topic

### Ownership

{{#quiz ../quizzes/ownership.toml}}

**Repair by borrowing.** Change the parameter and call below so the caller can print both the original label and the byte count. Keep the `String` in `main`. Do not clone it, return it from the function, or move the print into the function. Write your repair before revealing the solution.

```rust,compile_fail,E0382
fn byte_count(text: String) -> usize {
    text.len()
}

fn main() {
    let label = String::from("ink");
    let n = byte_count(label);
    println!("{label}: {n}");
}
```

<details>
<summary>Sample solution and self-check</summary>

```rust
fn byte_count(text: &str) -> usize {
    text.len()
}

fn main() {
    let label = String::from("ink");
    let n = byte_count(&label);
    println!("{label}: {n}");
}
```

- Does the parameter borrow text? `&str` accepts a view of a `String`; `&String` also works here but accepts fewer callers.
- Does the call borrow `label` without allocating or moving the string?
- Can the caller still read `label` after the call and print `ink: 3`?

</details>

**Review:** [Borrow instead of moving](ownership.md#borrow-instead-of-moving).
