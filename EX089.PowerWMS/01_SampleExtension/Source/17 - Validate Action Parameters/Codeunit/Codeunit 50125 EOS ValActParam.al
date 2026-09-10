
// 1 - Add "Item Information" activity to an user
// 2 - Create a new activity action named "ITEM_CALCULON"
// 3 - Add three parameters to the action:
// //    - P1: the first number, Decimal type, mandatory, validate enabled
// //    - P2: the second number, Decimal type, mandatory, validate enabled
// //    - RESULT: the result of the calculation, Decimal type, mandatory, validate disabled

codeunit 50125 "EOS ValActParam"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Task Mgmt.", OnExecuteActivityAction, '', false, false)]
    local procedure CU18060020_OnExecuteActivityAction(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; var ReturnResult: Enum "EOS089 WMS Activity Result"; var ReturnMessage: Text; var ScanId: Guid; var IsHandled: Boolean)
    var
        EOS089WMSToolBox: Codeunit "EOS089 WMS ToolBox";
        JsonArray: JsonArray;
        ParamValue: Decimal;
        OtherParamValue: Decimal;
        Result: Decimal;
    begin
        if IsHandled then
            exit;

        // If nothing handle the action, generic error occurs
        if EOS089WMSActivityEntry."Activity Type" <> Enum::"EOS089 WMS Activity Type"::"Item Information" then // Check the right activity
            exit;

        // Return is ok by default, you can throw an error or return the error status (first option is better)
        ReturnMessage := '';
        ReturnResult := Enum::"EOS089 WMS Activity Result"::Completed;

        IsHandled := false;
        case EOS089WMSActivityEntry."Activity Action" of
            'ITEM_CALCULON':
                begin
                    // Get parameters from payload
                    if EOS089WMSToolBox.GetActivityActionParametersArray(EOS089WMSActivityEntry.GetPayloadAsJsonObject(), JsonArray) then begin
                        ParamValue := EOS089WMSToolBox.GetActivityActionParameterValue(JsonArray, 'P1', true, FieldType::Decimal);
                        OtherParamValue := EOS089WMSToolBox.GetActivityActionParameterValue(JsonArray, 'P2', true, FieldType::Decimal);
                        Result := EOS089WMSToolBox.GetActivityActionParameterValue(JsonArray, 'RESULT', true, FieldType::Decimal);
                    end;

                    // Use parameters
                    if Result <> (ParamValue * OtherParamValue) then
                        Error('The result is not correct! %1 * %2 = %3, but the result is %4', ParamValue, OtherParamValue, (ParamValue * OtherParamValue), Result)
                    else
                        ReturnMessage := StrSubStNo('Yep %1 * %2 = %3, as %4', ParamValue, OtherParamValue, (ParamValue * OtherParamValue), Result);


                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Management", OnGetActionParametersDefaultValues, '', false, false)]
    local procedure CU18060015_OnGetActionParametersDefaultValues(ActivityType: Enum "EOS089 WMS Activity Type"; ActivityAction: Code[20]; JsonPayload: JsonObject; var ReturnValues: JsonObject; var IsHandled: Boolean)
    var
    begin
        if IsHandled then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Management", OnValidateActionParameter, '', false, false)]
    local procedure CU18060015__OnValidateActionParameter(ActivityType: Enum "EOS089 WMS Activity Type"; ActivityAction: Code[20]; ParameterCode: Code[20]; ParameterValue: Variant; JsonPayload: JsonObject; var ReturnValues: JsonObject; var IsHandled: Boolean)
    var
        EOS089WMSToolBox: Codeunit "EOS089 WMS ToolBox";
        JsonArray: JsonArray;
        ParamValue: Decimal;
        OtherParamValue: Decimal;
        Result: Decimal;
        JsonArray2: JsonArray;
        JsonObject: JsonObject;
    begin
        if IsHandled then
            exit;

        // If nothing handle the action, generic error occurs
        if ActivityType <> Enum::"EOS089 WMS Activity Type"::"Item Information" then // Check the right activity
            exit;

        case ActivityAction of
            'ITEM_CALCULON':
                begin
                    ParamValue := ParameterValue;
                    EOS089WMSToolBox.GetActivityActionParametersArray(JsonPayload, JsonArray);

                    case ParameterCode of
                        'P1':
                            OtherParamValue := EOS089WMSToolBox.GetActivityActionParameterValue(JsonArray, 'P2', true, FieldType::Decimal);
                        'P2':
                            OtherParamValue := EOS089WMSToolBox.GetActivityActionParameterValue(JsonArray, 'P1', true, FieldType::Decimal);
                    end;

                    Result := ParamValue * OtherParamValue;

                    JsonObject.add('code', 'RESULT');
                    JsonObject.add('value', Result);
                    JsonArray2.Add(JsonObject);

                    if JsonArray2.Count() > 0 then
                        ReturnValues.Add('parameters', JsonArray2);

                    IsHandled := true;
                end;
        end;
    end;
}
