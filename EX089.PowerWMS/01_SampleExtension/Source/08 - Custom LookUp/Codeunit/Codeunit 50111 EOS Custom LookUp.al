codeunit 50111 "EOS Custom LookUp"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS LookUp Values Mgmt.", OnGetCustomLookUpValues, '', false, false)]
    local procedure CU18060061_OnGetCustomLookUpValues(EOS089WMSLookUpListHeader: Record "EOS089 WMS LookUp List Header"; EmployeeNo: Code[20]; ActivityType: Enum "EOS089 WMS Activity Type"; ActivityAction: Code[20]; ParameterCode: Code[20]; SystemId: Guid; ActionParameters: JsonArray; var TempTempEOS089WMSLookUpListLine: Record "EOS089 WMS LookUp List Line" temporary; var IsHandled: Boolean)
    var
        EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header";
        EOS089WMSToolBox: Codeunit "EOS089 WMS ToolBox";
        JsonArray: JsonArray;
        ItemNo, BinCode : Code[20];
        VariantCode, LocationCode : Code[10];
        SerialNo, LotNo, PackageNo : Code[50];
        Quantity: Decimal;
        CurrentSequence: Integer;
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

        CurrentSequence += 1;
        TempTempEOS089WMSLookUpListLine.Init();
        TempTempEOS089WMSLookUpListLine.Code := EOS089WMSCustomActHeader."No.";
        TempTempEOS089WMSLookUpListLine."Value Code" := 'C';
        TempTempEOS089WMSLookUpListLine."Value Description" := 'C Value';
        TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
        TempTempEOS089WMSLookUpListLine.Insert();

        CurrentSequence += 1;
        TempTempEOS089WMSLookUpListLine.Init();
        TempTempEOS089WMSLookUpListLine.Code := EOS089WMSCustomActHeader."No.";
        TempTempEOS089WMSLookUpListLine."Value Code" := 'B';
        TempTempEOS089WMSLookUpListLine."Value Description" := 'B Value';
        TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
        TempTempEOS089WMSLookUpListLine.Insert();

        CurrentSequence += 1;
        TempTempEOS089WMSLookUpListLine.Init();
        TempTempEOS089WMSLookUpListLine.Code := EOS089WMSCustomActHeader."No.";
        TempTempEOS089WMSLookUpListLine."Value Code" := 'A';
        TempTempEOS089WMSLookUpListLine."Value Description" := 'A Value';
        TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
        TempTempEOS089WMSLookUpListLine.Insert();

        if ItemNo <> '' then begin
            CurrentSequence += 1;
            TempTempEOS089WMSLookUpListLine.Init();
            TempTempEOS089WMSLookUpListLine.Code := ItemNo;
            TempTempEOS089WMSLookUpListLine."Value Code" := ItemNo;
            TempTempEOS089WMSLookUpListLine."Value Description" := 'Item No: ' + ItemNo;
            TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
            TempTempEOS089WMSLookUpListLine.Insert();
        end;
        if VariantCode <> '' then begin
            CurrentSequence += 1;
            TempTempEOS089WMSLookUpListLine.Init();
            TempTempEOS089WMSLookUpListLine.Code := VariantCode;
            TempTempEOS089WMSLookUpListLine."Value Code" := VariantCode;
            TempTempEOS089WMSLookUpListLine."Value Description" := 'Variant Code: ' + VariantCode;
            TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
            TempTempEOS089WMSLookUpListLine.Insert();
        end;
        if LocationCode <> '' then begin
            CurrentSequence += 1;
            TempTempEOS089WMSLookUpListLine.Init();
            TempTempEOS089WMSLookUpListLine.Code := LocationCode;
            TempTempEOS089WMSLookUpListLine."Value Code" := LocationCode;
            TempTempEOS089WMSLookUpListLine."Value Description" := 'Location Code: ' + LocationCode;
            TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
            TempTempEOS089WMSLookUpListLine.Insert();
        end;
        if BinCode <> '' then begin
            CurrentSequence += 1;
            TempTempEOS089WMSLookUpListLine.Init();
            TempTempEOS089WMSLookUpListLine.Code := BinCode;
            TempTempEOS089WMSLookUpListLine."Value Code" := BinCode;
            TempTempEOS089WMSLookUpListLine."Value Description" := 'Bin Code: ' + BinCode;
            TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
            TempTempEOS089WMSLookUpListLine.Insert();
        end;
        if Quantity <> 0 then begin
            CurrentSequence += 1;
            TempTempEOS089WMSLookUpListLine.Init();
            TempTempEOS089WMSLookUpListLine.Code := 'QTY';
            TempTempEOS089WMSLookUpListLine."Value Code" := 'QTY';
            TempTempEOS089WMSLookUpListLine."Value Description" := 'Quantity: ' + Format(Quantity);
            TempTempEOS089WMSLookUpListLine.Sequence := CurrentSequence;
            TempTempEOS089WMSLookUpListLine.Insert();
        end;

        IsHandled := true;
    end;
}
