# Server Command

## Introduction

The `server` subcommand group is used to manage your network of data sources and delivery endpoints. All credentials added via these commands are automatically encrypted.

The addition of **API Endpoints** and **SMTP Email** support significantly expands the reach of your data pipeline. The CLI now functions as a universal data bridge, connecting secure Oracle environments directly to modern web services and internal communication channels.

---

## Add New Servers

Use these commands to manage data sources from the connector.

## Command Navigation

Use the links below to jump directly to a command section.

- [add-oracle](#add-oracle)
- [list](#list)
- [update](#update)
- [set-password](#set-password)
- [remove](#remove)
- [enable](#enable)
- [disable](#disable)
- [connect](#connect)

### Best Practices

- **Alias Naming:** Use clear aliases like `PROD_DB`, `FINANCE_SFTP`, or `MGMT_EMAIL` for `[NAME]` to keep your automation scripts readable.
- **Security:** Always rely on the secure prompt for passwords rather than passing them as plain text via `--store-plain`.
- **Verification:** After adding a server, use the `servers list` command to verify its registration.

| Type         | Command                     | Description                                                |
| ------------ | --------------------------- | ---------------------------------------------------------- |
| **Database** | [`add-oracle`](#add-oracle) | Registers a new Oracle Database connection for extraction. |
|              |                             |                                                            |

<a name="add-oracle"></a>

### **`add-oracle`**

Registers a new Oracle Database connection for extraction.

```
Usage: opera_cli.exe server add-oracle [OPTIONS] <NAME> <HOST> <DB_USER> <SERVICE_NAME>

Arguments:
  <NAME>
  <HOST>
  <DB_USER>
  <SERVICE_NAME>

Options:
      --port <PORT>                [default: 1521]
      --store-plain                Skips encryption for the password (Not recommended for production).
  -d, --description <DESCRIPTION>  Optional description for the Oracle server
  -h, --help                       Print help
```

- **Interaction:** The CLI will securely prompt you for the database password.

**Example**

```bash
# Registering a production Opera database
> server add-oracle PROD_DB 10.10.20.50 OPPROD OPPROD --port 1521
> Enter Oracle Database Password: ********
ORACLE connection 'PROD_DB' saved.
```

- **Context:** Connects to host `10.10.20.50` using the service name `PROD_DB`.
- **Result:** The server entry is saved and can be used for data execution.

---

## Manage Servers

These commands help you verify and manage Oracle server registrations after they have been added.

| Command                             | Description                                                         |
| ----------------------------------- | ------------------------------------------------------------------- |
| **[`list`](#list)**                 | Displays all configured server entries.                             |
| **[`update`](#update)**             | Update the server details                                           |
| **[`set-password`](#set-password)** | Update the server password securely                                 |
| **[`remove`](#remove)**             | Permanently deletes a server configuration                          |
| **[`enable`](#enable)**             | Enable a specific server                                            |
| **[`disable`](#disable)**           | Disable a specific server                                           |
| **[`connect`](#connect)**           | Attempts a connection test to the named server and verifies access. |
|                                     |                                                                     |

<a name="list"></a>

### **`list`**

Displays a tabular overview of all registered servers, their connection status, and endpoints.

```
Usage: opera_cli.exe server list

Options:
  -h, --help  Print help
```

Example

```bash
# Display all the server configured
> opera_cli server list

Status   Type       Name                 Details
----------------------------------------------------------------------------------------------------
ENABLED  ORACLE     main-db              system:****@db2:1521/XE
ENABLED  ORACLE     PROD_DB              system:****@10.1.1.50:1521/OPPROD
```

**Output Columns:**

- `Status`: Enabled/Disabled indicator.
- `Type`: The driver type (ORACLE).
- `Name`: The unique alias.
- `Details`: The connection URI or host address.

<a name="update"></a>

### **`update`**

command to update the required values of a stored server.

```
Usage: opera_cli.exe server update [OPTIONS] <NAME>

Arguments:
  <NAME>

Options:
      --host <HOST>
      --port <PORT>
      --db-user <DB_USER>
      --service-name <SERVICE_NAME>
      --base-url <BASE_URL>
      --auth-type <AUTH_TYPE>
  -u, --username <USERNAME>
  -d, --description <DESCRIPTION>    Optional description for the Oracle server
  -h, --help                         Print help
```

You only need to provide the flags you wish to change.

**Example:**

```bash
# Update the host and db-user for a connection stored as 'PROD_DB'
> opera_cli server update --host 10.1.1.50 --db-user system PROD_DB
Connection 'PROD_DB' updated.
```

<a name="set-password"></a>

### **`set-password`**

command to securely update the password of a stored sever

```
Usage: opera_cli.exe server set-password [OPTIONS] <NAME>

Arguments:
  <NAME>

Options:
      --store-plain  Skips encryption for the password (Not recommended for production).
  -h, --help         Print help
```

Example

```bash
# Update the password for a server stored as 'PROD_DB'
> opera_cli server set-password PROD_DB
> Enter Oracle Database Password: ********
Secret for connection 'PROD_DB' updated.
```

<a name="remove"></a>

### **`remove`**

Permanently deletes a server configuration and its associated encrypted credentials from the local vault.

```
Usage: opera_cli.exe server remove <NAME>

Arguments:
  <NAME>

Options:
  -h, --help  Print help
```

Example

```bash
# remove the Server 'PROD_DB'
> opera_cli server remove PROD_DB
Connection 'PROD_DB' removed.

# View the list of servers
> opera_cli server list
Status   Type       Name                 Details
----------------------------------------------------------------------------------------------------
ENABLED  ORACLE     main-db              system:****@db2:1521/XE
```

<a name="enable"></a>

### **`enable`**

enable the server for active connection

```
Usage: opera_cli.exe server enable <NAME>

Arguments:
  <NAME>

Options:
  -h, --help  Print help
```

Example

```bash
# Enable the Server 'PROD_DB'
> opera_cli server enable PROD_DB
Connection 'PROD_DB' enabled.

# View the list of servers
> opera_cli server list
Status   Type       Name                 Details
----------------------------------------------------------------------------------------------------
ENABLED  ORACLE     main-db              system:****@db2:1521/XE
ENABLED  ORACLE     PROD_DB              system:****@10.1.1.50:1521/OPPROD
```

<a name="disable"></a>

### **`disable`**

disable the server for so that it cannot be used

```
Usage: opera_cli.exe server disable <NAME>

Arguments:
  <NAME>

Options:
  -h, --help  Print help
```

Example

```bash
# Enable the Server 'PROD_DB'
> opera_cli server disable PROD_DB
Connection 'PROD_DB' disabled.

# View the list of servers
> opera_cli server list
Status   Type       Name                 Details
----------------------------------------------------------------------------------------------------
ENABLED  ORACLE     main-db              system:****@db2:1521/XE
DISABLED ORACLE     PROD_DB              system:****@10.1.1.50:1521/OPPROD
```

<a name="connect"></a>

### **`connect`**

Attempts a connection to the named server and validate network connectivity and credentials before executing reports.

```
Usage: opera_cli.exe server connect <NAME>

Arguments:
  <NAME>

Options:
  -h, --help  Print help
```

Example

```bash
# Test Connection to Server 'PROD_DB'
> opera_cli server connect PROD_DB
[Info] Testing database connection pool...
Connection Successful
```

---

## Integration Architecture

> [!NOTE]
> **Credential Safety:** When using the `set-password` command to change a password, Open Report automatically generates a new salt and re-encrypts the entry. The old salt is discarded to ensure cryptographic freshness.

---

\*Powered by **Xkyeron**\*
