dotnet
{
    assembly("ClosedXML")
    {

        Culture = 'neutral';
        //PublicKeyToken = 'fd1eb21b62ae805b';
        Version = "0.95.3.0";

        type("ClosedXML.Excel.XLWorkbook"; "EOS XLWorkbook") { }
        type("ClosedXML.Excel.IXLWorksheets"; "EOS IXLWorksheets") { }
        type("ClosedXML.Excel.IXLWorksheet"; "EOS IXLWorksheet") { }
        type("ClosedXML.Excel.IXLRange"; "EOS IXLRange") { }
        type("ClosedXML.Excel.IXLStyle"; "EOS IXLStyle") { }
        type("ClosedXML.Excel.XLEventTracking"; "EOS XLEventTracking") { }
        type("ClosedXML.Excel.XLPageOrientation"; "EOS XLPageOrientation") { }
        type("ClosedXML.Excel.IXLCell"; "EOS IXLCell") { }
        type("ClosedXML.Excel.XLDataType"; "EOS XLCellValues") { }
        type("ClosedXML.Excel.XLBorderStyleValues"; "EOS XLBorderStyleValues") { }
        type("ClosedXML.Excel.IXLNumberFormat"; "EOS IXLNumberFormat") { }
        type("ClosedXML.Excel.IXLDataValidation"; "EOS IXLDataValidation") { }
        type("ClosedXML.Excel.IXLNamedRange"; "EOS IXLNamedRange") { }
        type("ClosedXML.Excel.XLAllowedValues"; "EOS XLAllowedValues") { }
        type("ClosedXML.Excel.XLErrorStyle"; "EOS XLErrorStyle") { }
        type("ClosedXML.Excel.XLOperator"; "EOS XLOperator") { }
        type("ClosedXML.Excel.IXLAlignment"; "EOS IXLAlignment") { }
        type("ClosedXML.Excel.IXLCells"; "EOS IXLCells") { }
        type("ClosedXML.Excel.IXLFont"; "EOS IXLFont") { }
        type("ClosedXML.Excel.XLAlignmentHorizontalValues"; "EOS XLAlignmentHorizontalValues") { }
        type("ClosedXML.Excel.XLAlignmentVerticalValues"; "EOS XLAlignmentVerticalValues") { }
        type("ClosedXML.Excel.XLFontVerticalTextAlignmentValues"; "EOS XLFontVerticalTextAlignmentValues") { }
        type("ClosedXML.Excel.IXLColumns"; "EOS IXLColumns") { }
        type("ClosedXML.Excel.IXLRows"; "EOS IXLRows") { }
    }
    assembly("Microsoft.Office.Interop.Excel")
    {

        Culture = 'neutral';
        PublicKeyToken = '71e9bce111e9429c';
        Version = "15.0.0.0";

        type("Microsoft.Office.Interop.Excel.ApplicationClass"; "EOS ApplicationClass2") { }
        type("Microsoft.Office.Interop.Excel.Workbook"; "EOS Workbook2") { }
        type("Microsoft.Office.Interop.Excel.Worksheet"; "EOS Worksheet2") { }
        type("Microsoft.Office.Interop.Excel.Range"; "EOS Range") { }
        type("Microsoft.Office.Interop.Excel.Window"; "EOS Window") { }
        type("Microsoft.Office.Interop.Excel.Hyperlink"; "EOS Hyperlink") { }
        type("Microsoft.Office.Interop.Excel.PivotTable"; "EOS PivotTable") { }
        type("Microsoft.Office.Interop.Excel.XmlMap"; "EOS XmlMap") { }
        type("Microsoft.Office.Interop.Excel.XlXmlImportResult"; "EOS XlXmlImportResult") { }
        type("Microsoft.Office.Interop.Excel.XlXmlExportResult"; "EOS XlXmlExportResult") { }
        type("Microsoft.Office.Interop.Excel.ProtectedViewWindow"; "EOS ProtectedViewWindow") { }
        type("Microsoft.Office.Interop.Excel.XlProtectedViewCloseReason"; "EOS XlProtectedViewCloseReason") { }
        type("Microsoft.Office.Interop.Excel.Chart"; "EOS Chart") { }
    }
    assembly("Microsoft.Dynamics.Nav.Integration.Office")
    {
        Version = "17.0.0.0";
        Culture = "neutral";
        PublicKeyToken = "31bf3856ad364e35";
        type(Microsoft.Dynamics.Nav.Integration.Office.Excel.ExcelHelper; "EOS excelhelp")
        {

        }
    }
    assembly(mscorlib)
    {
        type(System.IO.File; "EOS SystemIOFile") { }
        type(System.IO.Path; "EOS SystemIOPath") { }
        type(System.IO.MemoryStream; "EOS SystemIOMemoryStream") { }
    }
}

Codeunit 50000 "EOS02802 CFG Excel Mgt."
{
    trigger OnRun()
    begin

    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS028 CFG Excel", 'GetResult', '', false, false)]
    local procedure C18091280_GetResult(Ins: InStream; var TempExcelBufResult: Record "Excel Buffer" temporary; var IsHandled: Boolean; SheetName: Text)
    var
        ExcelBuf: Record "EOS02802 Excel Buffer";
    begin
        ExcelBuf.DeleteAll();
        ExcelBuf.LockTable();
        ExcelBuf.OpenBookStream('', SheetName, Ins);
        ExcelBuf.ReadSheet();

        if ExcelBuf.FindSet() then begin
            IsHandled := true;

            repeat
                InsertStdExcelBuffer(TempExcelBufResult, ExcelBuf);
            until ExcelBuf.Next() = 0;
        end;
    end;

    local procedure InsertStdExcelBuffer(var TempExcelBufResult: Record "Excel Buffer" temporary; ExcelBuf: Record "EOS02802 Excel Buffer")
    begin
        with TempExcelBufResult do begin
            init();
            "Row No." := ExcelBuf."Row No.";
            xlRowID := ExcelBuf.xlRowID;
            "Column No." := ExcelBuf."Column No.";
            xlColID := ExcelBuf.xlColID;
            "Cell Value as Text" := CopyStr(ExcelBuf."Cell Value as Text", 1, MaxStrLen(TempExcelBufResult."Cell Value as Text"));
            Comment := ExcelBuf.Comment;
            Formula := ExcelBuf.Formula;
            Bold := ExcelBuf.Bold;
            Italic := ExcelBuf.Italic;
            Underline := ExcelBuf.Underline;
            NumberFormat := ExcelBuf.NumberFormat;
            Formula2 := ExcelBuf.Formula2;
            Formula3 := ExcelBuf.Formula3;
            Formula4 := ExcelBuf.Formula4;
            "Cell Type" := ExcelBuf."Cell Type";
            Insert();
        end;
    end;
}