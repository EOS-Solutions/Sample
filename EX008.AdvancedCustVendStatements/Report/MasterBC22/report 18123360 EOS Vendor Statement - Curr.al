report 18123360 "EOS Vendor Statement - Curr."
{

    DefaultLayout = RDLC;
    RDLCLayout = './source/Report/report 18123360 EOS Vendor Statement - Curr.rdlc';
    Caption = 'Vendor Statement - Currency (CVS)';
    PreviewMode = PrintLayout;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", Name, "Country/Region Code";

            trigger OnPreDataItem();
            begin
                Vendor.SETVIEW(AssetsEngine.CollapsSecurityFiltersToView(Vendor));

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
        // dataitem(ReportHeaderValues; Integer)
        // {
        //     DataItemTableView = sorting(Number)
        //                         where(Number = const(1));
        //     column(CompanyName; CompanyInformation.Name) { }
        //     column(CompanyPicture; CompanyInformation.Picture) { }
        //     column(CompanyAddress; GetCompanyAddress()) { }
        //     column(CompanyInfoColumn1; GetCompanyInfoColumn(1)) { }
        //     column(CompanyInfoColumn2; GetCompanyInfoColumn(2)) { }
        //     column(CompanyInfoColumn3; GetCompanyInfoColumn(3)) { }
        //     column(CompanyInfoColumn4; GetCompanyInfoColumn(4)) { }
        //     column(AtDate; GetAtDate()) { }
        //     column(DueDateFilter; DueDateFilterPrmtr) { }
        // }
        dataitem(DataProcessing; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));

            trigger OnPreDataItem();
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
                SalespersonFilter: Text;
            begin
                if UseSalespersonFromVendorPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        Vendor.SetFilter("Purchaser Code", SalespersonFilter);
                    end;

                case SortOrderPrmtr of
                    SortOrderPrmtr::VendorNo:
                        Vendor.SetCurrentKey("No.");
                    SortOrderPrmtr::VendorName:
                        Vendor.SetCurrentKey("Name", "Name 2", "No.");
                end;

                AssetsEngine.SetAddPreviousBalance(true);

                AssetsEngine.SetForceCustomerSalesperson(UseSalespersonFromVendorPrmtr);
                AssetsEngine.BuildMultiSourceTreeView(1, Vendor.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempReportingBuffer[1]);

                OnAfterBuildMultiSourceTreeView(Vendor.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempReportingBuffer[1]);

                TempReportingBuffer[1].Reset();
                TempReportingBuffer[1].setrange("EOS Document Type", TempReportingBuffer[1]."EOS Document Type"::"Previous Balance");
                TempReportingBuffer[1].DeleteAll();
                TempReportingBuffer[1].Reset();

                AssetsEngine.ReverseSigns(TempReportingBuffer[1]); //Amount Reversed for Vendors

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

                if not UseSalespersonFromVendorPrmtr then
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
                            TempDueAmountsBuffer[1]."EOS Remaining Amount" += TempReportingBuffer[2]."EOS Remaining Amount";
                            TempDueAmountsBuffer[1].Modify();
                        end else begin
                            TempDueAmountsBuffer[1]."EOS Source Type" := TempReportingBuffer[2]."EOS Source Type";
                            TempDueAmountsBuffer[1]."EOS Source No." := TempReportingBuffer[2]."EOS Source No.";
                            if TempReportingBuffer[2]."EOS Currency Code" <> '' then
                                TempDueAmountsBuffer[1]."EOS Currency Code" := TempReportingBuffer[2]."EOS Currency Code"
                            else
                                if GeneralLedgerSetup.Get() then
                                    TempDueAmountsBuffer[1]."EOS Currency Code" := GeneralLedgerSetup."LCY Code";
                            TempDueAmountsBuffer[1]."EOS Payment Method" := TempReportingBuffer[2]."EOS Payment Method";
                            TempDueAmountsBuffer[1]."EOS Due Date" := TempReportingBuffer[2]."EOS Due Date";

                            TempDueAmountsBuffer[1]."EOS Entry No." := TempReportingBuffer[2]."EOS Entry No.";
                            TempDueAmountsBuffer[1]."EOS Remaining Amount (LCY)" := TempReportingBuffer[2]."EOS Remaining Amount (LCY)" + TempReportingBuffer[2]."EOS Exposure (LCY)";
                            TempDueAmountsBuffer[1]."EOS Remaining Amount" := TempReportingBuffer[2]."EOS Remaining Amount";
                            TempDueAmountsBuffer[1]."EOS Language Code" := TempReportingBuffer[2]."EOS Language Code";
                            TempDueAmountsBuffer[1].Insert();
                        end;
                    until TempReportingBuffer[2].Next() = 0;

                Clear(TempReportingBuffer);
                Clear(TempDueAmountsBuffer);

                OnAfterBuildReportingDataset(Vendor.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                             StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '',
                                             TempReportingBuffer[1])
            end;
        }
        dataitem(VendorPrint; Vendor)
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            column(VendorAddress; GetVendorAddress()) { }
            column(VendorSalespersonCode; GetVendorSalesPersonCode()) { }
            column(VendorSalespersonName; GetCVendorSalesPersonName()) { }
            column(VendorPaymentMethod; GetVendorPaymentMethod()) { }
            column(VendorPaymentTerms; GetVendorPaymentTerms()) { }
            column(VendorPhone; GetVendorPhone()) { }
            column(VendorNo; "No.") { }


            column(CompanyName; CompanyNameText) { }
            column(CompanyPicture; CompanyInformation.Picture) { }
            column(CompanyAddress; GetCompanyAddress()) { }
            column(CompanyInfoColumn1; GetCompanyInfoColumn(1)) { }
            column(CompanyInfoColumn2; GetCompanyInfoColumn(2)) { }
            column(CompanyInfoColumn3; GetCompanyInfoColumn(3)) { }
            column(CompanyInfoColumn4; GetCompanyInfoColumn(4)) { }
            column(AtDate; GetAtDate()) { }
            column(DueDateFilter; DueDateFilterPrmtr) { }

            column(ReportTitleTxt; ReportTitleLbl) { }
            column(PageNoLabelTxt; PageNoLbl) { }

            column(VendorNoLabelTxt; VendorNoLbl) { }
            column(SalesPersonLabelTxt; SalesPersonLbl) { }
            column(VendorNameLabelTxt; VendorNameLbl) { }
            column(VendorPhoneLabelTxt; VendorPhoneLbl) { }
            column(DescriptionLabelTxt; DescriptionLbl) { }
            column(PostingDateLabelTxt; PostingDateLbl) { }
            column(DueDateLabelTxt; DueDateLbl) { }
            column(AssetTotalLabelTxt; AssetTotalLbl) { }
            column(DocumentTotalLabelTxt; DocumentTotalLbl) { }
            column(VendorTotalLabelTxt; VendorTotalLbl) { }
            column(DocumentTypeLabelTxt; DocumentTypeLbl) { }
            column(DocumentNoLabelTxt; DocumentNoLbl) { }
            column(DocumentDateLabelTxt; DocumentDateLbl) { }
            column(ExternalDocumentNoTxt; ExternalDocumentNoLbl) { }
            column(PaymentMethodLabelTxt; PaymentMethodLbl) { }
            column(PaymentTermsLabelTxt; PaymentTermsLbl) { }
            column(RemainingAmountLCYLabelTxt; RemainingAmountLCYLbl) { }
            column(RemainingAmountLabelTxt; RemainingAmountLbl) { }
            column(AmountLCYLabelTxt; AmountLCYLbl) { }
            column(AmountLabelTxt; AmountLbl) { }
            column(CurrencyCodeLabelTxt; CurrencyCodeLbl) { }
            column(BankReceiptStatusLabelTxt; BankReceiptStatusLbl) { }
            column(TotalAmountLabelTxt; TotalAmountLbl) { }
            column(ExposureLabelTxt; ExposureLbl) { }
            column(WithExposureLabelTxt; WithExposureLbl) { }
            column(DueDateSummaryLabelTxt; DueDateSummaryLbl) { }
            // column(AmountByCurrencyLabelTxt; AmountByCurrencyLbl) { }
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
                column(Amount; GetAmount(TempReportingBuffer[1]))
                {
                    DecimalPlaces = 2 : 2;
                }
                column(RemainingAmountLCY; GetRemainingAmountLCY(TempReportingBuffer[1]))
                {
                    DecimalPlaces = 2 : 2;
                }
                column(RemainingAmount; GetRemainingAmount(TempReportingBuffer[1]))
                {
                    DecimalPlaces = 2 : 2;
                }
                column(ExternalDocumentNo; TempReportingBuffer[1]."EOS External Document No.") { }
                column(ExposureLCY; TempReportingBuffer[1]."EOS Exposure (LCY)")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(BankReceiptNo; GetBackReceiptNo()) { }
                column(CurrencyCode; GetCurrencyCodeNo()) { }
                // column(PrintStatementinDocumentCurrency; PrintStatementCurrencyfromDocumentCurrencyPrmtr) { }
                column(CustomBoolean1; TempReportingBuffer[1]."EOS Custom Boolean 1") { }
                column(CustomBoolean2; TempReportingBuffer[1]."EOS Custom Boolean 2") { }
                column(CustomDate1; Format(TempReportingBuffer[1]."EOS Custom Date 1")) { }
                column(CustomDate2; Format(TempReportingBuffer[1]."EOS Custom Date 2")) { }
                column(CustomText1; TempReportingBuffer[1]."EOS Custom Text 1") { }
                column(CustomText2; TempReportingBuffer[1]."EOS Custom Text 2") { }

                trigger OnPreDataItem();
                begin
                    Clear(TempReportingBuffer);
                    TempReportingBuffer[1].SetRange("EOS Source Type", TempReportingBuffer[1]."EOS Source Type"::Vendor);
                    TempReportingBuffer[1].SetRange("EOS Source No.", VendorPrint."No.");
                    TempReportingBuffer[1].SetCurrentKey("EOS Entry No.");
                    if ShowLinkedEntriesPrmtr then
                        TempReportingBuffer[1].SetRange("EOS Level No.", 2, 4)
                    else
                        TempReportingBuffer[1].SetRange("EOS Level No.", 2, 2);

                    if not TempReportingBuffer[1].Find('-') then
                        CurrReport.BREAK();
                end;

                trigger OnAfterGetRecord();
                begin
                    if Number > 1 then
                        if TempReportingBuffer[1].Next() = 0 then
                            CurrReport.BREAK();

                    DetailLoopNo += 1;
                end;
            }
            // dataitem(DueDetail; Integer)
            // {
            //     DataItemTableView = sorting(Number)
            //                         where(Number = filter(1 ..));
            //     column(DueDetailDate; Format(TempDueAmountsBuffer[1]."EOS Due Date")) { }
            //     column(DueDetailPaymentMethod; AdvCustVendStatRoutines.GetPaymentMethodDescription(TempDueAmountsBuffer[1]."EOS Payment Method", TempDueAmountsBuffer[1]."EOS Language Code")) { }
            //     column(DueDetailRemainingAmountLCY; TempDueAmountsBuffer[1]."EOS Remaining Amount (LCY)")
            //     {
            //         DecimalPlaces = 2 : 2;
            //     }

            //     trigger OnAfterGetRecord();
            //     begin
            //         if Number > 1 then
            //             if TempDueAmountsBuffer[1].Next() = 0 then
            //                 CurrReport.BREAK();

            //         if Round(TempDueAmountsBuffer[1]."EOS Remaining Amount (LCY)") = 0 then
            //             CurrReport.Skip();

            //         DetailLoopNo += 1;
            //     end;

            //     trigger OnPreDataItem();
            //     begin
            //         TempDueAmountsBuffer[1].SetCurrentKey("EOS Reporting Group 1", "EOS Due Date");
            //         TempDueAmountsBuffer[1].SetRange("EOS Source Type", TempReportingBuffer[1]."EOS Source Type"::Vendor);
            //         TempDueAmountsBuffer[1].SetRange("EOS Source No.", VendorPrint."No.");
            //         if not TempDueAmountsBuffer[1].Find('-') then
            //             CurrReport.BREAK();
            //     end;
            // }

            trigger OnPreDataItem();
            begin
                CopyFilterS(Vendor);
            end;

            trigger OnAfterGetRecord();
            var
                Language: Codeunit Language;
            begin
                //if VendorCounter > 1 then
                //    Clear(CompanyInformation.Picture);
                //VendorCounter += 1;

                DetailLoopNo := 0;
                CurrReport.Language := Language.GetLanguageIdOrDefault(VendorPrint."Language Code");
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
                field(OnlyOpen; OnlyOpenPrmtr)
                {
                    Caption = 'Only Open Entries';
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the "Only Open Entries" field.';
                }
                // field(SortOrder; SortOrderPrmtr)
                // {
                //     Caption = 'Sort Order';
                //     OptionCaption = 'Vendor No.,Vendor Name';
                //     ApplicationArea = All;
                // }
                field(ShowLinkedEntries; ShowLinkedEntriesPrmtr)
                {
                    Caption = 'Show Linked Entries';
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the "Show Linked Entries" field.';
                }
                field(PostingDateFilter; PostingDateFilterPrmtr)
                {
                    Caption = 'Posting Date Filter';
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the "Posting Date Filter" field.';
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
                    ToolTip = 'Specifies the value of the "Due Date Filter" field.';
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
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the "Payment Method Filter" field.';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PaymentMethod: Record "Payment Method";
                    begin
                        if Page.RunModal(Page::"Payment Methods", PaymentMethod) = Action::LookupOK then
                            PaymentMethodFilterPrmtr := PaymentMethod.Code;
                    end;
                }
                field(UseSalespersonFromVendor; UseSalespersonFromVendorPrmtr)
                {
                    Caption = 'Use Salesperson from Vendor';
                    ApplicationArea = all;
                    ToolTip = 'Specifies the value of the "Use Salesperson from Vendor" field.';
                }
                field(PrintStatementCurrencyfromDocumentCurrency; PrintStatementCurrencyfromDocumentCurrencyPrmtr)
                {
                    Caption = 'Print using the Currency from the Document';
                    ToolTip = 'Payment Method column will be replaced by Remaining Amount.';
                    ApplicationArea = all;
                    Visible = false;
                    Enabled = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Field was deprecated because the currency feature was removed from the "Customer Statement" report and the current report was made using it, the field is therefore not necessary because the report will always print using the currency feature.';
                    ObsoleteTag = '20';
                }
                group("Output Options")
                {
                    Caption = 'Output Options';
                    Visible = false;
                    field(ReportOutput; SupportedOutputMethod)
                    {
                        Caption = 'Report Output';
                        OptionCaption = 'Print,Preview';
                        //'Each item is a verb/action - to print, to preview, to export to Word, export to PDF, send email, export to XML for RDLC layouts only
                        Visible = false;
                        ApplicationArea = all;
                        ToolTip = 'Specifies the value of the "Report Output" field.';
                        ObsoleteReason = 'This is no longer supported.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '21.0';
                        // trigger OnValidate();
                        // var
                        //     CustomLayoutReporting: Codeunit "Custom Layout Reporting";
                        // begin
                        //     case SupportedOutputMethod of
                        //         SupportedOutputMethod::Print:
                        //             ChosenOutputMethod := CustomLayoutReporting.GetPrintOption();
                        //         SupportedOutputMethod::Preview:
                        //             ChosenOutputMethod := CustomLayoutReporting.GetPreviewOption();
                        //     end;
                        // end;
                    }
                }
            }
        }

        trigger OnOpenPage();
        var
            Parameters: Record "EOS008 CVS Report Parameters";
            AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
        begin
            CurrReport.RequestOptionsPage.Caption := CurrReport.RequestOptionsPage.Caption() + SubscriptionMgt.GetLicenseText();

            if AdvCustVendStatSharedMem.GetReportParameter(Parameters) then begin
                OnlyOpenPrmtr := Parameters."Only Open";
                ShowLinkedEntriesPrmtr := Parameters."Show Linked Entries";
                UseSalespersonFromVendorPrmtr := Parameters."Use Salesperson from Vendor";
                PostingDateFilterPrmtr := Parameters."Posting Date Filter";
                DueDateFilterPrmtr := Parameters."Due Date Filter";
                PaymentMethodFilterPrmtr := Parameters."Payment Method Filter";

                if Parameters."Customer Vendor Table Filter 1" <> '' then begin
                    Vendor.Reset();
                    Vendor.SetView(Parameters."Customer Vendor Table Filter 1");
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
        ReportTitle = 'Vendor Account Statement at';
        VendorNoLabel = 'Vendor';
        SalesPersonLabel = 'Salesperson';
        VendorNameLabel = 'Name';
        VendorPhoneLabel = 'Phone';
        DescriptionLabel = 'Description';
        PostingDateLabel = 'Posting Date';
        DueDateLabel = 'Due Date';
        AssetTotalLabel = 'Total';
        DocumentTotalLabel = 'Document Total';
        VendorTotalLabel = 'Vendor Total';
        PageNoLabel = 'Page';
        DocumentTypeLabel = 'Type';
        DocumentNoLabel = 'Document';
        DocumentDateLabel = 'Doc. Date';
        ExternalDocumentNoLabel = 'External Document No.';
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
    begin
        OnlyOpenPrmtr := false;
        ShowLinkedEntriesPrmtr := true;
        UseSalespersonFromVendorPrmtr := true;
    end;

    trigger OnPreReport();
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        CompanyNameText := AssetsEngine.GetCompanyNameForReport(18123360);
        AdvCustVendStatRoutines.ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
        AdvCustVendStatRoutines.ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);
    end;

    var
        CompanyInformation: Record "Company Information";
        // TempAmountSummaryBuffer: array[4] of Record "EOS Statem. Assets Buffer EXT" temporary;
        TempDueAmountsBuffer: array[4] of Record "EOS Statem. Assets Buffer EXT" temporary;
        TempReportingBuffer: array[4] of Record "EOS Statem. Assets Buffer EXT" temporary;
        AdvCustVendStatRoutines: Codeunit "EOS AdvCustVendStat Routines";
        AssetsEngine: Codeunit "EOS AdvCustVendStat Engine";
        SubscriptionMgt: Codeunit "EOS AdvCustVendStat Subscript";
        CompanyNameText: Text;
        OnlyOpenPrmtr: Boolean;
        ShowLinkedEntriesPrmtr: Boolean;
        UseSalespersonFromVendorPrmtr: Boolean;
        PrintStatementCurrencyfromDocumentCurrencyPrmtr: Boolean;
        EndingDueDate: Date;
        EndingPostingDate: Date;
        StartingDueDate: Date;
        StartingPostingDate: Date;
        [InDataSet]
        DetailLoopNo: Integer;
        SortOrderPrmtr: Option VendorNo,VendorName;
        SupportedOutputMethod: Option Print,Preview;
        DueDateFilterPrmtr: Text;
        PaymentMethodFilterPrmtr: Text;
        PostingDateFilterPrmtr: Text;
        VendorAddress: array[11] of Text[100];


        ReportTitleLbl: label 'Vendor Account Statement at';
        VendorNoLbl: label 'Vendor';
        SalesPersonLbl: label 'Salesperson';
        VendorNameLbl: label 'Name';
        VendorPhoneLbl: label 'Phone';
        DescriptionLbl: label 'Description';
        PostingDateLbl: label 'Posting Date';
        DueDateLbl: label 'Due Date';
        AssetTotalLbl: label 'Total';
        DocumentTotalLbl: label 'Document Total';
        VendorTotalLbl: label 'Vendor Total';
        PageNoLbl: label 'Page';
        DocumentTypeLbl: label 'Type';
        DocumentNoLbl: label 'Document';
        DocumentDateLbl: label 'Doc. Date';
        ExternalDocumentNoLbl: label 'External Document No.';
        PaymentMethodLbl: label 'Payment Method Code';
        PaymentTermsLbl: label 'Payment Terms Code';
        RemainingAmountLCYLbl: label 'Remaining Amt. (LCY)';
        RemainingAmountLbl: label 'Remaining Amount';
        AmountLCYLbl: label 'Amount (LCY)';
        AmountLbl: label 'Amount';
        CurrencyCodeLbl: label 'Curr';
        BankReceiptStatusLbl: label 'Bank Receipt';
        TotalAmountLbl: label 'Total Report Amount';
        ExposureLbl: label 'Exposure (LCY)';
        WithExposureLbl: label 'with exposure';
        DueDateSummaryLbl: label 'Due by date summary';
    // AmountByCurrencyLbl: Label 'Amount by Currency summary';

    //VendorCounter: Integer;

    // local procedure GetBufferGroup(var BufferAssets: Record "EOS Statem. Assets Buffer EXT" temporary): Text;
    // begin
    //     exit(BufferAssets."EOS Source No.");
    // end;

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

    // local procedure GetAmount(AssetsBuffer: Record "EOS Statem. Assets Buffer EXT"): Text;
    // begin
    //     //Se sto mostrando la contropartita allora gli importi sono quelli complessivi e non il residuo
    //     if not ShowLinkedEntriesPrmtr then
    //         exit(Format(AssetsBuffer."EOS Remaining Amount"))
    //     else
    //         case AssetsBuffer."EOS Level No." of
    //             2:
    //                 exit(Format(AssetsBuffer."EOS Original Amount"));
    //             3, 4:
    //                 exit(Format(AssetsBuffer."EOS Applied Amount"));
    //         end;
    // end;

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

    local procedure GetAmount(AssetsBuffer: Record "EOS Statem. Assets Buffer EXT"): Decimal;
    begin
        //Se sto mostrando la contropartita allora gli importi sono quelli complessivi e non il residuo
        if not ShowLinkedEntriesPrmtr then
            exit(TempReportingBuffer[1]."EOS Remaining Amount")
        else
            case AssetsBuffer."EOS Level No." of
                2:
                    exit(AssetsBuffer."EOS Original Amount");
                3, 4:
                    exit(AssetsBuffer."EOS Applied Amount");
            end;
    end;

    local procedure GetRemainingAmount(AssetsBuffer: Record "EOS Statem. Assets Buffer EXT"): Decimal;
    begin
        exit(AssetsBuffer."EOS Remaining Amount");
    end;

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

    local procedure GetVendorAddress(): Text;
    var
        FormatAddress: Codeunit "Format Address";
    begin
        if DetailLoopNo > 1 then
            exit('');

        FormatAddress.Vendor(VendorAddress, VendorPrint);
        exit(GetAddressString(VendorAddress));
    end;

    local procedure GetVendorSalesPersonCode(): Text;
    begin
        if DetailLoopNo > 1 then
            exit('');

        exit(VendorPrint."Purchaser Code");
    end;

    local procedure GetCVendorSalesPersonName(): Text;
    var
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        if DetailLoopNo > 1 then
            exit('');

        Clear(SalesPerson);
        if VendorPrint."Purchaser Code" <> '' then
            if SalesPerson.Get(VendorPrint."Purchaser Code") then
                exit(SalesPerson.Name);
    end;

    local procedure GetVendorPaymentMethod(): Text;
    begin
        if DetailLoopNo > 1 then
            exit('');

        AdvCustVendStatRoutines.GetPaymentMethodDescription(VendorPrint."Payment Method Code", VendorPrint."Language Code");
    end;

    local procedure GetVendorPaymentTerms(): Text;
    begin
        if DetailLoopNo > 1 then
            exit('');

        exit(VendorPrint."Payment Terms Code");
    end;

    local procedure GetVendorPhone(): Text;
    begin
        exit(VendorPrint."Phone No.");
    end;

    local procedure GetBackReceiptNo(): Text;
    begin
        exit(TempReportingBuffer[1]."EOS Customer Bill No.");
    end;

    local procedure GetCurrencyCodeNo(): Text;
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if TempReportingBuffer[1]."EOS Currency Code" <> '' then
            exit(TempReportingBuffer[1]."EOS Currency Code")
        else
            if GeneralLedgerSetup.Get() then
                exit(GeneralLedgerSetup."LCY Code");
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

