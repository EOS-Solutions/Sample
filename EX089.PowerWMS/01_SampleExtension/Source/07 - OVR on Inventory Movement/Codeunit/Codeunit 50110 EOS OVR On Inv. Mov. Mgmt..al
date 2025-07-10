codeunit 50110 "EOS OVR On Inv. Mov. Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS OVR Mgmt.", OnCalculateOverdeliveryQuantitiesForSourceLine, '', false, false)]
    local procedure CU18060053_OnCalculateOverdeliveryQuantitiesForSourceLine(SourceLine: Variant; var OverOrUnderQtyManagement: Boolean; var MaxOutstandingQuantity: Decimal; var MaxOutstandingQuantityActual: Decimal)
    var
        WarehouseActivityLine: Record "Warehouse Activity Line";
        RecordRef: RecordRef;
        TableNo: Integer;
    begin
        case true of
            SourceLine.IsRecord():
                begin
                    RecordRef.GetTable(SourceLine);
                    TableNo := RecordRef.Number;
                end;
            SourceLine.IsRecordId():
                begin
                    RecordRef.Get(SourceLine);
                    TableNo := RecordRef.Number;
                end;
            SourceLine.IsRecordRef():
                begin
                    RecordRef := SourceLine;
                    TableNo := RecordRef.Number;
                end;
            else
                exit;
        end;

        if TableNo <> Database::"Warehouse Activity Line" then
            exit;
        RecordRef.SetTable(WarehouseActivityLine);

        if WarehouseActivityLine."Activity Type" <> WarehouseActivityLine."Activity Type"::"Invt. Movement" then
            exit;

        OverOrUnderQtyManagement := true;
        MaxOutstandingQuantity := 999999999;
        MaxOutstandingQuantityActual := 999999999;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Whse.Inv.Mov. Impl.", OnGetRecordRefForScanManagementOnBeforeFindSet, '', false, false)]
    local procedure CU18060060_OnGetRecordRefForScanManagementOnBeforeFindSet(var WarehouseActivityLine: Record "Warehouse Activity Line"; EOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail")
    var
        WarehouseActivityLine2: Record "Warehouse Activity Line";
        WhseLinesView: Text;
    begin
        if WarehouseActivityLine.IsEmpty() then
            exit; // No records to process

        WhseLinesView := WarehouseActivityLine.GetView(false);

        if WarehouseActivityLine.FindSet() then
            repeat
                if WarehouseActivityLine."Qty. Outstanding (Base)" < EOS089WMSActScanDetail."Quantity (Base)" then begin
                    // Update both take and place lines!
                    WarehouseActivityLine2.Get(WarehouseActivityLine."Activity Type", WarehouseActivityLine."No.", WarehouseActivityLine."EOS WMS Take Line No.");
                    WarehouseActivityLine2.Validate("Qty. (Base)", WarehouseActivityLine2."Qty. (Base)" + (EOS089WMSActScanDetail."Quantity (Base)" - WarehouseActivityLine."Qty. Outstanding (Base)"));
                    WarehouseActivityLine2.Validate("Qty. to Handle", 0);
                    WarehouseActivityLine2.Modify(true);

                    WarehouseActivityLine.Validate("Qty. (Base)", WarehouseActivityLine."Qty. (Base)" + (EOS089WMSActScanDetail."Quantity (Base)" - WarehouseActivityLine."Qty. Outstanding (Base)"));
                    WarehouseActivityLine.Validate("Qty. to Handle", 0);
                    WarehouseActivityLine.Modify(true);
                    exit;
                end;
            until WarehouseActivityLine.Next() = 0;

        WarehouseActivityLine.Reset();
        WarehouseActivityLine.SetView(WhseLinesView);
    end;
}
