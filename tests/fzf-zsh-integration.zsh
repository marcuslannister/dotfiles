#!/usr/bin/env zsh

set -eu

repo_root=${0:A:h:h}

REPO_ROOT=$repo_root zsh -fic '
  bindkey -v
  source "$REPO_ROOT/.config/zsh/.zshrc.fzf"

  binding=$(bindkey -M viins "^R")
  [[ $binding == "\"^R\" fzf-history-widget" ]] || {
    print -u2 -- "unexpected Ctrl-R binding: $binding"
    exit 1
  }
  [[ $(whence -w fzf-history-widget) == "fzf-history-widget: function" ]]
'
