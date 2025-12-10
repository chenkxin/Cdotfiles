
#!/bin/bash
# ===============================================================
# 🚀  ClashCtl 工具套件
# ===============================================================

set -e
set -o pipefail

DOTFILES=${DOTFILES:-${1:-$HOME/.local/.dotfiles}}
INSTALL_DIR="$DOTFILES/clash"
BIN_DIR="$HOME/.local/bin"
CONF_DIR="$HOME/.config/clash"
LOG_DIR="$CONF_DIR/logs"

mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$LOG_DIR"
info(){ echo "[✅] $*"; }

# ---------- clashctl (仅保留日志 + Git 控制功能) ----------
install_clashctl() {
  cat >"$INSTALL_DIR/clashctl.sh" <<"EOF"
#!/bin/bash
CLASH_HOME="$HOME/.config/clash"
LOG_DIR="$CLASH_HOME/logs"
LOG_FILE="$LOG_DIR/clashctl.log"
MODE_FILE="$CLASH_HOME/gitproxy.mode"
PROXY_URL="http://127.0.0.1:7890"
mkdir -p "$LOG_DIR"; [ -f "$MODE_FILE" ] || echo "auto" >"$MODE_FILE"

ts(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ echo "[$(ts)] $*" | tee -a "$LOG_FILE"; }

case "$1" in
 git)
   case "$2" in
     proxy)
       case "$3" in
         on) git config --global http.proxy "$PROXY_URL"; git config --global https.proxy "$PROXY_URL"; echo manual >"$MODE_FILE"; log "Git代理手动开启";;
         off) git config --global --unset http.proxy; git config --global --unset https.proxy; echo manual >"$MODE_FILE"; log "Git代理手动关闭";;
         auto) echo auto >"$MODE_FILE"; log "Git模式设为auto";;
         reset) for s in http https; do git config --global --remove-section "$s" 2>/dev/null || true; done; echo auto >"$MODE_FILE"; log "Git代理配置清空auto";;
         *) echo "Usage: clashctl git proxy {on|off|auto|reset}";;
       esac;;
     *) echo "Usage: clashctl git proxy {on|off|auto|reset}";;
   esac;;
 *) echo "Usage: clashctl git proxy {on|off|auto|reset}";;
esac
EOF
  chmod +x "$INSTALL_DIR/clashctl.sh"
  ln -sf "$INSTALL_DIR/clashctl.sh" "$BIN_DIR/clashctl"
}

# ---------- quickgit ----------
install_quickgit() {
  cat >"$BIN_DIR/quickgit" <<"EOF"
#!/bin/bash
CLASH_HOME="$HOME/.config/clash"
LOG_DIR="$CLASH_HOME/logs"
LOG_FILE="$LOG_DIR/quickgit.log"
MODE_FILE="$CLASH_HOME/gitproxy.mode"
PROXY_URL="http://127.0.0.1:7890"
mkdir -p "$LOG_DIR"

ts(){ date '+%Y-%m-%d %H:%M:%S'; }
log(){ echo "[$(ts)] $*" | tee -a "$LOG_FILE"; }

VERBOSE=false; DRYRUN=false
for arg in "$@"; do case "$arg" in --verbose) VERBOSE=true;; --dry-run) DRYRUN=true;; esac; done
clean_args=(); for arg in "$@"; do [[ "$arg" == "--verbose" || "$arg" == "--dry-run" ]] || clean_args+=("$arg"); done
mode=$(cat "$MODE_FILE" 2>/dev/null || echo auto)
sys_proxy="OFF"; [[ -n "$http_proxy" || -n "$https_proxy" ]] && sys_proxy="ON"

if [[ "$mode" == auto ]]; then
  if [[ "$sys_proxy" == "ON" ]]; then git config --global http.proxy "$PROXY_URL"; git config --global https.proxy "$PROXY_URL"; msg="自动同步 Git proxy (启用)"
  else git config --global --unset http.proxy; git config --global --unset https.proxy; msg="自动关闭 Git proxy"; fi
else msg="手动模式，跳过修改"; fi

log "🧠 模式:$mode | 系统代理:$sys_proxy"
log "🌐 $msg"
if $VERBOSE; then
  log "🔍 http_proxy=${http_proxy:-未设置}"
  log "🔍 https_proxy=${https_proxy:-未设置}"
fi
if $DRYRUN; then log "🧪 (dry-run) 不执行 git ${clean_args[*]}"; exit 0; fi
log "🚀 执行: git ${clean_args[*]}"
git "${clean_args[@]}"
EOF
  chmod +x "$BIN_DIR/quickgit"
}

# ---------- clog ----------
install_clog() {
  cat >"$BIN_DIR/clog" <<"EOF"
#!/bin/bash
LOG_DIR="$HOME/.config/clash/logs"
CLOG="$LOG_DIR/clashctl.log"
QLOG="$LOG_DIR/quickgit.log"
MLOG="$LOG_DIR/maintenance.log"

if [[ "$1" == "--summary" ]]; then
  echo "📊 ClashCtl / QuickGit 日志概要"
  echo "──────────────────────────────"
  for f in "$CLOG" "$QLOG"; do
    [[ -f "$f" ]] || continue
    name=$(basename "$f")
    count=$(wc -l < "$f")
    mod=$(date -r "$f" '+%Y-%m-%d %H:%M')
    printf "🪵 %-12s — %4s 行，更新于 %s\n" "$name" "$count" "$mod"
  done
  echo
  if [[ -f "$MLOG" ]]; then
    last=$(tail -n 1 "$MLOG" | cut -d']' -f1 | tr -d '[')
    echo "⏰ 最近定时清理: ${last:-未知}"
  fi
  exit 0
fi

tail -n 30 "$CLOG" "$QLOG"
EOF
  chmod +x "$BIN_DIR/clog"
}

# ---------- clclear ----------
install_clclear() {
  cat >"$BIN_DIR/clclear" <<"EOF"
#!/bin/bash
LOG_ROOT="$HOME/.config/clash/logs"
ARCHIVE="$LOG_ROOT/archive/$(date +%Y-%m-%d)"
mkdir -p "$ARCHIVE"
echo "🧹 归档路径: $ARCHIVE"
for f in "$LOG_ROOT"/*.log; do [[ -f "$f" ]] || continue; mv "$f" "$ARCHIVE/$(basename "$f")"; echo "📦 归档: $(basename "$f")"; done
echo "✅ 清理完成"
EOF
  chmod +x "$BIN_DIR/clclear"
}

# ---------- 定时任务 ----------
setup_cron() {
  (crontab -l 2>/dev/null | grep -v "clclear" || true; echo "0 3 * * 1 $BIN_DIR/clclear >> $LOG_DIR/maintenance.log 2>&1") | crontab -
  info "⏰ 每周一凌晨 03:00 自动执行 clclear"
}

# ---------- 智能 alias ----------
install_aliases() {
  for rc in ~/.zshrc ~/.bashrc; do
    [ -f "$rc" ] || continue
    mapfile -t SMART <<'AL'
# 🧠 实时生效系统代理控制
alias cpon='export http_proxy="http://127.0.0.1:7890" https_proxy="http://127.0.0.1:7890" all_proxy="socks5h://127.0.0.1:7891"; echo "✅ 系统代理已开启";'
alias cpoff='unset http_proxy https_proxy all_proxy; echo "🛑 系统代理已关闭";'

# Git 代理控制
alias cgauto="clashctl git proxy auto"
alias cgon="clashctl git proxy on"
alias cgoff="clashctl git proxy off"
alias cgreset="clashctl git proxy reset"

# 一键控制
alias cpall="cpon && cgon"
alias cpoffall="cpoff && cgoff"

# 日志工具
alias clsummary="clog --summary"
alias clwatch="clog -f quickgit"
alias clflush="clclear && clog --summary"

# 状态与测试
alias cpstat='echo "🌐 当前系统代理状态:"; [[ -n "$http_proxy" ]] && echo "  • http_proxy=$http_proxy" || echo "  × http_proxy 未设置"; [[ -n "$https_proxy" ]] && echo "  • https_proxy=$https_proxy" || echo "  × https_proxy 未设置"; [[ -n "$all_proxy" ]] && echo "  • all_proxy=$all_proxy" || echo "  × all_proxy 未设置";'
alias cgstat='echo "🧰 当前 Git 全局代理配置:"; git config --global --get http.proxy 2>/dev/null || echo "  × HTTP proxy 未配置"; git config --global --get https.proxy 2>/dev/null || echo "  × HTTPS proxy 未配置";'
alias cptest='echo "🚀 测试代理连通性:"; targets=("https://www.google.com" "https://github.com" "https://ipinfo.io"); for url in "${targets[@]}"; do echo -n "  → $url ... "; if curl -I -m 5 -s "$url" >/dev/null 2>&1; then echo "✅ 通"; else echo "❌ 不通"; fi; done; echo; echo "🌍 出口 IP:"; curl -s --max-time 5 https://ipinfo.io/ip || echo "⚠️ 无法获取出口 IP";'

# Clash 进程管理
alias cpup='if pgrep -x "clash" >/dev/null; then echo "⚡ Clash 已运行"; else (nohup clash > ~/.config/clash/logs/clash-run.log 2>&1 &); echo "🚀 Clash 已启动"; fi'
alias cpdown='if pkill -x clash >/dev/null 2>&1; then echo "🛑 Clash 已关闭"; else echo "⚠️ Clash 未在运行"; fi'

# 全局 alias 一览
alias cla='
echo "
🧩 ClashCtl 工具集 alias 一览
───────────────────────────────────────
  cpon / cpoff        ➜ 开关系统代理（立即生效）
  cgon / cgoff        ➜ 手动开关 Git 代理
  cgauto / cgreset    ➜ Git 代理自动 / 清空
───────────────────────────────────────
  cpall / cpoffall    ➜ 一键系统 + Git 代理开关
  cpstat / cgstat     ➜ 查看代理状态
  cptest              ➜ 测试网络连通性 / 出口 IP
───────────────────────────────────────
  cpup / cpdown       ➜ 启动 / 停止 Clash 后台进程
───────────────────────────────────────
  clsummary / clwatch / clflush ➜ 日志查询与清理
───────────────────────────────────────
  clog / clclear      ➜ 日志操作
  cla                 ➜ 查看此帮助菜单
───────────────────────────────────────
"
'
AL
    for a in "${SMART[@]}"; do grep -qxF "$a" "$rc" || echo "$a" >>"$rc"; done
  done
}

# ---------- 主程序 ----------
info "🚀 安装 ClashCtl 工具集，dotfiles 目录：$DOTFILES"
install_clashctl
install_quickgit
install_clog
install_clclear
install_aliases
setup_cron
info "✅ 安装完成！执行 source ~/.zshrc 启用所有 alias。"
echo -e "\n📂 安装目录: $INSTALL_DIR\n🪵 日志目录: $LOG_DIR\n💡 输入 cla 查看所有命令与说明\n"
