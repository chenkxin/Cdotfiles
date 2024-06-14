#/bin/zsh

# 获取指定代理组信息
get_proxy_group () {
	param1=$1
	param2=$2
	url=${param1:-"http://127.0.0.1:9090"}
	proxy_group=${param2:-"国外媒体"}
	curl -X GET -H "Content-Type: application/json" "$url/proxies/${proxy_group}"
}

# 获取当前节点名字
get_current_node () {
    get_proxy_group | jq -r '.now'
}

# 切换节点
set_current_node () {
    param1=$1
    param2=$2
    param3=$3
    current_name=`get_current_node`
    node_name=${param1:-"$current_name"}
    url=${param2:-"http://127.0.0.1:9090"}
    proxy_group=${param3:-'国外媒体'}
    curl -X PUT -H "Content-Type: application/json" -d "{\"name\": \"$node_name\"}" $url/proxies/$proxy_group
}

alias gnode="get_current_node"
alias snode="set_current_node"
