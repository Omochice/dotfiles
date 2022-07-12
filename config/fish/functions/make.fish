function make
    if test -f justfile
        command just $argv
    else
        command make $argv
    end
end
