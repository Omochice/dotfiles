local M = {}

function M.config()
  return {
    cmd = { "nixd" },
    filetypes = { "nix" },
    root_markers = { "flake.nix", "git" },
    formatting = {
      command = { "nixfmt" },
    },
  }
end

return M
