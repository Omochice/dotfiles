def abbreviate: sub("^(?<head>\\.?.).*"; .head);

# Inside a git-wt worktree the repository name sits above .wt, so the two trailing components alone would hide it.
def shorten($home):
  sub("^file://[^/]*"; "")
  | if . == $home or startswith($home + "/") then "~" + .[($home | length):] else . end
  | split("/")
  | (indices(".wt") | last) as $wt
  | (if $wt != null and $wt > 0 then [$wt - 1, length - 1] else [length - 2, length - 1] end) as $keep
  | to_entries
  | map(.key as $k | if any($keep[]; . == $k) then .value else .value | abbreviate end)
  | join("/");

def live($self): .sessions[] | select((.exited | not) and .id != $self);
