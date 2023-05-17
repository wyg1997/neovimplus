local icons = require('icons')

vim.opt.termguicolors = true

require("bufferline").setup{
    options = {
        mode = "buffers",
        numbers = function(opts)
            return string.format('%s', opts.ordinal)
        end,
        separator_style = "slant",
        indicator = {
            icon = icons.ui.BoldLineLeft, -- this should be omitted if indicator style is not 'icon'
            style = "icon", -- can also be 'underline'|'none',
        },
        modified_icon = icons.ui.Circle,
        left_trunc_marker = icons.ui.ArrowCircleLeft,
        right_trunc_marker = icons.ui.ArrowCircleRight,
        max_name_length = 18,
        max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
        truncate_names = true, -- whether or not tab names should be truncated
        tab_size = 18,
        enforce_regular_tabs = false,
        hover = {
            enabled = true,
            delay = 200,
            reveal = {'close'}
        },
        offsets = {
        {
          filetype = "undotree",
          text = "Undotree",
          highlight = "PanelHeading",
          padding = 1,
        },
        {
          filetype = "NvimTree",
          text = "Explorer",
          highlight = "PanelHeading",
          padding = 1,
        },
        {
          filetype = "DiffviewFiles",
          text = "Diff View",
          highlight = "PanelHeading",
          padding = 1,
        },
        {
          filetype = "flutterToolsOutline",
          text = "Flutter Outline",
          highlight = "PanelHeading",
        },
        {
          filetype = "lazy",
          text = "Lazy",
          highlight = "PanelHeading",
          padding = 1,
        },
      },
      color_icons = true, -- whether or not to add the filetype icon highlights
    }
}
require('bufferline.groups').builtin.pinned:with({ icon = "" })

vim.api.nvim_set_keymap("n", "<leader>1", ":BufferLineGoToBuffer 1<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>2", ":BufferLineGoToBuffer 2<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>3", ":BufferLineGoToBuffer 3<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>4", ":BufferLineGoToBuffer 4<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>5", ":BufferLineGoToBuffer 5<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>6", ":BufferLineGoToBuffer 6<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>7", ":BufferLineGoToBuffer 7<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>8", ":BufferLineGoToBuffer 8<CR>", {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "<leader>9", ":BufferLineGoToBuffer 9<CR>", {noremap = true, silent = true})

vim.api.nvim_set_keymap("n", "<leader>`", ":BufferLineTogglePin<CR>", {noremap = true, silent = true})
