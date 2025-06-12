function gi --description gitignore
    set --local selected (gh api gitignore/templates | jq -r ".[]" | fzf --no-sort --multi --preview="gh api gitignore/templates/{} | jq -r '.source'" --height=50% --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up')
    if test -z "$selected"
        return 1
    end
    for lang in "$selected"
        gh api gitignore/templates/$lang | jq -r ".source"
    end
end
