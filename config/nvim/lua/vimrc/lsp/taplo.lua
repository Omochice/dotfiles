local M = {}

function M.config()
  return {
    workspace_config = {
      formatter = {
        reorderKeys = false,
        compactArray = false,
        arrayAutoCollapse = false,
        alignEntries = true,
      },
    },
  }
end

return M
