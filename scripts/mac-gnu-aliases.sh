function main(){
    local commands=( "ln" "ls" "mkdir" "kill" "cut" "date" "dd" "df" "chmod" "chown" "base64" "md5dum" "sha256sum" "sha512sum" "sort" "sleep" "tail" "true" "false" "uname" "who" "whoami" "unlink" "yes" "readlink" )
    for c in ${commands[@]}; do
        alias "${c}"=g"${c}"
    done
}

main

