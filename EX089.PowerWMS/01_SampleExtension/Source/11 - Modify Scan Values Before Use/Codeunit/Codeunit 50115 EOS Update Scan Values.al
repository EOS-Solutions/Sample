codeunit 50115 "EOS Update Scan Values"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Task Mgmt.", OnReadArrayOnAfterParametersManagement, '', false, false)]
    local procedure CU18060020_OnReadArrayOnAfterParametersManagement(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; JsonObject: JsonObject; LineAction: Enum "EOS089 WMS Scan Action"; var EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan")
    begin
        if EOS089WMSActivityScan.Type <> EOS089WMSActivityScan.Type::EOSHandlingUnit then
            exit;

        if StrPos(EOS089WMSActivityScan."EOS Handling Unit No.", 'HU|') <> 1 then
            exit;

        EOS089WMSActivityScan."EOS Handling Unit No." := CopyStr(EOS089WMSActivityScan."EOS Handling Unit No.", 4);
    end;
}
