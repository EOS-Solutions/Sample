tableextension 50101 "EOS RCAH-Create Trans. Order" extends "EOS089 WMS Reg. Cus. Act. Hdr."
{
    fields
    {
        field(50100; "EOS To Location Code"; Code[10])
        {
            Caption = 'To Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(50101; "EOS To Bin Code"; Code[20])
        {
            Caption = 'To Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code where("Location Code" = field("EOS To Location Code"));
        }
    }
}
