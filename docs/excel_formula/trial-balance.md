# Trial Balance Formula

Use the trial balance formulas to pull trial balance data from the connector into Excel.

> [!IMPORTANT]
> Trial balance formulas depend on custom database tables and views. Add the required database elements before using them.

### Available formulas

- `=OPERA_TB(identifier, reportDate)` — returns the full trial balance table as a spill range.
- `=OPERA_TB_VALUE(identifier, trxCode, startDate, endDate)` — returns a single numeric value.

> [!NOTE]
> **identifier**: the unique connection name set up for the server.

---

## OPERA_TB

Use this formula to retrieve trial balance data for a resort on a specific date.

This formula returns a dynamic table with headers and rows. It uses Excel spill behavior, so the result fills adjacent cells automatically.

```excel
=OPERA_TB([IDENTIFIER], [DATE])
```

- **IDENTIFIER**: the unique connection name set up for the server.
- **DATE**: the date for which you want to retrieve the details.

**example**
Fetch the trial balance records for yesterday.

```excel
=OPERA_TB("RESORT01", TODAY()-1)
```

| TRX_CODE | DESCRIPTION                     | NET_AMOUNT | DEP_LED_DEBIT | DEP_LED_CREDIT | GUEST_LED_DEBIT | GUEST_LED_CREDIT | PACKAGE_LED_DEBIT | PACKAGE_LED_CREDIT | AR_LED_DEBIT | AR_LED_CREDIT |
| -------- | ------------------------------- | ---------- | ------------- | -------------- | --------------- | ---------------- | ----------------- | ------------------ | ------------ | ------------- |
| 1000     | Accommodation Wholesale         | 19893.67   | 0             | 0              | 0               | 0                | 25603.15          | 0                  | 0            | 0             |
| 1001     | Accommodation Wholesale No Show | 555.46     | 0             | 0              | 714.88          | 0                | 0                 | 0                  | 0            | 0             |
| 1005     | Accommodation Wholesale Upsell  | 155.4      | 0             | 0              | 200             | 0                | 0                 | 0                  | 0            | 0             |
| 1080     | Accommodation Wholesale SVC     | 2060.45    | 0             | 0              | 0               | 0                | 0                 | 0                  | 0            | 0             |
| 1090     | Accommodation Wholesale GST     | 3853.05    | 0             | 0              | 0               | 0                | 0                 | 0                  | 0            | 0             |
| 1100     | Accommodation Direct            | 1667.76    | 0             | 0              | 0               | 0                | 2146.41           | 0                  | 0            | 0             |
| 1105     | Accommodation Direct Upsell     | 310.8      | 0             | 0              | 400             | 0                | 0                 | 0                  | 0            | 0             |
| 1180     | Accommodation Direct SVC        | 197.86     | 0             | 0              | 0               | 0                | 0                 | 0                  | 0            | 0             |
| 1190     | Accommodation Direct GST        | 369.99     | 0             | 0              | 0               | 0                | 0                 | 0                  | 0            | 0             |
| 1999     | Accommodation Green Tax         | 3924       | 0             | 0              | 3924            | 0                | 0                 | 0                  | 0            | 0             |



> [!Important]
> Leave enough empty space to the right and below the formula cell. Excel will spill the returned table there.

---

## OPERA_TB_VALUE

Use this formula to retrieve a trial balance value for a single transaction code over a date range.

This formula returns a single value and the result will be displayed in the cell where the formula is entered.

```excel
=OPERA_TB_VALUE([IDENTIFIER], [TRX_CODE], [FROM_DATE], [TO_DATE])
```

- **IDENTIFIER**: the unique connection name set up for the server.
- **TRX_CODE**: the transaction code for which you want the summed value.
- **FROM_DATE**: the start date of the date range.
- **TO_DATE**: the end date of the date range.

**example 1**
Fetch the total value for transaction code `1000` for yesterday.

```excel
=OPERA_TB_VALUE("RESORT01", "1000", TODAY()-1, TODAY()-1)
```

**example 2**
Fetch the total value for transaction code `1000` over the last 7 days.

```excel
=OPERA_TB_VALUE("RESORT01", "1000", TODAY()-7, TODAY()-1)
```

---

## Basic usage tips

- Use a date that is valid in Excel.
- Make sure the connector is running before testing the formula.
- If needed, set `DATA_HOST` to the correct connector address before use.
- If the result is not returned as expected, check that the service is running and that Excel has been reopened after setting the environment variable.
