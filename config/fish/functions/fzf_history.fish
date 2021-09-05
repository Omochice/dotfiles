# this from
# https://github.com/jethrokuan/fzf/blob/0c0f57c541073fdcb61f0367c3b86e389b61a3c2/functions/__fzf_reverse_isearch.fish

function fzf_history
    history merge
    history -z | fzf --read0 --print0 --height=40% | read -lz result
    and commandline $result
    commandline -f repaint
end
