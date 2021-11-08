tableextension 50101 "Purchase Line Ext" extends "Purchase Line"
{
    fields
    {
        field(50102; "EOS Import Dtld. Discount"; Text[100])

        {
            DataClassification = CustomerContent;
            Description = 'Temp field for data import';
            Caption = 'Import Detailed Line Discount';
            trigger OnValidate()
            var
                DDDEventDispatcher: Codeunit "EOS066 DDD Event Dispatcher";
            begin
                DDDEventDispatcher.SetDtldLineDiscountString(Rec, Rec."EOS Import Dtld. Discount");
            end;
        }
        // Add changes to table fields here
    }
    
    var
        myInt: Integer;
}