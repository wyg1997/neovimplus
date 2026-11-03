# NeovimPlus

Simple and beautiful editor for neovim programmer.

## 简介

- 本仓库有很大一部分是借鉴自 [chxuan/vimplus](https://github.com/chxuan/vimplus) ，之前我也是这个仓库的忠实使用者，但在重度 vim 开发过程中越来越觉得 [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe) 的不方便，这才转用 neovim 和 coc.nvim 了。
- 最近开始学习并逐渐使用lua来做插件配置，主要是参考学习自 [aMonst/nvimrc-tutorial](https://github.com/aMonst/nvimrc-tutorial/tree/main)

初衷和原作者一样，希望为 vim 程序员提供一个安装方便、使用体验很棒的编辑器。

## 安装

安装脚本完全运行在用户态，不需要 `sudo` 或 root 权限。它会把工具和配置安装到当前用户目录，
不会修改系统目录；Python 依赖会安装到当前 `PATH` 中 `python3` 所属的环境。

```shell
git clone https://github.com/wyg1997/neovimplus.git ~/.neovimplus
cd ~/.neovimplus
./install.sh
```

安装脚本会自动完成以下工作：

- 下载官方较新版本的 Neovim 到 `~/.local/opt/nvim`
- 安装 coc.nvim 所需的 Node.js、ripgrep 和 fzf
- 在 PATH 中的全局 Python 3 环境安装 `pynvim`、`debugpy`、`jedi-language-server` 等依赖
- 安装 clangd，供 C/C++ 补全使用
- 链接 Neovim 配置，并通过 vim-plug 安装全部插件
- 安装 coc 扩展以及 `cpp`、`python`、`vim`、`lua` 的 Treesitter parser

安装器提供的 `nvim`、`node`、`rg`、`fzf`、`clangd` 会链接到 `~/.local/bin`。脚本会把这个
目录加入已有的 `~/.profile`、`~/.bashrc`、`~/.bash_profile`、`~/.zshrc`；如果当前 shell
还没有生效，可以执行：

```shell
export PATH="$HOME/.local/bin:$PATH"
```

### 前置依赖

只需要系统里已有 `curl`、`tar`、`git`、`python3` 和 C 编译器 `cc`。其中 `python3` 需要带有
`pip`；如果它是当前激活的虚拟环境，依赖会安装到该环境，否则安装到用户目录。缺少 `cc` 时仍可
正常启动，但 Treesitter parser 无法编译。其余依赖均由安装脚本下载到用户目录。

如果系统 Python 的 pip 启用了 PEP 668（常见于 Ubuntu 24.04+），请先激活一个日常使用的
Python 虚拟环境，再执行安装脚本。

### 网络受限或使用代理

安装脚本和 git 会读取标准的代理环境变量。例如本机 `127.0.0.1:7890` 有代理时：

```shell
HTTPS_PROXY=http://127.0.0.1:7890 \
HTTP_PROXY=http://127.0.0.1:7890 \
NO_PROXY=localhost,127.0.0.1 \
./install.sh
```

如果 `git clone` 仓库本身也需要代理：

```shell
HTTPS_PROXY=http://127.0.0.1:7890 \
git clone https://github.com/wyg1997/neovimplus.git ~/.neovimplus
```

GitHub 直连失败时，脚本会自动回退到内置镜像。也可以自行指定镜像和版本：

```shell
GITHUB_MIRRORS="https://ghfast.top/ https://gh-proxy.com/" \
NVIM_VERSION=v0.12.6 \
INSTALL_CLANGD=0 \
./install.sh
```

`INSTALL_CLANGD=0` 会跳过体积较大的 clangd 下载，此时 C/C++ 语法高亮和文件加载仍然可用，
只是没有基于 clangd 的补全与诊断。安装脚本是幂等的，重复执行会复用已安装或已校验的内容。

### 验证安装

```shell
./verify.sh
```

验证脚本会用当前用户态的 Neovim 分别加载一个 C++ 和一个 Python 文件，检查文件类型识别、
Treesitter parser、启动过程是否报错，以及 `node`、`rg`、`fzf`、`jedi-language-server` 等
运行时依赖是否齐全。

### 更新

```shell
./update.sh
```

`update.sh` 拉取当前分支更新后，会重新执行幂等的 `install.sh`，同步插件和语言服务。

> NOTE: 字体个人使用: [MesloNerdFont](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo/M)，可以兼顾p10k和插件里的一些图标显示。

## 自定义配置

- `~/.neovimplus/init.vim`：默认配置
- `~/.neovimplus/init.vim.custom.config`：用户自定义配置，可以覆盖默认配置
- `~/.neovimplus/init.vim.custom.plugins`：用户插件

## 帮助

可以在 nvim 中输入 `,h` 来打开帮助文档，各内置插件的功能和快捷键都在这里注明。

## 反馈

内置插件都是本人用起来比较舒服的，可能有些并不是那么好用，如果在使用体验上有不好的地方，欢迎提 issue 反馈，我也会慢慢改进。

