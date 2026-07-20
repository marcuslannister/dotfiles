#!/usr/bin/env zsh

set -eu
zmodload zsh/datetime

test_mode=full
if (( $# == 2 )); then
  test_mode=$1
  shift
fi
if (( $# != 1 )) || [[ $test_mode != full && $test_mode != --grant-only && $test_mode != --startup-only ]]; then
  print -u2 -- "usage: ${0:t} [--grant-only|--startup-only] /absolute/path/to/zjstatus.wasm"
  exit 2
fi

plugin_path=${1:A}
[[ -f $plugin_path ]] || {
  print -u2 -- "zjstatus WASM not found: $plugin_path"
  exit 2
}

test_id=$$
zellij_session=zt-$test_id
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/zjstatus-title-test.XXXXXX")
client_pid=
zellij_client_pid=

cleanup() {
  local cleanup_result=0

  [[ -z $zellij_client_pid ]] || kill "$zellij_client_pid" 2>/dev/null || true
  if [[ -n $client_pid ]]; then
    kill "$client_pid" 2>/dev/null || true
    wait "$client_pid" 2>/dev/null || true
  fi
  zellij kill-session "$zellij_session" 2>/dev/null || true

  for _ in {1..20}; do
    zellij list-sessions --short --no-formatting 2>/dev/null |
      rg -Fxq "$zellij_session" || break
    sleep 0.05
  done
  if zellij list-sessions --short --no-formatting 2>/dev/null |
    rg -Fxq "$zellij_session"; then
    print -u2 -- "failed to stop Zellij session: $zellij_session"
    cleanup_result=1
  fi
  [[ ! -d $test_dir ]] || command rm -r -- "$test_dir"
  return $cleanup_result
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

run_test() {
  setopt localoptions errreturn
  unsetopt errexit
  {

cat > "$test_dir/.zshrc" <<'EOF'
PROMPT='test> '
test_title_precmd() {
  print -n -- $'\e]0;startup-title\a'
  precmd_functions=("${(@)precmd_functions:#test_title_precmd}")
}
precmd_functions+=(test_title_precmd)
EOF

cat > "$test_dir/config.kdl" <<'EOF'
simplified_ui true
show_release_notes false
show_startup_tips false
pane_frames false
session_serialization false
disable_session_metadata true
mouse_mode false
EOF

escaped_plugin_path=${plugin_path//\\/\\\\}
escaped_plugin_path=${escaped_plugin_path//\"/\\\"}
shell_path=$(command -v zsh)
escaped_shell_path=${shell_path//\\/\\\\}
escaped_shell_path=${escaped_shell_path//\"/\\\"}

cat >> "$test_dir/config.kdl" <<EOF
default_shell "$escaped_shell_path"
EOF

cat > "$test_dir/layout.kdl" <<EOF
layout {
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="file:$escaped_plugin_path" skip_plugin_cache=true {
                format_left "{tabs}"
                format_center ""
                format_right ""
                format_space ""
                tab_active "ZJSTART{focused_pane_title}ZJEND"
                tab_normal "ZJSTART{focused_pane_title}ZJEND"
                tab_separator " | "
            }
        }
        children
    }
}
EOF

cat > "$test_dir/client.exp" <<EOF
log_file -noappend "$test_dir/client.log"
set timeout -1
set env(TERM) xterm-256color
set env(ZDOTDIR) "$test_dir"
spawn zellij --config "$test_dir/config.kdl" --session "$zellij_session" --new-session-with-layout "$test_dir/layout.kdl"
expect eof
EOF

/usr/bin/expect "$test_dir/client.exp" >/dev/null 2>&1 &
client_pid=$!

for _ in {1..50}; do
  [[ -n $zellij_client_pid ]] || zellij_client_pid=$(pgrep -P "$client_pid" zellij || true)
  zellij list-sessions --no-formatting 2>/dev/null | rg -Fq "$zellij_session" && break
  sleep 0.1
done

panes='[]'
plugin_id=
terminal_id=
for _ in {1..50}; do
  panes=$(zellij --session "$zellij_session" action list-panes --all --json)
  plugin_id=$(
    print -r -- "$panes" |
      jq -r --arg plugin_path "$plugin_path" \
        '.[] | select(.is_plugin and (.plugin_url | endswith($plugin_path))) | "plugin_\(.id)"' |
      head -n 1
  )
  terminal_id=$(print -r -- "$panes" | jq -r '.[] | select(.is_plugin | not) | "terminal_\(.id)"' | head -n 1)
  [[ -n $plugin_id && -n $terminal_id ]] && break
  sleep 0.1
done
[[ -n $plugin_id ]] || {
  print -u2 -- 'zjstatus plugin pane not found'
  print -u2 -- "$panes"
  return 1
}

if [[ $test_mode == --grant-only ]]; then
  zellij --session "$zellij_session" action write --pane-id "$plugin_id" 121
  sleep 0.2
  return 0
fi

wait_for_title() {
  local expected=$1
  local timeout_seconds=$2
  local deadline=$(( EPOCHREALTIME + timeout_seconds ))

  while (( EPOCHREALTIME < deadline )); do
    LC_ALL=C rg -aFq "ZJSTART${expected}ZJEND" "$test_dir/client.log" && return 0
    sleep 0.1
  done

  print -u2 -- "timed out waiting for title: $expected"
  LC_ALL=C rg -ao 'ZJSTART[^[:cntrl:]]*ZJEND' "$test_dir/client.log" | tail -10 >&2 || true
  return 1
}

send_osc_title() {
  local title=$1
  local marker=ZJUPDATE-$title
  local execution_marker=ZJEXEC-$title
  local update_command="print -n -- \$'\\e]0;${title}\\a'; print -r -- ZJEX''EC-$title # $marker"
  local update_prepared=false
  local update_executed=false

  zellij --session "$zellij_session" action write-chars --pane-id "$terminal_id" "$update_command"
  for _ in {1..50}; do
    if zellij --session "$zellij_session" action dump-screen --pane-id "$terminal_id" |
      rg -Fq "$marker"; then
      update_prepared=true
      break
    fi
    sleep 0.01
  done
  $update_prepared || {
    print -u2 -- "timed out preparing OSC update: $title"
    return 1
  }
  for _ in {1..5}; do
    zellij --session "$zellij_session" action send-keys --pane-id "$terminal_id" Enter
    for _ in {1..10}; do
      if zellij --session "$zellij_session" action dump-screen --pane-id "$terminal_id" |
        rg -Fq "$execution_marker"; then
        update_executed=true
        break 2
      fi
      sleep 0.01
    done
  done
  $update_executed || {
    print -u2 -- "timed out executing OSC update: $title"
    return 1
  }
}

wait_for_title startup-title 5
[[ $test_mode != --startup-only ]] || return 0
send_osc_title primed-title
wait_for_title primed-title 2
primed_render_count=$(LC_ALL=C rg -ao 'ZJSTARTprimed-titleZJEND' "$test_dir/client.log" | wc -l | tr -d ' ')
for _ in {1..120}; do
  current_render_count=$(LC_ALL=C rg -ao 'ZJSTARTprimed-titleZJEND' "$test_dir/client.log" | wc -l | tr -d ' ')
  (( current_render_count > primed_render_count )) && break
  sleep 0.01
done
(( current_render_count > primed_render_count )) || {
  print -u2 -- 'timed out aligning with zjstatus timer'
  return 1
}
update_started=$EPOCHREALTIME
send_osc_title updated-title
wait_for_title updated-title 0.8
update_elapsed=$(( EPOCHREALTIME - update_started ))
(( update_elapsed < 0.8 )) || {
  print -u2 -- "title update took ${update_elapsed}s; timer interval is 1s"
  return 1
}
  } always {
    cleanup
  }
}

run_test
