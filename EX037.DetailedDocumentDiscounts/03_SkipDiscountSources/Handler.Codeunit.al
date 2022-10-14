codeunit 50100 "DDD_Event_Handler"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS037 Sales Handler", 'OnAfterGetPaymentTermsAsDiscountSource', '', true, false)]
    local procedure OnAfterGetPaymentTermsAsDiscountSource(
        var PaymentTerms: Record "Payment Terms";
        SalesHeader: Record "Sales Header";
        var CanApply: Enum "EOS066 TriState Boolean"
    )
    begin
        // Someone else has already decided for us, so we do nothing.
        // Note: it is not strictly necessary to set this value to "True" by yourself. Only if this
        // is set to "False" will the discount application be skipped. "True" or "Undefined" will apply the discount.
        // But it is encouraged to explicitly set it to "True" to let potential other subscribers know that someone has decieded
        // to **actively** apply the discount.
        if (CanApply <> CanApply::Undefined) then exit;

        // Case 1
        // Never apply any payment discounts to quotes.
        // Note that if - in whatever way - a payment discount has already been applied to the document,
        // this will NOT remove it. It will just prevent application of the new one.
        if (SalesHeader."Document Type" = SalesHeader."Document Type"::Quote) then begin
            CanApply := CanApply::"False";
            exit;
        end;

        // Case 2
        // Make sure that customer 30000 never gets any payment discount. And even if one should already present,
        // remove it from the document.
        // This is done by clearing the discount set ID on the payment terms.
        if (SalesHeader."Sell-to Customer No." = '20000') then begin
            Clear(PaymentTerms."EOS037 Discount Set ID");
            CanApply := CanApply::"True"; // for clarity. Not really necessary though. See above.
        end;
    end;

}