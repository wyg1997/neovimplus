vim.cmd([[
    " How each level is indented and what to prepend.
    " This could make the display more compact or more spacious.
    " e.g., more compact: ["▸ ", ""]
    " Note: this option only works for the kind renderer, not the tree renderer.
    let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

    " Executive used when opening vista sidebar without specifying it.
    " See all the avaliable executives via `:echo g:vista#executives`.
    let g:vista_default_executive = 'coc'

    " Set the executive for some filetypes explicitly. Use the explicit executive
    " instead of the default one for these filetypes when using `:Vista` without
    " specifying the executive.
    let g:vista_executive_for = {
      \ 'cpp': 'coc',
      \ }

    " Declare the command including the executable and options used to generate ctags output
    " for some certain filetypes.The file path will be appened to your custom command.
    " For example:
    let g:vista_ctags_cmd = {
          \ 'haskell': 'hasktags -x -o - -c',
          \ }

    " To enable fzf's preview window set g:vista_fzf_preview.
    " The elements of g:vista_fzf_preview will be passed as arguments to fzf#vim#with_preview()
    " For example:
    let g:vista_fzf_preview = ['right:50%']
    
    " set the icons
    " Ensure you have installed some decent font to show these pretty symbols, then you can enable icon for the kind.
    let g:vista#renderer#enable_icon = 1

    " The default icons can't be suitable for all the filetypes, you can extend it as you wish.
    let g:vista#renderer#icons = {
    \   "function": "ƒ",
    \   "variable": "",
    \   "constant": "",
    \   "class": "",
    \  }
]])

require "which-key".register({
    name = "Vista",
    ["<leader>t"] = { ":Vista!!<CR>", "Toggle Vista"},
})
