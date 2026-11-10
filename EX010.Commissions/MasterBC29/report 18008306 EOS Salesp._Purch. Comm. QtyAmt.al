report 18008306 "EOS Salesp. Commissions QtyAmt"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Source/Report/EOS Salesp. Commissions QtyAmt.rdlc';
    ApplicationArea = All;
    Caption = 'Print Commissions Detail Qty/Amt (CMS)';
    // dettaglio provvigioni con colonna tipo calcolo (Importo/Quantità)
    UsageCategory = ReportsAndAnalysis;


    dataset
    {
        dataitem(SalespersonPurchaser; "Salesperson/Purchaser")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Code";
            column(COMPANYNAME; CompanyName())
            {
            }
            column(PeriodText_; StrSubstNo(PeriodLbl, PeriodText))
            {
            }
            column(ShowDetails; PrintDocDetail)
            {
            }
            column(SplitByDueDate; DueDateSplit)
            {
            }
            column(CB_SettlementPeriod; "EOS Settlement Period")
            {
            }
            column(CB_SettlementType; "EOS Settlement Type")
            {
            }
            column(CB_SalespVendorNo; "EOS Vendor No.")
            {
            }
            column(CB_SalespersonName; Name)
            {
                IncludeCaption = true;
            }
            dataitem("Comm. Ledger Entry"; "EOS Commission Ledger Entry")
            {
                DataItemLink = Salesperson = field(Code);
                DataItemTableView = sorting("Table ID", "Sales Document Type", "Document No.", "Document Line No.");
                RequestFilterFields = "Posting Date", "Reason Code";
                CalcFields = "Settled Amount (LCY)";

                column(CB_LineNo; "Document Line No.")
                {
                }
                column(CB_SourceTab; "Table ID")
                {

                }
                column(CB_ReasonCode; "Reason Code")
                {
                    IncludeCaption = true;
                }
                column(CB_DocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(CB_PostingDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(CB_OrderNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(CB_SellToNo; "Sell-to No.")
                {
                    IncludeCaption = true;
                }
                column(CB_SellToName; "Sell-to Name")
                {
                    IncludeCaption = true;
                }
                column(CB_BillToNo; "Bill-to No.")
                {
                    IncludeCaption = true;
                }
                column(CB_BillToName; "Bill-to Name")
                {
                    IncludeCaption = true;
                }
                column(CB_SalespersonRole; "Salesperson Role")
                {
                    IncludeCaption = true;
                }
                column(CB_SalespersonCode; Salesperson)
                {
                    IncludeCaption = true;
                }

                column(CB_Quantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(CB_UoMCode; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
                column(CB_BaseAmountLCY; "Commission Base Amount (LCY)")
                {
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
                }
                column(CB_AmountLCY; "Total Commission Amount")
                {
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
                    IncludeCaption = true;
                    // da escludere se non c'è il flag                    
                }
                column(CB_SettledAmountLCY; "Settled Amount (LCY)")
                {
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
                    IncludeCaption = true;
                }
                column(CB_Type; Type)
                {
                    IncludeCaption = true;
                }
                column(CB_No; "No.")
                {
                    IncludeCaption = true;
                }
                column(CB_EntryNo; "Entry No.")
                {
                    IncludeCaption = true;
                }
                column(CB_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(CB_Value; GetCommissionPercentage())
                {
                }
                column(CB_Amount; "Commission Amount")
                {
                    IncludeCaption = true;
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
                }
                column(CB_DueDate; "Due Date")
                {
                    IncludeCaption = true;
                    AutoFormatType = 1;
                }
                column(CB_DocLedgerEntryNo; "Document Ledger Entry No.")
                {

                }
                column(CB_CalcSetupType; "Calc. Setup Type")
                {
                    IncludeCaption = true;
                }
                column(CommissionAmountLCYxUoM_CommLedgerEntry; "Commission Amount (LCY) x UoM")
                {
                    IncludeCaption = true;
                }

                trigger OnPreDataItem()
                var
                    CommissionsSetup: Record "EOS Commissions Setup";
                begin
                    CommissionsSetup.Read(false);
                    "Comm. Ledger Entry".FilterGroup(90);
                    if CommissionsSetup."Correction Prepmnt Reason Code" <> '' then
                        "Comm. Ledger Entry".SetFilter("Reason Code", '<>%1', CommissionsSetup."Correction Prepmnt Reason Code");
                    if not IncludeExcludedEntry then
                        "Comm. Ledger Entry".SetRange(Exclude, false);
                    "Comm. Ledger Entry".FilterGroup(0);
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintDocumentDetail; PrintDocDetail)
                    {
                        ToolTip = 'if true will print the single lines';
                        ApplicationArea = All;
                        Caption = 'Print Document Detail';
                        trigger OnValidate()
                        begin
                            if not PrintDocDetail then
                                DueDateSplit := false;
                        end;
                    }
                    field(IncludeExcludedEntry; IncludeExcludedEntry)
                    {
                        ToolTip = 'if true all the lines will be printed, both included and excluded';
                        ApplicationArea = All;
                        Caption = 'Include Excluded Entries';
                    }

                    field("Split By Due Date"; DueDateSplit)
                    {
                        ToolTip = 'If true the line will be splitted also by due date';
                        ApplicationArea = All;
                        //Visible = DueVisible;
                        Caption = 'Split by Due Date';
                        trigger OnValidate()
                        begin
                            if DueDateSplit then
                                PrintDocDetail := true;
                        end;
                    }
                    //*aggiungere flag per spaccare scadenze (di default le unisce) visisbile solo se detail==true

                }
            }
        }

        trigger OnOpenPage()
        begin
            //DueVisible := ExistITapp();
            //if DueVisible = false then
            //    DueDateSplit := DueVisible;
        end;

    }

    labels
    {
        PageNoCaption = 'Page';
        CommissionOverviewCaption = 'Commission Overview';
        CB_BaseAmountLCYCaption = 'Commission Base Amount (Qty/LCY)';
        CB_SettlementPeriod_Caption = 'Settlement Period';
        CB_SettlementType_Caption = 'Settlement Type';
        CB_SalespVendorNo_Caption = 'Vendor Code';
        CB_CommissionPerc_Caption = 'Comm. %';
        CB_EmptyReasonCode_Caption = 'Commission Documents';
        CommAmount_Caption = 'Fixed comm. amount (LCY)';
        CB_TipoCalcolo_Caption = 'Calculation type';
    }

    trigger OnPreReport()
    begin
        PeriodText := CopyStr("Comm. Ledger Entry".GetFilter("Posting Date"), 1, MaxStrLen(PeriodText));
        GLSetup.Get();
        CurrencyCode := GLSetup."LCY Code";
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PeriodText: Text[100];
        PrintDocDetail: Boolean;
        DueDateSplit: Boolean;
        IncludeExcludedEntry: Boolean;
        CurrencyCode: Code[20];
        PeriodLbl: Label 'Period: %1';

    trigger OnInitReport()
    var
        SubscriptionMgt: Codeunit "EOS Subscription";
        IsExecAllowed: Boolean;
    begin
        SubscriptionMgt.AssertSubscriptionIsActive();
        IsExecAllowed := SubscriptionMgt.GetSubscriptionIsActive();
        if not IsExecAllowed then
            exit;
    end;

    local procedure GetCommissionPercentage(): Text
    begin
        case "Comm. Ledger Entry"."Calc. Setup Type" of
            "EOS010 Calc. Setup Type"::Quantity:
                exit('');
            "EOS010 Calc. Setup Type"::Amount:
                exit(Format("Comm. Ledger Entry"."Commission %"));
        end;
    end;
}
