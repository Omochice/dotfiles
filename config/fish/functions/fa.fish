function fa --description="open a zmx session in a ghq repository"
    if ! type zmx 2>&1 >/dev/null
        echo "zmx is not included into PATH"
        return 1
    end
    set --local p (__ghq-pick $argv[1])
    or return 1
    # zmx cannot use "/" in a session name.
    set --local name (string join - -- (string split / -- $p)[-2..])
    zmx attach $name fish -C "cd "(string escape -- $p)
end
