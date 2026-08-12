# Getting Started with self-hosted Connector

This guide explains how to install the connector on your own machine by downloading the latest GitHub release ZIP for your operating system, extracting it to a local folder, and running the CLI directly.

The self-hosted setup is useful when you want to run the connector without Docker and keep the configuration on the host machine.

## Download the latest release

Go to the project GitHub releases page and download the latest release archive for your platform:

- Windows: `opera-v1.0.0-windows-x86_64.zip`
- Linux: `opera-v1.0.0-linux-x86_64.tar.gz`
- macOS: `opera-v1.0.0-macos-arm64.tar.gz`

You can usually find the latest release here:

[**Go to Download Page**](https://github.com/Shaifhassan/opera-cli-release/releases)

Once downloaded, extract the archive to a folder you control.

---

## Windows

### 1. Download and extract the ZIP file

Download the Windows release file from GitHub:

- `opera-v1.0.0-windows-x86_64.zip`

Then extract it using Windows Explorer:

1. Right-click the ZIP file.
2. Choose `Extract All...`.
3. Select a folder such as `C:\OperaConnector`.
4. Finish the extraction.

### 2. Add the folder to your PATH

This makes it easier to run the CLI from any command prompt or PowerShell window.

1. Open `System Properties`.
2. Click `Environment Variables`.
3. Under `User variables`, select `Path` and click `Edit`.
4. Click `New` and add:

```text
C:\OperaConnector
```

5. Click `OK` to save.

Open a new Command Prompt or PowerShell window and check:

```powershell
opera_cli.exe --help
```

### 3. Configure the config file location

The connector uses this default Windows config path:

```text
C:\ProgramData\xkyeron\conn_manager\config.json
```

Create the folder and config file manually in Windows Explorer or with Notepad:

```json
{
  "host": "0.0.0.0",
  "port": 8080,
  "servers": []
}
```

Save it as:

```text
C:\ProgramData\xkyeron\conn_manager\config.json
```

If you want a different port, change `8080` to another value before starting the connector.

### 4. Run a server command

Run server management commands inside the CLI container:

- Add a new Oracle source: `opera_cli.exe server add-oracle <name> <host> <db_user> <service_name>` — [add-oracle](servers.md#add-oracle)
- List registered servers: `opera_cli.exe server list` — [list](servers.md#list)
- Verify a connection: `opera_cli.exe server connect <name>` — [connect](servers.md#connect)

### 5. Start the connector

Open the extracted folder and run:

```text
opera_connector.exe
```

When it starts successfully, you should see output similar to:

```text
2026-08-12T05:55:24.057009Z  INFO ThreadId(01) Loading configuration from "C:\ProgramData\xkyeron\conn_manager\config.json"
2026-08-12T05:55:24.057588Z  INFO ThreadId(01) Starting opera_api
2026-08-12T05:55:24.057765Z  INFO ThreadId(01) Config host: 0.0.0.0
2026-08-12T05:55:24.057971Z  INFO ThreadId(01) Config port: 8080
2026-08-12T05:55:24.058153Z  INFO ThreadId(01) Listening on: http://0.0.0.0:8080
2026-08-12T05:55:24.063924Z  INFO ThreadId(01) opera_api successfully listening on http://0.0.0.0:8080
```

---

## Linux

### 1. Create an installation folder

Create a folder such as `/opt/opera_cli` and extract the Linux release archive there.

```bash
sudo mkdir -p /opt/opera_cli
sudo tar -xzf opera-v1.0.0-linux-x86_64.tar.gz -C /opt/opera_cli
```

### 2. Add the folder to your PATH

```bash
echo 'export PATH="/opt/opera_cli:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Then verify the command is available:

```bash
opera_cli --help
```

### 3. Configure the config file location

On Linux, the default configuration file path is:

```text
/etc/conn_manager/config.json
```

Create the folder and config file:

```bash
sudo mkdir -p /etc/conn_manager
sudo sh -c 'cat > /etc/conn_manager/config.json <<"EOF"
{
  "host": "0.0.0.0",
  "port": 8080,
  "servers": []
}
EOF'
```

### 4. Run a server command

Run server management commands to add connection

- Add a new Oracle source: `opera_cli server add-oracle <name> <host> <db_user> <service_name>` — [add-oracle](servers.md#add-oracle)
- List registered servers: `opera_cli server list` — [list](servers.md#list)
- Verify a connection: `opera_cli server connect <name>` — [connect](servers.md#connect)

### 5. Start the connector

If you want the connector to listen on a different port, change `port` in `/etc/conn_manager/config.json` before launching it.

```bash
sudo nano /etc/conn_manager/config.json
```

Then start the connector from your install folder:

```bash
cd /opt/opera_cli
./opera_connector
```

The startup log should look similar to:

```text
Loading configuration from "/etc/conn_manager/config.json"
Starting opera_api
Config host: 0.0.0.0
Config port: 8080
Listening on: http://0.0.0.0:8080
opera_api successfully listening on http://0.0.0.0:8080
```

---

## macOS

### 1. Create an installation folder

Create a folder such as `/Applications/opera_cli` or `/opt/opera_cli`, then extract the macOS archive there.

```bash
sudo mkdir -p /opt/opera_cli
sudo tar -xzf opera-v1.0.0-macos-arm64.tar.gz -C /opt/opera_cli
```

### 2. Add the folder to your PATH

```bash
echo 'export PATH="/opt/opera_cli:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

If you use bash instead of zsh:

```bash
echo 'export PATH="/opt/opera_cli:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

Then verify:

```bash
opera_cli --help
```

### 3. Configure the config file location

On macOS, the connector also uses:

```text
/etc/conn_manager/config.json
```

Create the directory and config file:

```bash
sudo mkdir -p /etc/conn_manager
sudo sh -c 'cat > /etc/conn_manager/config.json <<"EOF"
{
  "host": "0.0.0.0",
  "port": 8080,
  "servers": []
}
EOF'
```

### 4. Run a server command

Run server management commands inside the CLI container:

- Add a new Oracle source: `opera_cli server add-oracle <name> <host> <db_user> <service_name>` — [add-oracle](servers.md#add-oracle)
- List registered servers: `opera_cli server list` — [list](servers.md#list)
- Verify a connection: `opera_cli server connect <name>` — [connect](servers.md#connect)

### 5. Start the connector

Edit the config file first if you want a custom port, then launch the binary:

```bash
sudo nano /etc/conn_manager/config.json
cd /opt/opera_cli
./opera_connector
```

You should see startup output like:

```text
Loading configuration from "/etc/conn_manager/config.json"
Starting opera_api
Config host: 0.0.0.0
Config port: 8080
Listening on: http://0.0.0.0:8080
opera_api successfully listening on http://0.0.0.0:8080
```

---

## Notes

- The default configuration path is determined by the operating system in the connector utility code.
- Windows uses `C:\ProgramData\xkyeron\conn_manager\config.json`.
- Linux and macOS use `/etc/conn_manager/config.json`.
- If you prefer, you can also set a custom path with the `CONN_MANAGER_CONFIG` environment variable.

Example:

```bash
export CONN_MANAGER_CONFIG=/custom/path/config.json
```

```powershell
$env:CONN_MANAGER_CONFIG = "C:\custom\path\config.json"
```

After configuration, you can add Oracle servers and test connectivity using the CLI commands documented in the server command section.

---
