list_sessions() {
  felis sessions list --format json |
    jq --raw-output \
      --arg self "${FELIS_SESSION_ID:-}" \
      --arg origin "${FELIS_ORIGIN_SESSION_ID:-}" \
      --arg home "$HOME" \
      'def abbreviate: sub("^(?<head>\\.?.).*"; .head);
      # Inside a git-wt worktree the repository name sits above .wt, so the two trailing components alone would hide it.
      def shorten:
        sub("^file://[^/]*"; "")
        | if . == $home or startswith($home + "/") then "~" + .[($home | length):] else . end
        | split("/")
        | (indices(".wt") | last) as $wt
        | (if $wt != null and $wt > 0 then [$wt - 1, length - 1] else [length - 2, length - 1] end) as $keep
        | to_entries
        | map(.key as $k | if any($keep[]; . == $k) then .value else .value | abbreviate end)
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
