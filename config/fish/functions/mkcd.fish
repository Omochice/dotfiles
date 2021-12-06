function mkcd
    set --local p $argv[1]
    echo "mkdir $p && cd $p"
    mkdir $p
    cd $p
end

