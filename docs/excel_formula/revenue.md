# Revenue

Use the revenue formulas to pull revenue data from the connector into Excel.

## Available formulas

- `=FETCH_REVENUE(identifier, reportDate)` — returns the full revenue table as a spill range.
- `=FETCH_REVENUE_VALUE(identifier, revenueBucket, revenueGroup, revenueCode, startDate, endDate)` — returns a single numeric value.

## Example: get the full revenue table

```excel
=FETCH_REVENUE("RESORT01", TODAY()-1)
```

- `RESORT01` is the identifier.
- `TODAY()-1` uses yesterday's date.

This formula returns a dynamic table with headers and rows. It uses Excel spill behavior, so the result fills adjacent cells automatically.

> Important: leave enough empty space to the right and below the formula cell. Excel will spill the returned table there.

## Example: get one revenue value

```excel
=FETCH_REVENUE_VALUE("RESORT01", "REVENUE", "ROOM", "1000", TODAY()-7, TODAY()-1)
```

- `RESORT01` is the identifier.
- `REVENUE` is the revenue bucket.
- `ROOM` is the revenue group.
- `1000` is the revenue code.
- `TODAY()-7` to `TODAY()-1` defines the date range.

This returns a single numeric value from the API response.

## Spill behavior

The formulas that use spill output are:

- `FETCH_REVENUE(...)`
- `FETCH_TB(...)`

These formulas return a table rather than a single cell value, so Excel spills the result into neighboring cells.

The single-value formulas are:

- `FETCH_REVENUE_VALUE(...)`
- `FETCH_TB_VALUE(...)`

These are used when you only need one number.

## Tips

- Use valid Excel dates for `startDate` and `endDate`.
- Make sure the connector API is running before using the function.
- If you are using a custom API host, confirm the `DATA_HOST` environment variable is set correctly.
- If the formula returns an error, verify the service is reachable and the identifier is valid.
- Leave space for spill results when using `FETCH_REVENUE(...)` or `FETCH_TB(...)`.
