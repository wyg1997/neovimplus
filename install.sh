#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?HOME is not set}"
LOCAL_PREFIX="${NEOVIMPLUS_PREFIX:-$HOME_DIR/.local}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME_DIR/.local/share}"

BIN_DIR="$LOCAL_PREFIX/bin"
OPT_DIR="$LOCAL_PREFIX/opt"
NVIM_ROOT="$OPT_DIR/nvim"
NODE_ROOT="$OPT_DIR/node"
NVIM_CONFIG_DIR="$XDG_CONFIG_HOME/nvim"
NVIM_SITE_DIR="$XDG_DATA_HOME/nvim/site"
PLUGIN_DATA_DIR="$XDG_DATA_HOME/neovimplus"
PLUGGED_DIR="$HOME_DIR/.vim/plugged"

MIN_NVIM_VERSION="${MIN_NVIM_VERSION:-0.10.0}"
NVIM_VERSION="${NVIM_VERSION:-}"
NVIM_FALLBACK_VERSION="${NVIM_FALLBACK_VERSION:-v0.12.6}"
NODE_VERSION="${NODE_VERSION:-v24.22.1}"
RIPGREP_VERSION="${RIPGREP_VERSION:-15.2.0}"
FZF_VERSION="${FZF_VERSION:-0.74.5}"
CLANGD_VERSION="${CLANGD_VERSION:-}"
CLANGD_FALLBACK_VERSION="${CLANGD_FALLBACK_VERSION:-23.1.0}"
BACKUP_SUFFIX="backup.$(date +%Y%m%d%H%M%S)"
GITHUB_MIRRORS="${GITHUB_MIRRORS:-https://ghfast.top/ https://gh-proxy.com/}"
GITHUB_DIRECT="${GITHUB_DIRECT:-1}"

OS=""
ARCH=""
NVIM_PLATFORM=""
NVIM_ARCH=""
NODE_PLATFORM=""
NODE_ARCH=""
RIPGREP_TARGET=""
FZF_PLATFORM=""
FZF_ARCH=""
SELECTED_GITHUB_MIRROR=""

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "缺少命令 '$1'，请先安装它（无需 root 的发行包也可以）。"
}

download() {
    local url="$1"
    local output="$2"
    curl -fL --retry 3 --retry-delay 2 --connect-timeout 8 --max-time 900 \
        --speed-limit 1024 --speed-time 15 \
        --silent --show-error "$url" -o "$output"
}

download_github() {
    local url="$1"
    local output="$2"
    local mirror

    rm -f "$output"
    if [ "$GITHUB_DIRECT" = "1" ]; then
        if download "$url" "$output"; then
            return
        fi
    fi

    for mirror in $GITHUB_MIRRORS; do
        warn "直连 GitHub 失败，尝试镜像：$mirror"
        if download "${mirror}${url}" "$output"; then
            return
        fi
    done

    rm -f "$output"
    die "无法下载 $url（GitHub 直连和镜像均失败）"
}

latest_github_tag() {
    local repo="$1"
    curl -fsSL --connect-timeout 15 "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
        | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' \
        | head -n 1 || true
}

version_ge() {
    local current="${1#v}"
    local required="${2#v}"
    local i
    local -a current_parts
    local -a required_parts
    IFS=. read -r -a current_parts <<< "$current"
    IFS=. read -r -a required_parts <<< "$required"

    for ((i = 0; i < ${#required_parts[@]}; i++)); do
        local current_part="${current_parts[i]:-0}"
        local required_part="${required_parts[i]:-0}"
        current_part="${current_part%%[!0-9]*}"
        required_part="${required_part%%[!0-9]*}"
        current_part="${current_part:-0}"
        required_part="${required_part:-0}"
        if ((current_part > required_part)); then
            return 0
        fi
        if ((current_part < required_part)); then
            return 1
        fi
    done
    return 0
}

nvim_version_of() {
    "$1" --version 2>/dev/null | sed -n '1s/^NVIM v\{0,1\}\([^ ]*\).*/\1/p'
}

github_asset_digest() {
    local repo="$1"
    local tag="$2"
    local asset="$3"
    curl -fsSL --connect-timeout 15 "https://api.github.com/repos/$repo/releases/tags/$tag" 2>/dev/null \
        | awk -v asset="\"name\": \"$asset\"" '
            index($0, asset) { found = 1 }
            found && /"digest": "sha256:/ {
                sub(/.*"digest": "sha256:/, "")
                sub(/".*/, "")
                print
                exit
            }
        ' || true
}

sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

first_subdir() {
    local root="$1"
    local dir
    for dir in "$root"/*/; do
        [ -d "$dir" ] && { printf '%s\n' "${dir%/}"; return 0; }
    done
    return 1
}

verify_github_asset() {
    local archive="$1"
    local repo="$2"
    local tag="$3"
    local asset="$4"
    local expected
    local actual

    expected="$(github_asset_digest "$repo" "$tag" "$asset")"
    if [ -z "$expected" ]; then
        warn "无法获取 $asset 的官方 SHA-256，跳过校验"
        return 0
    fi

    actual="$(sha256_file "$archive")"
    [ "$actual" = "$expected" ] || die "SHA-256 校验失败：$asset"
}

github_asset_is_valid() {
    local archive="$1"
    local repo="$2"
    local tag="$3"
    local asset="$4"
    local expected

    [ -s "$archive" ] || return 1
    expected="$(github_asset_digest "$repo" "$tag" "$asset")"
    [ -n "$expected" ] || return 1
    [ "$(sha256_file "$archive")" = "$expected" ]
}

verify_node_asset() {
    local archive="$1"
    local asset="$2"
    local checksums="$PLUGIN_DATA_DIR/SHASUMS256-${NODE_VERSION}.txt"
    local expected
    local actual

    if ! download "https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt" "$checksums"; then
        warn "无法获取 Node.js 官方校验文件，跳过 SHA-256 校验"
        return 0
    fi

    expected="$(awk -v file="$asset" '$2 == file { print $1; exit }' "$checksums")"
    if [ -z "$expected" ]; then
        warn "Node.js 校验文件中没有 $asset，跳过 SHA-256 校验"
        return 0
    fi

    actual="$(sha256_file "$archive")"
    [ "$actual" = "$expected" ] || die "SHA-256 校验失败：$asset"
}

detect_platform() {
    case "$(uname -s)" in
        Linux) OS="linux" ;;
        Darwin) OS="darwin" ;;
        *) die "只支持 Linux 和 macOS，当前系统：$(uname -s)" ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)
            ARCH="x86_64"
            NVIM_ARCH="x86_64"
            NODE_ARCH="x64"
            RIPGREP_TARGET="x86_64"
            FZF_ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            NVIM_ARCH="arm64"
            NODE_ARCH="arm64"
            RIPGREP_TARGET="aarch64"
            FZF_ARCH="arm64"
            ;;
        *) die "Neovim 官方预编译包不支持当前架构：$(uname -m)" ;;
    esac

    if [ "$OS" = "linux" ]; then
        NVIM_PLATFORM="linux"
        NODE_PLATFORM="linux"
        RIPGREP_TARGET="${RIPGREP_TARGET}-unknown-linux-musl"
        FZF_PLATFORM="linux"
    else
        NVIM_PLATFORM="macos"
        NODE_PLATFORM="darwin"
        RIPGREP_TARGET="${RIPGREP_TARGET}-apple-darwin"
        FZF_PLATFORM="darwin"
    fi
}

ensure_layout() {
    mkdir -p "$BIN_DIR" "$OPT_DIR" "$NVIM_CONFIG_DIR" "$NVIM_SITE_DIR" "$PLUGIN_DATA_DIR" "$PLUGGED_DIR"
    export PATH="$BIN_DIR:$PATH"
}

install_neovim() {
    local requested="${NVIM_VERSION:-$(latest_github_tag neovim/neovim)}"
    [ -n "$requested" ] || requested="$NVIM_FALLBACK_VERSION"
    requested="${requested#v}"
    requested="v$requested"

    if [ -x "$NVIM_ROOT/bin/nvim" ]; then
        local installed
        installed="$(nvim_version_of "$NVIM_ROOT/bin/nvim")"
        if version_ge "$installed" "${requested#v}" && version_ge "$installed" "$MIN_NVIM_VERSION"; then
            ln -sfn "$NVIM_ROOT/bin/nvim" "$BIN_DIR/nvim"
            log "Neovim v$installed 已安装，跳过下载"
            return
        fi
    fi

    local archive="$PLUGIN_DATA_DIR/neovim-${requested}.tar.gz"
    local temp_dir
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovimplus-nvim.XXXXXX")"
    local url="https://github.com/neovim/neovim/releases/download/${requested}/nvim-${NVIM_PLATFORM}-${NVIM_ARCH}.tar.gz"

    log "安装 Neovim ${requested}（${NVIM_PLATFORM}-${NVIM_ARCH}）"
    local asset="nvim-${NVIM_PLATFORM}-${NVIM_ARCH}.tar.gz"
    download_github "$url" "$archive"
    verify_github_asset "$archive" neovim/neovim "$requested" "$asset"
    tar -xzf "$archive" -C "$temp_dir"

    local extracted
    extracted="$(first_subdir "$temp_dir" || true)"
    [ -n "$extracted" ] && [ -x "$extracted/bin/nvim" ] || die "Neovim 压缩包结构异常：$archive"

    rm -rf "$NVIM_ROOT"
    mv "$extracted" "$NVIM_ROOT"
    ln -sfn "$NVIM_ROOT/bin/nvim" "$BIN_DIR/nvim"
    rm -rf "$temp_dir"

    local installed
    installed="$(nvim_version_of "$NVIM_ROOT/bin/nvim")"
    version_ge "$installed" "$MIN_NVIM_VERSION" \
        || die "Neovim v$installed 低于最低要求 v$MIN_NVIM_VERSION"
}

node_is_usable() {
    command -v node >/dev/null 2>&1 \
        && command -v npm >/dev/null 2>&1 \
        && version_ge "$(node --version 2>/dev/null || echo 0)" "18.0.0"
}

install_node() {
    if node_is_usable; then
        log "Node.js $(node --version) 已可用，跳过下载"
        return
    fi

    local archive="$PLUGIN_DATA_DIR/node-${NODE_VERSION}-${NODE_PLATFORM}-${NODE_ARCH}.tar.gz"
    local temp_dir
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovimplus-node.XXXXXX")"
    local url="https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-${NODE_PLATFORM}-${NODE_ARCH}.tar.gz"
    local asset="node-${NODE_VERSION}-${NODE_PLATFORM}-${NODE_ARCH}.tar.gz"

    log "安装 Node.js ${NODE_VERSION}（供 coc.nvim 使用）"
    download "$url" "$archive"
    verify_node_asset "$archive" "$asset"
    tar -xzf "$archive" -C "$temp_dir"

    local extracted
    extracted="$(first_subdir "$temp_dir" || true)"
    [ -n "$extracted" ] && [ -x "$extracted/bin/node" ] || die "Node.js 压缩包结构异常：$archive"

    rm -rf "$NODE_ROOT"
    mv "$extracted" "$NODE_ROOT"
    ln -sfn "$NODE_ROOT/bin/node" "$BIN_DIR/node"
    ln -sfn "$NODE_ROOT/bin/npm" "$BIN_DIR/npm"
    [ -x "$NODE_ROOT/bin/npx" ] && ln -sfn "$NODE_ROOT/bin/npx" "$BIN_DIR/npx"
    rm -rf "$temp_dir"

    hash -r
    node_is_usable || die "Node.js 安装后仍不可用"
}

install_ripgrep() {
    if command -v rg >/dev/null 2>&1; then
        log "ripgrep 已可用，跳过下载"
        return
    fi

    local version="${RIPGREP_VERSION#v}"
    local archive="$PLUGIN_DATA_DIR/ripgrep-${version}-${RIPGREP_TARGET}.tar.gz"
    local temp_dir
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovimplus-rg.XXXXXX")"
    local url="https://github.com/BurntSushi/ripgrep/releases/download/${version}/ripgrep-${version}-${RIPGREP_TARGET}.tar.gz"

    log "安装 ripgrep ${version}（${RIPGREP_TARGET}）"
    download_github "$url" "$archive"
    verify_github_asset "$archive" BurntSushi/ripgrep "$version" "ripgrep-${version}-${RIPGREP_TARGET}.tar.gz"
    tar -xzf "$archive" -C "$temp_dir"

    local rg_bin
    rg_bin="$(find "$temp_dir" -type f -name rg | head -n 1)"
    [ -n "$rg_bin" ] || die "ripgrep 压缩包中没有找到 rg：$archive"
    install -m 0755 "$rg_bin" "$BIN_DIR/rg"
    rm -rf "$temp_dir"
}

install_fzf() {
    if command -v fzf >/dev/null 2>&1; then
        log "fzf 已可用，跳过下载"
        return
    fi

    local version="${FZF_VERSION#v}"
    local archive="$PLUGIN_DATA_DIR/fzf-${version}-${FZF_PLATFORM}_${FZF_ARCH}.tar.gz"
    local temp_dir
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovimplus-fzf.XXXXXX")"
    local url="https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-${FZF_PLATFORM}_${FZF_ARCH}.tar.gz"

    log "安装 fzf ${version}（${FZF_PLATFORM}_${FZF_ARCH}）"
    download_github "$url" "$archive"
    verify_github_asset "$archive" junegunn/fzf "v${version}" "fzf-${version}-${FZF_PLATFORM}_${FZF_ARCH}.tar.gz"
    tar -xzf "$archive" -C "$temp_dir"
    [ -x "$temp_dir/fzf" ] || die "fzf 压缩包结构异常：$archive"
    install -m 0755 "$temp_dir/fzf" "$BIN_DIR/fzf"
    rm -rf "$temp_dir"
}

install_clangd() {
    if command -v clangd >/dev/null 2>&1; then
        log "clangd 已可用，跳过下载"
        return
    fi

    local version="${CLANGD_VERSION:-$(latest_github_tag clangd/clangd)}"
    [ -n "$version" ] || version="$CLANGD_FALLBACK_VERSION"
    version="${version#v}"

    local platform="$OS"
    [ "$platform" = "darwin" ] && platform="mac"
    local asset="clangd-${platform}-${version}.zip"
    local archive="$PLUGIN_DATA_DIR/$asset"
    local temp_dir
    temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovimplus-clangd.XXXXXX")"
    local url="https://github.com/clangd/clangd/releases/download/${version}/${asset}"

    log "安装 clangd ${version}（${platform}-${ARCH}）"
    if github_asset_is_valid "$archive" clangd/clangd "$version" "$asset"; then
        log "复用已校验的 clangd 安装包"
    else
        download_github "$url" "$archive"
        verify_github_asset "$archive" clangd/clangd "$version" "$asset"
    fi
    python3 -m zipfile -e "$archive" "$temp_dir"

    local extracted
    extracted="$(first_subdir "$temp_dir" || true)"
    [ -n "$extracted" ] && [ -f "$extracted/bin/clangd" ] \
        || die "clangd 压缩包结构异常：$archive"
    chmod +x "$extracted/bin/clangd"

    rm -rf "$OPT_DIR/clangd"
    mv "$extracted" "$OPT_DIR/clangd"
    ln -sfn "$OPT_DIR/clangd/bin/clangd" "$BIN_DIR/clangd"
    rm -rf "$temp_dir"
}

install_python_deps() {
    require_cmd python3

    local python_bin
    local scripts_dir
    local use_user_site=0
    python_bin="$(command -v python3)"

    "$python_bin" -m pip --version >/dev/null 2>&1 \
        || die "python3 缺少 pip，请安装 python3-pip 或激活包含 pip 的 Python 环境"

    if "$python_bin" -c 'import sys; raise SystemExit(sys.prefix != sys.base_prefix)' 2>/dev/null; then
        use_user_site=1
    fi

    log "安装 Python provider、debugpy 与语言工具到全局环境：$python_bin"
    if [ "$use_user_site" = 1 ]; then
        "$python_bin" -m pip install --disable-pip-version-check --upgrade --user \
            pynvim debugpy jedi-language-server cmakelang
        scripts_dir="$("$python_bin" -c 'import site; print(site.USER_BASE)')/bin"
    else
        "$python_bin" -m pip install --disable-pip-version-check --upgrade \
            pynvim debugpy jedi-language-server cmakelang
        scripts_dir="$("$python_bin" -c 'import sysconfig; print(sysconfig.get_path("scripts"))')"
    fi

    [ -x "$scripts_dir/jedi-language-server" ] \
        || die "Python 工具安装失败：$scripts_dir/jedi-language-server"
    if [ "$scripts_dir/jedi-language-server" != "$BIN_DIR/jedi-language-server" ]; then
        ln -sfn "$scripts_dir/jedi-language-server" "$BIN_DIR/jedi-language-server"
    fi
}

link_path() {
    local source="$1"
    local target="$2"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        return
    fi
    if [ -L "$target" ]; then
        rm -f "$target"
    elif [ -e "$target" ]; then
        mv "$target" "${target}.${BACKUP_SUFFIX}"
        warn "已备份 $target -> ${target}.${BACKUP_SUFFIX}"
    fi
    ln -s "$source" "$target"
}

copy_files() {
    log "链接 Neovim 配置"
    link_path "$REPO_DIR/init.vim" "$NVIM_CONFIG_DIR/init.vim"
    link_path "$REPO_DIR/coc-settings.json" "$NVIM_CONFIG_DIR/coc-settings.json"
    link_path "$REPO_DIR/init.vim.custom.plugins" "$NVIM_CONFIG_DIR/init.vim.custom.plugins"
    link_path "$REPO_DIR/init.vim.custom.config" "$NVIM_CONFIG_DIR/init.vim.custom.config"

    link_path "$REPO_DIR/colors" "$NVIM_SITE_DIR/colors"
    link_path "$REPO_DIR/ftplugin" "$NVIM_SITE_DIR/ftplugin"
    link_path "$REPO_DIR/autoload" "$NVIM_SITE_DIR/autoload"
    link_path "$REPO_DIR/lua" "$NVIM_SITE_DIR/lua"
}

install_fonts() {
    [ -d "$REPO_DIR/fonts" ] || return 0

    local font_dir
    if [ "$OS" = "darwin" ]; then
        font_dir="$HOME_DIR/Library/Fonts"
    else
        font_dir="$XDG_DATA_HOME/fonts"
    fi
    mkdir -p "$font_dir"
    cp -f "$REPO_DIR/fonts/"* "$font_dir/" 2>/dev/null || true

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$font_dir" >/dev/null 2>&1 || warn "刷新字体缓存失败，但不影响 Neovim 启动"
    fi
}

install_plugins() {
    local nvim="$NVIM_ROOT/bin/nvim"
    local mirror
    local attempt
    local missing

    github_git_probe() {
        if command -v timeout >/dev/null 2>&1; then
            GIT_TERMINAL_PROMPT=0 timeout 20 git ls-remote --heads "$1" master >/dev/null 2>&1
        else
            GIT_TERMINAL_PROMPT=0 git ls-remote --heads "$1" master >/dev/null 2>&1
        fi
    }

    if [ "$GITHUB_DIRECT" != "1" ] || ! github_git_probe https://github.com/neovim/neovim.git; then
        for mirror in $GITHUB_MIRRORS; do
            if github_git_probe "${mirror}https://github.com/neovim/neovim.git"; then
                log "GitHub 直连不可用，git 使用镜像：$mirror"
                export GIT_CONFIG_COUNT=1
                export GIT_CONFIG_KEY_0="url.${mirror}https://github.com/.insteadOf"
                export GIT_CONFIG_VALUE_0="https://github.com/"
                SELECTED_GITHUB_MIRROR="$mirror"
                break
            fi
        done
    fi

    log "安装 vim-plug 插件"
    local install_ok=0
    for attempt in 1 2 3 4 5 6 7 8; do
        install_ok=0
        if NEOVIMPLUS_INSTALLING=1 NEOVIMPLUS_PLUGINSTALL=1 "$nvim" --headless -i NONE \
            "+PlugInstall --sync" "+qa"; then
            install_ok=1
        else
            warn "第 ${attempt} 次 PlugInstall 执行失败"
        fi

        if ! missing="$(NEOVIMPLUS_INSTALLING=1 NEOVIMPLUS_PLUGINSTALL=1 "$nvim" --headless -i NONE \
            "+lua for name, spec in pairs(vim.g.plugs) do if vim.fn.isdirectory(spec.dir) == 0 then print('MISSING=' .. name) end end" \
            "+qa!" 2>&1 | sed -n 's/^MISSING=//p' | sort -u)"; then
            warn "第 ${attempt} 次插件状态检查失败"
            install_ok=0
            missing=""
        fi

        if [ "$install_ok" = 1 ] && [ -z "$missing" ]; then
            break
        fi
        warn "第 ${attempt} 次插件安装仍有问题${missing:+，缺失：$(echo "$missing" | tr '\n' ' ')}"
    done
    if [ "$install_ok" != 1 ] || [ -n "$missing" ]; then
        die "插件安装失败${missing:+：$(echo "$missing" | tr '\n' ' ')}"
    fi

    local treesitter_dir="$PLUGGED_DIR/nvim-treesitter"
    if [ -d "$treesitter_dir/.git" ] \
        && [ "$(git -C "$treesitter_dir" branch --show-current)" != "master" ]; then
        log "将 nvim-treesitter 切换回兼容的 master 分支"
        git -C "$treesitter_dir" fetch --depth=1 origin master
        git -C "$treesitter_dir" checkout -B master FETCH_HEAD
    fi

    log "安装 C/C++ 与 Python 语言服务"
    NEOVIMPLUS_INSTALLING=1 "$nvim" --headless -i NONE \
        "+CocInstall -sync coc-clangd coc-pyright coc-cmake coc-json" "+qa"

    local extension
    for extension in coc-clangd coc-pyright coc-cmake coc-json; do
        [ -d "$XDG_CONFIG_HOME/coc/extensions/node_modules/$extension" ] \
            || die "coc 扩展安装失败：$extension"
    done

    install_treesitter_parsers
}

create_github_curl_wrapper() {
    local wrapper_dir="$1"
    local real_curl
    real_curl="$(command -v curl)"

    mkdir -p "$wrapper_dir"
    cat > "$wrapper_dir/curl" <<EOF
#!/usr/bin/env bash
args=()
for arg in "\$@"; do
    case "\$arg" in
        https://github.com/*) arg="\${GITHUB_MIRROR}\$arg" ;;
    esac
    args+=("\$arg")
done
exec "$real_curl" "\${args[@]}"
EOF
    chmod +x "$wrapper_dir/curl"
}

install_treesitter_parsers() {
    local nvim="$NVIM_ROOT/bin/nvim"
    local wrapper_dir=""
    local parser_dir="$PLUGGED_DIR/nvim-treesitter/parser"
    local site_parser_dir="$XDG_DATA_HOME/nvim/site/parser"
    local language
    local missing_languages=""

    if ! command -v cc >/dev/null 2>&1; then
        warn "缺少 C 编译器 cc，跳过 Treesitter parser 编译；语法高亮仍可使用 Vim 语法"
        return 0
    fi
    if [ ! -d "$PLUGGED_DIR/nvim-treesitter" ]; then
        warn "nvim-treesitter 未安装，跳过 parser 编译"
        return 0
    fi

    for language in cpp python vim lua; do
        if [ ! -f "$parser_dir/$language.so" ] && [ ! -f "$site_parser_dir/$language.so" ]; then
            missing_languages="$missing_languages $language"
        fi
    done
    if [ -z "$missing_languages" ]; then
        log "Treesitter parser 已安装，跳过编译"
        return 0
    fi

    log "编译 Treesitter parser：$missing_languages"
    if [ -n "$SELECTED_GITHUB_MIRROR" ]; then
        wrapper_dir="$(mktemp -d "${TMPDIR:-/tmp}/neovimplus-curl.XXXXXX")"
        create_github_curl_wrapper "$wrapper_dir"
        GITHUB_MIRROR="$SELECTED_GITHUB_MIRROR" PATH="$wrapper_dir:$PATH" \
            NEOVIMPLUS_INSTALLING=1 "$nvim" --headless -i NONE \
            "+TSInstallSync!$missing_languages" "+qa"
        rm -rf "$wrapper_dir"
    else
        NEOVIMPLUS_INSTALLING=1 "$nvim" --headless -i NONE \
            "+TSInstallSync!$missing_languages" "+qa"
    fi
}

add_shell_path() {
    local marker="# neovimplus: add local binaries to PATH"
    local rc
    local updated=0
    for rc in "$HOME_DIR/.profile" "$HOME_DIR/.bashrc" "$HOME_DIR/.bash_profile" "$HOME_DIR/.zshrc"; do
        if [ ! -f "$rc" ] && [ "$rc" != "$HOME_DIR/.profile" ]; then
            continue
        fi
        touch "$rc"
        if ! grep -Fq "$marker" "$rc"; then
            printf '\n%s\nexport PATH="%s:$PATH"\n' "$marker" "$BIN_DIR" >> "$rc"
        fi
        updated=1
    done

    [ "$updated" = 1 ] || warn "无法写入 shell PATH 配置，请手动把 $BIN_DIR 加入 PATH"
}

main() {
    detect_platform
    ensure_layout

    require_cmd curl
    require_cmd tar
    require_cmd git

    install_neovim
    install_node
    install_ripgrep
    install_fzf
    install_python_deps
    if [ "${INSTALL_CLANGD:-1}" = "1" ]; then
        install_clangd
    else
        log "已跳过 clangd 安装（INSTALL_CLANGD=0）"
    fi
    copy_files
    install_fonts
    install_plugins
    add_shell_path

    log "安装完成"
    printf '  Neovim : %s (%s)\n' "$("$NVIM_ROOT/bin/nvim" --version | head -n 1)" "$BIN_DIR/nvim"
    printf '  Node   : %s\n' "$(node --version)"
    printf '  rg/fzf : %s / %s\n' "$(rg --version | head -n 1)" "$(fzf --version)"
    printf '\n如果没有立即生效，请重新登录 shell，或执行：\n  export PATH="%s:$PATH"\n' "$BIN_DIR"
}

main "$@"
