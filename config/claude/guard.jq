({Bash: "command", Read: "file_path", Write: "file_path", Edit: "file_path"}[.tool_name]) as $field
| .tool_name as $tool
| (.tool_input[$field // empty] // empty) as $value
| first(
    $rules[0][]
    | select(.matcher | split("|") | index($tool))
    | select(. as $rule | $value | test($rule.regex))
  )
| {
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: .message
    }
  }
