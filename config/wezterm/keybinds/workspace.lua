local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local ghq = require("ghq")

local function workspace_choices()
  local choices = {}
  for _, name in ipairs(mux.get_workspace_names()) do
    table.insert(choices, { label = name, id = name })
  end
  return choices
end

local switch_workspace = wezterm.action_callback(function(window, pane)
  window:perform_action(
    act.InputSelector({
      title = "Switch workspace",
      choices = workspace_choices(),
      fuzzy = true,
      action = wezterm.action_callback(function(inner_window, inner_pane, id, _)
        if id == nil then
          return
        end
        inner_window:perform_action(act.SwitchToWorkspace({ name = id }), inner_pane)
      end),
    }),
    pane
  )
end)

local create_workspace = wezterm.action_callback(function(window, pane)
  local repositories, err = ghq.repositories()
  if repositories == nil then
    -- A denied notification permission drops the toast without a trace, so the
    -- log keeps the reason recoverable.
    wezterm.log_error(err)
    window:toast_notification("wezterm", err, nil, 4000)
    return
  end
  local choices = {}
  for _, repository in ipairs(repositories) do
    table.insert(choices, { label = repository.name, id = repository.path })
  end
  window:perform_action(
    act.InputSelector({
      title = "Create workspace from ghq",
      choices = choices,
      fuzzy = true,
      -- SwitchToWorkspace switches to an existing workspace of the same name
      -- instead of creating a duplicate, so spawn only describes the first tab.
      action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
        if id == nil or label == nil then
          return
        end
        inner_window:perform_action(act.SwitchToWorkspace({ name = label, spawn = { cwd = id } }), inner_pane)
      end),
    }),
    pane
  )
end)

return {
  { key = "w", mods = "ALT", action = switch_workspace },
  { key = "w", mods = "ALT|SHIFT", action = create_workspace },
}
