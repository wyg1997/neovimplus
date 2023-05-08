require("nvim-tree").setup({
    filters = {
        -- 不显示 .git 目录中的内容
        custom = {
            ".git/"
        },
        -- 显示 .gitignore
        exclude = {
            ".gitignore"
        },
        -- 不显示隐藏文件
        dotfiles = true
    },
    -- 以图标显示git 状态
    git = {
        enable = true
    }
})

vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeToggle<CR>", {noremap = true, silent = true})
