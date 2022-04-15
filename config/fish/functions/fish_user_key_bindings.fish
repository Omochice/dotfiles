function fish_user_key_bindings
  if type "emptyls" >/dev/null 2>&1
    bind \r emptyls
  end
  bind \cr fzf_history
  bind \cg __lazygit
  bind \cE fzf-emoji
end
