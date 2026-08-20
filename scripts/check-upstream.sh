#!/usr/bin/env bash
#
# check-upstream.sh
# 本地 pi 的 GitHub 项目定时监控：每天 09:30 由 launchd 调用，
# 检查 DeepSeek Harness 官方仓库是否有更新。
#
# 流程：
#   1) 获取官方仓库最新 HEAD，与本地钉死的快照比较。
#   2) 无更新 -> 仅写日志，保持安静。
#   3) 有更新 -> 调用本地 pi(headless) 分析官方最近提交，
#      给出文档更新建议，并弹 macOS 通知。
#
# 职责边界：本脚本只做检测、分析和提醒，不自动改写文档。
# 技术文档需要人工核对（命令、包名、ctx key、事件都要对官方源码复核），
# 收到通知后按 docs/08 与 docs/SOURCES 的维护流程人工更新，再把新的
# 钉死 commit 填到下方 PINNED_COMMIT。
#
# 手动执行：bash scripts/check-upstream.sh

set -u

# launchd 环境 PATH 很窄，homebrew 的 git 在 /opt/homebrew/bin
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# ==== 配置区 ====
UPSTREAM_URL="https://github.com/deepseek-ai/deepseek-harness.git"
# 文档当前钉死的官方快照（2026-08-20 核对，09 章记录本轮变化）。
# 人工更新文档后，把新 commit 填到这里。
PINNED_COMMIT="141eb6fef83422698aef7a981029e843e8161534"
LOG_DIR="$HOME/Library/Logs/dsh-update-check"
LOG_FILE="$LOG_DIR/check.log"
STATUS_FILE="$LOG_DIR/last-status.txt"
PI="$HOME/.npm-global/bin/pi"
JQ="/usr/bin/jq"

mkdir -p "$LOG_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"; }

log "===== 开始检查 ====="

# 网络超时保护：低速或挂起 15 秒视为失败
export GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=15

UPSTREAM_HEAD="$(git ls-remote "$UPSTREAM_URL" HEAD 2>>"$LOG_FILE" | awk '{print $1}')"

if [ -z "$UPSTREAM_HEAD" ]; then
    log "获取官方 HEAD 失败（网络或仓库异常），本次跳过"
    echo "error" > "$STATUS_FILE"
    log "===== 结束 ====="
    exit 0
fi

log "官方 HEAD : $UPSTREAM_HEAD"
log "钉死快照 : $PINNED_COMMIT"

if [ "$UPSTREAM_HEAD" = "$PINNED_COMMIT" ]; then
    log "无更新：官方与钉死快照一致"
    echo "ok" > "$STATUS_FILE"
    log "===== 结束 ====="
    exit 0
fi

# ===== 官方有更新 =====
log ">>> 官方仓库有更新（HEAD $UPSTREAM_HEAD 与钉死快照不一致） <<<"
echo "updated" > "$STATUS_FILE"

# 拉取官方最近提交摘要（辅助信息，失败不影响检测结果）
SUMMARY="$(curl -s --max-time 10 "https://api.github.com/repos/deepseek-ai/deepseek-harness/commits?per_page=8" \
    | "$JQ" -r '.[] | .sha[0:7] + "  " + (.commit.message | split("\n")[0])' 2>/dev/null)"
if [ -n "$SUMMARY" ]; then
    log "官方最近提交："
    log "$SUMMARY"
fi

# 用本地 pi(headless) 分析更新并给出文档更新建议
ANALYSIS=""
if [ -x "$PI" ]; then
    PROMPT="DeepSeek Harness 官方仓库有更新：本地文档钉死快照 141eb6f，官方最新 HEAD ${UPSTREAM_HEAD:0:7}。最近提交：$(echo "$SUMMARY" | head -4 | tr '\n' '|')。请用中文简洁回答：1) 这次更新涉及哪些模块或改动重点；2) 对 ~/github/DeepSeekHarness_Whitepages 这份技术白皮书，哪几章需要核对更新。200 字以内。"
    log "调用本地 pi 分析..."
    ANALYSIS="$("$PI" -p "$PROMPT" 2>>"$LOG_FILE" | tail -40)"
    log "pi 分析结果："
    log "$ANALYSIS"
fi

# macOS 通知（取分析结果第一行做摘要）
FIRST_LINE="$(echo "$ANALYSIS" | grep -v '^[[:space:]]*$' | head -1)"
NOTIFY_BODY="官方仓库有更新（141eb6f -> ${UPSTREAM_HEAD:0:7}）"
[ -n "$FIRST_LINE" ] && NOTIFY_BODY="$NOTIFY_BODY。${FIRST_LINE}"
osascript -e "display notification \"$NOTIFY_BODY\" with title \"DeepSeek Harness 更新检查\" sound name \"Glass\"" >>"$LOG_FILE" 2>&1

log "===== 结束 ====="
