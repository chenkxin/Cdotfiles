PORT=7890
SOCKET_PORT=7891

# 测试能否成功访问
function _access_url() {
	start=$SECONDS
	result=$(curl -m 2 -I --silent $1 | head -n 1 | awk -F' ' '{print $2}')
	result=${result:-None}
	dur=$((SECONDS - start))

	if [ $result = "200" ]; then
		printf "[%.2f s] %-6s:200 OK✅\n" $dur $1
		return 0
	else
		printf "[%.2f s] %-6s:${result}🚫\n" $dur $1
		return 1
	fi
}

# 设置代理是否开放
proxy () {
	if [ "$1" = "on" ]; then
		export http_proxy=http://127.0.0.1:$PORT
		export HTTP_PROXY=http://127.0.0.1:$PORT
		export https_proxy=http://127.0.0.1:$PORT
		export HTTPS_PROXY=http://127.0.0.1:$PORT
		export all_proxy=socks5h://127.0.0.1:$SOCKET_PORT
		export ALL_PROXY=socks5h://127.0.0.1:$SOCKET_PORT
	elif [ "$1" = "off" ]; then
		export http_proxy=""
		export https_proxy=""
		export HTTP_PROXY=""
		export HTTPS_PROXY=""
		export all_proxy=""
		export ALL_PROXY=""
	elif [ "$1" = "test" ]; then
        # 测试国内外网络
        echo testing baidu...
        _access_url https://www.baidu.com/
        echo testing google...
        _access_url https://www.google.com/
        echo testing github...
        _access_url https://github.com/
	elif [ "$1" = "info" ]; then
        echo http_proxy: $http_proxy
        echo HTTP_PROXY: $HTTP_PROXY
        echo https_proxy: $https_proxy
        echo HTTPS_PROXY: $HTTPS_PROXY
        echo all_proxy: $all_proxy
        echo ALL_PROXY: $ALL_PROXY
        ps -aux | grep clash
	elif [ "$1" = "up" ]; then
        clash
	elif [ "$1" = "down" ]; then
        pkill -9 clash
	elif [ "$1" = "giton" ]; then
        git config --global http.https://github.com.proxy socks5h://127.0.0.1:$SOCKET_PORT
        git config --global https.https://github.com.proxy socks5h://127.0.0.1:$SOCKET_PORT
		cat >> $HOME/.ssh/config <<EOF
Host github.com
	Hostname ssh.github.com
	Port 443
	User git
	ProxyCommand nc -v -x  127.0.0.1:7891 %h %p

EOF
	elif [ "$1" = "gitoff" ]; then
        git config --global --unset http.https://github.com.proxy
        git config --global --unset https.https://github.com.proxy
        sed -i '/github/,+5d' $HOME/.ssh/config
	fi
}

alias ptest="proxy test"
alias pon="proxy on"
alias poff="proxy off"
alias pinfo="proxy info"
alias pup="proxy up"
alias pdown="proxy down"
alias pgon="proxy giton"
alias pgoff="proxy gitoff"

