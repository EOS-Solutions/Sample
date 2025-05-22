tableextension 50100 "EOS CAH-Create Trans. Order" extends "EOS089 WMS Custom Act. Header"
{
    fields
    {
        field(50100; "EOS To Location Code"; Code[10])
        {
            Caption = 'To Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;

            trigger OnValidate()
            begin
                Rec."EOS To Bin Code" := '';
            end;
        }
        field(50101; "EOS To Bin Code"; Code[20])
        {
            Caption = 'To Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code where("Location Code" = field("EOS To Location Code"));
        }
        field(50102; "Shipment Destination No."; Code[20])
        {
            Caption = 'Shipment Destination No.';
            DataClassification = CustomerContent;
        }
        field(50103; "Vendor Shipment No."; Code[35])
        {
            Caption = 'Vendor Shipment No.';
            DataClassification = CustomerContent;
        }
        field(50104; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
    }
}
