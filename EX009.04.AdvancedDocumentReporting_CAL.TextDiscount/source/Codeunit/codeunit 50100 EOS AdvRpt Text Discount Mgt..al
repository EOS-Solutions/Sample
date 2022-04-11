codeunit 50100 "EOS AdvRpt Text Discount Mgt."
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnAfterLineParsing', '', true, false)]
    local procedure OnAfterLineParsing(HeaderRecRef: RecordRef;
                                       CurrentLineRecRef: RecordRef;
                                       var RBHeader: Record "EOS Report Buffer Header";
                                       var RBLine: Record "EOS Report Buffer Line")
    var
        PurchaseLine: Record "Purchase Line";
    begin
        case CurrentLineRecRef.Number() of
            Database::"Sales Line",
            Database::"Sales Invoice Line",
            Database::"Sales Cr.Memo Line",
            Database::"Sales Line Archive":  //gestione avanzata dello sconto composto
                RBLine."EOS Discount Text" := GetAdvDocLineComposedDiscount(CurrentLineRecRef);

            Database::"Sales Shipment Line": //111 non ha il dettaglio sconti composto
                RBLine."EOS Discount Text" := GetFieldValue(CurrentLineRecRef, PurchaseLine.FieldNo("Line Discount %"), 0);

            database::"Purchase Line",
            database::"Purch. Rcpt. Line",
            database::"Purch. Inv. Line",
            database::"Purch. Cr. Memo Line",
            database::"Purchase Line Archive":
                RBLine."EOS Discount Text" := GetFieldValue(CurrentLineRecRef, PurchaseLine.FieldNo("Discount Text"), PurchaseLine.FieldNo("Line Discount %"));

            Database::"Warehouse Shipment Line": //7321 sourceDoc-->discount
                RBLine."EOS Discount Text" := GetDiscTextWarehouseShipmentLine(CurrentLineRecRef);

            Database::"Posted Whse. Shipment Line": //7323 sourceDoc-->discount
                RBLine."EOS Discount Text" := GetDiscTextPostedWhseShipmentLine(CurrentLineRecRef);
        end;
    end;

    local procedure GetAdvDocLineComposedDiscount(RecRef: RecordRef): Text[50]
    var
        DocDiscMgt: Codeunit "Document Discount Management";
    begin
        exit(CopyStr(DelChr(DocDiscMgt.GetDiscountText(RecRef, 2), '<=>', ' '), 1, 50));
    end;

    local procedure GetDiscTextWarehouseShipmentLine(RecRef: RecordRef): Text[50]
    var
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef2: recordref;
    begin
        WarehouseShipmentLine.ChangeCompany(RecRef.CurrentCompany());
        WarehouseShipmentLine.SetPosition(RecRef.GetPosition(false));
        WarehouseShipmentLine.Find('=');
        case WarehouseShipmentLine."Source Subtype" of
            WarehouseShipmentLine."Source Document"::"Sales Order":
                if SalesLine.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.") then begin
                    DataTypeManagement.GetRecordRef(salesline, RecRef2);
                    exit(GetAdvDocLineComposedDiscount(RecRef2));
                end;

            WarehouseShipmentLine."Source Document"::"Purchase Order":
                if PurchaseLine.Get(WarehouseShipmentLine."Source Subtype", WarehouseShipmentLine."Source No.", WarehouseShipmentLine."Source Line No.") then begin
                    DataTypeManagement.GetRecordRef(PurchaseLine, RecRef2);
                    exit(GetFieldValue(RecRef2, PurchaseLine.FieldNo("Discount Text"), PurchaseLine.FieldNo("Line Discount %")));
                end;
        end;
    end;

    local procedure GetDiscTextPostedWhseShipmentLine(RecRef: RecordRef): Text[50]
    var
        PostedWhseShipmentLine: Record "Posted Whse. Shipment Line";
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef2: recordref;

    begin
        PostedWhseShipmentLine.ChangeCompany(RecRef.CurrentCompany());
        PostedWhseShipmentLine.SetPosition(RecRef.GetPosition(false));
        PostedWhseShipmentLine.Find('=');
        case PostedWhseShipmentLine."Source Subtype" of
            PostedWhseShipmentLine."Source Document"::"Sales Order":
                if SalesLine.Get(PostedWhseShipmentLine."Source Subtype", PostedWhseShipmentLine."Source No.", PostedWhseShipmentLine."Source Line No.") then begin
                    DataTypeManagement.GetRecordRef(salesline, RecRef2);
                    exit(GetAdvDocLineComposedDiscount(RecRef2));
                end;

            PostedWhseShipmentLine."Source Document"::"Purchase Order":
                if PurchaseLine.Get(PostedWhseShipmentLine."Source Subtype", PostedWhseShipmentLine."Source No.", PostedWhseShipmentLine."Source Line No.") then begin
                    DataTypeManagement.GetRecordRef(PurchaseLine, RecRef2);
                    exit(GetFieldValue(RecRef2, PurchaseLine.FieldNo("Discount Text"), PurchaseLine.FieldNo("Line Discount %")));
                end;
        end;
    end;

    local procedure GetFieldValue(RecRef: RecordRef; FirstFieldID: Integer; SecondFieldID: Integer) Result: Text[50]
    var
        FieldTable: Record field;
    begin
        FieldTable.Reset();
        FieldTable.SetRange(TableNo, RecRef.Number());
        FieldTable.SetRange(Type, FieldTable.Type::Text);
        FieldTable.SetRange(Enabled, true);
        FieldTable.SetRange(ObsoleteState, FieldTable.ObsoleteState::No);
        FieldTable.SetRange("No.", FirstFieldID);
        if FieldTable.FindFirst() then
            exit(CopyStr(Format(RecRef.field(FieldTable."No.")), 1, 50));

        if SecondFieldID = 0 then
            exit;

        FieldTable.SetRange("No.", SecondFieldID);
        if FieldTable.FindFirst() then
            exit(CopyStr(Format(RecRef.field(FieldTable."No.")), 1, 50));
    end;

}