# NeovimPlus

Simple and beautiful editor for neovim programmer.

## 简介

- 本仓库有很大一部分是借鉴自 [chxuan/vimplus](https://github.com/chxuan/vimplus) ，之前我也是这个仓库的忠实使用者，但在重度 vim 开发过程中越来越觉得 [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe) 的不方便，这才转用 neovim 和 coc.nvim 了。
- 最近开始学习并逐渐使用lua来做插件配置，主要是参考学习自 [aMonst/nvimrc-tutorial](https://github.com/aMonst/nvimrc-tutorial/tree/main)

初衷和原作者一样，希望为 vim 程序员提供一个安装方便、使用体验很棒的编辑器。

## 安装

```shell
git clone https://github.com/wyg1997/neovimplus.git ~/.neovimplus
cd ~/.neovimplus
./install.sh
```

> NOTE: 字体个人使用: [MesloNerdFont](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo/M)，可以兼顾p10k和插件里的一些图标显示。

## 自定义配置

- `~/.neovimplus/init.vim`：默认配置
- `~/.neovimplus/init.vim.custom.config`：用户自定义配置，可以覆盖默认配置
- `~/.neovimplus/init.vim.custom.plugins`：用户插件

## 帮助

可以在 nvim 中输入 `,h` 来打开帮助文档，各内置插件的功能和快捷键都在这里注明。

## 反馈

内置插件都是本人用起来比较舒服的，可能有些并不是那么好用，如果在使用体验上有不好的地方，欢迎提 issue 反馈，我也会慢慢改进。

