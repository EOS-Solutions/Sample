codeunit 50100 "EOS CDW AddDocumentLinesToJnl"
{
    procedure GetDocumentLinesAndPost(Handler: Interface "EOS041 IDocumentHandler"; DocumentNo: Code[20])
    var
        tempBuffer: Record "EOS041 CDW Journal Line" temporary;
        CdwJnlLine: Record "EOS041 CDW Journal Line"; //temporary
        Filters: Record "EOS041 Document Filter";
        DocHandling: Codeunit "EOS041 Document Handling";
        CdwPost: Codeunit "EOS041 CDW Post";
    begin
        // Add filters
        Filters.SetRange("Document No. Filter", DocumentNo);
        // Get Document Lines in TempBuffer through the filters
        Handler.GetDocumentLines(Filters, tempBuffer);
        // Now you can do whatever you want with the TempBuffer
        // Assign a Journal Batch Name (not necessary if the CdwJnlLine is temporary)
        CdwJnlLine."Journal Batch Name" := 'JournalName';
        // Functions that moves line from the Buffer to the CdwJnlLine
        DocHandling.AddDocumentLinesToJnl(tempBuffer, CdwJnlLine);
        // If the CdwJnlLine is temporary you can direcly post it
        CdwPost.PostJournal(CdwJnlLine);
    end;

}