# Trial Balance

Use the trial balance formulas to pull the current accounting data from the connector into Excel.

## Available formulas

- `=OPERA_TB(identifier, reportDate)` — returns the trial balance table as a dynamic spill range.
- `=OPERA_TB_VALUE(identifier, tCode, startDate, endDate)` — returns a single numeric value for one account code.

## Example: get the full trial balance table

```excel
=FETCH_TB("RESORT01", TODAY()-1)
```

- `RESORT01` is the resort or identifier configured in the connector.
- `TODAY()-1` uses yesterday's date.

This formula returns a table with headers and rows. It uses Excel spill behavior, so the results flow into adjacent cells automatically.

> Important: leave enough empty space to the right and below the formula cell. Excel will spill the result there.

## Example: get one value from a trial balance

```excel
=FETCH_TB_VALUE("RESORT01", "1000", TODAY()-1, TODAY()-1)
```

This returns a single numeric value for the selected code and date range.

## Spill behavior

The formula that uses spill is:

- `FETCH_TB(...)`

This formula returns a multi-row, multi-column result. Excel spills the output instead of returning a single cell value.

Use the spill result when you want to review a table of balances. Use `FETCH_TB_VALUE(...)` when you only need one number.

## Basic usage tips

- Use a date that is valid in Excel.
- Make sure the connector is running before testing the formula.
- If needed, set `DATA_HOST` to the correct connector address before use.
- If the result is not returned as expected, check that the service is running and that Excel has been reopened after setting the environment variable.
