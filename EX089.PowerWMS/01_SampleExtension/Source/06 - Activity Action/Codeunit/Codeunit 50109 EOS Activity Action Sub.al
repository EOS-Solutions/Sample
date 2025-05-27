
// 1 - Add "Item Information" activity to an user
// 2 - Create a new activity action named "ITEM_PRINTLABELS"
// 3 - Add two parameters to the action:
// //    - NUMBER: the number of labels to print, Integer type, mandatory
// //    - TYPE: the label type to print, Text type, optional

codeunit 50109 "EOS Activity Action Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Task Mgmt.", OnExecuteActivityAction, '', false, false)]
    local procedure CU18060020_OnExecuteActivityAction(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; var ReturnResult: Enum "EOS089 WMS Activity Result"; var ReturnMessage: Text; var ScanId: Guid; var IsHandled: Boolean)
    var
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        ParameterValue: Variant;
        LabelsCount: Integer;
        LabelsType: Text;
    begin
        // If nothing handle the action, generic error occurs
        if EOS089WMSActivityEntry."Activity Type" <> Enum::"EOS089 WMS Activity Type"::"Item Information" then // Check the right activity
            exit;

        // Return is ok by default, you can throw an error or return the error status (first option is better)
        ReturnMessage := '';
        ReturnResult := Enum::"EOS089 WMS Activity Result"::Completed;

        IsHandled := false;
        case EOS089WMSActivityEntry."Activity Action" of
            'ITEM_PRINTLABELS':
                begin
                    // Get parameters from payload
                    EOS089WMSActivityEntry.GetPayloadAsJsonObject().Get('actionParameters', JsonToken);
                    JsonArray := JsonToken.AsArray();

                    // Retrieve parameters
                    if GetParameterValue(JsonArray, 'NUMBER', true, FieldType::Integer, ParameterValue) then
                        LabelsCount := ParameterValue;

                    if GetParameterValue(JsonArray, 'TYPE', false, FieldType::Text, ParameterValue) then
                        LabelsType := ParameterValue;

                    // Use parameters
                    if LabelsCount < 0 then
                        Error('I want to see how you can print a negative number of labels!');

                    if LabelsCount = 0 then
                        Error('You must specify the number of labels to print.');

                    if LabelsType = '' then
                        ReturnMessage := 'No label type specified, using default label type.'
                    else
                        ReturnMessage := StrSubStNo('Printed %1 %2 label', LabelsCount, LabelsType);

                    if (LabelsCount > 1) and (LabelsType <> '') then
                        ReturnMessage := ReturnMessage + 's';

                    IsHandled := true;
                end;
        end;
    end;

    local procedure GetParameterValue(JsonArray: JsonArray; ParameterName: Code[20]; Mandatory: Boolean; FieldType: FieldType; var ParameterValue: Variant): Boolean
    var
        EOS089WMSToolBox: Codeunit "EOS089 WMS ToolBox";
        JsonToken, JsonToken2 : JsonToken;
        JsonObject: JsonObject;
    begin
        Clear(JsonObject);
        foreach JsonToken in JsonArray do
            if JsonToken.IsObject() then begin
                JsonObject := JsonToken.AsObject();
                if JsonObject.Get('code', JsonToken2) then
                    if JsonToken2.IsValue() then
                        if JsonToken2.AsValue().AsCode() = ParameterName then begin
                            ParameterValue := EOS089WMSToolBox.GetJsonValueAs(JsonObject, 'inputValue', Mandatory, FieldType);
                            exit(true);
                        end;
            end;

        exit(false);
    end;
}
