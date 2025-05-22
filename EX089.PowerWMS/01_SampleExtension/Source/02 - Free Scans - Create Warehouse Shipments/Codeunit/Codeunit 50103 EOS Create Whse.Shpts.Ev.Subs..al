codeunit 50103 "EOS Create Whse.Shpts.Ev.Subs."
{
    // Init Tracking Fields
    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnBeforeInsertEvent, '', false, false)]
    local procedure T18060040_OnBeforeInsertEvent(var Rec: Record "EOS089 WMS Custom Act. Header"; RunTrigger: Boolean)
    begin
        if Rec."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateWhseShipments then
            exit;

        Rec."Item Ledger Entry Type" := Rec."Item Ledger Entry Type"::Sale;
        Rec.Inbound := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Task Mgmt.", OnFilterActivityScanParametersOnBeforeHandle, '', false, false)]
    local procedure CU18060020_OnFilterActivityScanParametersOnBeforeHandle(EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan"; var TempEOS089WMSActivityScan: Record "EOS089 WMS Activity Scan" temporary)
    begin
        TempEOS089WMSActivityScan.SetRange("Scan Document No.", EOS089WMSActivityScan."Scan Document No.");
    end;
}
