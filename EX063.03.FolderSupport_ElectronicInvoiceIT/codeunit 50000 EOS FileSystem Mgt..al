codeunit 50000 "EOS FE FileSystem Mgt."
{
    procedure TestRemoteFile(FolderName: Text[1024]): Boolean
    var
        FileName: Text;
        WorkFile: File;
    begin
        exit(true);
    end;

    [Obsolete('File managament standard functions used are no longer supported by Microsoft.', '19.0')]
    procedure UploadFolderFromClient(): Text;
    var
        filemanagement: Codeunit "File Management";
        clientFolder: Text;
        SelectFolderLbl: Label 'Select Folder';
        ClientNotSupportedErr: Label 'Your client is not supported';
    begin
        /*
        if CurrentClientType() = ClientType::Windows then begin
            clientFolder := filemanagement.BrowseForFolderDialog(SelectFolderLbl, '', false);
            clientFolder := filemanagement.BrowseForFolderDialog(SelectFolderLbl, '', false);
            exit(filemanagement.UploadClientDirectorySilent(clientFolder, '', true));
        end
        else
            Error(ClientNotSupportedErr);
        */
    end;

    procedure MoveFile(Filename: Text[250]; NewFilename: Text[250]; ServerSide: Boolean)
    var
        EOSInbEDocSetup: Record "EOS Inb. EDoc. Setup";
        Config: Record "EOS004 Service Config.";
        iStorage: Interface "EOS004 iStorage v2";
        ImportedFile: Text[250];
    begin
        if UPPERCASE(Filename) = UPPERCASE(NewFilename) then
            exit;

        EOSInbEDocSetup.Read();
        Config.Get(EOSInbEDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        iStorage.MoveFile(Filename, NewFilename);
    end;

    procedure CopyFile(Filename: Text[250]; NewFilename: Text[250]; ServerSide: Boolean): Boolean
    var
        InbDocSetup: Record "EOS Inb. EDoc. Setup";
        Config: Record "EOS004 Service Config.";
        iStorage: Interface "EOS004 iStorage v2";
    begin
        InbDocSetup.Get();
        Config.Get(InbDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        exit(iStorage.CopyFile(Filename, NewFilename) = Enum::"EOS004 Storage Response Status"::Success);
    end;

    procedure DeleteFile(FileName: Text[250]; ServerSide: Boolean): Boolean
    var
        InbDocSetup: Record "EOS Inb. EDoc. Setup";
        Config: Record "EOS004 Service Config.";
        iStorage: Interface "EOS004 iStorage v2";
    begin
        InbDocSetup.Get();
        Config.Get(InbDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        exit(iStorage.DeleteFile(FileName) = Enum::"EOS004 Storage Response Status"::Success);
    end;

    [Obsolete('Do not use, this procedure does nothing anymore.')]
    procedure BlobToTempFile(tempBlob: Codeunit "Temp Blob"; FileExt: text): Text[250];
    var
    // FileManagement: Codeunit "File Management";
    // tmpFileName: Text;
    begin
        // tmpFileName := FileManagement.ServerTempFileName(FileExt);
        // FileManagement.BLOBExportToServerFile(tempBlob, tmpFileName);
        // exit(Copystr(tmpFileName, 1, 250));
    end;

    procedure FileExists(FileName: Text[250]; ServerSide: Boolean): Boolean
    var
        // FileServerSide: DotNet File;
        // [RunOnClient]
        // FileClientSide: DotNet File;      
        InbDocSetup: Record "EOS Inb. EDoc. Setup";
        Config: Record "EOS004 Service Config.";
        iStorage: Interface "EOS004 iStorage v2";
        is: InStream;
    begin
        InbDocSetup.Get();
        Config.Get(InbDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        iStorage.SuppressError(true);
        exit(iStorage.ReadFile(filename, is) = Enum::"EOS004 Storage Response Status"::Success);
    end;

    procedure GetFileExtension(FileName: Text): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        exit('.' + FileManagement.GetExtension(FileName));
    end;

    procedure TestRemoteFilePath(IncElectrDocSetup: Record "EOS Inb. EDoc. Setup")
    var
        TestMessageLbl: Label '\%1, test: %2';
        MsgStr: Text[1024];
        TextOKLbl: Label 'Success';
        TextKOLbl: Label 'Failure';
    begin
        with IncElectrDocSetup do begin
            if "EOS Import Folder" <> '' then
                if TestRemoteFile("EOS Import Folder") then
                    MsgStr += StrSubstNo(TestMessageLbl, FIELDCAPTION("EOS Import Folder"), TextOKLbl)
                else
                    MsgStr += StrSubstNo(TestMessageLbl, FIELDCAPTION("EOS Import Folder"), TextKOLbl);

            if "EOS Archive Folder" <> '' then
                if TestRemoteFile("EOS Archive Folder") then
                    MsgStr += StrSubstNo(TestMessageLbl, FIELDCAPTION("EOS Archive Folder"), TextOKLbl)
                else
                    MsgStr += StrSubstNo(TestMessageLbl, FIELDCAPTION("EOS Archive Folder"), TextKOLbl);

            if "EOS Rejected Folder" <> '' then
                if TestRemoteFile("EOS Rejected Folder") then
                    MsgStr += StrSubstNo(TestMessageLbl, FIELDCAPTION("EOS Rejected Folder"), TextOKLbl)
                else
                    MsgStr += StrSubstNo(TestMessageLbl, FIELDCAPTION("EOS Rejected Folder"), TextKOLbl);
            if MsgStr <> '' then
                Message(MsgStr);
        end;
    end;

    procedure ImportXMLFolder(FolderName: Text[150]; var FileName: array[10000] of Text[150]): Integer
    var
        EOSInbEDocSetup: Record "EOS Inb. EDoc. Setup";
        //FileManagement: Codeunit "File Management";
        //Text001Msg: Label 'Select XML file to import';
        FilesListDirectory: List of [Text];
        k: Integer;
        i: Integer;
    begin
        EOSInbEDocSetup.Read();

        //if FolderName = '' then
        //    FolderName := CopyStr(FileManagement.BrowseForFolderDialog(Text001Msg, EOSInbEDocSetup."EOS Import Folder", false), 1, MaxStrLen(FolderName));

        for i := 1 to 10000 do
            FileName[i] := '';

        i := 0;

        k := GenerateFolderFilesList(FilesListDirectory, FolderName, 'p7m', FALSE, TRUE);

        IF k > 0 THEN
            FOR i := 1 TO k DO
                FileName[i] := Copystr(GetFilenameFromFileList(FilesListDirectory, i), 1, MaxStrLen(FileName[i]));

        k := GenerateFolderFilesList(FilesListDirectory, FolderName, 'xml', false, true);

        if k > 0 then
            for i := i + 1 to k do
                FileName[i] := CopyStr(GetFilenameFromFileList(FilesListDirectory, i), 1, MaxStrLen(FileName[i]));

        exit(k);
    end;

    procedure convertP7M(var filename: text[150])
    var
    begin
        if not ConvertP7M2XML(filename, false, filename) then
            filename := '';
    end;

    [TryFunction()]
    procedure ConvertP7M2XML(inFileName: Text[150]; DeleteSourceFile: Boolean; var outFileName: Text[150])
    var
        // P7MUtility: DotNet "EOS FE P7MUtils";
        Config: Record "EOS004 Service Config.";
        EOSInbEDocSetup: Record "EOS Inb. EDoc. Setup";
        P7MImpl: Codeunit "EOS004 P7M API Client";
        P7mFile, XmlFile : Codeunit "Temp Blob";
        iStorage: Interface "EOS004 iStorage v2";
        ExtPos: Integer;
        P7mOutS, XmlOutS : OutStream;
        P7mInS, XmlInS : InStream;
    // FileServerSide: DotNet File;
    begin
        EOSInbEDocSetup.Read();
        Config.Get(EOSInbEDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);

        ExtPos := StrPos(UpperCase(inFileName), '.P7M');
        if ExtPos = 0 then
            outFileName := inFileName;

        outFileName := Copystr(Copystr(inFileName, 1, ExtPos - 1), 1, MaxStrLen(outFileName));

        P7mFile.CreateOutStream(P7mOutS);

        iStorage.ReadFile(inFileName, P7mInS);
        CopyStream(P7mOutS, P7mInS);
        P7MImpl.Initialize(Config);
        P7MImpl.Extract(P7mFile, false, XmlFile);
        outFileName := outFileName + '.xml';
        iStorage.UploadFile(outFileName, XmlFile);

        if DeleteSourceFile then
            if FileExists(inFileName, TRUE) then
                iStorage.DeleteFile(inFileName);

        if ExtPos <> 0 then
            if FileExists(inFileName, TRUE) then
                iStorage.DeleteFile(inFileName);
    end;


    local procedure GenerateFolderFilesList(var FilesListDirectory: List of [Text]; PathFolder: Text[250]; ExtensionFilters: Text[250]; Recursive: Boolean; ServerSide: Boolean): Integer
    var
        TempFileLists: Record "Name/Value Buffer" temporary;
        Config: Record "EOS004 Service Config.";
        InbDocSetup: Record "EOS Inb. EDoc. Setup";
        FileManagement: Codeunit "File Management";
        iStorage: Interface "EOS004 iStorage v2";
        i: Integer;
        JArray: JsonArray;
        JToken, Result : JsonToken;
        JObj: JsonObject;
        JValue: JsonValue;
        Filename: Text;
    // SearchOption: DotNet "EOS FE SearchOption";
    begin
        InbDocSetup.Get();
        Config.Get(InbDocSetup."EOS Service Config Key");
        iStorage := Enum::"EOS004 iStorage Type"::"File System";
        iStorage.iStorageInit(Config);
        //es: ExtensionFilters:='*.pdf';
        // if Recursive then
        // else
        iStorage.GetFiles(InbDocSetup."EOS Import Folder" + '/', JArray);
        foreach JToken in JArray do begin
            // end;
            // for i := 0 to JArray.Count - 1 do begin
            //     JArray.Get(i, JToken);
            JToken.AsObject().Get('Name', Result);
            // JValue := Result.AsValue();
            Filename := Result.AsValue().AsText();
            if UpperCase(Filename).EndsWith(UpperCase(ExtensionFilters)) then
                if InbDocSetup."EOS Import Folder".EndsWith('/') then
                    FilesListDirectory.Add(InbDocSetup."EOS Import Folder" + Filename)
                else
                    FilesListDirectory.Add(InbDocSetup."EOS Import Folder" + '/' + Filename);
        end;

        exit(FilesListDirectory.Count());
    end;

    local procedure GetFilenameFromFileList(var FilesListDirectory: List of [Text]; Index: Integer): Text
    begin
        exit(Format(FilesListDirectory.Get(Index)));
    end;

    procedure GetFileName(FileName: Text): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        exit(FileManagement.GetFileName(FileName));
    end;
}