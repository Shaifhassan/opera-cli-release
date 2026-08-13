# Revenue Formula

Use the revenue formulas to pull revenue data from the connector into Excel.

> [!IMPORTANT]
> Revenue formulas depend on custom database tables and views. Add the required database elements before using them.

### Available formulas

- `=OPERA_REVENUE_CODES(identifier)` - returns the list of revenue codes configured in Opera
- `=OPERA_REVENUE(identifier, revenueGroup, reportDate)` — returns the full revenue table as a spill range.
- `=OPERA_REVENUE_VALUE(identifier, revenueGroup, revenueCode, startDate, endDate)` — returns a single numeric value.

> [!NOTE]
> **identifier**: the unique connection name set up for the server.

---

## OPERA_REVENUE_CODES

This formula returns the list of all configured revenue groups and statistic codes from the Opera PMS. It uses Excel spill behavior, so the result fills adjacent cells automatically.

```excel
=OPERA_REVENUE_CODES([IDENTIFIER])
```

- **IDENTIFIER**: the unique connection name set up for the server.

**example**

```excel
=OPERA_REVENUE_CODES('RESORT01')
```

| RESORT   | BUCKET_TYPE | GROUP_CODE | CODE               | DESCRIPTION            |
| -------- | ----------- | ---------- | ------------------ | ---------------------- |
| RESORT01 | REVENUE     | KPI        | RB01               | Room                   |
| RESORT01 | REVENUE     | KPI        | RB02               | Food                   |
| RESORT01 | REVENUE     | KPI        | RB03               | Beverage               |
| RESORT01 | REVENUE     | KPI        | RB04               | Spa                    |
| RESORT01 | STATS       | STATS      | ADULTS_IN_HOUSE    | Adults in House        |
| RESORT01 | STATS       | STATS      | AVAIL_ROOM         | Available Rooms        |
| RESORT01 | STATS       | STATS      | CANCEL_RESERVATION | Cancelled Reservations |
| RESORT01 | STATS       | STATS      | CANCEL_ROOMS       | Cancelled Rooms        |

> [!Important]
> Leave enough empty space to the right and below the formula cell. Excel will spill the returned table there.

---

## OPERA_REVENUE

Use this formula to retrieve a single day of `revenue` or `statistic` data for a resort.

This formula returns a dynamic table with headers and rows. It uses Excel spill behavior, so the result fills adjacent cells automatically.

```excel
=OPERA_REVENUE([IDENTIFIER], [GROUP_CODE], [DATE])
```

- **IDENTIFIER**: the unique connection name set up for the server.
- **GROUP_CODE**: the revenue bucket group code configured in Opera PMS, or `STATS` for statistics.
- **DATE**: the date for which you want to retrieve the details.

**example 1**
Fetch the daily revenue records for a revenue bucket group called `KPI`

```excel
=OPERA_REVENUE("RESORT01","KPI", TODAY()-1)
```

| RESORT   | BUSINESS_DATE       | BUCKET_TYPE | GROUP_CODE | CODE | DESCRIPTION | VALUE    |
| -------- | ------------------- | ----------- | ---------- | ---- | ----------- | -------- |
| RESORT01 | 2026-08-10 00:00:00 | REVENUE     | KPI        | RB01 | Room        | 24162.42 |
| RESORT01 | 2026-08-10 00:00:00 | REVENUE     | KPI        | RB02 | Food        | 20555.74 |
| RESORT01 | 2026-08-10 00:00:00 | REVENUE     | KPI        | RB03 | Beverage    | 11369.24 |
| RESORT01 | 2026-08-10 00:00:00 | REVENUE     | KPI        | RB04 | Spa         | 1498.83  |
| RESORT01 | 2026-08-10 00:00:00 | REVENUE     | KPI        | RB11 | Others      | 280.89   |
| RESORT01 | 2026-08-10 00:00:00 | REVENUE     | KPI        | RB12 | Transfer    | 18299.69 |

**example 2**
Fetch the manager flash statistics for a resort for a single day

```excel
=OPERA_REVENUE("RESORT01","STATS", TODAY()-1)
```

| RESORT   | BUSINESS_DATE       | BUCKET_TYPE | GROUP_CODE | CODE               | DESCRIPTION               | VALUE    |
| -------- | ------------------- | ----------- | ---------- | ------------------ | ------------------------- | -------- |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | ADULTS_IN_HOUSE    | Adults in House           | 241      |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | AVAIL_ROOM         | Available Rooms           | 6        |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | CANCEL_RESERVATION | Cancelled Reservations    | 35       |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | CANCEL_ROOMS       | Cancelled Rooms           | 27       |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | CHILDREN_IN_HOUSE  | Children in House         | 104      |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | COMP_ROOM          | Complimentary Rooms       | 2        |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | FOOD_BEV_REVENUE   | Food and Beverage Revenue | 32103.69 |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | GUEST_IN_HOUSE     | Guests in House           | 345      |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | HOUSE_USE_ROOM     | House Use Rooms           | 0        |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | OCC_ROOM           | Occupied Rooms            | 119      |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | OOO_ROOMS          | Out of Order Rooms        | 1        |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | OS_ROOMS           | Overstay Rooms            | 0        |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | OTHER_REVENUE      | Other Revenue             | 25326.88 |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | PHYSICAL_ROOM      | Physical Rooms            | 125      |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | ROOM_REVENUE       | Room Revenue              | 21442.91 |
| RESORT01 | 2026-08-10 00:00:00 | STATS       | STATS      | TOTAL_REVENUE      | Total Revenue             | 78873.48 |

> [!Important]
> Leave enough empty space to the right and below the formula cell. Excel will spill the returned table there.

---

## OPERA_REVENUE_VALUE

Use this formula to retrieve a `revenue` or `statistic` value for a single code over a date range.

This formula returns a single value and result will be displayed in the cell where the formula is entered.

```excel
=OPERA_REVENUE_VALUE([IDENTIFIER], [GROUP_CODE], [CODE], [FROM_DATE], [TO_DATE])
```

- **IDENTIFIER**: the unique connection name set up for the server.
- **GROUP_CODE**: the revenue bucket group code configured in Opera PMS, or `STATS` for statistics.
- **CODE**: the revenue code or statistic code for which you want the summed value.
- **FROM_DATE**: the start date of the date range.
- **TO_DATE**: the end date of the date range.

**example 1**
Fetch the total sum of revenue code `RB01` for the `KPI` bucket group over the last 7 days.

```excel
=OPERA_REVENUE_VALUE("RESORT01", "KPI", "RB01", TODAY()-7, TODAY()-1)
```

**example 2**
Fetch the number of occupied rooms for yesterday.

```excel
=OPERA_REVENUE_VALUE("RESORT01", "STATS", "OCC_ROOM", TODAY()-1, TODAY()-1)
```

---
