report 18008386 "EOS011 Purch. ProForma Invoice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/EOS Purch. ProFormaInvoice.rdlc';
    Caption = 'Purchase ProForma Invoice';
    UsageCategory = None;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            DataItemTableView = WHERE("Document Type" = CONST(Invoice));

            column(Purchase_Header_Posting_Description; "Posting Description")
            {
            }
            column(Purchase_Header_Document_Type; "Document Type")
            {
            }
            column(Purchase_Header_No_; "No.")
            {
            }
            column(ShowInvoiceText; ShowInvoiceText)
            {
            }
            column(ShowDetails; ShowDetails)
            {
            }
            dataitem(PageCounter; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(IndirizzoSocieta_5; IndirizzoSocieta[5])
                {
                }
                column(IndirizzoSocieta_4; IndirizzoSocieta[4])
                {
                }
                column(IndirizzoSocieta_3; IndirizzoSocieta[3])
                {
                }
                column(IndirizzoSocieta_2; IndirizzoSocieta[2])
                {
                }
                column(IndirizzoSocieta_1; IndirizzoSocieta[1])
                {
                }
                column(STRSUBSTNO___1__FORMAT_CurrReport_PAGENO__; StrSubstNo('%1', Format(CurrReport.PageNo)))
                {
                }
                column(BuyFromAddr_1; BuyFromAddr[1])
                {
                }
                column(BuyFromAddr_2; BuyFromAddr[2])
                {
                }
                column(BuyFromAddr_3; BuyFromAddr[3])
                {
                }
                column(BuyFromAddr_4; BuyFromAddr[4])
                {
                }
                column(BuyFromAddr_5; BuyFromAddr[5])
                {
                }
                column(Purchase_Header___Buy_from_Vendor_No__; "Purchase Header"."Buy-from Vendor No.")
                {
                }
                column(Purchase_Header___No__; "Purchase Header"."No.")
                {
                }
                column(PRO_FORMA_INVOICECaption; PRO_FORMA_INVOICECaptionLbl)
                {
                }
                column(Messrs_Caption; Messrs_CaptionLbl)
                {
                }
                column(PageCaption; PageCaptionLbl)
                {
                }
                column(Your_Supplier_CodeCaption; Your_Supplier_CodeCaptionLbl)
                {
                }
                column(Your_Ref___to_be_included_in_the_invoice_Caption; Your_Ref___to_be_included_in_the_invoice_CaptionLbl)
                {
                }
                column(PageCounter_Number; Number)
                {
                }
                dataitem(CopyLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    dataitem("Purchase Line"; "Purchase Line")
                    {
                        DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                        DataItemLinkReference = "Purchase Header";
                        DataItemTableView = SORTING("Document Type", "Document No.", "Line No.");

                        trigger OnPreDataItem()
                        begin
                            if Find('+') then
                                OrigMaxLineNo := "Line No.";
                            CurrReport.Break;
                        end;
                    }
                    dataitem(RoundLoop; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(STRSUBSTNO___1__FORMAT_CurrReport_PAGENO___Control18004100; StrSubstNo('%1', Format(CurrReport.PageNo)))
                        {
                        }
                        column(Purchase_Header___No___Control18004103; "Purchase Header"."No.")
                        {
                        }
                        column(Purchase_Header___Buy_from_Vendor_No___Control18004107; "Purchase Header"."Buy-from Vendor No.")
                        {
                        }
                        column(Purchase_Line___Line_Amount_; "Purchase Line"."Line Amount")
                        {
                            AutoFormatExpression = "Purchase Line"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(Purchase_Line___Direct_Unit_Cost_; "Purchase Line"."Direct Unit Cost")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 2;
                        }
                        column(Purchase_Line__Quantity; "Purchase Line".Quantity)
                        {
                        }
                        column(Purchase_Line__Description; "Purchase Line".Description)
                        {
                        }
                        column(IVA_Importo_3_; IVA_Importo[3])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Importo_2_; IVA_Importo[2])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Importo_1_; IVA_Importo[1])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Imposta_1_; IVA_Imposta[1])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Imposta_2_; IVA_Imposta[2])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Imposta_3_; IVA_Imposta[3])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Base_1_; IVA_Base[1])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Base_2_; IVA_Base[2])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Base_3_; IVA_Base[3])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Codice_1_; IVA_Codice[1])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Codice_2_; IVA_Codice[2])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(IVA_Codice_3_; IVA_Codice[3])
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATBaseAmount_; VATBaseAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount_; VATAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(VATAmount___VATBaseAmount_; VATAmount + VATBaseAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(PurchWithhContr__Withholding_Tax_Amount_; -PurchWithhContr."Withholding Tax Amount")
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(x___FORMAT_ROUND_PurchWithhContr__Withholding_Tax____0_01_________; ' x ' + Format(Round(PurchWithhContr."Withholding Tax %", 0.01)) + '%  =')
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }
                        column(TxtTotaleIva; TxtTotaleIva)
                        {
                            AutoFormatType = 1;
                        }

                        column(PurchWithhContr__ENASARCO_SalesPerson_Amount_; -EOS011AgentAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        column(x___FORMAT__ROUND_PurchWithhContr__ENASARCO_SalesPerson____0_01________; ' x ' + Format(Round(EOS011AgentPerc, 0.01)) + '% =')
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        column(x_____FORMAT_ROUND_PurchWithhContr__ENASARCO____0_01______; ' x ' + Format(Round(EOS011CompanyPerc, 0.01)) + '%')
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        column(NetTotal; (VATAmount + VATBaseAmount) - PurchWithhContr."Withholding Tax Amount" - EOS011AgentAmount)
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        column(Imponibile_Soggetto___FORMAT_ROUND_PurchWithhContr__Taxable_Base__0_01__; 'Impon. Soggetto:' + Format(Round(PurchWithhContr."Taxable Base", 0.01)))
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        column(Impon_Contributivo___FORMAT_ROUND_PurchWithhContr__ENASARCO_Contribution_Base__0_01__; 'Impon.Contributivo:' + Format(Round(EOS011BaseAmount, 0.01)))
                        {
                            AutoFormatExpression = "Purchase Header"."Currency Code";
                            AutoFormatType = 1;
                        }

                        column(PageCaption_Control18004101; PageCaption_Control18004101Lbl)
                        {
                        }
                        column(Your_Ref___to_be_included_in_the_invoice_Caption_Control18004102; Your_Ref___to_be_included_in_the_invoice_Caption_Control18004102Lbl)
                        {
                        }
                        column(Your_Supplier_CodeCaption_Control18004106; Your_Supplier_CodeCaption_Control18004106Lbl)
                        {
                        }
                        column(Messrs_Caption_Control18004112; Messrs_Caption_Control18004112Lbl)
                        {
                        }
                        column(AmountCaption; AmountCaptionLbl)
                        {
                        }
                        column(Direct_Unit_CostCaption; Direct_Unit_CostCaptionLbl)
                        {
                        }
                        column(Purchase_Line__QuantityCaption; "Purchase Line".FieldCaption(Quantity))
                        {
                        }
                        column(Purchase_Line__DescriptionCaption; Purchase_Line__DescriptionCaptionLbl)
                        {
                        }
                        column(Importo_IVA_InclusaCaption; Importo_IVA_InclusaCaptionLbl)
                        {
                        }
                        column(ImpostaCaption; ImpostaCaptionLbl)
                        {
                        }
                        column(Imponibile_IVACaption; Imponibile_IVACaptionLbl)
                        {
                        }
                        column(RIEPILOGO_IVA___FATTURACaption; RIEPILOGO_IVA___FATTURACaptionLbl)
                        {
                        }
                        column(Codice_IVACaption; Codice_IVACaptionLbl)
                        {
                        }
                        column(RIEPILOGO_IMPORTI_FATTURACaption; RIEPILOGO_IMPORTI_FATTURACaptionLbl)
                        {
                        }
                        column(Ritenuta_d_AccontoCaption; Ritenuta_d_AccontoCaptionLbl)
                        {
                        }
                        column(TOTALE_FATTURACaption; TOTALE_FATTURACaptionLbl)
                        {
                        }
                        column(Totale_ImponibileCaption; Totale_ImponibileCaptionLbl)
                        {
                        }
                        column(Contributo_ENASARCOCaption; Contributo_ENASARCOCaptionLbl)
                        {
                        }
                        column(TOTALE_AL_NETTOCaption; TOTALE_AL_NETTOCaptionLbl)
                        {
                        }
                        column(RoundLoop_Number; Number)
                        {
                        }
                        column(Line_No_; PurchLine."Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            TableID: array[10] of Integer;
                            No: array[10] of Code[20];
                        begin
                            if Number = 1 then
                                TempPurchLine2.Find('-')
                            else
                                TempPurchLine2.Next;
                            "Purchase Line" := TempPurchLine2;

                            with "Purchase Line" do begin
                                if not "Purchase Header"."Prices Including VAT" and
                                   ("VAT Calculation Type" = "VAT Calculation Type"::"Full VAT")
                                then
                                    TempPurchLine2."Line Amount" := 0;

                                if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]
                                then begin
                                    if "Document Type" = "Document Type"::"Credit Memo" then begin
                                        if ("Return Qty. to Ship" <> Quantity) and ("Return Shipment No." = '') then
                                            AddError(StrSubstNo(Text019, FieldCaption("Return Qty. to Ship"), Quantity));
                                        if "Qty. to Invoice" <> Quantity then
                                            AddError(StrSubstNo(Text019, FieldCaption("Qty. to Invoice"), Quantity));
                                    end;
                                    if "Qty. to Receive" <> 0 then
                                        AddError(StrSubstNo(Text040, FieldCaption("Qty. to Receive")));
                                end else begin
                                    if "Document Type" = "Document Type"::Invoice then begin
                                        if ("Qty. to Receive" <> Quantity) and ("Receipt No." = '') then
                                            AddError(StrSubstNo(Text019, FieldCaption("Qty. to Receive"), Quantity));
                                        if "Qty. to Invoice" <> Quantity then
                                            AddError(StrSubstNo(Text019, FieldCaption("Qty. to Invoice"), Quantity));
                                    end;
                                    if "Return Qty. to Ship" <> 0 then
                                        AddError(StrSubstNo(Text040, FieldCaption("Return Qty. to Ship")));
                                end;

                                if not "Purchase Header".Receive then
                                    "Qty. to Receive" := 0;
                                if not "Purchase Header".Ship then
                                    "Return Qty. to Ship" := 0;

                                if ("Document Type" = "Document Type"::Invoice) and ("Receipt No." <> '') then begin
                                    "Quantity Received" := Quantity;
                                    "Qty. to Receive" := 0;
                                end;

                                if ("Document Type" = "Document Type"::"Credit Memo") and ("Return Shipment No." <> '') then begin
                                    "Return Qty. Shipped" := Quantity;
                                    "Return Qty. to Ship" := 0;
                                end;

                                if "Purchase Header".Invoice then begin
                                    if "Document Type" = "Document Type"::"Credit Memo" then
                                        MaxQtyToBeInvoiced := "Return Qty. to Ship" + "Return Qty. Shipped" - "Quantity Invoiced"
                                    else
                                        MaxQtyToBeInvoiced := "Qty. to Receive" + "Quantity Received" - "Quantity Invoiced";
                                    if Abs("Qty. to Invoice") > Abs(MaxQtyToBeInvoiced) then
                                        "Qty. to Invoice" := MaxQtyToBeInvoiced;
                                end else
                                    "Qty. to Invoice" := 0;

                                if "Purchase Header".Receive then begin
                                    QtyToHandle := "Qty. to Receive";
                                    QtyToHandleCaption := FieldCaption("Qty. to Receive");
                                end;

                                if "Purchase Header".Ship then begin
                                    QtyToHandle := "Return Qty. to Ship";
                                    QtyToHandleCaption := FieldCaption("Return Qty. to Ship");
                                end;

                                if "Gen. Prod. Posting Group" <> '' then begin
                                    Clear(GenPostingSetup);
                                    GenPostingSetup.Reset;
                                    GenPostingSetup.SetRange("Gen. Bus. Posting Group", "Gen. Bus. Posting Group");
                                    GenPostingSetup.SetRange("Gen. Prod. Posting Group", "Gen. Prod. Posting Group");
                                    if not GenPostingSetup.Find('+') then
                                        AddError(
                                          StrSubstNo(
                                            Text020,
                                            GenPostingSetup.TableCaption, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group"));
                                end;

                                if Quantity <> 0 then begin
                                    if "No." = '' then
                                        AddError(StrSubstNo(Text006, FieldCaption("No.")));
                                    if Type = 0 then
                                        AddError(StrSubstNo(Text006, FieldCaption(Type)));
                                end else
                                    if Amount <> 0 then
                                        AddError(StrSubstNo(Text021, FieldCaption(Amount), FieldCaption(Quantity)));

                                PurchLine := "Purchase Line";
                                if "Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]
                                then begin
                                    PurchLine."Return Qty. to Ship" := -PurchLine."Return Qty. to Ship";
                                    PurchLine."Qty. to Invoice" := -PurchLine."Qty. to Invoice";
                                end;

                                RemQtyToBeInvoiced := PurchLine."Qty. to Invoice";

                                case "Document Type" of
                                    "Document Type"::"Return Order", "Document Type"::"Credit Memo":
                                        CheckShptLines("Purchase Line");
                                    "Document Type"::Order, "Document Type"::Invoice:
                                        CheckRcptLines("Purchase Line");
                                end;

                                if (Type >= Type::"G/L Account") and ("Qty. to Invoice" <> 0) then
                                    if not GenPostingSetup.Get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group") then
                                        AddError(
                                          StrSubstNo(
                                            Text020,
                                            GenPostingSetup.TableCaption, "Gen. Bus. Posting Group", "Gen. Prod. Posting Group"));

                                case Type of
                                    Type::"G/L Account":
                                        begin
                                            if ("No." = '') and (Amount = 0) then
                                                exit;

                                            if "No." <> '' then
                                                if GLAcc.Get("No.") then begin
                                                    if GLAcc.Blocked then
                                                        AddError(
                                                          StrSubstNo(
                                                            Text007,
                                                            GLAcc.FieldCaption(Blocked), false, GLAcc.TableCaption, "No."));
                                                    if not GLAcc."Direct Posting" and ("Line No." <= OrigMaxLineNo) then
                                                        AddError(
                                                          StrSubstNo(
                                                            Text007,
                                                            GLAcc.FieldCaption("Direct Posting"), true, GLAcc.TableCaption, "No."));
                                                end else
                                                    AddError(
                                                      StrSubstNo(
                                                        Text008,
                                                        GLAcc.TableCaption, "No."));
                                        end;
                                    Type::Item:
                                        begin
                                            if ("No." = '') and (Quantity = 0) then
                                                exit;

                                            if "No." <> '' then
                                                if Item.Get("No.") then begin
                                                    //xxx            IF Item.Blocked THEN
                                                    AddError(
                                                      StrSubstNo(
                                                        Text007,
                                                        Item.FieldCaption(Blocked), false, Item.TableCaption, "No."));
                                                    if Item."Costing Method" = Item."Costing Method"::Specific then begin
                                                        if Item.Reserve = Item.Reserve::Always then begin
                                                            CalcFields("Reserved Quantity");
                                                            if (Signed(Quantity) < 0) and (Abs("Reserved Quantity") < Abs("Qty. to Receive")) then
                                                                AddError(
                                                                  StrSubstNo(
                                                                    Text019,
                                                                    FieldCaption("Reserved Quantity"), Signed("Qty. to Receive")));
                                                        end;
                                                    end;
                                                end else
                                                    AddError(
                                                      StrSubstNo(
                                                        Text008,
                                                        Item.TableCaption, "No."));
                                        end;
                                    Type::"Fixed Asset":
                                        begin
                                            if ("No." = '') and (Quantity = 0) then
                                                exit;

                                            if "No." <> '' then
                                                if FA.Get("No.") then begin
                                                    if FA.Blocked then
                                                        AddError(
                                                          StrSubstNo(
                                                            Text007,
                                                            FA.FieldCaption(Blocked), false, FA.TableCaption, "No."));
                                                    if FA.Inactive then
                                                        AddError(
                                                          StrSubstNo(
                                                            Text007,
                                                            FA.FieldCaption(Inactive), false, FA.TableCaption, "No."));
                                                end else
                                                    AddError(
                                                      StrSubstNo(
                                                        Text008,
                                                        FA.TableCaption, "No."));
                                        end;
                                end;

                                TableID[1] := DimMgt.TypeToTableID3(Type);
                                No[1] := "No.";
                                TableID[2] := DATABASE::Job;
                                No[2] := "Job No.";
                                TableID[3] := DATABASE::"Work Center";
                                No[3] := "Work Center No.";
                                if "Line No." > OrigMaxLineNo then begin
                                    "No." := '';
                                    Type := Type::" ";
                                end;
                            end;
                        end;

                        trigger OnPreDataItem()
                        var
                            MoreLines: Boolean;
                        begin
                            CurrReport.CreateTotals(TempPurchLine2."Line Amount", TempPurchLine2."Inv. Discount Amount");

                            TempPurchLine2.Reset;

                            SetRange(Number, 1, TempPurchLine2.Count);
                        end;
                    }
                    dataitem(VATCounter; "Integer")
                    {
                        DataItemTableView = SORTING(Number);

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);
                        end;

                        trigger OnPreDataItem()
                        begin
                            if VATAmount = 0 then
                                CurrReport.Break;
                            SetRange(Number, 1, VATAmountLine.Count);
                            CurrReport.CreateTotals(
                              VATAmountLine."VAT Base", VATAmountLine."VAT Amount", VATAmountLine."Amount Including VAT",
                              VATAmountLine."Line Amount", VATAmountLine."Inv. Disc. Base Amount",
                              VATAmountLine."Invoice Discount Amount");
                        end;
                    }
                    dataitem(VATCounterLCY; "Integer")
                    {
                        DataItemTableView = SORTING(Number);

                        trigger OnAfterGetRecord()
                        begin
                            VATAmountLine.GetLine(Number);

                            VALVATBaseLCY := Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                               "Purchase Header"."Posting Date", "Purchase Header"."Currency Code",
                                               VATAmountLine."VAT Base", "Purchase Header"."Currency Factor"));
                            VALVATAmountLCY := Round(CurrExchRate.ExchangeAmtFCYToLCY(
                                                 "Purchase Header"."Posting Date", "Purchase Header"."Currency Code",
                                                 VATAmountLine."VAT Amount", "Purchase Header"."Currency Factor"));
                        end;

                        trigger OnPreDataItem()
                        begin
                            if (not GLSetup."Print VAT specification in LCY") or
                               ("Purchase Header"."Currency Code" = '') or
                               (VATAmountLine.GetTotalVATAmount = 0) then
                                CurrReport.Break;

                            SetRange(Number, 1, VATAmountLine.Count);
                            CurrReport.CreateTotals(VALVATBaseLCY, VALVATAmountLCY);

                            if GLSetup."LCY Code" = '' then
                                VALSpecLCYHeader := Text050 + Text051
                            else
                                VALSpecLCYHeader := Text050 + Format(GLSetup."LCY Code");

                            CurrExchRate.FindCurrency("Purchase Header"."Posting Date", "Purchase Header"."Currency Code", 1);
                            VALExchRate := StrSubstNo(Text052, CurrExchRate."Relational Exch. Rate Amount", CurrExchRate."Exchange Rate Amount");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        PurchPost: Codeunit "Purch.-Post";
                        GLAccount: Record "G/L Account";
                        Resource: Record Resource;
                        Item: Record Item;
                        ItemCharge: Record "Item Charge";
                        FixedAsset: Record "Fixed Asset";
                    begin
                        Clear(TempPurchLine);
                        Clear(PurchPost);

                        TempPurchLine.DeleteAll;
                        TempPurchLine2.DeleteAll;
                        VATAmountLine.DeleteAll;

                        PurchPost.GetPurchLines("Purchase Header", TempPurchLine, 1);
                        TempPurchLine.CalcVATAmountLines(0, "Purchase Header", TempPurchLine, VATAmountLine);
                        TempPurchLine.UpdateVATOnLines(0, "Purchase Header", TempPurchLine, VATAmountLine);

                        VATAmount := VATAmountLine.GetTotalVATAmount;
                        VATBaseAmount := VATAmountLine.GetTotalVATBase;
                        VATDiscountAmount :=
                            VATAmountLine.GetTotalVATDiscount("Purchase Header"."Currency Code", "Purchase Header"."Prices Including VAT");
                        TotalAmountInclVAT := VATAmountLine.GetTotalAmountInclVAT;

                        TempPurchLine.Reset;

                        if TempPurchLine.FindSet() then
                            repeat
                                TempPurchLine2.Reset();

                                if not GroupLines then begin
                                    TempPurchLine2 := TempPurchLine;
                                    TempPurchLine2.Insert;

                                end else
                                    if (GroupLines and ShowDetails) then begin
                                        TempPurchLine2.SetRange("Document No.", TempPurchLine."Document No.");
                                        TempPurchLine2.SetRange("Document Type", TempPurchLine."Document Type");
                                        TempPurchLine2.SetRange(Type, TempPurchLine.Type);

                                        TempPurchLine2.SetRange("No.", TempPurchLine."No.");
                                        // TempPurchLine2.SetRange("Direct Unit Cost", TempPurchLine."Direct Unit Cost");
                                        TempPurchLine2.SetRange("VAT Identifier", TempPurchLine."VAT Identifier");

                                        if TempPurchLine2.FindFirst then begin

                                            if TempPurchLine2.Type = 0 then begin
                                                TempPurchLine2.TransferFields(TempPurchLine);
                                                TempPurchLine2."Direct Unit Cost" := TempPurchLine.Amount;

                                                case TempPurchLine2.Type of
                                                    TempPurchLine2.Type::"G/L Account":
                                                        begin
                                                            GLAccount.Get(TempPurchLine2."No.");
                                                            TempPurchLine2.Description := GLAccount.Name;
                                                        end;

                                                    TempPurchLine2.Type::Item:
                                                        begin
                                                            Item.Get(TempPurchLine2."No.");
                                                            TempPurchLine2.Description := Item.Description;
                                                        end;

                                                    TempPurchLine2.Type::"Fixed Asset":
                                                        begin
                                                            FixedAsset.Get(TempPurchLine2."No.");
                                                            TempPurchLine2.Description := FixedAsset.Description;
                                                        end;

                                                    TempPurchLine2.Type::"Charge (Item)":
                                                        begin
                                                            ItemCharge.Get(TempPurchLine2."No.");
                                                            TempPurchLine2.Description := ItemCharge.Description;
                                                        end;
                                                end;

                                                TempPurchLine2.Insert;

                                            end else begin
                                                TempPurchLine2.Amount += TempPurchLine.Amount;
                                                TempPurchLine2."Line Amount" += TempPurchLine."Line Amount";
                                                TempPurchLine2."Unit Cost (LCY)" += TempPurchLine."Unit Cost (LCY)";
                                                TempPurchLine2."Amount Including VAT" += TempPurchLine."Amount Including VAT";
                                                TempPurchLine2."Direct Unit Cost" += TempPurchLine.Amount;
                                                TempPurchLine2.Quantity += TempPurchLine.Quantity;
                                                TempPurchLine2."Outstanding Quantity" += TempPurchLine."Outstanding Quantity";
                                                TempPurchLine2."Qty. to Invoice" += TempPurchLine."Qty. to Invoice";

                                                TempPurchLine2.Modify;
                                            end;

                                        end else begin
                                            TempPurchLine2.TransferFields(TempPurchLine);
                                            TempPurchLine2.Insert;
                                        end;
                                    end;

                            until TempPurchLine.Next = 0;

                        // Start TDAG28658/lma
                        Clear(IVA_Codice);
                        Clear(IVA_Base);
                        Clear(IVA_Imposta);
                        Clear(IVA_Importo);
                        // Stop TDAG28658/lma

                        VATAmountLine.Reset;
                        Idx := 0;
                        if VATAmountLine.FindFirst then
                            repeat
                                Idx += 1;
                                IVA_Codice[Idx] := VATAmountLine."VAT Identifier";
                                IVA_Base[Idx] := VATAmountLine."VAT Base";
                                IVA_Imposta[Idx] := VATAmountLine."VAT Amount";
                                IVA_Importo[Idx] := VATAmountLine."Amount Including VAT";
                            until (VATAmountLine.Next = 0) or (Idx = 5);
                        if Idx < 2 then begin
                            TxtTotaleIva := 'Totale IVA ' + IVA_Codice[1];
                        end else
                            TxtTotaleIva := 'Totale IVA';
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                TableID: array[10] of Integer;
                No: array[10] of Code[20];
            begin
                EOS011BaseAmount := 0;
                EOS011AgentAmount := 0;
                EOS011AgentPerc := 0;
                EOS011CompanyAmount := 0;
                EOS011CompanyPerc := 0;
                EOS011IntegrationAmount := 0;

                EOS011ContributionsUtilities.GetWithhContrEntryForDocument
                (
                    "Purchase Header",
                    EOS011BaseAmount, EOS011AgentAmount, EOS011AgentPerc,
                    EOS011CompanyAmount, EOS011CompanyPerc, EOS011IntegrationAmount
                );

                //---------------------------------------------------------------------------------

                CompanyInfo.Get;
                FormatAddr.Company(IndirizzoSocieta, CompanyInfo);

                FormatAddr.PurchHeaderPayTo(PayToAddr, "Purchase Header");
                FormatAddr.PurchHeaderBuyFrom(BuyFromAddr, "Purchase Header");
                FormatAddr.PurchHeaderShipTo(ShipToAddr, "Purchase Header");
                if "Currency Code" = '' then begin
                    GLSetup.TestField("LCY Code");
                    TotalText := StrSubstNo(Text004, GLSetup."LCY Code");
                    TotalInclVATText := StrSubstNo(Text005, GLSetup."LCY Code");
                    TotalExclVATText := StrSubstNo(Text031, GLSetup."LCY Code");
                end else begin
                    TotalText := StrSubstNo(Text004, "Currency Code");
                    TotalInclVATText := StrSubstNo(Text005, "Currency Code");
                    TotalExclVATText := StrSubstNo(Text031, "Currency Code");
                end;

                Invoice := InvOnNextPostReq;
                Receive := ReceiveShipOnNextPostReq;
                Ship := ReceiveShipOnNextPostReq;

                if "Buy-from Vendor No." = '' then
                    AddError(StrSubstNo(Text006, FieldCaption("Buy-from Vendor No.")))
                else begin
                    if Vend.Get("Buy-from Vendor No.") then begin
                        if Vend.Blocked = Vend.Blocked::All then
                            AddError(
                              StrSubstNo(
                                Text041,
                                Vend.FieldCaption(Blocked), Vend.Blocked, Vend.TableCaption, "Buy-from Vendor No."));
                    end else
                        AddError(
                          StrSubstNo(
                            Text008,
                            Vend.TableCaption, "Buy-from Vendor No."));
                end;

                if "Pay-to Vendor No." = '' then
                    AddError(StrSubstNo(Text006, FieldCaption("Pay-to Vendor No.")))
                else begin
                    if "Pay-to Vendor No." <> "Buy-from Vendor No." then begin
                        if Vend.Get("Pay-to Vendor No.") then begin
                            if Vend.Blocked = Vend.Blocked::All then
                                AddError(
                                  StrSubstNo(
                                    Text041,
                                    Vend.FieldCaption(Blocked), Vend.Blocked::All, Vend.TableCaption, "Pay-to Vendor No."));
                        end else
                            AddError(
                              StrSubstNo(
                                Text008,
                                Vend.TableCaption, "Pay-to Vendor No."));
                    end;
                end;

                PurchSetup.Get;

                if "Posting Date" = 0D then
                    AddError(StrSubstNo(Text006, FieldCaption("Posting Date")))
                else
                    if "Posting Date" <> NormalDate("Posting Date") then
                        AddError(StrSubstNo(Text009, FieldCaption("Posting Date")))
                    else begin
                        if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                            if UserId <> '' then
                                if UserSetup.Get(UserId) then begin
                                    AllowPostingFrom := UserSetup."Allow Posting From";
                                    AllowPostingTo := UserSetup."Allow Posting To";
                                end;
                            if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                                AllowPostingFrom := GLSetup."Allow Posting From";
                                AllowPostingTo := GLSetup."Allow Posting To";
                            end;
                            if AllowPostingTo = 0D then
                                AllowPostingTo := 99991231D;
                        end;
                        if ("Posting Date" < AllowPostingFrom) or ("Posting Date" > AllowPostingTo) then
                            AddError(StrSubstNo(Text010, FieldCaption("Posting Date")));
                    end;

                if ("Document Date" <> 0D) then
                    if ("Document Date" <> NormalDate("Document Date")) then
                        AddError(StrSubstNo(Text009, FieldCaption("Document Date")));

                case "Document Type" of
                    "Document Type"::Order:
                        Ship := false;
                    "Document Type"::Invoice:
                        begin
                            Receive := true;
                            Invoice := true;
                            Ship := false;
                        end;
                    "Document Type"::"Return Order":
                        Receive := false;
                    "Document Type"::"Credit Memo":
                        begin
                            Receive := false;
                            Invoice := true;
                            Ship := true;
                        end;
                end;

                if not (Receive or Invoice or Ship) then
                    AddError(
                      StrSubstNo(
                        Text032,
                        FieldCaption(Receive), FieldCaption(Invoice), FieldCaption(Ship)));

                if Invoice then begin
                    PurchLine.Reset;
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter(Quantity, '<>0');
                    if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                        PurchLine.SetFilter("Qty. to Invoice", '<>0');
                    Invoice := PurchLine.Find('-');
                    if Invoice and (not Receive) and ("Document Type" = "Document Type"::Order) then begin
                        Invoice := false;
                        repeat
                            Invoice := PurchLine."Quantity Received" - PurchLine."Quantity Invoiced" <> 0;
                        until Invoice or (PurchLine.Next = 0);
                    end else
                        if Invoice and (not Ship) and ("Document Type" = "Document Type"::"Return Order") then begin
                            Invoice := false;
                            repeat
                                Invoice := PurchLine."Return Qty. Shipped" - PurchLine."Quantity Invoiced" <> 0;
                            until Invoice or (PurchLine.Next = 0);
                        end;
                end;

                if Receive then begin
                    PurchLine.Reset;
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter(Quantity, '<>0');
                    if "Document Type" = "Document Type"::Order then
                        PurchLine.SetFilter("Qty. to Receive", '<>0');
                    PurchLine.SetRange("Receipt No.", '');
                    Receive := PurchLine.Find('-');
                end;
                if Ship then begin
                    PurchLine.Reset;
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter(Quantity, '<>0');
                    if "Document Type" = "Document Type"::"Return Order" then
                        PurchLine.SetFilter("Return Qty. to Ship", '<>0');
                    PurchLine.SetRange("Return Shipment No.", '');
                    Ship := PurchLine.Find('-');
                end;

                if not (Receive or Invoice or Ship) then
                    AddError(Text012);

                if Invoice then begin
                    PurchLine.Reset;
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.SetFilter("Sales Order Line No.", '<>0');
                    if PurchLine.Find('-') then
                        repeat
                            SalesLine.Get(SalesLine."Document Type"::Order, PurchLine."Sales Order No.", PurchLine."Sales Order Line No.");
                            if Receive and
                              Invoice and
                              (PurchLine."Qty. to Invoice" <> 0) and
                              (PurchLine."Qty. to Receive" <> 0)
                            then begin
                                AddError(Text013);
                            end;
                            if Abs(PurchLine."Quantity Received" - PurchLine."Quantity Invoiced") <
                               Abs(PurchLine."Qty. to Invoice")
                            then
                                PurchLine."Qty. to Invoice" := PurchLine."Quantity Received" - PurchLine."Quantity Invoiced";
                            if Abs(PurchLine.Quantity - (PurchLine."Qty. to Invoice" + PurchLine."Quantity Invoiced")) <
                               Abs(SalesLine.Quantity - SalesLine."Quantity Invoiced")
                            then
                                AddError(
                                  StrSubstNo(
                                    Text014,
                                    PurchLine."Sales Order No."));
                        until PurchLine.Next = 0;
                end;

                if Invoice then
                    if not ("Document Type" in ["Document Type"::"Return Order", "Document Type"::"Credit Memo"]) then
                        if "Due Date" = 0D then
                            AddError(StrSubstNo(Text006, FieldCaption("Due Date")));

                if Receive and ("Receiving No." = '') then
                    if ("Document Type" = "Document Type"::Order) or
                       (("Document Type" = "Document Type"::Invoice) and PurchSetup."Receipt on Invoice")
                    then
                        if "Receiving No. Series" = '' then
                            AddError(
                              StrSubstNo(
                                Text015,
                                FieldCaption("Receiving No. Series")));

                if Ship and ("Return Shipment No." = '') then
                    if ("Document Type" = "Document Type"::"Return Order") or
                       (("Document Type" = "Document Type"::"Credit Memo") and PurchSetup."Return Shipment on Credit Memo")
                    then
                        if "Return Shipment No. Series" = '' then
                            AddError(
                              StrSubstNo(
                                Text015,
                                FieldCaption("Return Shipment No. Series")));

                if Invoice and ("Posting No." = '') then
                    if "Document Type" in ["Document Type"::Order, "Document Type"::"Return Order"] then
                        if "Posting No. Series" = '' then
                            AddError(
                              StrSubstNo(
                                Text015,
                                FieldCaption("Posting No. Series")));

                PurchLine.Reset;
                PurchLine.SetRange("Document Type", "Document Type");
                PurchLine.SetRange("Document No.", "No.");
                PurchLine.SetFilter("Sales Order Line No.", '<>0');
                if PurchLine.Find('-') then begin
                    DropShipOrder := true;
                    if Receive then
                        repeat
                            if SalesHeader."No." <> PurchLine."Sales Order No." then begin
                                SalesHeader.Get(1, PurchLine."Sales Order No.");
                                if SalesHeader."Bill-to Customer No." = '' then
                                    AddError(
                                      StrSubstNo(
                                        Text016,
                                        SalesHeader.FieldCaption("Bill-to Customer No.")));
                                if SalesHeader."Shipping No." = '' then
                                    if SalesHeader."Shipping No. Series" = '' then
                                        AddError(
                                          StrSubstNo(
                                            Text016,
                                            SalesHeader.FieldCaption("Shipping No. Series")));
                            end;
                        until PurchLine.Next = 0;
                end;

                if Invoice then
                    if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then begin
                        if PurchSetup."Ext. Doc. No. Mandatory" and ("Vendor Invoice No." = '') then
                            AddError(StrSubstNo(Text006, FieldCaption("Vendor Invoice No.")));
                    end else
                        if PurchSetup."Ext. Doc. No. Mandatory" and ("Vendor Cr. Memo No." = '') then
                            AddError(StrSubstNo(Text006, FieldCaption("Vendor Cr. Memo No.")));

                if "Vendor Invoice No." <> '' then begin
                    VendLedgEntry.SetCurrentKey("Document Type", "External Document No.", "Vendor No.", "Document Occurrence");
                    VendLedgEntry.SetRange("Document Type", "Document Type");
                    VendLedgEntry.SetRange("External Document No.", "Vendor Invoice No.");
                    VendLedgEntry.SetRange("Vendor No.", "Pay-to Vendor No.");
                    if VendLedgEntry.Find('-') then
                        AddError(
                          StrSubstNo(
                            Text017,
                            "Document Type", "Vendor Invoice No."));
                end;

                TableID[1] := DATABASE::Vendor;
                No[1] := "Pay-to Vendor No.";
                TableID[2] := DATABASE::"Salesperson/Purchaser";
                No[2] := "Purchaser Code";
                TableID[3] := DATABASE::Campaign;
                No[3] := "Campaign No.";
                TableID[4] := DATABASE::"Responsibility Center";
                No[4] := "Responsibility Center";

                PurchWithhContr.Reset;
                ExistPurchContr := false;
                if PurchWithhContr.Get("Purchase Header"."Document Type", "Purchase Header"."No.") then
                    ExistPurchContr := true
                else
                    PurchWithhContr.Init;

                for i := 1 to 8 do begin
                    if BuyFromAddr[i] = '' then begin
                        BuyFromAddr[i] := 'Partita IVA : ' + "VAT Registration No.";
                        i := 8;
                    end;
                end;
                for i := 1 to 8 do begin
                    if IndirizzoSocieta[i] = '' then begin
                        IndirizzoSocieta[i] := 'Partita IVA : ' + CompanyInfo."VAT Registration No.";
                        i := 8;
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                PurchHeader.Copy("Purchase Header");
                PurchHeader.FilterGroup := 2;
                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                if PurchHeader.Find('-') then begin
                    case true of
                        ReceiveShipOnNextPostReq and InvOnNextPostReq:
                            ReceiveInvoiceText := Text000;
                        ReceiveShipOnNextPostReq:
                            ReceiveInvoiceText := Text001;
                        InvOnNextPostReq:
                            ReceiveInvoiceText := Text002;
                    end;
                    ReceiveInvoiceText := StrSubstNo(Text003, ReceiveInvoiceText);
                end;
                PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::"Return Order");
                if PurchHeader.Find('-') then begin
                    case true of
                        ReceiveShipOnNextPostReq and InvOnNextPostReq:
                            ShipInvoiceText := Text028;
                        ReceiveShipOnNextPostReq:
                            ShipInvoiceText := Text029;
                        InvOnNextPostReq:
                            ShipInvoiceText := Text002;
                    end;
                    ShipInvoiceText := StrSubstNo(Text030, ShipInvoiceText);
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowDetails; ShowDetails)
                    {
                        Caption = 'Show Details';
                        ToolTip = 'Show Details';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if (not ShowDetails) then GroupLines := false;
                        end;
                    }
                    field(GroupLines; GroupLines)
                    {
                        Caption = 'Grouped Lines for No.';
                        ToolTip = 'Grouped Lines for No.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if (not ShowDetails) then GroupLines := false;
                        end;
                    }
                }
            }
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        GLSetup.Get;
    end;

    trigger OnPreReport()
    begin
        PurchHeaderFilter := "Purchase Header".GetFilters;
    end;

    var
        Text000: Label 'Receive and Invoice';
        Text001: Label 'Receive';
        Text002: Label 'Invoice';
        Text003: Label 'Order Posting: %1';
        Text004: Label 'Total %1';
        Text005: Label 'Total %1 Incl. VAT';
        Text006: Label '%1 must be specified.';
        Text007: Label '%1 must be %2 for %3 %4.';
        Text008: Label '%1 %2 does not exist.';
        Text009: Label '%1 must not be a closing date.';
        Text010: Label '%1 is not within your allowed range of posting dates.';
        Text012: Label 'There is nothing to post.';
        Text013: Label 'A drop shipment from a purchase order cannot be received and invoiced at the same time.';
        Text014: Label 'Please invoice sales order %1 before invoicing this purchase order.';
        Text015: Label '%1 must be entered.';
        Text016: Label '%1 must be entered on the sales order header.';
        Text017: Label 'Purchase %1 %2 already exists for this vendor.';
        Text018: Label 'Purchase Document: %1';
        Text019: Label '%1 must be %2.';
        Text020: Label '%1 %2 %3 does not exist.';
        Text021: Label '%1 must be 0 when %2 is 0.';
        Text022: Label 'The %1 on the receipt is not the same as the %1 on the purchase header.';
        Text023: Label '%1 must have the same sign as the receipt.';
        Text025: Label '%1 must have the same sign as the return shipment.';
        Text028: Label 'Ship and Invoice';
        Text029: Label 'Ship';
        Text030: Label 'Return Order Posting: %1';
        Text031: Label 'Total %1 Excl. VAT';
        Text032: Label 'Enter "Yes" in %1 and/or %2 and/or %3.';
        Text033: Label 'Line %1 of the receipt %2, which you are attempting to invoice, has already been invoiced.';
        Text034: Label 'Line %1 of the return shipment %2, which you are attempting to invoice, has already been invoiced.';
        Text036: Label 'The %1 on the return shipment is not the same as the %1 on the purchase header.';
        Text037: Label 'The quantity you are attempting to invoice is greater than the quantity in receipt %1.';
        Text038: Label 'The quantity you are attempting to invoice is greater than the quantity in return shipment %1.';
        PurchSetup: Record "Purchases & Payables Setup";
        GLSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        Vend: Record Vendor;
        VendLedgEntry: Record "Vendor Ledger Entry";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchLine2: Record "Purchase Line";
        TempPurchLine: Record "Purchase Line" temporary;
        GLAcc: Record "G/L Account";
        Item: Record Item;
        FA: Record "Fixed Asset";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ReturnShptLine: Record "Return Shipment Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GenPostingSetup: Record "General Posting Setup";
        VATAmountLine: Record "VAT Amount Line" temporary;
        CurrExchRate: Record "Currency Exchange Rate";
        FormatAddr: Codeunit "Format Address";
        DimMgt: Codeunit DimensionManagement;
        PayToAddr: array[8] of Text[50];
        BuyFromAddr: array[8] of Text[50];
        ShipToAddr: array[8] of Text[50];
        PurchHeaderFilter: Text[250];
        ErrorText: array[100] of Text[150];
        DimText: Text[120];
        OldDimText: Text[75];
        ReceiveInvoiceText: Text[50];
        ShipInvoiceText: Text[50];
        TotalText: Text[50];
        TotalInclVATText: Text[50];
        TotalExclVATText: Text[50];
        QtyToHandleCaption: Text[30];
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        MaxQtyToBeInvoiced: Decimal;
        RemQtyToBeInvoiced: Decimal;
        QtyToBeInvoiced: Decimal;
        QtyToHandle: Decimal;
        VATAmount: Decimal;
        VATBaseAmount: Decimal;
        VATDiscountAmount: Decimal;
        TotalAmountInclVAT: Decimal;
        ErrorCounter: Integer;
        OrigMaxLineNo: Integer;
        DropShipOrder: Boolean;
        InvOnNextPostReq: Boolean;
        ReceiveShipOnNextPostReq: Boolean;
        ShowDim: Boolean;
        Continue: Boolean;
        ShowItemChargeAssgnt: Boolean;
        Text040: Label '%1 must be zero.';
        Text041: Label '%1 must not be %2 for %3 %4.';
        Text050: Label 'VAT Amount Specification in ';
        Text051: Label 'Local Currency';
        Text052: Label 'Exchange rate: %1/%2';
        VALVATBaseLCY: Decimal;
        VALVATAmountLCY: Decimal;
        VALSpecLCYHeader: Text[80];
        VALExchRate: Text[50];
        _SPAC_: Integer;
        CompanyInfo: Record "Company Information";
        IndirizzoSocieta: array[8] of Text[60];
        TempPurchLine2: Record "Purchase Line" temporary;
        Text500: Label 'TOTAL AMOUNT';
        PurchWithhContr: Record "Purch. Withh. Contribution";
        ExistPurchContr: Boolean;
        IVA_Codice: array[5] of Code[10];
        IVA_Base: array[5] of Decimal;
        IVA_Importo: array[5] of Decimal;
        IVA_Imposta: array[5] of Decimal;
        IVA_Tot_Base: Decimal;
        IVA_Tot_Imposta: Decimal;
        IVA_Tot_Importo: Decimal;
        Idx: Integer;
        TxtTotaleIva: Text[30];
        i: Integer;
        ShowInvoiceText: Boolean;
        GroupLines: Boolean;
        PRO_FORMA_INVOICECaptionLbl: Label 'PRO-FORMA INVOICE';
        Messrs_CaptionLbl: Label 'Messrs.';
        PageCaptionLbl: Label 'Page';
        Your_Supplier_CodeCaptionLbl: Label 'Your Supplier Code';
        Your_Ref___to_be_included_in_the_invoice_CaptionLbl: Label 'Your Document Ref.';
        PageCaption_Control18004101Lbl: Label 'Page';
        Your_Ref___to_be_included_in_the_invoice_Caption_Control18004102Lbl: Label 'Your Document Ref.';
        Your_Supplier_CodeCaption_Control18004106Lbl: Label 'Your Supplier Code';
        Messrs_Caption_Control18004112Lbl: Label 'Messrs.';
        AmountCaptionLbl: Label 'Amount';
        Direct_Unit_CostCaptionLbl: Label 'Direct Unit Cost';
        Purchase_Line__DescriptionCaptionLbl: Label 'Description';
        Importo_IVA_InclusaCaptionLbl: Label 'Amount Including VAT';
        ImpostaCaptionLbl: Label 'Tax';
        Imponibile_IVACaptionLbl: Label 'VAT Base';
        RIEPILOGO_IVA___FATTURACaptionLbl: Label 'RIEPILOGO IVA - FATTURA';
        Codice_IVACaptionLbl: Label 'VAT Identifier';
        RIEPILOGO_IMPORTI_FATTURACaptionLbl: Label 'Invoice Amounts Summary';
        Ritenuta_d_AccontoCaptionLbl: Label 'Withholding Tax';
        TOTALE_FATTURACaptionLbl: Label 'DOCUMENT TOTAL';
        Totale_ImponibileCaptionLbl: Label 'Total Base';
        Contributo_ENASARCOCaptionLbl: Label 'ENASARCO contribution';
        TOTALE_AL_NETTOCaptionLbl: Label 'NET TOTAL';
        ShowDetails: Boolean;
        //------------------------------------------------------------------------------------------------------
        EOS011ContributionsUtilities: Codeunit "EOS011 Contributions Utilities";
        EOS011BaseAmount: Decimal;
        EOS011AgentAmount: Decimal;
        EOS011AgentPerc: Decimal;
        EOS011CompanyAmount: Decimal;
        EOS011CompanyPerc: Decimal;
        EOS011IntegrationAmount: Decimal;

    local procedure AddError(Text: Text[250])
    begin
        ErrorCounter := ErrorCounter + 1;
        if ErrorCounter < 100 then
            ErrorText[ErrorCounter] := Text;
    end;

    local procedure CheckRcptLines(PurchLine2: Record "Purchase Line")
    begin
        with PurchLine2 do begin
            if Abs(RemQtyToBeInvoiced) > Abs("Qty. to Receive") then begin
                PurchRcptLine.Reset;
                case "Document Type" of
                    "Document Type"::Order:
                        begin
                            PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.");
                            PurchRcptLine.SetRange("Order No.", "Document No.");
                            PurchRcptLine.SetRange("Order Line No.", "Line No.");
                        end;
                    "Document Type"::Invoice:
                        begin
                            PurchRcptLine.SetRange("Document No.", "Receipt No.");
                            PurchRcptLine.SetRange("Line No.", "Receipt Line No.");
                        end;
                end;

                PurchRcptLine.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
                if PurchRcptLine.Find('-') then
                    repeat
                        if PurchRcptLine."Buy-from Vendor No." <> "Buy-from Vendor No." then
                            AddError(
                              StrSubstNo(
                                Text022,
                                FieldCaption("Buy-from Vendor No.")));
                        if PurchRcptLine.Type <> Type then
                            AddError(
                              StrSubstNo(
                                Text022,
                                FieldCaption(Type)));
                        if PurchRcptLine."No." <> "No." then
                            AddError(
                              StrSubstNo(
                                Text022,
                                FieldCaption("No.")));
                        if PurchRcptLine."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                            AddError(
                              StrSubstNo(
                                Text022,
                                FieldCaption("Gen. Bus. Posting Group")));
                        if PurchRcptLine."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" then
                            AddError(
                              StrSubstNo(
                                Text022,
                                FieldCaption("Gen. Prod. Posting Group")));
                        if PurchRcptLine."Location Code" <> "Location Code" then
                            AddError(
                              StrSubstNo(
                                Text022,
                                FieldCaption("Location Code")));
                        if PurchRcptLine."Job No." <> "Job No." then
                            AddError(
                              StrSubstNo(
                                Text022,
                                FieldCaption("Job No.")));

                        if PurchLine."Qty. to Invoice" * PurchRcptLine.Quantity < 0 then
                            AddError(StrSubstNo(Text023, FieldCaption("Qty. to Invoice")));

                        QtyToBeInvoiced := RemQtyToBeInvoiced - PurchLine."Qty. to Receive";
                        if Abs(QtyToBeInvoiced) > Abs(PurchRcptLine.Quantity - PurchRcptLine."Quantity Invoiced") then
                            QtyToBeInvoiced := PurchRcptLine.Quantity - PurchRcptLine."Quantity Invoiced";
                        RemQtyToBeInvoiced := RemQtyToBeInvoiced - QtyToBeInvoiced;
                        PurchRcptLine."Quantity Invoiced" := PurchRcptLine."Quantity Invoiced" + QtyToBeInvoiced;
                    until (PurchRcptLine.Next = 0) or (Abs(RemQtyToBeInvoiced) <= Abs("Qty. to Receive"))
                else
                    AddError(
                      StrSubstNo(
                        Text033,
                        "Receipt Line No.",
                        "Receipt No."));
            end;

            if Abs(RemQtyToBeInvoiced) > Abs("Qty. to Receive") then
                if "Document Type" = "Document Type"::Invoice then
                    AddError(
                      StrSubstNo(
                        Text037,
                        "Receipt No."))
        end;
    end;

    local procedure CheckShptLines(PurchLine2: Record "Purchase Line")
    begin
        with PurchLine2 do begin
            if Abs(RemQtyToBeInvoiced) > Abs("Return Qty. to Ship") then begin
                ReturnShptLine.Reset;
                case "Document Type" of
                    "Document Type"::"Return Order":
                        begin
                            ReturnShptLine.SetCurrentKey("Return Order No.", "Return Order Line No.");
                            ReturnShptLine.SetRange("Return Order No.", "Document No.");
                            ReturnShptLine.SetRange("Return Order Line No.", "Line No.");
                        end;
                    "Document Type"::"Credit Memo":
                        begin
                            ReturnShptLine.SetRange("Document No.", "Return Shipment No.");
                            ReturnShptLine.SetRange("Line No.", "Return Shipment Line No.");
                        end;
                end;

                PurchRcptLine.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
                if ReturnShptLine.Find('-') then
                    repeat
                        if ReturnShptLine."Buy-from Vendor No." <> "Buy-from Vendor No." then
                            AddError(
                              StrSubstNo(
                                Text036,
                                FieldCaption("Buy-from Vendor No.")));
                        if ReturnShptLine.Type <> Type then
                            AddError(
                              StrSubstNo(
                                Text036,
                                FieldCaption(Type)));
                        if ReturnShptLine."No." <> "No." then
                            AddError(
                              StrSubstNo(
                                Text036,
                                FieldCaption("No.")));
                        if ReturnShptLine."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                            AddError(
                              StrSubstNo(
                                Text036,
                                FieldCaption("Gen. Bus. Posting Group")));
                        if ReturnShptLine."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" then
                            AddError(
                              StrSubstNo(
                                Text036,
                                FieldCaption("Gen. Prod. Posting Group")));
                        if ReturnShptLine."Location Code" <> "Location Code" then
                            AddError(
                              StrSubstNo(
                                Text036,
                                FieldCaption("Location Code")));
                        if ReturnShptLine."Job No." <> "Job No." then
                            AddError(
                              StrSubstNo(
                                Text036,
                                FieldCaption("Job No.")));

                        if (-PurchLine."Qty. to Invoice") * ReturnShptLine.Quantity < 0 then
                            AddError(StrSubstNo(Text025, FieldCaption("Qty. to Invoice")));
                        QtyToBeInvoiced := RemQtyToBeInvoiced - PurchLine."Return Qty. to Ship";
                        if Abs(QtyToBeInvoiced) > Abs(ReturnShptLine.Quantity - ReturnShptLine."Quantity Invoiced") then
                            QtyToBeInvoiced := ReturnShptLine.Quantity - ReturnShptLine."Quantity Invoiced";
                        RemQtyToBeInvoiced := RemQtyToBeInvoiced - QtyToBeInvoiced;
                        ReturnShptLine."Quantity Invoiced" := ReturnShptLine."Quantity Invoiced" + QtyToBeInvoiced;
                    until (ReturnShptLine.Next = 0) or (Abs(RemQtyToBeInvoiced) <= Abs("Return Qty. to Ship"))
                else
                    AddError(
                      StrSubstNo(
                        Text034,
                        "Return Shipment Line No.",
                        "Return Shipment No."));
            end;

            if Abs(RemQtyToBeInvoiced) > Abs("Return Qty. to Ship") then
                if "Document Type" = "Document Type"::"Credit Memo" then
                    AddError(
                      StrSubstNo(
                        Text038,
                        "Return Shipment No."));
        end;
    end;
}

