codeunit 50002 "EOS MES Rep. Event Handler"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reporting Triggers", 'SubstituteReport', '', true, false)]
    local procedure SubstituteReports(ReportId: Integer; var NewReportId: Integer)
    var
        EOS070MESSetup: Record "EOS 070 MES Setup";
        EOS070MESReporPublicEvent: Codeunit "EOS 070 MES Repor.Public Event";
        isHandled: Boolean;
    begin
        EOS070MESSetup.Get();

        EOS070MESReporPublicEvent.OnBeforeGetReportDetCalc(ReportId, NewReportId, isHandled);
        if not isHandled then
            if (ReportId = Report::"Prod. Order - Detailed Calc.") and (EOS070MESSetup."Barcode Generation Method" = Enum::"EOS 070 MES Barcode Method"::OnPrem) then 
            begin
                NewReportId := Report::"EOS 070 MES ProdOrderDetCalc";
            end;
        EOS070MESReporPublicEvent.OnAfterGetReportDetCalc(ReportId, NewReportId);

        isHandled := false;

        EOS070MESReporPublicEvent.OnBeforeGetReportJobCard(ReportId, NewReportId, isHandled);
        if not isHandled then
            if (ReportId = Report::"Prod. Order - Job Card") and (EOS070MESSetup."Barcode Generation Method" = Enum::"EOS 070 MES Barcode Method"::OnPrem) then 
            begin
                NewReportId := Report::"EOS 070 MES ProdOrderJobCard";
            end;
        EOS070MESReporPublicEvent.OnAfterGetReportJobCard(ReportId, NewReportId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS070 MES Report EventHandler", 'SubstituteReport', '', false, false)]
    local procedure SubstituteReportMESSetup(ReportId: Integer; var NewReportId: Integer)
    var
        EOS070MESSetup: Record "EOS 070 MES Setup";
        EOS070MESReporPublicEvent: Codeunit "EOS 070 MES Repor.Public Event";
        isHandled: Boolean;
    begin
        EOS070MESSetup.Get();
        EOS070MESReporPublicEvent.OnBeforeGetReportEmployeeBadge(ReportId, NewReportId, isHandled);
        if not isHandled then
            if (ReportId = Report::"EOS 07000 MES Employee Badge") and (EOS070MESSetup."Barcode Generation Method" = Enum::"EOS 070 MES Barcode Method"::OnPrem) then 
            begin
                NewReportId := Report::"EOS 070 MES Employee Badge";
            end;
        EOS070MESReporPublicEvent.OnAfterGetReportEmployeeBadge(ReportId, NewReportId);

        isHandled := false;

        EOS070MESReporPublicEvent.OnBeforeGetReportBarcodeReason(ReportId, NewReportId, isHandled);
        if not isHandled then
            if (ReportId = Report::"EOS 07000 MES Barcode Reason") and (EOS070MESSetup."Barcode Generation Method" = Enum::"EOS 070 MES Barcode Method"::OnPrem) then 
            begin
                NewReportId := Report::"EOS 070 MES Barcode Reason";
            end;
        EOS070MESReporPublicEvent.OnAfterGetReportBarcodeReason(ReportId, NewReportId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS070 MES Report EventHandler", 'OnBeforeGetFontBarcode', '', false, false)]
    local procedure OnBeforeGetFontBarcode(BarcodeMethod: Enum "EOS 070 MES Barcode Method"; BarcodeTypeOpt: Enum "EOS 070 MES Barcode Type"; var FontName: Text; var isHandled: Boolean)
    begin
        if (BarcodeMethod = Enum::"EOS 070 MES Barcode Method"::OnPrem) then
            begin
                isHandled := true
            end;
    end;

}