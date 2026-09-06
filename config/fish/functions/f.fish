function f --description="fuzzy moving with ghq"
    set --local p (__ghq-pick $argv[1])
    or return 1
    cd "$p"
end
