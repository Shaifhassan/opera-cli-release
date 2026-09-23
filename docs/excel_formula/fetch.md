# Fetch Formula

Use the fetch formulas to execute custom SQL query files stored locally in `./sql` and return the results directly into Excel.

> [!IMPORTANT]
> Fetch formulas execute SQL from local query files. The file name is passed without the `.sql` extension, and parameter values are bound in the same order as the placeholders appear in the query.

### Configure Folder path

The connector reads the `OPERA_SQL_DIR` environment variable.

- additional to `OPERA_SQL_DIR` directory the default directory `%LOCALAPPDATA%\xkyeron\sql`

```powershell
setx OPERA_SQL_DIR "D:\sql"
```

After setting the variable if connector is running need to restart the connector

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

## Paginated fetch API

For queries that return a lot of rows, call `POST /fetch_table/{identifier}` to get the result one page at a time. It uses the same query files and parameters as `OPERA_DATA`.

### Request

```json
{
  "query": "reservations_by_date",
  "params": ["2026-08-24", "2026-09-23"],
  "page": 1,
  "fetch_count": 200
}
```

- **query**: the SQL file name without the `.sql` extension.
- **params**: values bound to query placeholders in order (optional).
- **page**: the page number to return, starting at 1 (optional, default `1`).
- **fetch_count**: rows per page (optional, default `200`, maximum `5000`).

### Response

```json
{
  "columns": ["RESORT", "NAME", "BEGIN_DATE", "HOTEL_ID"],
  "rows": [
    ["CRO", "CRO", "2014-05-13 13:57:31", 10461],
    ["RESORT01", "Demo Resort Small", "2023-08-08 00:00:00", 10462]
  ],
  "pagination": {
    "total_rows": 1250,
    "total_pages": 7,
    "current_page": 1,
    "next_page": 2,
    "fetch_count": 200
  }
}
```

- `columns` and `rows` have the same format as `/fetch`.
- `next_page` is `null` on the last page. To read everything, keep requesting `next_page` until it is `null`.
- A page after the last one returns an empty `rows` list.

Errors are returned as `{"error": "..."}`, the same as `/fetch`. A `page` of `0` or a `fetch_count` outside 1–5000 returns HTTP 400.

### How the query is paged

The connector does not change your SQL file. It wraps it in two queries:

```sql
-- total_rows
SELECT COUNT(*) FROM ( <your query> )

-- the requested page
SELECT /*+ FIRST_ROWS(<fetch_count>) */ * FROM ( <your query> )
OFFSET :page_offset ROWS FETCH NEXT :page_size ROWS ONLY
```

`:page_offset` is `(page - 1) * fetch_count` and `:page_size` is `fetch_count`. The `FIRST_ROWS` hint tells the Oracle optimizer to return the first rows quickly.

> [!NOTE]
> `OFFSET ... FETCH` requires Oracle 12c or later.

> [!IMPORTANT]
> Add an `ORDER BY` to any query you page through. Without one, Oracle can return rows in a different order on each request, so rows can repeat or go missing between pages.

A trailing `;` at the end of the query file is removed automatically.

### Example

```powershell
Invoke-WebRequest -Method Post -Uri http://127.0.0.1:8080/fetch_table/RESORT01 `
  -ContentType "application/json" -Body '{"query":"demo","page":2,"fetch_count":500}'
```

---

## Parameter binding

When using `OPERA_DATA`, `OPERA_VALUE` or the paginated fetch API, parameters are bound in the order they are supplied.

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
