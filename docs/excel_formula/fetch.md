# Fetch Formula

Use the fetch formulas to execute custom SQL query files stored locally in `./sql` and return the results directly into Excel.

> [!IMPORTANT]
> Fetch formulas execute SQL from local query files. The file name is passed without the `.sql` extension, and parameter values are bound in the same order as the placeholders appear in the query.

### Available formulas

- `=OPERA_DATA(identifier, queryName, [param1], [param2], ...)` — returns a full table with headers and rows as a spill range.
- `=OPERA_VALUE(identifier, queryName, [param1], [param2], ...)` — returns the first column value from the first data row.

> [!NOTE]
> **identifier**: the unique connection name set up for the server.

---

## OPERA_DATA

Use this formula to execute a custom SQL file and return the full result set as a spilled table.

```excel
=OPERA_DATA([IDENTIFIER], [QUERY_NAME], [PARAM1], [PARAM2], ...)
```

- **IDENTIFIER**: the unique connection name set up for the server.
- **QUERY_NAME**: the SQL file name without the `.sql` extension.
- **PARAM1, PARAM2, ...**: values bound to query placeholders in order.

The connector loads the query from one of these locations:

- `sql/{QUERY_NAME}.sql`
- `src/sql/{QUERY_NAME}.sql`

You can also override the query directory by setting `OPERA_SQL_DIR`.

### Example

If you have a query file named `demo.sql` in the local `sql` folder:

```sql
select RESORT, NAME, BEGIN_DATE, HOTEL_ID from RESORT
```

then you can return its full result table with:

```excel
=OPERA_DATA("RESORT01", "demo")
```

| RESORT   | NAME               | BEGIN_DATE          | HOTEL_ID |
| -------- | ------------------ | ------------------- | -------- |
| CRO      | CRO                | 2014-05-13 13:57:31 | 10461    |
| RESORT01 | Demo Resort Small  | 2023-08-08 00:00:00 | 10462    |
| ORS      | Opera Demo ORS/OIS | 1749-10-12 09:11:43 | 667963   |



> [!Important]
> Leave enough empty space to the right and below the formula cell. Excel will spill the returned table there.

---

## OPERA_VALUE

Use this formula when your query returns a single value and you want just the first column from the first data row.

```excel
=OPERA_VALUE([IDENTIFIER], [QUERY_NAME], [PARAM1], [PARAM2], ...)
```

- **IDENTIFIER**: the unique connection name set up for the server.
- **QUERY_NAME**: the SQL file name without the `.sql` extension.
- **PARAM1, PARAM2, ...**: values bound to query placeholders in order.

### Example

For a query file named `guest_count.sql` with placeholders like `:1` and `:2`:

```sql
select count(*) as total_guests from guest_table where resort = :1 and report_date = :2
```

call it from Excel as:

```excel
=OPERA_VALUE("RESORT01", "guest_count", "RESORT01", TODAY()-1)
```

This returns the single numeric value from the first column of the first row.

---

## Parameter binding

When using `OPERA_DATA` or `OPERA_VALUE`, parameters are bound in the order they are supplied.

- `p1` is bound to `:1`
- `p2` is bound to `:2`
- `p3` is bound to `:3`
- and so on.

If your SQL query uses no placeholders, supply only the query name.

---

## Query naming rules

Query names must contain only letters, numbers, underscores, or dashes. For example:

- `demo`
- `trial_balance_by_date`
- `report-exports`

Do not include the `.sql` extension in the formula.

---

## Local development

For local development, place your query files in `sql/` or `src/sql/`.

Example file path:

```text
sql/demo.sql
```

Then reference it in Excel as:

```excel
=OPERA_DATA("RESORT01", "demo")
```
