codeunit 50000 "EOS CWS Subscriber Examples"
{
    // [SCENARIO] Add Sales Line - Item No. as field for grouping criteria
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS CWS Comb. Criteria Mgmt.", 'OnAfterAddStandardFields', '', true, false)]
    local procedure C_CWSCombCriteriaMgmt_OnAfterAddStandardFields(TableId: Integer; var TmpField: Record Field)
    var
        SalesLine: record "Sales Line";
        PurchaseLine: record "Sales Line";
        TransferLine: record "Transfer Line";
        ServiceLine: record "Service Line";
    begin
        if TableId = Database::"Sales Header" then begin
            TmpField.Init();
            TmpField.TableNo := Database::"Sales Line";
            TmpField."No." := SalesLine.FieldNo(SalesLine."No.");
            TmpField."Field Caption" := CopyStr(SalesLine.Fieldcaption("No."), 1, MaxStrLen(TmpField."Field Caption"));
            if not TmpField.Insert() then;

            TmpField.Init();
            TmpField.TableNo := Database::"Sales Line";
            TmpField."No." := SalesLine.FieldNo(SalesLine."EOS Group No.");
            TmpField."Field Caption" := CopyStr(SalesLine.Fieldcaption("EOS Group No."), 1, MaxStrLen(TmpField."Field Caption"));
            if not TmpField.Insert() then;
        end;
        if TableId = Database::"Purchase Header" then begin
            TmpField.Init();
            TmpField.TableNo := Database::"Purchase Line";
            TmpField."No." := PurchaseLine.FieldNo(PurchaseLine."No.");
            TmpField."Field Caption" := CopyStr(PurchaseLine.Fieldcaption("No."), 1, MaxStrLen(TmpField."Field Caption"));
            if not TmpField.Insert() then;
        end;
        if TableId = Database::"Transfer Header" then begin
            TmpField.Init();
            TmpField.TableNo := Database::"Transfer Line";
            TmpField."No." := TransferLine.FieldNo(TransferLine."Item No.");
            TmpField."Field Caption" := CopyStr(TransferLine.Fieldcaption("Item No."), 1, MaxStrLen(TmpField."Field Caption"));
            if not TmpField.Insert() then;
        end;
        if TableId = Database::"Service Header" then begin
            TmpField.Init();
            TmpField.TableNo := Database::"Service Line";
            TmpField."No." := ServiceLine.FieldNo(ServiceLine."No.");
            TmpField."Field Caption" := CopyStr(ServiceLine.Fieldcaption("No."), 1, MaxStrLen(TmpField."Field Caption"));
            if not TmpField.Insert() then;
        end;
    end;

    // [SCENARIO] Page Warehouse Shipment - Action Groups: always open List Page and not directly Info if possible
    [EventSubscriber(ObjectType::Page, Page::"Warehouse Shipment", 'EOSOnBeforeOpenGroups', '', true, false)]
    local procedure P_WarehouseShipment_EOSOnBeforeOpenGroups(var AlwaysOpenPageList: Boolean)
    begin
        AlwaysOpenPageList := true;
    end;

    // [SCENARIO] Assign Custom No. to CWS Shipment
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS CWS Shipment Mgmt", 'OnBeforeGetHeaderNoSeries', '', true, false)]
    local procedure C_CWSShipmentMgmt_OnBeforeGetHeaderNoSeries(PostedSourceDocumentType: Enum "EOS CWS Posted Source Document"; PostedSourceDocumentNo: Code[20]; ReferenceDate: Date; var ShippingNo: Code[20]; var ShippingNoSeries: Code[20]; var IsHandled: Boolean)
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if PostedSourceDocumentType = PostedSourceDocumentType::"Posted Shipment" then begin
            SalesShipmentHeader.Get(PostedSourceDocumentNo);
            if SalesShipmentHeader."Sell-to Customer No." = '20000' then begin
                ShippingNoSeries := 'W-SHIP-20000';
                ShippingNo := NoSeriesMgt.GetNextNo(ShippingNoSeries, ReferenceDate, true);
                IsHandled := true;
            end;
        end;

    end;

    // [SCENARIO] Custom Message Whse. Post Shipment
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS CWS Shipment Mgmt", 'OnBeforeConfirmWhseShipmentPost', '', true, false)]
    local procedure C_CWSShipmentMgmt_OnBeforeConfirmWhseShipmentPost(var WhseShptLine: Record "Warehouse Shipment Line"; var HideDialog: Boolean; var Invoice: Boolean; var IsPosted: Boolean)
    var
        ShipInvoiceQst: Label '&Ship and Invoice for %1 %2?';
    begin
        with WhseShptLine do begin
            if "Source Document" = "Source Document"::"Sales Order" then begin
                if "Destination No." = '20000' then begin
                    if not Confirm(StrSubstNo(ShipInvoiceQst, "Destination Type", "Destination No.")) then begin
                        IsPosted := true;
                        exit;
                    end;
                    Invoice := true;
                    HideDialog := true;
                end;
            end;
        end;
    end;

    // [SCENARIO] Set Invoicing buffer in  Whse. Post Shipment
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS CWS Shipment Mgmt", 'OnAfterConfirmWhseShipmentPost', '', true, false)]
    local procedure C_CWSShipmentMgmt_OnAfterConfirmPost(WhseShipmentLine: Record "Warehouse Shipment Line"; Invoice: Boolean; var TempInvoicingCodeBuffer: Record "EOS CWS Invoicing Code Buffer")
    var
        ShipInvoiceQst: Label '&Ship and Invoice for %1 %2?';
    begin
        if Invoice then begin
            with WhseShipmentLine do begin
                if "Destination No." = '20000' then begin
                    if not TempInvoicingCodeBuffer.Get(TempInvoicingCodeBuffer.Type::Outbound
                                                        , TempInvoicingCodeBuffer."Source Document"::"Sales Order"
                                                        , TempInvoicingCodeBuffer."Destination Type"::Customer
                                                        , "Destination No.") then begin
                        TempInvoicingCodeBuffer.Init();
                        TempInvoicingCodeBuffer."Source Document" := TempInvoicingCodeBuffer."Source Document"::"Sales Order";
                        TempInvoicingCodeBuffer."Destination Type" := TempInvoicingCodeBuffer."Destination Type"::Customer;
                        TempInvoicingCodeBuffer."Destination No." := "Destination No.";
                        TempInvoicingCodeBuffer."Create Invoice" := true;
                        TempInvoicingCodeBuffer.Insert();
                    end;
                end;
            end;
        end;
    end;

    // [SCENARIO] Combine Shipment in Whse. Post Shipment: custom criteria
    [EventSubscriber(ObjectType::Report, Report::"EOS CWS Comb. Sales Shipments", 'OnAfterShouldFinalizeSalesInvHeader', '', true, false)]
    local procedure R_CombSalesShipments_OnAfterShouldFinalizeSalesInvHeader(SalesHeader: Record "Sales Header"; SalesShipmentHeader: Record "Sales Shipment Header"; var ShipmentHeader: Record "EOS CWS Shipment Header"; var Finalize: Boolean)
    begin
        Finalize :=
          (ShipmentHeader."No." <> SalesHeader."EOS Shipment No.") or
          (ShipmentHeader."Destination No." <> SalesHeader."Sell-to Customer No.") or
          (SalesShipmentHeader."Bill-to Customer No." <> SalesHeader."Bill-to Customer No.") or
          (SalesShipmentHeader."Currency Code" <> SalesHeader."Currency Code") or
          (SalesShipmentHeader."EU 3-Party Trade" <> SalesHeader."EU 3-Party Trade") or
          //(SalesShipmentHeader."Dimension Set ID" <> SalesHeader."Dimension Set ID") or
          (SalesShipmentHeader."Payment Terms Code" <> SalesHeader."Payment Terms Code") or
          (SalesShipmentHeader."Payment Method Code" <> SalesHeader."Payment Method Code");
    end;
}