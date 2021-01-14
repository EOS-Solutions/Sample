codeunit 50000 "EOS Calculate CONAI"
{
    local procedure CalculateCONAI(SourceDoc: Variant)
    var
        TmpCONAIDocumentDetail: Record "EOS031 CONAI Document Detail" temporary;
        CONAIMgt: Codeunit "EOS031 CONAI Mgt.";

        CONAIDetailsOnDocument: Boolean;
    begin
        CONAIMgt.CalculateDocumentDetail(SourceDoc, TmpCONAIDocumentDetail);
        CONAIDetailsOnDocument := CONAIMgt.UpdateDetailWithDocumentCONAILines(SourceDoc, TmpCONAIDocumentDetail);
        CONAIMgt.UpdateDetailWithCONAILedgerEntries(SourceDoc, TmpCONAIDocumentDetail);
        CONAIMgt.CreateGroupedDetail(SourceDoc, TmpCONAIDocumentDetail);
        CONAIMgt.UpdateDetailWithAmounts(SourceDoc, TmpCONAIDocumentDetail);
        CONAIMgt.UpdateCONAILines(SourceDoc, TmpCONAIDocumentDetail, false);
    end;
}