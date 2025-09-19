codeunit 50113 "EOS HU Custom" implements "EOS055.01 Source Document Handler"
{
    procedure AddItemLinesToBuffer(
        DocumentType: Integer; DocumentNo: Code[20]; DocumentLineFilter: Text;
        ItemNo: Code[20]; VariantCode: Code[10];
        var TempSourceBuffer: Record "EOS055 Handling Unit Buffer");
    var
        WMSActLine: Record "EOS089 WMS Custom Act. Line";
    begin
        // WMSActLine.SetRange("Activity Type", DocumentType);
        WMSActLine.SetRange("Activity Type", WMSActLine."Activity Type"::EOSHUOnCustom);
        WMSActLine.SetRange("Document No.", DocumentNo);
        if ItemNo <> '' then begin
            WMSActLine.SetRange("Item No.", ItemNo);
            WMSActLine.SetRange("Variant Code 2", VariantCode);
        end else
            WMSActLine.SetFilter("Item No.", '<>%1', '');
        if (DocumentLineFilter <> '') then
            WMSActLine.SetFilter("Line No.", DocumentLineFilter);
        if WMSActLine.FindSet() then
            repeat
                TempSourceBuffer.Init();
                CopyFieldsToHuBuffer(WMSActLine, TempSourceBuffer);
                if TempSourceBuffer."Quantity (Base)" <> 0 then
                    TempSourceBuffer.InsertTempLine();
            until WMSActLine.Next() = 0;
    end;

    procedure IsInbound(SourceSubtype: Integer): Boolean
    begin
        exit(false);
    end;

    procedure IsPostedDoc(): Boolean
    begin
        exit(false);
    end;

    procedure ShowPage(DocumentType: Integer; DocumentNo: Code[20]; LineNo: Integer; SublineNo: Integer): Boolean
    begin
    end;

    procedure FillEmptyJnlLine(DocumentType: Integer; DocumentNo: Code[20]; var EmptyJnlLine: Record "EOS029 Container Jnl. Line")
    begin
    end;

    procedure GetAssignmentTargets(DocumentType: Integer; DocumentNo: Code[20]; var TmpAssignmentTarget: Record "EOS055.01 HU Assignment Target");
    var
        WMSActHeader: Record "EOS089 WMS Custom Act. Header";
    begin
        if DocumentType <> 0 then begin
            WMSActHeader.Get(Enum::"EOS089 WMS Activity Type".FromInteger(DocumentType), DocumentNo);
        end else begin
            WMSActHeader.SetRange("Activity Type", Enum::"EOS089 WMS Activity Type"::EOSHUOnCustom);
            WMSActHeader.SetRange("No.", DocumentNo);
            WMSActHeader.FindFirst();
        end;

        TmpAssignmentTarget.Init();
        TmpAssignmentTarget.Type := Database::"EOS089 WMS Custom Act. Header";
        TmpAssignmentTarget."Source Type" := Database::"EOS089 WMS Custom Act. Line";
        TmpAssignmentTarget."Source Subtype" := Enum::"EOS089 WMS Activity Type"::EOSHUOnCustom.AsInteger();
        TmpAssignmentTarget."Source No." := DocumentNo;
        TmpAssignmentTarget."Caller Record ID" := WMSActHeader.RecordId;
        TmpAssignmentTarget.InsertLine();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS055.01 Globals", 'OnGetSourceDocumentHandler', '', true, false)]
    local procedure OnGetSourceDocumentHandler(
        SourceType: Integer;
        var Handled: Boolean;
        var handler: Interface "EOS055.01 Source Document Handler"
    )
    var
        thisCu: Codeunit "EOS HU Custom";
    begin
        if not (SourceType in [Database::"EOS089 WMS Custom Act. Header", Database::"EOS089 WMS Custom Act. Line"]) then
            exit;
        handler := thisCu;
        Handled := true;
    end;

    procedure LineSourceType(): Integer;
    begin
        exit(Database::"EOS089 WMS Custom Act. Line");
    end;

    procedure HeaderSourceType(): Integer;
    begin
        exit(Database::"EOS089 WMS Custom Act. Header");
    end;

    procedure HandleHuAssignment(Hu: Record "EOS055 Handling Unit"; SourceSubtype: Integer; SourceNo: Code[20]; Removed: Boolean; var AssignmentBuffer: Record "EOS055 Handling Unit Buffer");
    var
        Hu2: Record "EOS055 Handling Unit";
        WMSActLine: Record "EOS089 WMS Custom Act. Line";
        WhseShptLine: Record "Warehouse Shipment Line";
        HUAssign: Record "EOS055 Handling Unit Assignm.";
        HuAssignment: Codeunit "EOS055.01 HU Assignment";
        UoMMgt: Codeunit "Unit of Measure Management";
        Qty: Decimal;
    begin
        /*
        Hu2.Get(Hu."No.");
        Hu2."ISI Checked" := not Removed;
        Hu2.Modify(true);


        // if not Removed then begin

        HUAssign.SetRange("Handling Unit No.", Hu."No.");
        HUAssign.SetFilter("Source Type", '%1|%2', Database::"Sales Line", Database::"Purchase Line");
        HUAssign.FindLast();
        WhseShptLine.SetRange("Source Type", HUAssign."Source Type");
        WhseShptLine.SetRange("Source Subtype", HUAssign."Source Subtype");
        WhseShptLine.SetRange("Source No.", HUAssign."Source No.");
        WhseShptLine.SetRange("Source Line No.", HUAssign."Source Line No.");
        WhseShptLine.FindFirst();

        CheckAssignHu(WhseShptLine."No.", SourceSubtype, SourceNo);

        // WMSActLine.SetRange("ISI Whse Shpt Header No.", WhseShptLine."No.");
        // end;
        */

        WMSActLine.SetRange("Activity Type", Enum::"EOS089 WMS Activity Type".FromInteger(SourceSubtype));
        WMSActLine.SetRange("Document No.", SourceNo);
        WMSActLine.SetFilter(Quantity, '<>%1', 0);
        if WMSActLine.FindSet() then
            repeat

                Qty := UoMMgt.CalcQtyFromBase(HuAssignment.CalcAssignedQty(WMSActLine), WMSActLine."Qty. per Unit of Measure");
                if Qty = 0 then begin
                    HUAssign.Reset();
                    HUAssign.SetRange("Source Type", Database::"EOS089 WMS Custom Act. Line");
                    if SourceSubtype <> 0 then
                        HUAssign.SetFilter("Source Subtype", '%1|%2', 0, SourceSubtype);
                    HUAssign.SetRange("Source No.", WMSActLine."Document No.");
                    HUAssign.SetRange("Source Line No.", WMSActLine."Line No.");
                    HuAssign.CalcSums("Quantity (Base)");
                    Qty := UoMMgt.CalcQtyFromBase(HuAssign."Quantity (Base)", WMSActLine."Qty. per Unit of Measure");
                    // if Qty = 0 then begin
                    //     HUAssign.SetRange("Source Subtype");
                    //     HuAssign.CalcSums("Quantity (Base)");
                    //     Qty := UoMMgt.CalcQtyFromBase(HuAssign."Quantity (Base)", WMSActLine."Qty. per Unit of Measure");
                    // end
                end;
                WMSActLine.Validate("Qty. To Handle", Qty);
                WMSActLine.Modify();
            until WMSActLine.Next() = 0;
    end;

    /*
    local procedure CheckAssignHu(WhseNo: Code[20]; SourceSubType: Integer; SourceNo: Code[20])
    var
        WMSActHeader: Record "EOS089 WMS Custom Act. Header";
    begin
        if SourceSubType <> 0 then begin
            WMSActHeader.Get(SourceSubType, SourceNo);
        end else begin
            WMSActHeader.SetRange("No.", SourceNo);
            WMSActHeader.FindFirst();
        end;

        case WMSActHeader."Activity Type" of
            "EOS089 WMS Activity Type"::PTVTourCheckList:
                begin
                    ChecKAssignHuPTVTourCheckList(WhseNo, WMSActHeader);
                end;
        end;

    end;


    local procedure ChecKAssignHuPTVTourCheckList(WhseNo: Code[20]; WMSActHeader: Record "EOS089 WMS Custom Act. Header")
    var
        PTVTourHeader: Record "ISI001 PTV Tour Header";
        WhseShptHeader: Record "Warehouse Shipment Header";
        Hu: Record "EOS055 Handling Unit";
        TempSourceDoc: Record "EOS Record Ident. Buffer" temporary;
        TempHandlingUnit: Record "EOS055 Handling Unit" temporary;
        HuAssignment: Codeunit "EOS055.01 HU Assignment";
        ListOfCheckedHUs: List of [Code[20]];
        ListOfNotCheckedHUs: List of [Code[20]];
        CheckErr: Label 'Warehouse Shipment No. %1 is not completely checked for the PTV Tour %2', Comment = '%1 = WhseShptHeader."No.", %2 = PTVTourHeader."No."';
    begin

        PTVTourHeader.Get(WMSActHeader."ISI Tour No.");
        WhseShptHeader.SetRange("ISI Tour No.", PTVTourHeader."No.");
        if WhseShptHeader.FindSet() then
            repeat
                Clear(ListOfCheckedHUs);
                Clear(ListOfNotCheckedHUs);
                TempSourceDoc.GetTable(WhseShptHeader);
                TempHandlingUnit.Reset();
                TempHandlingUnit.DeleteAll();
                HuAssignment.GetAssignedHandlingUnits(TempSourceDoc."Source Type", TempSourceDoc."Source Subtype", TempSourceDoc."Source ID", 0, 0, TempHandlingUnit);
                if TempHandlingUnit.FindSet() then
                    repeat
                        Hu.Get(TempHandlingUnit."No.");
                        if Hu."ISI Checked" then begin
                            ListOfCheckedHUs.Add(Hu."No.");
                        end else begin
                            ListOfNotCheckedHUs.Add(Hu."No.");
                        end;

                    until TempHandlingUnit.Next() = 0;

                if (ListOfCheckedHUs.Count() > 0) and (ListOfNotCheckedHUs.Count() > 0) then
                    if WhseNo <> WhseShptHeader."No." then
                        Error(CheckErr, WhseShptHeader."No.", PTVTourHeader."No.");


            until WhseShptHeader.Next() = 0;

    end;
    */

    procedure DeleteEmptyItem(DocEmptyItem: Record "EOS029 Document Container");
    begin
    end;

    procedure CreateEmptyItem(var DocEmptyItem: Record "EOS029 Document Container");
    begin
    end;



    procedure CopyFieldsToHuBuffer(WMSActLine: Record "EOS089 WMS Custom Act. Line"; var TempHuBuffer: Record "EOS055 Handling Unit Buffer"): Boolean
    var
    begin
        TempHuBuffer."Source Type" := Database::"EOS089 WMS Custom Act. Line";
        TempHuBuffer."Source Subtype" := WMSActLine."Activity Type".AsInteger();
        TempHuBuffer."Source No." := WMSActLine."Document No.";
        TempHuBuffer."Source Line No." := WMSActLine."Line No.";
        TempHuBuffer."Source Subline No." := 0;
        TempHuBuffer.Type := TempHuBuffer.Type::Item;
        TempHuBuffer."No." := WMSActLine."Item No.";
        TempHuBuffer."Variant Code" := WMSActLine."Variant Code 2";
        TempHuBuffer.Description := WMSActLine.Description;
        TempHuBuffer."Location Code" := WMSActLine."Location Code";
        TempHuBuffer."Bin Code" := WMSActLine."Bin Code";
        TempHuBuffer."Unit of Measure Code" := WMSActLine."Unit of Measure Code";
        TempHuBuffer."Qty. per Unit of Measure" := WMSActLine."Qty. per Unit of Measure";
        TempHuBuffer.Quantity := WMSActLine."Outstanding Quantity";
        TempHuBuffer."Quantity (Base)" := WMSActLine."Outstanding Qty. (Base)";
        // TempHuBuffer.w
        TempHuBuffer."Original Qty." := WMSActLine.Quantity;
        TempHuBuffer."Original Qty. (Base)" := WMSActLine."Quantity (Base)";
        TempHuBuffer."Qty. to Handle" := 0;
        TempHuBuffer."Qty. to Handle (Base)" := 0;
        TempHuBuffer."Quantity (Max.)" := TempHuBuffer.Quantity;
        TempHuBuffer."Quantity (Max., Base)" := TempHuBuffer."Quantity (Base)";
        TempHuBuffer.GetContentDimensions();
        TempHuBuffer.CalcPackagingValues();
    end;

    [EventSubscriber(ObjectType::Table, Database::"EOS055 Handling Unit Buffer", 'OnCopyFieldsFromSourceDocumentLine', '', false, false)]
    local procedure EOS055HandlingUnitBuffer_OnCopyFieldsFromSourceDocumentLine(var Buffer: Record "EOS055 Handling Unit Buffer"; SourceDocumentLine: Variant; var IsHandled: Boolean)
    var
        TempRecIdBuf: Record "EOS Record Ident. Buffer" temporary;
        WMSActLine: Record "EOS089 WMS Custom Act. Line";
    begin
        if TempRecIdBuf.GetTable(SourceDocumentLine) and (TempRecIdBuf."Source Type" = Database::"EOS089 WMS Custom Act. Line") then begin
            Buffer."Source Type" := TempRecIdBuf."Source Type";
            Buffer."Source Subtype" := TempRecIdBuf."Source Subtype";
            Buffer."Source No." := TempRecIdBuf."Source ID";
            Buffer."Source Subline No." := TempRecIdBuf."Source Prod. Order Line";
            Buffer."Source Line No." := TempRecIdBuf."Source Ref. No.";
            if WMSActLine.Get(Enum::"EOS089 WMS Activity Type".FromInteger(Buffer."Source Subtype"), Buffer."Source No.", Buffer."Source Line No.") then begin
                CopyFieldsToHuBuffer(WMSActLine, Buffer);
                IsHandled := true;
            end;
        end;
    end;

}