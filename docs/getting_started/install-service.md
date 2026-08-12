# Install Connector as a Service

This guide explains how to install the Windows version of the connector as a background service using the MSI installer. The installer is created with WiX and registers a Windows service named `opera_service`.

The MSI package also adds the installation folder to the Windows `PATH` environment variable automatically, so you can run the CLI commands without manually updating environment settings.

## Download the MSI installer

Download the installer from the GitHub releases page:

- `opera_cli-1.0.0-x86_64.msi`

[**Go to Download Page**](https://github.com/Shaifhassan/opera-cli-release/releases)

## Install the service

1. Double-click the MSI file.
2. Follow the setup wizard and accept the default installation location.
3. Complete the installation.

The installer will:

- install the binaries under `Program Files\opera_cli\bin`
- add that folder to the system `PATH`
- register the Windows service `opera_service`
- configure the service to start automatically

## What gets installed

The WiX installer includes:

- `opera_connector.exe`
- `opera_cli.exe`
- `opera_service.exe`

The service is registered with the display name:

```text
Opera Data-Link Service
```

## Verify the PATH has been added automatically

Open a new Command Prompt or PowerShell window and run:

```powershell
opera_cli.exe --help
```

If the installation succeeded, the command should run without needing any manual PATH changes.

## Verify the Windows service is running

You can check the service in Windows Services or from the command line:

```powershell
sc query opera_service
```

Or:

```powershell
Get-Service opera_service
```

The service should show as `Running` after installation.

## Start, stop, or restart the service

### Start the service

```powershell
sc start opera_service
```

### Stop the service

```powershell
sc stop opera_service
```

### Restart the service

```powershell
sc stop opera_service
sc start opera_service
```

### Open the Windows Services window

1. Press `Win + R`
2. Type `services.msc`
3. Locate `Opera Data-Link Service`
4. Use the Start, Stop, or Restart actions from there

## Configure the connector

The connector reads its configuration from the default Windows location:

```text
C:\ProgramData\xkyeron\conn_manager\config.json
```

If needed, open that file and change the host or port before starting the service.

Example:

```json
{
  "host": "0.0.0.0",
  "port": 8080,
  "servers": []
}
```

The service will use the values in this file when it starts.

## Example: list configured servers

Once the PATH is available, you can run:

```powershell
opera_cli.exe server list
```

This confirms both the CLI and the installed Windows service are available on the machine.

---

## Notes

- The MSI install is the easiest option for a Windows machine that should run the connector continuously in the background.
- No manual environment variable setup is required because the WiX installer adds the install folder to `PATH` automatically.
- If you want to update the port, edit `C:\ProgramData\xkyeron\conn_manager\config.json` before restarting the service.
