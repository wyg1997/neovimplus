" OriginAuthor: chxuan <787280310@qq.com>
" OriginRepository: https://github.com/chxuan/vimplus
" Create Date: 2016-04-10
" License: MIT
"
" Author: wyg1997 <wyg19970408@gmail.com>
" Repository: https://github.com/wyg1997/neovimplus
" Create Date: 2020-12-23
" License: MIT

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 通用设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","      " 定义<leader>键
set nocompatible         " 设置不兼容原始vi模式
filetype on              " 设置开启文件类型侦测
filetype plugin on       " 设置加载对应文件类型的插件
set noeb                 " 关闭错误的提示
syntax enable            " 开启语法高亮功能
syntax on                " 自动语法高亮
set t_Co=256             " 开启256色支持
set cmdheight=2          " 设置命令行的高度
set showcmd              " select模式下显示选中的行数
set ruler                " 总是显示光标位置
set laststatus=2         " 总是显示状态栏
set number               " 开启行号显示
set relativenumber       " 开启相对行号显示
set cursorline           " 高亮显示当前行
set whichwrap+=<,>,h,l   " 设置光标键跨行
set ttimeoutlen=0        " 设置<ESC>键响应时间
set virtualedit=block,onemore   " 允许光标出现在最后一个字符的后面
set mouse=               " 默认关闭鼠标模式

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 代码缩进和排版
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set autoindent           " 设置自动缩进
set cindent              " 设置使用C/C++语言的自动缩进方式
set cinoptions=g0,:0,N-s,(0    " 设置C/C++语言的具体缩进方式
set smartindent          " 智能的选择对其方式
filetype indent on       " 自适应不同语言的智能缩进
set expandtab            " 将制表符扩展为空格
set tabstop=4            " 设置编辑时制表符占用空格数
set shiftwidth=4         " 设置格式化时制表符占用空格数
set softtabstop=4        " 设置4个空格为制表符
set smarttab             " 在行和段开始处使用制表符
set nowrap               " 禁止折行
set backspace=2          " 使用回车键正常处理indent,eol,start等
set sidescroll=10        " 设置向右滚动字符数
set nofoldenable         " 禁用折叠代码

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 代码补全
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wildmenu             " vim自身命名行模式智能补全
set completeopt-=preview " 补全时不显示窗口，只显示补全列表

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 搜索设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hlsearch            " 高亮显示搜索结果
set incsearch           " 开启实时搜索功能
set ignorecase          " 搜索时大小写不敏感

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 缓存设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hidden              " 允许隐藏未保存的buffer
set noswapfile          " 禁止生成临时文件
set autoread            " 文件在vim之外修改过，自动重新读入
set autowrite           " 设置自动保存
set confirm             " 在处理未保存或只读文件的时候，弹出确认

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 编码设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set langmenu=zh_CN.UTF-8
set helplang=cn
set termencoding=utf-8
set encoding=utf8
set fileencodings=utf8,ucs-bom,gbk,cp936,gb2312,gb18030

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" gvim/macvim设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("gui_running")
    let system = system('uname -s')
    if system == "Darwin\n"
        set guifont=Droid\ Sans\ Mono\ Nerd\ Font\ Complete:h18 " 设置字体
    else
        set guifont=DroidSansMono\ Nerd\ Font\ Regular\ 18      " 设置字体
    endif
    set guioptions-=m           " 隐藏菜单栏
    set guioptions-=T           " 隐藏工具栏
    set guioptions-=L           " 隐藏左侧滚动条
    set guioptions-=r           " 隐藏右侧滚动条
    set guioptions-=b           " 隐藏底部滚动条
    set showtabline=0           " 隐藏Tab栏
    set guicursor=n-v-c:ver5    " 设置光标为竖线
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 卸载默认插件UnPlug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:deregister(repo)
  let repo = substitute(a:repo, '[\/]\+$', '', '')
  let name = fnamemodify(repo, ':t:s?\.git$??')
  call remove(g:plugs, name)
endfunction
command! -nargs=1 -bar UnPlug call s:deregister(<args>)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 插件列表
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

Plug 'derekwyatt/vim-fswitch'  " .h和.c/.cc/.cpp文件切换
Plug 'chxuan/vim-edit'  " 方便的文本编辑工具
Plug 'Yggdroot/LeaderF'  " 强大的文件搜索工具
Plug 'junegunn/fzf', { 'dir': '~/.neovimplus/.fzf', 'do': './install --all' },
Plug 'junegunn/fzf.vim',
Plug 'easymotion/vim-easymotion'  " 单词跳转
Plug 'haya14busa/incsearch.vim'  " 文本搜索增强
Plug 'jiangmiao/auto-pairs'  " 括号匹配工具
Plug 'scrooloose/nerdtree'  " 文件树查看
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'  " 美化NerdTree的显示
Plug 'Xuyuanp/nerdtree-git-plugin'  " NerdTree git图标显示
Plug 'tpope/vim-fugitive'  " Git集成插件
Plug 'tpope/vim-surround'  " 括号高效处理工具
Plug 'tpope/vim-repeat'  " 扩展vim的repeat
Plug 'preservim/nerdcommenter'  " 代码注释工具
Plug 'octol/vim-cpp-enhanced-highlight'  " C++高亮工具
Plug 'vim-airline/vim-airline'  " vim状态栏美化
Plug 'vim-airline/vim-airline-themes'  " vim状态栏主题
Plug 'ryanoasis/vim-devicons'  " 图标美化
Plug 'junegunn/vim-slash'  " vim搜索优化
Plug 'junegunn/gv.vim'  " git commit查看工具
Plug 'RRethy/vim-illuminate'  " 相同单词高亮
" 以下5个插件将不同对象视为整体
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-indent'  " 定义缩进obj
Plug 'kana/vim-textobj-function'  " 定义function obj
Plug 'sgur/vim-textobj-parameter'  " 定义参数obj

Plug 'Shougo/echodoc.vim'  " 补全时显示函数签名
Plug 'terryma/vim-smooth-scroll'  " 平滑滚动
Plug 'rhysd/clever-f.vim'  " 快速字符跳转
Plug 'vim-scripts/indentpython.vim'  " python缩进辅助
Plug 'docunext/closetag.vim'  " 自动完成html标签
Plug 'nvie/vim-flake8'  " 使用flake8检察python代码
Plug 'chxuan/vim-buffer'  " Buffer操作工具
Plug 'puremourning/vimspector'  " 代码 Debug 工具
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " 强大的nvim代码智能感知插件
Plug 'ojroques/vim-oscyank', {'branch': 'main'}  " 复制内容到本地剪切板
Plug 'nvim-lua/plenary.nvim'  " Lua 语法糖
Plug 'ruifm/gitlinker.nvim'  " 生成代码对应的 github 链接

" 加载自定义插件
if filereadable(expand($HOME . '/.config/nvim/init.vim.custom.plugins'))
    source $HOME/.config/nvim/init.vim.custom.plugins
endif

call plug#end()  

" load vim default plugin
runtime macros/matchit.vim

" 打开当前光标所在单词的vim帮助文档
nnoremap <leader>H :execute ":help " . expand("<cword>")<cr>

" 查看neovimplus的help文件
nnoremap <leader>h :view +let\ &l:modifiable=0 ~/.neovimplus/help.md<cr>

" 分屏窗口移动
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" jump in popup window
nnoremap <leader>pp :call coc#float#jump()<cr>

" 复制当前选中到系统剪切板
set clipboard+=unnamed
vmap <leader><leader>y "+y

" 打开文件自动定位到最后编辑的位置
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif

" 主题设置
set background=dark
let g:onedark_termcolors=256
colorscheme onedark

" fswitch
nmap <silent> gf :FSHere<cr>

" vim-edit
nnoremap Y :CopyText<cr>
nnoremap D :DeleteText<cr>
nnoremap C :ChangeText<cr>
nnoremap <leader>rr :ReplaceTo<space>

" LeaderF
nnoremap <leader>f :LeaderfFile .<cr>
nnoremap <leader>t :LeaderfFunction!<cr>
let g:Lf_WildIgnore = {
            \ 'dir': ['.svn','.git','.hg','.vscode','.wine','.deepinwine','.oh-my-zsh', 'log'],
            \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
            \}
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 1
let g:Lf_NormalMap = {
	\ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
	\ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']],
	\ "Mru":    [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
	\ "Tag":    [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>']],
	\ "Function":    [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>']],
	\ "Colorscheme":    [["<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"<CR>']],
	\ }

" fzf
nnoremap <leader>F :Rg<space>
let g:fzf_buffers_jump = 1
let g:fzf_layout = { 'down': '~40%' }
let $FZF_DEFAULT_OPTS="--ansi --layout reverse"
" Rg command with preview window
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" vim-easymotion
let g:EasyMotion_smartcase = 1
map <leader>w <Plug>(easymotion-bd-w)
nmap <leader>w <Plug>(easymotion-overwin-w)

" incsearch.vim
map /  <Plug>(incsearch-forward)
map g/ <Plug>(incsearch-stay)

" auto-pairs
let g:AutoPairsFlyMode = 0
let g:AutoPairsMultilineClose = 0

" nerdtree
nnoremap <silent> <leader>n :NERDTreeToggle<cr>
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeHighlightFolders = 1         
let g:NERDTreeHighlightFoldersFullName = 1 
let g:NERDTreeDirArrowExpandable='▷'
let g:NERDTreeDirArrowCollapsible='▼'
let g:NERDTreeIgnore=['\.pyc','\~$','\.swp']

" nerdtree-git-plugin
let g:NERDTreeGitStatusIndicatorMapCustom = {
            \ "Modified"  : "✹",
            \ "Staged"    : "✚",
            \ "Untracked" : "✭",
            \ "Renamed"   : "➜",
            \ "Unmerged"  : "═",
            \ "Deleted"   : "✖",
            \ "Dirty"     : "✗",
            \ "Clean"     : "✔︎",
            \ 'Ignored'   : '☒',
            \ "Unknown"   : "?"
            \ }

" nerdcommenter
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }
let g:NERDCommentEmptyLines = 0
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1
nnoremap gcc :call nerdcommenter#Comment(0, "toggle")<C-m>
vnoremap gc :call nerdcommenter#Comment(0, "toggle")<C-m>

" airline
let g:airline_theme="onedark"
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''

" vim-slash
noremap <plug>(slash-after) zz

" gv
nnoremap <leader>g :GV<cr>
nnoremap <leader>G :GV!<cr>
nnoremap <leader>gg :GV?<cr>

" vim-illuminate
let g:Illuminate_useDeprecated = 1
let g:Illuminate_delay = 100
augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi link illuminatedWord VisualNOS
augroup END

" echodoc.vim
let g:echodoc_enable_at_startup = 1

" vim-smooth-scroll
noremap <silent> <c-u> :call smooth_scroll#up(&scroll, 0, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 0, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 0, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 0, 4)<CR>

" Termdebug
let g:termdebug_wide = 163
tnoremap <ESC><ESC> <C-\><C-N>

" vim-buffer
nnoremap <leader><tab> :NextBuffer<cr>
nnoremap <leader><S-tab> :PreviousBuffer<cr>
nnoremap <leader>x :CloseBuffer<cr>
nnoremap <leader>X :BufOnly<cr>

" coc.nvim
" ======================================> coc.vim setting start
let g:coc_global_extensions = [
            \ "coc-pyright",
            \ "coc-jedi",
            \ "coc-clangd",
            \ "coc-cmake",
            \ "coc-git",
            \ "coc-gitignore",
            \ "coc-highlight",
            \ "coc-json",
            \ "coc-sh",
            \ "coc-actions",
            \ "coc-docker",
            \ "coc-vimlsp",
            \ "coc-yaml",
            \ "coc-syntax",
            \ "coc-pairs",
            \ "coc-xml",
            \ "coc-markdownlint",
            \ "coc-diagnostic",
            \ "coc-translator",
            \ "coc-spell-checker"
            \]

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=100
 
" don't give |ins-completion-menu| messages.
set shortmess+=c
 
" always show signcolumns
set signcolumn=yes

" Link CocMenuSel to PmenuSel temporarily for new version of coc.nvim
" see: https://github.com/neoclide/coc.nvim/issues/3980
" and https://github.com/joshdick/onedark.vim/issues/313
" for detail
highlight! link CocMenuSel PmenuSel
 
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
 
" Use <C-l> to trigger completion.
inoremap <silent><expr> <C-l> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" Remap keys for gotos
nmap <silent> <leader>d <Plug>(coc-definition)
" nmap <silent> <leader>y <Plug>(coc-type-definition)
" nmap <silent> <leader>i <Plug>(coc-implementation)
nmap <silent> <leader>r <Plug>(coc-references)
 
" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
 
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
 
" Highlight symbol under cursor on CursorHold
" autocmd CursorHold * silent call CocActionAsync('highlight')
 
" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
 
" " Remap for format selected region
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)
 
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
 
" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
 
" Remap for do codeAction of current line
" nmap <leader>ac  <Plug>(coc-codeaction)

" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)
 
" Create mappings for function text object, requires document symbols feature of languageserver.
" NOTE: textobj plugin implement it, see help.md for detail.
" xmap if <Plug>(coc-funcobj-i)
" xmap af <Plug>(coc-funcobj-a)
" omap if <Plug>(coc-funcobj-i)
" omap af <Plug>(coc-funcobj-a)
 
" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
 
" " Use `:Fold` to fold current buffer
" command! -nargs=? Fold :call     CocAction('fold', <f-args>)
 
" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" coc-translator mapping
" popup
nmap <Leader>T <Plug>(coc-translator-p)
vmap <Leader>T <Plug>(coc-translator-pv)

" ======================================> coc.vim setting end

" puremourning/vimspector
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
" for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval

" ojroques/vim-oscyank
vnoremap <leader>c :OSCYank<CR>

" ruifm/gitlinker.nvim
lua require"gitlinker".setup()

" 加载自定义配置
if filereadable(expand($HOME . '/.config/nvim/init.vim.custom.config'))
    source $HOME/.config/nvim/init.vim.custom.config
endif

