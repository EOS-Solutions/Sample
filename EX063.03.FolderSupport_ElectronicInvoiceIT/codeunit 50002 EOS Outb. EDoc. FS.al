codeunit 50002 "EOS Outb. EDoc. FS"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Outb. EDoc. Mgt.", 'OnAfterEDocCreated', '', true, false)]
    local procedure OnAfterCreateXML(var RecRef: RecordRef)
    var
        Template: Record "Sales Invoice Header" temporary;
        EOSOutbElectrDocSetup: Record "EOS Outb. Electr. Doc. Setup";
        ServiceConfig: Record "EOS004 Service Config.";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        iStorage: Interface "EOS004 iStorage v2";
        FileName: Text;
    begin
        if not EOSOutbElectrDocSetup.Get() then
            EOSOutbElectrDocSetup.Insert();

        if EOSOutbElectrDocSetup."EOS File Path" = '' then
            exit;
        EOSOutbElectrDocSetup.TestField("EOS File Path"); //?

        EOSOutbElectrDocSetup.TestField("EOS Service Config Key");
        if not ServiceConfig.Get(EOSOutbElectrDocSetup."EOS Service Config Key") then
            exit;
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(ServiceConfig);

        TempBlob.FromRecordRef(RecRef, Template.FieldNo("EOS EDoc. XML File"));
        FileName := RecRef.Field(Template.FieldNo("EOS Elect. Doc. File Name")).Value();
        iStorage.UploadFile(EOSOutbElectrDocSetup."EOS File Path" + '\' + FileName, TempBlob)
        // FileManagement.BLOBExportToServerFile(tempBlob, EOSOutbElectrDocSetup."EOS File Path" + '\' + FileName);
        //tempBlob.Blob.Export(EOSOutbElectrDocSetup."EOS File Path" + '\' + FileName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS063 Outb. Purch. EDoc. Mgt.", 'OnAfterEDocCreated', '', true, false)]
    local procedure ExportSelfInvoice(var RecRef: RecordRef; EOS063OutbPEDocData: Record "EOS063 Outb. P. EDoc. Data")
    var
        EOSOutbElectrDocSetup: Record "EOS Outb. Electr. Doc. Setup";
        ServiceConfig: Record "EOS004 Service Config.";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        iStorage: Interface "EOS004 iStorage v2";
        FileName: Text;
    begin
        if not EOSOutbElectrDocSetup.Get() then
            EOSOutbElectrDocSetup.Insert();

        if EOSOutbElectrDocSetup."EOS Self-Invoice File Path" = '' then
            exit;
        EOSOutbElectrDocSetup.TestField("EOS Self-Invoice File Path");

        EOSOutbElectrDocSetup.TestField("EOS Service Config Key");
        if not ServiceConfig.Get(EOSOutbElectrDocSetup."EOS Service Config Key") then
            exit;
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(ServiceConfig);

        TempBlob.FromRecord(EOS063OutbPEDocData, EOS063OutbPEDocData.FieldNo(EOS063OutbPEDocData."Electr. Document XML"));
        FileName := EOS063OutbPEDocData."Electr. Document Filen.";
        iStorage.UploadFile(EOSOutbElectrDocSetup."EOS Self-Invoice File Path" + '\' + FileName, TempBlob);
        //FileManagement.BLOBExportToServerFile(tempBlob, EOSOutbElectrDocSetup."EOS Self-Invoice File Path" + '\' + FileName);
    end;
}