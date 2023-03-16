Codeunit 50001 "EOS074.02 EDI Helper Functions"
{

    [Obsolete('No longer supported.')]
    procedure MoveFileToLocalPath(TMPFilePath: Text[1024]; DestFilePath: Text[1024]) Status: Boolean
    begin
        exit(false);
    end;


    procedure GetDirectoryFilesList(PathFolder: Text; var NameValueBuffer: Record "Name/Value Buffer"): Integer
    var
        FileManagement: Codeunit "File Management";
    begin
        FileManagement.GetServerDirectoryFilesList(NameValueBuffer, PathFolder);
        exit(NameValueBuffer.Count);
    end;


    [EventSubscriber(ObjectType::Report, Report::"EOS074 Create EDI Messages In", 'OnBeforeGetFile', '', true, false)]
    local procedure AssignTotFile(EDIMessageSetup: Record "EOS074 EDI Message Setup"; var TotFile: Integer; var TempNameValueBuffer: Record "Name/Value Buffer"; var IsHandled: Boolean)
    var
        EDIHelperFunctions: Codeunit "EOS074.02 EDI Helper Functions";
    begin
        Clear(EDIHelperFunctions);
        EDIMessageSetup.TestField("EOS074.02 File System Path");

        TotFile := EDIHelperFunctions.GetDirectoryFilesList(EDIMessageSetup."EOS074.02 File System Path", TempNameValueBuffer);
    end;


    [EventSubscriber(ObjectType::Report, Report::"EOS074 Create EDI Messages In", 'OnBeforeModifyEDIFileExchange', '', true, false)]
    local procedure OnBeforeModifyEDIFileExchange(EDIMessageSetup: Record "EOS074 EDI Message Setup"; ListNameFile: Text; var EDIFileExchange: Record "EOS074 EDI File"; EDIMessageHeader: Record "EOS074 EDI Message Header")
    begin
        EDIFileExchange."EOS074.02 Path" := EDIMessageSetup."EOS074.02 File System Path" + '\' + EDIMessageHeader."No." + '_' + ListNameFile;
        EDIFileExchange.Modify(true);
    end;


    [EventSubscriber(ObjectType::Report, Report::"EOS074 Create EDI Messages In", 'OnBeforeModifyCheckEDIDocument', '', true, false)]
    local procedure OnBeforeModifyCheckEDIDocument(EDIMessageSetup: Record "EOS074 EDI Message Setup"; ListNameFile: Text; var CheckEDIDocument: Record "EOS074 EDI Docum. Check Buffer")
    begin
        CheckEDIDocument."EOS074.02 FILE - File Path" := EDIMessageSetup."EOS074.02 File System Path" + '\' + ListNameFile;
    end;

    [EventSubscriber(ObjectType::Report, Report::"EOS074 Create EDI Messages In", 'OnBeforeLoadFile', '', true, false)]
    local procedure OnBeforeLoadFile(EDIMessageSetup: Record "EOS074 EDI Message Setup"; var Handled: Boolean; ListNameFile: Text; var TempBlob: Codeunit "Temp Blob"; var FileIdentfier: Text)
    var
        FileManagement: Codeunit "File Management";
    begin
        FileManagement.BLOBImportFromServerFile(TempBlob, EDIMessageSetup."EOS074.02 File System Path" + '\' + ListNameFile);
        FileIdentfier := EDIMessageSetup."EOS074.02 File System Path" + '\' + ListNameFile;

        Handled := true;
    end;

}