function fish_user_key_bindings
  if type "emptyls" >/dev/null 2>&1
    bind \r emptyls
  end
  bind \cq fzf-editor
  bind \cr fzf_history
  bind \cg __lazygit
  bind \cT fzf-emoji
end
