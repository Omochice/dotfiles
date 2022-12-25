function fzf-editor
  # if not install fzf return early
  if not type "fzf" >/dev/null 2>&1
    command echo "need fzf"
    commandline --function repaint
    return 1
  end

  # if bat is enable, use it
  set --local preview_cmd
  if type "bat" >/dev/null 2>&1
    set preview_cmd "bat"
  else
    set preview_cmd "less"
  end
  set --local files (fd --exclude ".git" | fzf --no-sort --multi --preview="$preview_cmd {}" --height=30%)

  # if any file selected, fail this function
  if test -z "$files"
    commandline --function repaint
    return 1
  end

  set --local editor $EDITOR
  if test -z "$editor"
    set editor "vim"
  end

  if echo "$editor" | grep "n\?vim" 2>&1
    set editor "$editor -p"
  end

  commandline --function repaint
  commandline --replace "$editor $files"
  commandline --function execute
end
