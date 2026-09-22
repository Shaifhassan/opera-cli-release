# Windows Guided Install (Script)

This guide covers the fastest way to set up Opera CLI on Windows. A single PowerShell script downloads the latest release, installs the CLI and connector, adds them to your `PATH`, installs the Excel add-in, and can walk you through adding your first Oracle server connection — all in one run.

This guided install is Windows-only. For Linux, macOS, or a fully manual Windows setup, see [Getting Started with self-hosted Connector](self-hosted.md).

## What the script does

Running `install.ps1` will:

1. Look up the latest release on GitHub and download the Windows archive.
2. Extract `opera_cli.exe` and `opera_connector.exe` to `%LOCALAPPDATA%\xkyeron`.
3. Add that folder to your user `PATH`.
4. Download `OperaExcelFunctions.xlam` to `%APPDATA%\Microsoft\AddIns` and unblock it, so Excel won't flag it as coming from the internet.
5. Ask if you'd like to add your first Oracle server connection now, and if so, walk you through it interactively.

## 1. Run the installer

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/Shaifhassan/opera-cli-release/main/script/install.ps1 | iex
```

This downloads and runs the script directly in your session, so there's nothing to unblock and no execution policy to work around.

You'll see progress for each step: downloading the release, extracting the binaries, downloading the Excel add-in, and updating `PATH`.

> [!NOTE]
> Prefer to review the script before running it? Download it first and run it locally instead:
>
> ```powershell
> irm https://raw.githubusercontent.com/Shaifhassan/opera-cli-release/main/script/install.ps1 -OutFile install.ps1
> Unblock-File .\install.ps1
> .\install.ps1
> ```

## 2. Add your first server connection (optional)

Near the end, the script asks:

```text
Would you like to add your first server connection now? (Y/n)
```

Answering `Y` walks you through [`server add-oracle`](servers.md#add-oracle) interactively — connection name, host, schema, and a secure password prompt — then tests the connection automatically.

You can run this step again later at any time:

```powershell
irm https://raw.githubusercontent.com/Shaifhassan/opera-cli-release/main/script/setup-connection.ps1 | iex
```

## 3. Finish setting up Excel

The add-in file is already downloaded and unblocked at this point. Open Excel and enable it:

1. Go to `File` -> `Options` -> `Add-ins`.
2. At the bottom, in `Manage`, select `Excel Add-ins` and click `Go...`.
3. Check `OperaExcelFunctions` in the list and click `OK`.

See [Install Excel Add-in](excel-add-in.md) for configuring `DATA_HOST` and verifying the connector status.

## 4. Start the connector

Open a new terminal window (so the updated `PATH` takes effect) and run:

```powershell
opera_connector.exe
```

---

## Notes

- The guided install places binaries under `%LOCALAPPDATA%\xkyeron`. This is separate from the manual install path (`C:\OperaConnector`) described in the [self-hosted guide](self-hosted.md) — if you previously installed manually, pick one location to avoid confusion, or just rerun the installer to standardize on the guided path.
- The script always installs the latest release. To reinstall or upgrade later, just run the `irm ... | iex` command again.
- Both scripts are synced from this repository's `script/` folder — see [`self-hosted.md`](self-hosted.md) if you'd rather install manually or need Linux/macOS steps.
