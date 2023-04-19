report 18123354 "EOS Account Book Sheet - Print"
{

    DefaultLayout = RDLC;
    RDLCLayout = './Source/Report/report 18123354 EOS Account Book Sheet - Print.rdlc';
    Caption = 'Account Book Sheet - Print (CVS)';

    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = sorting("No.")
                                ORDER(Ascending)
                                where("Account Type" = filter(Posting));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter", "Business Unit Filter";
            column(CompAddr_4_; CompAddr[4])
            {
            }
            column(CompAddr_5_; CompAddr[5])
            {
            }
            column(CompAddr_3_; CompAddr[3])
            {
            }
            column(Text1033___GLDateFilter; DateFilterTxt + GLDateFilter)
            {
            }
            column(CompAddr_2_; CompAddr[2])
            {
            }
            column(CompAddr_1_; CompAddr[1])
            {
            }
            column(FORMAT_TODAY_0_4_; Format(TODAY(), 0, 4))
            {
            }
            column(GLDateFilter; GLDateFilter)
            {
            }
            column(GLFilterNo; GLFilterNo)
            {
            }
            column(ProgressiveBalance; ProgressiveBalancePrmtr)
            {
            }
            column(UseAmtsInAddCurr; UseAmtsInAddCurr)
            {
            }
            column(G_L_Account__TABLECAPTION___________G_L_Account___No____________G_L_Account__Name; "G/L Account".TableCaption() + ': ' + "G/L Account"."No." + ' ' + "G/L Account".Name)
            {
            }
            column(G_L_Account_No_; "No.")
            {
            }
            column(G_L_Account_Name_; Name)
            {
            }
            column(G_L_Account_Date_Filter; "Date Filter")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Account_Sheet___General_LedgerCaption; Account_Sheet___General_LedgerCaptionLbl)
            {
            }
            column(Account_No_Caption; Account_No_CaptionLbl)
            {
            }
            column(Account_Name_Caption; Account_Name_CaptionLbl)
            {
            }
            column(Period_Caption; Period_CaptionLbl)
            {
            }
            column(IcreasesAmnt_Control1130071Caption; IcreasesAmnt_Control1130071CaptionLbl)
            {
            }
            column(DecreasesAmnt_Control1130070Caption; DecreasesAmnt_Control1130070CaptionLbl)
            {
            }
            column(GL_Book_Entry_DescriptionCaption; GLBookEntry.FIELDCAPTION(Description))
            {
            }
            column(GL_Book_Entry__External_Document_No__Caption; GLBookEntry.FIELDCAPTION("External Document No."))
            {
            }
            column(GL_Book_Entry__Document_Date_Caption; GL_Book_Entry__Document_Date_CaptionLbl)
            {
            }
            column(GL_Book_Entry__Document_No__Caption; GLBookEntry.FIELDCAPTION("Document No."))
            {
            }
            column(GL_Book_Entry__Posting_Date_Caption; GL_Book_Entry__Posting_Date_CaptionLbl)
            {
            }
            column(GL_Book_Entry__Transaction_No__Caption; GLBookEntry.FIELDCAPTION("Transaction No."))
            {
            }
            column(GL_Book_Entry__Entry_No__Caption; GLBookEntry.FIELDCAPTION("Entry No."))
            {
            }
            column(Amounts_in_Additional_CurrencyCaption; Amounts_in_Additional_CurrencyCaptionLbl)
            {
            }
            column(IcreasesAmnt_Control1130071Caption_Control1130026; IcreasesAmnt_Control1130071Caption_Control1130026Lbl)
            {
            }
            column(DecreasesAmnt_Control1130070Caption_Control1130027; DecreasesAmnt_Control1130070Caption_Control1130027Lbl)
            {
            }
            column(GL_Book_Entry_DescriptionCaption_Control1130028; GLBookEntry.FIELDCAPTION(Description))
            {
            }
            column(GL_Book_Entry__External_Document_No__Caption_Control1130029; GLBookEntry.FIELDCAPTION("External Document No."))
            {
            }
            column(GL_Book_Entry__Document_Date_Caption_Control1130030; GL_Book_Entry__Document_Date_Caption_Control1130030Lbl)
            {
            }
            column(GL_Book_Entry__Document_No__Caption_Control1130031; GLBookEntry.FIELDCAPTION("Document No."))
            {
            }
            column(GL_Book_Entry__Posting_Date_Caption_Control1130032; GL_Book_Entry__Posting_Date_Caption_Control1130032Lbl)
            {
            }
            column(GL_Book_Entry__Transaction_No__Caption_Control1130033; GLBookEntry.FIELDCAPTION("Transaction No."))
            {
            }
            column(GL_Book_Entry__Entry_No__Caption_Control1130034; GLBookEntry.FIELDCAPTION("Entry No."))
            {
            }
            column(GL_Book_Entry__External_Document_No__Caption_Control1130036; GLBookEntry.FIELDCAPTION("External Document No."))
            {
            }
            column(GL_Book_Entry__Document_Date_Caption_Control1130037; GL_Book_Entry__Document_Date_Caption_Control1130037Lbl)
            {
            }
            column(GL_Book_Entry__Document_No__Caption_Control1130038; GLBookEntry.FIELDCAPTION("Document No."))
            {
            }
            column(GL_Book_Entry_DescriptionCaption_Control1130039; GLBookEntry.FIELDCAPTION(Description))
            {
            }
            column(IcreasesAmnt_Control1130071Caption_Control1130040; IcreasesAmnt_Control1130071Caption_Control1130040Lbl)
            {
            }
            column(DecreasesAmnt_Control1130070Caption_Control1130041; DecreasesAmnt_Control1130070Caption_Control1130041Lbl)
            {
            }
            column(AmntCaption; AmntCaptionLbl)
            {
            }
            column(GL_Book_Entry__Posting_Date_Caption_Control1130043; GL_Book_Entry__Posting_Date_Caption_Control1130043Lbl)
            {
            }
            column(GL_Book_Entry__Transaction_No__Caption_Control1130044; GLBookEntry.FIELDCAPTION("Transaction No."))
            {
            }
            column(GL_Book_Entry__Entry_No__Caption_Control1130045; GLBookEntry.FIELDCAPTION("Entry No."))
            {
            }
            column(IcreasesAmnt_Control1130071Caption_Control1130047; IcreasesAmnt_Control1130071Caption_Control1130047Lbl)
            {
            }
            column(DecreasesAmnt_Control1130070Caption_Control1130048; DecreasesAmnt_Control1130070Caption_Control1130048Lbl)
            {
            }
            column(AmntCaption_Control1130049; AmntCaption_Control1130049Lbl)
            {
            }
            column(GL_Book_Entry_DescriptionCaption_Control1130050; GLBookEntry.FIELDCAPTION(Description))
            {
            }
            column(GL_Book_Entry__External_Document_No__Caption_Control1130051; GLBookEntry.FIELDCAPTION("External Document No."))
            {
            }
            column(GL_Book_Entry__Document_Date_Caption_Control1130052; GL_Book_Entry__Document_Date_Caption_Control1130052Lbl)
            {
            }
            column(GL_Book_Entry__Document_No__Caption_Control1130053; GLBookEntry.FIELDCAPTION("Document No."))
            {
            }
            column(Amounts_in_Additional_CurrencyCaption_Control1130054; Amounts_in_Additional_CurrencyCaption_Control1130054Lbl)
            {
            }
            column(GL_Book_Entry__Posting_Date_Caption_Control1130055; GL_Book_Entry__Posting_Date_Caption_Control1130055Lbl)
            {
            }
            column(GL_Book_Entry__Transaction_No__Caption_Control1130056; GLBookEntry.FIELDCAPTION("Transaction No."))
            {
            }
            column(GL_Book_Entry__Entry_No__Caption_Control1130057; GLBookEntry.FIELDCAPTION("Entry No."))
            {
            }
            dataitem(PageCounter; Integer)
            {
                DataItemTableView = sorting(Number)
                                    where(Number = const(1));
                column(StartOnHand; StartOnHand)
                {
                    AutoFormatType = 1;
                    DecimalPlaces = 0 : 5;
                }
                column(PageCounter_Number; Number)
                {
                }
                column(Progressive_TotalCaption; Progressive_TotalCaptionLbl)
                {
                }
                column(Printed_Entries_TotalCaption; Printed_Entries_TotalCaptionLbl)
                {
                }
                column(Printed_Entries_TotalCaption_Control1130099; Printed_Entries_TotalCaption_Control1130099Lbl)
                {
                }
                column(Printed_Entries_Total___Progressive_TotalCaption; Printed_Entries_Total___Progressive_TotalCaptionLbl)
                {
                }
                dataitem(DataItem4838; "GL Book Entry")
                {
                    DataItemLink = "G/L Account No." = field("No."),
                                   "Posting Date" = field("Date Filter");
                    DataItemLinkReference = "G/L Account";
                    DataItemTableView = sorting("Posting Date", "Transaction No.", "Entry No.")
                                        ORDER(Ascending)
                                        where(Amount = filter(<> 0));
                    column(DecreasesAmnt; DecreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(IcreasesAmnt; IncreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(Text1035____G_L_Account___No______________G_L_Account__Name; GLAccTxt + "G/L Account"."No." + ' - ' + "G/L Account".Name)
                    {
                    }
                    column(StartOnHand___Amount; StartOnHand + Amount)
                    {
                        AutoFormatType = 1;
                        DecimalPlaces = 0 : 5;
                    }
                    column(Text1035____G_L_Account___No______________G_L_Account__Name_Control1130068; GLAccTxt + "G/L Account"."No." + ' - ' + "G/L Account".Name)
                    {
                    }
                    column(Amnt; Amnt)
                    {
                        AutoFormatType = 1;
                    }
                    column(DecreasesAmnt_Control1130070; DecreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(IcreasesAmnt_Control1130071; IncreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(GL_Book_Entry_Description; Description)
                    {
                    }
                    column(GL_Book_Entry__External_Document_No__; "External Document No.")
                    {
                    }
                    column(GL_Book_Entry__Document_Date_; Format("Document Date"))
                    {
                    }
                    column(GL_Book_Entry__Document_No__; "Document No.")
                    {
                    }
                    column(GL_Book_Entry__Posting_Date_; Format("Posting Date"))
                    {
                    }
                    column(GL_Book_Entry__Transaction_No__; "Transaction No.")
                    {
                    }
                    column(GL_Book_Entry__Entry_No__; "Entry No.")
                    {
                    }
                    column(DecreasesAmnt_Control1130079; DecreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(IcreasesAmnt_Control1130080; IncreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(GL_Book_Entry_Description_Control1130081; Description)
                    {
                    }
                    column(GL_Book_Entry__External_Document_No___Control1130082; "External Document No.")
                    {
                    }
                    column(GL_Book_Entry__Document_Date__Control1130083; Format("Document Date"))
                    {
                    }
                    column(GL_Book_Entry__Document_No___Control1130084; "Document No.")
                    {
                    }
                    column(GL_Book_Entry__Posting_Date__Control1130085; Format("Posting Date"))
                    {
                    }
                    column(GL_Book_Entry__Transaction_No___Control1130086; "Transaction No.")
                    {
                    }
                    column(GL_Book_Entry__Entry_No___Control1130087; "Entry No.")
                    {
                    }
                    column(DecreasesAmnt_Control1130088; DecreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(IcreasesAmnt_Control1130089; IncreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(StartOnHand___Amount_Control1130094; StartOnHand + Amount)
                    {
                        AutoFormatType = 1;
                        DecimalPlaces = 0 : 5;
                    }
                    column(DecreasesAmnt_Control1130095; DecreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(IcreasesAmnt_Control1130096; IncreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(IcreasesAmnt_Control1130102; IncreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(DecreasesAmnt_Control1130103; DecreasesAmounts)
                    {
                        AutoFormatType = 1;
                    }
                    column(GL_Book_Entry_Amount; Amount)
                    {
                        AutoFormatType = 1;
                    }
                    column(StartOnHand___Amount_Control1130105; StartOnHand + Amount)
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalAmount; Amount)
                    {
                        AutoFormatType = 1;
                    }
                    column(GL_Book_Entry_G_L_Account_No_; "G/L Account No.")
                    {
                    }
                    column(GL_Book_Entry_Posting_Date; "Posting Date")
                    {
                    }
                    column(ContinuedCaption; ContinuedCaptionLbl)
                    {
                    }
                    column(ContinuedCaption_Control1130092; ContinuedCaption_Control1130092Lbl)
                    {
                    }
                    column(SourceText; SourceText)
                    {
                    }
                    column(ShowSource; ShowSourcePrmtr)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        Customer: Record Customer;
                        Vendor: Record "Vendor";
                    begin
                        CalcFields(Amount, "Debit Amount", "Credit Amount", "Additional-Currency Amount");

                        if not UseAmtsInAddCurr then begin
                            Amnt := Amnt + Amount;
                            CalcAmounts(IncreasesAmounts, DecreasesAmounts, Amount);
                        end else begin
                            Amnt := Amnt + "Additional-Currency Amount";
                            CalcAmounts(IncreasesAmounts, DecreasesAmounts, "Additional-Currency Amount");
                        end;

                        SourceText := '';
                        case "Source Type" of
                            "Source Type"::Customer:
                                begin
                                    if not Customer.Get("Source No.") then
                                        Customer.Init();
                                    SourceText := CustomerCaptionLbl + "Source No." + ' ' + Customer.Name;
                                end;
                            "Source Type"::Vendor:
                                begin
                                    if not Vendor.Get("Source No.") then
                                        Vendor.Init();
                                    SourceText := VendorCaptionLbl + "Source No." + ' ' + Vendor.Name;
                                end;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        //CurrReport.CREATETOTALS(Amount, IcreasesAmnt, DecreasesAmnt, "Additional-Currency Amount");
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                if GETFILTER("No.") <> '' then
                    GLFilterNo := CopyStr(GETFILTER("No."), 1, 30)
                else
                    GLFilterNo := CopyStr(GLFilterNoTxt, 1, 30);

                StartOnHand := 0;
                if GLDateFilter <> '' then
                    if GETRANGEMIN("Date Filter") > DMY2Date(01, 01, 0001) then begin
                        if "Income/Balance" = "Income/Balance"::"Balance Sheet" then
                            SetRange("Date Filter", 0D, CLOSINGDATE(GETRANGEMIN("Date Filter") - 1))
                        else
                            if FiscalYearStartDate <> GETRANGEMIN("Date Filter") then
                                SetRange("Date Filter", FiscalYearStartDate, GETRANGEMIN("Date Filter") - 1);
                        CalcFields("Net Change", "Additional-Currency Net Change");
                        if not UseAmtsInAddCurr then
                            StartOnHand := "Net Change"
                        else
                            StartOnHand := "Additional-Currency Net Change";
                        SetFilter("Date Filter", GLDateFilter);
                        if (FiscalYearStartDate = GETRANGEMIN("Date Filter")) and
                           ("Income/Balance" = "Income/Balance"::"Income Statement")
                        then
                            StartOnHand := 0;
                    end;
                Amnt := StartOnHand;

                GLBookEntry.Reset();
                GLBookEntry.CalcFields(Amount);
                GLBookEntry.SetRange("G/L Account No.", "No.");
                GLBookEntry.SetFilter("Posting Date", GLDateFilter);
                GLBookEntry.SetFilter(Amount, '<>0');
                if (StartOnHand = 0) and GLBookEntry.IsEmpty() then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            var
                CVSEngine: Codeunit "EOS AdvCustVendStat Engine";
            begin
                CompanyInfo.Get();
                CompAddr[1] := CVSEngine.GetCompanyNameForReport(18123354);
                CompAddr[2] := CompanyInfo.Address;
                CompAddr[3] := CompanyInfo."Post Code";
                CompAddr[4] := CompanyInfo.City;
                CompAddr[5] := CompanyInfo."Fiscal Code";
                COMPRESSARRAY(CompAddr);

                AccPeriod.Reset();
                AccPeriod.SetRange("New Fiscal Year", true);
                AccPeriod.SetFilter("Starting Date", '<=%1', GETRANGEMIN("Date Filter"));
                AccPeriod.FindLast();

                FiscalYearStartDate := AccPeriod."Starting Date";
            end;
        }
    }

    requestpage
    {
        SaveValues = false;

        layout
        {
            area(content)
            {
                group(Optionen)
                {
                    Caption = 'Options';
                    field(ProgressiveBalance; ProgressiveBalancePrmtr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Progressive Balance';
                        ToolTip = 'Specifies the value of the "Progressive Balance" field.';
                    }
                    field(ShowAmountsInAddReportingCurrency; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies the value of the "Show Amounts in Add. Reporting Currency" field.';
                    }
                    field(ShowSource; ShowSourcePrmtr)
                    {
                        Caption = 'Show source line';
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the "Show source line" field.';
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
    }

    trigger OnPreReport()
    var
        EOSCDLEventMgt: Codeunit "EOS CDL Event Mgt.";
        CheckType: Option Hidedialog,Message,Confirm,Error;
        CheckSalesDocNoGapsPassed: Boolean;
        CheckPurchDocNoGapsPassed: Boolean;
    begin
        GLDateFilter := "G/L Account".GETFILTER("Date Filter");

        CheckType := CheckType::Confirm;

        if GLDateFilter <> '' then begin
            //CheckSalesDocNoGaps("G/L Account".GETRANGEMAX("Date Filter"));
            //CheckPurchDocNoGaps("G/L Account".GETRANGEMAX("Date Filter"));
            CheckSalesDocNoGapsPassed := EOSCDLEventMgt.CheckSalesDocNoGaps(ObjectType::Report, 18123354, "G/L Account".GETRANGEMAX("Date Filter"), CheckType);
            CheckPurchDocNoGapsPassed := EOSCDLEventMgt.CheckPurchDocNoGaps(ObjectType::Report, 18123354, "G/L Account".GETRANGEMAX("Date Filter"), CheckType);
        end else begin
            //CheckSalesDocNoGaps(0D);
            //CheckPurchDocNoGaps(0D);
            CheckSalesDocNoGapsPassed := EOSCDLEventMgt.CheckSalesDocNoGaps(ObjectType::Report, 18123354, 0D, CheckType);
            CheckPurchDocNoGapsPassed := EOSCDLEventMgt.CheckPurchDocNoGaps(ObjectType::Report, 18123354, 0D, CheckType);
        end;
        if (not CheckPurchDocNoGapsPassed) or (not CheckSalesDocNoGapsPassed) then
            Error('');
    end;

    var
        AccPeriod: Record "Accounting Period";
        GLBookEntry: Record "GL Book Entry";
        CompanyInfo: Record "Company Information";
        DateFilterTxt: Label 'Period: ';
        GLFilterNoTxt: Label 'ALL';
        GLAccTxt: Label 'Continued: ';
        CompAddr: array[5] of Text[100];
        GLDateFilter: Text;
        Amnt: Decimal;
        StartOnHand: Decimal;
        IncreasesAmounts: Decimal;
        DecreasesAmounts: Decimal;
        UseAmtsInAddCurr: Boolean;
        ProgressiveBalancePrmtr: Boolean;
        GLFilterNo: Text[30];
        FiscalYearStartDate: Date;
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Account_Sheet___General_LedgerCaptionLbl: Label 'Account Sheet - General Ledger';
        Account_No_CaptionLbl: Label 'Account No.';
        Account_Name_CaptionLbl: Label 'Account Name';
        Period_CaptionLbl: Label 'Period:';
        IcreasesAmnt_Control1130071CaptionLbl: Label 'Debit Amount';
        DecreasesAmnt_Control1130070CaptionLbl: Label 'Credit Amount';
        GL_Book_Entry__Document_Date_CaptionLbl: Label 'Doc. Date';
        GL_Book_Entry__Posting_Date_CaptionLbl: Label 'Posting Date';
        Amounts_in_Additional_CurrencyCaptionLbl: Label 'Amounts in Additional-Currency';
        IcreasesAmnt_Control1130071Caption_Control1130026Lbl: Label 'Debit Amount';
        DecreasesAmnt_Control1130070Caption_Control1130027Lbl: Label 'Credit Amount';
        GL_Book_Entry__Document_Date_Caption_Control1130030Lbl: Label 'Document Date';
        GL_Book_Entry__Posting_Date_Caption_Control1130032Lbl: Label 'Posting Date';
        GL_Book_Entry__Document_Date_Caption_Control1130037Lbl: Label 'Document Date';
        IcreasesAmnt_Control1130071Caption_Control1130040Lbl: Label 'Debit Amount';
        DecreasesAmnt_Control1130070Caption_Control1130041Lbl: Label 'Credit Amount';
        AmntCaptionLbl: Label 'Balance';
        GL_Book_Entry__Posting_Date_Caption_Control1130043Lbl: Label 'Posting Date';
        IcreasesAmnt_Control1130071Caption_Control1130047Lbl: Label 'Debit Amount';
        DecreasesAmnt_Control1130070Caption_Control1130048Lbl: Label 'Credit Amount';
        AmntCaption_Control1130049Lbl: Label 'Balance';
        GL_Book_Entry__Document_Date_Caption_Control1130052Lbl: Label 'Document Date';
        Amounts_in_Additional_CurrencyCaption_Control1130054Lbl: Label 'Amounts in Additional-Currency';
        GL_Book_Entry__Posting_Date_Caption_Control1130055Lbl: Label 'Posting Date';
        Progressive_TotalCaptionLbl: Label 'Progressive Total';
        ContinuedCaptionLbl: Label 'Continued';
        ContinuedCaption_Control1130092Lbl: Label 'Continued';
        Printed_Entries_TotalCaptionLbl: Label 'Printed Entries Total';
        Printed_Entries_TotalCaption_Control1130099Lbl: Label 'Printed Entries Total';
        Printed_Entries_Total___Progressive_TotalCaptionLbl: Label 'Printed Entries Total + Progressive Total';
        // CheckSalesDocNoGaps_Text1130000Err: Label 'There are unposted sales documents with a reserved %5 (%6). Please post these before continuing.\\%1: %2\%3: %4.';
        // CheckPurchDocNoGaps_Text1130001Err: Label 'There are unposted purchase documents with a reserved %5 (%6). Please post these before continuing.\\%1: %2\%3: %4.';
        SourceText: Text;
        ShowSourcePrmtr: Boolean;
        CustomerCaptionLbl: Label 'Customer: ';
        VendorCaptionLbl: Label 'Vendor: ';

    local procedure CalcAmounts(var IcreasesAmnt: Decimal; var DecreasesAmnt: Decimal; Amount: Decimal)
    begin
        IcreasesAmnt := 0;
        DecreasesAmnt := 0;

        if Amount > 0 then
            IcreasesAmnt := Amount
        else
            DecreasesAmnt := ABS(Amount);
    end;

    // local procedure CheckSalesDocNoGaps(MaxDate: Date)
    // var
    //     SalesHeader: Record "Sales Header";
    // begin
    //     SalesHeader.SetFilter("Posting No.", '<>%1', '');
    //     if MaxDate <> 0D then
    //         SalesHeader.SetFilter("Posting Date", '<=%1', MaxDate);
    //     if SalesHeader.Find('-') then
    //         Error(CheckSalesDocNoGaps_Text1130000Err, SalesHeader.FIELDCAPTION("Document Type"), SalesHeader."Document Type", SalesHeader.FIELDCAPTION("No."),
    //           SalesHeader."No.", SalesHeader.FIELDCAPTION("Posting No."), SalesHeader."Posting No.");
    // end;

    // local procedure CheckPurchDocNoGaps(MaxDate: Date)
    // var
    //     PurchHeader: Record "Purchase Header";
    // begin
    //     PurchHeader.SetFilter("Posting No.", '<>%1', '');
    //     if MaxDate <> 0D then
    //         PurchHeader.SetFilter("Posting Date", '<=%1', MaxDate);
    //     if PurchHeader.Find('-') then
    //         Error(CheckPurchDocNoGaps_Text1130001Err, PurchHeader.FIELDCAPTION("Document Type"), PurchHeader."Document Type", PurchHeader.FIELDCAPTION("No."),
    //           PurchHeader."No.", PurchHeader.FIELDCAPTION("Posting No."), PurchHeader."Posting No.");
    // end;
}

