codeunit 50122 "EOS WMS Cust.Seq.Scan.Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Task Mgmt.", OnReadArrayOnAfterParametersManagement, '', false, false)]
    local procedure CU18060020_OnReadArrayOnAfterParametersManagement(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; JsonObject: JsonObject; LineAction: Enum "EOS089 WMS Scan Action"; var EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan")
    begin
        if EOS089WMSActivityEntry."Activity Type" = EOS089WMSActivityEntry."Activity Type"::Picking then
            if EOS089WMSActivityScan."Free Text 1" <> '' then
                EOS089WMSActivityScan."New Bin Code" := CopyStr(EOS089WMSActivityScan."Free Text 1", 1, MaxStrLen(EOS089WMSActivityScan."New Bin Code"));
    end;
}
