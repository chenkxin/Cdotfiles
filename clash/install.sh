#/bin/bash
set -ex

# 下载解压 clash 文件
# !!!!!!!!!!!!!!
# 由于原仓库失效，取消从原仓库下载
#[ ! -d build ] && mkdir build
#cd build
#file="clash-linux-amd64-v3-v1.13.0"
#url=https://github.com/Dreamacro/clash/releases/download/v1.13.0/$file.gz
#[ ! -f $file ] && wget -c $url && gzip -d $file.gz
#chmod u+x $file

dir=$(cd $(dirname $0);pwd)

# 安装 clash，设置环境变量和软链接
file="clash-linux-amd64"
src="${dir}/build/${file}"
LOCAL_BIN_DIR="$HOME/.local/bin"
[ ! -d $LOCAL_BIN_DIR ] && mkdir -p $LOCAL_BIN_DIR
cp $src $LOCAL_BIN_DIR
ln -s ${LOCAL_BIN_DIR}/${file} ${LOCAL_BIN_DIR}/clash

# Country.mmdb
file2="${dir}/build/Country.mmdb"
CLASH_CONF_DIR="$HOME/.config/clash"
[ ! -d $CLASH_CONF_DIR ] && mkdir -p $CLASH_CONF_DIR
cp $file2 $HOME/.config/clash/
