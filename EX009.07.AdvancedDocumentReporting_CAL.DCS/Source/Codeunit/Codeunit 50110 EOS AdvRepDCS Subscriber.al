codeunit 50110 "EOS AdvRepDCS Subscriber"
{
    var
        SendDCS_PDF_Lbl: Label 'Send PDF to DocSolutions';
        SendDCS_PDFXML_Lbl: Label 'Send PDF/XML to DocSolutions';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Mngt", 'OnCustomizeSendDialog', '', true, false)]
    local procedure AdvDocRep_OnCustomizeSendDialog(var DocVariant: Variant; var ReportSetupCode: code[10]; var Chooses: List of [Text])
    var
        DataTypeManagement: Codeunit "Data Type Management";
        DocSolutionsMgt: Codeunit "DocSolutions Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(DocVariant, RecRef);

        // check if DocSolutions is enabled the current record
        if not DocSolutionsMgt.IsEnabledForRecord(DocVariant) then
            exit;

        // check if the current record is one of the enabled tables
        if recRef.Number() in [Database::"Sales Header",
        Database::"Purchase Header",
                                Database::"Service Invoice Header",
                                Database::"Service Cr.Memo Header",
                                Database::"Sales Shipment Header",
                                Database::"Sales Invoice Header",
                                Database::"Sales Cr.Memo Header",
                                Database::"Purch. Rcpt. Header",
                                Database::"Purch. Inv. Header",
                                Database::"Purch. Cr. Memo Hdr.",
                                Database::"Reminder Header",
                                Database::"Issued Reminder Header",
                                Database::"Transfer Shipment Header",
                                Database::"Service Header",
                                Database::"Service Shipment Header",
                                Database::"Return Shipment Header",
                                Database::"Return Receipt Header",
                                Database::"Delivery Reminder Header",
                                Database::"Issued Deliv. Reminder Header",
                                Database::"Proforma Sales Header"] then
            /*
            Database::"Delivery Reminder Header" --> Platform Object to remove in future AL extension
            Database::"Issued Deliv. Reminder Header" --> Platform Object to remove in future AL extension
            Database::"Proforma Sales Header" --> Platform Object to remove in future AL extension
            */
            Chooses.Add(SendDCS_PDF_Lbl);

        // 
        if recRef.Number() in [Database::"Sales Invoice Header",
                             Database::"Sales Cr.Memo Header",
                             Database::"Service Invoice Header",
                             Database::"Service Cr.Memo Header"] then
            Chooses.Add(SendDCS_PDFXML_Lbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Mngt", 'OnExecuteCustomizedSendDialog', '', true, false)]
    local procedure AdvDocRep_OnExecuteCustomizedSendDialog(var DocVariant: Variant; var ReportSetupCode: code[10]; Choose: Text; var Handled: Boolean)
    var
        AdvDocRequest: Record "EOS AdvDoc Request";
        EOSAdvMailProcessing: Codeunit "EOS Adv Mail Processing";
        recRef: RecordRef;
    begin
        recRef.GetTable(DocVariant);
        if not (Choose in [SendDCS_PDF_Lbl, SendDCS_PDFXML_Lbl]) then exit;

        BuildPDFRequest(DocVariant, AdvDocRequest, '', Choose);

        EOSAdvMailProcessing.ProcessRequest(AdvDocRequest);

        Handled := true;
    end;

    local procedure BuildPDFRequest(var DocVariant: Variant; var AdvDocRequest: Record "EOS AdvDoc Request"; ForceReportSetup: Code[10]; Choose: Text)
    var
        AdvReportingSetup: Record "EOS Adv Reporting Setup";
        DataTypeManagement: Codeunit "Data Type Management";
        EOSAdvDocMngt: Codeunit "EOS AdvDoc Mngt";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(DocVariant, RecRef);

        if IsNullGuid(AdvDocRequest."EOS ID") then begin
            AdvDocRequest."EOS ID" := CreateGuid();
            AdvDocRequest."EOS Creation" := CurrentDateTime();
            AdvDocRequest."EOS User ID" := CopyStr(UserId(), 1, MaxStrLen(AdvDocRequest."EOS User ID"));
            AdvDocRequest."EOS Report Setup Code" := ForceReportSetup;
            AdvDocRequest.Insert(true);
        end;

        if AdvDocRequest."EOS Mailbox Code" <> '' then begin
            AdvDocRequest."EOS Mailbox Code" := '';
            AdvDocRequest.Modify();
        end;

        EOSAdvDocMngt.BuildDocumentList(DocVariant, AdvDocRequest);

        if Choose = SendDCS_PDF_Lbl then begin
            AdvDocRequest."EOS Request Type" := AdvDocRequest."EOS Request Type"::EOSSendPDFToDCS;
            AdvDocRequest.Modify();
        end;
        if Choose = SendDCS_PDFXML_Lbl then begin
            AdvDocRequest."EOS Request Type" := AdvDocRequest."EOS Request Type"::EOSSendPDFXMLToDCS;
            AdvDocRequest.Modify();
        end;

        if AdvDocRequest."EOS Mailbox Code" = '' then begin
            AdvReportingSetup.Get();
            if AdvReportingSetup."EOS Default Mailbox Code" <> '' then begin
                AdvDocRequest.Validate("EOS Mailbox Code", AdvReportingSetup."EOS Default Mailbox Code");
                AdvDocRequest.Modify();
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Adv Mail Sandbox", 'OnBeforeSandboxProcessing', '', true, false)]
    local procedure OnBeforeSandboxProcessing_UploadDCS(var AdvDocRequest: Record "EOS AdvDoc Request"; var Handled: Boolean)

    var
        AdvDocFiles: Record "EOS AdvDoc Files";
        DCSALBuffer: Record "DCS AL Buffer" temporary;
        AdvDocDocuments: Record "EOS AdvDoc Documents";
        DocSolutionsManagement: Codeunit "DocSolutions Management";
        i: Integer;
    begin
        IF AdvDocRequest."EOS Request Type" <> AdvDocRequest."EOS Request Type"::EOSSendPDFToDCS then
            exit;

        IF Handled then
            exit;

        GenerateRequestFiles(AdvDocRequest);
        Commit();

        AdvDocDocuments.SetRange("EOS Request ID", AdvDocRequest."EOS ID");
        AdvDocDocuments.FindFirst();

        AdvDocFiles.SetRange("EOS Request ID", AdvDocRequest."EOS ID");
        AdvDocFiles.SetAutoCalcFields("EOS Embedded Blob");
        AdvDocFiles.FindFirst();

        i += 1;
        DCSALBuffer.Init();
        DCSALBuffer."Entry No" := i;
        DCSALBuffer.FileName := AdvDocFiles."EOS FileName";
        DCSALBuffer.Content := AdvDocFiles."EOS Embedded Blob";
        DCSALBuffer.RecID := AdvDocDocuments."EOS Record ID";
        DCSALBuffer.Insert();

        DocSolutionsManagement.UploadDocumentsRequestAL(DCSALBuffer);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Adv Mail Sandbox", 'OnBeforeSandboxProcessing', '', true, false)]
    local procedure OnBeforeSandboxProcessing(var AdvDocRequest: Record "EOS AdvDoc Request";
                                             var Handled: Boolean)
    var
        EOSAdvDocDocuments: Record "EOS AdvDoc Documents";
        OutboundElectrDocMgt: Codeunit "Outbound Electr. Doc. Mgt.";
        EOSAdvRptRoutines: Codeunit "EOS AdvRpt Routines";
        recRef: RecordRef;
        recRefTemp: RecordRef;
    begin

        IF AdvDocRequest."EOS Request Type" <> AdvDocRequest."EOS Request Type"::EOSSendPDFXMLToDCS then
            exit;

        IF Handled then
            exit;

        EOSAdvDocDocuments.SetRange("EOS Request ID", AdvDocRequest."EOS ID");
        EOSAdvDocDocuments.FindSet();

        recRef.open(EOSAdvDocDocuments."EOS Table No.");
        recRefTemp.open(EOSAdvDocDocuments."EOS Table No.", true);

        if EOSAdvDocDocuments.Count() = 1 then begin
            recRef.get(EOSAdvDocDocuments."EOS Record ID");
            recRef.SetRecFilter();
            OutboundElectrDocMgt.UploadEDocFromCardAL(recRef);
        end
        else begin
            repeat
                recRef.get(EOSAdvDocDocuments."EOS Record ID");
                EOSAdvRptRoutines.TryTransferFields(recRef, recRefTemp);
                recRefTemp.Insert();
            until EOSAdvDocDocuments.Next() = 0;

            OutboundElectrDocMgt.UploadEDocFromList(recRefTemp);
        end;

        recRef.Close();
        recRefTemp.Close();

        Handled := true;
    end;

    procedure GenerateRequestFiles(var AdvDocRequest: Record "EOS AdvDoc Request")
    var
        AdvDocDocuments: Record "EOS AdvDoc Documents";
        AdvDocProcessorsMngt: Codeunit "EOS AdvDoc Processors Mngt";
        EOSAdvMailSandbox: Codeunit "EOS Adv Mail Sandbox";
    begin
        AdvDocDocuments.Reset();
        AdvDocDocuments.SetRange("EOS Request ID", AdvDocRequest."EOS ID");

        if AdvDocDocuments.FindSet(true) then begin
            repeat
                EOSAdvMailSandbox.GenerateSingleDocument(AdvDocDocuments);
            until AdvDocDocuments.Next() = 0;

            AdvDocDocuments.FindFirst();
            AdvDocProcessorsMngt.ExecuteFileProcessors(AdvDocRequest, AdvDocDocuments);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Adv Mail Processing", 'OnBeforeAdvDocRequestCheck', '', true, false)]
    local procedure OnBeforeAdvDocRequestCheck(var AdvDocRequest: Record "EOS AdvDoc Request"; var Handled: Boolean)
    begin
        if not (AdvDocRequest."EOS Request Type" in
                [AdvDocRequest."EOS Request Type"::EOSSendPDFXMLToDCS,
                AdvDocRequest."EOS Request Type"::EOSSendPDFToDCS]) then
            Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Mngt", 'OnBeforeShowSendDialog', '', true, false)]
    local procedure OnBeforeShowSendDialog(var DocVariant: Variant; var ReportSetupCode: Code[10]; var OpenDialog: Boolean; var Handled: Boolean)
    begin

    end;

}