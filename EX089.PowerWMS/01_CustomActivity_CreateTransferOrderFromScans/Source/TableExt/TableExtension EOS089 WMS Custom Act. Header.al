tableextension 50000 "EOS Custom Act. Header" extends "EOS089 WMS Custom Act. Header"
{
    fields
    {
        field(50000; "EOS To Location Code"; Code[10])
        {
            Caption = 'To Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;

            trigger OnValidate()
            begin
                Rec."EOS To Bin Code" := '';
            end;
        }
        field(50001; "EOS To Bin Code"; Code[20])
        {
            Caption = 'To Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code where("Location Code" = field("EOS To Location Code"));
        }
    }
}
