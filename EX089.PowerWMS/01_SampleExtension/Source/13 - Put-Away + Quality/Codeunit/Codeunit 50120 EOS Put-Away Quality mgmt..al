codeunit 50120 "EOS Put-Away Quality mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Misc. Library", 'OnGetWarehouseActivityLineActualQtyBase', '', false, false)]
    local procedure CU18060048_OnGetWarehouseActivityLineActualQtyBase(WarehouseActivityLine: Record "Warehouse Activity Line"; var ActualQtyBase: Decimal)
    var
        EOSInspectionOrderHeader: Record "EOS Inspection Order Header";
        ControlQuantity: Decimal;
    begin
        EOSInspectionOrderHeader.Reset();
        EOSInspectionOrderHeader.SetRange("Wharehouse Activity No.", WarehouseActivityLine."No.");
        EOSInspectionOrderHeader.SetRange("Wharehouse Activity Line No.", WarehouseActivityLine."Line No.");
        if EOSInspectionOrderHeader.IsEmpty() then
            exit;

        EOSInspectionOrderHeader.FindSet();
        repeat
            ControlQuantity += EOSInspectionOrderHeader.Quantity;
        until EOSInspectionOrderHeader.Next() = 0;

        ActualQtyBase := ControlQuantity * WarehouseActivityLine."Qty. per Unit of Measure";
    end;
}
