codeunit 50000 "EOS PdfTk Event Handler"
{
    var
        PdfTKLabelMsg: Label 'Merge files in one PDF';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Processors Mngt", 'OnDiscoverAvailableProcessors', '', true, false)]
    local procedure AdvDocProcessorsMerge(var AdvDocProcessor: Record "EOS AdvDoc Processor")
    var
        modInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(modInfo);
        AdvDocProcessor.Init();
        AdvDocProcessor."EOS Extension Guid" := modInfo.Id();
        AdvDocProcessor."EOS Code" := 'MergePdf';
        AdvDocProcessor."EOS Description" := CopyStr(PdfTKLabelMsg, 1, 50);
        AdvDocProcessor."EOS Default Enabled" := true;
        AdvDocProcessor."EOS Default Sort" := 50000;
        AdvDocProcessor.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"EOS AdvDoc Documents", 'OnAfterInitializeFileWithReportSelections', '', true, false)]
    local procedure OnAfterInitializeFileWithReportSelections(
        FromAdvDocDocuments: Record "EOS AdvDoc Documents";
        ReportSelections: Record "Report Selections";
        var AdvDocFiles: Record "EOS AdvDoc Files")
    begin
        AdvDocFiles."EOS Combine PDF on Email Send" := ReportSelections."EOS Combine PDF on Email Send";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvDoc Processors Mngt", 'OnCopyFlagsFromFileToFile', '', true, false)]
    local procedure OnCopyFlagsFromFileToFile_ZIP(var OldFileList: Record "EOS AdvDoc Files"; var NewAdvDocFiles: Record "EOS AdvDoc Files")
    begin
        NewAdvDocFiles."EOS Add to Email as ZIP" := OldFileList."EOS Add to Email as ZIP";
    end;

}