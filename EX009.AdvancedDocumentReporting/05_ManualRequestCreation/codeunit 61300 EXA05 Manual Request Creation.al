codeunit 61300 "EXA05 Manual Request Creation"
{

    procedure CreateManualRequestWithDocument(MyCustomTable: Record "EXA005 My Custom Table")
    var
        AdvDocDocuments: Record "EOS AdvDoc Documents";
        AdvDocRequest: Record "EOS AdvDoc Request";
        AdvDocMngt: Codeunit "EOS AdvDoc Mngt";
    begin
        //This is an example with a manual ADR document handling but is better to let ADR create all, like on example 2 (CreateAuthomaticRequestWithMultiDocuments)

        AdvDocRequest.InitializeRequest();
        AdvDocRequest."EOS Request Type" := AdvDocRequest."EOS Request Type"::EOSSingleMail;

        AdvDocRequest.Insert(true);

        AdvDocRequest.InitializeDocument(AdvDocDocuments);
        AdvDocDocuments.Validate("EOS Record ID", MyCustomTable.RecordId());
        AdvDocDocuments."EOS Document No." := MyCustomTable.Code; //Readable Document no. (recordID is not very readable...)
        AdvDocDocuments."EOS Custom File Format" := 'PDF';
        AdvDocDocuments."EOS Custom Report ID" := Report::"EXA05 My Custom Report"; //no report selection for a custom table 
        AdvDocDocuments.Insert(true);

        AdvDocMngt.BuildRecipientList(AdvDocRequest);
        Commit();

        //AdvMailProcessing.ProcessRequest(Rec);
        Page.Run(Page::"EOS AdvDoc Mail Header", AdvDocRequest);
    end;

    procedure CreateAuthomaticRequestWithMultiDocuments(var MyCustomTable: Record "EXA005 My Custom Table")
    var
        ReportSetup: Record "EOS Report Setup";
        AdvDocRequest: Record "EOS AdvDoc Request";
        AdvDocMngt: Codeunit "EOS AdvDoc Mngt";
        DocVariant: Variant;
    begin
        // -->>>  manually create a specific report setup code.  <<<--
        // It's better bestpractice to save this specific report setup into a custom customer setup.
        // For this example we will create it by code.
        // Any report Setup Code different from "DEFAULT" require a valid subscription!
        ReportSetup."EOS Code" := 'MyTable';
        if not ReportSetup.Insert() then;

        DocVariant := MyCustomTable;
        AdvDocMngt.BuildSendRequest(DocVariant, AdvDocRequest, ReportSetup."EOS Code");
        Commit();

        Page.Run(Page::"EOS AdvDoc Mail Header", AdvDocRequest);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Adv Mail Routines", 'OnBeforeGetFieldCodeValue', '', true, false)]
    local procedure OnBeforeGetFieldCodeValue(var RecRef: RecordRef; SalesHeaderFieldNo: Integer; var CodeValue: Code[20]; var Handled: Boolean)
    var
        MyCustomTable: Record "EXA005 My Custom Table";
        SalesHeader: Record "Sales Header";
    begin
        // Teaching to ADR something about our table ;) 

        if RecRef.Number() <> Database::"EXA005 My Custom Table" then
            exit;

        if Handled then
            exit;

        CodeValue := '';

        case SalesHeaderFieldNo of
            SalesHeader.FieldNo("Sell-to Customer No."):
                CodeValue := RecRef.field(MyCustomTable.FieldNo("Sell-to Customer No.")).Value();
            SalesHeader.FieldNo("Bill-to Customer No."):
                CodeValue := RecRef.field(MyCustomTable.FieldNo("Bill-to Customer No.")).Value();
            SalesHeader.FieldNo("Salesperson Code"):
                CodeValue := RecRef.field(MyCustomTable.FieldNo("Salesperson Code")).Value();
        end;

        Handled := CodeValue <> '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Adv Mail Routines", 'OnCustomerVendorTableArea', '', true, false)]
    local procedure OnCustomerVendorTableArea(RecRef: RecordRef; var CustomerVendorTableNo: Integer)
    //We must tell to ADR if a table is "Customer" or "Vendor" area because Contact business relation must be
    //filtered as ContBusRel."Link to Table"::Customer or ""::vendor"
    begin
        if RecRef.Number() = database::"EXA005 My Custom Table" then
            CustomerVendorTableNo := database::Customer;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Mngt", 'OnBeforeDocumentInsert', '', true, false)]
    local procedure OnBeforeDocumentInsert(DocumentRecRef: RecordRef;
                                          var AdvDocRequest: Record "EOS AdvDoc Request";
                                          var AdvDocDocuments: Record "EOS AdvDoc Documents")
    begin
        //We will add manually each attachment avoiding standard ADR Report Print
        //But we will do this only for "MYTABLE" report setup
        if AdvDocRequest."EOS Report Setup Code" = 'MYTABLE' then
            AdvDocDocuments."EOS Skip Standard Doc Creation" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Mngt", 'OnAfterDocumentInsert', '', true, false)]
    local procedure OnAfterDocumentInsert(DocumentRecRef: RecordRef;
                                          var AdvDocRequest: Record "EOS AdvDoc Request";
                                          var AdvDocDocuments: Record "EOS AdvDoc Documents")
    var
        AdvDocFiles: Record "EOS AdvDoc Files";
        oStream: OutStream;
    begin
        //This event is raised after "Insert" so AdvDocDocuments."EOS Entry No." (autoincrement) is populated
        AdvDocDocuments.InitializeFile(AdvDocFiles); //this will also populate filename and fileextension from AdvDocDocuments."EOS Filename" value but we can override this name

        //Creating a simple text file
        AdvDocFiles."EOS Embedded Blob".CreateOutStream(oStream);
        oStream.WriteText('--Sample text--');
        AdvDocFiles."EOS File Extension" := 'TXT';
        AdvDocFiles."EOS FileName" := 'Example';
        AdvDocFiles.Insert();
    end;
}