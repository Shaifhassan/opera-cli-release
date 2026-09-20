# Bulk Configuration Download (VBA)

Version 2 adds a VBA download method that pulls Opera configuration data (see
[Configuration Data Endpoints](config-data.md)) straight into worksheets, instead of
entering a formula per cell. It writes a full table in one call and shows progress in a
modeless form while it runs.

> [!IMPORTANT]
> This lives in the `download.vb` and `prgressform.vb` modules of the Excel add-in
> workbook, alongside the `frmProgress` userform. Import all three if you are wiring this
> into a new workbook.

## Requirements

- A named range called `resort` in the workbook, containing the resort code to download
  (for example `RESORT01`). `Download_Data` reads this named range on every call.
- A worksheet per configuration table, matching the sheet names used by the download
  routine (see the table below). The routine writes to an existing sheet — it does not
  create one.
- `DATA_HOST` configured as described in [Install Excel Add-in](../getting_started/excel-add-in.md),
  since `Download_Data` calls `OperaExcel.DownloadData`, the same HTTP helper the worksheet
  formulas use.

## `Download_Data`

The core building block. One call downloads one endpoint into one sheet/column.

```vb
Public Sub Download_Data( _
    ByVal endpoint As String, _
    ByVal sheetName As String, _
    ByVal startColumn As String, _
    Optional ByVal apiVersion As String = "v1", _
    Optional ByVal appendData As Boolean = True, _
    Optional ByVal startRow As Long = 2 _
)
```

- **endpoint**: the configuration endpoint name, for example `"departments"`.
- **sheetName**: the destination worksheet. It is unprotected automatically if needed.
- **startColumn**: the column letter where the table starts, for example `"A"`.
- **apiVersion**: defaults to `"v1"`; override only if a newer API version is available.
- **appendData**: when `True` (default), data is written after the last used row in
  `startColumn` (or at `startRow` if the column is empty). When `False`, data always starts
  at `startRow`, overwriting whatever was there.
- **startRow**: the first data row when not appending, or the floor row when appending.
  Defaults to `2`, leaving row 1 for headers.

```vb
' Append departments starting at column A, row 2 (default).
Download_Data "departments", "Departments", "A"

' Explicitly target API v2 and start fresh at row 5 in column B.
Download_Data _
    endpoint:="roomtypes", _
    sheetName:="RoomTypes", _
    startColumn:="B", _
    apiVersion:="v2", _
    appendData:=False, _
    startRow:=5
```

Internally this resolves the resort code, builds `{apiVersion}/{resort}/{endpoint}`, and
calls `OperaExcel.DownloadData` with `excel=Y` so the response arrives as a plain
columns/rows array ready to paste into the sheet.

## `Download_opera_data`

Runs every wired-up configuration download in sequence, showing progress in `frmProgress`.

```vb
Download_opera_data
```

Run it from the Excel Macro dialog (`Alt+F8`) or bind it to a button/ribbon control. It
shows the progress form modelessly, downloads each module's tables in turn, marks the form
complete, then unloads it.

### What it downloads

| Module          | Sheet                             | Columns filled |
| ---------------- | ------------------------------------ | --------------- |
| Enterprise        | Departments                          | A               |
| Enterprise        | Track It - Types                     | A               |
| Enterprise        | Track It - Locations                 | A               |
| Enterprise        | Track It - Actions                   | A               |
| Client Relation    | Identification Type & Country        | A, G            |
| Client Relation    | Nationalities & Birth Country        | A               |
| Client Relation    | Preferences                          | A               |
| Client Relation    | Titles                               | A               |
| Client Relation    | VIP Levels                           | A               |
| Inventory          | Hsk Section Groups & Codes           | F               |
| Inventory          | Housekeeping Attendants              | A               |
| Inventory          | Tasks                                | A               |
| Inventory          | Floors                               | A               |
| Inventory          | Room Features                        | F               |
| Inventory          | Bed Types & Room Class               | F               |
| Inventory          | Room Types                           | A               |
| Inventory          | Rooms                                | A               |
| Inventory          | Room Maintenance                     | F               |
| Inventory          | Room Conditions                      | A               |
| Financial          | Transaction Groups                   | A               |
| Financial          | Transaction Subgroups                | A               |
| Financial          | Transaction Codes                    | A               |
| Financial          | Adjustment Codes                     | F               |
| Financial          | Folio Arrangement Codes              | A               |
| Financial          | Package Codes                        | A               |
| Financial          | Rate Classes & Categories            | A, G            |
| Financial          | AR Acct Types & Restricted Reas      | O               |
| Financial          | Routing Codes                        | A               |
| Financial          | Payment Types                        | A               |
| Financial          | Tax Types                            | E               |
| Financial          | Articles                             | A               |
| Booking            | Block Cxl & Refused Reasons          | A, F            |
| Booking            | Lost Reasons & Destination Code      | A, F            |
| Booking            | Business Blk Type & Res Methods      | F               |
| Booking            | Market Groups & Codes                | A, F            |
| Booking            | Origin Codes & Marketing Region      | A               |
| Booking            | Source Groups & Codes                | A               |
| Booking            | Cancellation & Discount Reasons      | A, F            |
| Booking            | Room Move & Prop Move Reasons        | A               |
| Booking            | Trace Texts                          | F               |
| Booking            | Turnaway Codes                       | A               |
| Booking            | Waitlist Codes & Priorities          | A               |

Every listed sheet must already exist in the workbook before running the macro, since
`Download_Data` targets an existing worksheet by name.

> [!NOTE]
> `oo_reasons`, `package_forecast_group`, `source_codes` and `block_status` have endpoints
> and can be downloaded with `Download_Data` individually, but are not part of the default
> `Download_opera_data` run yet.

## Adding your own download

Add a new private sub next to the existing ones in `download.vb` and call `Download_Data`
with the endpoint, sheet, and column you need, then add a call to it from
`Download_opera_data` (and bump `TotalProcesses` so the progress bar stays accurate):

```vb
Private Sub Download_RoomTypes()
    CurrentProcess = CurrentProcess + 1
    frmProgress.UpdateProgress _
        CurrentProcess / TotalProcesses * 100, _
        "Downloading Inventory Module...", _
        "Room Types (v2)..."
    Download_Data "roomtypes", "RoomTypes", "A", "v2"
End Sub
```

## Progress form (`frmProgress`)

`frmProgress` is a modeless userform used by both `Download_Data` callers above:

- `frmProgress.Show vbModeless` — shows the form without blocking the Excel UI.
- `frmProgress.UpdateProgress percentage, status, [details]` — updates the progress bar,
  status line, and detail line, then calls `DoEvents` so Excel stays responsive.
- `frmProgress.ShowCompleted [message]` — sets the bar to 100% and turns it green.
- `frmProgress.ShowError errorMessage` — turns the bar red and shows the error, for use in
  an `ErrorHandler` around your own download subs.
- `Unload frmProgress` — closes the form once the run finishes.

## Troubleshooting

- **"Resort code is not defined"**: the workbook is missing the `resort` named range, or it
  is empty.
- **A sheet does not receive data**: confirm the sheet name in the call matches the actual
  worksheet name exactly, including spaces and punctuation.
- **Data lands in the wrong row**: check `appendData`/`startRow` — appending resumes after
  the last used row in `startColumn`, so a stray value below the table pushes new rows down.
- **The macro stops partway through**: `Download_Data`'s own error handler shows a message
  box and exits that one sub; check the endpoint name and that the connector is reachable,
  then re-run `Download_opera_data`.
