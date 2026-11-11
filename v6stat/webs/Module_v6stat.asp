<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<script language="JavaScript" type="text/javascript">
window.onerror=function(m,s,l,c){
	var d=document.getElementById("errbox");
	if(!d){ d=document.createElement("div"); d.id="errbox";
		d.style.cssText="position:fixed;left:0;top:0;right:0;z-index:99999;background:#b00;color:#fff;font:12px/1.5 monospace;padding:6px;white-space:pre-wrap";
		(document.body||document.documentElement).appendChild(d); }
	d.appendChild(document.createTextNode("JS ERROR: "+m+" @ "+s+":"+l+":"+c+"  "));
};
</script>
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>软件中心 - IPv4/IPv6 流量</title>
<link rel="stylesheet" type="text/css" href="index_style.css"/>
<link rel="stylesheet" type="text/css" href="form_style.css"/>
<link rel="stylesheet" type="text/css" href="res/softcenter.css"/>
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/res/softcenter.js"></script>
<style>
.v6wrap{width:780px;}
.v6card{float:left;width:172px;margin:6px 8px 6px 0;padding:10px 0;text-align:center;border-radius:6px;background:#2f3a3e;border:1px solid #4a565a;}
.v6card .k{font-size:12px;color:#9fb0b5;}
.v6card .v{font-size:22px;color:#e8eef0;margin-top:4px;font-family:Menlo,Consolas,monospace;}
.v6card .s{font-size:11px;color:#7d8f95;margin-top:3px;}
.v4c{color:#4d9de0 !important;} .v6c{color:#4ec97a !important;}
.clear{clear:both;}
.v6bar2{background:#34424a;border:1px solid #4a565a;border-radius:6px;padding:10px 12px;margin-top:8px;}
.v6bar2 .item{margin:6px 0;}
.v6bar2 .row{display:flex;align-items:center;font-size:13px;color:#cfd9dc;}
.v6bar2 .row .nm{width:150px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:#e8eef0;}
.v6bar2 .row .ip{width:190px;color:#8fa1a7;font-size:11px;font-family:Menlo,Consolas,monospace;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.v6bar2 .row .by{width:90px;text-align:right;font-family:Menlo,Consolas,monospace;}
.v6bar2 .row .pc{width:66px;text-align:right;color:#9fb0b5;}
.v6bar2 .track{height:6px;background:#253034;border-radius:3px;margin:3px 0 0 0;overflow:hidden;}
.v6bar2 .fill{height:6px;border-radius:3px;}
.f4{background:linear-gradient(90deg,#5aa9e6,#3d7fbf);} .f6{background:linear-gradient(90deg,#5fd88b,#3aa864);}
.v6top{display:flex;align-items:center;gap:10px;margin:6px 0 2px 0;}
.v6top .lab{color:#9fb0b5;font-size:13px;}
.v6top input[type=date]{background:#253034;color:#e8eef0;border:1px solid #4a565a;border-radius:4px;padding:4px 8px;font-size:13px;font-family:Menlo,Consolas,monospace;}
.v6btn{background:#3d4b51;color:#dfe8ea;border:1px solid #55636a;border-radius:4px;padding:4px 10px;font-size:13px;cursor:pointer;}
.v6btn:hover{background:#47575e;}
.v6btn:disabled{opacity:.4;cursor:default;}
.piewrap{float:left;width:270px;margin-top:6px;}
.piw{width:270px;height:250px;}
.pieslice{cursor:pointer;transition:opacity .15s;}
.pieslice:hover{opacity:.82;}
.pielg{float:left;width:470px;margin:14px 0 0 10px;font-size:13px;color:#cfd9dc;}
.pielg .lg{display:flex;align-items:center;padding:8px 10px;margin:6px 0;background:#2f3a3e;border:1px solid #4a565a;border-radius:6px;cursor:pointer;}
.pielg .lg:hover{background:#38474c;}
.pielg .dot{width:12px;height:12px;border-radius:3px;margin-right:10px;}
.pielg .nm{width:100px;color:#e8eef0;}
.pielg .bv{flex:1;text-align:right;font-family:Menlo,Consolas,monospace;color:#e8eef0;}
.pielg .bp{width:70px;text-align:right;color:#9fb0b5;}
.pielg .tip{font-size:12px;color:#7d8f95;margin-top:10px;line-height:1.7em;}
table.v6tbl{width:100%;border-collapse:collapse;margin-top:10px;font-size:13px;}
table.v6tbl th,table.v6tbl td{border-bottom:1px solid #3f4b50;padding:6px 8px;text-align:right;}
table.v6tbl th{color:#9fb0b5;font-weight:normal;}
table.v6tbl td:first-child,table.v6tbl th:first-child{text-align:left;}
table.v6tbl tr{cursor:pointer;}
table.v6tbl tr:hover td{background:#33424a;}
table.v6tbl tr.sel td{background:#3b5158;color:#e8eef0;}
.v6note{font-size:12px;color:#8fa1a7;line-height:1.8em;margin-top:10px;}
#mask{position:fixed;left:0;top:0;right:0;bottom:0;background:rgba(0,0,0,.55);display:none;z-index:9000;}
#dlg{position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);width:660px;max-height:76vh;overflow:auto;background:#2b353a;border:1px solid #55636a;border-radius:8px;display:none;z-index:9001;box-shadow:0 12px 40px rgba(0,0,0,.5);}
#dlg .h{padding:12px 16px;border-bottom:1px solid #3f4b50;font-size:15px;color:#e8eef0;display:flex;}
#dlg .h .x{margin-left:auto;cursor:pointer;color:#9fb0b5;}
#dlg .h .x:hover{color:#fff;}
#dlg .b{padding:6px 16px 16px 16px;}
</style>
<script>
var V6 = {byDate:{}, order:[], sel:"", timer:null, dev:{}, devCache:{}, curFam:"v4"};

function fmt(b){
	b = parseFloat(b)||0;
	if (b >= 1073741824) return (b/1073741824).toFixed(2) + " GB";
	if (b >= 1048576) return (b/1048576).toFixed(1) + " MB";
	if (b >= 1024) return (b/1024).toFixed(0) + " KB";
	return b.toFixed(0) + " B";
}
function pct(a, b){
	var t = (parseFloat(a)||0) + (parseFloat(b)||0);
	if (t <= 0) return "0.0%";
	return (100*(parseFloat(b)||0)/t).toFixed(1) + "%";
}
function E(id){ return document.getElementById(id); }

function parseData(txt){
	V6.byDate = {}; V6.order = [];
	var dev = {}, devCache = {};
	var lines = (txt||"").split(/\r?\n/), meta = null, today = null, nowStr = "";
	for (var i=0;i<lines.length;i++){
		var f = lines[i].replace(/^\s+|\s+$/g,"").split(/\s+/);
		if (f[0] === "today" && f.length >= 4){
			today = {d:f[1], v4:+f[2], v6:+f[3], live:true};
		} else if (f[0] === "day" && f.length >= 4){
			V6.byDate[f[1]] = {d:f[1], v4:+f[2], v6:+f[3], live:false};
			V6.order.push(f[1]);
		} else if (f[0] === "now"){
			nowStr = f.slice(1).join(" ");
		} else if (f[0] === "meta"){
			meta = {acct:f[1], conns:f[2], days:f[3]};
		} else if (f[0] === "dev" && f.length >= 6){
			var dd = f[1], fam = f[2], did = f[3], dby = +f[4];
			var dnm = f.slice(5).join(" ");
			if (!dev[dd]) dev[dd] = [];
			dev[dd].push({ip:did, fam:fam, bytes:dby, name:dnm || did});
		}
	}
	if (today){ V6.byDate[today.d] = today; if (V6.order[V6.order.length-1] !== today.d) V6.order.push(today.d); }
	V6.meta = meta;
	V6.now = nowStr;
	V6.dev = dev; V6.devCache = devCache;
	V6.order.sort();
	if (!V6.sel || !V6.byDate[V6.sel]) V6.sel = today ? today.d : (V6.order[V6.order.length-1] || "");
}

function render(){
	var dp = E("dp");
	if (V6.order.length){
		dp.min = V6.order[0];
		dp.max = V6.order[V6.order.length-1];
	}
	dp.value = V6.sel;
	var it = V6.byDate[V6.sel] || {v4:0, v6:0};
	var tot = it.v4 + it.v6;
	E("c_v4").innerHTML = fmt(it.v4);
	E("c_v6").innerHTML = fmt(it.v6);
	E("c_sum").innerHTML = fmt(tot);
	E("c_pct").innerHTML = pct(it.v4, it.v6);
	E("c_day").innerHTML = V6.sel + (it.live ? " (今天·进行中)" : "");
	E("lg_v4").innerHTML = fmt(it.v4);
	E("lg_v6").innerHTML = fmt(it.v6);
	E("lg_p4").innerHTML = tot>0 ? (100*it.v4/tot).toFixed(1)+"%" : "0%";
	E("lg_p6").innerHTML = tot>0 ? (100*it.v6/tot).toFixed(1)+"%" : "0%";
	drawPie(it.v4, it.v6);
	renderTable();
	var i = V6.order.indexOf(V6.sel);
	E("btn_prev").disabled = (i <= 0);
	E("btn_next").disabled = (i < 0 || i >= V6.order.length-1);
}

function polar(cx, cy, r, deg){
	var a = (deg - 90) * Math.PI / 180;
	return [cx + r*Math.cos(a), cy + r*Math.sin(a)];
}
function slicePath(cx, cy, r1, r2, a1, a2){
	var large = (a2 - a1) > 180 ? 1 : 0;
	var p1 = polar(cx,cy,r1,a1), p2 = polar(cx,cy,r1,a2), p3 = polar(cx,cy,r2,a2), p4 = polar(cx,cy,r2,a1);
	return "M" + p1[0].toFixed(2) + "," + p1[1].toFixed(2) +
	       "A" + r1 + "," + r1 + " 0 " + large + ",1 " + p2[0].toFixed(2) + "," + p2[1].toFixed(2) +
	       "L" + p3[0].toFixed(2) + "," + p3[1].toFixed(2) +
	       "A" + r2 + "," + r2 + " 0 " + large + ",0 " + p4[0].toFixed(2) + "," + p4[1].toFixed(2) + "Z";
}

function drawPie(v4, v6){
	var cx = 135, cy = 122, R = 100, r = 60;
	var tot = v4 + v6;
	var svg = '<svg class="piw" viewBox="0 0 270 250">';
	if (tot <= 0){
		svg += '<circle cx="'+cx+'" cy="'+cy+'" r="'+R+'" fill="none" stroke="#3a474d" stroke-width="'+(R-r)+'"/>';
		svg += '<text x="'+cx+'" y="'+(cy+4)+'" text-anchor="middle" fill="#7d8f95" font-size="14">该日无数据</text>';
	} else {
		var a4 = 360 * v4 / tot;
		if (v4 > 0 && v6 > 0){
			svg += '<path class="pieslice" data-fam="v4" d="'+slicePath(cx,cy,R,r,0,a4)+'" fill="#4d9de0"><title>IPv4 '+fmt(v4)+'</title></path>';
			svg += '<path class="pieslice" data-fam="v6" d="'+slicePath(cx,cy,R,r,a4,359.99)+'" fill="#4ec97a"><title>IPv6 '+fmt(v6)+'</title></path>';
			var m4 = polar(cx,cy,(R+r)/2,a4/2), m6 = polar(cx,cy,(R+r)/2,a4+(360-a4)/2);
			if (v4/tot > 0.08) svg += '<text x="'+m4[0]+'" y="'+m4[1]+'" text-anchor="middle" fill="#fff" font-size="12" pointer-events="none">'+(100*v4/tot).toFixed(0)+'%</text>';
			if (v6/tot > 0.08) svg += '<text x="'+m6[0]+'" y="'+m6[1]+'" text-anchor="middle" fill="#fff" font-size="12" pointer-events="none">'+(100*v6/tot).toFixed(0)+'%</text>';
		} else if (v4 > 0){
			svg += '<path class="pieslice" data-fam="v4" d="'+slicePath(cx,cy,R,r,0,359.99)+'" fill="#4d9de0"><title>IPv4 '+fmt(v4)+'</title></path>';
		} else {
			svg += '<path class="pieslice" data-fam="v6" d="'+slicePath(cx,cy,R,r,0,359.99)+'" fill="#4ec97a"><title>IPv6 '+fmt(v6)+'</title></path>';
		}
		svg += '<text x="'+cx+'" y="'+(cy-6)+'" text-anchor="middle" fill="#9fb0b5" font-size="12">合计</text>';
		svg += '<text x="'+cx+'" y="'+(cy+18)+'" text-anchor="middle" fill="#e8eef0" font-size="16" font-family="Menlo,Consolas,monospace">'+fmt(tot)+'</text>';
	}
	svg += '</svg>';
	var box = E("pie");
	box.innerHTML = svg;
	var ps = box.getElementsByTagName("path");
	for (var i=0;i<ps.length;i++){
		ps[i].onclick = (function(fam){ return function(){ openDevices(fam); }; })(ps[i].getAttribute("data-fam"));
	}
}

function renderTable(){
	var html = "";
	for (var k=V6.order.length-1;k>=0;k--){
		var d = V6.order[k], it = V6.byDate[d];
		var t = it.v4 + it.v6;
		html += '<tr class="'+(d===V6.sel?'sel':'')+'" data-d="'+d+'"><td>'+d+(it.live?' (今天)':'')+'</td>'
		      + '<td>'+fmt(it.v4)+'</td><td>'+fmt(it.v6)+'</td><td>'+fmt(t)+'</td>'
		      + '<td>'+pct(it.v4,it.v6)+'</td></tr>';
	}
	if (!html) html = '<tr><td colspan="5" style="text-align:center;color:#7d8f95;">还没有完整的历史日（今天的数据见上方）</td></tr>';
	E("tbody").innerHTML = html;
	var trs = E("tbody").getElementsByTagName("tr");
	for (var i=0;i<trs.length;i++){
		if (trs[i].getAttribute("data-d")){
			trs[i].onclick = (function(d){ return function(){ selectDay(d); }; })(trs[i].getAttribute("data-d"));
		}
	}
}

function selectDay(d){
	if (!d || d === V6.sel) { render(); return; }
	V6.sel = d;
	render();
	if (E("dlg").style.display === "block") openDevices(V6.curFam, true);
}

function step(n){
	var i = V6.order.indexOf(V6.sel);
	if (i < 0) return;
	var j = i + n;
	if (j < 0 || j >= V6.order.length) return;
	selectDay(V6.order[j]);
}

function loadDevices(date, cb){
	// 设备明细已并入 /_temp/v6stat_data.txt（dev 行），无需再单独请求
	cb(V6.dev[date] || null);
}

function openDevices(fam, keep){
	V6.curFam = fam || "v4";
	var date = V6.sel;
	var isV6 = V6.curFam === "v6";
	E("dlg_t").innerHTML = date + " &nbsp;·&nbsp; " + (isV6 ? "IPv6" : "IPv4") + " 按设备明细";
	E("dlg_b").innerHTML = '<div style="color:#8fa1a7;padding:12px 0;">读取中…</div>';
	E("mask").style.display = "block";
	E("dlg").style.display = "block";
	loadDevices(date, function(rows){
		if (!rows){ E("dlg_b").innerHTML = '<div style="color:#8f9b9f;padding:14px 0;">这一天还没有设备明细。<br/>设备明细从安装本插件后开始记录，历史日期无法追溯。</div>'; return; }
		var sel = [];
		for (var i=0;i<rows.length;i++) if (rows[i].fam === (isV6?"ipv6":"ipv4")) sel.push(rows[i]);
		if (!sel.length){ E("dlg_b").innerHTML = '<div style="color:#8f9b9f;padding:14px 0;">这一天没有 '+(isV6?"IPv6":"IPv4")+' 的设备记录。</div>'; return; }
		sel.sort(function(a,b){ return b.bytes - a.bytes; });
		var sum = 0; for (var i=0;i<sel.length;i++) sum += sel[i].bytes;
		var day = V6.byDate[date] || {v4:0,v6:0};
		var dayTot = isV6 ? day.v6 : day.v4;
		var sub = '当天 '+(isV6?"IPv6":"IPv4")+' 合计 '+fmt(dayTot)+'，已归属到设备 '+fmt(sum);
		var gap = dayTot - sum;
		if (gap > dayTot*0.1) sub += '；未归属 '+fmt(gap)+'（设备明细启用之前的流量，或没走局域网的流量）';
		var html = '<div style="color:#8fa1a7;font-size:12px;padding:8px 0 4px 0;">'+sub+'</div>';
		html += '<div class="v6bar2" style="border:none;background:transparent;padding:0;">';
		for (var i=0;i<sel.length;i++){
			var r = sel[i];
			var share = dayTot>0 ? 100*r.bytes/dayTot : 0;
			var nm = (r.name && r.name !== r.ip) ? r.name : "未知设备";
			html += '<div class="item">'
			      + '<div class="row"><span class="nm" title="'+nm+'">'+(i+1)+'. '+nm+'</span>'
			      + '<span class="ip">'+r.ip+'</span>'
			      + '<span class="by">'+fmt(r.bytes)+'</span>'
			      + '<span class="pc">'+share.toFixed(1)+'%</span></div>'
			      + '<div class="track"><div class="fill '+(isV6?'f6':'f4')+'" style="width:'+Math.min(100,share).toFixed(1)+'%"></div></div>'
			      + '</div>';
		}
		html += '</div>';
		E("dlg_b").innerHTML = html;
	});
}

function closeDlg(){
	E("mask").style.display = "none";
	E("dlg").style.display = "none";
}

var SRC = ["/_temp/v6stat_data.txt", "/res/v6stat-data.json", "/_temp/v6stat/data.txt"];
function loadData(idx){
	idx = idx || 0;
	if (idx >= SRC.length){ E("upd").innerHTML = "读取失败，等待下一次刷新"; return; }
	$.ajax({
		url: SRC[idx] + "?_=" + new Date().getTime(),
		type: "GET", cache: false, dataType: "text",
		success: function(resp){
			parseData(resp); render();
			E("upd").innerHTML = "数据时间 " + (V6.now ? V6.now.slice(11) : new Date().toLocaleTimeString());
		},
		error: function(){ loadData(idx + 1); }
	});
}

function init(){
	show_menu(menu_hook);
	E("dp").onchange = function(){ selectDay(this.value); };
	E("btn_prev").onclick = function(){ step(-1); };
	E("btn_next").onclick = function(){ step(1); };
	E("btn_today").onclick = function(){ selectDay(V6.order[V6.order.length-1]); };
	E("mask").onclick = closeDlg;
	E("dlg_x").onclick = closeDlg;
	E("lg_4").onclick = function(){ openDevices("v4"); };
	E("lg_6").onclick = function(){ openDevices("v6"); };
	loadData(0);
	V6.timer = setInterval(function(){ loadData(0); }, 60000);
}
function menu_hook(title, tab){
	tabtitle[tabtitle.length - 1] = new Array("", "IPv4/IPv6 流量");
	tablink[tablink.length - 1] = new Array("", "Module_v6stat.asp");
}
</script>
</head>
<body onload="init();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<table class="content" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td width="17">&nbsp;</td>
		<td valign="top" width="202">
			<div id="mainMenu"></div>
			<div id="subMenu"></div>
		</td>
		<td valign="top">
			<div id="tabMenu" class="submenuBlock"></div>
			<div class="v6wrap">
				<div style="position:relative;">
					<div class="formfonttitle" style="display:inline-block;">IPv4 / IPv6 每日流量</div>
					<img id="return_btn" onclick="reload_Soft_Center();" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'" style="cursor:pointer;float:right;margin-top:4px;"/>
				</div>
				<div style="margin:8px 0 10px 0;" class="splitLine"></div>
				<div class="v6top">
					<span class="lab">选择日期</span>
					<button class="v6btn" id="btn_prev">◀</button>
					<input type="date" id="dp"/>
					<button class="v6btn" id="btn_next">▶</button>
					<button class="v6btn" id="btn_today">今天</button>
					<span class="lab" id="upd" style="margin-left:8px;"></span>
				</div>

				<div class="v6card"><div class="k">IPv4</div><div class="v v4c" id="c_v4">-</div><div class="s" id="c_day">&nbsp;</div></div>
				<div class="v6card"><div class="k">IPv6</div><div class="v v6c" id="c_v6">-</div><div class="s">占全区比 <span id="c_pct">-</span></div></div>
				<div class="v6card"><div class="k">合计</div><div class="v" id="c_sum">-</div><div class="s">WAN 上行+下行</div></div>
				<div class="clear"></div>

				<div class="piewrap"><div id="pie"></div></div>
				<div class="pielg">
					<div class="lg" id="lg_4">
						<span class="dot" style="background:#4d9de0;"></span>
						<span class="nm">IPv4</span>
						<span class="bv" id="lg_v4">-</span>
						<span class="bp" id="lg_p4">-</span>
					</div>
					<div class="lg" id="lg_6">
						<span class="dot" style="background:#4ec97a;"></span>
						<span class="nm">IPv6</span>
						<span class="bv" id="lg_v6">-</span>
						<span class="bp" id="lg_p6">-</span>
					</div>
					<div class="tip">点饼图里的某一块（或上面的色条），弹出当天该协议族 <b>按设备</b> 的流量排行。</div>
				</div>
				<div class="clear"></div>

				<table class="v6tbl" cellpadding="0" cellspacing="0">
					<thead><tr><th>日期</th><th>IPv4</th><th>IPv6</th><th>合计</th><th>IPv6 占比</th></tr></thead>
					<tbody id="tbody"></tbody>
				</table>

				<div class="v6note" id="note">
					计数方式：conntrack 字节记账，硬件加速下依然准确；属于 WAN 双向（上行+下行）。
					设备明细按 MAC 归并（同一台设备的多个 IPv6 地址会合并成一台设备），名字取自 DHCP 租约。
				</div>
			</div>
		</td>
		<td width="10" align="center" valign="top"></td>
	</tr>
</table>

<div id="mask"></div>
<div id="dlg">
	<div class="h"><span id="dlg_t">按设备明细</span><span class="x" id="dlg_x">✕</span></div>
	<div class="b" id="dlg_b"></div>
</div>
<div id="footer"></div>
</body>
</html>
