vim.cmd[[:nmenu fzf_grep_menu.grep\ pattern        <cmd>:FzfLua grep<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.grep\ last           <cmd>:FzfLua grep_last<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.grep\ current\ word  <cmd>:FzfLua grep_cword<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.grep\ current\ WORD  <cmd>:FzfLua grep_cWORD<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.live\ grep\ buffer   <cmd>:FzfLua lgrep_curbuf<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.live\ grep\ project  <cmd>:FzfLua live_grep<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.live\ grep\ resume   <cmd>:FzfLua live_grep_resume<CR>]]

require "which-key".register({
    name  = "fzf-lua",
    b     = { "<cmd>FzfLua buffers<CR>", "search buffer" },
    ["/"] = { "<cmd>FzfLua blines<CR>", "search line from current buffer" },
    f     = { "<cmd>FzfLua files<CR>", "search files" },
    F     = { "<cmd>popup fzf_grep_menu<CR>", "search text from files" },
  }, {
    mode    = "n",
    prefix  = "<leader>",
    buffer  = nil,
    silent  = true,
    noremap = true,
    nowait  = false,
})

require "which-key".register({
    F = { "<cmd>FzfLua grep_visual<CR>", "search visual text from files" },
  }, {
    mode    = "v",
    prefix  = "<leader>",
    buffer  = nil,
    silent  = true,
    noremap = true,
    nowait  = false,
})
