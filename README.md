# pptp2proxy

**A Dockerized PPTP VPN Client to SOCKS5/HTTP Proxy Gateway**

[![Docker Pulls](https://img.shields.io/docker/pulls/jasongzy/pptp2proxy)](https://hub.docker.com/r/jasongzy/pptp2proxy)

Do you need to access resources inside a legacy PPTP VPN (e.g., campus networks, corporate intranets) from your modern containerized environment? `pptp2proxy` makes this effortless.

It connects to a **PPTP** VPN server and exposes the connection as standard **SOCKS5** and **HTTP** proxies.

## ✨ Features

- **🪄 Zero Host Configuration**: No need to manually run `modprobe` or mess with `iptables` on your host machine. The container handles kernel modules and GRE connection tracking automatically using a safe `nsenter` approach upon startup.
- **🛡 Clean Network Isolation**: Runs in **Docker Bridge mode**. It does *not* require `--net=host`. It modifies only the necessary connection tracking rules on the host without taking over the host's network interfaces.
- **🔌 Flexible Connectivity**: Exposes standard proxy ports (1080/8888) that can be mapped to any port you like.
- **🔒 Auth Support**: Supports optional username/password authentication for the SOCKS/HTTP proxy.
- **❤️ Auto-Reconnection**: Built-in watchdog ensures the VPN connection stays alive.

## 🚀 Quick Start

Download the configs:

```bash
wget https://raw.githubusercontent.com/jasongzy/pptp2proxy/main/docker-compose.yml
wget https://raw.githubusercontent.com/jasongzy/pptp2proxy/main/.env.example -O .env
```

Edit the `.env` file with your VPN details, and optionally modify the port mappings in `docker-compose.yml`.

Then run:

```bash
docker compose up -d
```

Enjoy!

## 🏗️ Build from Source

If you prefer to build the image locally or want to modify the source code:

1. Clone the repository

   ```bash
   git clone https://github.com/jasongzy/pptp2proxy
   cd pptp2proxy
   ```

2. Enable build in `docker-compose.yml`

   ```yaml
   services:
     pptp2proxy:
       build: .  # <--- Uncomment this line
       # ...
   ```

3. Build and run

   ```bash
   docker compose up -d --build --force-recreate
   ```

## 🧪 Verification

You can verify the proxy is working by checking your IP address through the proxy:

```bash
curl cip.cc

# Through HTTP proxy
curl -x http://127.0.0.1:8888 cip.cc
# With auth (if configured)
curl -x http://127.0.0.1:8888 -U 'myuser:mypassword' cip.cc

# Through SOCKS5 proxy
curl --socks5-hostname 127.0.0.1:1080 cip.cc
# With auth (if configured)
curl --socks5-hostname 127.0.0.1:1080 -U 'myuser:mypassword' cip.cc
```
