# Installation

{{#quiz ../quizzes/ch01-installation.toml}}

## Rustup

The best way to install Rust is via [rustup](https://rustup.rs). On macOS,
rustup can be installed via Homebrew: `brew install rustup`.

> [!NOTE]
N.B. with this installation method, `rustup` itself cannot be updated via
`rustup self update`: it must be updated via Homebrew.

## Installation and Usage

Rust ships its tools in three release channels: stable, beta and nightly. We can
tell `rustup` to install the latext toolchain from the stable channel and make
it the default with:

```sh
rustup install stable
rustup default stable
```

Now, the commands `rustc`, `cargo` etc. are work, using the currently installed
stable toolchain.

We can install toolchains from other channels, e.g., nightly, but not make it
default, with:

```sh
rustup toolchain install nightly
```

Once installed, we can use the nightly toolchain as a one-off by:

```sh
cargo +nightly build
```

Or, we can override the toolchain per-project in the `rust-toolchain.toml` file,
specifying either a release channel, or a specific version:

```toml
[toolchain]
channel = "nightly"
```

For more details, see [The rustup
Book](https://rust-lang.github.io/rustup/overrides.html).

## Updates

We can update *all* installed toolchains with:

```sh
rustup update
```

We can update a given / default toolchain with:

```sh
rustup update stable
rustup update nightly
```

We can check (without downloading) if any toolchain is outdated:

```sh
rustup check
```
