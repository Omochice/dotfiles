function _color() {
    case $1 in
    black) echo -e -n "\001\e[30m\002" ;;
    red) echo -e -n "\001\e[31m\002" ;;
    green) echo -e -n "\001\e[32m\002" ;;
    yellow) echo -e -n "\001\e[33m\002" ;;
    blue) echo -e -n "\001\e[34m\002" ;;
    magenta) echo -e -n "\001\e[35m\002" ;;
    cyan) echo -e -n "\001\e[36m\002" ;;
    white) echo -e -n "\001\e[37m\002" ;;
    *) echo -e -n "\001\e[0m\002" ;;
    esac
    # \[\]の代わりに\001 \002を使うことで\[\]がないときに発生する履歴が残る不具合を解消する
    # arch wiki (bash/プロンプトのカスタマイズ)参照
}

function git_branch() {
    local s=$(git branch --no-color 2>/dev/null | sed -ne "s/^\* \(.*\)$/\1/p")
    # 未commitとかは以下で定義する
    # TODO define logo for commit, unstarging etc.
    if [ ! "$s" = "" ]; then
        echo "$(_color normal)($(_color yellow)$s$(_color normal))"
    fi
}

function abbr_pwd() {
    local p=$(echo $(pwd) | sed "s@$HOME@~@")
    local directories=(${p//\// })
    local _n_d=${#directories[@]}
    local _last=${directories[_n_d - 1]}
    local _abbr_pwd=""
    if [ ${directories[0]} != "~" ]; then
        _abbr_pwd=$_abbr_pwd/
    fi
    # 本当はif [[ $p =~ (.?[^\/]{1})[^\/]*\/ ]]で処理したい
    for d in "${directories[@]:0:_n_d-1}"; do
        _abbr_pwd=$_abbr_pwd${d:0:1}/
    done
    echo $_abbr_pwd$_last
}

# line 1
# # user at pc in dirname (git) <space> [HH:MM]
function _line_1() {
    local _ps1_1="$(_color yellow)$USER$(_color normal) at $(_color magenta)$HOSTNAME$(_color normal) in $(_color green)$(abbr_pwd) $(git_branch)"
    echo $_ps1_1
}

# line 2
# (venv) ↪ $|#
function _line_2() { # TODO show venv info
    local _ps1_2=$(_color normal)

    if [[ $1 != 0 ]]; then
        _ps1_2="$_ps1_2$(_color red)"
    fi

    echo "${_ps1_2} ↪"
}

function _ps1() {
    local latest_status=$?
    echo "$(_line_1)"
    echo "$(_line_2 $latest_status) \$$(_color normal) "
    # \nでつなげるとsingle quoteで解釈されないみたい
}

PS1="\$(_ps1)"
export PS1

function __command_rprompt() {
    echo # 前のコマンドから一行空白行を入れる
    local rprompt=$(date "+[ %H:%M ]")
    local w_prompt=$(($COLUMNS - ${#rprompt}))
    printf "%${w_prompt}s$rprompt\\r"
}

PROMPT_COMMAND="$PROMPT_COMMAND"$'\n'__command_rprompt
