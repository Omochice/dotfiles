local M = {
  cmd = { "nixd" },
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
  formatting = {
    command = { "nixfmt" },
  },
}

return M
