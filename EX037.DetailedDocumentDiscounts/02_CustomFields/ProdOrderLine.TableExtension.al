tableextension 50100 TableExt50100 extends "Prod. Order Line"
{

    fields
    {

        /// <summary>
        /// This will hold the discount SetID in use for the current line.
        /// Validating this will cause amounts to be updated.
        /// </summary>
        field(50100; "Discount Set ID"; Guid)
        {
            Caption = 'Discount Set ID';

            trigger OnValidate()
            begin
                UpdateAmounts();
            end;
        }

        /// <summary>
        /// Just some fake line amount field used for demonstration purposes.
        /// </summary>
        field(50101; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
        }
    }

    internal procedure GetBaseAmount(): Decimal
    var
        Item: Record Item;
    begin
        Item.Get("Item No.");
        exit(Item."Unit Price" * Quantity);
    end;

    /// <summary>
    /// Update our glorious fake line amount field.
    /// </summary>
    internal procedure UpdateAmounts()
    var
        DDD: Codeunit "EOS037 Detailed Discounts";
        DiscountAmount: Decimal;
    begin
        // calculate the discount amount from our set, if any.
        DiscountAmount := DDD.CalcDiscountAmount("Discount Set ID", DDD.GetDiscountCalcParameters(Rec), Enum::"EOS066 TriState Boolean"::Undefined);
        // deduct from the base amount
        "Line Amount" := GetBaseAmount() - DiscountAmount;
    end;

}