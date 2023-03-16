Table 50000 "EOS02802 Excel Buffer"
{
    Caption = 'Excel Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Row No."; Integer)
        {
            Caption = 'Row No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                xlRowID := '';
                if "Row No." <> 0 then
                    xlRowID := Format("Row No.");
            end;
        }
        field(2; xlRowID; Text[10])
        {
            Caption = 'xlRowID';
            DataClassification = CustomerContent;
        }
        field(3; "Column No."; Integer)
        {
            Caption = 'Column No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                xlColID := GetExcelColumnCode("Column No.");
            end;
        }
        field(4; xlColID; Text[10])
        {
            Caption = 'xlColID';
            DataClassification = CustomerContent;
        }
        field(5; "Cell Value as Text"; Text[2048])
        {
            Caption = 'Cell Value as Text';
            DataClassification = CustomerContent;
        }
        field(6; Comment; Text[250])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(7; Formula; Text[250])
        {
            Caption = 'Formula';
            DataClassification = CustomerContent;
        }
        field(8; Bold; Boolean)
        {
            Caption = 'Bold';
            DataClassification = CustomerContent;
        }
        field(9; Italic; Boolean)
        {
            Caption = 'Italic';
            DataClassification = CustomerContent;
        }
        field(10; Underline; Boolean)
        {
            Caption = 'Underline';
            DataClassification = CustomerContent;
        }
        field(11; NumberFormat; Text[30])
        {
            Caption = 'NumberFormat';
            DataClassification = CustomerContent;
        }
        field(12; Formula2; Text[250])
        {
            Caption = 'Formula2';
            DataClassification = CustomerContent;
        }
        field(13; Formula3; Text[250])
        {
            Caption = 'Formula3';
            DataClassification = CustomerContent;
        }
        field(14; Formula4; Text[250])
        {
            Caption = 'Formula4';
            DataClassification = CustomerContent;
        }
        field(15; "Cell Type"; Option)
        {
            Caption = 'Cell Type';
            OptionCaption = 'Number,Text,Date,Time';
            OptionMembers = Number,Text,Date,Time;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Row No.", "Column No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        InfoExcelBuf: Record "EOS02802 Excel Buffer" temporary;
        TempInternalBuffer: Record "EOS02802 Excel Buffer" temporary;
        FileManagement: Codeunit "File Management";
        ColumnEntityDefaults: array[16384, 3] of Boolean;
        DisableAutoFitColumns: Boolean;
        ExcelSheetCreated: Boolean;
        isHeader: Boolean;
        UseInfoSheet: Boolean;
        HideDialog: Boolean;
        ColumnEntityID: array[16384] of Code[10];
        CurrentCol: Integer;
        CurrentRecPosition: Integer;
        CurrentRow: Integer;
        IntLineNo: Integer;
        MaxColumnEntityID: Integer;
        ActiveSheetName: Text[250];
        CacheColumn: array[16384] of Text[3];
        FileNameServer: Text;
        RangeEndXlCol: Text[30];
        RangeEndXlRow: Text[30];
        RangeStartXlCol: Text[30];
        RangeStartXlRow: Text[30];
        Text001Err: label 'You must enter a file name.';
        Text002Err: label 'You must enter an Excel worksheet name.';
        Text003Err: label 'The file %1 does not exist.', Comment = '%1 =';
        Text004Err: label 'The Excel worksheet %1 does not exist.', Comment = '%1 =';
        Text005Lbl: label 'Creating Excel worksheet...\\';
        Text006Lbl: label '%1%3%4%3Page %2', Comment = '%1 = ; %2 = ; %3 = ; %4= ';
        Text007Lbl: label 'Reading Excel worksheet...\\';
        Text013Lbl: label '&B';
        Text014Lbl: label '&D';
        Text015Lbl: label '&P';
        Text016Lbl: label 'A1';
        Text017Lbl: label 'SUMIF';
        Text018Lbl: label '#N/A';
        Text019Lbl: label 'GLAcc';
        Text020Lbl: label 'Period';
        Text021Lbl: label 'Budget';
        Text022Lbl: label 'CostAcc';
        Text034Lbl: label 'Excel Files (*.xls*)|*.xls*|All Files (*.*)|*.*';
        Text035Err: label 'The operation was canceled.';
        Text036Err: label 'The Excel workbook does not exist.';
        Text037Err: label 'Could not create the Excel workbook.';
        Text038Err: label 'Global variable %1 is not included for test.', Comment = '%1 =';
        Text039Err: label 'Cell type has not been set.';
        Text040Lbl: label 'Export Excel File';
        TextRSA002Err: label 'Unknow column ID %1.', Comment = '%1 =';
        IXLWorksheet: dotnet "EOS IXLWorksheet";
        IXLWorksheets: dotnet "EOS IXLWorksheets";
        XLWorkbook: dotnet "EOS XLWorkbook";
        [RunOnClient]
        XlApp: dotnet "EOS ApplicationClass2";
        [RunOnClient]
        XlHelper: dotnet "EOS excelhelp";
        [RunOnClient]
        XlWrkBk: dotnet "EOS Workbook2";
        [RunOnClient]
        XlWrkSht: dotnet "EOS Worksheet2";

    procedure CreateBook(SheetName: Text[250])
    var
        XLEventTracking: dotnet "EOS XLEventTracking";
    begin
        if SheetName = '' then
            Error(Text002Err);

        FileNameServer := FileManagement.ServerTempFileName('xlsx');
        XLWorkbook := XLWorkbook.XLWorkbook(XLEventTracking.Disabled);
        if IsNull(XLWorkbook) then
            Error(Text037Err);

        IXLWorksheet := XLWorkbook.Worksheets.Add(SheetName);
        if SheetName <> '' then
            ActiveSheetName := SheetName;

    end;

    procedure OpenBook(FileName: Text; SheetName: Text[250])
    var
        Found: Boolean;
        UseFirst: Boolean;
        i: Integer;
    begin
        if FileName = '' then
            Error(Text001Err);

        if SheetName = '' then
            Error(Text002Err);

        UseFirst := (SheetName = '');

        XLWorkbook := XLWorkbook.XLWorkbook(FileName);
        IXLWorksheets := XLWorkbook.Worksheets;

        Found := false;
        for i := 1 to IXLWorksheets.Count do begin
            IXLWorksheet := IXLWorksheets.Worksheet(i);

            if UseFirst then begin
                SheetName := IXLWorksheet.Name;
                Found := true;
            end else
                if SheetName = IXLWorksheet.Name then
                    Found := true;

        end;

        if Found then
            IXLWorksheet := IXLWorksheets.Worksheet(SheetName)
        else begin
            QuitExcel();
            Error(Text004Err, SheetName);
        end;
    end;

    procedure OpenBook2(FileName: Text; SheetName: Text[250])
    var
        NVInStream: InStream;
        Found: Boolean;
        UseFirst: Boolean;
        i: Integer;
        FileName2: Text;
        FileRTC: DotNet "EOS SystemIOFile";
        MemoryStream: DotNet "EOS SystemIOMemoryStream";
    begin
        if FileName = '' then
            Error(Text001Err);

        if SheetName = '' then
            Error(Text002Err);

        UseFirst := (SheetName = '');

        IF NOT FileRTC.Exists(FileName) THEN
            ERROR(Text003Err, FileName);

        UploadIntoStream('Import', '', '', FileName2, NVInStream);
        MemoryStream := NVInStream;

        XLWorkbook := XLWorkbook.XLWorkbook(MemoryStream);
        IXLWorksheets := XLWorkbook.Worksheets;

        Found := false;
        for i := 1 to IXLWorksheets.Count do begin
            IXLWorksheet := IXLWorksheets.Worksheet(i);

            if UseFirst then begin
                SheetName := IXLWorksheet.Name;
                Found := true;
            end else
                if SheetName = IXLWorksheet.Name then
                    Found := true;

        end;

        if Found then
            IXLWorksheet := IXLWorksheets.Worksheet(SheetName)
        else begin
            QuitExcel();
            Error(Text004Err, SheetName);
        end;
    end;

    procedure OpenBookStream(FileName: Text; SheetName: Text; var NVInStream: InStream)
    var
        Found: Boolean;
        UseFirst: Boolean;
        i: Integer;
        MemoryStream: DotNet "EOS SystemIOMemoryStream";
    begin
        MemoryStream := NVInStream;

        XLWorkbook := XLWorkbook.XLWorkbook(MemoryStream);
        IXLWorksheets := XLWorkbook.Worksheets;

        Found := false;
        for i := 1 to IXLWorksheets.Count do begin
            IXLWorksheet := IXLWorksheets.Worksheet(i);

            if UseFirst then begin
                SheetName := IXLWorksheet.Name;
                Found := true;
            end else
                if SheetName = IXLWorksheet.Name then
                    Found := true;

        end;

        if Found then
            IXLWorksheet := IXLWorksheets.Worksheet(SheetName)
        else begin
            QuitExcel();
            Error(Text004Err, SheetName);
        end;
    end;

    procedure UpdateBook(FileName: Text; SheetName: Text[250])
    begin
    end;

    procedure CloseBook()
    begin
        if not IsNull(XLWorkbook) then begin
            Clear(IXLWorksheet);
            Clear(IXLWorksheets);
            Clear(XLWorkbook);
        end;
    end;

    procedure WriteSheet(ReportHeader: Text[80]; CompanyName: Text[30]; UserID2: Text)
    var
        ExcelBufferDialogMgt: Codeunit "Excel Buffer Dialog Management";
        CRLF: Char;
        LastUpdate: DateTime;
        RecNo: Integer;
        TotalRecNo: Integer;
        OrientationValues: dotnet "EOS XLPageOrientation";
    begin
        LastUpdate := CurrentDatetime;
        if not HideDialog then
            ExcelBufferDialogMgt.Open(Text005Lbl);

        CRLF := 10;
        RecNo := 1;
        TotalRecNo := Count + InfoExcelBuf.Count;
        RecNo := 0;

        if ReportHeader <> '' then
            IXLWorksheet.PageSetup.Header.Left.AddText(
              StrSubstNo('%1%2%1%3%4', GetExcelReference(1), ReportHeader, CRLF, CompanyName));

        IXLWorksheet.PageSetup.Header.Right.AddText(
          StrSubstNo(Text006Lbl, GetExcelReference(2), GetExcelReference(3), CRLF, UserID2));
        IXLWorksheet.PageSetup.PageOrientation := OrientationValues.Landscape;

        Commit();

        if FindSet() then
            repeat
                RecNo := RecNo + 1;
                if not UpdateProgressDialog(ExcelBufferDialogMgt, LastUpdate, RecNo, TotalRecNo) then begin
                    QuitExcel();
                    Error(Text035Err)
                end;
                if Formula = '' then
                    WriteCellValue(Rec)
                else
                    WriteCellFormula(Rec)
            until Next() = 0;


        ExcelBufferDialogMgt.Close();

        ExcelSheetCreated := true;
    end;

    local procedure WriteCellValue(ExcelBuffer: Record "EOS02802 Excel Buffer")
    var
        Int: Integer;
        IXLCell: dotnet "EOS IXLCell";
        XLBorderStyleValues: dotnet "EOS XLBorderStyleValues";
        XLCellValues: dotnet "EOS XLCellValues";
    begin
        with ExcelBuffer do begin
            IXLCell := IXLWorksheet.Cell("Row No.", xlColID);

            case "Cell Type" of
                "cell type"::Number:
                    begin
                        IXLCell.DataType := XLCellValues.Number;
                        if Evaluate(Int, NumberFormat) then
                            IXLCell.Style.NumberFormat.NumberFormatId := Int
                        else
                            IXLCell.Style.NumberFormat.SetFormat(NumberFormat);
                        IXLCell.Value := "Cell Value as Text";
                    end;
                "cell type"::Text:
                    begin
                        IXLCell.DataType := XLCellValues.Text;
                        IXLCell.Value := "Cell Value as Text";
                    end;
                "cell type"::Date:
                    begin
                        IXLCell.DataType := XLCellValues.DateTime;
                        IXLCell.Style.DateFormat.SetFormat(NumberFormat);
                        IXLCell.Value := "Cell Value as Text";
                    end;
                "cell type"::Time:
                    begin
                        IXLCell.DataType := XLCellValues.TimeSpan;
                        IXLCell.Value := "Cell Value as Text";
                    end
                else
                    Error(Text039Err);
            end;

            if Bold then
                IXLCell.Style.Font.Bold := true;
            if Italic then
                IXLCell.Style.Font.Italic := true;
            if Underline then
                IXLCell.Style.Border.BottomBorder := XLBorderStyleValues.Medium
            else
                IXLCell.Style.Border.BottomBorder := XLBorderStyleValues.None;
        end;
    end;

    local procedure WriteCellFormula(ExcelBuffer: Record "EOS02802 Excel Buffer")
    var
        IXLCell: dotnet "EOS IXLCell";
        XLBorderStyleValues: dotnet "EOS XLBorderStyleValues";
    begin
        with ExcelBuffer do begin
            IXLCell := IXLWorksheet.Cell("Row No.", xlColID);
            IXLCell.FormulaA1 := GetFormula();

            if Bold then
                IXLCell.Style.Font.Bold := true;
            if Italic then
                IXLCell.Style.Font.Italic := true;
            if Underline then
                IXLCell.Style.Border.BottomBorder := XLBorderStyleValues.Medium
            else
                IXLCell.Style.Border.BottomBorder := XLBorderStyleValues.None;
        end;
    end;

    procedure CreateRangeName(RangeName: Text[30]; FromColumnNo: Integer; FromRowNo: Integer)
    var
        TempExcelBuf: Record "EOS02802 Excel Buffer" temporary;
        ToxlRowID: Text[10];
    begin
        SetCurrentkey("Row No.", "Column No.");
        if Find('+') then
            ToxlRowID := xlRowID;
        TempExcelBuf.Validate("Row No.", FromRowNo);
        TempExcelBuf.Validate("Column No.", FromColumnNo);

        IXLWorksheet.NamedRanges.Add(
            RangeName,
            '=' + GetExcelReference(4) + TempExcelBuf.xlColID + GetExcelReference(4) + TempExcelBuf.xlRowID +
            ':' + GetExcelReference(4) + TempExcelBuf.xlColID + GetExcelReference(4) + ToxlRowID)
    end;

    procedure GiveUserControl()
    begin
        if not IsNull(XlApp) then begin
            XlApp.Visible := true;
            XlApp.UserControl := true;
            Clear(XlApp);
        end;
    end;

    procedure ReadSheet()
    var
        ExcelBufferDialogMgt: Codeunit "Excel Buffer Dialog Management";
        LastUpdate: DateTime;
        i: Integer;
        j: Integer;
        Maxi: Integer;
        Maxj: Integer;
        RowCount: Integer;
        a: text;
        CellFormat: Text;
        IXLCell: dotnet "EOS IXLCell";
    begin
        LastUpdate := CurrentDatetime;
        if not HideDialog then
            ExcelBufferDialogMgt.Open(Text007Lbl);
        DeleteAll();

        Maxi := IXLWorksheet.LastRowUsed().RowNumber();
        Maxj := IXLWorksheet.LastColumnUsed().ColumnNumber();
        i := 1;
        repeat
            RowCount += 1;
            j := 1;
            Validate("Row No.", i);
            repeat
                Validate("Column No.", j);
                IXLCell := IXLWorksheet.Cell("Row No.", "Column No.");
                a := Format(IXLCell.DataType);
                case Format(IXLCell.DataType) of
                    'TEXT', 'Text':
                        CellFormat := Format('@');
                    'NUMBER',
                  'TIMESPAN',
                  'BOOLEAN', 'Number', 'Timespan', 'Boolean':
                        CellFormat := Format(IXLCell.Style.NumberFormat);
                    'DATETIME', 'Datetime':
                        CellFormat := Format(IXLCell.Style.DateFormat);
                end;

                ParseCellValue(format(IXLCell.Value), CellFormat);
                Insert();
                j += 1;
            until j > Maxj;
            i += 1;

            Commit();
            if not UpdateProgressDialog(ExcelBufferDialogMgt, LastUpdate, i, RowCount) then begin
                QuitExcel();
                Error(Text035Err)
            end;
        until i > Maxi;

        QuitExcel();
        ExcelBufferDialogMgt.Close();
    end;

    local procedure ParseCellValue(Value: Text; FormatString: Text)
    var
        DateTime: DateTime;
        DateTimeHelper: dotnet DateTime;
        Decimal: Decimal;
    begin
        NumberFormat := CopyStr(FormatString, 1, 30);

        if FormatString = '@' then begin
            "Cell Type" := "cell type"::Text;
            "Cell Value as Text" := CopyStr(Value, 1, MaxStrLen("Cell Value as Text"));
            exit;
        end;

        if Evaluate(Decimal, Value) then;

        if StrPos(FormatString, ':') <> 0 then begin
            DateTime := DateTimeHelper.FromOADate(Decimal);
            "Cell Type" := "cell type"::Time;
            "Cell Value as Text" := Format(Dt2Time(DateTime));
            exit;
        end;

        if ((StrPos(FormatString, 'y') <> 0) or
            (StrPos(FormatString, 'm') <> 0) or
            (StrPos(FormatString, 'd') <> 0)) and
           (StrPos(FormatString, 'Red') = 0)
        then begin
            DateTime := CreateDatetime(Dmy2date(30, 12, 1899) + ROUND(Decimal), 0T);
            "Cell Type" := "cell type"::Date;
            "Cell Value as Text" := Format(Dt2Date(DateTime));
            exit;
        end;

        "Cell Type" := "cell type"::Number;
        "Cell Value as Text" := Format(ROUND(Decimal, 0.000001), 0, 1);
    end;

    procedure SelectSheetsName(FileName: Text): Text[250]
    var
        EndOfLoop: Integer;
        i: Integer;
        OptionNo: Integer;
        SelectedSheetName: Text[250];
        SheetName: Text[250];
        SheetsList: Text[250];
    begin
        if FileName = '' then
            Error(Text001Err);

        XLWorkbook := XLWorkbook.XLWorkbook(FileName);
        IXLWorksheets := XLWorkbook.Worksheets;

        EndOfLoop := XLWorkbook.Worksheets.Count;
        i := 1;
        while i <= EndOfLoop do begin
            IXLWorksheet := XLWorkbook.Worksheet(i);
            SheetName := IXLWorksheet.Name;
            if (SheetName <> '') and (StrLen(SheetsList) + StrLen(SheetName) < 250) then
                SheetsList := CopyStr(SheetsList + SheetName + ',', 1, MaxStrLen(SheetsList))
            else
                i := EndOfLoop;
            i := i + 1;
        end;
        Clear(XLWorkbook);
        OptionNo := StrMenu(SheetsList, 1);
        if OptionNo <> 0 then
            SelectedSheetName := CopyStr(SelectStr(OptionNo, SheetsList), 1, MaxStrLen(SelectedSheetName));

        QuitExcel();
        exit(SelectedSheetName);
    end;

    procedure GetExcelReference(Which: Integer): Text[250]
    begin
        case Which of
            1:
                exit(Text013Lbl);
            2:
                exit(Text014Lbl);
            3:
                exit(Text015Lbl);
            4:
                exit('$');
            5:
                exit(Text016Lbl);
            6:
                exit(Text017Lbl);
            7:
                exit(Text018Lbl);
            8:
                exit(Text019Lbl);
            9:
                exit(Text020Lbl);
            10:
                exit(Text021Lbl);
            11:
                exit(Text022Lbl);
        end;
    end;

    procedure ExportBudgetFilterToFormula(var ExcelBuf: Record "EOS02802 Excel Buffer"): Boolean
    var
        ExcelBufFormula2: Record "EOS02802 Excel Buffer" temporary;
        ExcelBufFormula: Record "EOS02802 Excel Buffer" temporary;
        HasFormulaError: Boolean;
        ThisCellHasFormulaError: Boolean;
        FirstRow: Integer;
        LastRow: Integer;
    begin
        ExcelBuf.SetFilter(Formula, '<>%1', '');
        if ExcelBuf.FindSet() then
            repeat
                ExcelBufFormula := ExcelBuf;
                ExcelBufFormula.Insert();
            until ExcelBuf.Next() = 0;
        ExcelBuf.Reset();

        with ExcelBufFormula do
            if FindSet() then
                repeat
                    ThisCellHasFormulaError := false;
                    ExcelBuf.SetRange("Column No.", 1);
                    ExcelBuf.SetFilter("Row No.", '<>%1', "Row No.");
                    ExcelBuf.SetFilter("Cell Value as Text", Formula);
                    ExcelBufFormula2 := ExcelBufFormula;
                    if ExcelBuf.FindSet() then
                        repeat
                            if not Get(ExcelBuf."Row No.", "Column No.") then
                                ExcelBuf.Mark(true);
                        until ExcelBuf.Next() = 0;
                    ExcelBufFormula := ExcelBufFormula2;
                    ClearFormula();
                    ExcelBuf.SetRange("Cell Value as Text");
                    ExcelBuf.SetRange("Row No.");
                    if ExcelBuf.FindSet() then
                        repeat
                            if ExcelBuf.Mark() then begin
                                LastRow := ExcelBuf."Row No.";
                                if FirstRow = 0 then
                                    FirstRow := LastRow;
                            end else
                                if FirstRow <> 0 then begin
                                    if FirstRow = LastRow then
                                        ThisCellHasFormulaError := AddToFormula(xlColID + Format(FirstRow))
                                    else
                                        ThisCellHasFormulaError :=
                                          AddToFormula('SUM(' + xlColID + Format(FirstRow) + ':' + xlColID + Format(LastRow) + ')');
                                    FirstRow := 0;
                                    if ThisCellHasFormulaError then
                                        SetFormula(ExcelBuf.GetExcelReference(7));
                                end;
                        until ThisCellHasFormulaError or (ExcelBuf.Next() = 0);

                    if not ThisCellHasFormulaError and (FirstRow <> 0) then begin
                        if FirstRow = LastRow then
                            ThisCellHasFormulaError := AddToFormula(xlColID + Format(FirstRow))
                        else
                            ThisCellHasFormulaError :=
                              AddToFormula('SUM(' + xlColID + Format(FirstRow) + ':' + xlColID + Format(LastRow) + ')');
                        FirstRow := 0;
                        if ThisCellHasFormulaError then
                            SetFormula(ExcelBuf.GetExcelReference(7));
                    end;

                    ExcelBuf.Reset();
                    ExcelBuf.Get("Row No.", "Column No.");
                    ExcelBuf.SetFormula(GetFormula());
                    ExcelBuf.Modify();
                    HasFormulaError := HasFormulaError or ThisCellHasFormulaError;
                until Next() = 0;

        exit(HasFormulaError);
    end;

    procedure AddToFormula(Text: Text[30]): Boolean
    var
        Overflow: Boolean;
        LongFormula: Text[1000];
    begin
        LongFormula := GetFormula();
        if LongFormula = '' then
            LongFormula := '=';
        if LongFormula <> '=' then
            if StrLen(LongFormula) + 1 > MaxStrLen(LongFormula) then
                Overflow := true
            else
                LongFormula := copystr(LongFormula + '+', 1, MaxStrLen(LongFormula));
        if StrLen(LongFormula) + StrLen(Text) > MaxStrLen(LongFormula) then
            Overflow := true
        else
            SetFormula(copystr(LongFormula + Text, 1, 1000));
        exit(Overflow);
    end;

    procedure GetFormula(): Text[1000]
    begin
        exit(Formula + Formula2 + Formula3 + Formula4);
    end;

    procedure SetFormula(LongFormula: Text[1000])
    begin
        ClearFormula();
        if LongFormula = '' then
            exit;

        Formula := CopyStr(LongFormula, 1, MaxStrLen(Formula));
        if StrLen(LongFormula) > MaxStrLen(Formula) then
            Formula2 := CopyStr(LongFormula, MaxStrLen(Formula) + 1, MaxStrLen(Formula2));
        if StrLen(LongFormula) > MaxStrLen(Formula) + MaxStrLen(Formula2) then
            Formula3 := CopyStr(LongFormula, MaxStrLen(Formula) + MaxStrLen(Formula2) + 1, MaxStrLen(Formula3));
        if StrLen(LongFormula) > MaxStrLen(Formula) + MaxStrLen(Formula2) + MaxStrLen(Formula3) then
            Formula4 := CopyStr(LongFormula, MaxStrLen(Formula) + MaxStrLen(Formula2) + MaxStrLen(Formula3) + 1, MaxStrLen(Formula4));
    end;

    procedure ClearFormula()
    begin
        Formula := '';
        Formula2 := '';
        Formula3 := '';
        Formula4 := '';
    end;

    procedure NewRow()
    begin
        CurrentRow := CurrentRow + 1;
        CurrentCol := 0;
    end;

    procedure AddColumn(Value: Variant; IsFormula: Boolean; CommentText: Text[1000]; IsBold: Boolean; IsItalics: Boolean; IsUnderline: Boolean; NumFormat: Text[30]; CellType: Option)
    begin
        if CurrentRow < 1 then
            NewRow();

        CurrentCol := CurrentCol + 1;
        Init();
        Validate("Row No.", CurrentRow);
        Validate("Column No.", CurrentCol);
        if IsFormula then
            SetFormula(Format(Value))
        else
            "Cell Value as Text" := Format(Value);
        Comment := copystr(CommentText, 1, MaxStrLen(Comment));
        Bold := IsBold;
        Italic := IsItalics;
        Underline := IsUnderline;
        NumberFormat := copystr(ConvertCellFormat(NumFormat), 1, MaxStrLen(NumberFormat));
        "Cell Type" := CellType;
        Insert();
    end;

    procedure StartRange()
    var
        TempExcelBuf: Record "EOS02802 Excel Buffer" temporary;
    begin
        TempExcelBuf.Validate("Row No.", CurrentRow);
        TempExcelBuf.Validate("Column No.", CurrentCol);

        RangeStartXlRow := TempExcelBuf.xlRowID;
        RangeStartXlCol := TempExcelBuf.xlColID;
    end;

    procedure EndRange()
    var
        TempExcelBuf: Record "EOS02802 Excel Buffer" temporary;
    begin
        TempExcelBuf.Validate("Row No.", CurrentRow);
        TempExcelBuf.Validate("Column No.", CurrentCol);

        RangeEndXlRow := TempExcelBuf.xlRowID;
        RangeEndXlCol := TempExcelBuf.xlColID;
    end;

    procedure CreateRange(RangeName: Text[250]): Boolean
    begin
        IXLWorksheet.NamedRanges.Add(
          RangeName,
          '=' + GetExcelReference(4) + RangeStartXlCol + GetExcelReference(4) + RangeStartXlRow +
          ':' + GetExcelReference(4) + RangeEndXlCol + GetExcelReference(4) + RangeEndXlRow)
    end;

    procedure AutoFit(RangeName: Text[50])
    begin
        if not IsNull(IXLWorksheet) then
            IXLWorksheet.Columns().AdjustToContents();
    end;

    procedure BorderAround(RangeName: Text[50])
    var
        XLBorderStyleValues: dotnet "EOS XLBorderStyleValues";
    begin
        if not IsNull(XlWrkBk) then
            IXLWorksheet.NamedRange(RangeName).Ranges.Style.Border.OutsideBorder := XLBorderStyleValues.None;
    end;

    procedure ClearNewRow()
    begin
        CurrentRow := 0;
        CurrentCol := 0;
    end;

    procedure SetUseInfoSheet()
    begin
        UseInfoSheet := true;
    end;

    procedure AddInfoColumn(Value: Variant; IsFormula: Boolean; CommentText: Text[1000]; IsBold: Boolean; IsItalics: Boolean; IsUnderline: Boolean; NumFormat: Text[30]; CellType: Option)
    begin
        if CurrentRow < 1 then
            NewRow();

        CurrentCol := CurrentCol + 1;
        InfoExcelBuf.Init();
        InfoExcelBuf.Validate("Row No.", CurrentRow);
        InfoExcelBuf.Validate("Column No.", CurrentCol);
        if IsFormula then
            InfoExcelBuf.SetFormula(Format(Value))
        else
            InfoExcelBuf."Cell Value as Text" := Format(Value);
        InfoExcelBuf.Bold := IsBold;
        InfoExcelBuf.Italic := IsItalics;
        InfoExcelBuf.Underline := IsUnderline;
        InfoExcelBuf.NumberFormat := NumFormat;
        InfoExcelBuf."Cell Type" := CellType;
        InfoExcelBuf.Insert();
    end;


    procedure UTgetGlobalValue(globalVariable: Text[30]; var value: Variant)
    begin
        case globalVariable of
            'CurrentRow':
                value := CurrentRow;
            'CurrentCol':
                value := CurrentCol;
            'RangeStartXlRow':
                value := RangeStartXlRow;
            'RangeStartXlCol':
                value := RangeStartXlCol;
            'RangeEndXlRow':
                value := RangeEndXlRow;
            'RangeEndXlCol':
                value := RangeEndXlCol;
            'ExcelFile':
                value := FileNameServer;
            else
                Error(Text038Err, globalVariable);
        end;
    end;

    procedure SetCurrent(NewCurrentRow: Integer; NewCurrentCol: Integer)
    begin
        CurrentRow := NewCurrentRow;
        CurrentCol := NewCurrentCol;
    end;

    procedure CreateValidationRule(Range: Code[20])
    var
        IXLDataValidation: dotnet "EOS IXLDataValidation";
        IXLNamedRange: dotnet "EOS IXLNamedRange";
        XLAllowedValues: dotnet "EOS XLAllowedValues";
        XLErrorStyle: dotnet "EOS XLErrorStyle";
        XLOperator: dotnet "EOS XLOperator";
    begin
        IXLNamedRange := IXLWorksheet.NamedRange(Range);
        IXLDataValidation := IXLNamedRange.Ranges.SetDataValidation();
        IXLDataValidation.AllowedValues := XLAllowedValues.List;
        IXLDataValidation.ErrorStyle := XLErrorStyle.Stop;
        IXLDataValidation.Operator := XLOperator.EqualTo;
        IXLDataValidation.List(IXLWorksheet.Range(
          '=' + GetExcelReference(4) + RangeStartXlCol + GetExcelReference(4) + RangeStartXlRow +
          ':' + GetExcelReference(4) + RangeEndXlCol + GetExcelReference(4) + RangeEndXlRow));
    end;


    procedure QuitExcel()
    begin
        CloseBook();

        if not IsNull(XlWrkSht) then
            Clear(XlWrkSht);

        if not IsNull(XlWrkBk) then
            Clear(XlWrkBk);

        if not IsNull(XlApp) then begin
            XlHelper.CallQuit(XlApp);
            Clear(XlApp);
        end;
    end;


    procedure OpenExcel()
    var
        FileNameClient: Text;
        NewFilePath: Text;
        directory: Text;
        PathHelper: DotNet Path;
        [RunOnClient]
        DirectoryHelper: DotNet Directory;
        [RunOnClient]
        ClientFileHelper: DotNet File;
        FileDoesNotExistErr: Label 'The file %1 does not exist.', Comment = '%1 File Path';
    begin
        if not PreOpenExcel() then
            exit;

        FileNameClient := FileManagement.DownloadTempFile(FileNameServer);
        //FileNameClient := FileManagement.MoveAndRenameClientFile(FileNameClient, 'Book1.xlsx', Format(CreateGuid()));

        if not ClientFileHelper.Exists(FileNameClient) then
            Error(FileDoesNotExistErr, FileNameClient);

        // Get the directory from the OldFilePath, if directory is empty it will just use the current location.
        directory := FileManagement.GetDirectoryName(FileNameClient);

        // create the sub directory name is name is given
        directory := PathHelper.Combine(directory, Format(CreateGuid()));
        DirectoryHelper.CreateDirectory(directory);

        NewFilePath := PathHelper.Combine(directory, 'Book1.xlsx');
        ClientFileHelper.Copy(FileNameClient, NewFilePath);
        ClientFileHelper.Delete(FileNameClient);

        XlWrkBk := XlHelper.CallOpen(XlApp, FileNameClient);

        PostOpenExcel();
    end;

    procedure OverwriteAndOpenExistingExcel(FileName: Text)
    begin
        if FileName = '' then
            Error(Text001Err);

        if not PreOpenExcel() then
            exit;

        FileManagement.DownloadHandler(FileNameServer, '''', '''', '''', FileName);
        XlWrkBk := XlHelper.CallOpen(XlApp, FileName);

        PostOpenExcel();
    end;

    local procedure PreOpenExcel(): Boolean
    begin
        if not Exists(FileNameServer) then
            Error(Text003Err, FileNameServer);

        if not FileManagement.DownloadHandler(FileNameServer, Text040Lbl, '', Text034Lbl, 'Book1.xlsx') then
            Error(Text001Err);

        exit(false);
    end;

    local procedure PostOpenExcel()
    begin
        XlWrkBk := XlApp.ActiveWorkbook;

        if IsNull(XlWrkBk) then
            Error(Text036Err);

        if not DisableAutoFitColumns then
            XlHelper.AutoFitColumnsInAllWorksheets(XlWrkBk);

        XlHelper.ActivateSheet(XlWrkBk, ActiveSheetName);
    end;


    procedure CreateBookAndOpenExcel(SheetName: Text[250]; ReportHeader: Text[80]; CompanyName: Text[30]; UserID2: Text)
    begin
        CreateBook(SheetName);
        WriteSheet(ReportHeader, CompanyName, UserID2);
        CloseBook();
        OpenExcel();
        GiveUserControl();
    end;

    local procedure UpdateProgressDialog(var ExcelBufferDialogManagement: Codeunit "Excel Buffer Dialog Management"; var LastUpdate: DateTime; CurrentCount: Integer; TotalCount: Integer): Boolean
    var
        CurrentTime: DateTime;
    begin
        CurrentTime := CurrentDatetime;
        if (CurrentCount = TotalCount) or (CurrentTime - LastUpdate >= 1000) then begin
            LastUpdate := CurrentTime;
            ExcelBufferDialogManagement.SetProgress(ROUND(CurrentCount / TotalCount * 10000, 1));
            if not ExcelBufferDialogManagement.Run() then
                exit(false);
        end;

        exit(true)
    end;

    procedure GetExcelColumnCode(ColumnNo: Integer) Result: Text[10]
    var
        c: Char;
        i: Integer;
        x: Integer;
        y: Integer;
        t: Text[30];
    begin
        if ColumnNo = 0 then
            exit('');

        if CacheColumn[ColumnNo] <> '' then
            exit(CacheColumn[ColumnNo]);

        Result := '';

        xlColID := '';
        x := "Column No.";
        while x > 26 do begin
            y := x MOD 26;
            if y = 0 then
                y := 26;
            c := 64 + y;
            i += 1;
            t[i] := c;
            x := (x - y) DIV 26;
        end;
        if x > 0 then begin
            c := 64 + x;
            i += 1;
            t[i] := c;
        end;
        for x := 1 to i do
            Result[x] := t[1 + i - x];

        CacheColumn[ColumnNo] := copystr(Result, 1, 3);
        exit(Result);
    end;


    procedure BuildRange(ULColumn: Integer; ULRow: Integer; BRColumn: Integer; BRRow: Integer): Text[30]
    begin
        if (ULColumn <> 0) and (BRColumn <> 0) and (ULRow <> 0) and (BRRow <> 0) then
            exit(GetExcelColumnCode(ULColumn) + Format(ULRow) + ':' + GetExcelColumnCode(BRColumn) + Format(BRRow));

        if (ULColumn <> 0) and (BRColumn <> 0) and (ULRow = 0) and (BRRow = 0) then
            exit(GetExcelColumnCode(ULColumn) + ':' + GetExcelColumnCode(BRColumn));

        if (ULColumn = 0) and (BRColumn = 0) and (ULRow <> 0) and (BRRow <> 0) then
            exit(Format(ULRow) + ':' + Format(BRRow));

        if (ULColumn = 0) and (BRColumn = 0) and (ULRow = 0) and (BRRow = 0) then
            exit('1:65536');
    end;

    procedure SaveExcelFile(ClientFileName: Text)
    var
    begin
        FileManagement.DownloadHandler(FileNameServer, '''', '''', '''', ClientFileName)
    end;

    procedure ConvertCellFormat(FormatStyle: Text): Text
    var
        String: dotnet String;
    begin
        String := FormatStyle;
        String := String.Replace('[Rosso]', '[Red]');
        exit(String.ToString());
    end;

    procedure GetFirstRowExt(): Boolean
    begin
        Clear(Rec);
        CurrentRecPosition := 0;
        if not FindFirst() then
            exit(false);

        Clear(TempInternalBuffer);
        TempInternalBuffer.DeleteAll();

        SetRange("Row No.", "Row No.");
        if FindSet(false, false) then
            repeat
                TempInternalBuffer.TransferFields(Rec);
                TempInternalBuffer."Row No." := 0;
                TempInternalBuffer.Insert();
                CurrentRecPosition += 1;
            until Next() = 0;

        SetRange("Row No.");
        exit(true);
    end;

    procedure GetNextRowExt(): Boolean
    var
        EmptyExcelBufferLoc: Record "EOS02802 Excel Buffer" temporary;
        CurrRow: Integer;
    begin
        CurrRow := "Row No.";
        Rec.CopyFilters(EmptyExcelBufferLoc);
        SetFilter("Row No.", '>%1', CurrRow);

        Clear(TempInternalBuffer);
        TempInternalBuffer.DeleteAll();

        if not FindFirst() then
            exit(false);

        SetRange("Row No.", "Row No.");

        if FindSet(false, false) then
            repeat
                TempInternalBuffer.TransferFields(Rec);
                TempInternalBuffer."Row No." := 0;
                TempInternalBuffer.Insert();
                CurrentRecPosition += 1;
            until Next() = 0;

        SetRange("Row No.");
        exit(true);
    end;

    procedure GetCellRowValue(Column: Integer): Text
    begin
        if TempInternalBuffer.Get(0, Column) then
            exit(TempInternalBuffer."Cell Value as Text");

        exit('');
    end;

    procedure GetCurrentRowPos(): Integer
    begin
        exit(CurrentRecPosition);
    end;

    procedure GetLastRowExt(): Boolean
    begin
        Clear(Rec);
        CurrentRecPosition := 0;
        if not FindLast() then
            exit(false);

        Clear(TempInternalBuffer);
        TempInternalBuffer.DeleteAll();

        SetRange("Row No.", "Row No.");
        if FindSet(false, false) then
            repeat
                TempInternalBuffer.TransferFields(Rec);
                TempInternalBuffer."Row No." := 0;
                TempInternalBuffer.Insert();
                CurrentRecPosition += 1;
            until Next() = 0;

        SetRange("Row No.");
        exit(true);
    end;

    procedure GetTotalRowNo(): Integer
    begin
        Clear(Rec);

        if not FindLast() then
            exit(0);

        exit("Row No.");
    end;

    procedure AddRecord(Column: Integer; Row: Integer; Text: Text[1000]; AutoInsert: Boolean; Bold2: Boolean; Italic2: Boolean; UnderLine2: Boolean)
    var
        DateValue: Date;
        DecimalValue: Decimal;
        TimeValue: Time;
    begin
        Init();
        Validate("Column No.", Column);

        Validate("Row No.", Row);
        Validate("Cell Value as Text", CopyStr(Text, 1, MaxStrLen("Cell Value as Text")));
        Validate(Bold, Bold2);
        Validate(Italic, Italic2);
        Validate(Underline, UnderLine2);

        if Evaluate(DecimalValue, Text) then
            "Cell Type" := "cell type"::Number
        else
            if Evaluate(DateValue, Text) then
                "Cell Type" := "cell type"::Date
            else
                if Evaluate(TimeValue, Text) then
                    "Cell Type" := "cell type"::Time
                else
                    "Cell Type" := "cell type"::Text;

        if AutoInsert then
            Insert(true);
    end;

    procedure SetNewColumnEntry(ID: Code[10]; ColumnNo: Integer; DefaultBold: Boolean; DefaultItalic: Boolean; DefaultUnderline: Boolean)
    begin
        ColumnEntityID[ColumnNo] := ID;
        ColumnEntityDefaults[ColumnNo, 1] := DefaultBold;
        ColumnEntityDefaults[ColumnNo, 2] := DefaultItalic;
        ColumnEntityDefaults[ColumnNo, 3] := DefaultUnderline;
        if MaxColumnEntityID < ColumnNo then
            MaxColumnEntityID := ColumnNo;
    end;

    procedure SetHeader(Value: Boolean)
    begin
    end;

    procedure NewLine()
    begin
        IntLineNo += 1;
    end;


    procedure AddNewCell(ColumnID: Code[10]; TextValue: Text[1024])
    var
        ColumnNo: Integer;
    begin
        ColumnNo := ResolveColumnEntityID(ColumnID);

        if ColumnNo = -1 then
            Error(TextRSA002Err, ColumnID);

        if IntLineNo = 0 then
            IntLineNo := 1;

        AddRecord(ColumnNo, IntLineNo,
                  copystr(TextValue, 1, 1000),
                  true,
                  ColumnEntityDefaults[ColumnNo, 1] or isHeader,
                  ColumnEntityDefaults[ColumnNo, 2],
                  ColumnEntityDefaults[ColumnNo, 3]);
    end;

    local procedure ResolveColumnEntityID(EntityID: Code[10]): Integer
    var
        i: Integer;
    begin
        for i := 1 to MaxColumnEntityID do
            if ColumnEntityID[i] = EntityID then
                exit(i);
        exit(-1);
    end;


    procedure SetFormatCellRange(ULColumn: Integer; ULRow: Integer; BRColumn: Integer; BRRow: Integer; NumberFormat: Text; CellType: Option)
    var
        ExcelLoc: Record "EOS02802 Excel Buffer" temporary;
        Column: Integer;
        Row: Integer;
        IXLCell: dotnet "EOS IXLCell";
        XLCellValues: dotnet "EOS XLCellValues";
    begin
        if not ExcelSheetCreated then begin
            NumberFormat := ConvertCellFormat(NumberFormat);

            ExcelLoc.Copy(Rec, true);

            ExcelLoc.SetRange("Row No.", ULRow, BRRow);
            ExcelLoc.SetRange("Column No.", ULColumn, BRColumn);
            ExcelLoc.ModifyAll(NumberFormat, NumberFormat);
            if CellType <> -1 then
                ExcelLoc.ModifyAll("Cell Type", CellType);

            if ("Row No." in [ULRow, BRRow]) and
               ("Column No." in [ULColumn, BRColumn]) then
                if not Find('=') then begin
                    NumberFormat := NumberFormat;
                    if CellType <> -1 then
                        "Cell Type" := CellType;
                end;
        end else
            for Column := ULColumn to BRColumn do
                for Row := ULRow to BRRow do begin
                    IXLCell := IXLWorksheet.Cell(Row, Column);
                    case "Cell Type" of
                        "cell type"::Number:
                            begin
                                IXLCell.DataType := XLCellValues.Number;
                                IXLCell.Style.NumberFormat.SetFormat(NumberFormat);
                            end;
                        "cell type"::Date:
                            begin
                                IXLCell.DataType := XLCellValues.DateTime;
                                IXLCell.Style.DateFormat.SetFormat(NumberFormat);
                            end;
                        "cell type"::Time:
                            begin
                                IXLCell.DataType := XLCellValues.TimeSpan;
                                IXLCell.Value := "Cell Value as Text";
                            end
                    end;
                end;
    end;

    procedure AddNewSheet(SheetName: Text)
    begin
        XLWorkbook.AddWorksheet(SheetName);
        ExcelSheetCreated := false;
        UseInfoSheet := false;
    end;


    procedure DeleteSheetName(SheetName: Text[50])
    begin
        IXLWorksheet := XLWorkbook.Worksheet(SheetName);
        IXLWorksheet.Delete();
    end;


    procedure SetWrappedText(ULColumn: Integer; ULRow: Integer; BRColumn: Integer; BRRow: Integer)
    var
        Column: Integer;
        Row: Integer;
        IXLAlignment: dotnet "EOS IXLAlignment";
        IXLCell: dotnet "EOS IXLCell";
    begin
        for Column := ULColumn to BRColumn do
            for Row := ULRow to BRRow do begin
                IXLCell := IXLWorksheet.Cell(Row, Column);
                IXLAlignment := IXLCell.Style.Alignment;
                IXLAlignment.SetWrapText(true);
            end;
    end;


    procedure SetDisableAutoFitColumns(Set: Boolean)
    begin
        DisableAutoFitColumns := Set;
    end;


    procedure SetFontAlignmentCellRange(ULColumn: Integer; ULRow: Integer; BRColumn: Integer; BRRow: Integer; HFontAlignment: Option " ",Left,Center,Right; VFontAlignment: Option " ",Top,Center,Bottom)
    var
        Column: Integer;
        Row: Integer;
        IXLAlignment: dotnet "EOS IXLAlignment";
        IXLCell: dotnet "EOS IXLCell";
        XLAlignmentHorizontalValues: dotnet "EOS XLAlignmentHorizontalValues";
        XLAlignmentVerticalValues: dotnet "EOS XLAlignmentVerticalValues";
    begin
        for Column := ULColumn to BRColumn do
            for Row := ULRow to BRRow do begin
                IXLCell := IXLWorksheet.Cell(Row, Column);
                IXLAlignment := IXLCell.Style.Alignment;

                case HFontAlignment of
                    Hfontalignment::Left:
                        IXLAlignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
                    Hfontalignment::Center:
                        IXLAlignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                    Hfontalignment::Right:
                        IXLAlignment.SetHorizontal(XLAlignmentHorizontalValues.Right);
                end;

                case VFontAlignment of
                    Vfontalignment::Top:
                        IXLAlignment.SetVertical(XLAlignmentVerticalValues.Top);
                    Vfontalignment::Center:
                        IXLAlignment.SetVertical(XLAlignmentVerticalValues.Center);
                    Vfontalignment::Bottom:
                        IXLAlignment.SetVertical(XLAlignmentVerticalValues.Bottom);
                end;
            end;
    end;

    procedure SetColumnWidth(ULColumn: Integer; BRColumn: Integer; Width: Integer)
    var
        IXLColumns: dotnet "EOS IXLColumns";
    begin
        IXLColumns := IXLWorksheet.Columns(ULColumn, BRColumn);
        IXLColumns.Width := Width;
    end;

    procedure SetRowWidth(ULRow: Integer; BRRow: Integer; Height: Integer)
    var
        IXLRows: dotnet "EOS IXLRows";
    begin
        IXLRows := IXLWorksheet.Rows(ULRow, BRRow);
        IXLRows.Height := Height;
    end;

    procedure DeleteDefaultSheets()
    begin
    end;

    /// <summary>
    /// Set the parameter to true to hide dialogs.
    /// </summary>
    /// <param name="Hide_Dialog"></param>
    procedure SetHideDialog(Hide_Dialog: Boolean)
    begin
        HideDialog := Hide_Dialog;
    end;
}

