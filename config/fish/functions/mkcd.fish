function mkcd
    set --local p $argv[1]
    echo "mkdir -p $p && cd $p"
    mkdir -p $p
    cd $p
end

