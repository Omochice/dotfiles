-- sketchybar runs under launchd without the home-manager PATH, so the binaries
-- the Lua callbacks shell out to are pinned by store path at build time.
return {
  jq = "@jq@",
  omniwmctl = "@omniwmctl@",
}
