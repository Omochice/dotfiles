# Stop hook: block once when the last assistant message contains wording from
# the prh dictionary. textlint is not started here because its npx startup
# would dominate a hook that runs on every turn; the rules are plain regexes.
#
# The dictionary is the main input (YAML) and the hook payload arrives as
# $hook, because gojq can parse YAML only on its main input.

def rules:
  [ .rules[]
    | select(.prh | startswith("possible") | not)
    | { re: (.pattern | capture("^/(?<p>.*)/$").p), why: .prh } ];

def prose:
  (.last_assistant_message // "")
  | gsub("(?s)```.*?```"; "")
  | gsub("`[^`\n]*`"; "");

def hits($rules):
  prose
  | split("\n")
  | to_entries
  | [ .[] as { key: $i, value: $line }
      | $rules[] as $rule
      | ($line | match($rule.re))
      | "L\($i + 1) 「\(.string)」 (\($rule.why))" ];

rules as $rules
| ($hook | fromjson)
# Blocking again on a turn that already continues from a block would loop.
| if .stop_hook_active then empty
  else
    hits($rules) as $hits
    | if ($hits | length) == 0 then empty
      else
        { decision: "block",
          reason: ([ "chii vocabulary hook: 直前の応答に、英語を訳したような言い回しがあります。",
                     "「言葉の選び方」の節に照らして、地の文だけを書き直してください。",
                     "文脈上その語が正しい場合は、そのままにしてよいです。",
                     "検出箇所:" ] + ($hits | map("  " + .)) | join("\n")) }
      end
  end
