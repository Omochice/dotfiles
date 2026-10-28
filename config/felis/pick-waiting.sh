picked=$(
  felis sessions list --format json |
    jq --raw-output --library-path "$SESSION_JQ_LIB" \
      --arg self "${FELIS_SESSION_ID:-}" \
      --arg home "$HOME" \
      'include "session";
      [live($self)
        | (.program_status | map(select(.state | IN("blocked", "done", "error"))) | first) as $status
        | select($status != null)
        | {id, idle: (.idle_seconds // 0), cwd: (.cwd // ""), $status}]
      | sort_by((if .status.state == "blocked" then 0 else 1 end), -.idle)[]
      | [.id, (.status.state | . + " " * (7 - length)), (.cwd | shorten($home)), (.status.title // "")]
      | @tsv' |
    fzf --delimiter '\t' --with-nth 2.. \
      --header 'enter: switch' \
      --preview 'felis sessions capture {1}'
) || exit 0

IFS=$'\t' read -r id _ <<<"$picked"
# The window already returns to the origin when this transient session exits.
if [[ $id == "${FELIS_ORIGIN_SESSION_ID:-}" ]]; then
  exit 0
fi
felis sessions switch "$id"
