
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
        EOS089WMSToolBox: Codeunit "EOS089 WMS ToolBox";
        JsonArray: JsonArray;
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
                    if EOS089WMSToolBox.GetActivityActionParametersArray(EOS089WMSActivityEntry.GetPayloadAsJsonObject(), JsonArray) then begin
                        LabelsCount := EOS089WMSToolBox.GetActivityActionParameterValue(JsonArray, 'NUMBER', true, FieldType::Integer);
                        LabelsType := EOS089WMSToolBox.GetActivityActionParameterValue(JsonArray, 'TYPE', false, FieldType::Text);
                    end;

                    // Use parameters
                    if LabelsCount < 0 then
                        Error('I want to see how you can print a negative number of labels!');

                    if LabelsCount = 0 then
                        Error('You must specify the number of labels to print.');

                    if LabelsType = '' then
                        ReturnMessage := StrSubStNo('No label type specified, using default label type. Printed %1 label', LabelsCount)
                    else
                        ReturnMessage := StrSubStNo('Printed %1 %2 label', LabelsCount, LabelsType);

                    if (LabelsCount > 1) and (LabelsType <> '') then
                        ReturnMessage := ReturnMessage + 's';

                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Management", OnGetActionParametersDefaultValues, '', false, false)]
    local procedure CU18060015_OnGetActionParametersDefaultValues(ActivityType: Enum "EOS089 WMS Activity Type"; ActivityAction: Code[20]; JsonPayload: JsonObject; var ReturnValues: JsonObject; var IsHandled: Boolean)
    var
        EOS089WMSActActionParameter: Record "EOS089 WMS Act. Action Param.";
        JsonArray: JsonArray;
        JsonObject: JsonObject;
    begin
        if ActivityType <> Enum::"EOS089 WMS Activity Type"::"Item Information" then // Check the right activity
            exit;

        if ActivityAction <> 'ITEM_PRINTLABELS' then // Check the right action
            exit;

        EOS089WMSActActionParameter.Reset();
        EOS089WMSActActionParameter.SetRange(Activity, ActivityType);
        EOS089WMSActActionParameter.SetRange("Action Code", ActivityAction);
        if EOS089WMSActActionParameter.FindSet() then
            repeat
                Clear(JsonObject);
                case EOS089WMSActActionParameter.Code of
                    'NUMBER':
                        begin
                            JsonObject.add('code', EOS089WMSActActionParameter.Code);
                            JsonObject.add('value', 666);
                        end;
                    'TYPE':
                        begin
                            JsonObject.add('code', EOS089WMSActActionParameter.Code);
                            JsonObject.add('value', 'HUGE');
                        end;
                end;
                JsonArray.Add(JsonObject);
            until EOS089WMSActActionParameter.Next() = 0;

        if JsonArray.Count() > 0 then
            ReturnValues.Add('parameters', JsonArray);
    end;
}
