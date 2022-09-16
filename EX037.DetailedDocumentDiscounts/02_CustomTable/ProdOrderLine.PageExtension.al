pageextension 50100 PageExt50100 extends "Released Prod. Order Lines"
{

    layout
    {
        addafter(Quantity)
        {
            field(DtldDiscount; DiscountString)
            {
                ApplicationArea = All;
                Caption = 'Discount %';

                trigger OnValidate()
                begin
                    // parse the user input and try to create the discount set. This will (probably) create new SetID.
                    DDD.ParseDetailedDiscountString(Rec."Discount Set ID", DiscountString);
                    // validate the discount set ID, causing amounts to be recalculated
                    Rec.Validate("Discount Set ID");
                    // required to retrigger 'OnAfterGetCurrRecord' to update our DiscountString
                    CurrPage.Update();
                end;

                trigger OnAssistEdit()
                begin
                    // show the page to edit the discount set. Once the page is closed a new SetID will (probably) have been created.
                    DDD.EditDiscountSet(Rec."Discount Set ID", true);
                    // validate the discount set ID, causing amounts to be recalculated
                    Rec.Validate("Discount Set ID");
                    // required to retrigger 'OnAfterGetCurrRecord' to update our DiscountString
                    CurrPage.Update();
                end;
            }
            field("Line Amount"; Rec."Line Amount")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    var
        DDD: Codeunit "EOS037 Detailed Discounts";
        DiscountString: Text;


    trigger OnAfterGetCurrRecord()
    var
        Set: Record "EOS037 Discount Set";
        Params: JsonObject;
    begin
        // Try to show a string representation for lines having a discount.
        Clear(DiscountString);
        if (Set.Get(Rec."Discount Set ID")) then
            DiscountString := Set.ToString(DDD.GetDiscountCalcParameters(Rec));
    end;

}