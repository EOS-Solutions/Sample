report 18008299 "EOS Salesp./Purch. Commissions"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Source/Report/EOS Salesp. Commissions.rdlc';
    ApplicationArea = All;
    Caption = 'Print Commissions Detail (CMS)';
    // dettaglio provvigioni
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
                Caption = 'Settlement Period';
            }
            column(CB_SettlementType; "EOS Settlement Type")
            {
                Caption = 'Settlement Type';
            }
            column(CB_SalespVendorNo; "EOS Vendor No.")
            {
                Caption = 'Vendor Code';
            }
            column(CB_SalespersonName; Name)
            {
                IncludeCaption = true;
            }
            dataitem("Comm. Ledger Entry"; "EOS Commission Ledger Entry")
            {
                DataItemLink = "Salesperson" = FIELD(Code);
                DataItemTableView = SORTING("Table ID", "Sales Document Type", "Document No.", "Document Line No.") where("Exclude" = const(false));
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
                column(CB_SalespersonCode; "Salesperson")
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
                column(CB_Value; "Commission %")
                {
                    IncludeCaption = true;
                    AutoFormatExpression = CurrencyCode;
                    AutoFormatType = 1;
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

                trigger OnPreDataItem()
                var
                    CommissionsSetup: Record "EOS Commissions Setup";
                begin
                    CommissionsSetup.Read(false);
                    "Comm. Ledger Entry".FilterGroup(90);
                    if CommissionsSetup."Correction Prepmnt Reason Code" <> '' then
                        "Comm. Ledger Entry".SetFilter("Reason Code", '<>%1', CommissionsSetup."Correction Prepmnt Reason Code");
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
            area(content)
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
        var
            DueVisible: Boolean;

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
        CB_BaseAmountLCYCaption = 'Base Amount (LCY)';
        CB_SettlementPeriod_Caption = 'Settlement Period';
        CB_SettlementType_Caption = 'Settlement Type';
        CB_SalespVendorNo_Caption = 'Vendor Code';
        CB_CommissionPerc_Caption = 'Comm. %';
        CB_EmptyReasonCode_Caption = 'Commission Documents';
        CommAmount_Caption = 'Fixed comm. amount (LCY)';
    }

    trigger OnPreReport()
    begin
        PeriodText := CopyStr("Comm. Ledger Entry".GetFilter("Posting Date"), 1, MaxStrLen(PeriodText));
        GLSetup.Get();
        CurrencyCode := GLSetup."LCY Code";
        //HideHeaderIDFilter := false;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PeriodText: Text[100];
        PrintDocDetail: Boolean;
        DueDateSplit: Boolean;

        CurrencyCode: Code[20];
        PeriodLbl: Label 'Period: %1';

    local procedure ExistITapp(): Boolean;
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        ITApp: Guid;
    begin
        Evaluate(ITApp, '00c0e4f3-5497-4a0c-9275-b8330ba8148b');
        NAVAppInstalledApp.SetRange("App ID", ITApp);
        Exit(not NAVAppInstalledApp.IsEmpty());
    end;

    trigger OnInitReport()
    var
        SubscriptionMgt: Codeunit "EOS Subscription";
        IsExecAllowed: Boolean;
    begin
        SubscriptionMgt.CheckSubscriptionCU();
        IsExecAllowed := SubscriptionMgt.GetUsingAllowed();
        if not IsExecAllowed then
            exit;
    end;
}

