#!/bin/sh
# koolshare 软件中心插件卸载脚本：v6stat（IPv4/IPv6 每日流量统计）
# 目标是卸载后不留任何残留：文件、cron、dbus 键、内存盘、早期手工部署痕迹。

# 1) 定时任务
cru d v6stat >/dev/null 2>&1

# 2) 注册信息（先按前缀遍历，再逐个兜底）
for k in $(dbus listall 2>/dev/null | grep -o 'softcenter_module_v6stat_[A-Za-z0-9_]*' | sort -u); do
    dbus remove "$k" >/dev/null 2>&1
done
for s in name title description version install md5; do
    dbus remove "softcenter_module_v6stat_$s" >/dev/null 2>&1
done

# 3) 插件本体
rm -f /koolshare/scripts/v6stat.sh
rm -f /koolshare/webs/Module_v6stat.asp
rm -f /koolshare/res/icon-v6stat.png
rm -f /koolshare/init.d/V99v6stat.sh

# 4) 历史数据与页面兜底文件（jffs）
rm -rf /jffs/traffic
rm -f /jffs/.koolshare/res/v6stat-data.json
rm -f /jffs/.koolshare/res/.v6s.tmp
rm -f /jffs/.koolshare/res/v6dev-*.json

# 5) 内存盘
rm -rf /tmp/v6stat /tmp/v6stat_rt
rm -rf /tmp/v6stat* 2>/dev/null
rm -f /tmp/v6dev-*.txt

# 6) 早期手工部署留下的痕迹（脚本曾放在 /jffs/scripts，靠 services-start 启 cron）
rm -f /jffs/scripts/v6stat.sh
if [ -f /jffs/scripts/services-start ]; then
    sed -i '/v6stat/d' /jffs/scripts/services-start 2>/dev/null
fi

# 7) 卸载脚本自身的副本（放最后，删掉也不影响本次执行）
rm -f /koolshare/scripts/uninstall_v6stat.sh

echo "[v6stat] 已卸载：脚本、页面、图标、开机钩子、cron、dbus 键、历史数据全部清除。"
exit 0
