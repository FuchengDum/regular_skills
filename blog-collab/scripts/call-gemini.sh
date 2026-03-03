#!/bin/bash
# 调用 Gemini CLI 进行技术审核
# 用法: call-gemini.sh <prompt_file> [output_file]

set -e

PROMPT_FILE="$1"
OUTPUT_FILE="${2:-/dev/stdout}"

if [ -z "$PROMPT_FILE" ] || [ ! -f "$PROMPT_FILE" ]; then
    echo "错误: 请提供有效的 prompt 文件路径" >&2
    exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")

# 使用 gemini -p 非交互模式执行
gemini -p "$PROMPT" -o text 2>&1 | tee "$OUTPUT_FILE"
