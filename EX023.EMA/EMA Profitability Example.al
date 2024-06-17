codeunit 50041 "EOS Packaging Costs"
{
    TableNo = "EOS C/A Analysis Code";

    trigger OnRun()
    begin
        CAAnalysisCode := Rec;

        case true of
            CAAnalysisCode."EOS Value Entry No." <> 0:
                FuncValEntry();
        end;

        Rec."EOS Amount" := CAAnalysisCode."EOS Amount";
    end;

    var
        ValueEntry: Record "Value Entry";
        CAAnalysisCode: Record "EOS C/A Analysis Code";
        PremiSetup: Record "PRE Premi Setup";

    procedure FuncValEntry()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntry2: Record "Item Ledger Entry";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Currency: Record Currency;
        PREWACCost: Codeunit "PRE Weighed Average Cost";
        PackagingAmount, WACCost, FactorAmt, DocAmt : Decimal;
    begin
        PremiSetup.Get();
        CAAnalysisCode."EOS Amount" := 0;
        if not ValueEntry.Get(CAAnalysisCode."EOS Value Entry No.") then
            exit;
        if ValueEntry."Document Type" <> ValueEntry."Document Type"::"Sales Invoice" then
            exit;

        PackagingAmount := 0;
        FactorAmt := 0;
        if not IsPacking(ValueEntry."Item No.") then begin
            ItemLedgerEntry2.Get(ValueEntry."Item Ledger Entry No.");
            ItemLedgerEntry.SetFilter("Entry Type", '%1|%2', ItemLedgerEntry."Entry Type"::"Negative Adjmt.", ItemLedgerEntry."Entry Type"::Sale);
            ItemLedgerEntry.SetRange("Document No.", ItemLedgerEntry2."Document No.");
            ItemLedgerEntry.SetRange("PRE Item Type", ItemLedgerEntry."PRE Item Type"::Packing);
            ItemLedgerEntry.SetLoadFields("Item No.", Quantity);
            if ItemLedgerEntry.FindSet() then
                repeat
                    WACCost := PREWACCost.GetCurrentWeighedAverageCost(ItemLedgerEntry."Item No.", CAAnalysisCode."EOS Costing Period");
                    PackagingAmount += (ItemLedgerEntry.Quantity * WACCost);
                until ItemLedgerEntry.Next() = 0;
            if SalesInvoiceLine.Get(ValueEntry."Document No.", ValueEntry."Document Line No.") then
                DocAmt := CalcInvoiceTotalAmount(SalesInvoiceLine."Document No.");
            if DocAmt <> 0 then
                FactorAmt := SalesInvoiceLine.Amount / DocAmt;
            PackagingAmount := PackagingAmount * FactorAmt;
            Currency.InitRoundingPrecision();
            PackagingAmount := Round(PackagingAmount, Currency."Amount Rounding Precision");
        end;
        CAAnalysisCode."EOS Amount" := PackagingAmount;
    end;

    local procedure CalcInvoiceTotalAmount(DocumentNo: code[20]): Decimal
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        Amt: Decimal;
    begin
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SetFilter("No.", '<>%1', '');
        SalesInvoiceLine.SetFilter(Quantity, '<>%1', 0);
        SalesInvoiceLine.CalcSums(Amount);
        Amt := SalesInvoiceLine.Amount;
        //esclusione righe fattura di tipo imballo 
        if PremiSetup."Packing Category Filter" <> '' then begin
            SalesInvoiceLine.SetLoadFields("No.", Amount);
            if SalesInvoiceLine.FindSet() then
                repeat
                    if IsPacking(SalesInvoiceLine."No.") then
                        Amt := Amt - SalesInvoiceLine.Amount;
                until SalesInvoiceLine.Next() = 0;
        end;
        exit(Amt);
    end;

    local procedure IsPacking(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
        TempItem: Record Item temporary;
    begin
        Item.Get(ItemNo);
        Clear(TempItem);
        TempItem.Reset();
        if not TempItem.IsEmpty() then
            TempItem.DeleteAll(false);
        clear(TempItem);
        TempItem.Init();
        TempItem.TransferFields(Item);
        TempItem.Insert(false);
        TempItem.SetFilter("Item Category Code", PremiSetup."Packing Category Filter");
        exit(not TempItem.IsEmpty());
    end;
}