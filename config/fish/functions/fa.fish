function fa --description="open an abduco session in a ghq repository"
    if ! type abduco 2>&1 >/dev/null
        echo "abduco is not included into PATH"
        return 1
    end
    set --local p (__ghq-pick $argv[1])
    or return 1
    # abduco cannot use "/" in a session name.
    set --local name (string join - -- (string split / -- $p)[-2..])
    abduco -A $name fish -C "cd "(string escape -- $p)
end
