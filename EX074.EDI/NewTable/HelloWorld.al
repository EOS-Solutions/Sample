@@ -0,0 +1,54 @@
reportextension 50100 HelloWorld extends "EOS074 Create EDI Messages Out"
{
    dataset
    {
        addlast(EDIMessageSetup)
        {
            // filter for EDI values first
            dataitem(EDIValues_SalesShipment; "EOS074 EDI Values")
            {
                DataItemTableView = sorting("Entry No.");

                // filter for the actual document, starting from the EDI values
                dataitem("Sales Shipment Header"; "Sales Shipment Header")
                {
                    DataItemLink = "No." = field("Source ID");
                    DataItemTableView = sorting("Sell-to Customer No.", "Posting Date");

                    trigger OnPreDataItem()
                    begin
                        // make sure we only process the correct message type
                        if EDIMessageSetup."Message Type" <> EDIMessageSetup."Message Type"::"Desadv Out" then
                            CurrReport.Break();

                        // apply filters that the user might have set up on the report
                        if EDIMessageSetup.GetFilter("Document No. Filter") <> '' then
                            SetFilter("No.", EDIMessageSetup.GetFilter("Document No. Filter"));
                        if EDIMessageSetup.GetFilter("Date Filter") <> '' then
                            SetFilter("Posting Date", EDIMessageSetup.GetFilter("Date Filter"));
                    end;

                    trigger OnAfterGetRecord()
                    var
                        DocCheckBuffer: Record "EOS074 EDI Docum. Check Buffer";
                    begin
                        // Initialize the buffer with the default values
                        InitBuffer(DocCheckBuffer, "Sales Shipment Header", "Posting Date");

                        // The following values may or may not be required - depending on the conversion report used.
                        DocCheckBuffer."External Document No." := "External Document No.";
                        DocCheckBuffer."Customer No." := "Sell-to Customer No.";
                        DocCheckBuffer."Customer Name" := "Sell-to Customer Name";
                        DocCheckBuffer."EDI Group Code" := EDIValues_SalesShipment."EDI Group Code";
                        DocCheckBuffer."Bill-to Customer No." := "Bill-to Customer No.";
                        DocCheckBuffer."Bill-to Name" := "Bill-to Name";

                        // Create the message
                        // This procedure will return true or false, depending on whether the message was created or not.
                        // If the message was not created, the buffer will contain the error message.
                        // If the message was created, the buffer record will also be written to the database.
                        CreateMessage(DocCheckBuffer);
                    end;
                }

                trigger OnPreDataItem()
                begin
                    // Filter for the correct message type and group code
                    if EDIMessageSetup."Message Type" <> EDIMessageSetup."Message Type"::"Desadv Out" then
                        CurrReport.Break();
                    SetRange("EDI Group Code", EDIMessageSetup."EDI Group Code");
                end;
            }
        }
    }
}