vim.api.nvim_set_keymap("n", "<leader>t", ":TlistToggle<CR>", {noremap = true, silent = true})

vim.cmd([[
    let Tlist_Show_One_File = 1
    let Tlist_Exit_OnlyWindow = 1
    let Tlist_Use_Right_Window = 1
    let Tlist_Process_File_Always = 0
    let Tlist_File_Fold_Auto_Close = 1
    let Tlist_Highlight_Tag_On_BufEnter = 1
    let Tlist_WinWidth = 30
]])
