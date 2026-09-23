# Remote Access with ngrok

This guide covers exposing `opera_connector` over the internet using [ngrok](https://ngrok.com), so Excel users don't need to be on the same network as the server running the connector.

You install the connector on a remote/cloud server as usual, run `ngrok` on that same server to open a public HTTPS tunnel to the connector's port, then point `DATA_HOST` at the ngrok URL from any machine that has the Excel add-in installed.

## When to use this

- The connector runs on a server that Excel users can't reach directly (different network, no VPN, no port-forwarding on the router/cloud security group).
- You want an HTTPS URL without provisioning your own TLS certificate or DNS record.

If the connector and Excel are on the same LAN, use a plain [self-hosted](self-hosted.md) or [Docker](docker.md) setup and point `DATA_HOST` at the machine's LAN IP instead — that's simpler and doesn't depend on an external service.

> [!WARNING]
> `opera_connector`'s API has no authentication of its own — every endpoint is open to whoever can reach it. A plain `ngrok http 8080` tunnel makes those endpoints reachable from the public internet. Follow [Securing the tunnel](#securing-the-tunnel) below before sharing the URL with anyone.

## Prerequisites

- `opera_connector` already installed on the remote server — see [Getting Started with self-hosted Connector](self-hosted.md), [Using Connector with Docker](docker.md), or [Install Connector as a Service](install-service.md).
- A free or paid [ngrok](https://ngrok.com) account and its authtoken (from the [ngrok dashboard](https://dashboard.ngrok.com/get-started/your-authtoken)).
- Admin/shell access on the remote server to install and run `ngrok` there.

## 1. Confirm the connector is running

On the remote server, start (or verify) `opera_connector` first — it should be listening on its configured port (`8080` by default):

```text
opera_connector.exe
```

or on Linux/macOS:

```bash
./opera_connector
```

`ngrok` only forwards to a port that's already open, so leave this running.

## 2. Install ngrok on the remote server

Download the agent for your platform from [ngrok.com/download](https://ngrok.com/download) and follow the installer for your OS, or use a package manager if you have one available (e.g. `winget install ngrok.ngrok` on Windows, `brew install ngrok` on macOS).

Then add your authtoken (one-time setup, same command on every platform):

```bash
ngrok config add-authtoken <YOUR_AUTHTOKEN>
```

## 3. Start the tunnel

With the connector running, open a separate terminal on the same server and run:

```bash
ngrok http 8080
```

Change `8080` if your connector uses a different port (see `port` in `config.json`).

ngrok prints a forwarding block similar to:

```text
Forwarding    https://abcd-12-34-56-78.ngrok-free.app -> http://localhost:8080
```

Copy the `https://` URL — that's the public address for the connector.

> [!NOTE]
> On the free plan, this URL is random and changes every time you restart `ngrok`. A paid plan lets you reserve a fixed domain so the URL (and your `DATA_HOST` setting) never has to change — see [Keep the URL stable](#keep-the-url-stable).

## 4. Verify the tunnel

From any machine with internet access:

```bash
curl https://abcd-12-34-56-78.ngrok-free.app/health
```

Expected response:

```json
{"status":"ok","service":"opera_api"}
```

## 5. Point Excel at the ngrok URL

On each Excel user's machine, set `DATA_HOST` to the ngrok forwarding URL instead of a LAN address — see [Install Excel Add-in](excel-add-in.md) for the full add-in setup.

```powershell
setx DATA_HOST "https://abcd-12-34-56-78.ngrok-free.app"
```

Close and reopen Excel, then check with:

```excel
=show_status()
```

It should return `ok`.

## Securing the tunnel

Since the connector itself doesn't check credentials, lock the tunnel down at the ngrok layer instead. The simplest option that needs no add-in changes is ngrok's built-in HTTP basic auth, available on every plan:

```bash
ngrok http 8080 --basic-auth "user:strong-password"
```

The Excel add-in doesn't send an `Authorization` header, but you can embed the credentials directly in `DATA_HOST` — the add-in's HTTP transport (`MSXML2.XMLHTTP`) sends them as basic auth automatically:

```powershell
setx DATA_HOST "https://user:strong-password@abcd-12-34-56-78.ngrok-free.app"
```

Other options, depending on your ngrok plan:

- **IP restrictions** — allow only the office/VPN IP ranges your Excel users connect from.
- **OAuth** — require sign-in with a Google/Microsoft/GitHub account before traffic reaches the connector (this one won't work for the Excel add-in itself, since `MSXML2.XMLHTTP` can't complete an OAuth login flow; it's better suited to browser/`curl` access).

Whichever option you pick, treat the ngrok URL like a credential — don't post it anywhere public.

## Keep the URL stable

On a free ngrok plan, the forwarding URL is reassigned each time the tunnel restarts, which means updating `DATA_HOST` on every Excel machine again. To avoid that:

- Reserve a static domain for your ngrok account (paid feature) and start the tunnel with `ngrok http 8080 --domain your-reserved-domain.ngrok-free.app` (or `.ngrok.app` for a custom domain) — `DATA_HOST` then never needs to change.
- Run `ngrok` as a background service on the remote server (`ngrok service install` on Windows/Linux, then `ngrok service start`) so the tunnel comes back automatically after a reboot, instead of relying on a terminal window staying open.

## Notes

- `ngrok` and `opera_connector` are two separate processes — both must be running on the remote server for the tunnel to work.
- The tunnel only forwards to whatever the connector is bound to locally; you don't need to change `host`/`port` in `config.json` to use ngrok.
- If `=show_status()` doesn't return `ok`, check that `ngrok` is still running, that the forwarding URL hasn't changed since you set `DATA_HOST`, and that Excel was reopened after the environment variable was updated.

---

### Whats Next

Continue with [Install Excel Add-in](excel-add-in.md) to finish configuring `DATA_HOST` on each Excel user's machine.

---
