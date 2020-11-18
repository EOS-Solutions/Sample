codeunit 50001 "EOS EX050 Event Subscriber"
{
    // Add the field in the list as mandatory
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Invoicing Management", 'AddRequiredFieldManagement', '', true, false)]
    local procedure InvoicingManagement_AddRequiredFieldManagement(var TmpField: Record Field)
    var
        SalesShptHeader: Record "Sales Shipment Header";
        InvManagement: Codeunit "EOS Invoicing Management";
    begin
        InvManagement.AddField(TmpField, DATABASE::"Sales Shipment Header", SalesShptHeader.FieldNo("Operation Type"));
    end;

    /*   [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Invoicing Management", 'AddCustomFieldManagement', '', true, false)]
    // Add the field in the list (not mandatory)
    local procedure InvoicingManagement_AddCustomFieldManagement(var TmpField: Record Field)
    var
        SalesShptHeader: Record "Sales Shipment Header";
        InvManagement: Codeunit "EOS Invoicing Management";
    begin
        InvManagement.AddField(TmpField, DATABASE::"Sales Shipment Header", SalesShptHeader.FieldNo("Operation Type"));
    end;*/

    [EventSubscriber(ObjectType::Report, Report::"EOS Combine Shipments", 'OnInsertSalesInvHeaderFields', '', true, false)]
    local procedure CombineShipments_OnInsertSalesInvHeaderFields(var SalesInvHeader: Record "Sales Header"; SalesOrderHeader: Record "Sales Header")
    begin
        with SalesInvHeader do begin
            Validate("Bank Account", SalesOrderHeader."Bank Account");
            Validate("Operation Type", SalesOrderHeader."Operation Type");
            Validate("Activity Code", SalesOrderHeader."Activity Code");
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"EOS Combine Shipments", 'onAfter_PopulateHeaderValuesBuffer', '', true, false)]
    local procedure CombineShipments_onAfter_PopulateHeaderValuesBuffer(SalesShptHeader: Record "Sales Shipment Header"; var SalesOrderHeader: Record "Sales Header"; InvMethodCode: Code[10])
    var
        EOSInvoicingManagement: Codeunit "EOS Invoicing Management";
    begin
        if EOSInvoicingManagement.GetFieldValueFromShipment(SalesShptHeader.FieldNo("Operation Type"), InvMethodCode) then
            SalesOrderHeader."Operation Type" := SalesShptHeader."Operation Type";
    end;
}