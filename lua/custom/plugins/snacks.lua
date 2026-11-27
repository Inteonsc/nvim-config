---@diagnostic disable: undefined-global
local function gh(repo) return 'https://github.com/' .. repo end
local cow_lines = {}

vim.pack.add { gh 'folke/snacks.nvim' }
require('snacks').setup {
  dashboard = {
    preset = {
      keys = {
        { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
        { icon = '🐮', key = 'm', desc = 'New Quote', action = function() Snacks.dashboard.update() end },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { pane = 2, icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
      { pane = 2, icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
      {
        pane = 2,
        icon = ' ',
        title = 'Git Status',
        section = 'terminal',
        enabled = function() return Snacks.git.get_root() ~= nil end,
        cmd = 'git status --short --branch --renames',
        padding = 1,
        height = 5,
        ttl = 5 * 60,
        indent = 3,
      },
      { pane = 3, section = 'cow' },
      -- Dynamic bottom spacer for Pane 2
      function()
        -- Approximate base height of Pane 2 (Recent Files ~7 + Projects ~7 + Git Status ~7 if in git repo)
        local pane2_height = 14 + (Snacks.git.get_root() ~= nil and 7 or 0)
        local diff = math.max(0, #cow_lines + 5 - pane2_height)
        return { pane = 2, text = '', padding = { diff, 0 } }
      end,
    },
  },
}
-- cow in the corner
Snacks.dashboard.sections.cow = function()
  cow_lines = {}
  local lines
  for _ = 1, 10 do
    lines = vim.fn.systemlist 'fortune -l | cowsay -n'
    if vim.v.shell_error == 0 and #lines <= 25 then
      cow_lines = lines
      break
    end
  end
  local items = {}
  for _, l in ipairs(lines) do
    items[#items + 1] = { pane = 3, text = { { l, hl = 'header' } } }
  end
  return items
end
