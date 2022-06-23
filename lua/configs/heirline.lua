local status_ok, heirline = pcall(require, "heirline")
if status_ok then
  local C = require "default_theme.colors"
  local utils = require "heirline.utils"
  local conditions = require "heirline.conditions"
  local st = require "core.status"

  local function hl_default(hlgroup, prop, default)
    return vim.fn.hlexists(hlgroup) == 1 and utils.get_highlight(hlgroup)[prop] or default
  end

  local function setup_colors()
    return astronvim.user_plugin_opts("heirline.colors", {
      fg = hl_default("StatusLine", "fg", C.fg),
      bg = hl_default("StatusLine", "bg", C.grey_4),
      section_bg = hl_default("StatusLine", "bg", C.grey_4),
      normal = st.hl.lualine_mode("normal", hl_default("HeirlineNormal", "fg", C.blue)),
      insert = st.hl.lualine_mode("insert", hl_default("HeirlineInsert", "fg", C.green)),
      visual = st.hl.lualine_mode("visual", hl_default("HeirlineVisual", "fg", C.purple)),
      replace = st.hl.lualine_mode("replace", hl_default("HeirlineReplace", "fg", C.red_1)),
      command = st.hl.lualine_mode("command", hl_default("HeirlineCommand", "fg", C.yellow_1)),
      inactive = hl_default("HeirlineInactive", "fg", C.grey_7),
      git_branch = hl_default("Conditional", "fg", C.purple_1),
      git_add = hl_default("GitSignsAdd", "fg", C.green),
      git_change = hl_default("GitSignsChange", "fg", C.orange_1),
      git_del = hl_default("GitSignsDelete", "fg", C.red_1),
      diag_error = hl_default("DiagnosticError", "fg", C.red_1),
      diag_warn = hl_default("DiagnosticWarn", "fg", C.orange_1),
      diag_info = hl_default("DiagnosticInfo", "fg", C.white_2),
      diag_hint = hl_default("DiagnosticHint", "fg", C.yellow_1),
      green = hl_default("String", "fg", C.green),
      yellow = hl_default("TypeDef", "fg", C.yellow),
    })
  end

  heirline.load_colors(setup_colors())
  heirline.setup(astronvim.user_plugin_opts("plugins.heirline", {
    hl = { fg = "fg", bg = "bg" },
    utils.surround(st.separators.left, st.hl.mode_fg, { provider = st.provider.str " " }),
    {
      condition = conditions.is_git_repo,
      utils.surround(st.separators.left, "section_bg", {
        { provider = st.provider.git_branch { icon = " " }, hl = { fg = "git_branch", bold = true } },
      }),
    },
    {
      condition = st.condition.has_filetype,
      utils.surround(st.separators.left, "section_bg", {
        { provider = st.provider.fileicon(), hl = st.hl.filetype_color },
        { provider = st.provider.filetype { padding = { left = 1 } } },
      }),
    },
    {
      condition = st.condition.git_changed,
      utils.surround(st.separators.left, "section_bg", {
        { provider = st.provider.git_diff("added", { icon = "  " }), hl = { fg = "git_add" } },
        { provider = st.provider.git_diff("changed", { icon = "  " }), hl = { fg = "git_change" } },
        { provider = st.provider.git_diff("removed", { icon = "  " }), hl = { fg = "git_del" } },
      }),
    },
    {
      condition = conditions.has_diagnostics,
      utils.surround(st.separators.left, "section_bg", {
        { provider = st.provider.diagnostics("ERROR", { icon = "  " }), hl = { fg = "diag_error" } },
        { provider = st.provider.diagnostics("WARN", { icon = " " }), hl = { fg = "diag_warn" } },
        { provider = st.provider.diagnostics("INFO", { icon = " " }), hl = { fg = "diag_info" } },
        { provider = st.provider.diagnostics("HINT", { icon = " " }), hl = { fg = "diag_hint" } },
      }),
    },
    { provider = st.provider.fill() },
    {
      condition = conditions.lsp_attached,
      utils.surround(st.separators.right, "section_bg", {
        utils.make_flexible_component(1, { provider = st.provider.lsp_progress() }, { provider = "" }),
        utils.make_flexible_component(
          2,
          { provider = st.provider.lsp_client_names(true, 0.25, { icon = "   " }) },
          { provider = st.provider.str("LSP", { icon = "   " }) }
        ),
      }),
    },
    {
      condition = st.condition.treesitter_available,
      utils.surround(st.separators.right, "section_bg", {
        { provider = st.provider.str("TS", { icon = "綠" }), hl = { fg = "green" } },
      }),
    },
    {
      utils.surround(st.separators.right, "section_bg", {
        { provider = st.provider.ruler(0, 0) },
      }),
    },
    {
      utils.surround(st.separators.right, "section_bg", {
        { provider = st.provider.percentage() },
        { provider = st.provider.scrollbar { padding = { left = 1 } }, hl = { fg = "yellow" } },
      }),
    },
    utils.surround(st.separators.right, st.hl.mode_fg, { provider = st.provider.str " " }),
  }))

  vim.api.nvim_create_augroup("Heirline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "Heirline",
    callback = function()
      heirline.reset_highlights()
      heirline.load_colors(setup_colors())
    end,
  })
end
