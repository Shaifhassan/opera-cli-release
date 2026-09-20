# Configuration Data Endpoints

Version 2 adds a set of read-only REST endpoints that return Opera's setup/configuration
tables directly, instead of going through a custom SQL file. Use these when you need a
reference list of codes (departments, room types, market codes, transaction codes, and so
on) rather than transactional or revenue data.

> [!IMPORTANT]
> These endpoints are called directly by URL (usually through `Download_Data`, see
> [Bulk Configuration Download](../excel_formula/bulk-download.md)), not through a
> worksheet formula like `OPERA_DATA`.

## URL shape

```text
GET {DATA_HOST}/v1/{resort}/{endpoint}
GET {DATA_HOST}/v1/{resort}/{endpoint}?excel=y
```

- **resort**: the resort/property code, for example `RESORT01`. It is always part of the
  path, even for endpoints that return the same global table regardless of resort.
- **endpoint**: one of the configuration endpoints listed below.
- **excel** (optional): when set to `y`, the response is shaped as raw
  `columns`/`rows` arrays (the format `Download_Data` expects) instead of an array of JSON
  objects. Omit it, or use any other value, to get plain JSON objects — useful for testing
  an endpoint in a browser or with `curl`.

Every endpoint returns a `Code`/`Description` pair at minimum, plus module-specific columns
(sequence, color, parent group, associated transaction codes, and so on).

## Available endpoints

### Enterprise

| Endpoint             | Returns                                  |
| --------------------- | ----------------------------------------- |
| `departments`          | Department codes                          |
| `track_it_types`       | Track It types (Valet/Parcel/Baggage/Lost) |
| `track_it_actions`     | Track It actions and status                |
| `track_it_locations`   | Track It locations                         |

### Client Relation

| Endpoint                 | Returns                                     |
| -------------------------- | --------------------------------------------- |
| `identification_types`     | Identification/document types                 |
| `identification_country`   | Identification issuing countries              |
| `nationalities`             | Nationality / birth country codes             |
| `preferences`               | Guest preference codes (excludes floor, room features, smoking, specials) |
| `titles`                    | Salutation/title codes                        |
| `vip_levels`                | VIP level codes and display color             |

### Inventory

| Endpoint               | Returns                                  |
| ------------------------- | ------------------------------------------ |
| `housekeeping_sections`    | Housekeeping section groups and codes      |
| `housekeeping_attendants`  | Housekeeping attendants and their sections |
| `housekeeping_tasks`       | Housekeeping task codes                    |
| `floors`                   | Floor codes                                |
| `room_features`            | Room feature codes                         |
| `room_class`                | Bed types / room classes                  |
| `room_types`                | Room types, occupancy limits, features    |
| `rooms`                     | Individual rooms and their attributes     |
| `oo_reasons`                | Out-of-order / out-of-service reasons     |
| `room_maintenance`          | Room maintenance codes                    |
| `room_condition`            | Room condition / assignment reasons       |

### Financial

| Endpoint                    | Returns                                   |
| ------------------------------ | -------------------------------------------- |
| `transaction_groups`            | Transaction code groups                      |
| `transaction_subgroups`         | Transaction code subgroups                   |
| `transaction_codes`             | Transaction codes, tax and posting setup     |
| `adjustment_codes`              | Adjustment / deletion reason codes           |
| `folio_arrangement_codes`       | Folio arrangement codes and mapped transaction codes |
| `package_codes`                 | Package codes, pricing and posting rules     |
| `package_forecast_group`        | Package forecast groups                      |
| `rate_classes`                  | Rate classes                                 |
| `rate_categories`               | Rate categories (linked to rate class)       |
| `ar_restriction_reasons`        | AR flagged/restriction reasons               |
| `routing_codes`                 | Billing routing codes and mapped transaction codes |
| `payment_types`                 | Payment/credit card types                    |
| `tax_types`                     | Tax types                                    |
| `articles`                      | Article (Charge It) codes                    |

### Booking

| Endpoint                        | Returns                                  |
| ---------------------------------- | -------------------------------------------- |
| `block_cancellation_reasons`        | Business block cancellation reasons          |
| `block_refused_reasons`             | Business block refused reasons               |
| `block_lost_reasons`                | Business block lost reasons                  |
| `block_destination_codes`           | Business block destination codes             |
| `block_reservation_methods`         | Business block reservation methods           |
| `block_status`                      | Business block status codes                  |
| `market_groups`                     | Market groups                                |
| `market_codes`                      | Market codes (linked to market group)        |
| `origin_codes`                      | Origin/channel codes                         |
| `source_groups`                     | Source of business groups                    |
| `source_codes`                      | Source of business codes (linked to source group) |
| `cancellation_reasons`              | Reservation cancellation reasons             |
| `discount_reasons`                  | Discount reasons                             |
| `room_move_reasons`                 | Room / property move reasons                 |
| `trace_texts`                       | Trace text library                           |
| `turnaway_codes`                    | Turnaway codes                               |
| `waitlist_codes`                    | Waitlist codes                               |

> [!NOTE]
> A few endpoints (`oo_reasons`, `package_forecast_group`, `source_codes`, `block_status`)
> are available on the connector but are not wired into the default
> `Download_opera_data` macro yet. Call them the same way as any other endpoint with
> `Download_Data` if you need them in a workbook.

## Using config codes in Excel

The `Code` column returned by these endpoints is the same short Opera code used
everywhere else in the workbook — it is not a separate identifier system. Two common ways
to use it once a configuration sheet has been downloaded (see
[Bulk Configuration Download](../excel_formula/bulk-download.md)):

### 1. Translate a code into a description with `VLOOKUP`

If `Transaction Codes!A:B` holds transaction `Code`/`Description` pairs, resolve a code
that appears elsewhere in a report:

```excel
=VLOOKUP(B4, 'Transaction Codes'!A:B, 2, FALSE)
```

The same pattern works for `Market Groups & Codes`, `Room Types`, `Rate Classes & Categories`,
or any other downloaded configuration sheet.

### 2. Feed a code straight into an existing formula

Codes downloaded here are valid inputs for the other Excel formulas in this workbook. For
example, once `Transaction Codes` is populated, use a code from that sheet directly in
`OPERA_TB_VALUE` (see [Trial Balance Formula](trial-balance.md)):

```excel
=OPERA_TB_VALUE("RESORT01", 'Transaction Codes'!A4, TODAY()-1, TODAY()-1)
```

### 3. Restrict manual entry to valid codes with data validation

Point a cell's data validation list at the `Code` column of a downloaded configuration
sheet (`Data` -> `Data Validation` -> `List`, source `='Market Groups & Codes'!$A$2:$A$200`)
so users can only enter codes that actually exist in Opera.

> [!IMPORTANT]
> Configuration sheets are a snapshot from the time they were downloaded. Re-run
> `Download_opera_data`, or the individual download for that sheet, after Opera setup
> changes so lookups and validation lists stay accurate.
