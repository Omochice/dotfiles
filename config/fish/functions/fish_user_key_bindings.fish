function fish_user_key_bindings
  if type "emptyls" >/dev/null 2>&1
    bind \r emptyls
  end
  bind \cq fzf-select
  bind \cr fzf_history
  bind \cg __lazygit
  bind \cT fzf-emoji
  bind --erase \cv --preset
  bind \cV fish_clipboard_paste
end
