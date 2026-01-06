#!/bin/bash
set -e

echo "Loading kernel modules..."
modprobe -a nf_conntrack_pptp nf_conntrack_proto_gre ppp_mppe nf_nat_pptp ip_nat_pptp 2>/dev/null || true
host_run() {
    nsenter --net=/host/proc/1/ns/net "$@"
}
ARGS="-t raw -p tcp --dport 1723 -j CT --helper pptp"
echo "Adding iptables rules..."
if ! host_run iptables -C PREROUTING $ARGS 2>/dev/null; then
    host_run iptables -A PREROUTING $ARGS
fi
if ! host_run iptables -C OUTPUT $ARGS 2>/dev/null; then
    host_run iptables -A OUTPUT $ARGS
fi
echo "Setup complete."

[ -z "$VPN_SERVER" ] || [ -z "$VPN_USER" ] || [ -z "$VPN_PASS" ] && echo "Error: Missing args" && exit 1

if [ -n "$PROXY_USER" ] && [ -n "$PROXY_PASS" ]; then
    echo "Configuring Proxy Authentication for user: $PROXY_USER"
    cat >/etc/3proxy.auth <<EOF
users $PROXY_USER:CL:$PROXY_PASS
auth strong
allow $PROXY_USER
EOF
else
    echo "Configuring Proxy without Authentication"
    echo "auth none" >/etc/3proxy.auth
fi

pptpsetup --create vpn --server "$VPN_SERVER" --username "$VPN_USER" --password "$VPN_PASS" --encrypt

echo "nodefaultroute" >>/etc/ppp/peers/vpn
echo "ipparam vpn" >>/etc/ppp/peers/vpn

(
    while sleep 10; do
        if ip link show ppp0 >/dev/null 2>&1 && ! pgrep 3proxy >/dev/null; then
            IP=$(ip addr show ppp0 | awk '/inet / {print $2}' | cut -d/ -f1)
            [ -n "$IP" ] && /etc/ppp/ip-up.local ppp0 "" "" "$IP"
        fi
    done
) &

exec pppd call vpn nodetach dump
