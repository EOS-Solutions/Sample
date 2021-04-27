report 18123353 "EOS Cust Aging In Column"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/Report/report 18123353 EOS Cust Aging In Column.rdlc';
    Caption = 'Customer Aging - in Column (CVS)';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = true;
    ApplicationArea = All;

    dataset
    {
        dataitem(CustomerFilters; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", Name, "Country/Region Code";

            trigger OnPreDataItem();
            begin
                CurrReport.BREAK();
            end;
        }
        dataitem(SalespersonFilters; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting(Code);
            RequestFilterFields = "Code";

            trigger OnPreDataItem();
            begin
                CurrReport.BREAK();
            end;
        }
        dataitem(DataProcessing; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            trigger OnPreDataItem();
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
                Customer: Record Customer;
                TempAssetsBufferLocal: array[4] of Record "EOS Statem. Assets Buffer EXT" temporary;
                LastCustomer: Code[20];
                LastSalesperson: Code[20];
                Index: Integer;
                ProcessingSort: Integer;
                SalespersonFilter: Text;
                i: Integer;
            begin
                if UseSalespersonFromCustomerPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        CustomerFilters.SetFilter("Salesperson Code", SalespersonFilter);
                    end;
                AssetsEngine.SetForceCustomerSalesperson(UseSalespersonFromCustomerPrmtr);
                AssetsEngine.BuildMultiSourceTreeView(0, CustomerFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate, StartingDueDate, EndingDueDate, OnlyOpen, false, '', TempAssetsBufferLocal[1]);

                OnAfterBuildMultiSourceTreeView(CustomerFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpen, false, '', TempAssetsBufferLocal[1]);

                if not UseSalespersonFromCustomerPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        TempAssetsBufferLocal[2].SetFilter("EOS Salesperson Code", SalespersonFilter);
                    end;
                LastSalesperson := 'XYZ123';
                TempAssetsBufferLocal[2].SetCurrentKey("EOS Salesperson Code", "EOS Source No.");
                ProcessingSort := 0;
                CustomerFilters.CopyFilter("Currency Filter", TempAssetsBufferLocal[2]."EOS Currency Code");
                TempAssetsBufferLocal[2].SetRange("EOS Level No.", 2);
                TempAssetsBufferLocal[2].SetFilter("EOS Payment Method", PaymentMethodFilterPrmtr);
                if TempAssetsBufferLocal[2].FindSet() then begin
                    LastCustomer := TempAssetsBufferLocal[2]."EOS Source No.";
                    repeat
                        Customer.Get(TempAssetsBufferLocal[2]."EOS Source No.");

                        ProcessingSort += 1;
                        if LastSalesperson <> TempAssetsBufferLocal[2]."EOS Salesperson Code" then begin
                            LastSalesperson := TempAssetsBufferLocal[2]."EOS Salesperson Code";
                            if not SalespersonPurchaser.Get(TempAssetsBufferLocal[2]."EOS Salesperson Code") then begin
                                Clear(SalespersonPurchaser);
                                SalespersonPurchaser.Name := CopyStr(NoSalespersonTxt, 1, 50);
                            end;
                            //      if NewPagePerSalesperson then
                            //        PageGroup += 1;
                        end;
                        if LastCustomer <> TempAssetsBufferLocal[2]."EOS Source No." then
                            if NewPagePerCustomerPrmtr then
                                PageGroup += 1;

                        if TempAssetsBufferLocal[2]."EOS Level No." > 3 then
                            TempAssetsBufferLocal[2]."EOS Level No." := 3;

                        if PrintAmountInLCYPrmtr then
                            TempAssetsBufferLocal[2]."EOS Currency Code" := '';

                        case DetailLevelPrmtr of
                            DetailLevelPrmtr::Customer:
                                TempReportingBuffer.PrepareRecord_CustomerDetail(TempAssetsBufferLocal[2], ProcessingSort, false);
                            DetailLevelPrmtr::Document:
                                TempReportingBuffer.PrepareRecord_DocumentDetail(TempAssetsBufferLocal[2], ProcessingSort, false);
                            DetailLevelPrmtr::Duedates:
                                TempReportingBuffer.PrepareRecord_DuedatesDetail(TempAssetsBufferLocal[2], ProcessingSort, false);
                        end;

                        if TempReportingBuffer."EOS Due Date" > TempAssetsBufferLocal[2]."EOS Due Date" then
                            TempReportingBuffer."EOS Due Date" := TempAssetsBufferLocal[2]."EOS Due Date";

                        TempReportingBuffer."EOS Original Amount (LCY)" += TempAssetsBufferLocal[2]."EOS Original Amount (LCY)";
                        TempReportingBuffer."EOS Remaining Amount (LCY)" += TempAssetsBufferLocal[2]."EOS Remaining Amount (LCY)";
                        TempReportingBuffer."EOS Original Amount" += TempAssetsBufferLocal[2]."EOS Original Amount";
                        TempReportingBuffer."EOS Remaining Amount" += TempAssetsBufferLocal[2]."EOS Remaining Amount";
                        TempReportingBuffer."EOS Exposure (LCY)" += TempAssetsBufferLocal[2]."EOS Exposure (LCY)";
                        TempReportingBuffer."EOS Dishonored Entry No." := TempAssetsBufferLocal[2]."EOS Dishonored Entry No.";
                        TempReportingBuffer."EOS Source Name" := Customer.Name;
                        TempReportingBuffer."EOS Due Date" := TempAssetsBufferLocal[2]."EOS Due Date";
                        TempReportingBuffer."EOS Page Group" := PageGroup;
                        // Calcolo il vettore per incasellare i totali
                        Index := GetPeriodIndex(TempAssetsBufferLocal[2]."EOS Due Date");
                        TempReportingBuffer.AddColumnAmounts(Index, TempAssetsBufferLocal[2]."EOS Remaining Amount", TempAssetsBufferLocal[2]."EOS Remaining Amount (LCY)", TempAssetsBufferLocal[2]."EOS Exposure (LCY)");
                        TempReportingBuffer.Modify();
                        // Gestisco le somme (valuta) delle colonne
                        TempCurrencyBuffer.PrepareRecord_Currency(TempAssetsBufferLocal[2], false, false);
                        TempCurrencyBuffer.AddColumnAmounts(Index, TempAssetsBufferLocal[2]."EOS Remaining Amount", TempAssetsBufferLocal[2]."EOS Remaining Amount (LCY)", 0);
                        TempCurrencyBuffer.Modify();
                        // Inserisco l'esposizione (che per definizione è solo euro)
                        if TempAssetsBufferLocal[2]."EOS Exposure (LCY)" <> 0 then begin
                            TempCurrencyBuffer.PrepareRecord_Currency(TempAssetsBufferLocal[2], true, false);
                            TempCurrencyBuffer.AddColumnAmounts(Index, TempAssetsBufferLocal[2]."EOS Exposure (LCY)", TempAssetsBufferLocal[2]."EOS Exposure (LCY)", 0);
                            TempCurrencyBuffer.Modify();
                        end;

                        for i := 1 to 7 do
                            if (i in [Index .. GetMiddle() - 1]) or ((Index in [GetMiddle() .. 7]) and (i >= Index)) then begin
                                TempCurrencyBuffer.PrepareRecord_Currency(TempAssetsBufferLocal[2], false, true);
                                TempCurrencyBuffer.AddColumnAmounts(i, TempAssetsBufferLocal[2]."EOS Remaining Amount", TempAssetsBufferLocal[2]."EOS Remaining Amount (LCY)", 0);
                                TempCurrencyBuffer.Modify();
                                if TempAssetsBufferLocal[2]."EOS Exposure (LCY)" <> 0 THEN begin
                                    TempCurrencyBuffer.PrepareRecord_Currency(TempAssetsBufferLocal[2], true, true);
                                    TempCurrencyBuffer.AddColumnAmounts(i, TempAssetsBufferLocal[2]."EOS Exposure (LCY)", TempAssetsBufferLocal[2]."EOS Exposure (LCY)", 0);
                                    TempCurrencyBuffer.Modify();
                                end;
                            end;

                    // for i := 1 to 7 do
                    //     if (i in [Index .. GetMiddle() - 1]) or ((Index in [GetMiddle() .. 7]) and (i >= Index)) then begin
                    //         TempCurrency.Code := TempAssetsBufferLocal[2]."EOS Currency Code" + '#CMLT';
                    //         if TempAssetsBufferLocal[2]."EOS Currency Code" = '' then
                    //             TempCurrency.Description := 'Euro (' + RunningTotalTxt + ')'
                    //         else
                    //             TempCurrency.Description := TempAssetsBufferLocal[2]."EOS Currency Code" + ' (' + RunningTotalTxt + ')';
                    //         if TempCurrency.Insert() then;
                    //         TempCurrencyBuffer."Primary Key" := TempCurrency.Code + '!' + Format(i);
                    //         if TempCurrencyBuffer.Find('=') then begin
                    //             TempCurrencyBuffer."Amount (ACY)" += TempAssetsBufferLocal[2]."EOS Remaining Amount";
                    //             TempCurrencyBuffer.Amount += TempAssetsBufferLocal[2]."EOS Remaining Amount (LCY)";
                    //             TempCurrencyBuffer.Modify();
                    //         end else begin
                    //             GenericBufferEntryNo += 1;
                    //             TempCurrencyBuffer.Init();
                    //             TempCurrencyBuffer."Dimension Set ID" := GenericBufferEntryNo;
                    //             TempCurrencyBuffer."Amount (ACY)" := TempAssetsBufferLocal[2]."EOS Remaining Amount";
                    //             TempCurrencyBuffer.Amount := TempAssetsBufferLocal[2]."EOS Remaining Amount (LCY)";
                    //             TempCurrencyBuffer.Insert();
                    //         end;
                    //     end;
                    until TempAssetsBufferLocal[2].Next() = 0;
                end;
                Clear(TempReportingBuffer);

                OnAfterBuildReportingDataset(CustomerFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                             StartingDueDate, EndingDueDate, OnlyOpen, false, '', TempAssetsBufferLocal[1],
                                             TempReportingBuffer)

            end;
        }
        dataitem(ReportHeaderValues; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(CompanyName; COMPANYNAME()) { }
            column(ApplyedFilters; GetReportParametersText()) { }
            column(ColumnText1; HeaderText[1]) { }
            column(ColumnText2; HeaderText[2]) { }
            column(ColumnText3; HeaderText[3]) { }
            column(ColumnText4; HeaderText[4]) { }
            column(ColumnText5; HeaderText[5]) { }
            column(ColumnText6; HeaderText[6]) { }
            column(ColumnText7; HeaderText[7]) { }
        }
        dataitem(TempReportingBuffer; "EOS AdvCustVend Buffer")
        {
            DataItemTableView = sorting("EOS Processing Sort");
            UseTemporary = true;

            column(PageGroup; TempReportingBuffer."EOS Page Group") { }
            column(DetailGroup; TempReportingBuffer."EOS Detail Group") { }
            column(LineTypeFormat; GetLineTypeFormat(TempReportingBuffer)) { }
            column(Level; TempReportingBuffer."EOS Level No.") { }
            column(PrintLayout; GetPrintLayout()) { }
            column(CustomerNo; TempReportingBuffer."EOS Source No.") { }
            column(CustomerName; TempReportingBuffer."EOS Source Name") { }
            column(PostingDate; Format(TempReportingBuffer."EOS Posting Date")) { }
            column(DocumentType; Format(TempReportingBuffer."EOS Document Type")) { }
            column(DocumentNo; TempReportingBuffer."EOS Document No.") { }
            column(PaymentMethod; GetPaymentMethod()) { }
            column(OriginalAmount; GetOriginalAmount()) { }
            column(RemainingAmount; GetRemainingAmount()) { }
            column(DueAmount1; GetDueAmount(1, false)) { }
            column(DueAmount2; GetDueAmount(2, false)) { }
            column(DueAmount3; GetDueAmount(3, false)) { }
            column(DueAmount4; GetDueAmount(4, false)) { }
            column(DueAmount5; GetDueAmount(5, false)) { }
            column(DueAmount6; GetDueAmount(6, false)) { }
            column(DueAmount7; GetDueAmount(7, false)) { }
            column(ExpositionAmount1; GetExposureAmount(1)) { }
            column(ExpositionAmount2; GetExposureAmount(2)) { }
            column(ExpositionAmount3; GetExposureAmount(3)) { }
            column(ExpositionAmount4; GetExposureAmount(4)) { }
            column(ExpositionAmount5; GetExposureAmount(5)) { }
            column(ExpositionAmount6; GetExposureAmount(6)) { }
            column(ExpositionAmount7; GetExposureAmount(7)) { }
            column(DueDate; Format(TempReportingBuffer."EOS Due Date")) { }
            column(CurrencyCode; GetCurrencyCode(false)) { }
            column(VerticalColumn; GetVerticalColumn()) { }
            trigger OnAfterGetRecord();
            begin
                ReportLineCount += 1;
            end;

            trigger OnPreDataItem();
            begin
                Reset();
                SetCurrentKey("EOS Processing Sort");
            end;
        }
        dataitem(CurrencyDetail; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));

            column(CurrencyTotalCode; GetCurrencyCode(true)) { }
            column(CurrencyTotalDescription; GetDueAmountDescription()) { }
            column(HideTotal; GetHideTotal()) { }
            column(CurrencyDueAmount0; GetDueAmount(0, true)) { }
            column(CurrencyDueAmount1; GetDueAmount(1, true)) { }
            column(CurrencyDueAmount2; GetDueAmount(2, true)) { }
            column(CurrencyDueAmount3; GetDueAmount(3, true)) { }
            column(CurrencyDueAmount4; GetDueAmount(4, true)) { }
            column(CurrencyDueAmount5; GetDueAmount(5, true)) { }
            column(CurrencyDueAmount6; GetDueAmount(6, true)) { }
            column(CurrencyDueAmount7; GetDueAmount(7, true)) { }

            trigger OnPreDataItem();
            begin
                TempCurrencyBuffer.Reset();
                TempCurrencyBuffer.SetCurrentKey("EOS Currency Code", "EOS Exposition", "EOS Cumulative Amounts");
                if not TempCurrencyBuffer.Find('-') then
                    CurrReport.Break();
            end;

            trigger OnAfterGetRecord();
            begin
                if Number > 1 then
                    if TempCurrencyBuffer.Next() = 0 then
                        CurrReport.Break();
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
                field(HeadingType; HeadingTypePrmtr)
                {
                    Caption = 'Heading Type';
                    ApplicationArea = All;
                }
                field(DueDateAt; DueDateAtPrmtr)
                {
                    Caption = 'Aged As Of';
                    ApplicationArea = All;
                }
                field(PeriodLength; PeriodLengthPrmtr)
                {
                    Caption = 'Period Length';
                    ApplicationArea = All;
                }
                field(PrintAmountInLCY; PrintAmountInLCYPrmtr)
                {
                    Caption = 'Print Amounts in LCY';
                    ApplicationArea = All;
                }
                field(DetailLevel; DetailLevelPrmtr)
                {
                    Caption = 'Detail Level';
                    ApplicationArea = All;

                    trigger OnValidate();
                    begin
                        UpdateReqPage();
                    end;
                }
                field(ColumnLayout; ColumnLayoutPrmtr)
                {
                    Caption = 'Column Count due/to be due';
                    ApplicationArea = All;
                }
                field(NewPagePerCustomer; NewPagePerCustomerPrmtr)
                {
                    Caption = 'New Page Per Customer';
                    ApplicationArea = All;
                }
                field(UseSalespersonFromCustomer; UseSalespersonFromCustomerPrmtr)
                {
                    Caption = 'Use Salesperson from Customer';
                    ApplicationArea = All;
                }
                field(PrintFilters; PrintFiltersPrmtr)
                {
                    Caption = 'Print Filters';
                    ApplicationArea = All;
                }
                field(PostingDateFilter; PostingDateFilterPrmtr)
                {
                    Caption = 'Posting Date Filter';
                    ApplicationArea = All;

                    trigger OnValidate();
                    begin
                        ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
                        RequestOptionsPage.Update(false);
                    end;
                }
                field(DueDateFilter; DueDateFilterPrmtr)
                {
                    Caption = 'Due Date Filter';
                    ApplicationArea = All;

                    trigger OnValidate();
                    begin
                        ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);
                        RequestOptionsPage.Update(false);
                    end;
                }
                field(PaymentMethodFilter; PaymentMethodFilterPrmtr)
                {
                    Caption = 'Payment Method Filter';
                    TableRelation = "Payment Method";
                    ApplicationArea = All;
                }
            }
        }
        trigger OnOpenPage();
        var
            Parameters: Record "EOS008 CVS Report Parameters";
            AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
        begin
            CurrReport.RequestOptionsPage.Caption := CurrReport.RequestOptionsPage.Caption() + SubscriptionMgt.GetLicenseText();
            OnlyOpen := true;
            NewPagePerCustomerPrmtr := false;
            UpdateReqPage();
            if AdvCustVendStatSharedMem.GetReportParameter(Parameters) then begin
                HeadingTypePrmtr := Parameters."Heading Type";
                DueDateAtPrmtr := Parameters."Aged As Of";
                PeriodLengthPrmtr := Parameters."Period Length";
                PrintAmountInLCYPrmtr := Parameters."Print Amounts in LCY";
                DetailLevelPrmtr := Parameters."Customer Detail Level";
                ColumnLayoutPrmtr := Parameters."Customer Column Setup";
                NewPagePerCustomerPrmtr := Parameters."New Page Per Vendor";
                UseSalespersonFromCustomerPrmtr := Parameters."Use Salesperson from Customer";
                PrintFiltersPrmtr := Parameters."Print Filters";
                PostingDateFilterPrmtr := Parameters."Posting Date Filter";
                DueDateFilterPrmtr := Parameters."Due Date Filter";
                PaymentMethodFilterPrmtr := Parameters."Payment Method Filter";

                if Parameters."Customer Vendor Table Filter 1" <> '' then begin
                    CustomerFilters.Reset();
                    CustomerFilters.SetView(Parameters."Customer Vendor Table Filter 1");
                end;
                if Parameters."SalesPerson Table Filter 1" <> '' then begin
                    SalespersonFilters.Reset();
                    SalespersonFilters.SetView(Parameters."SalesPerson Table Filter 1");
                end;

            end;
        end;
    }
    labels
    {
        ReportTitle = 'Customer Aging';
        CustomerNoLabel = 'Customer';
        CustomerNameLabel = 'Name';
        PostingDateLabel = 'Posting Date';
        DueDateLabel = 'Due Date';
        OriginalAmountLabel = 'Original Amt.';
        PageNoLabel = 'Page';
        DocumentTypeLabel = 'Type';
        DocumentNoLabel = 'Document';
        PaymentMethodLabel = 'Pmt.';
        RemainingAmountLCYLabel = 'Remaining Amt. (LCY)';
        RemainingAmountLabel = 'Remaining Amount';
        AmountLCYLabel = 'Amount (LCY)';
        AmountLabel = 'Amount';
        CurrencyCodeLabel = 'Curr';
        TotalAmountLabel = 'Total Report Amount';
        ExposureLabel = 'Exposure';
        CustomerTotalLabel = 'Total For';
        DescriptionLabel = 'Description';
        BalanceCaption = 'Balance';
    }
    trigger OnInitReport();
    begin
        ColumnLayoutPrmtr := ColumnLayoutPrmtr::"2/3";
        SubscriptionActiv := SubscriptionMgt.GetSubscriptionIsActive();
    end;

    trigger OnPreReport();
    begin
        if not SubscriptionActiv then
            Currreport.quit();

        if Format(PeriodLengthPrmtr) = '' then
            Error(Text010Err, PeriodLengthPrmtr);
        GeneralLedgerSetup.Get();
        CalcDates();
        ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
        ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCurrencyBuffer: Record "EOS AdvCustVend Buffer" temporary;
        AssetsEngine: Codeunit "EOS AdvCustVendStat Engine";
        SubscriptionMgt: Codeunit "EOS AdvCustVendStat Subscript";
        PeriodLengthPrmtr: DateFormula;
        PageGroup: Integer;
        [InDataSet]
        LinkedEntriesEnabled: Boolean;
        ReportLineCount: Integer;
        PostingDateFilterPrmtr: Text;
        DueDateFilterPrmtr: Text;
        PaymentMethodFilterPrmtr: Text;
        DetailLevelPrmtr: Enum "EOS008 CVD Cust Detail Level";
        OnlyOpen: Boolean;
        DueDateAtPrmtr: Date;
        ColumnLayoutPrmtr: Enum "EOS008 CVD Cust Column setup";
        HeadingTypePrmtr: Enum "EOS008 CVS Report Heading Type";
        PrintAmountInLCYPrmtr: Boolean;
        [InDataSet]
        NewPagePerCustomerPrmtr: Boolean;
        PrintFiltersPrmtr: Boolean;
        UseSalespersonFromCustomerPrmtr: Boolean;
        StartingPostingDate: Date;
        EndingPostingDate: Date;
        StartingDueDate: Date;
        EndingDueDate: Date;
        CustomerFilterTextMsg: Label 'Customer Filters:';
        PostingDateFilterTextMsg: Label 'Posting Date Filter:';
        DueDateFilterTextMsg: Label 'Due Date Filter:';
        PaymentFilterTextMsg: Label 'Payment Filter:';
        ReportSortTextMsg: Label 'Sorted By %1 with %2 detail level. %3';
        OnlyOpenTextMsg: Label 'Only open entries.';
        PeriodStartDate: array[10] of Date;
        PeriodEndDate: array[10] of Date;
        HeaderText: array[10] of Text[30];
        ExposureTxt: Label 'exposure';
        RunningTotalTxt: Label 'cumulated';
        AllAmtinLCYCptnLbl: Label 'All Amounts in LCY.';
        DueAtTxt: Label 'Due at %1.';
        PeriodLengthTxt: Label 'Period Leght %1.';
        Header001Txt: Label 'Before';
        Header002Txt: Label 'days';
        Header003Txt: Label 'More than';
        Text010Err: Label 'The Date Formula %1 cannot be used. Try to restate it. E.g. 1M+CM instead of CM+1M.';
        Text032Txt: Label '-%1';
        NoSalespersonTxt: Label 'Without Salesperson';
        SubscriptionActiv: Boolean;

    local procedure GetMiddle(): Integer;
    begin
        case ColumnLayoutPrmtr of
            ColumnLayoutPrmtr::"0/5":
                exit(2);
            ColumnLayoutPrmtr::"1/4":
                exit(3);
            ColumnLayoutPrmtr::"2/3":
                exit(4);
            ColumnLayoutPrmtr::"3/2":
                exit(5);
            ColumnLayoutPrmtr::"4/1":
                exit(6);
            ColumnLayoutPrmtr::"5/0":
                exit(7);
        end;
    end;

    local procedure CalcDates();
    var
        PeriodLength2: DateFormula;
        TempDateFormula: DateFormula;
        i: Integer;
        Middle: Integer;
        DueDateAtMatchEndingPeriod: Boolean;
        MonthTag: Text;
        QuarterTag: Text;
        PeriodLengthPrmtrErr: Label 'You must specify "Period Length" parameter.';
    begin
        if Format(PeriodLengthPrmtr) = '' then
            Error(PeriodLengthPrmtrErr);

        Evaluate(PeriodLength2, StrSubstNo(Text032Txt, PeriodLengthPrmtr));
        Middle := GetMiddle();
        DueDateAtMatchEndingPeriod := CALCDATE('<CM>', DueDateAtPrmtr) = DueDateAtPrmtr;
        if DueDateAtMatchEndingPeriod then begin
            Evaluate(TempDateFormula, '<1M>');
            MonthTag := DELCHR(Format(TempDateFormula), '<=>', '0123456789');
            Evaluate(TempDateFormula, '<1Q>');
            QuarterTag := DELCHR(Format(TempDateFormula), '<=>', '0123456789');
            if not (DELCHR(Format(PeriodLengthPrmtr), '<=>', '0123456789') in [MonthTag, QuarterTag]) then
                DueDateAtMatchEndingPeriod := false;
        end;
        //Current Month
        PeriodStartDate[Middle] := DueDateAtPrmtr + 1;
        PeriodEndDate[Middle] := CALCDATE(PeriodLengthPrmtr, PeriodStartDate[Middle]) - 1;
        for i := Middle - 1 downto 1 do begin
            PeriodEndDate[i] := PeriodStartDate[i + 1] - 1;
            if DueDateAtMatchEndingPeriod then begin
                PeriodStartDate[i] := CALCDATE(PeriodLength2, PeriodEndDate[i]);
                PeriodStartDate[i] := CALCDATE('<CM>', PeriodStartDate[i]) + 1;
            end else
                PeriodStartDate[i] := CALCDATE(PeriodLength2, PeriodEndDate[i]) + 1;
            if HeadingTypePrmtr = HeadingTypePrmtr::"Date Interval" then
                HeaderText[i] := CopyStr(StrSubstNo('%1 %2', PeriodStartDate[i], PeriodEndDate[i]), 1, 30)
            else
                HeaderText[i] := CopyStr(StrSubstNo('%1 .. %2 %3', DueDateAtPrmtr - PeriodStartDate[i] + 1, DueDateAtPrmtr - PeriodEndDate[i] + 1, Header002Txt), 1, 30);
        end;
        for i := Middle to 7 do begin
            PeriodStartDate[i] := PeriodEndDate[i - 1] + 1;
            PeriodEndDate[i] := CALCDATE(PeriodLengthPrmtr, PeriodEndDate[i - 1]);
            if DueDateAtMatchEndingPeriod then
                PeriodEndDate[i] := CALCDATE('<CM>', PeriodEndDate[i]);
            if HeadingTypePrmtr = HeadingTypePrmtr::"Date Interval" then
                HeaderText[i] := CopyStr(StrSubstNo('%1 %2', PeriodStartDate[i], PeriodEndDate[i]), 1, 30)
            else
                HeaderText[i] := CopyStr(StrSubstNo('%1 .. %2 %3', ABS(DueDateAtPrmtr - PeriodStartDate[i] + 1), ABS(DueDateAtPrmtr - PeriodEndDate[i] + 1), Header002Txt), 1, 30);
        end;
        PeriodStartDate[1] := 0D;
        PeriodEndDate[7] := DMY2DATE(31, 12, 9999);
        HeaderText[1] := Header001Txt + ' ' + Format(PeriodEndDate[1]);
        HeaderText[7] := Header003Txt + ' ' + Format(PeriodStartDate[7]);
    end;

    local procedure BuildRanges();
    begin
    end;

    local procedure GetBufferGroup(var BufferAssets: Record "EOS Statem. Assets Buffer EXT" temporary): Text;
    begin
        exit(BufferAssets."EOS Source No.");
    end;

    local procedure GetPeriodIndex(Date: Date): Integer;
    var
        i: Integer;
    begin
        for i := 1 to ARRAYLEN(PeriodEndDate) do
            if Date in [PeriodStartDate[i] .. PeriodEndDate[i]] then
                exit(i);
    end;

    local procedure GetReportParametersText() Result: Text;
    var
        Customer2: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EOSLibraryEXT: Codeunit "EOS Library EXT";
        PeriodLength2: DateFormula;
        DetailText: Text;
    begin
        Customer2 := CustomerFilters;
        if OnlyOpen then
            Customer2.SetRange("Balance (LCY)");
        Result += StrSubstNo(DueAtTxt, DueDateAtPrmtr);
        if PrintFiltersPrmtr then begin
            Result += StrSubstNo(PeriodLengthTxt, PeriodLength2);
            if Customer2.GetFilters() <> '' then
                Result += CustomerFilterTextMsg + CustomerFilters.GetFilters() + EOSLibraryEXT.NewLine();
            if PostingDateFilterPrmtr <> '' then
                Result += PostingDateFilterTextMsg + PostingDateFilterPrmtr + EOSLibraryEXT.NewLine();
            if DueDateFilterPrmtr <> '' then
                Result += DueDateFilterTextMsg + DueDateFilterPrmtr + EOSLibraryEXT.NewLine();
            if PaymentMethodFilterPrmtr <> '' then
                Result += PaymentFilterTextMsg + PaymentMethodFilterPrmtr + EOSLibraryEXT.NewLine();
        end;
        case DetailLevelPrmtr of
            DetailLevelPrmtr::Customer:
                DetailText := CustLedgerEntry.FIELDCAPTION("Customer No.");
            DetailLevelPrmtr::Document:
                DetailText := CustLedgerEntry.FIELDCAPTION("Document No.");
            DetailLevelPrmtr::Duedates:
                DetailText := CustLedgerEntry.FIELDCAPTION("Due Date");
        end;
        if PrintAmountInLCYPrmtr then
            Result += StrSubstNo(ReportSortTextMsg, CustLedgerEntry.FIELDCAPTION("Customer No."), DetailText, AllAmtinLCYCptnLbl)
        else
            Result += StrSubstNo(ReportSortTextMsg, CustLedgerEntry.FIELDCAPTION("Customer No."), DetailText, '');
        Result += ' ' + OnlyOpenTextMsg;
    end;

    local procedure GetLineTypeFormat(AdvCustVendBuffer: Record "EOS AdvCustVend Buffer"): Text;
    begin
        // 10 -> main asset (unused)
        // 20 -> asset level 2
        // 21 -> asset level 2 (customername expanded)
        // 30 -> asset level 3 (Payment)
        // xx -> asset level 4 (Dishonored)
        // 50 -> asset level 5 (Document Total)
        case AdvCustVendBuffer."EOS Level No." of
            1:
                exit('10');
            2:
                exit('20');
            3:
                exit('30');
            5:
                exit('50');
        end;
    end;

    local procedure GetPaymentMethod(): Text;
    begin
        if TempReportingBuffer."EOS Dishonored Entry No." <> 0 then
            exit('*' + CopyStr(TempReportingBuffer."EOS Payment Method", 1, 5))
        else
            exit(CopyStr(TempReportingBuffer."EOS Payment Method", 1, 5));
    end;

    local procedure GetOriginalAmount(): Decimal;
    begin
        if PrintAmountInLCYPrmtr then
            exit(TempReportingBuffer."EOS Original Amount (LCY)");
        exit(TempReportingBuffer."EOS Original Amount");
    end;

    procedure GetRemainingAmount(): Decimal;
    begin
        if PrintAmountInLCYPrmtr then
            exit(TempReportingBuffer."EOS Remaining Amount (LCY)" + TempReportingBuffer."EOS Exposure (LCY)");
        exit(TempReportingBuffer."EOS Remaining Amount")
    end;

    local procedure GetDueAmount(Index: Integer; CurrencyTotal: Boolean): Decimal;
    var
        Amount: Decimal;
        AmountLCY: Decimal;
        ExposureAmount: Decimal;
    begin
        if (Index = 0) and (CurrencyTotal) and (TempCurrencyBuffer."EOS Cumulative Amounts") then
            exit(0);

        if Index = 0 then
            exit(GetDueAmount(1, CurrencyTotal) + GetDueAmount(2, CurrencyTotal) + GetDueAmount(3, CurrencyTotal) + GetDueAmount(4, CurrencyTotal) + GetDueAmount(5, CurrencyTotal));

        if CurrencyTotal then
            TempCurrencyBuffer.GetColumnAmounts(Index, Amount, AmountLCY, ExposureAmount)
        else
            TempReportingBuffer.GetColumnAmounts(Index, Amount, AmountLCY, ExposureAmount);

        if PrintAmountInLCYPrmtr then
            exit(AmountLCY)
        else
            exit(Amount);
    end;

    local procedure GetDueAmountDescription() Result: Text;
    var
        Currency: Record Currency;
    begin
        if TempCurrencyBuffer."EOS Currency Code" <> '' then begin
            Currency.Get(TempCurrencyBuffer."EOS Currency Code");
            Result := Currency.Description;
        end else
            Result := 'Euro';

        if TempCurrencyBuffer."EOS Exposition" then
            result += ' (' + ExposureTxt + ')';

        if TempCurrencyBuffer."EOS Cumulative Amounts" then
            result += ' (' + RunningTotalTxt + ')';
    end;

    local procedure GetExposureAmount(Index: Integer): Decimal;
    var
        Amount: Decimal;
        AmountLCY: Decimal;
        ExposureAmount: Decimal;
    begin
        TempReportingBuffer.GetColumnAmounts(Index, Amount, AmountLCY, ExposureAmount);
        exit(ExposureAmount);
    end;

    local procedure GetPrintLayout(): Text;
    begin
        if (DetailLevelPrmtr = DetailLevelPrmtr::Customer) then
            exit('NOTOTAL');
        exit('TOTAL');
    end;

    local procedure GetCurrencyCode(CurrencyTotal: Boolean): Text;
    var
        CurrencyCode: Code[10];
    begin
        if not CurrencyTotal then
            CurrencyCode := TempReportingBuffer."EOS Currency Code"
        else
            CurrencyCode := TempCurrencyBuffer."EOS Currency Code";
        if STRPOS(CurrencyCode, '#') <> 0 then
            CurrencyCode := CopyStr(CopyStr(CurrencyCode, 1, STRPOS(CurrencyCode, '#') - 1), 1, 10);
        if (CurrencyCode = '') then
            exit(GeneralLedgerSetup."LCY Code");
        exit(CurrencyCode);
    end;

    procedure GetVerticalColumn(): Integer;
    begin
        case ColumnLayoutPrmtr of
            ColumnLayoutPrmtr::"0/5":
                exit(2);
            ColumnLayoutPrmtr::"1/4":
                exit(3);
            ColumnLayoutPrmtr::"2/3":
                exit(4);
            ColumnLayoutPrmtr::"3/2":
                exit(5);
            ColumnLayoutPrmtr::"4/1":
                exit(6);
            ColumnLayoutPrmtr::"5/0":
                exit(7);
        end;
    end;

    local procedure GetHideTotal(): Boolean;
    begin
        exit(TempCurrencyBuffer."EOS Cumulative Amounts");
    end;

    local procedure ResolveDateFilter(var DateFilter: Text; var StartingDate: Date; var EndingDate: Date);
    var
        DateTable: Record "Date";
    begin
        DateTable.SetRange("Period Type", DateTable."Period Type"::Date);
        DateTable.SetFilter("Period Start", DateFilter);
        if DateTable.FindFirst() then
            StartingDate := DateTable."Period Start";
        if DateTable.FindLast() then
            EndingDate := DateTable."Period Start";
        DateFilter := DateTable.GETFILTER("Period Start");
    end;

    local procedure UpdateReqPage();
    begin
        LinkedEntriesEnabled := DetailLevelPrmtr = DetailLevelPrmtr::Duedates;
    end;

    procedure SetOnlyOpenEntries(Set: Boolean);
    begin
        OnlyOpen := Set;
    end;

    procedure SetPeriodLength(Set: DateFormula);
    begin
        PeriodLengthPrmtr := Set;
    end;

    procedure SetDetailByCustomer();
    begin
        DetailLevelPrmtr := DetailLevelPrmtr::Customer;
    end;

    procedure SetDetailByDocument();
    begin
        DetailLevelPrmtr := DetailLevelPrmtr::Document;
    end;

    procedure SetDetailByDueDate();
    begin
        DetailLevelPrmtr := DetailLevelPrmtr::Duedates;
    end;

    procedure SetNewPagePerCustomer(Set: Boolean);
    begin
        NewPagePerCustomerPrmtr := Set;
    end;

    procedure SetUseCustomerSalesperson(Set: Boolean);
    begin
        UseSalespersonFromCustomerPrmtr := Set;
    end;

    procedure SetPostingDateFilter(Set: Text);
    begin
        PostingDateFilterPrmtr := Set;
    end;

    procedure SetDueDateFilter(Set: Text);
    begin
        DueDateFilterPrmtr := Set;
    end;

    procedure SetPaymentMethodFilter(Set: Text);
    begin
        PaymentMethodFilterPrmtr := Set;
    end;

    procedure GetReportLineCount(): Integer;
    begin
        exit(ReportLineCount);
    end;

    procedure SetDueDateAt(Set: Date);
    begin
        DueDateAtPrmtr := Set;
    end;

    procedure GetSelectionFilterForSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GETTABLE(SalespersonPurchaser);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, SalespersonPurchaser.FIELDNO(Code)));
        // TO-DO
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildMultiSourceTreeView(SourceView: Text; DateFilterType: Option "Posting Date","Document Date"; StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date; OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text; var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildReportingDataset(SourceView: Text; DateFilterType: Option "Posting Date","Document Date"; StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date; OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text; var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT"; var TempReportingBuffer: Record "EOS AdvCustVend Buffer")
    begin
    end;
}
