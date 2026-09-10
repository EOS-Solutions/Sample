codeunit 50123 "EOS Custom Field Subs."
{
    // Custom field "FAKEDESC" on the Sales Shipment activity:
    // 1) Show the description + description 2 of the line
    // 2) On edit/validate raise a placeholder error

    var
        FakeDescFieldCodeLbl: Label 'FAKEDESC', Locked = true;
        ValidatePlaceholderErr: Label 'Validation of field %1 is not implemented yet.', Comment = '%1 = Field Code';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS User Activity Mgmt.", OnManageUserActivityField, '', false, false)]
    local procedure OnManageUserActivityField(EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; SourceRecordRef: RecordRef; UserActivityField: Record "EOS089 WMS User Act. Field" temporary; var FieldValue: Variant; var IsHandled: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if IsHandled then
            exit;

        if UserActivityField."Field Code" <> FakeDescFieldCodeLbl then
            exit;

        if SourceRecordRef.Number <> Database::"Sales Line" then
            exit;

        SourceRecordRef.SetTable(SalesLine);
        FieldValue := SalesLine.Description + ' ' + SalesLine."Description 2";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Add. Fields Mgmt.", OnValidateCustomField, '', false, false)]
    local procedure OnValidateCustomField(EmployeeNo: Code[20]; EOS089WMSUserActField: Record "EOS089 WMS User Act. Field"; var RecordRef: RecordRef; NewValue: Text; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        if EOS089WMSUserActField."Field Code" <> FakeDescFieldCodeLbl then
            exit;

        Error(ValidatePlaceholderErr, EOS089WMSUserActField."Field Code");
    end;
}
