After docker-compose -up, when you see this:

mcodev_hytale_server  | [2026/01/28 11:23:42   INFO]                   [HytaleServer] ===============================================================================================
mcodev_hytale_server  | [2026/01/28 11:23:42   INFO]                   [HytaleServer]          Hytale Server Booted! [Multiplayer, Fresh Universe] took 6sec 705ms 817us 736ns
mcodev_hytale_server  | [2026/01/28 11:23:42   INFO]                   [HytaleServer] ===============================================================================================
mcodev_hytale_server  | [2026/01/28 11:23:42   WARN]                   [HytaleServer] No server tokens configured. Use /auth login to authenticate.

Login with  /auth login
# mCoDev Hytale Server on Docker

## Overview
This project provides a fully containerized environment for running a dedicated Hytale server using Docker.  
It includes:

- A Debian-based Docker image  
- Adoptium Temurin JDK 25 (required by Hytale)  
- Automated OAuth device-code authentication  
- A clean folder structure for persistent data  
- Bind-mounted configuration and data files for easy editing  

The goal is to make hosting a Hytale server simple, reproducible, and fully headless.

---

## Features
- Runs the official Hytale server inside Docker  
- Automatic device-code authentication on startup  
- Persistent configuration, logs, universe data, and mods  
- Clean separation between server binaries and user data  
- Works on Linux, macOS, and Windows (via Docker Desktop)  
- No manual Java installation required  

---

## Prerequisites
Make sure the following is installed:

- **Docker**  
  Windows users should install Docker Desktop:  
  https://www.docker.com/products/docker-desktop/

- **Docker Compose** (included with Docker Desktop)

---

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/your/repo.git
cd your-repo
```

### 2. Build the Docker image
```bash
docker build -t mcodev-hytale-server:main . --no-cache
```

### 3. Start the server
```bash
docker-compose up
```

On first launch, the server will prompt you to authenticate using the OAuth device-code flow.  
You will see something like:

```
Visit this URL to authenticate your Hytale server:
https://oauth.accounts.hytale.com/device
Enter this code:
ABCD-EFGH
```

Open the URL in your browser, enter the code, and approve the login.

If you started the container in detached mode (`-d`), retrieve the URL using:

```bash
docker logs mcodev_hytale_server
```

Once authenticated, the server will start and generate its configuration files.

---

## Connecting to Your Server
The server listens on:

- **Port:** 5520  
- **Protocol:** UDP  
- **Transport:** QUIC  

To connect locally:

```
127.0.0.1:5520
```

If hosting publicly, ensure your router/firewall forwards **UDP 5520**.

---

## Persistent Data & Mount Points

Your `docker-compose.yaml` mounts the following files and directories:

```yaml
volumes:
  - ./data/bans.json:/app/Server/bans.json:rw
  - ./data/config.json:/app/Server/config.json:rw
  - ./data/permissions.json:/app/Server/permissions.json:rw
  - ./data/whitelist.json:/app/Server/whitelist.json:rw
  - ./data/backups:/app/Server/backups:rw
  - ./data/logs:/app/Server/logs:rw
  - ./data/mods:/app/Server/mods:rw
  - ./data/universe:/app/Server/universe:rw
```

### What each mount does

| Host Path | Container Path | Purpose |
|----------|----------------|---------|
| `./data/bans.json` | `/app/Server/bans.json` | Stores banned players |
| `./data/config.json` | `/app/Server/config.json` | Main server configuration |
| `./data/permissions.json` | `/app/Server/permissions.json` | Permission groups & roles |
| `./data/whitelist.json` | `/app/Server/whitelist.json` | Whitelisted players |
| `./data/backups/` | `/app/Server/backups/` | Automatic world backups |
| `./data/logs/` | `/app/Server/logs/` | Server logs |
| `./data/mods/` | `/app/Server/mods/` | Mods and extensions |
| `./data/universe/` | `/app/Server/universe/` | World save data |

Only these files and directories are persisted.  
The server binaries remain inside the container and are not overwritten.

---

## Configuration

To modify server settings:

1. Stop the server:
   ```bash
   docker-compose down
   ```
2. Edit the configuration files inside the `./data` directory  
3. Start the server again:
   ```bash
   docker-compose up
   ```

Changes take effect on restart.

---

## Updating the Server

To update to a new Hytale server version:

1. Stop the container:
   ```bash
   docker-compose down
   ```
2. Rebuild the image:
   ```bash
   docker build -t mcodev-hytale-server:main . --no-cache
   ```
3. Start again:
   ```bash
   docker-compose up
   ```

Your world and configuration files remain intact.

---

## Troubleshooting

### I can’t connect to the server
- Ensure you mapped **UDP 5520**, not TCP:
  ```yaml
  ports:
    - "5520:5520/udp"
  ```
- Allow the port through your firewall:
  ```bash
  sudo ufw allow 5520/udp
  ```

### The server asks for authentication every time
This is expected.  
Hytale requires a fresh session token on each startup.


---

## Also see
- https://support.hytale.com/hc/en-us/articles/45328341414043-Server-Provider-Authentication-Guide#method-b-device-code-flow-rfc-8628-
- https://hytale-docs.pages.dev/server/authentication/


