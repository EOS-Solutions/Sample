/// <summary>Codeunit that allow you to modify codes</summary>
codeunit 50001 "EOS 070 MES Repor.Public Event"
{
    trigger OnRun()
    begin

    end;

    /// <summary>This function is used in Codeunit MES Reporting.If custom Barcode type are added, use this function to encode it Example DataMatrix</summary>
    /// <param name="BarcodeEncoder">DLL use to encode</param>
    /// <param name="BarcodeString">String to convert</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGetBarcode(BarcodeEncoder: dotnet "EOS BarcodeEconder"; var BarcodeString: Text)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    /// <param name="isHandled">if true, no following app code will be executed</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGetReportEmployeeBadge(ReportId: Integer; var NewReportId: Integer; var isHandled: Boolean)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetReportEmployeeBadge(ReportId: Integer; var NewReportId: Integer)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    /// <param name="isHandled">if true, no following app code will be executed</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGetReportBarcodeReason(ReportId: Integer; var NewReportId: Integer; var isHandled: Boolean)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetReportBarcodeReason(ReportId: Integer; var NewReportId: Integer)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    /// <param name="isHandled">if true, no following app code will be executed</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGetReportDetCalc(ReportId: Integer; var NewReportId: Integer; var isHandled: Boolean)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetReportDetCalc(ReportId: Integer; var NewReportId: Integer)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    /// <param name="isHandled">if true, no following app code will be executed</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeGetReportJobCard(ReportId: Integer; var NewReportId: Integer; var isHandled: Boolean)
    begin
    end;

    /// <summary>
    /// This function is used in Codeunit MES Rep. Event Handler. Allow you to modify NewReportId before report processing.
    /// </summary>
    /// <param name="ReportId">Id of the base report</param>
    /// <param name="NewReportId">Record to modify</param>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetReportJobCard(ReportId: Integer; var NewReportId: Integer)
    begin
    end;
}
