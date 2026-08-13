# Getting Started

Start using Opera Connector in two steps.

## Step 1: Run the connector

Before using the Excel formulas, make sure `opera_connector` is running and your Opera server connection has been configured.

Choose one setup method:

- [Using Connector with Docker](getting_started/docker.md)
- [Getting Started with self-hosted Connector](getting_started/self-hosted.md)
- [Install Connector as a Service](getting_started/install-service.md)

Once the connector is running, confirm the API is reachable before moving to Excel.

---

## Step 2: Install the Excel add-in

Install the Excel add-in and point it to your connector host:

- [Install Excel Add-in](getting_started/excel-add-in.md)

After the add-in is loaded, you can start using formulas directly in Excel.

Example:

```excel
=OPERA_TB_VALUE("RESORT01", "1000", TODAY()-1, TODAY()-1)
```

This returns the trial balance value for transaction code `1000` for yesterday.

If the formula does not return a value, check that:

- `opera_connector` is running
- `DATA_HOST` points to the correct connector address
- Excel was reopened after updating environment variables
