state=$1
kind=${2:-}

if [[ -z ${FELIS_SESSION_ID:-} ]]; then
  exit 0
fi

# Hooks run without a controlling terminal, so /dev/tty cannot be opened; the device of the nearest ancestor that has one is the terminal claude draws on.
pid=$PPID
while :; do
  read -r ppid tty < <(ps -o ppid=,tty= -p "$pid") || exit 0
  [[ -n $tty && $tty != \?* ]] && break
  [[ $ppid -gt 1 ]] || exit 0
  pid=$ppid
done

# felis replaces the whole record on every report, so a working report without the title would erase it from the picker.
{ grep --extended-regexp '^\{"type":"(custom|ai)-title"' "$(jq --raw-output '.transcript_path // ""')" 2>/dev/null || true; } |
  jq --raw-output --join-output --slurp --arg state "$state" --arg kind "$kind" '
    ((map(select(.type == "custom-title") | .customTitle) | last)
      // (map(select(.type == "ai-title") | .aiTitle) | last)) as $title
    | ["state=\($state)", "app=claude"]
    + (if $kind != "" then ["kind=\($kind)"] else [] end)
    # felis caps a decoded title at 192 bytes, which 48 four-byte characters stay under.
    + (if $title then ["title=\($title | explode | map(select(. >= 32 and . != 127)) | implode | .[:48] | @base64)"] else [] end)
    | "\u001b]7501;\(join(":"))\u001b\\"' >"/dev/$tty"
