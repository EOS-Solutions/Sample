codeunit 50001 "EOS Inb. EDoc. FS"
{
    var
        EOSFEFileSystemMgt: Codeunit "EOS FE FileSystem Mgt.";
        EOSInbElectrDocExec: Codeunit "EOS Inb. Electr. Doc. Exec";
        IncElectrDocLogMgt: Codeunit "EOS Inb. EDoc. Log Mgt.";
        GlobalBatchGUID: Guid;
        HideDialog: Boolean;
        IsBatchProcess: Boolean;
        GlobalAction: Option Import,Validate,Create,ProcessXML;
        TextOperationCompletedWValuesLbl: Label 'Processed records:%1\Accepted: %2\Rejected/Ignored: %3';
        TextDialogMsg: Label 'Elaboration in progress\@1@@@@@@@@@@@@@@';
        NoFileErr: Label 'The file %1 were not found';

    procedure ImportFolder(FolderName: Text[150])
    var
        Files: Record "Name/Value Buffer" temporary;
        ServiceConfig: Record "EOS004 Service Config.";
        EOSInbEDocSetup: Record "EOS Inb. EDoc. Setup";
        TempBlob: Codeunit "Temp Blob";
        filemanagement: Codeunit "File Management";
        iStorage: Interface "EOS004 iStorage v2";
        os: OutStream;
        is: InStream;
        TotCount: Integer;
        k: Integer;
        LastId: Integer;
        i: Integer;
        Dialog: Dialog;
        NoOfKO: Integer;
        NoOfOK: Integer;
        FileNames: array[10000] of Text[150];
        TmpFileName: Text[150];
        isCorrupted: Boolean;
        fileCorruptedLbl: label 'The file is corrupted';
    begin
        //if FolderName = '' then
        //    FolderName := CopyStr(EOSFEFileSystemMgt.UploadFolderFromClient(), 1, MaxStrLen(FolderName));
        EOSInbEDocSetup.Read();
        EOSInbEDocSetup.TestField("EOS Service Config Key");
        if not ServiceConfig.Get(EOSInbEDocSetup."EOS Service Config Key") then
            exit;
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(ServiceConfig);

        TotCount := EOSFEFileSystemMgt.ImportXMLFolder(FolderName, FileNames);
        // TotCount := JArray.Count;

        if GuiAllowed() then
            Dialog.Open(TextDialogMsg);

        k := 0;
        Clear(Files);
        if TotCount > 0 then
            for i := 1 to TotCount do begin
                Clear(TempBlob);
                isCorrupted := false;
                TmpFileName := '';

                if FileNames[i].ToUpper().Contains('.P7M') then begin
                    TmpFileName := FileNames[i];
                    EOSFEFileSystemMgt.convertP7M(TmpFileName);
                    if TmpFileName = '' then
                        isCorrupted := true
                    else begin
                        iStorage.ReadFile(TmpFileName, is);
                        TempBlob.CreateOutStream(os);
                        CopyStream(os, is);
                    end;
                end else begin
                    iStorage.ReadFile(FileNames[i], is);
                    TempBlob.CreateOutStream(os);
                    CopyStream(os, is);
                end;
                // filemanagement.BLOBImportFromServerFile(TempBlob, FileNames[i]);

                if Files.FindLast() then
                    LastId := Files.ID;

                Files.Init();
                Files.ID := LastId + 1;
                if TmpFileName <> '' then
                    Files.Name := TmpFileName
                else
                    Files.Name := FileNames[i];
                if isCorrupted then
                    Files.Value := '1';
                Files."Value BLOB".CreateOutStream(os);
                TempBlob.CreateInStream(is);
                CopyStream(os, is);
                Files.Insert();
            end;
        if not IsBatchProcess then begin
            ClearLastError();
            if IsNullGuid(GlobalBatchGUID) then
                GlobalBatchGUID := CreateGuid();
            IncElectrDocLogMgt.Logbegin(0, GlobalBatchGUID, false);
        end;
        if Files.FindFirst() then begin
            repeat
                if IsGuiAllowed() then begin
                    k += 1;
                    Dialog.Update(1, Round(k / TotCount * 10000, 1));
                end;
                if Files.Name <> '' then begin
                    Commit();

                    Clear(is);
                    Clear(os);
                    Clear(TempBlob);
                    Files.CalcFields("Value BLOB");
                    Files."Value BLOB".CreateInStream(is);
                    TempBlob.CreateOutStream(os);
                    CopyStream(os, is);

                    Clear(EOSInbElectrDocExec);
                    EOSInbElectrDocExec.SetHideDialog(HideDialog);
                    EOSInbElectrDocExec.SetBatchProcess(IsBatchProcess, GlobalBatchGUID);
                    EOSInbElectrDocExec.SetAction(GlobalAction::Import);
                    EOSInbElectrDocExec.SetFileName(Files.Name, 0);
                    EOSInbElectrDocExec.setTempBlob(TempBlob);
                    if not EOSInbElectrDocExec.Run() then begin
                        NoOfKO += 1;
                        if Files.Value = '1' then
                            IncElectrDocLogMgt.LogLine(GlobalBatchGUID, copystr(Files.Name, 1, 150), 1, 1, CopyStr(fileCorruptedLbl, 1, 250))
                        else
                            IncElectrDocLogMgt.LogLine(GlobalBatchGUID, copystr(Files.Name, 1, 150), 1, 1, CopyStr(GETLASTerrorTEXT(), 1, 250));
                    end else begin
                        NoOfOK += 1;
                        IncElectrDocLogMgt.LogLine(GlobalBatchGUID, copystr(Files.Name, 1, 150), 0, 1, '');
                    end;
                end;
            until Files.Next() = 0;

            if IsGuiAllowed() then
                Dialog.Close();

            if not IsBatchProcess then
                IncElectrDocLogMgt.Logend(GlobalBatchGUID, StrSubstNo(TextOperationCompletedWValuesLbl, NoOfKO + NoOfOK, NoOfOK, NoOfKO));

            if IsGuiAllowed() then
                Message(TextOperationCompletedWValuesLbl, NoOfKO + NoOfOK, NoOfOK, NoOfKO);
        end;
    end;

    local procedure IsGuiAllowed(): Boolean
    begin
        exit(GuiAllowed() and (not HideDialog));
    end;

    procedure SetBatchProcess(NewValue: Boolean; NewBatchGUID: Guid)
    begin
        IsBatchProcess := NewValue;
        GlobalBatchGUID := NewBatchGUID;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Inb. Electr. Doc. Mgt.", 'OnAddFSForSchedule', '', true, false)]
    local procedure OnAddFSForSchedule(var ProcessGuid: Guid)
    var
        EOSInbEDocSetup: Record "EOS Inb. EDoc. Setup";
    begin
        EOSInbEDocSetup.Read();
        HideDialog := true;
        SetBatchProcess(true, ProcessGuid);
        EOSInbEDocSetup.TestField("EOS Service Config Key");
        if EOSInbEDocSetup."EOS Import Folder" <> '' then
            ImportFolder(EOSInbEDocSetup."EOS Import Folder");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Inb. Electr. Doc. Mgt.", 'OnErrorLoadElectrDocFromXML', '', true, false)]
    local procedure OnErrorLoadElectrDocFromXML(FileName: Text[250]; tempBlob: Codeunit "Temp Blob"; EOSFEInbLotEntryNo: Integer)
    var
        Config: Record "EOS004 Service Config.";
        IncomingElectrDocSetup: Record "EOS Inb. EDoc. Setup";
        iStorage: Interface "EOS004 iStorage v2";
    begin
        IncomingElectrDocSetup.Read();
        Config.Get(IncomingElectrDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        if IncomingElectrDocSetup."EOS Rejected Folder" <> '' then
            iStorage.UploadFile(copystr(IncomingElectrDocSetup."EOS Rejected Folder" + '\' +
                EOSFEFileSystemMgt.GetFileName(FileName), 1, 250), tempBlob);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Inb. Electr. Doc. Mgt.", 'OnSuccessLoadElectrDocFromXML', '', true, false)]
    local procedure OnSuccessLoadElectrDocFromXML(FileName: Text[250]; tempBlob: Codeunit "Temp Blob"; EOSFEInbLotEntryNo: Integer)
    var
        Config: Record "EOS004 Service Config.";
        IncomingElectrDocSetup: Record "EOS Inb. EDoc. Setup";
        iStorage: Interface "EOS004 iStorage v2";
    begin
        IncomingElectrDocSetup.Read();
        Config.Get(IncomingElectrDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        if (IncomingElectrDocSetup."EOS Archive Folder" <> '') then
            iStorage.UploadFile(copystr(IncomingElectrDocSetup."EOS Archive Folder" + '\' +
            EOSFEFileSystemMgt.GetFileName(FileName), 1, 250), tempBlob);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Inb. Electr. Doc. Mgt.", 'OnRefuseIncomingHeader', '', true, false)]
    local procedure OnRefuseIncomingHeader(var IncomingElectrDocHeader: Record "EOS Inb. EDoc. Header")
    var
        Config: Record "EOS004 Service Config.";
        IncomingElectrDocSetup: Record "EOS Inb. EDoc. Setup";
        EOSInbEDocFile: Record "EOS Inb. EDoc. File";
        TempBlob: Codeunit "Temp Blob";
        iStorage: Interface "EOS004 iStorage v2";
        os: OutStream;
        is: InStream;
    begin
        if not EOSInbEDocFile.Get(IncomingElectrDocHeader."EOS Parent Entry No.") then
            Error(NoFileErr, IncomingElectrDocHeader."EOS File Name");

        EOSInbEDocFile.CalcFields("EOS File BLOB");
        EOSInbEDocFile."EOS File BLOB".CreateInStream(is);
        TempBlob.CreateOutStream(os);
        CopyStream(os, is);

        IncomingElectrDocSetup.Read();
        Config.Get(IncomingElectrDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        if (IncomingElectrDocSetup."EOS Archive Folder" <> '') AND (IncomingElectrDocSetup."EOS Rejected Folder" <> '') then
            iStorage.UploadFile(copystr(IncomingElectrDocSetup."EOS Rejected Folder" + '\' + IncomingElectrDocHeader."EOS File Name", 1, 150), tempBlob);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Inb. Electr. Doc. Mgt.", 'OnRestoreIncomingHeader', '', true, false)]
    local procedure OnRestoreIncomingHeader(var IncomingElectrDocHeader: Record "EOS Inb. EDoc. Header")
    var
        Config: Record "EOS004 Service Config.";
        IncomingElectrDocSetup: Record "EOS Inb. EDoc. Setup";
        EOSInbEDocFile: Record "EOS Inb. EDoc. File";
        TempBlob: Codeunit "Temp Blob";
        iStorage: Interface "EOS004 iStorage v2";
        os: OutStream;
        is: InStream;
    begin
        if not EOSInbEDocFile.Get(IncomingElectrDocHeader."EOS Parent Entry No.") then
            Error(NoFileErr, IncomingElectrDocHeader."EOS File Name");

        EOSInbEDocFile.CalcFields("EOS File BLOB");
        EOSInbEDocFile."EOS File BLOB".CreateInStream(is);
        TempBlob.CreateOutStream(os);
        CopyStream(os, is);

        IncomingElectrDocSetup.Read();
        Config.Get(IncomingElectrDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        if (IncomingElectrDocSetup."EOS Archive Folder" <> '') AND (IncomingElectrDocSetup."EOS Rejected Folder" <> '') then
            iStorage.UploadFile(copystr(IncomingElectrDocSetup."EOS Archive Folder" + '\' + IncomingElectrDocHeader."EOS File Name", 1, 250), tempBlob);
    end;


}