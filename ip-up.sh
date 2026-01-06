#!/bin/bash
exec > >(tee -a /proc/1/fd/1) 2>&1

IFNAME=$1
LOCAL_IP=$4

[ -z "$LOCAL_IP" ] && echo "[ip-up] Error: Empty IP" && exit 1

echo "[ip-up] Interface: $IFNAME, IP: $LOCAL_IP"

ip rule del from $LOCAL_IP lookup 200 2>/dev/null || true
ip route flush table 200 2>/dev/null || true
ip rule add from $LOCAL_IP lookup 200
ip route add default dev $IFNAME table 200

cat >/etc/3proxy.cfg <<CONFIG
log /proc/1/fd/1
logformat "L%d-%m-%Y %H:%M:%S 3proxy: %C:%c > %R:%r (%O bytes)"
nserver 8.8.8.8
nserver 1.1.1.1
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
daemon
$(cat /etc/3proxy.auth)
internal 0.0.0.0
external $LOCAL_IP
flush
socks -p1080
flush
proxy -p8888
CONFIG

pkill 3proxy
sleep 1
/usr/bin/3proxy /etc/3proxy.cfg

echo "[ip-up] 3proxy restarted"
