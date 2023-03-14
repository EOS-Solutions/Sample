codeunit 50001 "EOS PdfTk Processor"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Processors Mngt", 'OnExecuteProcessor', '', true, false)]
    local procedure OnExecuteProcessorPDFTK(AdvDocRequest: Record "EOS AdvDoc Request";
                                            AdvDocDocuments: Record "EOS AdvDoc Documents";
                                            ReportSetup: Record "EOS Report Setup";
                                            ExtensionCode: Code[20];
                                            ExtensionGuid: Guid
                                            )
    var
        modInfo: ModuleInfo;
    begin
        if ExtensionCode <> UpperCase('MergePdf') then
            exit;

        NavApp.GetCurrentModuleInfo(modInfo);
        if ExtensionGuid <> modInfo.Id() then
            exit;

        if AdvDocRequest."EOS Request Type" = AdvDocRequest."EOS Request Type"::EOSDownloadPDF then
            MergeFiles(AdvDocRequest, AdvDocDocuments, true)
        else
            MergeFiles(AdvDocRequest, AdvDocDocuments, false);
    end;

    procedure MergeFiles(AdvDocRequest: Record "EOS AdvDoc Request"; AdvDocDocuments: Record "EOS AdvDoc Documents"; IgnoreMergeFlag: Boolean)
    var
        AdvDocFiles2: Record "EOS AdvDoc Files";
        AdvDocFiles: Record "EOS AdvDoc Files";
        AdvDocFilesMerged: Record "EOS AdvDoc Files";
        AdvDocProcessorsMngt: Codeunit "EOS AdvDoc Processors Mngt";
        AdvMailRoutines: Codeunit "EOS Adv Mail Routines";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        IStreamPDF: InStream;
        OStream: OutStream;
        FirstFileNo: Integer;
        LastFileNo: Integer;
        CommonFileName: Text;
        FileName: Text;
        ServerTempFileName: Text;
        Files: DotNet GenericList1;
        pdftk: DotNet "EOSPdfTkWrapper";
    begin
        AdvDocFiles.Reset();
        AdvDocFiles.SetRange("EOS Request ID", AdvDocRequest."EOS ID");
        if AdvDocRequest."EOS Request Type" = AdvDocRequest."EOS Request Type"::EOSMultiMail then
            AdvDocFiles.SetRange("EOS Document Entry No.", AdvDocDocuments."EOS Entry No.")
        else begin
            AdvDocDocuments.SetRange("EOS Request ID", AdvDocRequest."EOS ID");
            if AdvDocDocuments.FindFirst() then;
        end;

        if not IgnoreMergeFlag then
            AdvDocFiles.SetRange("EOS Combine PDF on Email Send", true);

        AdvDocFiles.SetRange("EOS Processed", false);
        AdvDocFiles.SetRange("EOS File Extension", 'PDF');

        if AdvDocFiles.Count() in [0, 1] then
            exit;

        AdvDocFiles.SetCurrentKey("EOS Entry No.");
        AdvDocFiles.LockTable();
        AdvDocFiles.FindFirst();
        FirstFileNo := AdvDocFiles."EOS Entry No.";
        AdvDocFiles.FindLast();
        LastFileNo := AdvDocFiles."EOS Entry No.";

        AdvDocDocuments.InitializeFile(AdvDocFilesMerged);
        AdvDocFilesMerged."EOS DoNotDelete" := false;

        if AdvDocDocuments."EOS Filename" <> '' then
            AdvDocFilesMerged.SetFileName(FileManagement.GetFileNameWithoutExtension(AdvDocDocuments."EOS Filename"))
        else begin
            CommonFileName := AdvMailRoutines.FindCommonFileName(AdvDocFiles);
            if CommonFileName = '' then
                CommonFileName := 'Attachment';
            AdvDocFilesMerged.SetFileName(CommonFileName);
        end;

        AdvDocFilesMerged."EOS File Extension" := 'pdf';

        Files := Files.List();
        AdvDocFiles.SetRange("EOS Entry No.", FirstFileNo, LastFileNo);
        AdvDocFiles.SetAutoCalcFields("EOS Embedded Blob");

        AdvDocFiles.FindSet(true);
        repeat
            if AdvDocFiles."EOS Embedded Blob".HasValue() then begin
                ServerTempFileName := GetTempFilename('pdf');

                // export the file in a temp path (we are "onprem" se we are allowed to do it)
                AdvDocFiles."EOS Embedded Blob".CreateInStream(IStream);
                TempBlob.CreateOutStream(OStream);
                CopyStream(OStream, IStream);
                FileManagement.BLOBExportToServerFile(TempBlob, ServerTempFileName);

                // add the file path to files varabile
                Files.Add(ServerTempFileName);
            end;
        until AdvDocFiles.Next() = 0;

        // gives the files variable to PDFtk to concatenate the files
        pdftk := pdftk.PdfTkWrapper();
        IStreamPDF := pdftk.ConcatenateFilesAL(Files);

        // flush merged PDF to single temp file
        TempBlob.CreateOutStream(OStream);
        CopyStream(OStream, IStreamPDF);

        AdvDocFiles.FindFirst();
        AdvDocFiles2.Copy(AdvDocFiles);
        AdvDocProcessorsMngt.OnCopyFlagsFromFileToFile(AdvDocFiles2, AdvDocFilesMerged);

        Clear(IStream);
        Clear(OStream);

        AdvDocFiles.SetRange("EOS DoNotDelete", false);
        AdvDocFiles.DeleteAll();
        AdvDocFiles.SetRange("EOS DoNotDelete");
        AdvDocFiles.ModifyAll("EOS Processed", true);
        AdvDocFilesMerged."EOS Embedded Blob".CreateOutStream(OStream);
        TempBlob.CreateInStream(IStream);
        CopyStream(OStream, IStream);

        AdvDocFilesMerged."EOS DoNotDelete" := false;
        AdvDocFilesMerged."EOS Processed" := false;
        AdvDocFilesMerged.Insert();

        // deletes to-merge files
        foreach FileName in Files do
            FileManagement.DeleteServerFile(FileName);
    end;

    procedure GetTempFilename(Extension: Text): Text
    var
        DateTimeValue: Text;
        Path: Text;
        RandomGUIDText: Text;
    begin
        //ORG:EXIT(GetTempPath() + '\' + FORMAT(CREATEGUID) + '.pdf');
        // using date order here is crucial! why?
        // because NAV creats all PDFs, one after the other, and then passes all the created files to PDFtk
        // but PDFtk fetches them using operating system file sorting. using a timestamp in the filename ensures correct sorting.
        DateTimeValue := Format(CurrentDateTime(), 0, 9);
        DateTimeValue := ConvertStr(DateTimeValue, '\/:*?+<>', '________');
        RandomGUIDText := CopyStr(DelChr(Format(CreateGuid()), '<=>', '{}-'), 1, 8);

        Extension := DelChr(Extension, '<>', '.');
        if Extension = '' then
            Extension := 'pdf';

        Path := System.TemporaryPath();
        if Path = '' then
            exit;

        if Path[StrLen(Path)] <> '\' then
            Path += '\';

        Path += StrSubstNo('%1_%2_%3.%4', SessionId(), DateTimeValue, RandomGUIDText, Extension);

        exit(Path);
    end;
}