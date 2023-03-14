#/bin/zsh
set -ex

# 下载解压 clash 文件
[ ! -d build ] && mkdir build
cd build
file="clash-linux-amd64-v3-v1.13.0"
url=https://github.com/Dreamacro/clash/releases/download/v1.13.0/$file.gz
[ ! -f $file ] && wget $url && gzip -d $file.gz
chmod u+x $file

# 安装 clash，设置环境变量和软链接
LOCAL_BIN="$HOME/.local/bin"
[ ! -d $LOCAL_BIN ] && mkdir -p "$LOCAL_BIN"
export PATH=$LOCAL_BIN:$PATH
cp $file ~/.local/bin/
ln -s ~/.local/bin/$file ~/.local/bin/clash

# 删除临时文件夹
cd ..
rm -rf build
