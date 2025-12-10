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
