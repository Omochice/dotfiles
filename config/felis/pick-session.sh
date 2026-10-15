list_sessions() {
  felis sessions list --format json |
    jq --raw-output \
      --arg self "${FELIS_SESSION_ID:-}" \
      --arg origin "${FELIS_ORIGIN_SESSION_ID:-}" \
      --arg home "$HOME" \
      'def shorten:
        sub("^file://[^/]*"; "")
        | if . == $home or startswith($home + "/") then "~" + .[($home | length):] else . end
        | split("/")
        | (.[:-2] | map(sub("^(?<head>\\.?.).*"; .head))) + .[-2:]
        | join("/");
      .sessions[]
      | select((.exited | not) and .id != $self)
      | [.id, (if .id == $origin then "*" else " " end), (.cwd // "" | shorten)]
      | @tsv'
}

# fzf runs reload in a fresh shell that cannot see list_sessions, so it re-enters this script instead.
if [[ ${1:-} == --list ]]; then
  list_sessions
  exit 0
fi

picked=$(
  list_sessions |
    fzf --delimiter '\t' --with-nth 2.. \
      --header 'enter: switch / ctrl-x: kill' \
      --preview 'felis sessions capture {1}' \
      --bind "ctrl-x:execute-silent(felis sessions kill {1})+reload($0 --list)"
) || exit 0

IFS=$'\t' read -r id _ <<<"$picked"
# The window already returns to the origin when this transient session exits.
if [[ $id == "${FELIS_ORIGIN_SESSION_ID:-}" ]]; then
  exit 0
fi
felis sessions switch "$id"
