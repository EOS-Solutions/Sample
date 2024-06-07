codeunit 50001 "EMA C/A Driver Example"
{
    TableNo = "EOS C/A Driver Code";

    trigger OnRun()
    begin
        if (Rec."EOS Code" = '') or (Rec."EOS Starting Date" = 0D) or (Rec."EOS Ending Date" = 0D) then
            exit;

        CASetup.Get();
        CASetup.TestField("EOS Cost Accounting Dimension");
        GLSetup.Get();

        MfgSetup.Get();
        MfgSetup.TestField("Show Capacity In");

        CreateDriverValue(Rec);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        CASetup: Record "EOS C/A Setup";
        MfgSetup: Record "Manufacturing Setup";
        TempValueEntry: Record "Value Entry" temporary;
        Text001Err: Label 'can be used only if %1 is equal to global dimension 1 or 2 in %2.';

    local procedure CreateDriverValue(DriverCode: Record "EOS C/A Driver Code")
    var
    begin
        case DriverCode."EOS Function No." of
            'KWCDC':
                CalcEnergy(DriverCode);
            'VALOREECON':
                CalcFixedAssetValue(DriverCode);
            else
                Error('Function not managed');
        end;
    end;

    local procedure CalcEnergy(DriverCode: Record "EOS C/A Driver Code")
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        WorkCenter: Record "Work Center";
        DriverCode2: Record "EOS C/A Driver Code";
        CalendarMgt: Codeunit "Shop Calendar Management";
        DriverObjectCode: Code[20];
        Qty, Amt : Decimal;
    begin
        DeleteDriverValue(DriverCode."EOS Code");

        CapacityLedgerEntry.SetCurrentKey("Item No.", "Order Type", "Order No.", "Posting Date", Subcontracting);
        CapacityLedgerEntry.SetRange("Order Type", CapacityLedgerEntry."Order Type"::Production);
        CapacityLedgerEntry.SetRange("Posting Date", DriverCode."EOS Starting Date", DriverCode."EOS Ending Date");
        //CapLedgEntry.SetRange(Type,CapLedgEntry.Type::"Machine Center");
        DriverCode2.Get(DriverCode."EOS Code");
        if DriverCode2."EOS Driver Object Filter" <> '' then
            CapacityLedgerEntry.SetFilter("Work Center No.", DriverCode2."EOS Driver Object Filter");
        /*case CASetup."EOS Cost Accounting Dimension" of
            GLSetup."Global Dimension 1 Code":
                CapacityLedgerEntry.SetFilter("Global Dimension 1 Code", DriverCode2."EOS Driver Object Filter");
            GLSetup."Global Dimension 2 Code":
                CapacityLedgerEntry.SetFilter("Global Dimension 2 Code", DriverCode2."EOS Driver Object Filter");
            else
                Error(Text001Err, DriverCode2.fieldcaption("EOS Driver Object Filter"), CASetup.fieldcaption("EOS Cost Accounting Dimension"));
        end;*/

        CapacityLedgerEntry.SetLoadFields("Dimension Set ID", "Run Time", "Setup Time", "No.", "Work Center No.", "Cap. Unit of Measure Code", "Qty. per Cap. Unit of Measure", Type);
        if CapacityLedgerEntry.FindSet() then
            repeat
                Qty := 0;
                if CapacityLedgerEntry.Type = CapacityLedgerEntry.Type::"Work Center" then begin
                    if not WorkCenter.Get(CapacityLedgerEntry."No.") then
                        Clear(WorkCenter);
                end else
                    Clear(WorkCenter);
                if WorkCenter."Subcontractor No." = '' then begin
                    if CapacityLedgerEntry."Qty. per Cap. Unit of Measure" = 0 then
                        GetCapacityUoM(CapacityLedgerEntry);
                    Qty :=
                      (CapacityLedgerEntry."Setup Time" + CapacityLedgerEntry."Run Time") /
                      CapacityLedgerEntry."Qty. per Cap. Unit of Measure" *
                      CalendarMgt.TimeFactor(CapacityLedgerEntry."Cap. Unit of Measure Code");
                    Qty := Qty / CalendarMgt.TimeFactor(MfgSetup."Show Capacity In")
                end;

                Amt := 0;
                if WorkCenter.Get(CapacityLedgerEntry."Work Center No.") then
                    Amt := Qty * WorkCenter."EMAM Rated Power" * WorkCenter."EMAM Cost KWH";
                //DriverObjectCode := GetCostCenterDimCode(CapacityLedgerEntry."Dimension Set ID");
                DriverObjectCode := CapacityLedgerEntry."Work Center No.";
                AddDriverValue(DriverCode."EOS Code", DriverObjectCode, DriverCode."EOS Ending Date", Amt);
            until CapacityLedgerEntry.Next() = 0;
    end;

    local procedure GetCapacityUoM(var CapacityLedgerEntry: Record "Capacity Ledger Entry")
    var
        WorkCenter: Record "Work Center";
    begin
        CapacityLedgerEntry."Qty. per Cap. Unit of Measure" := 1;
        WorkCenter.SetLoadFields("Unit of Measure Code");
        if WorkCenter.Get(CapacityLedgerEntry."Work Center No.") then
            CapacityLedgerEntry."Cap. Unit of Measure Code" := WorkCenter."Unit of Measure Code";
    end;

    local procedure CalcFixedAssetValue(DriverCode: Record "EOS C/A Driver Code")
    var
        FALedgerEntry: Record "FA Ledger Entry";
        TempDriverValueBuffer: Record "EOS C/A Driver Value" temporary;
        DriverCode2: Record "EOS C/A Driver Code";
        DriverObjectCode: Code[20];
    begin
        TempDriverValueBuffer.Reset();
        TempDriverValueBuffer.DeleteAll();
        DeleteDriverValue(DriverCode."EOS Code");

        FALedgerEntry.Reset();
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
        DriverCode2.Get(DriverCode."EOS Code");
        if DriverCode2."EOS Driver Object Filter" <> '' then
            //FAEntry.SETFILTER("FA No.", DriverCode2."EOS Driver Object Filter");
            case CASetup."EOS Cost Accounting Dimension" of
                GLSetup."Global Dimension 1 Code":
                    FALedgerEntry.SetFilter("Global Dimension 1 Code", DriverCode2."EOS Driver Object Filter");
                GLSetup."Global Dimension 2 Code":
                    FALedgerEntry.SetFilter("Global Dimension 2 Code", DriverCode2."EOS Driver Object Filter");
                else
                    Error(Text001Err, DriverCode2.fieldcaption("EOS Driver Object Filter"), CASetup.fieldcaption("EOS Cost Accounting Dimension"));
            end;

        FALedgerEntry.SetLoadFields("Dimension Set ID", "Amount (LCY)");
        if FALedgerEntry.FindSet() then
            repeat
                DriverObjectCode := GetCostCenterDimCode(FALedgerEntry."Dimension Set ID");
                if not TempDriverValueBuffer.Get(DriverCode."EOS Code", DriverObjectCode, DriverCode."EOS Ending Date") then begin
                    TempDriverValueBuffer.Init();
                    TempDriverValueBuffer."EOS Driver Code" := DriverCode."EOS Code";
                    TempDriverValueBuffer."EOS Driver Object Code" := DriverObjectCode;
                    TempDriverValueBuffer."EOS Starting Date" := DriverCode."EOS Ending Date";
                    TempDriverValueBuffer."EOS Quantity" := FALedgerEntry."Amount (LCY)";
                    TempDriverValueBuffer.Insert();
                end else begin
                    TempDriverValueBuffer."EOS Quantity" += FALedgerEntry."Amount (LCY)";
                    TempDriverValueBuffer.Modify();
                end;
            until FALedgerEntry.Next() = 0;

        TempDriverValueBuffer.Reset();
        if TempDriverValueBuffer.FindSet() then
            repeat
                AddDriverValue(TempDriverValueBuffer."EOS Driver Code", TempDriverValueBuffer."EOS Driver Object Code", TempDriverValueBuffer."EOS Starting Date", TempDriverValueBuffer."EOS Quantity");
            until TempDriverValueBuffer.Next() = 0;
    end;

    LOCAL procedure GetCostCenterDimCode(DimSetIDCode: Integer): Code[20]
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, DimSetIDCode);
        TempDimSetEntry.SetRange("Dimension Code", CASetup."EOS Cost Accounting Dimension");
        if TempDimSetEntry.FindFirst() then
            exit(TempDimSetEntry."Dimension Value Code")
        else
            exit('');
    end;

    local procedure DeleteDriverValue(DriverCode: Code[20])
    var
        DriverValue: Record "EOS C/A Driver Value";
    begin
        DriverValue.SetRange("EOS Driver Code", DriverCode);
        DriverValue.DeleteAll();
    end;

    local procedure AddDriverValue(DriverCode: Code[20]; DriverObjCode: Code[20]; DriverDate: Date; DriverQty: Decimal)
    var
        DriverValue: Record "EOS C/A Driver Value";
    begin
        if (DriverObjCode = '') OR (DriverObjCode = '') or (DriverDate = 0D) or (DriverQty = 0) then
            exit;

        if DriverValue.Get(DriverCode, DriverObjCode, DriverDate) then begin
            DriverValue.Validate("EOS Quantity", DriverValue."EOS Quantity" + DriverQty);
            DriverValue.Modify();
        end else begin
            DriverValue.Init();
            DriverValue.Validate("EOS Driver Code", DriverCode);
            DriverValue.Validate("EOS Driver Object Code", DriverObjCode);
            DriverValue.Validate("EOS Starting Date", DriverDate);
            DriverValue.Validate("EOS Quantity", DriverQty);
            DriverValue.Insert();
        end;
    end;
}
