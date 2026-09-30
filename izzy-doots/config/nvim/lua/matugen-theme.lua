local M = {}

function M.apply()
  package.loaded["matugen"] = nil

  local ok, c = pcall(require, "matugen")
  if not ok then
    return
  end

  local hl = vim.api.nvim_set_hl

  hl(0, "Normal",       { fg = c.foreground, bg = c.background })
  hl(0, "NormalFloat",  { fg = c.foreground, bg = c.surface })
  hl(0, "FloatBorder",  { fg = c.primary, bg = c.surface })

  hl(0, "CursorLine",   { bg = c.surface_container })
  hl(0, "Visual",       { bg = c.surface_container_high })
  hl(0, "LineNr",       { fg = c.outline })
  hl(0, "CursorLineNr", { fg = c.primary, bold = true })

  hl(0, "Comment",      { fg = c.foreground_dim, italic = true })

  hl(0, "String",       { fg = c.secondary })
  hl(0, "Character",    { fg = c.secondary })
  hl(0, "Number",       { fg = c.tertiary })
  hl(0, "Boolean",      { fg = c.tertiary })

  hl(0, "Identifier",   { fg = c.foreground })
  hl(0, "Function",     { fg = c.primary })

  hl(0, "Statement",    { fg = c.primary })
  hl(0, "Keyword",      { fg = c.primary, italic = true })
  hl(0, "Operator",     { fg = c.tertiary })

  hl(0, "Type",         { fg = c.secondary })
  hl(0, "Special",      { fg = c.tertiary })

  hl(0, "DiagnosticError", { fg = c.error })
  hl(0, "DiagnosticWarn",  { fg = c.tertiary })
  hl(0, "DiagnosticInfo",  { fg = c.primary })
  hl(0, "DiagnosticHint",  { fg = c.secondary })

  hl(0, "Pmenu",        { fg = c.foreground, bg = c.surface })
  hl(0, "PmenuSel",     { fg = c.background, bg = c.primary })

  hl(0, "StatusLine",   { fg = c.foreground, bg = c.surface_container })
  hl(0, "StatusLineNC", { fg = c.foreground_dim, bg = c.surface })
end

return M

