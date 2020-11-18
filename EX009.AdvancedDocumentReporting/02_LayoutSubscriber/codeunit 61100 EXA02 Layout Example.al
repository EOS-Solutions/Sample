codeunit 61100 "EXA02 Layout Example"
{
    // this example add a new "after line" showing current item tariff number on all documents

    // This event allows us to inject our custom report section into available report setup sections
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvRpt Layout Mngt", 'OnDiscoverAvailableSections', '', true, false)]
    local procedure OnDiscoverAvailableSections(var Sections: Record "EOS Adv Reporting Sections")
    var
        TariffNumber: Record "Tariff Number";
        modInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(modInfo);

        Sections.Init();
        Sections."EOS Code" := 'TariffNo';  // <--- is a custom value end must be the same value inside "OnExecuteAfterLineProcessing"
        Sections."EOS Description" := CopyStr(TariffNumber.TableCaption(), 1, 50);
        Sections."EOS Position" := Sections."EOS Position"::AfterLine;
        Sections."EOS Default Enabled" := true;
        Sections."EOS Default Sort" := 20000;

        Sections.CopyFromModuleInfo(modInfo);
        Sections.Insert(true);
    end;

    //  Execute our custom code if the caller requests our execution
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvRpt Layout Mngt", 'OnExecuteAfterLineProcessing', '', true, false)]
    local procedure OnExecuteAfterLineProcessing(DocVariant: Variant; ExtensionCode: Code[20]; ExtensionGuid: Guid; var LineRecRef: RecordRef; RBHeader: Record "EOS Report Buffer Header"; var RBLine: Record "EOS Report Buffer Line")
    var
        Item: Record "Item";
        RBLine2: Record "EOS Report Buffer Line" temporary;
        modInfo: ModuleInfo;
    begin
        // if the caller is calling another module we must exit
        if ExtensionCode <> UpperCase('TariffNo') then
            exit;

        NavApp.GetCurrentModuleInfo(modInfo);
        if ExtensionGuid <> modInfo.Id() then
            exit;

        if RBLine."EOS Type" <> RBLine."EOS Type"::Item then
            exit;

        if RBLine."EOS No." = '' then
            exit;

        if not Item.Get(RBLine."EOS No.") then
            exit;

        if Item."Tariff No." = '' then
            exit;

        RBLine2.copy(RBLine, true); //creating a new temp rbline instance

        RBLine2.Init();
        RBLine2."EOS Line No." := 0;
        RBLine2."EOS Type" := RBLine2."EOS Type"::" ";
        RBLine2."EOS No." := '';
        RBLine2."EOS Description" := Item.FieldCaption("Tariff No.") + ': ' + Item."Tariff No.";
        RBLine2."EOS Extension Code" := ExtensionCode;
        RBLine2."EOS Extension Guid" := ExtensionGuid;
        RBLine2."EOS Line type" := RBLine2."EOS Line type"::EOSLineComment;
        RBLine2.Appendline(RBHeader);
    end;
}