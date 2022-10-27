/// <summary>
/// This extension adds the "CWS Shipment No." on page "Container Entries (EPM)".
/// The required dependencies, from EOS apps, are "Advanced Logistic Common Library" and "Combine Warehouse Shipment".
/// </summary>
pageextension 50100 "PageExt50100" extends "EOS029 Container Entries" //70491919 
{
    layout
    {
        addafter("Document No.")
        {
            field("EOS CWS Shipment No."; ShipmentNo)
            {
                ApplicationArea = All;
                Caption = 'CWS Shipment No.';
                ToolTip = 'Specifies the number of the related CWS document.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetShipmentNoCWS();
    end;

    var
        ShipmentNo: code[20];

    local procedure GetShipmentNoCWS()
    var
        SalesShipHeader: Record "Sales Shipment Header";
    begin
        Clear(ShipmentNo);
        case Rec."Document Type" of
            Rec."Document Type"::"Sales Shipment":
                if SalesShipHeader.Get(Rec."Document No.") then
                    ShipmentNo := SalesShipHeader."EOS Shipment No.";
        end;
    end;
}