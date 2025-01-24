codeunit 50001 "EOS Event Subs."
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
        if Rec.IsTemporary() then
            exit;

        EOS089WMSCustomActLine.Reset();
        EOS089WMSCustomActLine.SetRange("Activity Type", Rec."Activity Type");
        EOS089WMSCustomActLine.SetRange("Document No.", Rec."No.");
        if EOS089WMSCustomActLine.IsEmpty() then
            exit;

        EOS089WMSCustomActLine.FindSet();
        repeat
            EOS089WMSCustomActLine.Validate("Location Code", Rec."Location Code");
            EOS089WMSCustomActLine.Modify(true)
        until EOS089WMSCustomActLine.Next() = 0;
    end;

    // Propagate values from header to lines
    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnAfterValidateEvent, "Bin Code", false, false)]
    local procedure T18060040_OnAfterValidate_BinCode(var Rec: Record "EOS089 WMS Custom Act. Header"; var xRec: Record "EOS089 WMS Custom Act. Header"; CurrFieldNo: Integer)
    var
        EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line";
    begin
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
}
