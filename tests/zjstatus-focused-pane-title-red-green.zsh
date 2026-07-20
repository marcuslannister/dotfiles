#!/usr/bin/env zsh

set -eu

if (( $# != 1 )); then
  print -u2 -- "usage: ${0:t} /path/to/zjstatus-checkout"
  exit 2
fi

source_dir=${1:A}
repo_root=${0:A:h:h}
live_test=$repo_root/tests/zellij-focused-pane-title.zsh
fixture_patch=$repo_root/tests/fixtures/zjstatus-stale-pane-manifest.patch
production_patch=$repo_root/.config/zellij/patches/zjstatus-focused-pane-title.patch
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/zjstatus-red-green.XXXXXX")
red_dir=$test_dir/red
green_dir=$test_dir/green

cleanup() {
  [[ ! -d $test_dir ]] || command rm -r -- "$test_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

mkdir -p "$red_dir" "$green_dir"
git -C "$source_dir" archive HEAD | tar -xf - -C "$red_dir"
cp -R "$red_dir/." "$green_dir"

git -C "$red_dir" apply "$fixture_patch"
git -C "$green_dir" apply "$fixture_patch"
git -C "$green_dir" apply "$production_patch"

toolchain=$(rg -or '$1' '^channel = "([^"]+)"' "$red_dir/rust-toolchain.toml")
rustc_path=$(rustup which --toolchain "$toolchain" rustc)
for build_dir in "$red_dir" "$green_dir"; do
  (cd "$build_dir" && RUSTC=$rustc_path cargo build --release --bin zjstatus)
done

red_wasm=$red_dir/target/wasm32-wasip1/release/zjstatus.wasm
green_wasm=$green_dir/target/wasm32-wasip1/release/zjstatus.wasm

"$live_test" --grant-only "$red_wasm"
"$live_test" --grant-only "$green_wasm"

if "$live_test" --startup-only "$red_wasm" > "$test_dir/red.log" 2>&1; then
  print -u2 -- 'expected stale-manifest build to fail startup-title assertion'
  exit 1
fi
rg -Fq 'ZJSTARTPane #1ZJEND' "$test_dir/red.log" || {
  print -u2 -- 'red build failed without reproducing stale Pane #1 title'
  command tail -20 "$test_dir/red.log" >&2
  exit 1
}

"$live_test" --startup-only "$green_wasm"
print -- 'red: stale Pane #1 reproduced'
print -- 'green: startup title synchronized'
