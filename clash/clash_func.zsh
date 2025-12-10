
#!/bin/bash
# Clash 节点状态与切换脚本
# 自动获取当前节点和可选节点，并可一键切换

API_URL=${1:-"http://127.0.0.1:9090"}
GROUP_NAME=${2:-"🚀 节点选择"}

# 获取指定代理组的完整信息
get_proxy_group() {
  curl -s -H "Content-Type: application/json" "$API_URL/proxies/$(printf %s "$GROUP_NAME" | jq -sRr @uri)"
}

# 获取当前节点名
get_current_node() {
  get_proxy_group | jq -r '.now'
}

# 获取所有可选节点
list_all_nodes() {
  get_proxy_group | jq -r '.all[]'
}

# 切换节点
set_current_node() {
  local name="$1"
  [[ -z "$name" ]] && { echo "❌ 请输入节点名称"; exit 1; }

  data=$(jq -n --arg name "$name" '{ name: $name }')
  curl -s -X PUT -H "Content-Type: application/json" -d "$data" \
    "$API_URL/proxies/$(printf %s "$GROUP_NAME" | jq -sRr @uri)" | jq .
}

# 主控制逻辑
case "$3" in
  current)
    echo "当前节点：$(get_current_node)"
    ;;
  list)
    echo "可选节点："
    list_all_nodes
    ;;
  set)
    shift 3
    set_current_node "$@"
    ;;
  *)
    echo "用法：$0 [API_URL] [GROUP_NAME] {current|list|set <节点名>}"
    echo "示例：$0 http://127.0.0.1:9090 '🚀 节点选择' current"
    echo "示例：$0 http://127.0.0.1:9090 '🚀 节点选择' set '香港专线BGP8[M][Trojan]'"
    ;;
esac

