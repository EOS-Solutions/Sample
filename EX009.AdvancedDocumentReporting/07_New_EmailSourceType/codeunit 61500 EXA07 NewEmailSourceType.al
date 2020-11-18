codeunit 61500 "EXA07 NewEmailSourceType"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Adv Mail Routines", 'OnBeforeProcessingMailSetup', '', True, False)]
    local procedure OnBeforeProcessingMailSetup(AdvDocRequest: Record "EOS AdvDoc Request";
                                        DocumentRecRef: RecordRef;
                                        MailAddrSetup: Record "EOS AdvDoc Mail Address Setup";
                                        var LastEntryNo: Integer;
                                        var TempAdvDocRecipients: Record "EOS AdvDoc Recipients";
                                        var Handled: Boolean)
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        AdvMailRoutines: Codeunit "EOS Adv Mail Routines";
        CustomerCode: Code[20];
    begin
        // We only manage our type
        if MailAddrSetup."EOS E-Mail Source Type" <> MailAddrSetup."EOS E-Mail Source Type"::"EXA Email 2 Example" then
            exit;

        // We need the customer or vendor associated with our current record 

        //First question: Our DocumentRecRef is a purchase document or a sales document? 
        //  We have our new field only on customer table, not on vendor table.

        if not AdvMailRoutines.IsCustomer(DocumentRecRef) then
            exit;

        // So we call GetFieldCodeValue with a question like this:
        // If the table was the "Sales Header", what would be the value of the "Sell-to Customer No."?
        CustomerCode := AdvMailRoutines.GetFieldCodeValue(DocumentRecRef, SalesHeader.FieldNo("Sell-to Customer No."));

        if CustomerCode = '' then
            exit;

        if not Customer.Get(CustomerCode) then
            exit;

        if Customer."EXA Email 2 Example" = '' then
            exit;

        AdvDocRequest.InitializeRecipient(TempAdvDocRecipients);
        TempAdvDocRecipients."EOS Mail Source Table No." := 0;
        TempAdvDocRecipients."EOS Source No." := '';
        TempAdvDocRecipients."EOS Address Type" := MailAddrSetup."EOS Address Type";

        // if the table field contains many emails splitted by a ";" we must split it
        // This function does the job for us by inserting as many records as there are emails
        AdvMailRoutines.AutoSplitMultiMail(LastEntryNo, TempAdvDocRecipients, Customer."EXA Email 2 Example");
        Handled := true;
    end;


}