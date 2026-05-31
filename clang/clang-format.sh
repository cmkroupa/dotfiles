#!/usr/bin/env bash

if ! command -v clang-format &> /dev/null; then
    echo "[SKIP] clang-format not found"
    exit 0
fi

if ! command -v git-clang-format &> /dev/null; then
    echo "[SKIP] git-clang-format not found"
    exit 0
fi

REPO_ROOT=$(git rev-parse --show-toplevel)

if [ ! -f "$REPO_ROOT/tools/git_hooks/.clang-format" ]; then
    echo "[SKIP] .clang-format not found in tools/git_hooks/"
    exit 0
fi

git clang-format --diff --style="file:$REPO_ROOT/tools/git_hooks/.clang-format" HEAD

# Re-stage any files that were reformatted
git add -u

exit 0
