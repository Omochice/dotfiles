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

transcript=$(jq --raw-output '.transcript_path // ""')

# working never reaches the picker, and PostToolUse fires on every tool call, so the transcript is read only for the states that do.
if [[ $state != working && -r $transcript ]]; then
  grep --extended-regexp '^\{"type":"(custom|ai)-title"' "$transcript" || true
fi |
  jq --raw-output --join-output --slurp --arg state "$state" --arg kind "$kind" '
    # The transcript layout is undocumented, so a title that cannot be found is left out rather than failing the report.
    ((map(select(.type == "custom-title") | .customTitle) | last)
      // (map(select(.type == "ai-title") | .aiTitle) | last)) as $title
    | ["state=\($state)", "app=claude"]
    + (if $kind != "" then ["kind=\($kind)"] else [] end)
    # felis caps a decoded title at 192 bytes, which 48 four-byte characters stay under.
    + (if $title then ["title=\($title | explode | map(select(. >= 32 and . != 127)) | implode | .[:48] | @base64)"] else [] end)
    | "\u001b]7501;\(join(":"))\u001b\\"' >"/dev/$tty"
