codeunit 50100 "EOS MyCodeunit ECS"
{
    [EventSubscriber(ObjectType::Report, Report::"EOS Combine Shipments", OnInsertRequestPageFieldsAsJson, '', false, false)]
    local procedure "EOS Combine Shipments_OnInsertRequestPageFieldsAsJson"(var Sender: Report "EOS Combine Shipments"; var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextReaderWriter.WriteStringProperty('GenericCustomPageField', Sender.GetGenericCustomPageField());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS050 Try Interfaces", OnAfterSetParameters, '', false, false)]
    local procedure "EOS050 Try Interfaces_OnAfterSetParameters"(var CombineShipment: Report "EOS Combine Shipments"; var InvSessions: Record "EOS050 Invoicing Session")
    var
        genericCustomPageFieldCode: Code[5];
        genericCustomPageField: Text;
    begin
        InvSessions.GetRequestPageFields('GenericCustomPageField', genericCustomPageField);
        Evaluate(genericCustomPageFieldCode, genericCustomPageField);
        CombineShipment.SetGenericCustomPageField(genericCustomPageFieldCode);
    end;
}