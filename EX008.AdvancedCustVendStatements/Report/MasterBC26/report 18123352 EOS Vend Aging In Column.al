report 18123352 "EOS Vend Aging In Column"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/Report/report 18123352 EOS Vend Aging In Column.rdlc';
    Caption = 'Vendor Aging - in Column (CVS)';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = true;
    ApplicationArea = All;

    dataset
    {
        dataitem(VendorFilters; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", Name, "Country/Region Code";

            trigger OnPreDataItem();
            begin
                CurrReport.Break();
            end;
        }
        dataitem(SalespersonFilters; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting(Code);
            RequestFilterFields = "Code";

            trigger OnPreDataItem();
            begin
                CurrReport.Break();
            end;
        }
        dataitem(DataProcessing; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            trigger OnPreDataItem();
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
                TempAssetsBufferLocal: array[4] of Record "EOS Statem. Assets Buffer EXT" temporary;
                Vendor: Record Vendor;
                LastSalesperson: Code[20];
                LastVendor: Code[20];
                i: Integer;
                Index: Integer;
                ProcessingSort: Integer;
                SalespersonFilter: Text;
            begin
                if UseSalespersonFromVendorPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        VendorFilters.SetFilter("Purchaser Code", SalespersonFilter);
                    end;
                AssetsEngine.SetForceCustomerSalesperson(UseSalespersonFromVendorPrmtr);
                AssetsEngine.BuildMultiSourceTreeView("EOS008 Source Type"::Vendor, VendorFilters.GetView(false), "EOS008 Date Filter Type"::"Posting Date",
                                                        StartingPostingDate, EndingPostingDate, StartingDueDate, EndingDueDate, OnlyOpen, false, '', OnHoldPrmtr, TempAssetsBufferLocal[1]);

                OnAfterBuildMultiSourceTreeView(VendorFilters.GetView(false), "EOS008 Date Filter Type"::"Posting Date", StartingPostingDate, EndingPostingDate,
                                                StartingDueDate, EndingDueDate, OnlyOpen, false, '', OnHoldPrmtr, TempAssetsBufferLocal[1]);

                if not UseSalespersonFromVendorPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        TempAssetsBufferLocal[2].SetFilter("EOS Salesperson Code", SalespersonFilter);
                    end;

                LastSalesperson := 'XYZ123';
                TempAssetsBufferLocal[2].SetCurrentKey("EOS Salesperson Code", "EOS Source No.");
                ProcessingSort := 0;
                VendorFilters.CopyFilter("Currency Filter", TempAssetsBufferLocal[2]."EOS Currency Code");
                TempAssetsBufferLocal[2].SetRange("EOS Level No.", 2);
                TempAssetsBufferLocal[2].SetFilter("EOS Payment Method", PaymentMethodFilterPrmtr);
                if TempAssetsBufferLocal[2].FindSet() then begin
                    LastVendor := TempAssetsBufferLocal[2]."EOS Source No.";
                    repeat
                        Vendor.SetLoadFields(Name);
                        Vendor.Get(TempAssetsBufferLocal[2]."EOS Source No.");

                        ProcessingSort += 1;
                        if LastSalesperson <> TempAssetsBufferLocal[2]."EOS Salesperson Code" then begin
                            LastSalesperson := TempAssetsBufferLocal[2]."EOS Salesperson Code";
                            if not SalespersonPurchaser.Get(TempAssetsBufferLocal[2]."EOS Salesperson Code") then begin
                                Clear(SalespersonPurchaser);
                                SalespersonPurchaser.Name := CopyStr(NoSalespersonTxt, 1, 50);
                            end;
                        end;
                        if LastVendor <> TempAssetsBufferLocal[2]."EOS Source No." then
                            if NewPagePerVendorPrmtr then
                                PageGroup += 1;

                        if TempAssetsBufferLocal[2]."EOS Level No." > 3 then
                            TempAssetsBufferLocal[2]."EOS Level No." := 3;

                        if PrintAmountInLCYPrmtr then
                            TempAssetsBufferLocal[2]."EOS Currency Code" := '';

                        case DetailLevelPrmtr of
                            DetailLevelPrmtr::Vendor:
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
                        TempReportingBuffer."EOS Source Name" := Vendor.Name;
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

                        for i := 1 to 6 do
                            if (i in [Index .. GetMiddle() - 1]) or ((Index in [GetMiddle() .. 6]) and (i >= Index)) then begin
                                TempCurrencyBuffer.PrepareRecord_Currency(TempAssetsBufferLocal[2], false, true);
                                TempCurrencyBuffer.AddColumnAmounts(i, TempAssetsBufferLocal[2]."EOS Remaining Amount", TempAssetsBufferLocal[2]."EOS Remaining Amount (LCY)", 0);
                                TempCurrencyBuffer.Modify();
                            end;

                    until TempAssetsBufferLocal[2].Next() = 0;
                end;
                Clear(TempReportingBuffer);

                OnAfterBuildReportingDataset(VendorFilters.GetView(false), "EOS008 Date Filter Type"::"Posting Date", StartingPostingDate, EndingPostingDate,
                                             StartingDueDate, EndingDueDate, OnlyOpen, false, '', TempAssetsBufferLocal[1],
                                             TempReportingBuffer)
            end;
        }
        dataitem(ReportHeaderValues; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(CompanyName; CompanyNameText) { }
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
            column(VendorNo; TempReportingBuffer."EOS Source No.") { }
            column(VendorName; TempReportingBuffer."EOS Source Name") { }
            column(PostingDate; Format(TempReportingBuffer."EOS Posting Date")) { }
            column(DocumentType; Format(TempReportingBuffer."EOS Document Type")) { }
            column(DocumentNo; TempReportingBuffer."EOS Document No.") { }
            column(ExternalDocumentNo; TempReportingBuffer."EOS External Document No.") { }
            column(PaymentMethod; GetPaymentMethod()) { }
            column(OriginalAmount; GetOriginalAmount()) { }
            column(RemainingAmount; GetRemainingAmount()) { }
            column(DueAmount1; GetDueAmount(1, false, false)) { }
            column(DueAmount2; GetDueAmount(2, false, false)) { }
            column(DueAmount3; GetDueAmount(3, false, false)) { }
            column(DueAmount4; GetDueAmount(4, false, false)) { }
            column(DueAmount5; GetDueAmount(5, false, false)) { }
            column(DueAmount6; GetDueAmount(6, false, false)) { }
            column(DueAmount7; GetDueAmount(7, false, false)) { }
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
            column(CurrencyDueAmount0; GetDueAmount(0, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }
            column(CurrencyDueAmount1; GetDueAmount(1, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }
            column(CurrencyDueAmount2; GetDueAmount(2, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }
            column(CurrencyDueAmount3; GetDueAmount(3, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }
            column(CurrencyDueAmount4; GetDueAmount(4, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }
            column(CurrencyDueAmount5; GetDueAmount(5, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }
            column(CurrencyDueAmount6; GetDueAmount(6, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }
            column(CurrencyDueAmount7; GetDueAmount(7, true, TempCurrencyBuffer."EOS Cumulative Amounts")) { }

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
        SaveValues = true;

        layout
        {
            area(Content)
            {
                field(HeadingType; HeadingTypePrmtr)
                {
                    Caption = 'Heading Type';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Heading Type" field.';
                }
                field(DueDateAt; DueDateAtPrmtr)
                {
                    Caption = 'Aged As Of';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Aged As Of" field.';
                }
                field(PeriodLength; PeriodLengthPrmtr)
                {
                    Caption = 'Period Length';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Period Length" field.';
                }
                field(PrintAmountInLCY; PrintAmountInLCYPrmtr)
                {
                    Caption = 'Print Amounts in LCY';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Print Amounts in LCY" field.';
                }
                field(DetailLevel; DetailLevelPrmtr)
                {
                    Caption = 'Detail Level';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Detail Level" field.';
                    trigger OnValidate();
                    begin
                        UpdateReqPage();
                    end;
                }
                field(ColumnLayout; ColumnLayoutPrmtr)
                {
                    Caption = 'Column Count due/to be due';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Column Count due/to be due" field.';
                }
                field(NewPagePerVendor; NewPagePerVendorPrmtr)
                {
                    Caption = 'New Page Per Vendor';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "New Page Per Vendor" field.';
                }
                field(UseSalespersonFromVendor; UseSalespersonFromVendorPrmtr)
                {
                    Caption = 'Use purchaser from Vendor';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Use purchaser from Vendor" field.';
                }
                field(PrintFilters; PrintFiltersPrmtr)
                {
                    Caption = 'Print Filters';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Print Filters" field.';
                }
                field(PostingDateFilter; PostingDateFilterPrmtr)
                {
                    Caption = 'Posting Date Filter';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Posting Date Filter" field.';

                    trigger OnValidate();
                    begin
                        ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
                    end;
                }
                field(DueDateFilter; DueDateFilterPrmtr)
                {
                    Caption = 'Due Date Filter';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Due Date Filter" field.';
                    trigger OnValidate();
                    begin
                        ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);
                    end;
                }
                field(PaymentMethodFilter; PaymentMethodFilterPrmtr)
                {
                    Caption = 'Payment Method Filter';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Payment Method Filter" field.';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PaymentMethod: Record "Payment Method";
                    begin
                        if Page.RunModal(Page::"Payment Methods", PaymentMethod) = Action::LookupOK then
                            PaymentMethodFilterPrmtr := PaymentMethod.Code;
                    end;
                }
                field(OnHoldFilter; OnHoldPrmtr)
                {
                    Caption = '"On Hold" Filter';
                    ApplicationArea = All;
                    ToolTip = 'Use this field to filter vendor ledger entries that are on hold or not on hold.';
                }
            }
        }
        trigger OnOpenPage();
        begin
            SubscriptionMgt.GetSubscriptionIsActive(); //this will show any subscription warnings if needed
            OnlyOpen := true;
            NewPagePerVendorPrmtr := false;
            UpdateReqPage();

            SetReportParameters();
        end;
    }
    labels
    {
        ReportTitle = 'Vendor Aging';
        VendorNoLabel = 'Vendor';
        VendorNameLabel = 'Name';
        PostingDateLabel = 'Posting Date';
        DueDateLabel = 'Due Date';
        OriginalAmountLabel = 'Original Amt.';
        PageNoLabel = 'Page';
        DocumentTypeLabel = 'Type';
        DocumentNoLabel = 'Document';
        ExternalDocumentNoLabel = 'External Document No.';
        PaymentMethodLabel = 'Pmt.';
        RemainingAmountLCYLabel = 'Remaining Amt. (LCY)';
        RemainingAmountLabel = 'Remaining Amount';
        AmountLCYLabel = 'Amount (LCY)';
        AmountLabel = 'Amount';
        CurrencyCodeLabel = 'Curr';
        TotalAmountLabel = 'Total Report Amount';
        ExposureLabel = 'Exposure';
        VendorTotalLabel = 'Total For';
        DescriptionLabel = 'Description';
        BalanceCaption = 'Balance';
    }
    trigger OnInitReport();
    begin
        ColumnLayoutPrmtr := ColumnLayoutPrmtr::"2/2";
    end;

    trigger OnPreReport();
    var
        CVStatEngine: Codeunit "EOS AdvCustVendStat Engine";
    begin
        SetReportParameters();
        if Format(PeriodLengthPrmtr) = '' then
            Error(Text010Err, PeriodLengthPrmtr);
        GeneralLedgerSetup.Get();
        CalcDates();
        ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
        ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);

        CompanyNameText := CVStatEngine.GetCompanyNameForReport(18123352);
    end;

    protected var
        TempCurrencyBuffer: Record "EOS AdvCustVend Buffer" temporary;
        ParametersBuffer: Record "EOS008 CVS Report Parameters";
        PeriodLengthPrmtr: DateFormula;
        PostingDateFilterPrmtr: Text;
        DueDateFilterPrmtr: Text;
        DetailLevelPrmtr: Enum "EOS008 CVD Vend Detail Level";
        PaymentMethodFilterPrmtr: Text;
        OnHoldPrmtr: Text;
        DueDateAtPrmtr: Date;
        ColumnLayoutPrmtr: Enum "EOS008 CVD Vend Column setup";
        HeadingTypePrmtr: Enum "EOS008 CVS Report Heading Type";
        PrintAmountInLCYPrmtr: Boolean;
        NewPagePerVendorPrmtr: Boolean;
        PrintFiltersPrmtr: Boolean;
        UseSalespersonFromVendorPrmtr: Boolean;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AssetsEngine: Codeunit "EOS AdvCustVendStat Engine";
        SubscriptionMgt: Codeunit "EOS008 Subscriptions";
        LinkedEntriesEnabled: Boolean;
        OnlyOpen: Boolean;
        EndingDueDate: Date;
        EndingPostingDate: Date;
        PeriodEndDate: array[10] of Date;
        PeriodStartDate: array[10] of Date;
        StartingDueDate: Date;
        StartingPostingDate: Date;
        PageGroup: Integer;
        ReportLineCount: Integer;
        CompanyNameText: Text;
        HeaderText: array[10] of Text[30];
        AllAmtinLCYCptnLbl: Label 'All Amounts in LCY.';
        DueAtTxt: Label 'Due at %1.';
        DueDateFilterTextMsg: Label 'Due Date Filter:';
        ExposureTxt: Label 'exposure';
        Header001Txt: Label 'Before';
        Header002Txt: Label 'days';
        Header003Txt: Label 'More than';
        NoSalespersonTxt: Label 'Without Salesperson';
        OnlyOpenTextMsg: Label 'Only open entries.';
        PaymentFilterTextMsg: Label 'Payment Filter:';
        PeriodLengthTxt: Label 'Period Leght %1.';
        Placeholders123Lbl: Label '%1 .. %2 %3', Locked = true, Comment = 'no translation';
        Placeholders12Lbl: Label '%1 %2', Locked = true, Comment = 'no translation';
        PostingDateFilterTextMsg: Label 'Posting Date Filter:';
        ReportSortTextMsg: Label 'Sorted By %1 with %2 detail level. %3';
        RunningTotalTxt: Label 'cumulated';
        Text010Err: Label 'The Date Formula %1 cannot be used. Try to restate it. E.g. 1M+CM instead of CM+1M.';
        Text032Txt: Label '-%1';
        VendorFilterTextMsg: Label 'Vendor Filters:';

    local procedure GetMiddle(): Integer;
    begin
        case ColumnLayoutPrmtr of
            ColumnLayoutPrmtr::"0/4":
                exit(2);
            ColumnLayoutPrmtr::"1/3":
                exit(3);
            ColumnLayoutPrmtr::"2/2":
                exit(4);
            ColumnLayoutPrmtr::"3/1":
                exit(5);
            ColumnLayoutPrmtr::"4/0":
                exit(6);
        end;
    end;

    local procedure CalcDates();
    var
        PeriodLength2: DateFormula;
        TempDateFormula: DateFormula;
        DueDateAtMatchEndingPeriod: Boolean;
        i: Integer;
        Middle: Integer;
        MonthTag: Text;
        QuarterTag: Text;
        PeriodLengthPrmtrErr: Label 'You must specify "Period Length" parameter.';
    begin
        if Format(PeriodLengthPrmtr) = '' then
            Error(PeriodLengthPrmtrErr);

        Evaluate(PeriodLength2, StrSubstNo(Text032Txt, PeriodLengthPrmtr));
        Middle := GetMiddle();
        DueDateAtMatchEndingPeriod := CalcDate('<CM>', DueDateAtPrmtr) = DueDateAtPrmtr;
        if DueDateAtMatchEndingPeriod then begin
            Evaluate(TempDateFormula, '<1M>');
            MonthTag := DelChr(Format(TempDateFormula), '<=>', '0123456789');
            Evaluate(TempDateFormula, '<1Q>');
            QuarterTag := DelChr(Format(TempDateFormula), '<=>', '0123456789');
            if not (DelChr(Format(PeriodLengthPrmtr), '<=>', '0123456789') in [MonthTag, QuarterTag]) then
                DueDateAtMatchEndingPeriod := false;
        end;
        //Current Month
        PeriodStartDate[Middle] := DueDateAtPrmtr + 1;
        PeriodEndDate[Middle] := CalcDate(PeriodLengthPrmtr, PeriodStartDate[Middle]) - 1;
        for i := Middle - 1 downto 1 do begin
            PeriodEndDate[i] := PeriodStartDate[i + 1] - 1;
            if DueDateAtMatchEndingPeriod then begin
                PeriodStartDate[i] := CalcDate(PeriodLength2, PeriodEndDate[i]);
                PeriodStartDate[i] := CalcDate('<CM>', PeriodStartDate[i]) + 1;
            end else
                PeriodStartDate[i] := CalcDate(PeriodLength2, PeriodEndDate[i]) + 1;
            if HeadingTypePrmtr = HeadingTypePrmtr::"Date Interval" then
                HeaderText[i] := CopyStr(StrSubstNo(Placeholders12Lbl, PeriodStartDate[i], PeriodEndDate[i]), 1, 30)
            else
                HeaderText[i] := CopyStr(StrSubstNo(Placeholders123Lbl, DueDateAtPrmtr - PeriodStartDate[i] + 1, DueDateAtPrmtr - PeriodEndDate[i] + 1, Header002Txt), 1, 30);
        end;
        for i := Middle to 6 do begin
            PeriodStartDate[i] := PeriodEndDate[i - 1] + 1;
            PeriodEndDate[i] := CalcDate(PeriodLengthPrmtr, PeriodEndDate[i - 1]);
            if DueDateAtMatchEndingPeriod then
                PeriodEndDate[i] := CalcDate('<CM>', PeriodEndDate[i]);
            if HeadingTypePrmtr = HeadingTypePrmtr::"Date Interval" then
                HeaderText[i] := CopyStr(StrSubstNo(Placeholders12Lbl, PeriodStartDate[i], PeriodEndDate[i]), 1, 30)
            else
                HeaderText[i] := CopyStr(StrSubstNo(Placeholders123Lbl, Abs(DueDateAtPrmtr - PeriodStartDate[i] + 1), Abs(DueDateAtPrmtr - PeriodEndDate[i] + 1), Header002Txt), 1, 30);
        end;
        PeriodStartDate[1] := 0D;
        PeriodEndDate[6] := DMY2Date(31, 12, 9999);
        HeaderText[1] := Header001Txt + ' ' + Format(PeriodEndDate[1]);
        HeaderText[6] := Header003Txt + ' ' + Format(PeriodStartDate[6]);
    end;

    local procedure GetPeriodIndex(Date: Date): Integer;
    var
        i: Integer;
    begin
        for i := 1 to ArrayLen(PeriodEndDate) do
            if Date in [PeriodStartDate[i] .. PeriodEndDate[i]] then
                exit(i);
    end;

    local procedure GetReportParametersText() Result: Text;
    var
        Vendor2: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EOSLibraryEXT: Codeunit "EOS Library EXT";
        PeriodLength2: DateFormula;
        DetailText: Text;
    begin
        Vendor2 := VendorFilters;
        if OnlyOpen then
            Vendor2.SetRange("Balance (LCY)");
        Result += StrSubstNo(DueAtTxt, DueDateAtPrmtr);
        if PrintFiltersPrmtr then begin
            Result += StrSubstNo(PeriodLengthTxt, PeriodLength2);
            if Vendor2.GetFilters() <> '' then
                Result += VendorFilterTextMsg + VendorFilters.GetFilters() + EOSLibraryEXT.NewLine();
            if PostingDateFilterPrmtr <> '' then
                Result += PostingDateFilterTextMsg + PostingDateFilterPrmtr + EOSLibraryEXT.NewLine();
            if DueDateFilterPrmtr <> '' then
                Result += DueDateFilterTextMsg + DueDateFilterPrmtr + EOSLibraryEXT.NewLine();
            if PaymentMethodFilterPrmtr <> '' then
                Result += PaymentFilterTextMsg + PaymentMethodFilterPrmtr + EOSLibraryEXT.NewLine();
        end;
        case DetailLevelPrmtr of
            DetailLevelPrmtr::Vendor:
                DetailText := VendorLedgerEntry.FieldCaption("Vendor No.");
            DetailLevelPrmtr::Document:
                DetailText := VendorLedgerEntry.FieldCaption("Document No.");
            DetailLevelPrmtr::Duedates:
                DetailText := VendorLedgerEntry.FieldCaption("Due Date");
        end;
        if PrintAmountInLCYPrmtr then
            Result += StrSubstNo(ReportSortTextMsg, VendorLedgerEntry.FieldCaption("Vendor No."), DetailText, AllAmtinLCYCptnLbl)
        else
            Result += StrSubstNo(ReportSortTextMsg, VendorLedgerEntry.FieldCaption("Vendor No."), DetailText, '');
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

    local procedure GetDueAmount(Index: Integer; CurrencyTotal: Boolean; CumulativeAmounts: Boolean): Decimal;
    var
        Amount: Decimal;
        AmountLCY: Decimal;
        ExposureAmount: Decimal;
    begin
        if (Index = 0) and (CurrencyTotal) and CumulativeAmounts then
            exit(0);

        if Index = 0 then
            exit(GetDueAmount(1, CurrencyTotal, CumulativeAmounts) + GetDueAmount(2, CurrencyTotal, CumulativeAmounts) +
                    GetDueAmount(3, CurrencyTotal, CumulativeAmounts) + GetDueAmount(4, CurrencyTotal, CumulativeAmounts) +
                    GetDueAmount(5, CurrencyTotal, CumulativeAmounts) + GetDueAmount(6, CurrencyTotal, CumulativeAmounts) +
                    GetDueAmount(7, CurrencyTotal, CumulativeAmounts));

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
            Result += ' (' + ExposureTxt + ')';

        if TempCurrencyBuffer."EOS Cumulative Amounts" then
            Result += ' (' + RunningTotalTxt + ')';
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
        if (DetailLevelPrmtr = DetailLevelPrmtr::Vendor) then
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
        if StrPos(CurrencyCode, '#') <> 0 then
            CurrencyCode := CopyStr(CopyStr(CurrencyCode, 1, StrPos(CurrencyCode, '#') - 1), 1, 10);
        if (CurrencyCode = '') then
            exit(GeneralLedgerSetup."LCY Code");
        exit(CurrencyCode);
    end;

    procedure GetVerticalColumn(): Integer;
    begin
        case ColumnLayoutPrmtr of
            ColumnLayoutPrmtr::"0/4":
                exit(2);
            ColumnLayoutPrmtr::"1/3":
                exit(3);
            ColumnLayoutPrmtr::"2/2":
                exit(4);
            ColumnLayoutPrmtr::"3/1":
                exit(5);
            ColumnLayoutPrmtr::"4/0":
                exit(6);
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
        DateFilter := DateTable.GetFilter("Period Start");
    end;

    local procedure UpdateReqPage();
    begin
        LinkedEntriesEnabled := DetailLevelPrmtr = DetailLevelPrmtr::Duedates;
    end;

    local procedure SetReportParameters()
    var
        Parameters: Record "EOS008 CVS Report Parameters";
        AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
    begin
        if (ParametersBuffer."Customer Vendor Table Filter 1" <> '') or (ParametersBuffer."SalesPerson Table Filter 1" <> '') then
            AdvCustVendStatSharedMem.SetReportParameter(ParametersBuffer); //allows more than 1 parameters assignation
        if AdvCustVendStatSharedMem.GetReportParameter(Parameters) then begin
            HeadingTypePrmtr := Parameters."Heading Type";
            DueDateAtPrmtr := Parameters."Aged As Of";
            PeriodLengthPrmtr := Parameters."Period Length";
            PrintAmountInLCYPrmtr := Parameters."Print Amounts in LCY";
            DetailLevelPrmtr := Parameters."Vendor Detail Level";
            ColumnLayoutPrmtr := Parameters."Vendor Column Setup";
            NewPagePerVendorPrmtr := Parameters."New Page Per Vendor";
            UseSalespersonFromVendorPrmtr := Parameters."Use Salesperson from Vendor";
            PrintFiltersPrmtr := Parameters."Print Filters";
            PostingDateFilterPrmtr := Parameters."Posting Date Filter";
            DueDateFilterPrmtr := Parameters."Due Date Filter";
            PaymentMethodFilterPrmtr := Parameters."Payment Method Filter";

            if Parameters."Customer Vendor Table Filter 1" <> '' then begin
                VendorFilters.Reset();
                VendorFilters.SetView(Parameters."Customer Vendor Table Filter 1");
            end;
            if Parameters."SalesPerson Table Filter 1" <> '' then begin
                SalespersonFilters.Reset();
                SalespersonFilters.SetView(Parameters."SalesPerson Table Filter 1");
            end;
            ParametersBuffer := Parameters;
        end;
    end;

    procedure SetOnlyOpenEntries(Set: Boolean);
    begin
        OnlyOpen := Set;
    end;

    procedure SetPeriodLength(Set: DateFormula);
    begin
        PeriodLengthPrmtr := Set;
    end;

    procedure SetDetailByVendor();
    begin
        DetailLevelPrmtr := DetailLevelPrmtr::Vendor;
    end;

    procedure SetDetailByDocument();
    begin
        DetailLevelPrmtr := DetailLevelPrmtr::Document;
    end;

    procedure SetDetailByDueDate();
    begin
        DetailLevelPrmtr := DetailLevelPrmtr::Duedates;
    end;

    procedure SetNewPagePerVendor(Set: Boolean);
    begin
        NewPagePerVendorPrmtr := Set;
    end;

    procedure SetUseVendorSalesperson(Set: Boolean);
    begin
        UseSalespersonFromVendorPrmtr := Set;
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

    procedure GetSelectionFilterForSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(SalespersonPurchaser);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, SalespersonPurchaser.FieldNo(Code)));
        // TO-DO
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildMultiSourceTreeView(SourceView: Text; DateFilterType: enum "EOS008 Date Filter Type";
                                                    StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date;
                                                    OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text;
                                                    OnHoldFilter: Text; var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildReportingDataset(SourceView: Text; DateFilterType: enum "EOS008 Date Filter Type";
                                                    StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date;
                                                    OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text;
                                                    var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT";
                                                    var TempReportingBuffer: Record "EOS AdvCustVend Buffer")
    begin
    end;
}
