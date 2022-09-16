codeunit 50100 ProdOrderDiscounts
{

    /// <summary>
    /// This subscriber provides the discount calculation parameters for a given source document header or line.
    /// See the method 'GetDiscountCalcParams' below for a detailed explanation.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS037 Detailed Discounts", 'OnGetDiscountCalcParameters', '', true, false)]
    local procedure OnGetDiscountCalcParameters(
        DocumentLine: Variant;
        var Handled: Boolean;
        var Parameters: JsonObject
    )
    var
        ProdOrderLine: Record "Prod. Order Line";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        DataTypeMgt.GetRecordRef(DocumentLine, RecRef);
        if (RecRef.Number() = Database::"Prod. Order Line") then begin
            RecRef.SetTable(ProdOrderLine);
            Parameters := GetDiscountCalcParams(ProdOrderLine);
            Handled := true;
        end;
    end;

    /// <summary>
    /// Constructs a JSON object that holds all parameters of a given document line required to calculate the discount.
    /// Sales and purchase lines are already handled by the DDD base application.
    /// Any custom tables need to subscribe to the event 'OnGetDiscountCalcParameters' (above) and provide this JSON object in order
    /// for DDD to be able to calculate the discount amount.
    /// See below for possible values and an explanation.
    /// This JSON object will be replaced by a temporary table in a future implementation.
    /// </summary>
    local procedure GetDiscountCalcParams(ProdOrderLine: Record "Prod. Order Line"): JsonObject
    var
        jo: JsonObject;
        BaseAmount: Decimal;
    begin
        BaseAmount := ProdOrderLine.GetBaseAmount();

        // The base amount of the line. This is usually the undiscounted gross amount (Quantity * UnitPrice) from where the discount calculation starts.
        jo.Add('BaseAmount', BaseAmount);

        // The quantity of the line, in UoM. This is required when discounts per quantity are used.
        jo.Add('Quantity', ProdOrderLine.Quantity); 

        // The quantity of the line, in base UoM. This is required when discounts per quantity are used.
        jo.Add('QuantityBase', ProdOrderLine."Quantity (Base)"); 

        // The net weight of the line. This is required when discounts per net weight are used.
        jo.Add('NetWeight', 0);

        // The currency code. This is required for rounding and display purposes.
        jo.Add('CurrencyCode', '');

        exit(jo);
    end;

}