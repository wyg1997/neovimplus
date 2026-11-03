#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_PREFIX="${NEOVIMPLUS_PREFIX:-${HOME}/.local}"
NVIM="${NVIM:-${LOCAL_PREFIX}/bin/nvim}"

cd "$REPO_DIR"
command -v "$NVIM" >/dev/null 2>&1 || "$REPO_DIR/install.sh"

current_branch="$(git rev-parse --abbrev-ref HEAD)"
git fetch
update_list="$(git rev-list --abbrev-commit --no-merges "HEAD..origin/$current_branch")"

if [ -z "$update_list" ]; then
    echo "当前分支 '$current_branch' 没有可用的更新。"
else
    previous_head="$(git rev-parse HEAD)"
    git merge "origin/$current_branch"
    current_head="$(git rev-parse HEAD)"

    if [ "$previous_head" != "$current_head" ]; then
        echo "以下是本次更新的 commit 改动："
        while read -r commit_hash; do
            git --no-pager show --stat --oneline --abbrev-commit "$commit_hash"
        done <<< "$update_list"
    fi
fi

# 同步脚本自身与最新配置；安装脚本是幂等的。
"$REPO_DIR/install.sh"
