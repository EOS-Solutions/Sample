codeunit 50000 "EOS074.02 EDI File System Mgt."
{

    procedure GetFilename(EDIMsgHeader: Record "EOS074 EDI Message Header"): Text
    var
        EDIMsgSetup: Record "EOS074 EDI Message Setup";
        fName: Text;
        s: Text;
        placeholder: Text;
        strIncLenght: Integer;
        tmpFileName: Text;
        tmpIncreasedValue: Text;
        isHandled: Boolean;
    begin
        OnBeforeGetFilename(EDIMsgHeader, fName, isHandled);
        if (isHandled) then exit(fName);

        if (EDIMsgSetup."Message Type" <> EDIMsgHeader."Message Type") or
           (EDIMsgSetup."EDI Group Code" <> EDIMsgHeader."EDI Group Code")
        then
            EDIMsgSetup.Get(EDIMsgHeader."Message Type", EDIMsgHeader."EDI Group Code");

        EDIMsgSetup.TestField("EOS074.02 File System Path");

        fName := EDIMsgSetup."EOS074.02 File System Path";

        s := fName;
        s := s.Replace('<DOC>', EDIMsgHeader."Reference No.");
        s := s.Replace('<DATE>', Format(Today, 0, '<Year4><Month,2><Day,2>'));
        s := s.Replace('<DATETIME>', Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours,2><Minutes,2><Seconds,2>'));


        if s.Contains('<INC') then begin

            placeholder := CopyStr(s, s.IndexOf('<INC'), s.IndexOf('>') - s.IndexOf('<INC') + 1);
            if placeholder.Contains(',') then
                Evaluate(strIncLenght, CopyStr(placeholder, placeholder.IndexOf(',') + 1, placeholder.IndexOf('>') - placeholder.IndexOf(',') - 1));

            tmpIncreasedValue := PadStr('', strIncLenght, '0');
            repeat
                tmpIncreasedValue := IncStr(tmpIncreasedValue);
                tmpFileName := s.Replace(placeholder, tmpIncreasedValue);
            until not file.Exists(tmpFileName);

            s := tmpFileName;
        end;

        fName := s;
        OnAfterGetFilename(EDIMsgHeader, fName);
        exit(fName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS074 EDI Management", 'OnBeforeExportFile', '', true, false)]
    local procedure OnBeforeExportFile_CreateFile(EDIMsgSetup: Record "EOS074 EDI Message Setup";
                                                    var EDIMsgHeader: Record "EOS074 EDI Message Header";
                                                    var Handled: Boolean)
    var
        EDIFile: Record "EOS074 EDI File";
        EDILine: Record "EOS074 EDI Message Line";
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        FileContent: BigText;
        Filename: Text;
        Os: OutStream;
        NoLinesErr: label 'No lines found for EDI message %1 %2.';
    begin
        Filename := GetFilename(EDIMsgHeader);

        EDILine.SetRange("Message Type", EDIMsgHeader."Message Type");
        EDILine.SetRange("Message No.", EDIMsgHeader."No.");
        if EDILine.IsEmpty() then
            Error(NoLinesErr, EDIMsgHeader."Message Type", EDIMsgHeader."No.");

        TempBlob.CreateOutStream(Os);

        if EDIMsgSetup."XMLport-ID" <> 0 then
            XmlPort.Export(EDIMsgSetup."XMLport-ID", Os, EDILine)
        else begin
            if EDILine.FindSet() then
                repeat
                    FileContent.AddText(EDILine.GetText());
                until EDILine.Next() = 0;

            FileContent.Write(Os);
        end;
        //Filename := FileMgt.ServerTempFileName('.txt');
        FileMgt.BLOBExportToServerFile(TempBlob, Filename);
        //FileMgt.DownloadToFile(ServerFileName, Filename);

        EDIMsgHeader.Status := EDIMsgHeader.Status::Exported;
        EDIMsgHeader.Modify();

        EDIFile.Init();
        EDIFile."Message Type" := EDIMsgHeader."Message Type";
        EDIFile."Message No." := EDIMsgHeader."No.";
        EDIFile.Type := EDIFile.Type::Export;
        EDIFile.Creation := CurrentDateTime;
        EDIFile."Creation By" := CopyStr(UserId(), 1, MaxStrLen(EDIFile."Creation By"));
        EDIFile."EOS074.02 Path" := CopyStr(Filename, 1, MaxStrLen(EDIFile."EOS074.02 Path"));
        EDIFile.Insert(true);

        Handled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS074 EDI Management", 'OnBeforeInsertEDIFile', '', true, false)]
    local procedure OnBeforeInsertEDIFile_InsertPath(Filename: Text; var EDIFile: Record "EOS074 EDI File")
    begin
        if StrLen(filename) > MaxStrLen(EDIFile."EOS074.02 Path") then
            EDIFile."EOS074.02 Path" := CopyStr(Filename.Substring(StrLen(Filename) - MaxStrLen(EDIFile."EOS074.02 Path")), 1, MaxStrLen(EDIFile."EOS074.02 Path"))
        else
            EDIFile."EOS074.02 Path" := CopyStr(Filename, 1, MaxStrLen(EDIFile."EOS074.02 Path"));
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS074 EDI Management", 'OnBeforeBufferInsert', '', true, false)]
    local procedure OnBeforeBufferInsert_InsertFilePath(var Buffer: Record "EOS074 EDI Docum. Check Buffer"; var EDIFile: Record "EOS074 EDI File")
    begin
        if EDIFile.FindLast() then
            Buffer."EOS074.02 FILE - File Path" := EDIFile."EOS074.02 Path";
    end;


    [EventSubscriber(ObjectType::XmlPort, XmlPort::"EOS074 EDI Import", 'OnBeforeEDIFileExchangeInsert', '', true, false)]
    local procedure OnAfterEDIFileExchangeInsert_InsertPath(Filename: Text; var EDIFileExchange: Record "EOS074 EDI File")
    begin
        EDIFileExchange."EOS074.02 Path" := CopyStr(Filename, 1, MaxStrLen(EDIFileExchange."EOS074.02 Path"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS074 EDI Try-Accept Message", 'OnAfterImportFile', '', true, false)]
    local procedure OnAfterImportFile(StreamIdentifier: Text; EDIHeaderMess: Record "EOS074 EDI Message Header"; var EdiFileExchange: Record "EOS074 EDI File")
    var
        EDIMessageTypeSetupL: Record "EOS074 EDI Message Setup";
        FileMgt: Codeunit "File Management";
    begin
        EdiFileExchange."EOS074.02 Path" := CopyStr(StreamIdentifier, 1, MaxStrLen(EdiFileExchange."EOS074.02 Path"));
    end;

    /// <summary>
    /// Raised after the filename for a given EDI message header has been determined.
    /// </summary>
    /// <param name="EDIMsgHeader">The EDI message heaeder</param>
    /// <param name="FileName">The filename. You can override this to change the filename.</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterGetFilename(EDIMsgHeader: Record "EOS074 EDI Message Header"; var FileName: Text)
    begin
    end;

    /// <summary>
    /// Raised before the filename for a given EDI message header is determined.
    /// </summary>
    /// <param name="EDIMsgHeader">The EDI message heaeder</param>
    /// <param name="FileName">The filename. You can override this to change the filename.</param>
    /// <param name="Handled">Gets or sets if this event has been completely handled.</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetFilename(EDIMsgHeader: Record "EOS074 EDI Message Header"; var FileName: Text; var Handled: Boolean)
    begin
    end;

}