tableextension 50100 "SalesLineDiscountMigration" extends "Sales Line"
{
    fields
    {
        field(50101; "EOS Import Dtld. Discount"; Text[100])

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