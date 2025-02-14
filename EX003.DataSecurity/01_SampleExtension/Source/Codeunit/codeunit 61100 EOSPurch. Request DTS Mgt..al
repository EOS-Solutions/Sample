codeunit 61100 "EOSPurch. Request DTS Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DS Management", 'OnDiscoverDSFunctions', '', true, false)]
    local procedure DS_ChangeRDAStatus(var DataSecurityFunctions: Record "EOS DS Functions")
    var
        PurchReqHeader: Record "EOS Purch. Request Header";
        i: Integer;
        FunctionTxt: Label 'Purch. Req - Status = %1';
    begin
        for i := PurchReqHeader."EOS Status"::Open to PurchReqHeader."EOS Status"::Closed do begin
            PurchReqHeader."EOS Status" := i;
            DataSecurityFunctions.Init();
            case i of
                0:
                    DataSecurityFunctions.Code := 'RDA_OP';
                1:
                    DataSecurityFunctions.Code := 'RDA_AA';
                2:
                    DataSecurityFunctions.Code := 'RDA_AP';
                3:
                    DataSecurityFunctions.Code := 'RDA_CL';
            end;
            DataSecurityFunctions.Description := CopyStr(StrSubstNo(FunctionTxt, PurchReqHeader."EOS Status"), 1, MaxStrLen(DataSecurityFunctions.Description));
            DataSecurityFunctions.Type := DataSecurityFunctions.Type::Exec;
            DataSecurityFunctions."Table ID" := DATABASE::"EOS Purch. Request Header";
            DataSecurityFunctions."Table Option Type" := 0;
            if not DataSecurityFunctions.Insert() then DataSecurityFunctions.Modify();
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DS Management", 'OnExecuteDSFunction', '', true, false)]
    local procedure DS_ChangeRDAStatus_Execute(var DataSecurityFunctions: Record "EOS DS Functions"; var RecRef: RecordRef; TableOptionType: Integer; UseOptionType: Boolean; var ContinueExecution: Boolean)
    var
        PurchReqHeader: Record "EOS Purch. Request Header";
        NewStatus: Integer;
    begin
        if RecRef.Number() <> DATABASE::"EOS Purch. Request Header" then
            exit;

        case DataSecurityFunctions.Code of

            'RDA_OP':
                NewStatus := 0;

            'RDA_AA':
                NewStatus := 1;

            'RDA_AP':
                NewStatus := 2;

            'RDA_CL':
                NewStatus := 3;

            else
                exit;
        end;

        RecRef.SetTable(PurchReqHeader);
        PurchReqHeader.Validate("EOS Status", NewStatus);
        if PurchReqHeader.Modify() then;
        RecRef.GetTable(PurchReqHeader);

        ContinueExecution := true;
    end;

    //Modify Record EOS Purch. Request Header/EOS Purch. Req. Header Archive --- use this event to handle permissions on custom table
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS003 Tables Operations", 'OnBeforeModifyRecord', '', true, false)]
    local procedure EOS003TablesOperations_OnBeforeModifyRecord(var RecRef: RecordRef; var ModifyValue: Boolean; var IsHandled: Boolean)
    begin
        if not (RecRef.Number() in [Database::"EOS Purch. Request Header", Database::"EOS Purch. Req. Header Archive"]) then
            exit;
        if RecRef.IsTemporary then
            exit;
        IsHandled := true;
        ModifyValue := RecRef.Modify();
    end;


}
