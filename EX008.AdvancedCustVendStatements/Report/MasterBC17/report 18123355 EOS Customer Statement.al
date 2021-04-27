report 18123355 "EOS Customer Statement"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/Report/report 18123355 EOS Customer Statement.rdlc';
    Caption = 'Customer Statement (CVS)';
    PreviewMode = PrintLayout;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", Name, "Country/Region Code";

            trigger OnPreDataItem();
            var
            begin
                Customer.SETVIEW(AssetsEngine.CollapsSecurityFiltersToView(Customer));

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
        dataitem(ReportHeaderValues; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));
            column(CompanyName; CompanyInformation.Name) { }
            column(CompanyPicture; CompanyInformation.Picture) { }
            column(CompanyAddress; GetCompanyAddress()) { }
            column(CompanyInfoColumn1; GetCompanyInfoColumn(1)) { }
            column(CompanyInfoColumn2; GetCompanyInfoColumn(2)) { }
            column(CompanyInfoColumn3; GetCompanyInfoColumn(3)) { }
            column(CompanyInfoColumn4; GetCompanyInfoColumn(4)) { }
            column(AtDate; GetAtDate()) { }
            column(DueDateFilter; DueDateFilterPrmtr) { }
        }
        dataitem(DataProcessing; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));

            trigger OnPreDataItem();
            var
                SalespersonFilter: Text;
            begin
                if UseSalespersonFromCustomerPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        Customer.SetFilter("Salesperson Code", SalespersonFilter);
                    end;

                case SortOrderPrmtr of
                    SortOrderPrmtr::CustomerNo:
                        Customer.SetCurrentKey("No.");
                    SortOrderPrmtr::CustomerName:
                        Customer.SetCurrentKey("Name", "Name 2", "No.");
                end;

                AssetsEngine.SetAddPreviousBalance(true);

                AssetsEngine.SetForceCustomerSalesperson(UseSalespersonFromCustomerPrmtr);
                AssetsEngine.BuildMultiSourceTreeView(0, Customer.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempReportingBuffer[1]);

                OnAfterBuildMultiSourceTreeView(Customer.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempReportingBuffer[1]);

                TempReportingBuffer[1].Reset();
                TempReportingBuffer[1].setrange("EOS Document Type", TempReportingBuffer[1]."EOS Document Type"::"Previous Balance");
                TempReportingBuffer[1].DeleteAll();
                TempReportingBuffer[1].Reset();

                if ShowLinkedEntriesPrmtr then begin
                    AssetsEngine.MergeMultipleLevel3Items(TempReportingBuffer[1]);
                    AssetsEngine.MergeL2RemainingAmounts(TempReportingBuffer[1]);
                end;

                if PaymentMethodFilterPrmtr <> '' then begin
                    Clear(TempReportingBuffer);
                    TempReportingBuffer[2].ModifyAll("EOS Selected Node", false);
                    TempReportingBuffer[2].SetRange("EOS Level No.", 2);
                    TempReportingBuffer[2].SetFilter("EOS Payment Method", PaymentMethodFilterPrmtr);
                    if TempReportingBuffer[2].FindSet(true) then
                        repeat
                            TempReportingBuffer[2].SelectUpperLevels();
                            TempReportingBuffer[2].SelectLowerLevels();
                        until TempReportingBuffer[2].Next() = 0;

                    Clear(TempReportingBuffer);
                    TempReportingBuffer[2].SetRange("EOS Selected Node", false);
                    TempReportingBuffer[2].DeleteAll();
                end;

                Clear(TempReportingBuffer);
                TempReportingBuffer[4].ModifyAll("EOS Selected Node", false);
                TempReportingBuffer[4].ModifyAll("EOS Reporting Boolean 1", false);
                TempReportingBuffer[4].ModifyAll("EOS Reporting Boolean 2", false);
                TempReportingBuffer[4].ModifyAll("EOS Reporting Group 1", 0);
                TempReportingBuffer[4].ModifyAll("EOS Reporting Group 2", 0);
                Clear(TempReportingBuffer);

                if not UseSalespersonFromCustomerPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        TempReportingBuffer[2].SetFilter("EOS Salesperson Code", SalespersonFilter);
                    end;

                TempReportingBuffer[2].SetRange("EOS Level No.", 2);
                if TempReportingBuffer[2].FindSet(true) then
                    repeat
                        Clear(TempReportingBuffer[4]);
                        TempReportingBuffer[4].SetRange("EOS Node Linked To", TempReportingBuffer[2]."EOS Node Linked To");
                        if TempReportingBuffer[4].Count() > 1 then begin //ci sono più rate e quindi stampo il totale documento
                            TempReportingBuffer[1].Get(TempReportingBuffer[2]."EOS Node Linked To");
                            if TempReportingBuffer[1]."EOS Level No." <> 0 then begin
                                TempReportingBuffer[1].SelectLowerLevels();
                                TempReportingBuffer[1].SetRange("EOS Selected Node", true);
                                TempReportingBuffer[1].ModifyAll("EOS Reporting Boolean 1", true);
                                TempReportingBuffer[1].ModifyAll("EOS Selected Node", false);
                            end;
                        end;

                        if ShowLinkedEntriesPrmtr then begin
                            Clear(TempReportingBuffer[3]);
                            TempReportingBuffer[3].SetRange("EOS Node Linked To", TempReportingBuffer[2]."EOS Entry No.");
                            if not TempReportingBuffer[3].IsEmpty() then begin
                                ; //ci sono partite collegate quindi stampo il totale della partita
                                TempReportingBuffer[2]."EOS Reporting Boolean 2" := true;
                                TempReportingBuffer[2].Modify();
                                TempReportingBuffer[3].ModifyAll("EOS Reporting Boolean 2", true);
                            end;
                        end;
                    until TempReportingBuffer[2].Next() = 0;

                //definisco il gruppo per "documento" (cioè la partita di livello 1)
                Clear(TempReportingBuffer);
                TempReportingBuffer[1].SetRange("EOS Level No.", 1);
                if TempReportingBuffer[1].FindSet() then
                    repeat
                        TempReportingBuffer[1].SelectLowerLevels();
                        TempReportingBuffer[2].SetRange("EOS Selected Node", true);
                        TempReportingBuffer[2].ModifyAll("EOS Reporting Group 1", TempReportingBuffer[1]."EOS Entry No.");
                        TempReportingBuffer[2].ModifyAll("EOS Selected Node", false);
                    until TempReportingBuffer[1].Next() = 0;

                //definisco il gruppo per "Rata" (cioè la partita di livello 2)
                Clear(TempReportingBuffer);
                TempReportingBuffer[2].SetRange("EOS Level No.", 2);
                if TempReportingBuffer[2].FindSet() then
                    repeat
                        TempReportingBuffer[2].SelectLowerLevels();
                        TempReportingBuffer[3].SetRange("EOS Selected Node", true);
                        TempReportingBuffer[3].ModifyAll("EOS Reporting Group 2", TempReportingBuffer[2]."EOS Entry No.");
                        TempReportingBuffer[3].ModifyAll("EOS Selected Node", false);
                    until TempReportingBuffer[2].Next() = 0;

                Clear(TempReportingBuffer);
                TempReportingBuffer[2].SetRange("EOS Level No.", 2);
                //TempAssetsBuffer[2].SetFilter("Remaining Amount (LCY)", '<>0');
                if TempReportingBuffer[2].FindSet() then
                    repeat
                        Clear(TempReportingBuffer[3]);
                        TempReportingBuffer[3].SetRange("EOS Node Linked To", TempReportingBuffer[2]."EOS Entry No.");
                        TempReportingBuffer[3].SetRange("EOS Document Type", TempReportingBuffer[2]."EOS Document Type"::Payment);
                        TempReportingBuffer[3].SetFilter("EOS Remaining Amount (LCY)", '<>0');
                        if TempReportingBuffer[3].FindFirst() then begin
                            TempReportingBuffer[2]."EOS Due Date" := TempReportingBuffer[3]."EOS Due Date";
                            TempReportingBuffer[2].Modify();
                        end else begin
                            TempReportingBuffer[3].SetRange("EOS Remaining Amount (LCY)");
                            TempReportingBuffer[3].SetFilter("EOS Exposure (LCY)", '<>0');
                            if TempReportingBuffer[3].FindFirst() then begin
                                TempReportingBuffer[2]."EOS Due Date" := TempReportingBuffer[3]."EOS Due Date";
                                TempReportingBuffer[2].Modify();
                            end;
                        end;

                        Clear(TempDueAmountsBuffer);

                        TempDueAmountsBuffer[1].SetRange("EOS Source Type", TempReportingBuffer[2]."EOS Source Type");
                        TempDueAmountsBuffer[1].SetRange("EOS Source No.", TempReportingBuffer[2]."EOS Source No.");
                        TempDueAmountsBuffer[1].SetRange("EOS Payment Method", TempReportingBuffer[2]."EOS Payment Method");
                        TempDueAmountsBuffer[1].SetRange("EOS Due Date", TempReportingBuffer[2]."EOS Due Date");
                        if TempDueAmountsBuffer[1].FindFirst() then begin
                            TempDueAmountsBuffer[1]."EOS Remaining Amount (LCY)" += TempReportingBuffer[2]."EOS Remaining Amount (LCY)" + TempReportingBuffer[2]."EOS Exposure (LCY)";
                            TempDueAmountsBuffer[1].Modify();
                        end else begin
                            TempDueAmountsBuffer[1]."EOS Source Type" := TempReportingBuffer[2]."EOS Source Type";
                            TempDueAmountsBuffer[1]."EOS Source No." := TempReportingBuffer[2]."EOS Source No.";
                            TempDueAmountsBuffer[1]."EOS Payment Method" := TempReportingBuffer[2]."EOS Payment Method";
                            TempDueAmountsBuffer[1]."EOS Due Date" := TempReportingBuffer[2]."EOS Due Date";

                            TempDueAmountsBuffer[1]."EOS Entry No." := TempReportingBuffer[2]."EOS Entry No.";
                            TempDueAmountsBuffer[1]."EOS Remaining Amount (LCY)" := TempReportingBuffer[2]."EOS Remaining Amount (LCY)" + TempReportingBuffer[2]."EOS Exposure (LCY)";
                            TempDueAmountsBuffer[1]."EOS Language Code" := TempReportingBuffer[2]."EOS Language Code";
                            TempDueAmountsBuffer[1].Insert();
                        end;
                    until TempReportingBuffer[2].Next() = 0;

                Clear(TempReportingBuffer);
                Clear(TempDueAmountsBuffer);

                OnAfterBuildReportingDataset(Customer.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                             StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '',
                                             TempReportingBuffer[1])
            end;
        }
        dataitem(CustomerPrint; Customer)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            column(CustomerAddress; GetCustomerAddress()) { }
            column(CustomerSalespersonCode; GetCustomerSalesPersonCode()) { }
            column(CustomerSalespersonName; GetCustomerSalesPersonName()) { }
            column(CustomerPaymentMethod; GetCustomerPaymentMethod()) { }
            column(CustomerPaymentTerms; GetCustomerPaymentTerms()) { }
            column(CustomerPhone; GetCustomerPhone()) { }
            column(CustomerNo; "No.") { }
            dataitem(Detail; Integer)
            {
                DataItemTableView = sorting(Number)
                                    where(Number = filter(1 ..));
                column(AssetNo; TempReportingBuffer[1]."EOS Asset No.") { }
                column(ShowDocumentTotal; TempReportingBuffer[1]."EOS Reporting Boolean 1") { }
                column(ShowAssetTotal; TempReportingBuffer[1]."EOS Reporting Boolean 2") { }
                column(DocumentGroup; TempReportingBuffer[1]."EOS Reporting Group 1") { }
                column(AssetGroup; TempReportingBuffer[1]."EOS Reporting Group 2") { }
                column(DocumentGroupDate; TempReportingBuffer[1]."EOS Posting Date 1") { }
                column(LineType; GetLineType()) { }
                column(PostingDate; Format(TempReportingBuffer[1]."EOS Posting Date")) { }
                column(DocumentType; GetDocumentTypeAbbreviation(TempReportingBuffer[1]."EOS Document Type")) { }
                column(DocumentNo; TempReportingBuffer[1]."EOS Document No.") { }
                column(Description; TempReportingBuffer[1]."EOS Description") { }
                column(DocumentDate; Format(TempReportingBuffer[1]."EOS Document Date")) { }
                column(PaymentMethod; GetPaymentMethod(TempReportingBuffer[1]."EOS Language Code")) { }
                column(DueDate; Format(TempReportingBuffer[1]."EOS Due Date")) { }
                column(AmountLCY; GetAmountLCY(TempReportingBuffer[1]))
                {
                    DecimalPlaces = 2 : 2;
                }
                column(RemainingAmountLCY; GetRemainingAmountLCY(TempReportingBuffer[1]))
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ExposureLCY; TempReportingBuffer[1]."EOS Exposure (LCY)")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(BankReceiptNo; GetBackReceiptNo()) { }
                column(CustomBoolean1; TempReportingBuffer[1]."EOS Custom Boolean 1") { }
                column(CustomBoolean2; TempReportingBuffer[1]."EOS Custom Boolean 2") { }
                column(CustomDate1; Format(TempReportingBuffer[1]."EOS Custom Date 1")) { }
                column(CustomDate2; Format(TempReportingBuffer[1]."EOS Custom Date 2")) { }
                column(CustomText1; TempReportingBuffer[1]."EOS Custom Text 1") { }
                column(CustomText2; TempReportingBuffer[1]."EOS Custom Text 2") { }
                trigger OnAfterGetRecord();
                begin
                    if Number > 1 then
                        if TempReportingBuffer[1].Next() = 0 then
                            CurrReport.BREAK();

                    DetailLoopNo += 1;
                end;

                trigger OnPreDataItem();
                begin
                    Clear(TempReportingBuffer);
                    TempReportingBuffer[1].SetRange("EOS Source Type", TempReportingBuffer[1]."EOS Source Type"::Customer);
                    TempReportingBuffer[1].SetRange("EOS Source No.", CustomerPrint."No.");
                    TempReportingBuffer[1].SetCurrentKey("EOS Entry No.");
                    if ShowLinkedEntriesPrmtr then
                        TempReportingBuffer[1].SetRange("EOS Level No.", 2, 4)
                    else
                        TempReportingBuffer[1].SetRange("EOS Level No.", 2, 2);

                    if not TempReportingBuffer[1].Find('-') then
                        CurrReport.BREAK();
                end;
            }
            dataitem(DueDetail; Integer)
            {
                DataItemTableView = sorting(Number)
                                    where(Number = filter(1 ..));
                column(DueDetailDate; Format(TempDueAmountsBuffer[1]."EOS Due Date")) { }
                column(DueDetailPaymentMethod; AdvCustVendStatRoutines.GetPaymentMethodDescription(TempDueAmountsBuffer[1]."EOS Payment Method", TempDueAmountsBuffer[1]."EOS Language Code")) { }
                column(DueDetailRemainingAmountLCY; TempDueAmountsBuffer[1]."EOS Remaining Amount (LCY)")
                {
                    DecimalPlaces = 2 : 2;
                }

                trigger OnAfterGetRecord();
                begin
                    if Number > 1 then
                        if TempDueAmountsBuffer[1].Next() = 0 then
                            CurrReport.BREAK();

                    if Round(TempDueAmountsBuffer[1]."EOS Remaining Amount (LCY)") = 0 then
                        CurrReport.Skip();

                    DetailLoopNo += 1;
                end;

                trigger OnPreDataItem();
                begin
                    TempDueAmountsBuffer[1].SetCurrentKey("EOS Reporting Group 1", "EOS Due Date");
                    TempDueAmountsBuffer[1].SetRange("EOS Source Type", TempReportingBuffer[1]."EOS Source Type"::Customer);
                    TempDueAmountsBuffer[1].SetRange("EOS Source No.", CustomerPrint."No.");
                    if not TempDueAmountsBuffer[1].Find('-') then
                        CurrReport.BREAK();
                end;
            }

            trigger OnAfterGetRecord();
            var
            begin
                DetailLoopNo := 0;
            end;

            trigger OnPreDataItem();
            var
            begin
                CopyFilterS(Customer);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(OnlyOpen; OnlyOpenPrmtr)
                {
                    Caption = 'Only Open Entries';
                    ApplicationArea = all;
                }
                // field(SortOrder; SortOrderPrmtr)
                // {
                //     Caption = 'Sort Order';
                //     OptionCaption = 'Customer No.,Customer Name';
                //     ApplicationArea = All;
                // }
                field(ShowLinkedEntries; ShowLinkedEntriesPrmtr)
                {
                    Caption = 'Show Linked Entries';
                    ApplicationArea = all;
                }
                field(PostingDateFilter; PostingDateFilterPrmtr)
                {
                    Caption = 'Posting Date Filter';
                    ApplicationArea = all;

                    trigger OnValidate();
                    var
                        AdvCustVendStatRoutines: Codeunit "EOS AdvCustVendStat Routines";
                    begin
                        AdvCustVendStatRoutines.ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
                        RequestOptionsPage.Update(false);
                    end;
                }
                field(DueDateFilter; DueDateFilterPrmtr)
                {
                    Caption = 'Due Date Filter';
                    ApplicationArea = all;

                    trigger OnValidate();
                    var
                        AdvCustVendStatRoutines: Codeunit "EOS AdvCustVendStat Routines";
                    begin
                        AdvCustVendStatRoutines.ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);
                        RequestOptionsPage.Update(false);
                    end;
                }
                field(PaymentMethodFilter; PaymentMethodFilterPrmtr)
                {
                    Caption = 'Payment Method Filter';
                    TableRelation = "Payment Method";
                    ApplicationArea = all;
                }
                field(UseSalespersonFromCustomer; UseSalespersonFromCustomerPrmtr)
                {
                    Caption = 'Use Salesperson from Customer';
                    ApplicationArea = all;
                }
                group("Output Options")
                {
                    Caption = 'Output Options';
                    Visible = false;
                    //Enabled = SubscriptionActiv;
                    field(ReportOutput; SupportedOutputMethod)
                    {
                        Caption = 'Report Output';
                        OptionCaption = 'Print,Preview';
                        //'Each item is a verb/action - to print, to preview, to export to Word, export to PDF, send email, export to XML for RDLC layouts only
                        Visible = false;
                        ApplicationArea = all;

                        trigger OnValidate();
                        var
                            CustomLayoutReporting: Codeunit "Custom Layout Reporting";
                        begin
                            case SupportedOutputMethod of
                                SupportedOutputMethod::Print:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPrintOption();
                                SupportedOutputMethod::Preview:
                                    ChosenOutputMethod := CustomLayoutReporting.GetPreviewOption();
                            end;
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        var
            Parameters: Record "EOS008 CVS Report Parameters";
            AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
        begin
            CurrReport.RequestOptionsPage.Caption := CurrReport.RequestOptionsPage.Caption() + SubscriptionMgt.GetLicenseText();

            if AdvCustVendStatSharedMem.GetReportParameter(Parameters) then begin
                OnlyOpenPrmtr := Parameters."Only Open";
                ShowLinkedEntriesPrmtr := Parameters."Show Linked Entries";
                UseSalespersonFromCustomerPrmtr := Parameters."Use Salesperson from Customer";
                PostingDateFilterPrmtr := Parameters."Posting Date Filter";
                DueDateFilterPrmtr := Parameters."Due Date Filter";
                PaymentMethodFilterPrmtr := Parameters."Payment Method Filter";

                if Parameters."Customer Vendor Table Filter 1" <> '' then begin
                    Customer.Reset();
                    Customer.SetView(Parameters."Customer Vendor Table Filter 1");
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
        ReportTitle = 'Customer Account Statement at';
        CustomerNoLabel = 'Customer';
        SalesPersonLabel = 'Salesperson';
        CustomerNameLabel = 'Name';
        CustomerPhoneLabel = 'Phone';
        DescriptionLabel = 'Description';
        PostingDateLabel = 'Posting Date';
        DueDateLabel = 'Due Date';
        AssetTotalLabel = 'Total';
        DocumentTotalLabel = 'Document Total';
        CustomerTotalLabel = 'Customer Total';
        PageNoLabel = 'Page';
        DocumentTypeLabel = 'Type';
        DocumentNoLabel = 'Document';
        DocumentDateLabel = 'Doc. Date';
        ExternalDocumentNo = 'External Document No.';
        PaymentMethodLabel = 'Payment Method Code';
        PaymentTermsLabel = 'Payment Terms Code';
        RemainingAmountLCYLabel = 'Remaining Amt. (LCY)';
        RemainingAmountLabel = 'Remaining Amount';
        AmountLCYLabel = 'Amount (LCY)';
        AmountLabel = 'Amount';
        CurrencyCodeLabel = 'Curr';
        BankReceiptStatusLabel = 'Bank Receipt';
        TotalAmountLabel = 'Total Report Amount';
        ExposureLabel = 'Exposure (LCY)';
        WithExposureLabel = 'with exposure';
        DueDateSummaryLabel = 'Due by date summary';
    }

    trigger OnInitReport();
    var
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
    begin
        OnlyOpenPrmtr := false;
        ShowLinkedEntriesPrmtr := true;
        UseSalespersonFromCustomerPrmtr := true;

        ChosenOutputMethod := CustomLayoutReporting.GetPreviewOption();

        SubscriptionActive := SubscriptionMgt.GetSubscriptionIsActive();

    end;

    trigger OnPreReport();
    begin
        if not SubscriptionActive then
            Currreport.quit();

        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        AdvCustVendStatRoutines.ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
        AdvCustVendStatRoutines.ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);
    end;

    var
        CompanyInformation: Record "Company Information";
        TempDueAmountsBuffer: array[4] of Record "EOS Statem. Assets Buffer EXT" temporary;
        TempReportingBuffer: array[4] of Record "EOS Statem. Assets Buffer EXT" temporary;
        AdvCustVendStatRoutines: Codeunit "EOS AdvCustVendStat Routines";
        AssetsEngine: Codeunit "EOS AdvCustVendStat Engine";
        SubscriptionMgt: Codeunit "EOS AdvCustVendStat Subscript";
        OnlyOpenPrmtr: Boolean;
        ShowLinkedEntriesPrmtr: Boolean;
        SubscriptionActive: Boolean;
        UseSalespersonFromCustomerPrmtr: Boolean;
        EndingDueDate: Date;
        EndingPostingDate: Date;
        StartingDueDate: Date;
        StartingPostingDate: Date;
        ChosenOutputMethod: Integer;
        [InDataSet]
        DetailLoopNo: Integer;
        SortOrderPrmtr: Option CustomerNo,CustomerName;
        SupportedOutputMethod: Option Print,Preview;
        CustomerAddress: array[11] of Text[100];
        DueDateFilterPrmtr: Text;
        PaymentMethodFilterPrmtr: Text;
        PostingDateFilterPrmtr: Text;


    local procedure GetBufferGroup(var BufferAssets: Record "EOS Statem. Assets Buffer EXT" temporary): Text;
    begin
        exit(BufferAssets."EOS Source No.");
    end;

    local procedure GetCompanyInfoColumn(ColumnNo: Integer): Text;
    var
        EOSLibraryEXT: Codeunit "EOS Library EXT";
    begin
        case ColumnNo of
            1:

                exit('Tel.' + EOSLibraryEXT.NewLine() +
                      'Fax.' + EOSLibraryEXT.NewLine() +
                      'P.Iva' + EOSLibraryEXT.NewLine() +
                      'C.F.');

            2:

                exit(CompanyInformation."Phone No." + EOSLibraryEXT.NewLine() +
                      CompanyInformation."Fax No." + EOSLibraryEXT.NewLine() +
                      CompanyInformation."VAT Registration No." + EOSLibraryEXT.NewLine() +
                      CompanyInformation."Fiscal Code");

            3:

                exit('E-Mail:' + EOSLibraryEXT.NewLine() +
                      'Web:' + EOSLibraryEXT.NewLine() +
                      'R.E.A.');

            4:

                exit(CompanyInformation."E-Mail" + EOSLibraryEXT.NewLine() +
                      CompanyInformation."Home Page" + EOSLibraryEXT.NewLine() +
                      CompanyInformation."REA No.");

        end
    end;

    local procedure GetAtDate(): Text;
    var
        EndingPostingDate2: Date;
        StartingPostingDate2: Date;
    begin
        if PostingDateFilterPrmtr = '' then
            exit(Format(TODAY()));

        AdvCustVendStatRoutines.ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate2, EndingPostingDate2);
        if EndingPostingDate2 <> DMY2Date(31, 12, 9999) then
            exit(Format(EndingPostingDate2));

        exit(Format(TODAY()));
    end;

    local procedure GetDocumentTypeAbbreviation(DocumentType: Integer): Text;
    var
        AbreviationsLbl: Label ' ,Pmt,Inv,CrM,FinChrge,Rem,Ref,,,,Dish,,,,,PrevBal.';
    begin
        exit(CopyStr(SelectStr(DocumentType + 1, Format(AbreviationsLbl)), 1, 4));
    end;

    local procedure GetAmount(AssetsBuffer: Record "EOS Statem. Assets Buffer EXT"): Text;
    begin
        //Se sto mostrando la contropartita allora gli importi sono quelli complessivi e non il residuo
        if not ShowLinkedEntriesPrmtr then
            exit(Format(AssetsBuffer."EOS Remaining Amount"))
        else
            case AssetsBuffer."EOS Level No." of
                2:
                    exit(Format(AssetsBuffer."EOS Original Amount"));
                3, 4:
                    exit(Format(AssetsBuffer."EOS Applied Amount"));
            end;
    end;

    local procedure GetAmountLCY(AssetsBuffer: Record "EOS Statem. Assets Buffer EXT"): Decimal;
    begin
        //Se sto mostrando la contropartita allora gli importi sono quelli complessivi e non il residuo
        if not ShowLinkedEntriesPrmtr then
            exit(TempReportingBuffer[1]."EOS Remaining Amount (LCY)")
        else
            case AssetsBuffer."EOS Level No." of
                2:
                    exit(AssetsBuffer."EOS Original Amount (LCY)");
                3, 4:
                    exit(AssetsBuffer."EOS Applied Amount (LCY)");
            end;
    end;

    // local procedure GetRemainingAmount(AssetsBuffer: Record "EOS Statem. Assets Buffer EXT"): Decimal;
    // begin
    //     exit(AssetsBuffer."EOS Remaining Amount");
    // end;

    local procedure GetRemainingAmountLCY(AssetsBuffer: Record "EOS Statem. Assets Buffer EXT"): Decimal;
    begin
        exit(AssetsBuffer."EOS Remaining Amount (LCY)");
    end;

    local procedure GetPaymentMethod(LanguageCode: Code[10]) Result: Text;
    begin
        Result := AdvCustVendStatRoutines.GetPaymentMethodDescription(TempReportingBuffer[1]."EOS Payment Method", LanguageCode);
        if TempReportingBuffer[1]."EOS Dishonored Entry No." <> 0 then
            Result := '*' + Result;
    end;

    local procedure GetAddressString(var AddrArray: array[8] of Text[50]): Text;
    var
        EOSLibraryEXT: Codeunit "EOS Library EXT";
        i: Integer;
        ResText: Text;
    begin
        for i := 1 to ARRAYLEN(AddrArray) do
            if AddrArray[i] <> '' then
                if ResText = '' then
                    ResText := AddrArray[i]
                else
                    ResText := ResText + EOSLibraryEXT.NewLine() + AddrArray[i];
        exit(ResText);
    end;

    local procedure GetCompanyAddress() Result: Text;
    var
        EOSLibraryEXT: Codeunit "EOS Library EXT";
    begin
        Result := CompanyInformation.Address + EOSLibraryEXT.NewLine();
        if (CompanyInformation."Address 2" <> '') then
            Result += CompanyInformation."Address 2" + EOSLibraryEXT.NewLine();

        Result += CompanyInformation."Post Code" + ' ' + CompanyInformation.City + ' (' + CompanyInformation.County + ') ' +
                  CompanyInformation."Country/Region Code";
    end;

    local procedure GetCustomerAddress(): Text;
    var
        FormatAddress: Codeunit "Format Address";
    begin
        if DetailLoopNo > 1 then
            exit('');

        FormatAddress.Customer(CustomerAddress, CustomerPrint);
        exit(GetAddressString(CustomerAddress));
    end;

    local procedure GetCustomerSalesPersonCode(): Text;
    begin
        if DetailLoopNo > 1 then
            exit('');

        exit(CustomerPrint."Salesperson Code");
    end;

    local procedure GetCustomerSalesPersonName(): Text;
    var
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        if DetailLoopNo > 1 then
            exit('');

        Clear(SalesPerson);
        if CustomerPrint."Salesperson Code" <> '' then
            if SalesPerson.Get(CustomerPrint."Salesperson Code") then
                exit(SalesPerson.Name);
    end;

    local procedure GetCustomerPaymentMethod(): Text;
    begin
        if DetailLoopNo > 1 then
            exit('');

        AdvCustVendStatRoutines.GetPaymentMethodDescription(CustomerPrint."Payment Method Code", CustomerPrint."Language Code");
    end;

    local procedure GetCustomerPaymentTerms(): Text;
    begin
        if DetailLoopNo > 1 then
            exit('');

        exit(CustomerPrint."Payment Terms Code");
    end;

    local procedure GetCustomerPhone(): Text;
    begin
        exit(CustomerPrint."Phone No.");
    end;

    local procedure GetBackReceiptNo(): Text;
    begin
        exit(TempReportingBuffer[1]."EOS Customer Bill No.");
    end;

    local procedure GetLineType(): Text;
    begin
        if TempReportingBuffer[1]."EOS Document Type" <> TempReportingBuffer[1]."EOS Document Type"::"Previous Balance" then
            exit('DETAIL')
        else
            exit('PREVBAL');
    end;

    procedure SetOnlyOpenEntries(Set: Boolean);
    begin
        OnlyOpenPrmtr := Set;
    end;

    procedure SetShowLinkedEntries(Set: Boolean);
    begin
        ShowLinkedEntriesPrmtr := Set;
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

    procedure GetSelectionFilterForSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser"): Text
    var
        SelectionFilterManagement: Codeunit "SelectionFilterManagement";
        RecRef: RecordRef;
    begin
        RecRef.GETTABLE(SalespersonPurchaser);
        exit(SelectionFilterManagement.GetSelectionFilter(RecRef, SalespersonPurchaser.FIELDNO(Code)));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildMultiSourceTreeView(SourceView: Text; DateFilterType: Option "Posting Date","Document Date"; StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date; OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text; var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildReportingDataset(SourceView: Text; DateFilterType: Option "Posting Date","Document Date"; StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date; OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text; var TempReportingBuffer: Record "EOS Statem. Assets Buffer EXT")
    begin
    end;
}

