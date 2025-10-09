codeunit 50100 "CustomTable"
{

    // This example shows how to add support for tables to EDI.
    // Using the report 'EOS074 EDI Messages Out (v2)', only documents that are picked up using this mechanism will be
    // exported to EDI. Out-of-the-box the tables "Sales Invoice Header" and "Sales Cr.Memo Header" are supported for Invoice OUT.

    [EventSubscriber(ObjectType::Report, Report::"EOS074 EDI Messages Out (v2)", OnCollectingDocuments, '', false, false)]
    local procedure MyProcedure(
        var EDIMessageSetup: Record "EOS074 EDI Message Setup";
        var DocCheckBuffer: Record "EOS074 EDI Docum. Check Buffer"
    )
    begin
        // respond only to the message type that you are interested in
        if (EDIMessageSetup."Message Type" <> EDIMessageSetup."Message Type"::"Pricad Out") then
            exit;

        // Add the documents to the buffer.
        AddDocumentToBuffer(EDIMessageSetup, DocCheckBuffer);
    end;

    local procedure AddDocumentToBuffer(var EDIMessageSetup: Record "EOS074 EDI Message Setup"; var TempDocumentBuffer: Record "EOS074 EDI Docum. Check Buffer")
    var
        PriceList: Record "Price List Header";
        EdiCreateMessage: Codeunit "EOS074 EDI Try-Create Message";
    begin
        // filter by document, if a filter was provided
        if EDIMessageSetup.GetFilter("Document No. Filter") <> '' then
            PriceList.SetRange(Code, EDIMessageSetup.GetFilter("Document No. Filter"));

        // loop on all relevant documents and add them to the buffer
        if PriceList.FindSet() then
            repeat
                // Always use the method `InitBuffer` to initialize a new record. This sets essential fields.
                EdiCreateMessage.InitBuffer(EDIMessageSetup, TempDocumentBuffer, PriceList, PriceList."Starting Date");

                // The fields below should be provided, but are not strictly necessary. However, it depends on the conversion report.
                TempDocumentBuffer."External Document No." := PriceList.Description;
                TempDocumentBuffer."Customer No." := PriceList."Source No.";
                TempDocumentBuffer."Customer Name" := '';
                TempDocumentBuffer."Bill-to Customer No." := '';
                TempDocumentBuffer."Bill-to Name" := '';

                // Always use the method `InsertLine` to actually insert the line. This makes sure that it is inserted as required by the framework.
                TempDocumentBuffer.InsertLine(EDIMessageSetup, PriceList);
            until PriceList.Next() = 0;
    end;

}