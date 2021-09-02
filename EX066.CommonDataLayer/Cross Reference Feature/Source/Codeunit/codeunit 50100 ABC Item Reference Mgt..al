codeunit 50100 "ABC Item Reference Mgt."
{
    local procedure PrintReference(ItemNo: Code[20]; VariantCode: Code[10]; UnitOfMeasure: Code[10]; ReferenceType: Integer; ReferenceTypeNo: Code[20])
    var
        TempItemReference: Record "Item Reference" temporary;
        OptionalFeatureMgt: Codeunit "EOS066 Optional Feature Mgt.";
        ItemReferenceType: Enum "Item Reference Type";
    begin
        if not (ReferenceType in [ItemReferenceType::Customer.AsInteger(), ItemReferenceType::Vendor.AsInteger()]) then
            exit;

        OptionalFeatureMgt.GetItemReferenceSet(ItemNo, VariantCode, UnitOfMeasure, ReferenceType, ReferenceTypeNo, TempItemReference);

        if TempItemReference.FindSet() then
            repeat
                Message(TempItemReference."Reference No.")
            until TempItemReference.Next() = 0;
    end;
}