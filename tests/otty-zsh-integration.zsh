#!/usr/bin/env zsh

set -eu

repo_root=${0:A:h:h}
zshrc=$repo_root/.zshrc
marker_line=$(command grep -nF '# >>> otty shell integration >>>' "$zshrc" | command cut -d: -f1)
prepare_line=$(command grep -nF 'precmd_functions+=(__otty_prepare_dump_aliases)' "$zshrc" | command cut -d: -f1 || true)

if [[ -z $prepare_line || $prepare_line -ge $marker_line ]]; then
  print -u2 -- 'Otty dump preparer must load before its managed marker block'
  exit 1
fi

integration_dir=$(mktemp -d "${TMPDIR:-/tmp}/otty-zsh-test.XXXXXX")
trap 'command rm -r -- "$integration_dir"' EXIT
print -r -- '__otty_dump_aliases() {
  builtin alias > "${TMPDIR:-/tmp}/otty-aliases-${EUID}" 2>/dev/null
  print -rn -- "$PATH" > "${TMPDIR:-/tmp}/otty-path-${EUID}" 2>/dev/null
  precmd_functions=("${(@)precmd_functions:#__otty_dump_aliases}")
}
precmd_functions+=(__otty_dump_aliases)' > "$integration_dir/otty-integration.zsh"

output=$(
  OTTY_SHELL_INTEGRATION=$integration_dir ZDOTDIR=$repo_root TMPDIR=$integration_dir zsh -lic '
    setopt noclobber
    test_dir=$(mktemp -d)
    TMPDIR=$test_dir
    for hook in $precmd_functions; do
      $hook
    done
    __otty_prepare_dump_aliases
    __otty_dump_aliases
    [[ -s $test_dir/otty-aliases-$EUID ]]
    [[ -s $test_dir/otty-path-$EUID ]]
    [[ -o noclobber ]]
  ' 2>&1
) || {
  print -u2 -- "$output"
  exit 1
}

if [[ $output == *'file exists:'* ]]; then
  print -u2 -- "$output"
  exit 1
fi
