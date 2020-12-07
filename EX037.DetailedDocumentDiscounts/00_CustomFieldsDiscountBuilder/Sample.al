Codeunit 50022 "FOS015 Det. Doc. Dis. Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure MakeDetailDocumentDiscounts(var Rec: Record "Sales Line")
    var
        TempDiscSetEntry: Record "EOS037 Discount Set Entry" temporary;
        DtldDiscounts: Codeunit "EOS037 Detailed Discounts";
    begin
        if Rec.Type <> Rec.Type::Item then
            exit;

        CreateDiscSetEntry(TempDiscSetEntry, Rec."FOS Customer Discount %", 1);
        CreateDiscSetEntry(TempDiscSetEntry, Rec."FOS Extra Discount %", 2);
        CreateDiscSetEntry(TempDiscSetEntry, Rec."FOS Logistic Discount %", 3);
        CreateDiscSetEntry(TempDiscSetEntry, Rec."FOS Sell-in Discount %", 4);
        CreateDiscSetEntry(TempDiscSetEntry, Rec."FOS Cash Desk Discount %", 5);
        CreateDiscSetEntry(TempDiscSetEntry, Rec."FOS Item Discount %", 6);
        CreateDiscSetEntry(TempDiscSetEntry, Rec."FOS Additional Discount %", 7);

        Rec.Validate("EOS Discount Set ID", DtldDiscounts.WriteDiscountSet(TempDiscSetEntry));
    end;

    local procedure CreateDiscSetEntry(var TempDiscSetEntry: Record "EOS037 Discount Set Entry"; DiscValue: Integer; Sequence: Integer)
    begin
        if DiscValue = 0 then
            exit;

        TempDiscSetEntry.Init();
        TempDiscSetEntry.Sequence := Sequence;
        TempDiscSetEntry.Type := TempDiscSetEntry.Type::"Discount %";
        TempDiscSetEntry.Value := DiscValue;
        TempDiscSetEntry.Insert();
    end;
}