codeunit 61101 "EXA03 Body Replacement"
{
    // this example add a new "after line" showing current item tariff number on all documents

    // This event allows us to inject our custom report section into available report setup sections
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvRpt Layout Mngt", 'OnDiscoverAvailableSections', '', true, false)]
    local procedure OnDiscoverAvailableSections(var Sections: Record "EOS Adv Reporting Sections")
    var
        modInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(modInfo);

        Sections.Init();
        Sections."EOS Code" := 'BodyReplacement';  // <--- is a custom value end must be the same value inside "OnExecuteAfterLineProcessing"
        Sections."EOS Description" := 'Body Replacement';
        Sections."EOS Position" := Sections."EOS Position"::BodyFooter;
        Sections."EOS Default Enabled" := true;
        Sections."EOS Default Sort" := 20000;

        Sections.CopyFromModuleInfo(modInfo);
        Sections.Insert(true);
    end;

    //  Execute our custom code if the caller requests our execution
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvRpt Layout Mngt", 'OnExecuteBodyFooterProcessing', '', true, false)]
    local procedure OnExecuteBodyFooterProcessing(ExtensionGuid: Guid; ExtensionCode: Code[20]; DocVariant: Variant; var RBHeader: Record "EOS Report Buffer Header"; var RBLine: Record "EOS Report Buffer Line")
    var
        SalesHeader: Record "Sales Header";
        modInfo: ModuleInfo;
    begin
        // if the caller is calling another module we must exit
        if ExtensionCode <> UpperCase('BodyReplacement') then
            exit;

        NavApp.GetCurrentModuleInfo(modInfo);
        if ExtensionGuid <> modInfo.Id() then
            exit;

        //Only sales document
        if RBHeader."EOS Source Table ID" <> database::"Sales Header" then
            exit;

        //Only sales orders
        if RBHeader."EOS Source Subtype" <> SalesHeader."Document Type"::Order then
            exit;

        //RBLine is temporary so we can do whatever we want
        RBLine.Reset();
        RBLine.DeleteAll();

        RBLine.Init();
        RBLine."EOS Entry ID" := RBHeader."EOS Entry ID";
        RBLine."EOS Source Table ID" := Database::"Sales Line";
        RBLine."EOS Line type" := RBLine."EOS Line type"::EOSDocumentLine;

        //it's not necessary to manually handle "Line No." because "AppendLine" method always adds lines at the and of current dataset.
        RBLine."EOS Description" := 'This is a replacement line 1';
        RBLine.Appendline(RBHeader);
        RBLine."EOS Description" := 'This is a replacement line 2';
        RBLine.Appendline(RBHeader);
        RBLine."EOS Description" := 'This is a replacement line 3';
        RBLine.Appendline(RBHeader);
    end;
}