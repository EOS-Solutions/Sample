codeunit 50108 "EOS Free Text Ev.Subs."
{
    // Init Tracking Fields
    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnBeforeInsertEvent, '', false, false)]
    local procedure T18060040_OnBeforeInsertEvent(var Rec: Record "EOS089 WMS Custom Act. Header"; RunTrigger: Boolean)
    begin
        if Rec."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSFreeText then
            exit;

        Rec."Item Ledger Entry Type" := Rec."Item Ledger Entry Type"::Transfer;
        Rec.Inbound := false;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Custom Act. Mgmt.", OnFilterCustomActivityLinesOnBeforeFind, '', false, false)]
    local procedure CU18060062_OnFilterCustomActivityLinesOnBeforeFind(EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header"; EOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail"; var EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line")
    begin
        if EOS089WMSCustomActHeader."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSFreeText then
            exit;
        EOS089WMSCustomActLine.SetRange("Location Code", EOS089WMSActScanDetail."Location Code");
        EOS089WMSCustomActLine.SetRange("Bin Code", EOS089WMSActScanDetail."Bin Code");
        EOS089WMSCustomActLine.SetRange("Expiration Date", EOS089WMSActScanDetail."Expiration Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Custom Act. Mgmt.", OnBeforeInsertCustomActivityLine, '', false, false)]
    local procedure CU18060062_OnBeforeInsertCustomActivityLine(EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header"; EOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail"; var EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line")
    begin
        if EOS089WMSCustomActHeader."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSFreeText then
            exit;
        EOS089WMSCustomActLine."Free Text 1" := EOS089WMSActScanDetail."Free Text 1";
        EOS089WMSCustomActLine."Free Text 2" := EOS089WMSActScanDetail."Free Text 2";
        EOS089WMSCustomActLine."Free Text 3" := EOS089WMSActScanDetail."Free Text 3";

        EOS089WMSCustomActLine.Validate("Location Code", EOS089WMSActScanDetail."Location Code");
        if EOS089WMSActScanDetail."Bin Code" <> '' then
            EOS089WMSCustomActLine.Validate("Bin Code", EOS089WMSActScanDetail."Bin Code");
        if EOS089WMSActScanDetail."Expiration Date" <> 0D then
            EOS089WMSCustomActLine.Validate("Expiration Date", EOS089WMSActScanDetail."Expiration Date");
    end;
}