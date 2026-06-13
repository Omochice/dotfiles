input=$(cat)
# display_name is short (e.g. "Opus"); build "Opus 4.8" from model.id instead.
# 5h/weekly are shown as remaining percentage (100 - used); -1 marks absent.
IFS=$'\t' read -r model cost ctx h5 week < <(
  printf '%s' "$input" | jq -r '
    [ ( ( (.model.id // "") | ltrimstr("claude-") | split("-") ) as $t
        | ( [$t[] | select(test("^[a-z]+$"))] | map((.[0:1] | ascii_upcase) + .[1:]) | join(" ") ) as $name
        | ( [$t[] | select(test("^[0-9]{1,2}$"))] | join(".") ) as $ver
        | if $name == "" then (.model.display_name // "?")
          else $name + (if $ver == "" then "" else " " + $ver end) end ),
      (.cost.total_cost_usd // 0),
      (.context_window.used_percentage // -1),
      (.rate_limits.five_hour.used_percentage  | if . == null then -1 else 100 - . end),
      (.rate_limits.seven_day.used_percentage  | if . == null then -1 else 100 - . end)
    ] | @tsv'
)
line=$(printf '🤖 %s | 💰 $%.2f' "$model" "$cost")
if [ "${ctx%.*}" != "-1" ]; then line="$line | 🧠 ${ctx%.*}%"; fi
if [ "${h5%.*}" != "-1" ]; then line="$line | ⏳ 5h ${h5%.*}%"; fi
if [ "${week%.*}" != "-1" ]; then line="$line | 📅 weekly ${week%.*}%"; fi
printf '%s' "$line"
