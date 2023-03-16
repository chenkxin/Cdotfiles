#/bin/zsh

# 获取指定代理组信息
get_proxy_group () {
	param1=$1
	param2=$2
	url=${param1:-"http://127.0.0.1:9090"}
	proxy_group=${param2:-"🔰国外流量"}
	curl -X GET -H "Content-Type: application/json" "$url/proxies/$proxy_group"
}

# 获取当前节点名字
get_current_node () {
    get_proxy_group | jq -r '.now'
}
