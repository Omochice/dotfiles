picked=$(
  felis sessions list --format json |
    jq --raw-output --library-path "$SESSION_JQ_LIB" \
      --arg self "${FELIS_SESSION_ID:-}" \
      --arg home "$HOME" \
      'include "session";
      # sgr is an ANSI palette index rather than a hex color so that the felis theme decides the actual shade.
      {
        blocked: {rank: 0, sgr: 33},
        done: {rank: 1, sgr: 32},
        error: {rank: 1, sgr: 31},
        working: {rank: 2, sgr: 34}
      } as $states
      | [live($self)
        | (.program_status | map(select($states[.state])) | first) as $status
        | select($status != null)
        | {id, idle: (.idle_seconds // 0), cwd: (.cwd // ""), $status}]
      | sort_by($states[.status.state].rank, -.idle)[]
      | .status.state as $state
      | [.id, "\u001b[\($states[$state].sgr)m\($state + " " * (7 - ($state | length)))\u001b[0m", (.cwd | shorten($home)), (.status.title // "")]
      | @tsv' |
    fzf --ansi --delimiter '\t' --with-nth 2.. \
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
