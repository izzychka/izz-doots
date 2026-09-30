local matugen = require("matugen-theme")
matugen.apply()

vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    matugen.apply()
    vim.cmd("redraw!")
  end,
})
