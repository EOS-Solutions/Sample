report 18123474 "EOS Item Cost Detail"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/Item Cost Detail.rdlc';
    Caption = 'Item Cost Detail (IVC)';
    UsageCategory = None;

    dataset
    {
        dataitem("Item Cost History"; "EOS Item Cost History")
        {
            DataItemTableView = SORTING("Period Code", "Item No.") ORDER(Ascending);
            RequestFilterFields = "Item No.";
            column(COMPANYNAME; CompanyName())
            {
            }
            column(ExecutionTime; Format(Today(), 0, 4))
            {
            }
            column(Item_Cost_History_NP_Description; Description)
            {
            }
            column(Item_Cost_History_NP__Item_No__; "Item No.")
            {
            }
            column(Item_Output__Units_per_Parcel_; Item_Output."Units per Parcel")
            {
            }
            column(Item_Cost_History_NP_Base_Unit_of_Measure_; "Item Cost History"."Base Unit of Measure")
            {
            }
            column(Item_Cost_History_NP_Period_Code; "Period Code")
            {
            }
            column(PurchQtyPrint; PurchQtyPrint)
            {
            }
            column(ProdQtyPrint; ProdQtyPrint)
            {
            }
            column(ACPurchAmntPrint; ACPurchAmntPrint)
            {
            }
            column(ACMatAmntPrint; ACMatAmntPrint)
            {
            }
            column(ACRtngAmntPrint; ACRtngAmntPrint)
            {
            }
            dataitem(PurchQtyILE; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(PurchQtyILE_Quantity; PurchaseQtyILE.Quantity)
                {
                }
                column(PurchQtyILE__Order_No__; PurchaseQtyILE."Order No.")
                {
                }
                column(PurchQtyILE__Lot_No__; PurchaseQtyILE."Lot No.")
                {
                }
                column(PurchQtyILE__Location_Code_; PurchaseQtyILE."Location Code")
                {
                }
                column(PurchQtyILE__Document_No__; PurchaseQtyILE."Document No.")
                {
                }
                column(PurchQtyILE__Posting_Date_; PurchaseQtyILE."Posting Date")
                {
                }
                column(PurchQtyILE_gTxtEntryType; EntryType)
                {
                }
                column(PurchQtyILE__Item_No__; PurchaseQtyILE."Item No.")
                {
                }
                column(PurchQtyILE_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        PurchaseQtyILE.FindSet()
                    else
                        PurchaseQtyILE.Next();
                    EntryType := Format(PurchaseQtyILE."Entry Type");
                    PurchQty += PurchaseQtyILE.Quantity;
                end;

                trigger OnPreDataItem()
                begin
                    PurchQtyILE.SetRange(Number, 1, PurchaseQtyILE.Count());
                end;
            }
            dataitem(PrtPurchQty; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                MaxIteration = 1;
                column(PrtPurchQty_gDecPurchQty; PurchQty)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(PrtPurchQty_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not PurchQtyPrint then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if PurchQtyPrint then
                        if (Round("Item Cost History"."Purchased Quantity", RoundPrecision) - Round(PurchQty, RoundPrecision)) <> 0 then
                            Message(PurchQtyLbl +
                            Text002Lbl +
                            Format(Round(("Item Cost History"."Purchased Quantity" - PurchQty), 0.0001)) + Text003Lbl);
                end;
            }
            dataitem(ProdQtyILE; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(ProdQtyILE__Posting_Date_; MfgQtyILE."Posting Date")
                {
                }
                column(ProdQtyILE__Document_No__; MfgQtyILE."Document No.")
                {
                }
                column(ProdQtyILE__Location_Code_; MfgQtyILE."Location Code")
                {
                }
                column(ProdQtyILE_Quantity; MfgQtyILE.Quantity)
                {
                }
                column(ProdQtyILE__Global_Dimension_1_Code_; MfgQtyILE."Global Dimension 1 Code")
                {
                }
                column(ProdQtyILE__Lot_No__; MfgQtyILE."Lot No.")
                {
                }
                column(ProdQtyILE__Order_No__; MfgQtyILE."Order No.")
                {
                }
                column(ProdQtyILE__gTxtErrorText; ErrorText)
                {
                }
                column(ProdQtyILE__gTxtEntryType; EntryType)
                {
                }
                column(ProdQtyILE__Item_No__; MfgQtyILE."Item No.")
                {
                }
                column(ProdQtyILE_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        MfgQtyILE.FindSet()
                    else
                        MfgQtyILE.Next();
                    EntryType := Format(MfgQtyILE."Entry Type");
                    ProdQty += MfgQtyILE.Quantity;
                end;

                trigger OnPreDataItem()
                begin
                    ProdQtyILE.SetRange(Number, 1, MfgQtyILE.Count());
                end;
            }
            dataitem(PrtProdQty; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                MaxIteration = 1;
                column(PrtProdQty_gDecProdQty; ProdQty)
                {
                    DecimalPlaces = 0 : 5;
                }
                column(PrtProdQty_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not ProdQtyPrint then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if ProdQtyPrint then
                        if (Round("Item Cost History"."Processed Quantity", RoundPrecision) - Round(ProdQty, RoundPrecision)) <> 0 then
                            Message(ProcessedQtyLbl +
                            Text002Lbl +
                            Format(Round(("Item Cost History"."Processed Quantity" - ProdQty), 0.0001)) + Text003Lbl);
                end;
            }
            dataitem(ACPurchAmountILE; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(ACPurchAmntILE__External_Document_No__; ACPurchAmntILE."External Document No.")
                {
                }
                column(ACPurchAmntILE__Location_Code_; ACPurchAmntILE."Location Code")
                {
                }
                column(ACPurchAmntILE__Document_No__; ACPurchAmntILE."Document No.")
                {
                }
                column(ACPurchAmntILE__gTxtEntryType; EntryType)
                {
                }
                column(ACPurchAmntILE__Posting_Date_; ACPurchAmntILE."Posting Date")
                {
                }
                column(ACPurchAmntILE__gTxtErrorText; ErrorText)
                {
                }
                column(ACPurchAmntILE__Item_No__; ACPurchAmntILE."Item No.")
                {
                }
                column(ACPurchAmntILE__Cost_Amount__Actual__; ACPurchAmntILE."Cost Amount (Actual)")
                {
                    AutoFormatType = 1;
                }
                column(ACPurchAmntILE__Invoiced_Quantity_; ACPurchAmntILE."Invoiced Quantity")
                {
                }
                column(ACPurchAmountILE_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                var
                begin
                    if Number = 1 then
                        ACPurchAmntILE.FindSet()
                    else
                        ACPurchAmntILE.Next();
                    //MovArtImportoAcqCM."Costo già Rettificato" = FLAG per importo non fatturato
                    EntryType := Format(ACPurchAmntILE."Entry Type");
                    if ACPurchAmntILE."Drop Shipment" then
                        ErrorText := NotInventoryLbl
                    else
                        ErrorText := '';
                    ACPurchAmnt += ACPurchAmntILE."Cost Amount (Actual)";
                end;

                trigger OnPreDataItem()
                begin
                    ACPurchAmountILE.SetRange(Number, 1, ACPurchAmntILE.Count());
                end;
            }
            dataitem(PrtACPurchAmount; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Descending);
                MaxIteration = 1;
                column(PrtACPurchAmount_gDecACPurchAmnt; ACPurchAmnt)
                {
                    AutoFormatType = 1;
                }
                column(PrtACPurchAmount_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not ACPurchAmntPrint then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if ACPurchAmntPrint then
                        if (Round("Item Cost History"."A.C. Purchase Amount", RoundPrecision) - Round(ACPurchAmnt, RoundPrecision)) <> 0 then
                            Message(CostPurchAmtLbl +
                            Text002Lbl +
                            Format(Round(("Item Cost History"."A.C. Purchase Amount" - ACPurchAmnt), 0.0001)) + Text003Lbl);
                end;
            }
            dataitem(ACMatAmountPOComp; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(ACMatAmntPOComp__Item_No; ACMatAmntPOComp."Item No.")
                {
                }
                column(ACMatAmntPOComp__Prod__Order_No__; ACMatAmntPOComp."Prod. Order No.")
                {
                }
                column(ACMatAmntPOComp__Shortcut_Dimension_1_Code_; ACMatAmntPOComp."Shortcut Dimension 1 Code")
                {
                }
                column(ACMatAmntPOComp__Act__Consumption__Qty__; ACMatAmntPOComp."Act. Consumption (Qty)")
                {
                }
                column(ACMatAmntPOComp__Quantity__Base__; ACMatAmntPOComp."Quantity (Base)")
                {
                }
                column(ACMatAmntPOComp__Cost_Amount_; ACMatAmntPOComp."Cost Amount")
                {
                    AutoFormatType = 1;
                }
                column(ACMatAmntPOComp__Location_Code; ACMatAmntPOComp."Location Code")
                {
                }
                column(ACMatAmountPOComp_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        ACMatAmntPOComp.FindSet()
                    else
                        ACMatAmntPOComp.Next();
                    ACMatAmnt += ACMatAmntPOComp."Cost Amount";
                end;

                trigger OnPreDataItem()
                begin
                    ACMatAmountPOComp.SetRange(Number, 1, ACMatAmntPOComp.Count());
                end;
            }
            dataitem(ACMatAmountILE; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(ACMatAmntILE__Remaining_Quantity_; ACMatAmntILE."Remaining Quantity")
                {
                    AutoFormatType = 1;
                }
                column(ACMatAmntILE_Quantity; ACMatAmntILE.Quantity)
                {
                }
                column(ACMatAmntILE__Invoiced_Quantity_; ACMatAmntILE."Invoiced Quantity")
                {
                }
                column(ACMatAmntILE__Order_No__; ACMatAmntILE."Order No.")
                {
                }
                column(ACMatAmntILE__Global_Dimension_1_Code_; ACMatAmntILE."Global Dimension 1 Code")
                {
                }
                column(ACMatAmntILE__Location_Code_; ACMatAmntILE."Location Code")
                {
                }
                column(ACMatAmntILE__Item_No__; ACMatAmntILE."Item No.")
                {
                }
                column(ACMatAmntILE__Document_No__; ACMatAmntILE."Document No.")
                {
                }
                column(ACMatAmntILE__Posting_Date_; ACMatAmntILE."Posting Date")
                {
                }
                column(ACMatAmntILE__Prod_Order_No; '')
                {
                }
                column(ACMatAmntILE_TOTAL__Remaining_Quantity_; ACMatAmntILE_TOTAL."Remaining Quantity")
                {
                    AutoFormatType = 1;
                }
                column(ACMatAmntILE_TOTAL_Quantity; ACMatAmntILE_TOTAL.Quantity)
                {
                }
                column(ACMatAmntILE_TOTAL__Invoiced_Quantity_; ACMatAmntILE_TOTAL."Invoiced Quantity")
                {
                }
                column(ACMatAmntILE_TOTAL__Item_No__; ACMatAmntILE_TOTAL."Item No.")
                {
                }
                column(ACMatAmntILE_Text009; MaterilTotalLbl)
                {
                }
                column(ACMatAmntILE_Item_Consumption_Description; Item_Consumption.Description)
                {
                }
                column(ACMatAmountILE_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        ACMatAmntILE.SetCurrentKey("Item No.");
                        ACMatAmntILE.FindSet();
                        Clear(ACMatAmntILE_TOTAL);
                        ACMatAmntILE_TOTAL."Item No." := ACMatAmntILE."Item No.";
                        PrintACMatAmntILE_TOTAL := false;
                    end else
                        ACMatAmntILE.Next();
                    EntryType := Format(ACMatAmntILE."Entry Type");
                    ACMatAmnt += ACMatAmntILE."Remaining Quantity";

                    if PrintACMatAmntILE_TOTAL then begin
                        Clear(ACMatAmntILE_TOTAL);
                        ACMatAmntILE_TOTAL."Item No." := ACMatAmntILE."Item No.";
                    end;

                    ACMatAmntILE2.Copy(ACMatAmntILE);
                    if ACMatAmntILE.Next() = 0 then
                        //Se è l'ultima riga stampa totale
                        PrintACMatAmntILE_TOTAL := true
                    else
                        //Se è l'ultima riga dell'articolo stampa totale
                        PrintACMatAmntILE_TOTAL := ACMatAmntILE."Item No." <> ACMatAmntILE_TOTAL."Item No.";

                    ACMatAmntILE.Copy(ACMatAmntILE2);

                    ACMatAmntILE_TOTAL."Invoiced Quantity" += ACMatAmntILE."Invoiced Quantity";
                    ACMatAmntILE_TOTAL.Quantity += ACMatAmntILE.Quantity;
                    ACMatAmntILE_TOTAL."Remaining Quantity" += ACMatAmntILE."Remaining Quantity";
                end;

                trigger OnPreDataItem()
                begin
                    ACMatAmountILE.SetRange(Number, 1, ACMatAmntILE.Count());
                end;
            }
            dataitem(PrtACMatAmount; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                MaxIteration = 1;
                column(PrtACMatAmount_gDecACMatAmnt; ACMatAmnt)
                {
                    AutoFormatType = 1;
                }
                column(PrtACMatAmount_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not ACMatAmntPrint then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if ACMatAmntPrint then
                        if (Round("Item Cost History"."A.C. Material Amount", RoundPrecision) - Round(ACMatAmnt, RoundPrecision)) <> 0 then
                            Message(CostMaterialAmtLbl +
                            Text002Lbl +
                            Format(Round(("Item Cost History"."A.C. Material Amount" - ACMatAmnt), 0.0001)) + Text003Lbl);
                end;
            }
            dataitem(RtngAmountPORtngLine; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(RtngAmountPORtngLine__Setup_Time_; ACRtngAmntPORtngLine."Setup Time")
                {
                    AutoFormatType = 1;
                }
                column(RtngAmountPORtngLine__Prod__Order_No__; ACRtngAmntPORtngLine."Prod. Order No.")
                {
                }
                column(RtngAmountPORtngLine__gTxtEntryType; EntryType)
                {
                }
                column(RtngAmountPORtngLine__No__; ACRtngAmntPORtngLine."No.")
                {
                }
                column(RtngAmountPORtngLine__Routing_No__; ACRtngAmntPORtngLine."Routing No.")
                {
                }
                column(RtngAmountPORtngLine_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        ACRtngAmntPORtngLine.FindSet()
                    else
                        ACRtngAmntPORtngLine.Next();
                    EntryType := Format(ACRtngAmntPORtngLine.Type);
                    ACRtngAmnt += ACRtngAmntPORtngLine."Setup Time";
                    ACRtngAmnt += ACRtngAmntPORtngLine."Run Time";
                end;

                trigger OnPreDataItem()
                begin
                    RtngAmountPORtngLine.SetRange(Number, 1, ACRtngAmntPORtngLine.Count());
                end;
            }
            dataitem(RtngAmountCapLE; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(RtngAmountCapLE_Quantity; ACRtngAmntCapLE.Quantity)
                {
                }
                column(RtngAmountCapLE_Order_No__; ACRtngAmntCapLE."Order No.")
                {
                }
                column(RtngAmountCapLE_No__; ACRtngAmntCapLE."No.")
                {
                }
                column(RtngAmountCapLE_Document_No__; ACRtngAmntCapLE."Document No.")
                {
                }
                column(RtngAmountCapLE_Posting_Date_; ACRtngAmntCapLE."Posting Date")
                {
                }
                column(RtngAmountCapLE_Setup_Time_; ACRtngAmntCapLE."Setup Time")
                {
                    AutoFormatType = 1;
                }
                column(RtngAmountCapLE_Run_Time_; ACRtngAmntCapLE."Run Time")
                {
                    AutoFormatType = 1;
                }
                column(RtngAmountCapLE_gTxtEntryType; EntryType)
                {
                }
                column(RtngAmountCapLE_Item_No__; ACRtngAmntCapLE."Item No.")
                {
                }
                column(RtngAmountCapLE_TOTAL__Setup_Time_; ACRtngAmntCapLE_TOTAL."Setup Time")
                {
                    AutoFormatType = 1;
                }
                column(RtngAmountCapLE_TOTAL__Run_Time_; ACRtngAmntCapLE_TOTAL."Run Time")
                {
                    AutoFormatType = 1;
                }
                column(RtngAmountCapLE_TOTAL__No__; ACRtngAmntCapLE_TOTAL."No.")
                {
                }
                column(RtngAmountCapLE_Text010_gTxtEntryType; TotalLbl + ' ' + EntryType)
                {
                }
                column(RtngAmountCapLE_TOTAL_Quantity; ACRtngAmntCapLE_TOTAL.Quantity)
                {
                    AutoFormatType = 1;
                }
                column(RtngAmountCapLE_DescrMovCapacita; DescrMovCapacita)
                {
                }
                column(RtngAmountCapLE_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        ACRtngAmntCapLE.SetCurrentKey(Type, "No.");
                        ACRtngAmntCapLE.FindSet();
                        Clear(ACRtngAmntCapLE_TOTAL);
                        ACRtngAmntCapLE_TOTAL.Type := ACRtngAmntCapLE.Type;
                        ACRtngAmntCapLE_TOTAL."No." := ACRtngAmntCapLE."No.";
                        PrintACRtngAmntCapLE_TOTAL := false;
                    end else
                        ACRtngAmntCapLE.Next();
                    EntryType := Format(ACRtngAmntCapLE.Type);
                    ACRtngAmnt += ACRtngAmntCapLE."Setup Time";  //Direct Cost
                    ACRtngAmnt += ACRtngAmntCapLE."Run Time";

                    if PrintACRtngAmntCapLE_TOTAL then begin
                        Clear(ACRtngAmntCapLE_TOTAL);
                        ACRtngAmntCapLE_TOTAL.Type := ACRtngAmntCapLE.Type;
                        ACRtngAmntCapLE_TOTAL."No." := ACRtngAmntCapLE."No.";
                    end;

                    ACRtngAmntCapLE2.Copy(ACRtngAmntCapLE);
                    if ACRtngAmntCapLE.Next() = 0 then
                        //Se è l'ultima riga stampa totale
                        PrintACRtngAmntCapLE_TOTAL := true
                    else
                        //Se è l'ultima riga dell'articolo stampa totale
                        PrintACRtngAmntCapLE_TOTAL := (ACRtngAmntCapLE.Type <> ACRtngAmntCapLE_TOTAL.Type) or
                                                      (ACRtngAmntCapLE."No." <> ACRtngAmntCapLE_TOTAL."No.");

                    ACRtngAmntCapLE.Copy(ACRtngAmntCapLE2);

                    ACRtngAmntCapLE_TOTAL."Setup Time" += ACRtngAmntCapLE."Setup Time";
                    ACRtngAmntCapLE_TOTAL."Run Time" += ACRtngAmntCapLE."Run Time";
                    ACRtngAmntCapLE_TOTAL.Quantity += ACRtngAmntCapLE.Quantity;
                end;

                trigger OnPreDataItem()
                begin
                    RtngAmountCapLE.SetRange(Number, 1, ACRtngAmntCapLE.Count());
                end;
            }
            dataitem(RtngAmountResLE; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                column(RtngAmountResLE_Total_Cost_; ACRtngAmntResLE."Total Cost")
                {
                    AutoFormatType = 1;
                }
                column(RtngAmountResLE_Quantity; ACRtngAmntResLE.Quantity)
                {
                }
                column(RtngAmountResLE_Order_No__; ACRtngAmntResLE."Order No.")
                {
                }
                column(RtngAmountResLE_Document_No__; ACRtngAmntResLE."Document No.")
                {
                }
                column(RtngAmountResLE_Posting_Date_; ACRtngAmntResLE."Posting Date")
                {
                }
                column(RtngAmountResLE_Resource_No__; ACRtngAmntResLE."Resource No.")
                {
                }
                column(RtngAmountResLE_Prod_Order_No; '')
                {
                }
                column(RtngAmountResLE_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then
                        ACRtngAmntResLE.FindSet()
                    else
                        ACRtngAmntResLE.Next();
                    ACRtngAmnt += ACRtngAmntResLE."Total Cost";
                end;

                trigger OnPreDataItem()
                begin
                    RtngAmountResLE.SetRange(Number, 1, ACRtngAmntResLE.Count());
                end;
            }
            dataitem(PrtRtngAmount; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                MaxIteration = 1;
                column(PrtRtngAmount_gDecACRtngAmnt; ACRtngAmnt)
                {
                    AutoFormatType = 1;
                }
                column(PrtRtngAmount_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not ACRtngAmntPrint then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if ACRtngAmntPrint then
                        if (Round("Item Cost History"."Actual Routing Amount", RoundPrecision) - Round(ACRtngAmnt, RoundPrecision)) <> 0 then
                            Message(RountingAmtLbl +
                            Text002Lbl +
                            Format(Round(("Item Cost History"."Actual Routing Amount" - ACRtngAmnt), 0.0001)) + Text003Lbl);
                end;
            }
            dataitem(PrintTotals; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending);
                MaxIteration = 1;
                column(PrintTotals_Item_Cost_History_NP___Start_Period_Inventory_; "Item Cost History"."Start Period Inventory")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(PrintTotals_Item_Cost_History_NP___End_Period_Inventory_; "Item Cost History"."End Period Inventory")
                {
                    DecimalPlaces = 0 : 5;
                }
                column(PrintTotals_Item_Cost_History_NP___Weighed_Average_Cost_; "Item Cost History"."Weighed Average Cost")
                {
                    AutoFormatType = 2;
                }
                column(PrintTotals_Item_Cost_History_NP___Average_Cost_; "Item Cost History"."Average Cost")
                {
                    AutoFormatType = 2;
                }
                column(PrintTotals_PrevWeighedAverageCost; PrevWeighedAverageCost)
                {
                    AutoFormatType = 2;
                }
                column(PrintTotals_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if ItemCostMgt.GetPrevItemCostHistory("Item Cost History", PrevItemCostHistory) then
                        PrevWeighedAverageCost := PrevItemCostHistory."Weighed Average Cost"
                    else
                        PrevWeighedAverageCost := 0;
                end;
            }

            trigger OnAfterGetRecord()
            var
                CostingPeriod: Record "EOS Costing Period";
            begin
                CostingPeriod.Get("Period Code");
                StartDate := CostingPeriod."Starting Date";
                EndDate := CostingPeriod."Ending Date";
                PurchQty := 0;
                ProdQty := 0;
                ACPurchAmnt := 0;
                ACMatAmnt := 0;
                ACRtngAmnt := 0;
                if PurchQtyPrint then
                    HistCostLog.CalculatePurchasedQty("Period Code", StartDate, EndDate,
                      "Item Cost History"."Item No.", PurchaseQtyILE);
                if ProdQtyPrint then
                    HistCostLog.CalculateProcessedQty("Period Code", StartDate, EndDate,
                      "Item Cost History"."Item No.", MfgQtyILE);
                if ACPurchAmntPrint then
                    HistCostLog.CalculatePurchaseAmount("Period Code", StartDate, EndDate,
                      "Item Cost History"."Item No.", ACPurchAmntILE);
                if ACMatAmntPrint then
                    HistCostLog.CalcMaterialCost("Period Code", StartDate, EndDate, "Item Cost History"."Item No.",
                           ACMatAmntILE, ACMatAmntPOComp);

                if ACRtngAmntPrint then
                    HistCostLog.CalculateRoutingCost("Period Code", StartDate, EndDate,
                      "Item Cost History"."Item No.", ACRtngAmntCapLE, ACRtngAmntPORtngLine, ACRtngAmntResLE);

                Item_Output.Init();
                if Item_Output.Get("Item Cost History"."Item No.") then;

            end;

            trigger OnPreDataItem()
            begin
                RoundPrecision := 0.01;
                Currency.InitRoundingPrecision();
            end;
        }
    }

    requestpage
    {
        Caption = 'Quantity Detail / Cost Amounts';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(gBlnPurchQtyPrint; PurchQtyPrint)
                    {
                        Caption = 'Purchased Quantity';

                        ApplicationArea = All;
                    }
                    field(gBlnProdQtyPrint; ProdQtyPrint)
                    {
                        Caption = 'Processed Quantity';

                        ApplicationArea = All;
                    }
                    field(gBlnACPurchAmntPrint; ACPurchAmntPrint)
                    {
                        Caption = 'Purchase Average Cost Amount';

                        ApplicationArea = All;
                    }
                    field(gBlnACMatAmntPrint; ACMatAmntPrint)
                    {
                        Caption = 'Mat. Average Cost Amount';

                        ApplicationArea = All;
                    }
                    field(gBlnACRtngAmntPrint; ACRtngAmntPrint)
                    {
                        Caption = 'Routing Average Cost Amount';

                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        PageNoCaption = 'Page';
        Ledger_Entries_DetailCaption = 'Ledger Entries Detail';
        Item_Cost_History_NP__Item_No__Caption = 'Item No.';
        Quantity__Base_Caption = 'Quantity (Base)';
        Prod__Order_No_Caption = 'Prod. Order No.';
        Lot_No_Caption = 'Lot No.';
        Location_CodeCaption = 'Location Code';
        Document_No_Caption = 'Document No.';
        Entry_TypeCaption = 'Entry Type';
        Posting_DateCaption = 'Posting Date';
        Purchased_QuantityCaption = 'Purchased Quantity';
        Item_No_Caption = 'Item No.';
        Processed_QuantityCaption = 'Processed Quantity';
        Global_Dimension_1_CodeCaption = 'Global Dimension 1 Code';
        Purchase_AmountCaption = 'Purchase Amount';
        Invoiced_Qty__Base_Caption = 'Invoiced Qty (Base)';
        ImportoCaption = 'Amount';
        Purchase_Average_Cost_AmountCaption = 'Purchase Average Cost Amount';
        Production_Order_Comp__AmountCaption = 'Production Order Comp. Amount';
        AmountCaption = 'Amount';
        Material_No_Caption = 'Material No.';
        Theoretical_QuantityCaption = 'Theoretical Quantity';
        Actual_QuantityCaption = 'Actual Quantity';
        Consumptions_AmountCaption = 'Consumptions Amount';
        Mat__Average_Cost_AmountCaption = 'Mat. Average Cost Amount';
        Production_Order_Routing_AmountCaption = 'Production Order Routing Amount';
        TypeCaption = 'Type';
        Nr_Caption = 'No.';
        Capacity_Entries_AmountCaption = 'Capacity Entries Amount';
        QuantityCaption = 'Quantity';
        Resource_No_Caption = 'Resource No.';
        Resource_Entries_AmountCaption = 'Resource Entries Amount';
        Routing_Average_Cost_AmountCaption = 'Routing Average Cost Amount';
        Start_Period_InventoryCaption = 'Start Period Inventory';
        End_Period_InventoryCaption = 'End Period Inventory';
        Weighed_Average_CostCaption = 'Weighed Average Cost';
        Average_CostCaption = 'Average Cost';
        Prev__Year_Weighed_Average_CostCaption = 'Prev. Year Weighed Average Cost';
        Item_Cost_History_NP__U_M_Base = 'Base U.M.';
        Item_Cost_History_Units_x_Parcel = 'Units x Parcel';
        OvhdAmountCaption = 'Overhead Amount';
    }

    trigger OnInitReport()
    begin
        PurchQtyPrint := true;
        ProdQtyPrint := true;
        ACPurchAmntPrint := true;
        ACMatAmntPrint := true;
        ACRtngAmntPrint := true;
    end;

    var
        PurchaseQtyILE: Record "Item Ledger Entry" temporary;
        MfgQtyILE: Record "Item Ledger Entry" temporary;
        ACPurchAmntILE: Record "Value Entry" temporary;
        ACMatAmntPOComp: Record "Prod. Order Component" temporary;
        ACMatAmntILE: Record "Item Ledger Entry" temporary;
        ACRtngAmntPORtngLine: Record "Prod. Order Routing Line" temporary;
        ACRtngAmntCapLE: Record "Capacity Ledger Entry" temporary;
        ACRtngAmntResLE: Record "Res. Ledger Entry" temporary;
        PrevItemCostHistory: Record "EOS Item Cost History";
        Currency: Record Currency;
        ACMatAmntILE2: Record "Item Ledger Entry" temporary;
        ACMatAmntILE_TOTAL: Record "Item Ledger Entry" temporary;
        ACRtngAmntCapLE2: Record "Capacity Ledger Entry" temporary;
        ACRtngAmntCapLE_TOTAL: Record "Capacity Ledger Entry" temporary;
        Item_Output: Record Item;
        Item_Consumption: Record Item;
        ItemCostMgt: Codeunit "EOS Item Cost Management";
        HistCostLog: Codeunit "EOS History Cost Log";
        PurchQtyLbl: Label 'Attention. Purchased Quantity calculated value\';
        Text002Lbl: Label 'has a variance of ';
        Text003Lbl: Label ' from the table value.';
        ProcessedQtyLbl: Label 'Attention. Processed Quantity calculated value\';
        NotInventoryLbl: Label 'not inv.';
        CostPurchAmtLbl: Label 'Attention. Average Cost Purchase Amount calculated value\';
        CostMaterialAmtLbl: Label 'Attention. Average Cost Material Amount calculated value\';
        RountingAmtLbl: Label 'Attention. Actual Routing Amount calculated value\';
        MaterilTotalLbl: Label 'Mat. Totals';
        TotalLbl: Label 'Totals';
        StartDate: Date;
        EndDate: Date;
        ErrorText: Text[30];
        EntryType: Text[50];
        DescrMovCapacita: Text[50];
        PurchQty: Decimal;
        ACMatAmnt: Decimal;
        ProdQty: Decimal;
        ACPurchAmnt: Decimal;
        ACRtngAmnt: Decimal;
        RoundPrecision: Decimal;
        PrevWeighedAverageCost: Decimal;
        PurchQtyPrint: Boolean;
        ProdQtyPrint: Boolean;
        ACRtngAmntPrint: Boolean;
        ACPurchAmntPrint: Boolean;
        ACMatAmntPrint: Boolean;
        PrintACMatAmntILE_TOTAL: Boolean;
        PrintACRtngAmntCapLE_TOTAL: Boolean;

}

