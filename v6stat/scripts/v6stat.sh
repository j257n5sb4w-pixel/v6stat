#!/bin/sh
# v6stat.sh - 按天统计 WAN 上 IPv4 / IPv6 各走了多少流量，并按设备拆分
# 适用: Asuswrt-Merlin (含梅林改) RT-AX86U 等 HND 机型
# 原理: 开 nf_conntrack_acct=1，每分钟读 /proc/net/nf_conntrack，
#       按五元组取"已见最大字节数"的增量，按协议族 + 局域网侧 IP 累加。
#       硬件加速(Runner/FlowCache)会绕过 iptables/netfilter 计数，
#       但字节数会回写到 conntrack，所以这条路开加速时依然准。
# 用法: v6stat.sh sample | report | check | reset | boot

DIR=/jffs/traffic
DEV=$DIR/dev
T=/tmp/v6stat_rt
RES=/jffs/.koolshare/res
CSV="$DIR/v6stat-daily.csv"
PERSIST="$DIR/v6stat.state"
FLUSH_EVERY=10
mkdir -p "$DIR" "$DEV" "$T"
[ -f "$T/tuples" ] || : > "$T/tuples"

lan_pfx() {
    ip -6 addr show dev br0 scope global 2>/dev/null | awk '
        /inet6/ { split($2, a, ":"); print a[1]":"a[2]":"a[3]":"a[4]; exit }'
}

wan6_addr() {
    ip -6 addr show dev ppp0 scope global 2>/dev/null | awk '
        /inet6/ { split($2, a, "/"); print a[1]; exit }'
}

# 把 $T/dev.totals 渲染成 “id 族 字节 名字” 行（id 优先用 MAC）
render_dev() {
    ip neigh show dev br0 2>/dev/null > "$T/neigh"
    ip -6 neigh show dev br0 2>/dev/null >> "$T/neigh"
    awk -v leases="/var/lib/misc/dnsmasq.leases" -v neighf="$T/neigh" -v lanip="$(nvram get lan_ipaddr 2>/dev/null)" '
        function clean(s) { gsub(/[,\r\n]/, " ", s); return s }
        function hex2d(s,   i, v, c) {
            v = 0
            for (i = 1; i <= length(s); i++) {
                c = index("0123456789abcdef", tolower(substr(s, i, 1))) - 1
                if (c < 0) return -1
                v = v * 16 + c
            }
            return v
        }
        # 统一成 4 位补零写法：conntrack 是 240e:03a3:…，ip neigh 是 240e:3a3:…
        function norm6(a,   n, g, i, o) {
            n = split(a, g, ":")
            if (n != 8) return a
            o = ""
            for (i = 1; i <= n; i++) o = o (i > 1 ? ":" : "") sprintf("%04x", hex2d(g[i]))
            return o
        }
        BEGIN {
            while ((getline l < neighf) > 0) {
                n = split(l, A, " ")
                for (i = 1; i < n; i++) if (A[i] == "lladdr") { m2a[norm6(A[1])] = A[i+1] }
            }
            while ((getline l < leases) > 0) {
                n = split(l, B, " ")
                if (n >= 4 && B[3] ~ /^[0-9]+\./) {
                    mac2name[B[2]] = B[4]; ip2name[B[3]] = B[4]
                }
            }
        }
        {
            k = $1; b = $2 + 0
            split(k, K, "|"); ip = K[1]; fam = K[2]
            mac = (norm6(ip) in m2a) ? m2a[norm6(ip)] : ""
            id = (mac != "") ? mac : ip
            nm = (mac != "" && (mac in mac2name)) ? mac2name[mac] : ip2name[ip]
            if (nm == "" || nm == "*") nm = (ip == lanip) ? "路由器" : id
            key = id "|" fam
            sum[key] += b
            if (!(key in label)) label[key] = nm
        }
        END {
            for (k in sum) {
                split(k, K, "|")
                if (K[1] ~ /^fe80/) continue
                printf "%s %s %d %s\n", K[1], K[2], sum[k], clean(label[k])
            }
        }
    ' "$T/dev.totals"
}

# 把累计明细落盘成 $DEV/<日期>.csv，并生成给页面读的文件
flush_dev() {
    d="$1"
    [ -s "$T/dev.totals" ] || return 0
    render_dev > "$T/devout"
    awk -F' ' 'NF>=4 { printf "%s,%s,%s,%s\n", $1, $2, $3, $4 }' "$T/devout" > "$DEV/$d.csv.tmp" && \
        mv -f "$DEV/$d.csv.tmp" "$DEV/$d.csv"
    awk -F' ' 'NF>=4 { printf "%s|%s|%s|%s\n", $1, $2, $3, $4 }' "$T/devout" > "$T/v6dev-$d.txt"
    cp -f "$T/v6dev-$d.txt" "/tmp/v6dev-$d.txt" 2>/dev/null
    [ -d "$RES" ] && cp -f "$T/v6dev-$d.txt" "$RES/v6dev-$d.json" 2>/dev/null
    return 0
}

# 每分钟刷新一次给页面用的设备明细（只写 /tmp，不碰 jffs）
dev_view() {
    d="$1"
    [ -s "$T/devout" ] || return 0
    awk -F' ' 'NF>=4 { printf "%s|%s|%s|%s\n", $1, $2, $3, $4 }' "$T/devout" > "/tmp/v6dev-$d.txt"
}

emit_view() {
    today=$(echo "$1"); v4=$(echo "$2"); v6=$(echo "$3"); cnt=$(echo "$4")
    {
        echo "#v6stat 1"
        echo "now $(date '+%Y-%m-%d %H:%M')"
        echo "today $today $v4 $v6 $cnt"
        n=0
        if [ -f "$CSV" ]; then
            tail -n 31 "$CSV" | sed 's/^/day /'
            n=$(grep -c . "$CSV" 2>/dev/null)
        fi
        echo "meta $(cat /proc/sys/net/netfilter/nf_conntrack_acct 2>/dev/null) $(grep -c . /proc/net/nf_conntrack 2>/dev/null) $n"

        # 设备明细直接并入本文件：今天走实时 devout，历史读每天的设备 csv。
        # 这样页面不必再单独请求 /_temp/v6dev-*.txt（实测该文件名会 404）。
        if [ -s "$T/devout" ]; then
            awk -F' ' -v d="$today" 'NF>=4 {
                printf "dev %s %s %s %s", d, $2, $1, $3
                for (i = 4; i <= NF; i++) printf " %s", $i
                printf "\n"
            }' "$T/devout"
        fi
        if [ -f "$CSV" ]; then
            tail -n 7 "$CSV" | cut -d, -f1 | while read -r dd; do
                [ "$dd" = "$today" ] && continue
                [ -f "$DEV/$dd.csv" ] || continue
                awk -F, -v d="$dd" 'NF>=4 { printf "dev %s %s %s %s %s\n", d, $2, $1, $3, $4 }' "$DEV/$dd.csv"
            done
        fi
    } > "$T/data.txt"

    # 页面取数副本：httpd 的 /_temp 只映射 /tmp 下的单层文件名
    cp -f "$T/data.txt" /tmp/v6stat_data.txt 2>/dev/null

    # 兜底副本（/_temp 对部分客户端会 500）：按"文件年龄"控制，每 10 分钟落一次盘，
    # 这样与采样计数的对齐无关；文件不存在时立刻写一份，刚装好就能看到数据。
    if [ -d "$RES" ]; then
        _now=$(date +%s)
        _jm=$(date -r "$RES/v6stat-data.json" +%s 2>/dev/null)
        case "$_jm" in ''|*[!0-9]*) _jm=0 ;; esac
        if [ -z "$_jm" ] || [ $((_now - _jm)) -ge 600 ] || [ ! -s "$RES/v6stat-data.json" ]; then
            cp -f "$T/data.txt" "$RES/.v6s.tmp" 2>/dev/null && \
                mv -f "$RES/.v6s.tmp" "$RES/v6stat-data.json" 2>/dev/null
        fi
    fi
}

sample() {
    [ -s "$PERSIST" ] && [ ! -s "$T/totals" ] && cp "$PERSIST" "$T/totals"

    day=$(date +%Y-%m-%d)
    [ -s "$T/totals" ] || echo "$day 0 0 0" > "$T/totals"

    # 设备累计器按天切换；重启后从当天的 csv 恢复
    dday=$(cat "$T/dev.day" 2>/dev/null)
    if [ "$dday" != "$day" ]; then
        [ -n "$dday" ] && [ -s "$T/dev.totals" ] && flush_dev "$dday"
        rm -f "$T/dev.totals"
        if [ -f "$DEV/$day.csv" ]; then
            awk -F, 'NF>=3 { print $1"|"$2, $3 }' "$DEV/$day.csv" > "$T/dev.totals"
        fi
        echo "$day" > "$T/dev.day"
    fi

    [ "$(cat /proc/sys/net/netfilter/nf_conntrack_acct 2>/dev/null)" = "1" ] || \
        echo 1 > /proc/sys/net/netfilter/nf_conntrack_acct 2>/dev/null

    base=0
    [ -s "$T/tuples" ] || base=1
    : > "$T/devdelta"
    [ -f "$T/dev.totals" ] || : > "$T/dev.totals"

    out=$(awk -v oldf="$T/tuples" -v newf="$T/tuples.new" -v base="$base" \
              -v pfx="$(lan_pfx)" -v wan6="$(wan6_addr)" -v lanip="$(nvram get lan_ipaddr 2>/dev/null)" \
              -v devf="$T/devdelta" '
        function priv(a) { return a ~ /^192\.168\./ || a ~ /^10\./ || a ~ /^172\.(1[6-9]|2[0-9]|3[01])\./ }
        function loc6(a) { return a ~ /^fe80:/ || a ~ /^f[cd]/ }
        function h2d(s,   i, v, c) {
            v = 0
            for (i = 1; i <= length(s); i++) {
                c = index("0123456789abcdef", tolower(substr(s, i, 1))) - 1
                if (c < 0) return -1
                v = v * 16 + c
            }
            return v
        }
        function k4(a,   g) { split(a, g, ":"); return h2d(g[1]) "," h2d(g[2]) "," h2d(g[3]) "," h2d(g[4]) }
        BEGIN {
            while ((getline l < oldf) > 0) {
                n = split(l, F, " ")
                if (n >= 1) { old[F[1]] = F[2] + 0; if (n >= 3) dl[F[1]] = F[3] }
            }
            if (pfx != "") { split(pfx, P, ":"); pkey = h2d(P[1]) "," h2d(P[2]) "," h2d(P[3]) "," h2d(P[4]) }
            if (wan6 != "") wkey = k4(wan6)
        }
        /^ipv4 / || /^ipv6 / {
            fam = $1; proto = $3; nb = 0; src = dst = sp = dp = idv = ""
            for (i = 4; i <= NF; i++) {
                t = $i
                if (t ~ /^src=/ && src == "") src = substr(t, 5)
                else if (t ~ /^dst=/ && dst == "") dst = substr(t, 5)
                else if (t ~ /^sport=/ && sp == "") sp = substr(t, 7)
                else if (t ~ /^dport=/ && dp == "") dp = substr(t, 7)
                else if (t ~ /^id=/ && idv == "") idv = substr(t, 4)
                if (t ~ /^bytes=/) nb += substr(t, 7) + 0
            }
            if (src == "") next
            # 组播/广播/未分配源地址属于局域网内部流量，不能算 WAN
            if (fam == "ipv4") {
                if (src == "0.0.0.0" || dst == "255.255.255.255") next
                if (dst ~ /^22[4-9]\./ || dst ~ /^23[0-9]\./) next
            } else {
                if (src ~ /^::$/ || dst ~ /^ff/ || src ~ /^ff/) next
            }
            loc = ""
            if (fam == "ipv4") {
                if (priv(src) && priv(dst)) next
                if (priv(src)) loc = src
                else if (priv(dst)) loc = dst
            } else {
                s6 = (pkey != "" && k4(src) == pkey)
                d6 = (pkey != "" && k4(dst) == pkey)
                if (s6 && d6) next
                if (s6) loc = src
                else if (d6) loc = dst
                else if (wkey != "" && k4(src) == wkey) loc = lanip
                else if (wkey != "" && k4(dst) == wkey) loc = lanip
                else if (loc6(src) && loc6(dst)) next
                else if (loc6(src)) loc = src
                else if (loc6(dst)) loc = dst
            }
            key = fam "|" proto "|" src "|" sp "|" dst "|" dp "|" idv
            if (nb > cur[key]) cur[key] = nb
            if (loc != "") lc[key] = loc
        }
        END {
            for (k in cur) {
                l = (k in lc) ? lc[k] : ((k in dl) ? dl[k] : "")
                print k " " cur[k] " " l > newf
                if (base) continue
                d = cur[k] - ((k in old) ? old[k] : 0)
                if (d < 0) d = cur[k]
                if (k ~ /^ipv4\|/) v4 += d; else v6 += d
                if (d > 0 && l != "") {
                    split(k, K, "|")
                    printf "%s|%s %d\n", l, K[1], d > devf
                }
            }
            print v4 + 0, v6 + 0
        }
    ' /proc/net/nf_conntrack)
    mv -f "$T/tuples.new" "$T/tuples" 2>/dev/null

    # 合并设备增量
    if [ -s "$T/devdelta" ]; then
        awk -v add="$T/devdelta" '
            BEGIN { while ((getline l < add) > 0) { split(l, A, " "); t[A[1]] += A[2] + 0 } }
            NF { t[$1] += $2 + 0 }
            END { for (k in t) if (t[k] > 0) print k, t[k] }
        ' "$T/dev.totals" > "$T/dev.totals.new"
        mv -f "$T/dev.totals.new" "$T/dev.totals"
    fi
    render_dev > "$T/devout" 2>/dev/null
    dev_view "$day"

    d4=$(echo "$out" | awk '{print $1+0}')
    d6=$(echo "$out" | awk '{print $2+0}')
    read today v4 v6 cnt < "$T/totals"
    [ -z "$today" ] && today=$(date +%Y-%m-%d)
    # 注意：这个 busybox ash 的整数是 32 位有符号（$((2147483647+1)) 得 -2147483648），
    # 单日流量超过 2 GiB 就会溢出成负数，所以字节累加一律走 awk（双精度，2^53 以内精确）。
    v4=$(awk -v a="$v4" -v b="$d4" 'BEGIN{ if (a < 0) a = 0; if (b < 0) b = 0; printf "%.0f", a+b }')
    v6=$(awk -v a="$v6" -v b="$d6" 'BEGIN{ if (a < 0) a = 0; if (b < 0) b = 0; printf "%.0f", a+b }')
    cnt=$((cnt + 1))

    nd=$(date +%Y-%m-%d)
    if [ "$today" != "$nd" ]; then
        echo "$today $v4 $v6" >> "$CSV"
        flush_dev "$today"
        today=$nd
        v4=$((d4))
        v6=$((d6))
        cnt=1
        rm -f "$T/dev.totals"
        echo "$today" > "$T/dev.day"
    fi
    echo "$today $v4 $v6 $cnt" > "$T/totals"

    if [ $((cnt % FLUSH_EVERY)) -eq 0 ]; then
        echo "$today $v4 $v6 $cnt" > "$PERSIST"
        flush_dev "$today"
    fi
    emit_view "$today" "$v4" "$v6" "$cnt"
    return 0
}

boot() {
    cru d v6stat >/dev/null 2>&1
    cru a v6stat "* * * * * /koolshare/scripts/v6stat.sh sample" >/dev/null 2>&1
    sample
}

report() {
    echo "日期           IPv4        IPv6     IPv6占比"
    [ -f "$CSV" ] && awk '{ t=$2+$3; if (t<1) t=1; printf "%-13s %7.2f GB %7.2f GB %6.1f%%\n", $1, $2/1073741824, $3/1073741824, 100*$3/t }' "$CSV"
    [ -s "$T/totals" ] && awk '{ t=$2+$3; if (t<1) t=1; printf "%-13s %7.2f GB %7.2f GB %6.1f%%   (今天,进行中)\n", $1, $2/1073741824, $3/1073741824, 100*$3/t }' "$T/totals"
}

check() {
    echo "acct=$(cat /proc/sys/net/netfilter/nf_conntrack_acct 2>/dev/null)  conns=$(grep -c . /proc/net/nf_conntrack 2>/dev/null)"
    echo "今天: $(cat "$T/totals" 2>/dev/null)"
    echo "设备累计: $(grep -c . "$T/dev.totals" 2>/dev/null) 条"
    awk '$1=="ppp0:"{printf "netdev ppp0 rx=%.2f GB tx=%.2f GB\n", $2/1073741824, $10/1073741824}' /proc/net/dev
}

reset() {
    rm -f "$T/totals" "$T/tuples" "$T/dev.totals" "$T/dev.day" "$PERSIST"
    : > "$T/tuples"
    echo reset
}

case "$1" in
    sample) sample ;;
    boot)   boot ;;
    report) report ;;
    check)  check ;;
    reset)  reset ;;
    *) echo "用法: $0 sample|boot|report|check|reset" ;;
esac
