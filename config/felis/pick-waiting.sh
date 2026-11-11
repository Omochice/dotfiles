picked=$(
  felis sessions list --format json |
    jq --raw-output --library-path "$SESSION_JQ_LIB" \
      --arg self "${FELIS_SESSION_ID:-}" \
      --arg home "$HOME" \
      'include "session";
      [live($self)
        | (.program_status | map(select(.state | IN("blocked", "done", "error", "working"))) | first) as $status
        | select($status != null)
        | {id, idle: (.idle_seconds // 0), cwd: (.cwd // ""), $status}]
      | sort_by(({blocked: 0, working: 2}[.status.state] // 1), -.idle)[]
      | [.id, (.status.state | . + " " * (7 - length)), (.cwd | shorten($home)), (.status.title // "")]
      | @tsv' |
    fzf --delimiter '\t' --with-nth 2.. \
      --header 'enter: switch' \
      --preview 'felis sessions capture {1} | perl -0777 -pe "s/^~[ \t]*\n//mg; s/\s+\z/\n/"' \
      --preview-window follow \
      --with-shell "$BASH -c" \
      --bind 'start,resize:transform:if (( FZF_COLUMNS < FZF_LINES * 2 )); then echo "change-preview-window(down)"; else echo "change-preview-window(right)"; fi'
) || exit 0

IFS=$'\t' read -r id _ <<<"$picked"
# The window already returns to the origin when this transient session exits.
if [[ $id == "${FELIS_ORIGIN_SESSION_ID:-}" ]]; then
  exit 0
fi
felis sessions switch "$id"
