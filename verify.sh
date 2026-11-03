#!/usr/bin/env bash
set -Eeuo pipefail

LOCAL_PREFIX="${NEOVIMPLUS_PREFIX:-${HOME}/.local}"
NVIM="${NVIM:-${LOCAL_PREFIX}/bin/nvim}"
export PATH="${LOCAL_PREFIX}/bin:${LOCAL_PREFIX}/opt/node/bin:${PATH}"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/neovimplus-check.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

if ! [ -x "$NVIM" ]; then
    NVIM="$(command -v nvim || true)"
fi
[ -n "$NVIM" ] && [ -x "$NVIM" ] || { echo "未找到 Neovim，请先运行 ./install.sh" >&2; exit 1; }

cat > "$TMP_DIR/sample.cpp" <<'CPP'
#include <iostream>

int main() {
    std::cout << "Hello from C++\n";
    return 0;
}
CPP

cat > "$TMP_DIR/sample.py" <<'PY'
def main() -> None:
    print("Hello from Python")


if __name__ == "__main__":
    main()
PY

run_check() {
    local file="$1"
    local expected="$2"
    local log="$TMP_DIR/$(basename "$file").log"

    if ! "$NVIM" --headless -i NONE "$file" \
        "+lua print('FILE_TYPE=' .. vim.bo.filetype)" \
        "+lua print('SYNTAX=' .. tostring(vim.bo.syntax))" \
        "+lua local ok, err = pcall(vim.treesitter.language.add, '$expected'); print('TS=' .. tostring(ok)); if not ok then print(err) end" \
        "+qa!" >"$log" 2>&1; then
        cat "$log" >&2
        return 1
    fi

    if ! grep -q "FILE_TYPE=$expected" "$log"; then
        echo "无法正确识别 $file 的文件类型（期望 $expected）" >&2
        cat "$log" >&2
        return 1
    fi

    if ! grep -q '^TS=true$' "$log"; then
        echo "$file 的 Treesitter parser 未安装或无法加载" >&2
        cat "$log" >&2
        return 1
    fi

    if grep -Eq '(^|[^A-Za-z])(E[0-9]{3,4}:|Error|error:)' "$log"; then
        echo "加载 $file 时检测到 Neovim 错误：" >&2
        cat "$log" >&2
        return 1
    fi

    echo "OK  $(basename "$file")  filetype=$expected"
}

echo "Neovim: $($NVIM --version | head -n 1)"

startup_log="$TMP_DIR/startup.log"
if ! "$NVIM" --headless -i NONE '+messages' '+qa!' >"$startup_log" 2>&1; then
    echo "Neovim 启动失败：" >&2
    cat "$startup_log" >&2
    exit 1
fi
if [ -s "$startup_log" ]; then
    echo "Neovim 启动时产生了消息或错误：" >&2
    cat "$startup_log" >&2
    exit 1
fi

run_check "$TMP_DIR/sample.cpp" cpp
run_check "$TMP_DIR/sample.py" python

for cmd in node npm rg fzf jedi-language-server; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "缺少运行时依赖：$cmd" >&2; exit 1; }
done

if command -v clangd >/dev/null 2>&1; then
    echo "OK  $(clangd --version 2>/dev/null | head -n 1)"
else
    echo "warning: 未找到 clangd，C++ 补全不可用" >&2
fi

python_host="$("$NVIM" --headless -i NONE '+lua io.write(vim.g.python3_host_prog or "")' '+qa!' 2>/dev/null)"
if [ -n "$python_host" ] && [ -x "$python_host" ]; then
    "$python_host" -c 'import pynvim, debugpy' >/dev/null 2>&1 \
        || { echo "Python provider 依赖不可用：$python_host" >&2; exit 1; }
    echo "OK  Python provider: $python_host"
else
    echo "warning: 未配置可执行的 python3_host_prog" >&2
fi

echo "OK  用户态运行时依赖齐全"
