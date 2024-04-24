page 50526 "EOI JobPSPHeader"
{
    Caption = 'Job WBS-Header';
    DataCaptionFields = "Job No.";
    PageType = Document;
    Permissions = tabledata "KVSPSA Job Budget Entry" = rimd;
    SourceTable = KVSPSAJobPSPHeader;
    UsageCategory = None;
    ContextSensitiveHelpPage = 'ProjectPlanning/#project-psp-head';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(JobBudgetName; Rec."Job Budget Name")
                {
                    ApplicationArea = KVSPSABasic;
                }
                field(VersionNo; Rec."Version No.")
                {
                    ApplicationArea = KVSPSABasic;
                    Importance = Promoted;
                }
                field(DescriptionJob; Rec."Description (Job)")
                {
                    ApplicationArea = KVSPSABasic;
                    Importance = Promoted;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = KVSPSABasic;
                    Importance = Promoted;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = KVSPSABasic;
                }
                field(SalesBudgetBlocked; Rec."Sales Budget Blocked")
                {
                    ApplicationArea = KVSPSABasic;
                    Importance = Additional;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = KVSPSABasic;
                    Importance = Promoted;
                }
                field(Budgetstatus; Rec.Budgetstatus)
                {
                    ApplicationArea = KVSPSABasic;
                }
                field(Releasedby; Rec."Released By")
                {
                    ApplicationArea = KVSPSABasic;
                    Editable = false;
                    Importance = Additional;
                }
                field(Releasedat; Rec."Released At")
                {
                    ApplicationArea = KVSPSABasic;
                    Editable = false;
                    Importance = Additional;
                }
                field(LastWBSHistoryDate; LastWBSHistoryDate)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Job Progress Perc. Hist. Calc. Last Date';

                }
            }
            part(PSPLine; "EOI JobPSPLineListPart")
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'WBS-Lines';
                SubPageLink = "Job No." = field("Job No."),
                              "Version No." = field("Version No."),
                              "Job Budget Name" = field("Job Budget Name");
            }
            group(Invoicing)
            {
                Caption = 'Invoicing';
                field(JobInvoiceCurrencyCode; Rec."Job Invoice Currency Code")
                {
                    ApplicationArea = KVSPSABasic;
                    Importance = Promoted;
                    Lookup = false;
                }
                field(InvoiceCurrencyFactor; Rec."Invoice Currency Factor")
                {
                    ApplicationArea = KVSPSABasic;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRateLoc: Page "Change Exchange Rate";
                    begin
                        if Rec."Job Invoice Currency Code" = '' then
                            exit;
                        Clear(ChangeExchangeRateLoc);
                        if Rec."Invoice Currency Date" = 0D then
                            Rec."Invoice Currency Date" := WorkDate();
                        ChangeExchangeRateLoc.SetParameter(Rec."Job Invoice Currency Code", Rec."Invoice Currency Factor", Rec."Invoice Currency Date");
                        if ChangeExchangeRateLoc.RunModal() = Action::OK then begin
                            Rec.Validate("Invoice Currency Factor", ChangeExchangeRateLoc.GetParameter());
                            CurrPage.Update();
                        end;
                        Clear(ChangeExchangeRateLoc);
                    end;
                }
                field(InvoiceCurrencyDate; Rec."Invoice Currency Date")
                {
                    ApplicationArea = KVSPSABasic;
                }
            }
        }
        /*area(FactBoxes)
        {
            part(PSATextLinesView; "KVSPSA Text Lines View")
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'WBS-Line Texts';
                Provider = PSPLine;
                SubPageLink = "Table Name" = const(KVSPSAJobPSPLine),
                              "Job No." = field("Job No."),
                              "Job Budget Name" = field("Job Budget Name"),
                              "Version No." = field("Version No."),
                              "Table Line" = field("Line No.");
                Visible = true;
            }
            part(KVSPSAJobPaymPlanEntryFactbox; KVSPSAJobPaymPlanEntryFactbox)
            {
                ApplicationArea = KVSPSABasic;
                Provider = PSPLine;
                SubPageLink = "Job No." = field("Job No."),
                              "Source Subtype" = const("PSP-Line"),
                              "Source Work Package Code" = field("No."),
                              "Source Phase Code" = field("Phase Code"),
                              "Source Task Code" = field("Task Code"),
                              "Source Step Code" = field("Step Code");
                Visible = true;
            }
            part(PSPCommentSheetView; "KVSPSAPSP Comment Sheet View")
            {
                ApplicationArea = KVSPSABasic;
                Provider = PSPLine;
                SubPageLink = "Table Name" = const("Job PSP Line"),
                              "No." = field("Job No."),
                              "Job Budget Name" = field("Job Budget Name"),
                              "Version No." = field("Version No."),
                              "Table Line" = field("Line No.");
                Visible = true;
            }
            part(PSPLineFactBox2; "KVSPSAPSP-Line FactBox 2")
            {
                ApplicationArea = KVSPSABasic;
                Provider = PSPLine;
                SubPageLink = "Job No." = field("Job No."),
                              "Version No." = field("Version No."),
                              "Job Budget Name" = field("Job Budget Name"),
                              "Line No." = field("Line No.");
            }
            part(KVSPSAPSPLineFactBox; "KVSPSAPSP-Line FactBox")
            {
                ApplicationArea = KVSPSABasic;
                Provider = PSPLine;
                SubPageLink = "Job No." = field("Job No."),
                              "Version No." = field("Version No."),
                              "Job Budget Name" = field("Job Budget Name"),
                              "Line No." = field("Line No.");
            }
            part(KVSPSAPSPLineFactBox3; "KVSPSAPSP-Line FactBox 3")
            {
                ApplicationArea = KVSPSABasic;
                Provider = PSPLine;
                SubPageLink = "Job No." = field("Job No."),
                              "Version No." = field("Version No."),
                              "Job Budget Name" = field("Job Budget Name"),
                              "Line No." = field("Line No.");
            }
            systempart(RecordLinks; Links)
            {
                ApplicationArea = KVSPSABasic;
            }
        }*/
    }

    /*actions
    {
        area(Navigation)
        {
            action(PSPwithbudgetview)
            {
                ApplicationArea = KVSPSABasic;
                Caption = 'WBS with budget view';
                Image = ProdBOMMatrixPerVersion;
                Promoted = true;
                PromotedCategory = Process;
                ShortcutKey = 'Shift+F9';

                trigger OnAction()
                begin
                    Rec.OpenPSPWithBudget();
                end;
            }
            separator(Separator5025901)
            {
                Caption = '', Locked = true;
            }*/
    /*action(Statistics)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Statistics';
        Image = Statistics;
        Promoted = true;
        PromotedCategory = Process;
        RunObject = page "KVSPSAPSP Statistics";
        RunPageLink = "Version No." = field("Version No."),
                      "Job No." = field("Job No."),
                      "Job Budget Name" = field("Job Budget Name");
        ShortcutKey = 'F7';
    }
    action(Comments)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Comments';
        Image = ViewComments;
        RunObject = page "KVSPSAPSP Comment Sheet";
        RunPageLink = "No." = field("Job No."),
                      "Version No." = field("Version No."),
                      "Job Budget Name" = field("Job Budget Name");
        RunPageView = order(ascending)
                      where("Table Name" = const("Job PSP-Header"));
    }
    action(Documents)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Documents';
        Image = Navigate;
        Promoted = true;
        PromotedCategory = Process;

        trigger OnAction()
        begin
            Rec.DocumentNavigate();
        end;
    }
    separator(Separator5025878)
    {
        Caption = '', Locked = true;
    }
    action(PSPScheduling)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'WBS Scheduling';
        Image = CalculateSimulation;
        Promoted = true;
        PromotedCategory = Process;

        trigger OnAction()
        begin
            Rec.StartPSPPlanning();
        end;
    }
    action(JobBudgetActualComparison)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Job Budget / Actual Comparison';
        Image = CalculatePlan;
        Promoted = true;
        PromotedCategory = Process;
        RunObject = page "KVSPSACompare PSP / actual";
        RunPageLink = "Job No." = field("Job No."),
                      "Job Budget Name" = field("Job Budget Name"),
                      "Version No." = field("Version No.");
    }
    action(BudgetLinesList)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Budget Lines List';
        Image = EditList;
        Promoted = true;
        PromotedCategory = Process;

        trigger OnAction()
        var
            BudgetLinesLoc: Record "KVSPSA Job Budget Line";
            BudLineMgtLoc: Page "KVSPSAPSP Budget Lines";
        begin
            BudgetLinesLoc.FilterGroup(2);
            BudgetLinesLoc.SetRange("Job No.", Rec."Job No.");
            BudgetLinesLoc.SetRange("Job Budget Name", Rec."Job Budget Name");
            BudgetLinesLoc.SetRange("Version No.", Rec."Version No.");
            BudgetLinesLoc.FilterGroup(0);
            BudLineMgtLoc.SetTableView(BudgetLinesLoc);
            BudLineMgtLoc.RunModal();
        end;
    }
    action(JobAccountEntries)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Job Account Entries';
        Image = Entries;
        RunObject = page "KVSPSA Job Account Entries";
        RunPageLink = "Job No." = field("Job No."),
                      "Job Budget Name" = field("Job Budget Name"),
                      "Version No." = field("Version No.");
        RunPageView = sorting("Job No.", "Job Budget Name", "Version No.");
    }
    action(BudgetResources)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Budget Resources';
        Image = ListPage;
        Promoted = true;
        PromotedCategory = Process;

        trigger OnAction()
        var
            BudgetOverviewLoc: Record "KVSPSABudget Overview";
            BudgetOverviewPageLoc: Page "KVSPSABudget Overview";
        begin
            Rec.TestField("Job No.");

            BudgetOverviewLoc.Reset();
            BudgetOverviewLoc.SetRange("Job No.", Rec."Job No.");
            BudgetOverviewLoc.SetRange("Job Budget Name", Rec."Job Budget Name");
            BudgetOverviewLoc.SetRange("Version No.", Rec."Version No.");
            BudgetOverviewPageLoc.SetTableView(BudgetOverviewLoc);
            BudgetOverviewPageLoc.RunModal();
        end;
    }
}
area(Processing)
{
    group(PSPFunctions)
    {
        Caption = 'WBS Functions';
        action(CopyPSP)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Copy WBS';
            Image = CopyDocument;
            Promoted = true;
            PromotedCategory = Process;

            trigger OnAction()
            var
                PSPHeaderLoc: Record KVSPSAJobPSPHeader;
            begin
                if not PSPHeaderLoc.Get(Rec."Job No.", Rec."Job Budget Name", Rec."Version No.") then
                    Error(NotInsertedErr, PSPHeaderLoc.TableCaption());

                Rec.CopyFromPSPIntoThis();
                CurrPage.Update();
            end;
        }
        action(InsertNewTemplate)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Insert New Template';
            Image = GetLines;

            trigger OnAction()
            begin
                Rec.TestField("Job No.");
                Rec.AddNewPSPPartsFromTemplate();
            end;
        }
        action(CarryOutPositionNumbering)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Carry Out Position Numbering';
            Image = Indent;
            Promoted = true;
            PromotedCategory = Process;

            trigger OnAction()
            begin
                Subtotals.EvaluatePSPLine2(Rec, true);
                Rec.CalculatePrecursor();
            end;
        }
        action(RenumberLines)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Renumber Lines';
            Image = NumberSetup;

            trigger OnAction()
            begin
                Rec.RenumberPSPLines();
                Subtotals.EvaluatePSPLine2(Rec, false);
            end;
        }
        action(TransferCostfrombudget)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Transfer Cost from budget';
            Image = TraceOppositeLine;

            trigger OnAction()
            begin
                Rec.UpdateBudgetLinesFromPSPLines();
                CurrPage.Update();
            end;
        }
    }
    group(Functions)
    {
        Caption = 'Functions';
        Image = "Action";
        action(UpdateSumsnotinvoicedAmounts)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Update Sums + not invoiced Amounts + Profit';
            Image = Refresh;
            Promoted = true;
            PromotedCategory = Process;
            PromotedIsBig = true;

            trigger OnAction()
            begin
                Rec.SetFilter("Date Filter", CurrPage.PSPLine.Page.GetDateFilter());
                Clear(Subtotals);
                Subtotals.UpdatePSP(Rec);
            end;
        }
        action(CalcJobAccountEntries)
        {
            ApplicationArea = KVSPSAJobAcc;
            Caption = 'Calc. Job Account Entries';
            Image = RefreshLines;

            trigger OnAction()
            begin
                Rec.UpdateJobAccountEntry();
            end;
        }
        action(ICDefinition)
        {
            ApplicationArea = KVSPSAIC;
            Caption = 'IC Definition';
            Image = Intercompany;

            trigger OnAction()
            begin
                Rec.SetICPartnerInPSPLines();
            end;
        }
    }
    group(AdvancePaymentPlans)
    {
        Caption = '(Advance) Payment Plans';
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
                Rec.CalcPSPLinePaymentPlans(false);
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
                KVSPSAJobPSPLine: Record KVSPSAJobPSPLine;
            begin
                Rec.ShowJobPaymentPlan(KVSPSAJobPSPLine);
            end;
        }
    }
    group(CreateDocuments)
    {
        Caption = 'Create Documents';
        action(CreateSalesDocument)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Create Sales Document';
            Image = NewOrder;
            Promoted = true;

            trigger OnAction()
            begin
                Rec.CreateSalesDoc();
            end;
        }
        action(CreatePurchaseDocument)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Create Purchase Document';
            Image = NewOrder;
            Promoted = true;

            trigger OnAction()
            begin
                Rec.CreatePurchaseDoc();
            end;
        }
        action(CreateJobShipment)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Create Job Shipment';
            Image = NewShipment;
            Promoted = true;

            trigger OnAction()
            begin
                Rec.CreateJobShipment();
            end;
        }
        action(CreateJobVendorShipment)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Create Job Vendor Shipment';
            Image = NewShipment;
            Promoted = true;

            trigger OnAction()
            begin
                Rec.CreateJobVendorShipment();
            end;
        }
    }
    group(Interfaces)
    {
        Caption = 'Interfaces';
        action(CalculatePrecursors)
        {
            ApplicationArea = KVSPSABasic;
            Caption = 'Calculate Precursors';
            Image = Relationship;

            trigger OnAction()
            begin
                Rec.CalculatePrecursor();
            end;
        }
    }
}
area(Reporting)
{
    action(Print)
    {
        ApplicationArea = KVSPSABasic;
        Caption = 'Print';
        Image = "Report";
        Promoted = true;
        PromotedCategory = "Report";

        trigger OnAction()
        begin
            Rec.PrintPSP();
        end;
    }
}
}*/
    actions
    {
        area(Processing)
        {
            action("Job Progress Perc. Hist. Calc.")
            {
                Caption = 'Job Progress Perc. Hist. Calc.';
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    JobProgressPercHistCalc: Report "EOI Job Prog. Perc. Hist. Calc";
                begin
                    //Start TDAG45766/dc
                    JobProgressPercHistCalc.SetJob(Rec."Job No.");
                    JobProgressPercHistCalc.RunModal();
                    //Stop TDAG45766/dc
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        JobProgressPercHistory.Reset();
        JobProgressPercHistory.SetCurrentKey(Date);
        JobProgressPercHistory.SetRange("Job No.", Rec."Job No.");
        if JobProgressPercHistory.FindLast() then
            LastWBSHistoryDate := JobProgressPercHistory.Date;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec."Version No." = '' then
            Rec.CreateNew();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        PSAJobBudgetName.SetRange("Standard Budget Name", true);
        if PSAJobBudgetName.FindFirst() then begin
            Rec."Job Budget Name" := PSAJobBudgetName.Name;
            Rec.CreateNew();
        end;
    end;

    var

        JobProgressPercHistory: Record "EOI Job Progress Perc. History";
        PSAJobBudgetName: Record "KVSPSA Job Budget Name";
        Subtotals: Codeunit "KVSPSAGeneral Functions PSA";
        LastWBSHistoryDate: Date;
        NotInsertedErr: Label '%1 has not be inserted. For this click on field description.';

    procedure GetActivePSPVersion()
    begin
        if Rec.GetFilter("Job No.") <> '' then begin
            if Rec.FindLast() then begin
                Rec.SetRange(Active, true);
                if Rec.FindFirst() then;
                Rec.SetRange(Active);
            end else begin
                Rec."Job Budget Name" := Rec.FindStandardBudget();
                Rec."Version No." := '001';
                Rec.Budgetstatus := Rec.Budgetstatus::"in check";
                Rec.Insert(true);
            end;
        end else
            if not Rec.FindLast() then
                Rec."Job Budget Name" := Rec.FindStandardBudget();
    end;
}