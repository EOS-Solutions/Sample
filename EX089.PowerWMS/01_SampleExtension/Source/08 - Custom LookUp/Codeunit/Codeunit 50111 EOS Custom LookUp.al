codeunit 50111 "EOS Custom LookUp"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS LookUp Values Mgmt.", OnGetCustomLookUpValuesList, '', false, false)]
    local procedure CU18060061_OnGetCustomLookUpValuesList(EOS089WMSLookUpListHeader: Record "EOS089 WMS LookUp List Header"; EmployeeNo: Code[20]; ActivityType: Enum "EOS089 WMS Activity Type"; ActivityAction: Code[20]; ParameterCode: Code[20]; SystemId: Guid; ActionParameters: JsonArray; var TempEOS089WMSLookUpListValue: Record "EOS089 WMS LookUp List Value" temporary; var IsHandled: Boolean)
    var
        EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header";
        EOS089WMSToolBox: Codeunit "EOS089 WMS ToolBox";
        JsonArray: JsonArray;
        ItemNo, BinCode : Code[20];
        VariantCode, LocationCode : Code[10];
        SerialNo, LotNo, PackageNo : Code[50];
        Quantity: Decimal;
        CurrLineNo: Integer;
    begin
        //if ActivityType <> "EOS089 WMS Activity Type"::EOSCreateBox then
        //    exit;

        //EOS089WMSCustomActHeader.GetBySystemId(SystemId);

        if EOS089WMSToolBox.GetLookUpInventoryInfoArray(ActionParameters, JsonArray) then begin
            ItemNo := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'itemNo', true, FieldType::Code);
            VariantCode := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'variantCode', false, FieldType::Code);
            LocationCode := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'locationCode', true, FieldType::Code);
            BinCode := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'binCode', false, FieldType::Code);
            SerialNo := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'serialNo', false, FieldType::Code);
            LotNo := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'lotNo', false, FieldType::Code);
            PackageNo := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'packageNo', false, FieldType::Code);
            Quantity := EOS089WMSToolBox.GetLookUpInventoryInfoValue(JsonArray, 'quantity', true, FieldType::Decimal);
        end;

        CurrLineNo += 1;
        TempEOS089WMSLookUpListValue.Init();
        TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
        TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
        TempEOS089WMSLookUpListValue."Value Code" := 'C';
        TempEOS089WMSLookUpListValue."Value Description" := 'C Value';
        TempEOS089WMSLookUpListValue.Insert();

        CurrLineNo += 1;
        TempEOS089WMSLookUpListValue.Init();
        TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
        TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
        TempEOS089WMSLookUpListValue."Value Code" := 'B';
        TempEOS089WMSLookUpListValue."Value Description" := 'B Value';
        TempEOS089WMSLookUpListValue.Insert();

        CurrLineNo += 1;
        TempEOS089WMSLookUpListValue.Init();
        TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
        TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
        TempEOS089WMSLookUpListValue."Value Code" := 'A';
        TempEOS089WMSLookUpListValue."Value Description" := 'A Value';
        TempEOS089WMSLookUpListValue.Insert();

        if ItemNo <> '' then begin
            CurrLineNo += 1;
            TempEOS089WMSLookUpListValue.Init();
            TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
            TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
            TempEOS089WMSLookUpListValue."Value Code" := ItemNo;
            TempEOS089WMSLookUpListValue."Value Description" := 'Item No: ' + ItemNo;
            TempEOS089WMSLookUpListValue.Insert();
        end;
        if VariantCode <> '' then begin
            CurrLineNo += 1;
            TempEOS089WMSLookUpListValue.Init();
            TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
            TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
            TempEOS089WMSLookUpListValue."Value Code" := VariantCode;
            TempEOS089WMSLookUpListValue."Value Description" := 'Variant Code: ' + VariantCode;
            TempEOS089WMSLookUpListValue.Insert();
        end;
        if LocationCode <> '' then begin
            CurrLineNo += 1;
            TempEOS089WMSLookUpListValue.Init();
            TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
            TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
            TempEOS089WMSLookUpListValue."Value Code" := LocationCode;
            TempEOS089WMSLookUpListValue."Value Description" := 'Location Code: ' + LocationCode;
            TempEOS089WMSLookUpListValue.Insert();
        end;
        if BinCode <> '' then begin
            CurrLineNo += 1;
            TempEOS089WMSLookUpListValue.Init();
            TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
            TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
            TempEOS089WMSLookUpListValue."Value Code" := BinCode;
            TempEOS089WMSLookUpListValue."Value Description" := 'Bin Code: ' + BinCode;
            TempEOS089WMSLookUpListValue.Insert();
        end;
        if Quantity <> 0 then begin
            CurrLineNo += 1;
            TempEOS089WMSLookUpListValue.Init();
            TempEOS089WMSLookUpListValue.Code := EOS089WMSLookUpListHeader.Code;
            TempEOS089WMSLookUpListValue."Line No." := CurrLineNo;
            TempEOS089WMSLookUpListValue."Value Code" := 'QTY';
            TempEOS089WMSLookUpListValue."Value Description" := 'Quantity: ' + Format(Quantity);
            TempEOS089WMSLookUpListValue.Insert();
        end;

        IsHandled := true;
    end;
}
