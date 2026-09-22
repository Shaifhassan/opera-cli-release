# Install Excel Add-in

This guide explains how to install the Excel add-in that adds the connector formulas to Excel.

## Download the add-in

Download the add-in file from GitHub:

```text
https://github.com/Shaifhassan/opera-cli-release/blob/main/excel/OperaExcelFunctions.xlam
```

Download `OperaExcelFunctions.xlam` and save it to the following folder:

```
%APPDATA%\Microsoft\AddIns
```

## Install the add-in in Excel

1. In File Explorer, right-click `OperaExcelFunctions.xlam`, select `Properties`, and click `Unblock` if that option is shown.
2. If you saved the file in `%APPDATA%\Microsoft\AddIns`, open Microsoft Excel.
3. Go to `File` -> `Options` -> `Add-ins`.
4. At the bottom, in `Manage`, select `Excel Add-ins` and click `Go...`.
5. If `OperaExcelFunctions` appears in the list, enable it by checking the box and click `OK`.
6. Use `Browse...` only if the add-in is stored in another location.
7. If you load the add-in from another location, make sure that folder is added as a Trusted Location in Excel.
8. Select the `OperaExcelFunctions.xlam` file and click `OK`.
9. Make sure the add-in is checked in the list and click `OK` again.

The connector formulas will now be available in Excel.

## Configure the API host

Before using the add-in, set the base URL of the connector.

The add-in reads the `DATA_HOST` environment variable.

- If `DATA_HOST` is set, that value is used.
- If it is not set, the default is `http://127.0.0.1:8080`.

Example PowerShell commands:

```powershell
setx DATA_HOST "http://127.0.0.1:8080"
setx DATA_HOST "http://192.168.31.17:8080"
```

After setting the variable, close and reopen Excel.

## Check the connector status

In any Excel cell, enter:

```excel
=show_status()
```

If the connector is running correctly, the result should be:

```text
ok
```

If the result is not `ok`, make sure the connector is running and that the API host is correct.

## Notes

- The add-in uses the configured `DATA_HOST` to call the connector API.
- If you change the environment variable, reopen Excel before testing formulas again.
- This guide is only for Excel installation and the status check formula.
