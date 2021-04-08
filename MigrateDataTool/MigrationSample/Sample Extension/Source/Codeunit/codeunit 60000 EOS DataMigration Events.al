codeunit 60000 "EOS DataMigration Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS JSON Import Helper", 'OnRunImport', '', true, false)]
    local procedure OnRunImport(
        Buffer: Record "EOS JSON Import Buffer";
        sender: Codeunit "EOS JSON Import Helper";
        var ErrorMessage: Text;
        var Success: Boolean
    )
    var
        ImportHandler: Codeunit "EOS Additional Data Migration";
    begin
        if (Buffer."Import Id" <> ImportHandler.GetImportId()) then
            exit;

        ImportHandler.SetSender(sender);
        ClearLastError();
        if ImportHandler.Run(Buffer) then begin
            Success := true;
            ErrorMessage := '';

        end else begin
            Success := false;
            ErrorMessage := GetLastErrorText();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS JSON Import Helper", 'OnDiscoverImportHandlers', '', true, false)]
    local procedure OnDiscoverImportHandlers(var Buffer: Record "Name/Value Buffer")
    var
        ImportHandler: Codeunit "EOS Additional Data Migration";
        modInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(modInfo);
        Buffer.AddNewEntry(CopyStr(Format(ImportHandler.GetImportId()), 1, MaxStrLen(Buffer.Name)), CopyStr(modInfo.Name(), 1, MaxStrLen(Buffer.Name)));
    end;
}