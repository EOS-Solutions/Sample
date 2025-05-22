codeunit 50101 "EOS Create Trans.Ord. Ev.Subs."
{
    // Init Tracking Fields
    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnBeforeInsertEvent, '', false, false)]
    local procedure T18060040_OnBeforeInsertEvent(var Rec: Record "EOS089 WMS Custom Act. Header"; RunTrigger: Boolean)
    begin
        if Rec."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        Rec."Item Ledger Entry Type" := Rec."Item Ledger Entry Type"::Transfer;
        Rec.Inbound := false;
    end;

    // Add LookUp lists and relations
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Activity Management", OnAfterInitActivityFields, '', false, false)]
    local procedure CU18060015_OnAfterInitActivityFields(ActivityType: Enum "EOS089 WMS Activity Type"; ActivityFieldClass: Enum "EOS089 WMS Act. Field Class"; TableNo: Integer)
    var
        EOS089WMSActivityField: Record "EOS089 WMS Activity Field";
        EOS089WMSLookUpListHeader: Record "EOS089 WMS LookUp List Header";
        Location: Record Location;
        Bin: Record Bin;
        EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header";
        EOS089WMSMiscHelper: Codeunit "EOS089 WMS Misc. Helper";
        LocationLbl: Label 'LOCATIONS', Locked = true;
        BinLbl: Label 'BINS', Locked = true;
    begin
        if ActivityType <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        if ActivityFieldClass <> Enum::"EOS089 WMS Act. Field Class"::Detail then
            exit;

        if TableNo <> Database::"EOS089 WMS Custom Act. Header" then
            exit;

        // Create LookUps and relations
        //Location LookUp
        if not EOS089WMSLookUpListHeader.Get(LocationLbl) then begin
            EOS089WMSLookUpListHeader.Init();
            EOS089WMSLookUpListHeader.Code := LocationLbl;
            EOS089WMSLookUpListHeader.Validate("Source Type", Enum::"EOS089 WMS LUp.Lst.Source Type"::Table);
            EOS089WMSLookUpListHeader.Validate("Table Id", Database::Location);
            EOS089WMSLookUpListHeader.Validate("Code Field No.", Location.FieldNo("Code"));
            EOS089WMSLookUpListHeader.Validate("Description Field No.", Location.FieldNo("Name"));
            EOS089WMSLookUpListHeader.Insert(true);
        end;

        // Bin LookUp
        if not EOS089WMSLookUpListHeader.Get(BinLbl) then begin
            EOS089WMSLookUpListHeader.Init();
            EOS089WMSLookUpListHeader.Code := BinLbl;
            EOS089WMSLookUpListHeader.Validate("Source Type", Enum::"EOS089 WMS LUp.Lst.Source Type"::Table);
            EOS089WMSLookUpListHeader.Validate("Table Id", Database::Bin);
            EOS089WMSLookUpListHeader.Validate("Code Field No.", Bin.FieldNo("Code"));
            EOS089WMSLookUpListHeader.Validate("Description Field No.", Bin.FieldNo(Description));
            EOS089WMSLookUpListHeader.Validate("Dynamic Values", true);
            EOS089WMSLookUpListHeader.Insert(true)
        end;

#pragma warning disable AA0210
        EOS089WMSActivityField.Reset();
        EOS089WMSActivityField.SetRange("Activity", ActivityType);
        EOS089WMSActivityField.SetRange("Field Class", ActivityFieldClass);
        EOS089WMSActivityField.SetRange("Field No.", EOS089WMSCustomActHeader.FieldNo("Bin Code"));
        EOS089WMSActivityField.SetRange("LookUp List Code", BinLbl);
        EOS089WMSActivityField.FindFirst();
        EOS089WMSMiscHelper.LookUpRelation_AddRelationFromActivityField(EOS089WMSActivityField, Bin.FieldNo("Location Code"), EOS089WMSCustomActHeader.FieldNo("Location Code"));

        EOS089WMSActivityField.Reset();
        EOS089WMSActivityField.SetRange("Activity", ActivityType);
        EOS089WMSActivityField.SetRange("Field Class", ActivityFieldClass);
        EOS089WMSActivityField.SetRange("Field No.", EOS089WMSCustomActHeader.FieldNo("EOS To Bin Code"));
        EOS089WMSActivityField.SetRange("LookUp List Code", BinLbl);
        EOS089WMSActivityField.FindFirst();
        EOS089WMSMiscHelper.LookUpRelation_AddRelationFromActivityField(EOS089WMSActivityField, Bin.FieldNo("Location Code"), EOS089WMSCustomActHeader.FieldNo("EOS To Location Code"));
#pragma warning restore AA0210
    end;

    // Do not check bin code for location that does'nt require bins
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS User Activity Mgmt.", OnCheckMandatoryFieldByFieldValue, '', false, false)]
    local procedure CU18060025_OnCheckMandatoryFieldByFieldValue(RecordRef: RecordRef; FieldRef: FieldRef; EOS089WMSUserActField: Record "EOS089 WMS User Act. Field"; FieldValue: Variant; var IsHandled: Boolean)
    var
        EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header";
        Location: Record Location;
    begin
        if IsHandled then
            exit;

        if EOS089WMSUserActField.Activity <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        if RecordRef.Number <> Database::"EOS089 WMS Custom Act. Header" then
            exit;

        if not (FieldRef.Number in [EOS089WMSCustomActHeader.FieldNo("Bin Code"), EOS089WMSCustomActHeader.FieldNo("EOS To Bin Code")]) then
            exit;

        RecordRef.SetTable(EOS089WMSCustomActHeader);
        case FieldRef.Number of
            EOS089WMSCustomActHeader.FieldNo("Bin Code"):
                if Location.BinMandatory(EOS089WMSCustomActHeader."Location Code") then
                    if EOS089WMSCustomActHeader."Bin Code" = '' then
                        exit;
            EOS089WMSCustomActHeader.FieldNo("EOS To Bin Code"):
                if Location.BinMandatory(EOS089WMSCustomActHeader."EOS To Location Code") then
                    if EOS089WMSCustomActHeader."EOS To Bin Code" = '' then
                        exit;
        end;

        IsHandled := true;
    end;

    // Propagate values from header to lines
    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnAfterValidateEvent, "Location Code", false, false)]
    local procedure T18060040_OnAfterValidate_LocationCode(var Rec: Record "EOS089 WMS Custom Act. Header"; var xRec: Record "EOS089 WMS Custom Act. Header"; CurrFieldNo: Integer)
    var
        EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line";
    begin
        if Rec."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        if Rec.IsTemporary() then
            exit;

        Rec.Validate("Bin Code", '');

        EOS089WMSCustomActLine.Reset();
        EOS089WMSCustomActLine.SetRange("Activity Type", Rec."Activity Type");
        EOS089WMSCustomActLine.SetRange("Document No.", Rec."No.");
        if EOS089WMSCustomActLine.IsEmpty() then
            exit;

        EOS089WMSCustomActLine.FindSet();
        repeat
            EOS089WMSCustomActLine.Validate("Location Code", Rec."Location Code");
            EOS089WMSCustomActLine.Validate("Bin Code", '');
            EOS089WMSCustomActLine.Modify(true)
        until EOS089WMSCustomActLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnAfterValidateEvent, "Bin Code", false, false)]
    local procedure T18060040_OnAfterValidate_BinCode(var Rec: Record "EOS089 WMS Custom Act. Header"; var xRec: Record "EOS089 WMS Custom Act. Header"; CurrFieldNo: Integer)
    var
        EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line";
    begin
        if Rec."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        if Rec.IsTemporary() then
            exit;

        EOS089WMSCustomActLine.Reset();
        EOS089WMSCustomActLine.SetRange("Activity Type", Rec."Activity Type");
        EOS089WMSCustomActLine.SetRange("Document No.", Rec."No.");
        if EOS089WMSCustomActLine.IsEmpty() then
            exit;

        EOS089WMSCustomActLine.FindSet();
        repeat
            EOS089WMSCustomActLine.Validate("Bin Code", Rec."Bin Code");
            EOS089WMSCustomActLine.Modify(true)
        until EOS089WMSCustomActLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnAfterValidateEvent, "EOS To Location Code", false, false)]
    local procedure T18060040_OnAfterValidate_ToLocationCode(var Rec: Record "EOS089 WMS Custom Act. Header"; var xRec: Record "EOS089 WMS Custom Act. Header"; CurrFieldNo: Integer)
    begin
        if Rec."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        if Rec.IsTemporary() then
            exit;

        Rec.Validate("EOS To Bin Code", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Custom Act. - Post", OnAfterInsertRegisteredHeader, '', false, false)]
    local procedure CU18060067_OnAfterInsertRegisteredHeader(EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header"; var EOS089WMSRegCusActHdr: Record "EOS089 WMS Reg. Cus. Act. Hdr.")
    var
        TransferHeader: Record "Transfer Header";
    begin
        if EOS089WMSCustomActHeader."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        // Create Transfer Header
        TransferHeader.Init();
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", EOS089WMSCustomActHeader."Location Code");
        TransferHeader.Validate("Transfer-to Code", EOS089WMSCustomActHeader."EOS To Location Code");
        TransferHeader.Validate("In-Transit Code", 'LOG. EST.');
        TransferHeader.Modify(true);

        EOS089WMSRegCusActHdr."Linked Activity Type" := Enum::"EOS089 WMS Activity Type"::"Transfer Shipment";
        EOS089WMSRegCusActHdr."Linked Source Type" := Database::"Transfer Header";
        EOS089WMSRegCusActHdr.Validate("Linked Source Subtype", Enum::"EOS089 WMS Source Subtype"::"0");
        EOS089WMSRegCusActHdr."Linked Source Id" := TransferHeader."No.";
        EOS089WMSRegCusActHdr."Linked Source SystemId" := TransferHeader.SystemId;
        EOS089WMSRegCusActHdr."Linked Source RecordId" := TransferHeader.RecordId();
        EOS089WMSRegCusActHdr.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Custom Act. - Post", OnAfterInsertRegisteredLine, '', false, false)]
    local procedure CU18060067_OnAfterInsertRegisteredLine(EOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header"; EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line"; EOS089WMSRegCusActHdr: Record "EOS089 WMS Reg. Cus. Act. Hdr."; var EOS089WMSRegCusActLine: Record "EOS089 WMS Reg. Cus. Act. Line")
    var
        TransferLine: Record "Transfer Line";
        EOS089WMSAutomaticTracking: Codeunit "EOS089 WMS Automatic Tracking";
        LineNo: Integer;
    begin
        if EOS089WMSCustomActHeader."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        TransferLine.Reset();
        TransferLine.SetRange("Document No.", EOS089WMSRegCusActHdr."Linked Source Id");
        TransferLine.SetRange("Item No.", EOS089WMSCustomActLine."Item No.");
        TransferLine.SetRange("Variant Code", EOS089WMSCustomActLine."Variant Code 2");
        if TransferLine.IsEmpty() then begin
            TransferLine.Reset();
            TransferLine.SetLoadFields("Line No.");
            TransferLine.SetRange("Document No.", EOS089WMSRegCusActHdr."Linked Source Id");
            if TransferLine.FindLast() then
                LineNo := TransferLine."Line No." + 10000
            else
                LineNo := 10000;

            Clear(TransferLine);
            TransferLine.Init();
            TransferLine.Validate("Document No.", EOS089WMSRegCusActHdr."Linked Source Id");
            TransferLine."Line No." := LineNo;
            TransferLine.Insert(true);

            TransferLine.Validate("Item No.", EOS089WMSCustomActLine."Item No.");
            TransferLine.Validate("Variant Code", EOS089WMSCustomActLine."Variant Code 2");
            TransferLine."Transfer-from Code" := EOS089WMSCustomActHeader."Location Code";
            TransferLine."Transfer-to Code" := EOS089WMSCustomActHeader."EOS To Location Code";
            TransferLine."Transfer-from Bin Code" := EOS089WMSCustomActHeader."Bin Code";
            TransferLine."Transfer-to Bin Code" := EOS089WMSCustomActHeader."EOS To Bin Code";
        end else
            TransferLine.FindLast();

        TransferLine.Validate("Quantity", TransferLine.Quantity + EOS089WMSCustomActLine.Quantity);
        TransferLine.Validate("Qty. to Ship", TransferLine."Qty. to Ship" + EOS089WMSCustomActLine.Quantity);
        TransferLine.Modify(true);

        // Assign Tracking
        if EOS089WMSCustomActLine."Tracking Type" <> Enum::"EOS089 WMS Tracking Type"::None then begin
            EOS089WMSAutomaticTracking.SetDirection(Enum::"Transfer Direction"::Outbound);
            EOS089WMSAutomaticTracking.SetDirectTransfer(false);
            EOS089WMSAutomaticTracking.SetSource(TransferLine);
            EOS089WMSAutomaticTracking.AddTracking(EOS089WMSCustomActLine."Serial No.", EOS089WMSCustomActLine."Lot No.", EOS089WMSCustomActLine."Package No.", EOS089WMSCustomActLine."Quantity (Base)", 0D, 0D);
            EOS089WMSAutomaticTracking.Save();
        end;

        EOS089WMSRegCusActLine."Linked Activity Type" := Enum::"EOS089 WMS Activity Type"::"Transfer Shipment";
        EOS089WMSRegCusActLine."Linked Source Type" := Database::"Transfer Line";
        EOS089WMSRegCusActLine.Validate("Linked Source Subtype", Enum::"EOS089 WMS Source Subtype"::"0");
        EOS089WMSRegCusActLine."Linked Source Id" := EOS089WMSRegCusActHdr."Linked Source Id";
        EOS089WMSRegCusActLine."Linked Source Ref. No." := TransferLine."Line No.";
        EOS089WMSRegCusActLine."Linked Source SystemId" := TransferLine.SystemId;
        EOS089WMSRegCusActLine."Linked Source RecordId" := TransferLine.RecordId();
        EOS089WMSRegCusActLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS089 WMS Custom Act. - Post", OnAfterInsertRegisteredSourceScan, '', false, false)]
    local procedure CU18060067_OnAfterInsertRegisteredSourceScan(EOS089WMSRegCusActLine: Record "EOS089 WMS Reg. Cus. Act. Line"; var EOS089WMSRegSourceScan: Record "EOS089 WMS Reg. Source Scan"; NewSourceScanId: Guid)
    var
        EOS089WMSSourceScan2: Record "EOS089 WMS Source Scan";
        TransferLine: Record "Transfer Line";
    begin
        if EOS089WMSRegCusActLine."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder then
            exit;

        // Raw procedure to transfer source scans, in order to have Transfer Order as "scanned"
        EOS089WMSSourceScan2.Init();
        EOS089WMSSourceScan2."Scan Id" := NewSourceScanId;
        EOS089WMSSourceScan2."Scan Line Id" := CreateGuid();
        EOS089WMSSourceScan2."Activity Type" := Enum::"EOS089 WMS Activity Type"::"Transfer Shipment";
        EOS089WMSSourceScan2.Type := Enum::"EOS089 WMS Scan Entity Type"::Item;
        EOS089WMSSourceScan2."Item No." := EOS089WMSRegCusActLine."Item No.";
        EOS089WMSSourceScan2."Variant Code" := EOS089WMSRegCusActLine."Variant Code 2";
        EOS089WMSSourceScan2."Tracking Type" := EOS089WMSRegCusActLine."Tracking Type";
        EOS089WMSSourceScan2."Serial No." := EOS089WMSRegCusActLine."Serial No.";
        EOS089WMSSourceScan2."Lot No." := EOS089WMSRegCusActLine."Lot No.";
        EOS089WMSSourceScan2."Package No." := EOS089WMSRegCusActLine."Package No.";
        EOS089WMSSourceScan2.Quantity := EOS089WMSRegCusActLine.Quantity;
        EOS089WMSSourceScan2."Quantity (Base)" := EOS089WMSRegCusActLine."Quantity (Base)";
        EOS089WMSSourceScan2."Location Code" := EOS089WMSRegCusActLine."Location Code";
        EOS089WMSSourceScan2."Bin Code" := EOS089WMSRegCusActLine."Bin Code";
        EOS089WMSSourceScan2."Automatic Tracking" := EOS089WMSRegCusActLine."Automatic Tracking";

        EOS089WMSSourceScan2."Item Journal Entry Type" := EOS089WMSSourceScan2."Item Journal Entry Type"::"Negative Adjmt.";

        TransferLine.GetBySystemId(EOS089WMSRegCusActLine."Linked Source SystemId");
        EOS089WMSSourceScan2."Source Type" := Database::"Transfer Line";
        EOS089WMSSourceScan2."Source Subtype" := Enum::"EOS089 WMS Source Subtype"::"0";
        EOS089WMSSourceScan2."Source Subtype As Int" := Enum::"EOS089 WMS Source Subtype"::"0".AsInteger();
        EOS089WMSSourceScan2."Source ID" := TransferLine."Document No.";
        EOS089WMSSourceScan2."Source Ref. No." := TransferLine."Line No.";
        EOS089WMSSourceScan2."Unit Of Measure Code" := TransferLine."Unit Of Measure Code";
        EOS089WMSSourceScan2."Source SystemId" := TransferLine.SystemId;
        EOS089WMSSourceScan2.Description := TransferLine.Description;
        EOS089WMSSourceScan2."Description 2" := TransferLine."Description 2";

        EOS089WMSSourceScan2.Insert();
    end;
}
