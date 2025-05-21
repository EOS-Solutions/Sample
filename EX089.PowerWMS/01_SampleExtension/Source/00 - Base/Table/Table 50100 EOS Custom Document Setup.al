table 50100 "EOS Custom Activity Setup"
{
    Caption = 'Custom Activity Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(3; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
            TableRelation = "Bin".Code where("Location Code" = field("Location Code"));
        }
        field(4; "Item No. 1"; Code[20])
        {
            Caption = 'Item No. 1';
            TableRelation = Item;
        }
        field(5; "Item No. 2"; Code[20])
        {
            Caption = 'Item No. 2';
            TableRelation = Item;
        }
        field(6; "Item No. 3"; Code[20])
        {
            Caption = 'Item No. 3';
            TableRelation = Item;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
