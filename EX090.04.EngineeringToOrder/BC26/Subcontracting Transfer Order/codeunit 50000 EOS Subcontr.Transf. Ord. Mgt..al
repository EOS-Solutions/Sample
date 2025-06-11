codeunit 50000 "EOS Subcontr.Transf. Ord. Mgt."
{
    trigger OnRun()
    begin

    end;

    local procedure GetJobStructureEntryNo_FromProdOrderComponent(TransferLine: Record "Transfer Line"; var JobStructureEntryNo: Integer): Boolean
    var
        ProdOrderComponent: Record "Prod. Order Component";
        EngineeringSetup: Record "M365 Engineering Setup";
    begin
        JobStructureEntryNo := 0;
        if EngineeringSetup.Read(false) and EngineeringSetup."Modus Engineering Active" then begin
            ProdOrderComponent.SetLoadFields("M365 Job Structure Entry No.");
            if ProdOrderComponent.Get(ProdOrderComponent.Status::Released, TransferLine."Prod. Order No.", TransferLine."Prod. Order Line No.", TransferLine."Prod. Order Comp. Line No.") then begin
                JobStructureEntryNo := ProdOrderComponent."M365 Job Structure Entry No.";
                exit(true);
            end;
        end;
        exit(false)
    end;

    [EventSubscriber(ObjectType::Report, Report::"Create Subcontr.Transf. Order", OnCheckPurchLineOnAfterTransferLineInsert, '', false, false)]
    local procedure CreateSubcontrTransfOrder_OnCheckPurchLineOnAfterTransferLineInsert(var Sender: Report "Create Subcontr.Transf. Order"; var TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; PurchaseLine: Record "Purchase Line")
    var
        JobStructureEntryNo: Integer;
    begin
        if GetJobStructureEntryNo_FromProdOrderComponent(TransferLine, JobStructureEntryNo) then begin
            TransferLine."EOS Job Structure Entry No." := JobStructureEntryNo;
            TransferLine.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Create Subcontr.Transf. Order", OnPurchaselineOnAfterGetRecordOnAfterTransferLineInsert, '', false, false)]
    local procedure CreateSubcontrTransfOrder_OnPurchaselineOnAfterGetRecordOnAfterTransferLineInsert(var Sender: Report "Create Subcontr.Transf. Order"; var TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line"; PurchaseLine: Record "Purchase Line")
    var
        JobStructureEntryNo: Integer;
    begin
        if GetJobStructureEntryNo_FromProdOrderComponent(TransferLine, JobStructureEntryNo) then begin
            TransferLine."EOS Job Structure Entry No." := JobStructureEntryNo;
            TransferLine.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", OnAfterCreateItemJnlLine, '', false, false)]
    local procedure TransferOrderPostShipment_OnAfterCreateItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferShipmentHeader: Record "Transfer Shipment Header"; TransferShipmentLine: Record "Transfer Shipment Line")
    var
        EngineeringSetup: Record "M365 Engineering Setup";
    begin
        If EngineeringSetup.Read(false) and EngineeringSetup."Modus Engineering Active" then
            ItemJournalLine."M365 Job Structure Entry No." := TransferLine."EOS Job Structure Entry No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", OnBeforePostItemJournalLine, '', false, false)]
    local procedure TransferOrderPostReceipt_OnBeforePostItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; TransferLine: Record "Transfer Line"; TransferReceiptHeader: Record "Transfer Receipt Header"; TransferReceiptLine: Record "Transfer Receipt Line"; CommitIsSuppressed: Boolean; TransLine: Record "Transfer Line"; PostedWhseRcptHeader: Record "Posted Whse. Receipt Header")
    var
        EngineeringSetup: Record "M365 Engineering Setup";
    begin
        If EngineeringSetup.Read(false) and EngineeringSetup."Modus Engineering Active" then
            ItemJournalLine."M365 Job Structure Entry No." := TransferLine."EOS Job Structure Entry No.";
    end;
}