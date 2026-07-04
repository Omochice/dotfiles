input=$(cat)
# display_name is short (e.g. "Opus"); build "Opus 4.8" from model.id instead.
IFS=$'\t' read -r model cost ctx h5 week h5reset weekreset < <(
  printf '%s' "$input" | jq -r '
    [ ( ( (.model.id // "") | ltrimstr("claude-") | split("-") ) as $t
        | ( [$t[] | select(test("^[a-z]+$"))] | map((.[0:1] | ascii_upcase) + .[1:]) | join(" ") ) as $name
        | ( [$t[] | select(test("^[0-9]{1,2}$"))] | join(".") ) as $ver
        | if $name == "" then (.model.display_name // "?")
          else $name + (if $ver == "" then "" else " " + $ver end) end ),
      (.cost.total_cost_usd // 0),
      (.context_window.used_percentage | if . == null then -1 else 100 - . end),
      (.rate_limits.five_hour.used_percentage  | if . == null then -1 else 100 - . end),
      (.rate_limits.seven_day.used_percentage  | if . == null then -1 else 100 - . end),
      (.rate_limits.five_hour.resets_at // ""),
      (.rate_limits.seven_day.resets_at // "")
    ] | @tsv'
)

# rate_limits.*.resets_at is epoch seconds (per statusline JSON schema).
format_reset() {
  v="$1"
  printf '%s' "$v" | grep -Eq '^[0-9]+$' || {
    echo ""
    return
  }
  date -r "$v" "+%m-%d %H:%M"
}

line=$(printf '🤖 %s | 💰 $%.2f' "$model" "$cost")
if [ "${ctx%.*}" != "-1" ]; then line="$line | 🧠 ${ctx%.*}%"; fi
if [ "${h5%.*}" != "-1" ]; then
  r=$(format_reset "$h5reset")
  if [ -n "$r" ]; then line="$line | ⏳ 5h ${h5%.*}% ($r)"; else line="$line | ⏳ 5h ${h5%.*}%"; fi
fi
if [ "${week%.*}" != "-1" ]; then
  r=$(format_reset "$weekreset")
  if [ -n "$r" ]; then line="$line | 📅 weekly ${week%.*}% ($r)"; else line="$line | 📅 weekly ${week%.*}%"; fi
fi
printf '%s' "$line"
