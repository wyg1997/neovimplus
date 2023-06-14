#!/bin/bash

set -e

# 获取当前分支名称
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 拉取上游代码并获取更新列表
git fetch
update_list=$(git rev-list --abbrev-commit --no-merges HEAD..origin/$current_branch)

# 检查是否有更新可用
if [ -z "$update_list" ]; then
  echo "当前分支 '$current_branch' 没有可用的更新。"
  exit 0
fi

# 获取合并前的最新提交
previous_head=$(git rev-parse HEAD)

# 更新到远程分支版本
git merge origin/$current_branch

# 获取合并后的最新提交
current_head=$(git rev-parse HEAD)

# 打印中间的所有 commit 改动
echo "以下是本次更新的 commit 改动："
while read -r commit_hash; do
  git --no-pager show --stat --oneline --abbrev-commit $commit_hash || { echo "无法打印 commit $commit_hash 的改动信息。"; exit 1; }
done <<< "$update_list"

# 在 Neovim 中执行 PlugInstall
nvim -c "PlugInstall|qall" || { echo "在 Neovim 中执行插件安装操作时发生错误。"; exit 1; }

echo "更新完成。"
