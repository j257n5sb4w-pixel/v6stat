#!/bin/sh
# koolshare 软件中心插件安装脚本：v6stat（IPv4/IPv6 每日流量统计）

PKG=$(cd "$(dirname "$0")" && pwd)
VER="1.5"

echo "[v6stat] 安装目录：$PKG"

mkdir -p /koolshare/scripts /koolshare/webs /koolshare/res /koolshare/init.d /jffs/traffic

# 迁移早期手工部署的版本（脚本放在 /jffs/scripts，靠 services-start 启 cron）
cru d v6stat >/dev/null 2>&1
if [ -f /jffs/scripts/services-start ]; then
    sed -i '/v6stat/d' /jffs/scripts/services-start 2>/dev/null
fi
rm -f /jffs/scripts/v6stat.sh
rm -f /tmp/v6stat.hook

cp -f "$PKG/scripts/v6stat.sh" /koolshare/scripts/v6stat.sh
cp -f "$PKG/webs/Module_v6stat.asp" /koolshare/webs/Module_v6stat.asp
[ -f "$PKG/res/icon-v6stat.png" ] && cp -f "$PKG/res/icon-v6stat.png" /koolshare/res/icon-v6stat.png
[ -f "$PKG/uninstall.sh" ] && cp -f "$PKG/uninstall.sh" /koolshare/scripts/uninstall_v6stat.sh
chmod +x /koolshare/scripts/v6stat.sh
[ -f /koolshare/scripts/uninstall_v6stat.sh ] && chmod +x /koolshare/scripts/uninstall_v6stat.sh

cat > /koolshare/init.d/V99v6stat.sh <<EOP
#!/bin/sh
# 开机：开启 conntrack 字节记账、补写注册信息、注册每分钟采样
# 记账开关同时写 sysctl 与 module 参数，兼容 4.1 与 4.19+ 内核
echo 1 > /proc/sys/net/netfilter/nf_conntrack_acct 2>/dev/null
echo 1 > /sys/module/nf_conntrack/parameters/acct 2>/dev/null
dbus set softcenter_module_v6stat_name=v6stat
dbus set softcenter_module_v6stat_title=IPv4/IPv6流量
dbus set softcenter_module_v6stat_version=$VER
dbus set softcenter_module_v6stat_install=1
/koolshare/scripts/v6stat.sh boot >/dev/null 2>&1
EOP
chmod +x /koolshare/init.d/V99v6stat.sh

dbus set softcenter_module_v6stat_name=v6stat
dbus set softcenter_module_v6stat_title=IPv4/IPv6流量
dbus set softcenter_module_v6stat_description="按天统计 WAN 上 IPv4 与 IPv6 各走了多少流量，硬件加速下依然准确"
dbus set softcenter_module_v6stat_version=$VER
dbus set softcenter_module_v6stat_install=1

/koolshare/scripts/v6stat.sh boot

echo "[v6stat] 安装完成（$VER）：软件中心 -> IPv4/IPv6流量"
exit 0
