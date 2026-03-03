#!/bin/bash
# 调用 Codex CLI 进行内容填充
# 用法: call-codex.sh <prompt_file> [output_file]

set -e

PROMPT_FILE="$1"
OUTPUT_FILE="${2:-/dev/stdout}"

if [ -z "$PROMPT_FILE" ] || [ ! -f "$PROMPT_FILE" ]; then
    echo "错误: 请提供有效的 prompt 文件路径" >&2
    exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")

# 使用 codex exec 非交互模式执行
# 注意：codex exec 可能需要较长时间，建议设置足够的超时
codex exec "$PROMPT" 2>&1 | tee "$OUTPUT_FILE"
