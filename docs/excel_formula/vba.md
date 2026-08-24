# Automating a Daily Report with VBA

You can combine the Opera Excel formulas with a VBA macro to populate a daily revenue report. A common layout keeps the report mappings in columns `BA` and `BB`:

- `BA`: Opera revenue group, such as `KPI` or `STATS`
- `BB`: Opera revenue or statistic code, such as `RB01` or `OCC_ROOM`

The macro reads those mappings for each report row, finds the selected report date, writes an `OPERA_REVENUE_VALUE` formula, calculates the cell, and stores the returned value.

> [!IMPORTANT]
> This example assumes the `OPERA_REVENUE_VALUE` Excel function is available through the Opera Excel add-in and that the connection identifier is stored in cell `A1`.

## Worksheet layout

The sample report uses this layout:

| Location    | Purpose                                             |
| ----------- | --------------------------------------------------- |
| `A1`        | Opera connection identifier, for example `RESORT01` |
| `E2:AI2`    | Daily report dates                                  |
| `E4:AI118`  | Daily result cells                                  |
| `BA4:BA118` | Revenue group mapping                               |
| `BB4:BB118` | Revenue code mapping                                |

Example mapping rows:

| Report row | Description    | `BA` group | `BB` code  |
| ---------: | -------------- | ---------- | ---------- |
|          4 | Room revenue   | `KPI`      | `RB01`     |
|          5 | Food revenue   | `KPI`      | `RB02`     |
|          6 | Occupied rooms | `STATS`    | `OCC_ROOM` |

For row 4 and date `E2`, the macro generates a formula equivalent to:

```excel
=OPERA_REVENUE_VALUE($A$1,$BA4,$BB4,E$2,E$2)
```

The two date arguments are the same because this report retrieves one day at a time.

## Sample VBA macro

Paste the following code into a standard VBA module in the workbook that contains the report sheet. The macro can process dates selected in the worksheet. When no valid dates are selected, it offers to process yesterday.

```vb
Option Explicit

Private Const FIRST_DATA_ROW As Long = 4
Private Const LAST_DATA_ROW As Long = 118
Private Const FIRST_DATE_COLUMN As String = "E"
Private Const LAST_DATE_COLUMN As String = "AI"
Private Const REVENUE_GROUP_COLUMN As String = "BA"
Private Const REVENUE_CODE_COLUMN As String = "BB"

Private Function FindReportDateColumn( _
	ByVal ws As Worksheet, _
	ByVal reportDate As Date _
) As Long

	Dim cell As Range

	For Each cell In ws.Range(FIRST_DATE_COLUMN & "2:" & LAST_DATE_COLUMN & "2").Cells
		If IsDate(cell.Value) Then
			If DateValue(cell.Value) = DateValue(reportDate) Then
				FindReportDateColumn = cell.Column
				Exit Function
			End If
		End If
	Next cell

	FindReportDateColumn = 0
End Function

Private Function WorksheetExists(ByVal sheetName As String) As Boolean
	Dim ws As Worksheet

	On Error Resume Next
	Set ws = ThisWorkbook.Worksheets(sheetName)
	On Error GoTo 0

	WorksheetExists = Not ws Is Nothing
End Function

Private Function CreateMonthSheet( _
	ByVal reportDate As Date, _
	ByVal previousSheet As Worksheet _
) As Worksheet

	Dim newSheet As Worksheet
	Dim constantCells As Range
	Dim sheetName As String

	On Error GoTo ErrorHandler

	sheetName = UCase$(Format$(reportDate, "MMMyy"))

	If WorksheetExists(sheetName) Then
		Set CreateMonthSheet = ThisWorkbook.Worksheets(sheetName)
		Exit Function
	End If

	previousSheet.Copy After:=previousSheet
	Set newSheet = ActiveSheet
	newSheet.Name = sheetName

	With newSheet.Range(FIRST_DATE_COLUMN & "2")
		.Value = DateSerial(Year(reportDate), Month(reportDate), 1)
	End With

	newSheet.Range(FIRST_DATE_COLUMN & "2:" & LAST_DATE_COLUMN & "2").NumberFormat = "dd-mmm"

	' Carry the previous sheet's YTD values into the new month.
	newSheet.Range("AQ" & FIRST_DATA_ROW & ":AQ" & LAST_DATA_ROW).Value = _
		previousSheet.Range("AP" & FIRST_DATA_ROW & ":AP" & LAST_DATA_ROW).Value

	On Error Resume Next
	Set constantCells = newSheet.Range( _
		FIRST_DATE_COLUMN & FIRST_DATA_ROW & ":" & LAST_DATE_COLUMN & LAST_DATA_ROW _
	).SpecialCells(xlCellTypeConstants)
	On Error GoTo ErrorHandler

	If Not constantCells Is Nothing Then constantCells.ClearContents

	Set CreateMonthSheet = newSheet
	Exit Function

ErrorHandler:
	MsgBox "Error creating monthly report: " & Err.Description, vbCritical, "Daily Revenue Report"
	Set CreateMonthSheet = Nothing
End Function

Private Function SetRevenue( _
	ByVal ws As Worksheet, _
	ByVal rowNumber As Long, _
	ByVal columnNumber As Long _
) As Boolean

	Dim targetCell As Range
	Dim dateCell As Range
	Dim revenueGroup As String
	Dim revenueCode As String

	On Error GoTo ErrorHandler

	Set targetCell = ws.Cells(rowNumber, columnNumber)
	Set dateCell = ws.Cells(2, columnNumber)

	revenueGroup = Trim$(CStr(ws.Cells(rowNumber, REVENUE_GROUP_COLUMN).Value))
	revenueCode = Trim$(CStr(ws.Cells(rowNumber, REVENUE_CODE_COLUMN).Value))

	targetCell.Formula = _
		"=OPERA_REVENUE_VALUE(" & _
		"$A$1," & _
		"$" & REVENUE_GROUP_COLUMN & rowNumber & "," & _
		"$" & REVENUE_CODE_COLUMN & rowNumber & "," & _
		dateCell.Address(RowAbsolute:=True, ColumnAbsolute:=False) & "," & _
		dateCell.Address(RowAbsolute:=True, ColumnAbsolute:=False) & ")"

	targetCell.Calculate

	If IsError(targetCell.Value) Then
		Err.Raise vbObjectError + 1000, "SetRevenue", _
			"OPERA_REVENUE_VALUE returned an Excel error: " & targetCell.Text
	End If

	' Store the fetched result instead of leaving the formula in the report.
	targetCell.Value = targetCell.Value
	SetRevenue = True
	Exit Function

ErrorHandler:
	If MsgBox( _
		"Error fetching row " & rowNumber & "." & vbCrLf & vbCrLf & _
		"Revenue Group: " & revenueGroup & vbCrLf & _
		"Revenue Code: " & revenueCode & vbCrLf & _
		"Report Date: " & Format$(dateCell.Value, "dd-mmm-yyyy") & vbCrLf & _
		"Error: " & Err.Description & vbCrLf & vbCrLf & _
		"Click OK to continue, or Cancel to stop the report.", _
		vbCritical + vbOKCancel, "Revenue Fetch Error") = vbCancel Then
		SetRevenue = False
	Else
		SetRevenue = True
	End If
End Function

Public Function RunDate(ByVal reportDate As Date) As Boolean
	Dim ws As Worksheet
	Dim activeColumn As Long
	Dim reportSheetName As String
	Dim rowNumber As Long
	Dim revenueGroup As String
	Dim revenueCode As String

	On Error GoTo ErrorHandler

	Set ws = ActiveSheet
	activeColumn = FindReportDateColumn(ws, reportDate)

	If activeColumn = 0 Then
		reportSheetName = UCase$(Format$(reportDate, "MMMyy"))

		If WorksheetExists(reportSheetName) Then
			Set ws = ThisWorkbook.Worksheets(reportSheetName)
		Else
			Set ws = CreateMonthSheet(reportDate, ActiveSheet)
			If ws Is Nothing Then Exit Function
		End If

		activeColumn = FindReportDateColumn(ws, reportDate)
		If activeColumn = 0 Then
			MsgBox "Report date was not found on sheet '" & ws.Name & "'.", _
				vbExclamation, "Daily Revenue Report"
			Exit Function
		End If
	End If

	For rowNumber = FIRST_DATA_ROW To LAST_DATA_ROW
		revenueGroup = Trim$(CStr(ws.Cells(rowNumber, REVENUE_GROUP_COLUMN).Value))
		revenueCode = Trim$(CStr(ws.Cells(rowNumber, REVENUE_CODE_COLUMN).Value))

		If revenueGroup <> vbNullString And revenueCode <> vbNullString Then
			If Not SetRevenue(ws, rowNumber, activeColumn) Then Exit Function
		End If
	Next rowNumber

	RunDate = True
	Exit Function

ErrorHandler:
	MsgBox "Error while processing " & Format$(reportDate, "dd-mmm-yyyy") & ": " & _
		Err.Description, vbCritical, "Daily Revenue Report"
End Function

Public Sub RunReport()
	Dim cell As Range
	Dim selectedDate As Date
	Dim foundDate As Boolean

	If TypeName(Selection) = "Range" Then
		For Each cell In Selection.Cells
			If Len(cell.Value) > 0 And IsDate(cell.Value) Then
				foundDate = True
				selectedDate = DateValue(cell.Value)
				If Not RunDate(selectedDate) Then Exit Sub
			End If
		Next cell
	End If

	If Not foundDate Then
		If MsgBox("No report dates were selected." & vbCrLf & vbCrLf & _
			"Run the report for yesterday?", vbYesNo + vbQuestion, _
			"Daily Revenue Report") = vbYes Then
			RunDate Date - 1
		End If
	End If
End Sub
```

## How the automation works

1. Select one or more date cells, usually cells in row 2, and run `RunReport` from the Macro dialog.
2. `FindReportDateColumn` compares the selected date with the dates in `E2:AI2`.
3. If the date is not on the active sheet, the macro opens the corresponding `MMMyy` sheet or copies the active sheet as a monthly template.
4. For each report row with both BA and BB mappings, `SetRevenue` writes the formula into the matching date column.
5. The target cell is calculated and checked for an Excel error.
6. The formula is replaced with its returned value, leaving a static daily snapshot in the report.

## Setup and usage

1. Enter the Opera connection identifier in `A1`.
2. Enter dates in row 2 using real Excel date values, not text that only looks like a date.
3. Add the Opera group mapping in `BA` and code mapping in `BB` for each report line.
4. Save the workbook as an Excel macro-enabled workbook (`.xlsm`).
5. Open the VBA editor with `Alt+F11`, insert a standard module, and paste the macro.
6. Select one or more report dates and run `RunReport`.

Rows with an empty BA or BB value are skipped. If a formula returns an error, the macro displays the row and mapping so the user can correct the mapping or continue with the remaining rows.

## Customizing the template

Adjust the constants at the top of the module when the report uses different locations:

```vb
Private Const FIRST_DATA_ROW As Long = 4
Private Const LAST_DATA_ROW As Long = 118
Private Const FIRST_DATE_COLUMN As String = "E"
Private Const LAST_DATE_COLUMN As String = "AI"
Private Const REVENUE_GROUP_COLUMN As String = "BA"
Private Const REVENUE_CODE_COLUMN As String = "BB"
```

The monthly-sheet logic also copies the previous sheet's `AP` values into `AQ` as the previous month YTD carry-forward. Change those columns if the workbook uses a different YTD layout.

## Troubleshooting

- **The report date is not found:** confirm that the row 2 cells contain valid Excel dates and that the date falls within the configured date columns.
- **A row is skipped:** both the BA group and BB code must be non-empty.
- **The formula returns an error:** verify the connection identifier in `A1`, the Opera group/code mapping, and that the add-in is loaded.
- **A monthly sheet is incorrect:** run the macro from the intended template sheet and verify that the copied date formulas produce the required month dates.
- **Values are not refreshed:** the macro calculates each target cell before replacing its formula with the result. Re-run the report for a date to fetch it again.
