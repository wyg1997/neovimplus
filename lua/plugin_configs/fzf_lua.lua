vim.cmd[[:nmenu fzf_grep_menu.grep\ pattern        <cmd>:FzfLua grep<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.grep\ last           <cmd>:FzfLua grep_last<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.grep\ current\ word  <cmd>:FzfLua grep_cword<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.grep\ current\ WORD  <cmd>:FzfLua grep_cWORD<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.live\ grep\ buffer   <cmd>:FzfLua lgrep_curbuf<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.live\ grep\ project  <cmd>:FzfLua live_grep<CR>]]
vim.cmd[[:nmenu fzf_grep_menu.live\ grep\ resume   <cmd>:FzfLua live_grep_resume<CR>]]

require "which-key".add({
    { "<leader>/", "<cmd>FzfLua blines<CR>", desc = "search line from current buffer", nowait = false, remap = false },
    { "<leader>F", "<cmd>popup fzf_grep_menu<CR>j", desc = "search text from files", nowait = false, remap = false },
    { "<leader>b", "<cmd>FzfLua buffers<CR>", desc = "search buffer", nowait = false, remap = false },
    { "<leader>f", "<cmd>FzfLua files<CR>", desc = "search files", nowait = false, remap = false },
})

require "which-key".add({
    mode = {"v"},
    { "<leader>F", "<cmd>FzfLua grep_visual<CR>", desc = "search visual text from files", nowait = false, remap = false },
})
