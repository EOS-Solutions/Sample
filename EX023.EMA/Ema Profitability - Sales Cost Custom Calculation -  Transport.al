codeunit 50037 "PRE EMA Extension"
{

    TableNo = "EOS C/A Analysis Code";

    trigger OnRun()
    var
        CAAnalysisCode: Record "EOS C/A Analysis Code";
    begin
        CAAnalysisCode := Rec;
        CAAnalysisCode."EOS Amount" := 0;

        GetTransportCost(CAAnalysisCode);

        Rec."EOS Amount" := CAAnalysisCode."EOS Amount";
    end;

    local procedure GetTransportCost(var CAAnalysisCode: Record "EOS C/A Analysis Code")
    var
        ValueEntry: Record "Value Entry";
        SalesShipmentLine: Record "Sales Shipment Line";
        DocumentShippingPrice: Record "EOS DocumentShippingPrice";
        CWSShipmentLine: Record "EOS CWS Shipment Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Currency: Record Currency;
        Item: Record Item;
        CWSDocNo: Code[20];
        QtyInv, TrasportCost, TmpAmount, CWSTotAmount, CWSTotAmountNotInvoiced : Decimal;
    begin
        if not ValueEntry.Get(CAAnalysisCode."EOS Value Entry No.") then
            exit;
        if ValueEntry."Document Type" <> ValueEntry."Document Type"::"Sales Invoice" then
            exit;
        Item.Get(ValueEntry."Item No.");
        if Item.IsNonInventoriableType() then
            exit;
        PremiSetup.Get();
        if not IsItemCategoryCodeInFilter(Item."Item Category Code") then
            exit;

        Currency.InitRoundingPrecision();
        TmpAmount := 0;
        QtyInv := 0;

        ItemLedgerEntry.Get(ValueEntry."Item Ledger Entry No.");

        if DocumentShippingPrice.Get(DocumentShippingPrice."EOS Document Type"::"Sales Shipment", ItemLedgerEntry."Document No.") Then begin
            if DocumentShippingPrice."EOS Transport Cost (Actual)" <> 0 then
                TrasportCost := DocumentShippingPrice."EOS Transport Cost (Actual)"
            else
                TrasportCost := DocumentShippingPrice."EOS Transport Cost (Expected)";
            if not SalesShipmentLine.Get(ItemLedgerEntry."Document No.", ItemLedgerEntry."Document Line No.") then
                SalesShipmentLine.Init();
            if DocumentShippingPrice."EOS Net Weight" <> 0 then
                TmpAmount := (TrasportCost * SalesShipmentLine."Net Weight") * (SalesShipmentLine.Quantity) / DocumentShippingPrice."EOS Net Weight";
            QtyInv := ValueEntry."Valued Quantity";
            if (QtyInv <> 0) and (QtyInv <> ValueEntry."Valued Quantity") then
                TmpAmount := TmpAmount * ValueEntry."Valued Quantity" / QtyInv;
        end else begin
            CWSDocNo := '';
            CWSShipmentLine.Reset();
            CWSShipmentLine.SetRange("Posted Source Document", CWSShipmentLine."Posted Source Document"::"Posted Shipment");
            CWSShipmentLine.SetRange("Posted Source No.", ItemLedgerEntry."Document No.");
            CWSShipmentLine.SetRange("Posted Source Line No.", ItemLedgerEntry."Document Line No.");
            CWSShipmentLine.SetRange(Type, CWSShipmentLine.Type::Item);
            if CWSShipmentLine.FindLast() then
                CWSDocNo := CWSShipmentLine."Document No.";
            if CWSDocNo <> '' then
                if DocumentShippingPrice.Get(DocumentShippingPrice."EOS Document Type"::"CWS Shipment", CWSDocNo) then begin
                    if DocumentShippingPrice."EOS Transport Cost (Actual)" <> 0 then
                        TrasportCost := DocumentShippingPrice."EOS Transport Cost (Actual)"
                    else
                        TrasportCost := DocumentShippingPrice."EOS Transport Cost (Expected)";
                    if TrasportCost <> 0 then begin
                        CWSTotAmountNotInvoiced := CalcCWSTotAmtNotInvoiced(CWSDocNo);
                        CWSTotAmount := CalcCWSTotAmt(CWSDocNo);
                        if CWSTotAmount <> 0 then begin
                            if CWSTotAmountNotInvoiced <> 0 then
                                TrasportCost := TrasportCost * (CWSTotAmount / (CWSTotAmount + CWSTotAmountNotInvoiced));
                            TmpAmount := (GetCWSLineCost(CWSShipmentLine) / CWSTotAmount) * TrasportCost;
                        end;

                    end;
                end;
        end;

        TmpAmount := Round(TmpAmount, Currency."Amount Rounding Precision");
        CAAnalysisCode."EOS Amount" := TmpAmount;
    end;

    local procedure CalcCWSTotAmt(DocNo: Code[20]): Decimal
    var
        CWSShipmentLine: Record "EOS CWS Shipment Line";
        Item: Record Item;
        Amt: Decimal;
    begin
        CWSShipmentLine.SetRange("Document No.", DocNo);
        CWSShipmentLine.SetRange(Type, CWSShipmentLine.Type::Item);
        CWSShipmentLine.Setfilter("No.", '<>%1', '');
        //CWSShipmentLine.SetRange("Bill/Pay-to No.", '');
        CWSShipmentLine.SetFilter("Quantity (Base)", '<>0');
        if CWSShipmentLine.FindSet() then
            repeat
                Item.Get(CWSShipmentLine."No.");
                if Item.IsInventoriableType() then
                    if IsItemCategoryCodeInFilter(CWSShipmentLine."Item Category Code") then
                        Amt += GetCWSLineCost(CWSShipmentLine);
            until CWSShipmentLine.Next() = 0;
        exit(Amt);
    end;

    local procedure GetCWSLineCost(CWSShipmentLine: Record "EOS CWS Shipment Line"): Decimal
    var
        TempSalesInvoiceLine: Record "Sales Invoice Line" temporary;
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        TempSalesInvoiceLine.Reset();
        TempSalesInvoiceLine.DeleteAll();

        if SalesShipmentLine.Get(CWSShipmentLine."Posted Source No.", CWSShipmentLine."Posted Source Line No.") then
            SalesShipmentLine.GetSalesInvLines(TempSalesInvoiceLine);
        TempSalesInvoiceLine.CalcSums(Amount);
        exit(TempSalesInvoiceLine.Amount);
    end;


    local procedure CalcCWSTotAmtNotInvoiced(DocNo: Code[20]): Decimal
    var
        CWSShipmentLine: Record "EOS CWS Shipment Line";
        Item: Record Item;
        Amt: Decimal;
    begin
        CWSShipmentLine.SetRange("Document No.", DocNo);
        CWSShipmentLine.SetRange(Type, CWSShipmentLine.Type::Item);
        CWSShipmentLine.Setfilter("No.", '<>%1', '');
        //CWSShipmentLine.SetRange("Bill/Pay-to No.", '');
        CWSShipmentLine.SetRange("Posted Source Document", CWSShipmentLine."Posted Source Document"::"Posted Shipment");
        CWSShipmentLine.SetFilter("Posted Source No.", '<>%1', '');
        CWSShipmentLine.SetFilter("Quantity (Base)", '<>0');
        CWSShipmentLine.SetRange("Quantity Invoiced", 0);
        if CWSShipmentLine.FindSet() then
            repeat
                Item.Get(CWSShipmentLine."No.");
                if Item.IsInventoriableType() then
                    if IsItemCategoryCodeInFilter(CWSShipmentLine."Item Category Code") then
                        Amt += GetCWSLineCostNotInvoiced(CWSShipmentLine);
            until CWSShipmentLine.Next() = 0;
        exit(Amt);
    end;

    local procedure GetCWSLineCostNotInvoiced(CWSShipmentLine: Record "EOS CWS Shipment Line"): Decimal
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        SalesLine: Record "Sales Line";
        Amt: Decimal;
    begin
        Amt := 0;
        if SalesShipmentLine.Get(CWSShipmentLine."Posted Source No.", CWSShipmentLine."Posted Source Line No.") then
            if SalesLine.Get(SalesLine."Document Type"::Order, SalesShipmentLine."Order No.", SalesShipmentLine."Order Line No.") then
                Amt += SalesLine.Amount;
        exit(Amt);
    end;

    local procedure IsItemCategoryCodeInFilter(ItemCategoryCode: Code[20]): Boolean
    var
        TempItemCategory: Record "Item Category" temporary;
    begin
        if PremiSetup."Item cat. excl filter from ETC" = '' then
            exit(true);
        TempItemCategory.Init();
        TempItemCategory.Code := ItemCategoryCode;
        TempItemCategory.Insert();

        TempItemCategory.SetFilter(Code, PremiSetup."Item cat. excl filter from ETC");
        if not TempItemCategory.IsEmpty() then
            exit(false)
        else
            exit(true);
    end;

    var
        PremiSetup: Record "PRE Premi Setup";
}