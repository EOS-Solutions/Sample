codeunit 50114 "EOS HU Mgmt. Ev. Subs."
{
    // Enable Handling Unit Management Tab in PowerApp
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089.01 WMS HU Mgmt.", OnBeforeCheckActivityForHUAction, '', false, false)]
    local procedure CU18060345_OnBeforeCheckActivityForHUAction(ActivityType: Enum "EOS089 WMS Activity Type"; HUAction: Option Scan,Assign; var IsValid: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        if ActivityType <> Enum::"EOS089 WMS Activity Type"::EOSHUOnCustom then
            exit;

        IsValid := HUAction = HUAction::Scan;
        IsHandled := true;
    end;

    // MANDATORY! Standard tracking is not used in Custom Activities!
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS055.01 HU Assignment", OnBeforeGetCanUpdateItemTrackingLines, '', false, false)]
    local procedure CU70491904_OnBeforeGetCanUpdateItemTrackingLines(SourceDocLine: Variant; var TrackingHandled: Boolean)
    var
        EOSRecordIdentBuffer: Record "EOS Record Ident. Buffer";
        RecordRef: RecordRef;
    begin
        if TrackingHandled then
            exit;

        if not SourceDocLine.IsRecord() then
            exit;

        RecordRef.GetTable(SourceDocLine);
        if RecordRef.Number <> Database::"EOS Record Ident. Buffer" then
            exit;

        RecordRef.SetTable(EOSRecordIdentBuffer);
        if not (EOSRecordIdentBuffer."Source Type" in [Database::"EOS089 WMS Custom Act. Header", Database::"EOS089 WMS Custom Act. Line"]) then
            exit;

        TrackingHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS055.01 HU Assignment", OnAfterHandlingUnitAssigned, '', false, false)]
    local procedure CU70491905_OnAfterHandlingUnitAssignedOnAfterHandlingUnitAssigned(HandlingUnit: Record "EOS055 Handling Unit"; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; var TmpAssignedBuffer: Record "EOS055 Handling Unit Buffer");
    var
        EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header";
        EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line";
        EOS089WMSSourceScan: Record "EOS089 WMS Source Scan";
        QtyRoundingPrecision: Decimal;
        ActivityScanId: Guid;
    begin
        if not (SourceType in [Database::"EOS089 WMS Custom Act. Header", Database::"EOS089 WMS Custom Act. Line"]) then
            exit;

        EOS089WMSCustomActHeader.Reset();
        EOS089WMSCustomActHeader.SetRange("Activity Type", Enum::"EOS089 WMS Activity Type".FromInteger(SourceSubtype));
        EOS089WMSCustomActHeader.SetRange("No.", SourceNo);
        if not EOS089WMSCustomActHeader.FindFirst() then
            exit;

        TmpAssignedBuffer.Reset();
#pragma warning disable AA0210
        TmpAssignedBuffer.SetRange(Type, TmpAssignedBuffer.Type::Item);
        TmpAssignedBuffer.SetRange("Source Type", SourceType);
        TmpAssignedBuffer.SetRange("Source Subtype", SourceSubtype);
        TmpAssignedBuffer.SetRange("Source No.", SourceNo);
        TmpAssignedBuffer.SetFilter("Source Line No.", '<>%1', 0);
#pragma warning restore AA0210
        if TmpAssignedBuffer.IsEmpty() then
            exit;

        EOS089WMSSourceScan.Reset();
        EOS089WMSSourceScan.SetLoadFields("Activity Scan Id");
        EOS089WMSSourceScan.SetRange("Source Type", SourceType);
        EOS089WMSSourceScan.SetRange("Source Subtype", EOS089WMSSourceScan."Source Subtype"::"0");
        EOS089WMSSourceScan.SetRange("Source Subtype As Int", EOS089WMSSourceScan."Source Subtype"::"0".AsInteger());
        EOS089WMSSourceScan.SetRange("Source ID", SourceNo);
        if EOS089WMSSourceScan.FindFirst() then
            ActivityScanId := EOS089WMSSourceScan."Activity Scan Id"
        else
            ActivityScanId := CreateGuid();

        TmpAssignedBuffer.FindSet();
        repeat
            EOS089WMSCustomActLine.Get(Enum::"EOS089 WMS Activity Type".FromInteger(SourceSubtype), SourceNo, TmpAssignedBuffer."Source Line No.");
            EOS089WMSSourceScan.Reset();
            EOS089WMSSourceScan.SetRange("Source Type", SourceType);
            EOS089WMSSourceScan.SetRange("Source Subtype", EOS089WMSSourceScan."Source Subtype"::"0");
            EOS089WMSSourceScan.SetRange("Source Subtype As Int", EOS089WMSSourceScan."Source Subtype"::"0".AsInteger());
            EOS089WMSSourceScan.SetRange("Source ID", SourceNo);
            EOS089WMSSourceScan.SetRange("Source Ref. No.", TmpAssignedBuffer."Source Line No.");
            EOS089WMSSourceScan.SetRange("Item No.", TmpAssignedBuffer."No.");
            EOS089WMSSourceScan.SetRange("Variant Code", TmpAssignedBuffer."Variant Code");
            EOS089WMSSourceScan.SetRange("Serial No.", TmpAssignedBuffer."Serial No.");
            EOS089WMSSourceScan.SetRange("Lot No.", TmpAssignedBuffer."Lot No.");
            //EOS089WMSSourceScan."Package No." := EOS055HandlingUnitAssignm."Package No.";
            EOS089WMSSourceScan.SetRange("EOS Handling Unit No.", TmpAssignedBuffer."Handling Unit No.");
            if EOS089WMSSourceScan.IsEmpty() then begin
                EOS089WMSSourceScan.Init();
                EOS089WMSSourceScan."Scan Id" := ActivityScanId;
                EOS089WMSSourceScan."Scan Line Id" := CreateGuid();
                EOS089WMSSourceScan."Activity Type" := EOS089WMSCustomActHeader."Activity Type";
                EOS089WMSSourceScan.Type := Enum::"EOS089 WMS Scan Entity Type"::Item;
                EOS089WMSSourceScan."Item No." := TmpAssignedBuffer."No.";
                EOS089WMSSourceScan."Variant Code" := TmpAssignedBuffer."Variant Code";
                EOS089WMSSourceScan."Tracking Type" := Enum::"EOS089 WMS Tracking Type"::None;
                case true of
                    (TmpAssignedBuffer."Serial No." <> '') and (TmpAssignedBuffer."Lot No." = ''):
                        EOS089WMSSourceScan."Tracking Type" := Enum::"EOS089 WMS Tracking Type"::SerialNo;
                    (TmpAssignedBuffer."Serial No." = '') and (TmpAssignedBuffer."Lot No." <> ''):
                        EOS089WMSSourceScan."Tracking Type" := Enum::"EOS089 WMS Tracking Type"::LotNo;
                    (TmpAssignedBuffer."Serial No." <> '') and (TmpAssignedBuffer."Lot No." <> ''):
                        EOS089WMSSourceScan."Tracking Type" := Enum::"EOS089 WMS Tracking Type"::SerialLotNo;
                end;

                QtyRoundingPrecision := EOS089WMSCustomActLine."Qty. Rounding Precision";

                if QtyRoundingPrecision = 0 then
                    QtyRoundingPrecision := 0.00001;

                EOS089WMSSourceScan."Serial No." := TmpAssignedBuffer."Serial No.";
                EOS089WMSSourceScan."Lot No." := TmpAssignedBuffer."Lot No.";
                //EOS089WMSSourceScan."Package No." := EOS055HandlingUnitAssignm."Package No.";
                EOS089WMSSourceScan.Quantity := Round(TmpAssignedBuffer."Quantity (Base)" / EOS089WMSCustomActLine."Qty. Per Unit Of Measure", QtyRoundingPrecision);
                EOS089WMSSourceScan."Quantity (Base)" := TmpAssignedBuffer."Quantity (Base)";
                //EOS089WMSSourceScan."Warranty Date" := EOS055HandlingUnitAssignm."Warranty Date";
                //EOS089WMSSourceScan."Expiration Date" := EOS055HandlingUnitAssignm."Expiration Date";
                EOS089WMSSourceScan."Location Code" := EOS089WMSCustomActLine."Location Code";
                EOS089WMSSourceScan."Bin Code" := EOS089WMSCustomActLine."Bin Code";

                EOS089WMSSourceScan."Unit Of Measure Code" := EOS089WMSCustomActLine."Unit Of Measure Code";

                EOS089WMSSourceScan."Source Type" := SourceType;
                EOS089WMSSourceScan."Source Subtype" := EOS089WMSSourceScan."Source Subtype"::"0";
                EOS089WMSSourceScan."Source Subtype As Int" := EOS089WMSSourceScan."Source Subtype"::"0".AsInteger();
                EOS089WMSSourceScan."Source ID" := EOS089WMSCustomActLine."Document No.";
                EOS089WMSSourceScan."Source Ref. No." := EOS089WMSCustomActLine."Line No.";
                EOS089WMSSourceScan."Source Prod. Order Line" := 0;

                EOS089WMSSourceScan."Unit Of Measure Code" := EOS089WMSCustomActLine."Unit Of Measure Code";
                EOS089WMSSourceScan."Source SystemId" := EOS089WMSCustomActLine.SystemId;

                EOS089WMSSourceScan."EOS Handling Unit No." := TmpAssignedBuffer."Handling Unit No.";
                EOS089WMSSourceScan."EOS Assigned Handling Unit No." := TmpAssignedBuffer."Handling Unit No.";
                EOS089WMSSourceScan."Block Edit" := true;
                EOS089WMSSourceScan."Block Delete" := true;
                EOS089WMSSourceScan.Insert(true);
            end;
        until TmpAssignedBuffer.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS055.01 HU Assignment", OnAfterHandlingUnitUnassigned, '', false, false)]
    local procedure CU70491905_OnAfterHandlingUnitUnassigned(HandlingUnit: Record "EOS055 Handling Unit"; SourceType: Integer; SourceSubtype: Integer; SourceNo: Code[20]; var TmpAssignedBuffer: Record "EOS055 Handling Unit Buffer")
    var
        EOS089WMSSourceScan: Record "EOS089 WMS Source Scan";
    begin
        if not (SourceType in [Database::"EOS089 WMS Custom Act. Header", Database::"EOS089 WMS Custom Act. Line"]) then
            exit;

        EOS089WMSSourceScan.Reset();
        EOS089WMSSourceScan.SetRange("Activity Type", Enum::"EOS089 WMS Activity Type".FromInteger(SourceSubtype));
        EOS089WMSSourceScan.SetRange("Source Type", SourceType);
        EOS089WMSSourceScan.SetRange("Source Subtype", Enum::"EOS089 WMS Source Subtype"::"0");
        EOS089WMSSourceScan.SetRange("EOS Assigned Handling Unit No.", HandlingUnit."No.");
        EOS089WMSSourceScan.DeleteAll(true);
    end;
}
