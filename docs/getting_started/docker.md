# Using Connector with Docker

## Docker Container Setup

This guide shows how to install the Opera Connector using Docker Compose on a Linux machine. The public image is used directly, so cloning the repository is not required.

### Prerequisites

- Docker and Docker Compose installed
- Linux shell access

### Step 1: Create a working folder

Create a local folder to hold the connector configuration and compose file:

```bash
mkdir -p ~/opera_cli
cd ~/opera_cli
```

### Step 2: Create `config.json`

Create `config.json` using a shell `cat` command.

```bash
cat << 'EOF' > config.json
{
  "host": "0.0.0.0",
  "port": 8080,
  "servers": []
}
EOF
```

### Step 3: Create `docker-compose.yml`

Create `docker-compose.yml` with the connector and CLI service definitions:

```bash
cat << 'EOF' > docker-compose.yml
version: '3.9'
services:
  connector:
    image: ghcr.io/shaifhassan/opera-cli:latest
    container_name: opera_connector
    command: ["/app/opera_connector"]
    ports:
      - "8080:8080"
    volumes:
      - ./config.json:/etc/conn_manager/config.json
      - ./sql:/app/sql

  cli:
    image: ghcr.io/shaifhassan/opera-cli:latest
    container_name: opera_cli_shell
    depends_on:
      - connector
    command: ["sleep", "infinity"]
    stdin_open: true
    tty: true
    volumes:
      - ./config.json:/etc/conn_manager/config.json
EOF
```

### Step 4: Pull the connector image

Pull the public connector image before starting the stack:

```bash
docker pull ghcr.io/shaifhassan/opera-cli:latest
```

This ensures the latest image is available locally.

### Step 5: Start Docker Compose

Start the connector and CLI services in detached mode:

```bash
docker compose up -d cli
```

### Step 6: Connect to the CLI and configure servers

Open an interactive shell into the CLI container:

```bash
docker compose exec cli bash
```

Run server management commands inside the CLI container:

- Add a new Oracle source: `opera_cli.exe server add-oracle <name> <host> <db_user> <service_name>` — [add-oracle](servers.md#add-oracle)
- List registered servers: `opera_cli.exe server list` — [list](servers.md#list)
- Verify a connection: `opera_cli.exe server connect <name>` — [connect](servers.md#connect)

Use these commands to create your Oracle source, verify it is saved, and validate connectivity before using it in reports.

### Step 7: Start the connector

The connector service is started automatically by Docker Compose. If you need to restart it later, use:

```bash
docker compose up -d connector
```

### Notes

- The connector reads `config.json` from `/etc/conn_manager/config.json` inside the container.
- Keep the image updated with `docker pull ghcr.io/shaifhassan/opera-cli:latest`.
- If you change `config.json`, restart the connector container to apply the updated settings.

---
