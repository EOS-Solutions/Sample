codeunit 71367880 "EOS009.18 ADR-PRQ Bridge"
{
    [EventSubscriber(ObjectType::Table, Database::"EOS Purch. Request Header", OnAfterValidateEvent, "EOS Vendor No.", true, true)]
    local procedure PRQ_OnAfterValidateEvent(var Rec: Record "EOS Purch. Request Header"; var xRec: Record "EOS Purch. Request Header"; CurrFieldNo: Integer)
    var
        Vendor: Record Vendor;
        AdvTextMngt: Codeunit "EOS009 AdvText Mngt.";
    begin
        if Rec."EOS Vendor No." <> '' then begin
            Vendor.get(Rec."EOS Vendor No.");
            AdvTextMngt.CopyTexts(Vendor, Rec, true, '');
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Purch. Request Management", OnAfterArchivePurchRequest, '', false, false)]
    local procedure OnAfterArchivePurchRequest(var PurchReqHeader: Record "EOS Purch. Request Header"; var ArchivedPurchReqHeader: Record "EOS Purch. Req. Header Archive");
    var
        AdvTextMngt: Codeunit "EOS009 AdvText Mngt.";
    begin
        AdvTextMngt.CopyTexts(PurchReqHeader, ArchivedPurchReqHeader, true, '');
    end;

    [EventSubscriber(ObjectType::Report, Report::"EOS Purch. Req. - Create Doc.", OnAfterInsertPurchHeader, '', false, false)]
    local procedure OnAfterInsertPurchHeader(var PurchHeader: Record "Purchase Header"; PurchReqHeader: Record "EOS Purch. Request Header");
    var
        AdvTextMngt: Codeunit "EOS009 AdvText Mngt.";
    begin
        AdvTextMngt.CopyTexts(PurchReqHeader, PurchHeader, true, '');
    end;

}