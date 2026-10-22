#!/usr/bin/env bash
# Builds the release binary as a normal user -> target/release/conduit. Cargo's registry goes to ~/.cargo.
set -euo pipefail
cd "$(dirname "$0")"
if [ -x /usr/local/cargo/bin/cargo ]; then
  # cargo runs rustc from PATH, so the toolchain's bin dir must be on it too
  export RUSTUP_HOME=/usr/local/rustup CARGO_HOME="$HOME/.cargo" PATH="/usr/local/cargo/bin:$PATH"; CARGO=/usr/local/cargo/bin/cargo
else
  CARGO=cargo   # local development: cargo on PATH
fi
"$CARGO" build --release --locked
