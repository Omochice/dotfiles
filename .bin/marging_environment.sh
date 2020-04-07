marge_env(){
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)
    if [[ "$HOME" != "$dotdir" ]];then
    for f in $dotdir/.??*; do
      [[ `basename $f` == ".git" ]] && continue
      if [[ -e "$HOME/`basename $f`" ]];then
        command cp -ru "$HOME/`basename $f`" "$dotdir/"
      fi
    done
  else
    command echo "same install src dest"
  fi
}


marge_env
command echo "complete merging !"
