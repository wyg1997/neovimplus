require "which-key".register({
    name = "fzf-lua",
    b = { "<cmd>FzfLua buffers<CR>", "search buffer" },
    ["/"] = { "<cmd>FzfLua blines<CR>", "search line from current buffer" },
    f = { "<cmd>FzfLua files<CR>", "search files" },
    F = { "<cmd>FzfLua grep<CR>", "search text from files" },
  }, {
    mode = "n",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = false,
})

require "which-key".register({
    F = { "<cmd>FzfLua grep_visual<CR>", "search visual text from files" },
  }, {
    mode = "v",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = false,
})
