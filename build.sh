#!/bin/sh
# 打包成 koolshare 软件中心可用的离线安装包
set -e
cd "$(dirname "$0")"

VER=$(sed -n 's/^VER="\(.*\)"$/\1/p' v6stat/install.sh)
mkdir -p dist
rm -f dist/v6stat.tar.gz

# 统一 LF，避免 busybox ash 因 CRLF 报 "syntax error"
find v6stat -type f \( -name '*.sh' -o -name '*.asp' \) -exec sed -i 's/\r$//' {} \;

tar -czf dist/v6stat.tar.gz v6stat

echo "v6stat ${VER} -> dist/v6stat.tar.gz ($(wc -c < dist/v6stat.tar.gz) bytes)"
if command -v md5sum >/dev/null 2>&1; then
    echo "md5: $(md5sum dist/v6stat.tar.gz | cut -d' ' -f1)"
else
    echo "md5: $(md5 -q dist/v6stat.tar.gz)"
fi
