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

require "which-key".register({
    name = "bufferline",
    ["1"] = { ":BufferLineGoToBuffer 1<CR>", "To buffer 1"},
    ["2"] = { ":BufferLineGoToBuffer 2<CR>", "To buffer 2"},
    ["3"] = { ":BufferLineGoToBuffer 3<CR>", "To buffer 3"},
    ["4"] = { ":BufferLineGoToBuffer 4<CR>", "To buffer 4"},
    ["5"] = { ":BufferLineGoToBuffer 5<CR>", "To buffer 5"},
    ["6"] = { ":BufferLineGoToBuffer 6<CR>", "To buffer 6"},
    ["7"] = { ":BufferLineGoToBuffer 7<CR>", "To buffer 7"},
    ["8"] = { ":BufferLineGoToBuffer 8<CR>", "To buffer 8"},
    ["9"] = { ":BufferLineGoToBuffer 9<CR>", "To buffer 9"},
    ["`"] = { ":BufferLineTogglePin<CR>", "Pin current buffer" },
  }, {
    mode = "n",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = false,
})
