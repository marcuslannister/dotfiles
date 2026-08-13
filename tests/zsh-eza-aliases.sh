#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d "${TMPDIR:-/tmp}/zsh-eza-test.XXXXXX")"
trap 'rm -r -- "$test_dir"' EXIT

aliases="$(
  REPO_ROOT="$repo_root" TEST_DIR="$test_dir" zsh -dfi -c '
    source "$REPO_ROOT/.zshenv"
    zstyle ":zim:completion" dumpfile "$TEST_DIR/.zcompdump"
    source "$REPO_ROOT/.zshrc"
    for f in $precmd_functions; do
      $f
    done
    eval "alias l; alias ls; l >/dev/null"
  ' 2>/dev/null
)"

actual_l="$(printf '%s\n' "$aliases" | sed -n "/^l=/p")"
actual_ls="$(printf '%s\n' "$aliases" | sed -n "/^ls=/p")"

if [[ "$actual_l" == "l='ls -CF'" ]]; then
  printf 'expected l to use eza directly, got: %s\n' "$actual_l" >&2
  exit 1
fi

if [[ "$actual_l" != *"eza -l -snew --icons"* ]]; then
  printf 'expected l to preserve the eza long-list alias, got: %s\n' "$actual_l" >&2
  exit 1
fi

# Every host Declares scmpuff, but one that has not switched yet has no
# binary, and there ls has to stay a plain eza alias rather than break.
if command -v scmpuff >/dev/null 2>&1; then
  if [[ "$actual_ls" != *"scmpuff exec --relative -- eza --icons"* ]]; then
    printf 'expected ls to keep scmpuff argument expansion around eza, got: %s\n' "$actual_ls" >&2
    exit 1
  fi
else
  if [[ "$actual_ls" != "ls='eza --icons'" ]]; then
    printf 'expected ls to fall back to plain eza without scmpuff, got: %s\n' "$actual_ls" >&2
    exit 1
  fi
fi
