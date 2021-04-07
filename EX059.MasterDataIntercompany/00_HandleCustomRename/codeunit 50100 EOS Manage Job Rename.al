codeunit 50100 "EOS Manage Job Rename"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS MDI Security Checks", 'OnHandleExplicitRenameEvent', '', false, false)]
    local procedure OnHandleExplicitRenameEvent(TableNo: Integer; var IsHandled: Boolean);
    begin
        if TableNo = Database::Job then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterRenameEvent', '', true, false)]
    local procedure Job_OnAfterRenameEvent(var Rec: Record Job; var xRec: Record Job)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        MDISecurityChecks: Codeunit "EOS MDI Security Checks";
        RecRef: RecordRef;
        xRecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(Rec, RecRef);
        DataTypeManagement.GetRecordRef(xRec, xRecRef);

        MDISecurityChecks.HandleRecordRename(RecRef, xRecRef);
    end;

}