page 50525 "EOI JobPSPLineListPart"
{
    AutoSplitKey = true;
    Caption = 'WBS-Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = KVSPSAJobPSPLine;

    layout
    {
        area(Content)
        {
            repeater(RepeaterControl)
            {
                FreezeColumn = Description;
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowAsTree = true;
                field(PositionNo; Rec."Position No.")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MyLineStyle;
                }
                /*field(Milestone; Rec.Milestone)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        MyLineStyle := Rec.GetLineTypeStyle(false);
                    end;
                }*/
                /*lma2 field(AssignedAsMilestoneBase; Rec."Assigned as Milestone Base")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }*/
                /*lma2 field(NoOfPrecursors; Rec."No. of Precursors")
                {
                    ApplicationArea = KVSPSABasic;
                    DrillDownPageId = KVSPSAPSPLineTaskLinksForLine;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                /*lma2 field(NoOfSuccessors; Rec."No. of Successors")
                {
                    ApplicationArea = KVSPSABasic;
                    DrillDownPageId = KVSPSAPSPLineTaskLinksToLine;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                /*field(Precursors; Rec.Precursors)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(Successors; Rec.Successors)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field(Type; Rec.Type)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MyLineStyle;

                    trigger OnValidate()
                    begin
                        TypeChosen := Rec.Type = Rec.Type::"Work Package";
                        MyLineStyle := Rec.GetLineTypeStyle(false);
                    end;
                }
                field(No; Rec."No.")
                {
                    ApplicationArea = KVSPSABasic;
                    ShowMandatory = TypeChosen;
                    StyleExpr = MyLineStyle;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MyLineStyle;
                }
                field(EOIStartingDatePM; EOIStartingDate)
                {
                    Caption = 'Starting Date';
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        EOIFunction: Codeunit "EOI Functions";
                    begin
                        //Start TDAG48302/dc
                        SkipSalesBudgetBlocked := true;
                        //Stop TDAG48302/dc
                        EOIFunction.WBSEOIStartingDateValidate(rec, EOIStartingDate);
                        CurrPage.Update(false);

                    end;
                }
                field(EOIEndingDatePM; EOIEndingDate)
                {
                    Caption = 'Ending Date';
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        EOIFunction: Codeunit "EOI Functions";
                    begin
                        //Start TDAG48302/dc
                        SkipSalesBudgetBlocked := true;
                        //Stop TDAG48302/dc
                        EOIFunction.WBSEOIEndingDateValidate(rec, EOIEndingDate);
                        CurrPage.Update(false);

                    end;
                }
                field("Posting Progress %"; rec."Posting Progress %")
                {
                    ApplicationArea = all;
                    StyleExpr = MySumStyle;
                    Visible = true;
                }
                field("KVSPSAInvoicing Type"; rec."KVSPSAInvoicing Type")
                {
                    ApplicationArea = all;
                }
                field(EOIWorkStatusDatePM; EOIWorkStatus)
                {
                    Caption = 'Work Status';
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        EOIFunction: Codeunit "EOI Functions";
                    begin
                        //Start TDAG48302/dc
                        SkipSalesBudgetBlocked := true;
                        //Stop TDAG48302/dc
                        EOIFunction.WBSEOIWorkStatusValidate(rec, EOIWorkStatus);
                        CurrPage.Update(false);

                    end;
                }
                field(EOIJobProgressPM; EOIJobProgress)
                {
                    Caption = 'Job Progress %';
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        EOIFunction: Codeunit "EOI Functions";
                    begin
                        //Start TDAG48302/dc
                        SkipSalesBudgetBlocked := true;
                        //Stop TDAG48302/dc
                        EOIFunction.WBSEOIJobProgressValidate(rec, EOIJobProgress);
                        CurrPage.Update(false);
                    end;

                    trigger OnAssistEdit()
                    var
                        JobProgressPercHistory: Record "EOI Job Progress Perc. History";
                        JobProgressPercHistList: Page "EOI Job Pro Perc. Hist. List";
                    begin
                        //Start TDAG45766/dc
                        CLEAR(JobProgressPercHistList);
                        JobProgressPercHistory.Reset();
                        JobProgressPercHistory.SETRANGE("Job No.", rec."Job No.");
                        JobProgressPercHistory.SETRANGE("Line No.", rec."Line No.");
                        JobProgressPercHistList.SETTABLEVIEW(JobProgressPercHistory);
                        JobProgressPercHistList.RunModal();
                        //Stop TDAG45766/dc
                    end;
                }
                field("Last Date Job Progress %"; rec."EOI Last Date Job Progress %")
                {
                    ApplicationArea = all;
                }
                field("Work Type Code"; rec."Work Type Code")
                {
                    ApplicationArea = all;
                }
                field("Stat. Phase Code"; rec."EOI Stat. Phase Code")
                {
                    Visible = false;
                    ApplicationArea = all;
                }

                field(EOIBudgetIncrementFactorPM; EOIBudgetIncrementFactor)
                {
                    Caption = 'Budget Increment Factor';
                    ApplicationArea = all;
                    trigger OnValidate()
                    var
                        EOIFunction: Codeunit "EOI Functions";
                    begin
                        EOIFunction.WBSEOIBudgetIncrementFactorValidate(rec, EOIBudgetIncrementFactor);
                        CurrPage.Update(false);
                        //Start TDAG48302/dc
                        SkipSalesBudgetBlocked := true;
                        //Stop TDAG48302/dc
                    end;
                }

                field("Milestone Review"; rec."EOI Milestone Review")
                {
                    ApplicationArea = all;
                }

                /*field(Description2; Rec."Description 2")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MyLineStyle;
                    Visible = false;
                }
                field(DifferingSalesDescription; Rec."Differing Sales Description")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(DifferingSalesDescription2; Rec."Differing Sales Description 2")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(PhaseCode; Rec."Phase Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(TaskCode; Rec."Task Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(StepCode; Rec."Step Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(StartingDate; Rec."Starting Date")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MyLineStyle;
                }
                field(EndingDate; Rec."Ending Date")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MyLineStyle;
                }
                field(DurationInDays; Rec."Duration in Days")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(ClosingDate; Rec."Closing Date")
                {
                    ApplicationArea = KVSPSABasic;
                    Editable = false;
                    Visible = false;
                }
                field(PlanningType; Rec."Planning Type")
                {
                    ApplicationArea = KVSPSABasic;
                    ToolTip = 'For MS-project Interface';
                    Visible = false;
                }
                field(NoConsiderationinPlanning; Rec."No Consideration in Planning")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(FixedStartingDate; Rec."Fixed Starting Date")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(FixedEndingDate; Rec."Fixed Ending Date")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }*/
                field(TransferInSalesDoc; Rec."Transfer in Sales Doc")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;

                    trigger OnValidate()
                    begin
                        Rec.ModifyWorkPackageLinesFromBeginTotal(0);
                        CurrPage.Update();
                    end;
                }
                /*field(UseAsBundle; Rec."Use as bundle")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(InvoicingIntegration; Rec."Invoicing Integration")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field(InvoicingType; Rec."KVSPSAInvoicing Type")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;

                    trigger OnValidate()
                    begin
                        PSPCalc.CalcOutStandingPrice(Rec);
                        Rec.ModifyWorkPackageLinesFromBeginTotal(1);
                        CurrPage.Update();
                    end;
                }
                /*field(InvoicingDelimination; Rec."Invoicing Delimination")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(Control5025957; Rec."Invoicing Delimination %")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(IgnorePaymPlaninInvSugg; Rec."Ignore Paym.-Plan in Inv-Sugg.")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field(Status; Rec.PSPStatus)
                {
                    ApplicationArea = KVSPSABasic;
                    HideValue = IsEmptyTypeLine;
                    StyleExpr = MySumStyle;

                    trigger OnValidate()
                    begin
                        Rec.ModifyWorkPackageLinesFromBeginTotal(2);
                        CurrPage.Update();
                    end;
                }/*
                field(WorkStatus; Rec."Work Status")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;

                    trigger OnValidate()
                    begin
                        Rec.ModifyWorkPackageLinesFromBeginTotal(3);
                        CurrPage.Update();
                    end;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Requisition; Rec.Requisition)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field(Budgetcalculation; Rec."Budget calculation")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;

                    trigger OnValidate()
                    begin
                        Rec.ModifyWorkPackageLinesFromBeginTotal(4);
                        CurrPage.Update();
                    end;
                }
                /*field(NoTransferToTempVision; Rec."No Transfer to TempVision")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                    Enabled = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved to TempvisionPSA Bridge App.';
                    ObsoleteTag = '19.0';
                }*/
                /*field(SalesBudgetBlocked; Rec."Sales Budget Blocked")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(TimePostingwProgress; Rec."Time Posting w. Progress")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                /*field(JobProgress; Rec."Job Progress %")
                {
                    ApplicationArea = KVSPSABasic;
                    DecimalPlaces = 0 : 2;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(PostingProgress; Rec."Posting Progress %")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(ToDoProgress; Rec."KVSPSATo-Do Progress")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                /*lma2 field(Comment; Rec.Comment)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                /*lma2 field("Previous Text"; Rec."Previous Text")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ShowTextLines(Enum::KVSKBATextPosition::"Previous Text");
                    end;
                }*/
                /*lma 2field("After Text"; Rec."After Text")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ShowTextLines(Enum::KVSKBATextPosition::"After Text");
                    end;
                }*/
                /*field(WorkTypeCode; Rec."Work Type Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(ICPartnerCode; Rec."IC Partner Code")
                {
                    ApplicationArea = KVSPSAIC;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                /*lma2 field(QtyICObligoBase; Rec."Qty. IC Obligo (Base)")
                {
                    ApplicationArea = KVSPSAIC;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                /*lma2 field(TotalPriceICObligoLCY; Rec."Total Price IC Obligo (LCY)")
                {
                    ApplicationArea = KVSPSAIC;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field(ShortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(ShortcutDimension2Code; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = KVSPSABasic;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = KVSPSABasic;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = KVSPSABasic;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = KVSPSABasic;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = KVSPSABasic;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = KVSPSABasic;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                /*field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(BinCode; Rec."Bin Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;

                    trigger OnValidate()
                    var
                        C_PSA023: Label 'The Sales Budget is blocked! If necessary please unblock in the current PSP-Line or generally in the PSP-Header.';
                    begin
                        //Start TDAG48302/dc
                        if rec.SalesBudgetBlockedEOS and not SkipSalesBudgetBlocked then
                            ERROR(C_PSA023);
                        //Stop TDAG48302/dc
                        PSPCalc.CalcOutStandingPrice(Rec);
                    end;
                }
                field(UnitofMeasureCode; Rec."Unit of Measure Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                }
                /*field(DirectUnitCostLCY; Rec."Direct Unit Cost (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field(UnitCostLCY; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                }
                field(TotalCostLCY; Rec."Total Cost (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(InvoicingQuantity; Rec."Invoicing Quantity")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;

                    trigger OnValidate()
                    begin
                        PSPCalc.CalcOutStandingPrice(Rec);
                    end;
                }
                field(InvoicingUnitofMeasureCode; Rec.KVSPSAInvoicUnitOfMeasureCode)
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                /*field(ManualInvoicingQuantity; Rec."Manual Invoicing Quantity")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(SuspendfromInvoice; Rec."Suspend from Invoice")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(CostFactor; Rec."Cost Factor")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(InvoiceCurrencyDate; Rec."Invoice Currency Date")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(InvoiceCurrencyFactor; Rec."Invoice Currency Factor")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnAssistEdit()
                    begin
                        Rec.InvCurrencyAssist();
                        CurrPage.Update();
                    end;
                }*/
                field(UnitPriceICY; Rec."Unit Price (ICY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(TotalPriceICY; Rec."Total Price (ICY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(LineDiscount; Rec."Line Discount %")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                /*field(LineDiscountAmountICY; Rec."Line Discount Amount (ICY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(ManualUnitPrice; Rec."Manual Unit Price")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(UnitPriceLCY; Rec."Unit Price (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        PSPCalc.CalcOutStandingPrice(Rec);
                    end;
                }
                field(TotalPriceLCY; Rec."Total Price (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(LineDiscountAmountLCY; Rec."Line Discount Amount (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(Prof; Rec.Profit)
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }*/
                field("Profit_%"; Rec."Profit %")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                }
                field("Actual Profit"; Rec."Actual Profit")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field("Actual Profit Percent"; Rec."Actual Profit Percent")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                /*lma2 field(SalesQuoteAmount; Rec."Sales Quote Amount")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSalesAmountField(0); //0 = Quote
                    end;
                }*/
                /*lma2 field(SalesOrderAmount; Rec."Sales Order Amount")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSalesAmountField(1);//1 = Order
                    end;
                }*/
                /*lma2 field(SalesOrderOutstandingAmount; Rec."Sales Order Outstd. Amount")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSalesAmountField(1);//1 = Order
                    end;
                }*/
                /*lma2 field(SalesInvoiceAmount; Rec."Sales Invoice Amount")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSalesAmountField(2);// 2=Invoice
                    end;
                }*/
                /*lma2 field(QtyJobBudget; Rec."Qty. (Job Budget)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownBudgetField();
                    end;
                }*/
                /*lma2 field(TotalCostBudgetLCY; Rec."Total Cost (Budget LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownBudgetField();
                    end;
                }*/
                /*lma2 field(TotalPriceBudgetLCY; Rec."Total Price (Budget LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownBudgetField();
                    end;
                }*/
                /*lma2 field(CommitmentLCY; Rec."Commitment (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownCommitment();
                    end;
                }*/
                /*lma2 field(TimeCommitment; Rec."Time Commitment")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownTimeCommitment(0); // Qty.
                    end;
                }*/
                /*lma2 field(TimeCostCommitmentLCY; Rec."Time Cost Commitment (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownTimeCommitment(1); // Amount
                    end;
                }*/

                /*field(UsageTotalCostLCY; Rec."Usage Total Cost (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    CaptionClass = Rec.FieldCaption("Usage Total Cost (LCY)");
                    Editable = false;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownUsageField();
                    end;
                }*/
                /*field(UsageInvoicingQty; Rec."Usage Invoicing Qty.")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownUsageField();
                    end;
                }*/
                /*field(UsageTotalPriceLCY; Rec."Usage Total Price (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownUsageField();
                    end;
                }*/
                /*field(SaleQuantityBase; Rec."Sale Quantity (Base)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSalesField();
                    end;
                }*/
                /*field(SaleTotalCostLCY; Rec."Sale - Total Cost (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSalesField();
                    end;
                }*/
                /*field(SaleTotalPriceLCY; Rec."Sale - Total Price (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownSalesField();
                    end;
                }*/
                /*field(SaleDiscountAmountLCY; Rec."Sale - Discount Amount (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }*/
                /*field(SaleLineAmountLCY; Rec."Sale - Line Amount (LCY)")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }*/
                /*field(QtypostInvLedger; Rec."Qty. post. Inv. Ledger")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }*/
                /*field(InvQtypostInvLedger; Rec."Inv. Qty. post. Inv. Ledger")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }*/
                /*field(CalcOutstSalesPriceType; Rec."Calc. Outst. Sales Price Type")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        PSPCalc.CalcOutStandingPrice(Rec);
                    end;
                }
                field(OutstandingSalesTotalPrice; Rec."Outstanding Sales Total Price")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(JobInvoiceCurrencyCode; Rec."Job Invoice Currency Code")
                {
                    ApplicationArea = KVSPSABasic;
                    StyleExpr = MySumStyle;
                    Visible = false;
                }
                field(SubprojectManager; Rec."Subproject Manager")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(SubprojectManagerName; Rec."Subproject Manager Name")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(LineNo; Rec."Line No.")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field(CalculationBaseEVA; Rec."Calculation Base EVA")
                {
                    ApplicationArea = KVSPSAEVA;
                    Visible = false;
                }
                field(AutomaticProgessCalculation; Rec."Automatic Progess Calculation")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }*/
                field(UsageQuantityBase; Rec."Usage Quantity (Base)")
                {
                    ApplicationArea = KVSPSABasic;
                    Editable = false;
                    StyleExpr = MySumStyle;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownUsageField();
                    end;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = KVSPSABasic;
                    Visible = false;
                }
                /*field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    Visible = false;
                    Enabled = false;
                    ApplicationArea = KVSPSABasic;
                }
                field("Bill-to Customer Name"; Rec."Bill-to Customer Name")
                {
                    Visible = false;
                    Enabled = false;
                    ApplicationArea = KVSPSABasic;
                }*/
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewLineBefore)
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'New Line';
                Image = ReverseLines;
                ShortcutKey = 'Ctrl+F9';
                ToolTip = 'New WBS-Line';

                trigger OnAction()
                begin
                    NewLine(Rec, true);
                end;
            }
            action(NewLineAfter)
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'Insert new Line after Current Line';
                Image = TransferToLines;
                ShortcutKey = 'Ctrl+F8';
                ToolTip = 'New WBS-Line after current Line';

                trigger OnAction()
                begin
                    NewLine(Rec, false);
                end;
            }
#pragma warning disable AA0194
            action(DeleteLines)
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'Delete lines';
                Image = Delete;
                //ShortCutKey = 'Ctrl+D';
                Visible = false;
                Enabled = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'The action will be removed. Please use standard Delete Line function.';
                ObsoleteTag = '18.3';
            }
#pragma warning restore AA0194
            action(ClearIndenationFromLinesAction)
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'Clear Indentation';
                ToolTip = 'Use this action to clear the Indent from records if deleting of WBS line is blocked by existing indentation.';
                Image = CancelIndent;
                Visible = ShowClearIndentation;

                trigger OnAction()
                begin
                    Rec.ClearIndentationForCurrentHeader();
                    CurrPage.Update();
                end;
            }
            action(KVSPSACreateNewUserTask)
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'Create new User Task (missing implementation)';
                Image = Task;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Message('Da implementare');
                    //Rec.KVSPSACreateNewUserTask();
                end;
            }
            action(BudgetLines)
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'Budget Lines';
                Image = LedgerBudget;
                ShortcutKey = 'Ctrl+B';

                trigger OnAction()
                begin
                    Rec.ShowBudget();
                end;
            }
            group(Manage)
            {
                Caption = 'Manage';
                Visible = false;
                Enabled = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'The action group will be removed.';
                ObsoleteTag = '18.3';
            }
            group(Functions)
            {
                Caption = 'Functions';
                Image = "Action";
                action(MoveLine)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Move Line';
                    Image = Replan;

                    trigger OnAction()
                    begin
                        Rec.MovePSPLine();
                        CurrPage.Update();
                    end;
                }
                action(ChangeDates)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Change Dates';
                    Image = DateRange;

                    trigger OnAction()
                    begin
                        Rec.ChangeDate();
                    end;
                }
                action(ExplodeBOM)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Explode BOM (missing implementation)';
                    Image = ExplodeBOM;

                    trigger OnAction()
                    var
                        KVSPSAJobPSPLine: Record KVSPSAJobPSPLine;
                    begin
                        Message('Da implementare');
                        /*CurrPage.SetSelectionFilter(KVSPSAJobPSPLine);
                        KVSPSAJobPSPLine.ExplodeBomAndRecalculateSums();
                        CurrPage.Update();*/
                    end;
                }
                action(ExplodeBlock)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Explode Block (missing implementation)';
                    Image = ExplodeRouting;

                    trigger OnAction()
                    begin
                        Message('Da implementare');
                        //Rec.ExplodeBlock();
                    end;
                }
            }
            group(AdvancePaymentPlans)
            {
                Caption = '(Advance) Payment Plans';
                Image = PrepaymentSimulation;
                action(PSA_MilestoneLinks)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Milestonedefinition';
                    Image = BreakpointsList;

                    trigger OnAction()
                    begin
                        Rec.ShowMilestoneLinksToLine();
                        CurrPage.Update(false);
                    end;
                }
                /*lma
                action(PSA_CompareSalesPlanAmt)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Compare Sales Amount/Payment Plan';
                    Image = CompareCost;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Rec.CheckPaymentPlanTotal(2); // Verbose
                    end;
                }
                action(PSA_CreatePayPlan)
                {
                    AccessByPermission = tabledata KVSPSAJobPaymentPlanningEntry = IM;
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Update Payment Plan';
                    Image = CalculatePlanChange;

                    trigger OnAction()
                    begin
                        Rec.CalcMileStonePaymentPlans(false);
                    end;
                }
                action(PSA_CreatePayPlanMilestoneLines)
                {
                    AccessByPermission = tabledata KVSPSAJobPaymentPlanningEntry = IM;
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Create Paymentplan f. Milestone Lines ';
                    Image = CalculatePlanChange;

                    trigger OnAction()
                    begin
                        Rec.UpdateJobPayPlanToMilestoneLines();
                    end;
                }
                action(PSA_ShowPmtPlan)
                {
                    AccessByPermission = tabledata KVSPSAJobPaymentPlanningEntry = R;
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Payment Plan';
                    Image = PaymentDays;

                    trigger OnAction()
                    var

                    begin
                        Rec.ShowJobPaymentPlan(Rec);
                    end;
                }*/
            }
            group(Line)
            {
                Caption = 'Line';
                Image = Line;
                action(SetDate)
                {
                    ApplicationArea = all;
                    Caption = 'Set Dates';
                    Image = DateRange;

                    ToolTip = 'Set dates on selected lines';
                    trigger OnAction()
                    var
                        CurrRec: Record KVSPSAJobPSPLine;
                        EOIModifyWBSDate: Report "EOI Modify WBS Date";
                    begin
                        CurrPage.SetSelectionFilter(CurrRec);
                        EOIModifyWBSDate.SetTableView(CurrRec);
                        EOIModifyWBSDate.RunModal();
                    end;
                }
                action(FormulaCalculation)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Formula Calculation';
                    Image = MoveNegativeLines;
                    Enabled = Rec.Type = Rec.Type::"Work Package";
                    trigger OnAction()
                    var
                        PSACalculationBaseMappingLoc: Page KVSPSACalculationBaseMapping;
                    begin
                        PSACalculationBaseMappingLoc.SetTargetPSPLine(Rec);
                        PSACalculationBaseMappingLoc.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                action(Skills)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Skills';
                    Image = Skills;
                    RunObject = page "KVSPSAPSP Line Skills";
                    RunPageLink = "Job No." = field("Job No."),
                                  "Job Budget Name" = field("Job Budget Name"),
                                  "Version No." = field("Version No."),
                                  "PSP Line No." = field("Line No."),
                                  "Budget Line No." = const(0);
                    ToolTip = 'Opens the list of skills needed to process the to-dos of this WBS line.';
                }
                action(Dimensions)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortcutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action(WorkPackageInfo)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Work Package Info';
                    Image = Info;

                    trigger OnAction()
                    begin
                        Rec.ShowWPStatistic();
                    end;
                }
                action(InteractionLogEntries)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Interaction Log Entries';
                    Image = InteractionLog;

                    trigger OnAction()
                    begin
                        Rec.ShowInteractionLogEntries();
                    end;
                }
                action(SalesDocJobBudgetChangingLog)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Sales Doc - Job Budget-Changing Log';
                    Image = ChangeLog;
                    RunObject = page KVSPSASalesJobBudgetChangLog;
                    RunPageLink = "Job No." = field("Job No."),
                                  "Work Package Code" = field("No."),
                                  "Phase Code" = field("Phase Code"),
                                  "Task Code" = field("Task Code"),
                                  "Step Code" = field("Step Code");
                    RunPageMode = View;
                    RunPageView = sorting("Job No.", "Work Package Code", "Phase Code", "Task Code", "Step Code", "Budget Line No.");
                }
                action(PreCursorsAction)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'PreCursors';
                    Image = RoutingVersions;

                    trigger OnAction()
                    begin
                        Rec.ShowTaskLinksToLine();
                        CurrPage.Update(false);
                    end;
                }
                action(Successor)
                {
                    ApplicationArea = KVSPSABasic;
                    Caption = 'Successor';
                    Image = RoutingVersions;

                    trigger OnAction()
                    begin
                        Rec.ShowTaskLinksFromLine();
                        CurrPage.Update(false);
                    end;
                }
                group(Texts)
                {
                    Caption = 'Texts';
                    Image = Text;
                    action(BeginningText)
                    {
                        ApplicationArea = KVSPSABasic;
                        Caption = 'Beginning Text';
                        Image = BeginningText;

                        trigger OnAction()
                        begin
                            Rec.ShowTextLines(Enum::KVSKBATextPosition::"Previous Text");
                        end;
                    }
                    action(EndingText)
                    {
                        ApplicationArea = KVSPSABasic;
                        Caption = 'Ending Text';
                        Image = EndingText;

                        trigger OnAction()
                        begin
                            Rec.ShowTextLines(Enum::KVSKBATextPosition::"After Text");
                        end;
                    }
                    /*action(Comments)
                    {
                        ApplicationArea = KVSPSABasic;
                        Caption = 'Comments';
                        Image = ViewComments;

                        trigger OnAction()
                        begin
                            Rec.ShowCommentLines();
                        end;
                    }*/
                }
                group(History)
                {
                    Caption = 'History';
                    Image = History;
                    action(EarnedValueAnalysis)
                    {
                        ApplicationArea = KVSPSAEVA;
                        Caption = 'Earned Value Analysis';
                        Image = AnalysisView;

                        trigger OnAction()
                        begin
                            Page.RunModal(Page::"KVSPSAEVA PSP Line", Rec);
                        end;
                    }
                    action(EarnedValueHistory)
                    {
                        ApplicationArea = KVSPSAEVA;
                        Caption = 'Earned Value History';
                        Image = History;

                        trigger OnAction()
                        var
                            EVAPSPLineLoc: Record "KVSPSAEVA PSP Line";
                            EVAPSPLineListLoc: Page "KVSPSAEVA PSP Line List";
                        begin
                            EVAPSPLineLoc.SetRange("Job No.", Rec."Job No.");
                            EVAPSPLineLoc.SetRange("PSP-Line No", Rec."Line No.");
                            EVAPSPLineLoc.SetRange("Version No.", Rec."Version No.");
                            EVAPSPLineLoc.SetRange("Task Code", Rec."Task Code");
                            EVAPSPLineLoc.SetRange("Phase Code", Rec."Phase Code");
                            EVAPSPLineLoc.SetRange("Step Code", Rec."Step Code");
                            EVAPSPLineListLoc.SetTableView(EVAPSPLineLoc);
                            EVAPSPLineListLoc.RunModal();
                        end;
                    }
                }
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        job: Record "job";
        Text50000: Label 'IC Job. Sync. all child jobs.';
    begin
        //Start TDAG05777/dc
        if Job.GET(rec."Job No.") then begin
            Job.CALCFIELDS("KVSPSANo. of IC Partners");
            if Job."KVSPSANo. of IC Partners" <> 0 then
                MESSAGE(Text50000);
        end;
        //Stop TDAG05777/dc
    end;

    trigger OnAfterGetCurrRecord()
    begin
        TypeChosen := Rec.Type = Rec.Type::"Work Package";
        ShowClearIndentation := Rec.Indentation > 0;
    end;

    trigger OnAfterGetRecord()
    var
        PSPHeaderLoc: Record KVSPSAJobPSPHeader;
        IsSumLineLoc: Boolean;
    begin
        GetJobOnce();
        if not Job.KVSPSAManualUpdatePSPOnOpen then
            if UpdateSumLinesByOnOpen then begin
                if PSPHeaderLoc.Get(Rec."Job No.", Rec."Job Budget Name", Rec."Version No.") then begin
                    PSPHeaderLoc.SetFilter("Date Filter", Rec.GetFilter("Date Filter"));
                    Clear(PSPCalc);
                    PSPCalc.UpdatePSP(PSPHeaderLoc);
                    Rec.Get(Rec."Job No.", Rec."Job Budget Name", Rec."Version No.", Rec."Line No.");
                end;
                UpdateSumLinesByOnOpen := false;
            end;

        MySumStyle := Rec.GetLineTypeStyle(true);
        MyLineStyle := Rec.GetLineTypeStyle(false);
        TypeChosen := Rec.Type = Rec.Type::"Work Package";

        rec.CalcFields("Usage Total Cost (LCY)");
        if Rec.Type = Rec.Type::"Work Package" then
            if Rec."Total Cost (LCY)" <> 0 then
                Rec."Posting Progress %" := Round(Rec."Usage Total Cost (LCY)" * 100 / Rec."Total Cost (LCY)", 0.01);

        Rec.ShowShortcutDimCode(ShortcutDimCode);

        IsEmptyTypeLine := Rec.Type = Rec.Type::" ";
        IsSumLineLoc := ((Rec.Type = Rec.Type::"End-Total") or (Rec.Type = Rec.Type::"Heading-Sum")) and (Rec.Totaling <> '');

        DescriptionIndent := 0;
        if Rec.Indentation > 0 then begin
            DescriptionIndent := Rec.Indentation - 1;
            ShowClearIndentation := true;
        end;
        if IsSumLineLoc then
            Rec.FillSumLinesForPage();

        EOIStartingDate := rec."Starting Date";
        EOIEndingDate := rec."ending Date";
        EOIWorkStatus := rec."Work Status";
        EOIJobProgress := rec."Job Progress %";
        EOIBudgetIncrementFactor := rec."EOI Budget Increment Factor";
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    /*trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.InitNewRecord();
        Clear(ShortcutDimCode);
    end;*/

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("Usage Total Cost (LCY)");
        UpdateSumLinesByOnOpen := true;

        EOIStartingDate := rec."Starting Date";
        EOIEndingDate := rec."ending Date";
        EOIWorkStatus := rec."Work Status";
        EOIJobProgress := rec."Job Progress %";
        EOIBudgetIncrementFactor := rec."EOI Budget Increment Factor";
    end;

    trigger OnModifyRecord(): Boolean
    var
        JobLocal: Record job;
        UserSetup: Record "User Setup";
        C_PSA023: Label 'The Sales Budget is blocked! If necessary please unblock in the current PSP-Line or generally in the PSP-Header.';
        WbsModError: Label 'You are not authorized to modify the WBS. Only Job PM, user administrators and user manager are authorized.';

    begin

        if not JobLocal.get(rec."Job No.") then
            exit;
        if not UserSetup.GET(USERID) then
            exit;
        if UserSetup."EOI Administration User" then
            exit;
        if UserSetup."EOI Manager User" then
            exit;
        if JobLocal."Person Responsible" = UserSetup."KVSPSAResource No." then
            exit;
        if JobLocal.KVSPSAPersonResponsibleSubstit = UserSetup."KVSPSAResource No." then
            exit;

        //Start TDAG48302/dc
        if rec.SalesBudgetBlockedEOS and not SkipSalesBudgetBlocked then
            ERROR(C_PSA023);
        SkipSalesBudgetBlocked := false;
        //Stop TDAG48302/dc;

        error(WbsModError);

    end;


    protected var
        MyLineStyle: Text;
        MySumStyle: Text;

    var
        Job: Record Job;
        PSPCalc: Codeunit "KVSPSAGeneral Functions PSA";
        IsEmptyTypeLine: Boolean;
        JobRecordRetrieved: Boolean;
        ShowClearIndentation: Boolean;

        SkipSalesBudgetBlocked: Boolean;
        TypeChosen: Boolean;
        UpdateSumLinesByOnOpen: Boolean;
        ShortcutDimCode: array[8] of Code[20];
        EOIEndingDate: Date;
        EOIStartingDate: Date;
        EOIBudgetIncrementFactor: Decimal;
        EOIJobProgress: Decimal;
        gQtyBudgetDays: Decimal;
        gQtyBudgetHours: Decimal;
        gQtySalesBudgetDays: Decimal;
        gQtySalesBudgettHours: Decimal;
        EOIWorkStatus: Enum KVSPSAWorkStatusType;
        DescriptionIndent: Integer;


    local procedure GetJobOnce()
    begin
        if not JobRecordRetrieved then begin
            Job.Get(Rec."Job No.");
            JobRecordRetrieved := true;
        end;
    end;

    internal procedure GetDateFilter(): Text
    begin
        exit(Rec.GetFilter("Date Filter"));
    end;

    procedure NewLine(var psaJobPSPLineVar: Record KVSPSAJobPSPLine; insertLineBeforePar: Boolean)
    var
        JobLoc: Record Job;
        PSAJobPSPLineLoc: Record KVSPSAJobPSPLine;
        PSAJobPSPLineNext: Record KVSPSAJobPSPLine;
        PSAJobPSPLinePrev: Record KVSPSAJobPSPLine;
        NewLineNoLoc: Integer;
        NotEnoughSpaceErr: Label 'No free Line No. found. Line can not be inserted.';
    begin
        PSAJobPSPLineLoc := psaJobPSPLineVar;
        if insertLineBeforePar then begin
            //Insert Before
            //-> Find Line Before
            PSAJobPSPLinePrev := PSAJobPSPLineLoc;
            PSAJobPSPLinePrev.SetRecFilter();
            PSAJobPSPLinePrev.SetRange("Line No.");

            if PSAJobPSPLinePrev.Next(-1) = 0 then
                PSAJobPSPLinePrev."Line No." := 0;

            //->Use Current Line
            PSAJobPSPLineNext := PSAJobPSPLineLoc;
        end else begin
            //Insert After
            //-> Use Current Line
            PSAJobPSPLinePrev := PSAJobPSPLineLoc;
            //-> Find Next() Line
            PSAJobPSPLineNext := PSAJobPSPLineLoc;
            PSAJobPSPLineNext.SetRecFilter();
            PSAJobPSPLineNext.SetRange("Line No.");
            if PSAJobPSPLineNext.Next() = 0 then
                PSAJobPSPLineNext."Line No." := PSAJobPSPLineLoc."Line No." + 20000;
        end;

        if PSAJobPSPLineNext."Line No." = 0 then
            NewLineNoLoc := 10000
        else
            NewLineNoLoc := PSAJobPSPLinePrev."Line No." + Round((PSAJobPSPLineNext."Line No." - PSAJobPSPLinePrev."Line No.") / 2, 1);
        if NewLineNoLoc = PSAJobPSPLineNext."Line No." then
            Error(NotEnoughSpaceErr);

        JobLoc.Get(PSAJobPSPLineLoc."Job No.");
        psaJobPSPLineVar.Init();
        psaJobPSPLineVar."Job No." := PSAJobPSPLineLoc."Job No.";
        psaJobPSPLineVar."Job Budget Name" := PSAJobPSPLineLoc."Job Budget Name";
        psaJobPSPLineVar."Version No." := PSAJobPSPLineLoc."Version No.";
        psaJobPSPLineVar."Line No." := NewLineNoLoc;
        psaJobPSPLineVar.Indentation := PSAJobPSPLineLoc.Indentation;
        psaJobPSPLineVar.Type := PSAJobPSPLineLoc.Type;
        psaJobPSPLineVar."Starting Date" := JobLoc."Starting Date";
        psaJobPSPLineVar.Validate("Ending Date", JobLoc."Ending Date");
        psaJobPSPLineVar.Validate(PSPStatus, PSPStatus::Quote);

        if PSAJobPSPLineLoc.Type > PSAJobPSPLineLoc.Type::"Work Package" then
            if PSAJobPSPLineLoc.Indentation > 1 then
                psaJobPSPLineVar.Indentation := PSAJobPSPLineLoc.Indentation - 1;
        psaJobPSPLineVar.Insert(true);
    end;

    /*procedure KVSPSACreateNewUserTask()
    var
        UserTask: Record "User Task";
    begin
        UserTask.Init();
        UserTask.KVSPSASetLinkedRecord(Rec);
        UserTask.Insert(true);
        UserTask.SetRecFilter();
        Page.Run(Page::"User Task Card", UserTask);
    end;*/

    /*procedure ExplodeBomAndRecalculateSums()
    begin
        Rec.SetRange(Type, Rec.Type::"Work Package");
        if Rec.FindSet(false) then begin
            if Rec.Count() > 1 then
                Rec.SetHideDialogs(true);
            repeat
                Rec.ExplodeBOM();
                if Rec."Budget calculation" then begin
                    Rec.CalcFields("Total Cost (Budget LCY)", "Total Price (Budget LCY)", "Budget Line Disc. Amount (LCY)",
                                                                    "Total Price Budget (ICY)", "Budget Line Disc. Amount (ICY)");
                    Rec.BudgetIntoPSPLine(
                        Rec."Total Cost (Budget LCY)", Rec."Total Price (Budget LCY)",
                        Rec."Budget Line Disc. Amount (LCY)", Rec."Total Price Budget (ICY)",
                        Rec."Budget Line Disc. Amount (ICY)");
                end;
            until Rec.Next() = 0;
        end;
    end;*/

    /*procedure CheckPaymentPlanTotal(MessageTypePar: Option OnlyDiff,Confirm,Verbose)
    var
        AdvancePaymentPlanMgt: Codeunit KVSPSAAdvancePaymentPlanMgt;
    begin
        TestField("Job No.");
        AdvancePaymentPlanMgt.CheckJobSalesTotalInPaymentPlan("Job No.", MessageTypePar);
    end;*/

}