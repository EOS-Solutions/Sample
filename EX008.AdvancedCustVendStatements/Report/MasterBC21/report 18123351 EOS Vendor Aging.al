report 18123351 "EOS Vendor Aging"
{
    // version NP11.01

    DefaultLayout = RDLC;
    RDLCLayout = './source/Report/report 18123351 EOS Vendor Aging.rdlc';
    Caption = 'Payable aging (CVS)';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
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
        dataitem(DataProcessing; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));

            trigger OnPreDataItem();
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
                TempAssetsBufferLocal: array[12] of Record "EOS Statem. Assets Buffer EXT" temporary;
                Vendor: Record "Vendor";
                Language: Codeunit Language;
                CurrentLanguageCode: Code[10];
                LastVendor: Code[20];
                Level2DueDate: Date;
                Level2Node: Integer;
                Level3Node: Integer;
            begin
                CurrentLanguageCode := Language.GetUserLanguageCode();

                AssetsEngine.BuildMultiSourceTreeView(1, VendorFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempAssetsBufferLocal[1]);

                OnAfterBuildMultiSourceTreeView(VendorFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempAssetsBufferLocal[1]);

                if ShowLinkedEntriesPrmtr then
                    AssetsEngine.MergeMultipleLevel3Items(TempAssetsBufferLocal[1]);

                Clear(TempReportingBuffer);

                AssetsEngine.ReverseSigns(TempAssetsBufferLocal[1]);

                Clear(TempAssetsBufferLocal);
                case SortOrderPrmtr of
                    SortOrderPrmtr::Vendor:
                        TempAssetsBufferLocal[2].SetCurrentKey("EOS Source No.");
                    SortOrderPrmtr::DueDate:
                        TempAssetsBufferLocal[2].SetCurrentKey("EOS Due Date");
                end;

                VendorFilters.CopyFilter("Currency Filter", TempAssetsBufferLocal[2]."EOS Currency Code");
                TempAssetsBufferLocal[2].SetRange("EOS Level No.", 2);
                TempAssetsBufferLocal[2].SetFilter("EOS Payment Method", PaymentMethodFilterPrmtr);
                if TempAssetsBufferLocal[2].FindSet() then
                    repeat
                        TempAssetsBufferLocal[2]."EOS Language Code" := CurrentLanguageCode;

                        TempAssetsBufferLocal[12] := TempAssetsBufferLocal[2];
                        if LastVendor <> TempAssetsBufferLocal[12]."EOS Source No." then begin
                            LastVendor := TempAssetsBufferLocal[12]."EOS Source No.";
                            Vendor.Get(TempAssetsBufferLocal[12]."EOS Source No.");
                            if (SortOrderPrmtr in [SortOrderPrmtr::Vendor]) and NewPagePerVendorPrmtr then
                                PageGroup += 1;
                        end;

                        if TempAssetsBufferLocal[12]."EOS Level No." > 3 then
                            TempAssetsBufferLocal[12]."EOS Level No." := 3;

                        //definisco un raggruppamento/spaccatura in base al sorting e al dettaglio richiesto. *Vendor
                        Clear(TempGenericVendorBuffer);
                        TempAssetsBufferLocal[12]."EOS Reporting Date 1" := TempAssetsBufferLocal[12]."EOS Due Date";
                        TempGenericVendorBuffer."Primary Key" := CopyStr(GetVendorBufferGroup(TempAssetsBufferLocal[12]), 1, 250);
                        if TempGenericVendorBuffer.Find('=') then begin
                            TempGenericVendorBuffer.Amount += TempAssetsBufferLocal[12]."EOS Remaining Amount (LCY)";
                            TempGenericVendorBuffer.Modify();
                        end else begin
                            GenericBufferEntryNo += 1;
                            TempGenericVendorBuffer."Reporting Group No." := GenericBufferEntryNo;
                            TempGenericVendorBuffer.Amount += TempAssetsBufferLocal[12]."EOS Remaining Amount (LCY)";
                            TempGenericVendorBuffer.Insert();
                        end;

                        case SortOrderPrmtr of
                            SortOrderPrmtr::DueDate:
                                begin
                                    TempEntryNo += 1;
                                    TempReportingBuffer := TempAssetsBufferLocal[12];
                                    TempReportingBuffer."EOS Reporting Date 1" := TempAssetsBufferLocal[12]."EOS Due Date";
                                    TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                    TempReportingBuffer."EOS Reporting Group 1" := TempGenericVendorBuffer."Reporting Group No.";
                                    TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                    TempReportingBuffer."EOS Reporting Group 3" := 0;
                                    TempReportingBuffer."EOS Reporting Subject Name" := Vendor.Name;
                                    TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                    TempReportingBuffer.Insert();
                                    if ShowLinkedEntriesPrmtr then begin
                                        // aggiungo le chiusure, agganciandole sotto la partita
                                        Level2Node := TempReportingBuffer."EOS Entry No.";
                                        Level2DueDate := TempReportingBuffer."EOS Due Date";
                                        Clear(TempAssetsBufferLocal[3]);
                                        TempAssetsBufferLocal[3].SetRange("EOS Node Linked To", TempAssetsBufferLocal[12]."EOS Entry No.");
                                        if TempAssetsBufferLocal[3].FindSet() then begin
                                            repeat
                                                TempEntryNo += 1;
                                                TempReportingBuffer := TempAssetsBufferLocal[3];
                                                TempReportingBuffer."EOS Node Linked To" := Level2Node;
                                                TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                                TempReportingBuffer."EOS Reporting Group 1" := TempGenericVendorBuffer."Reporting Group No.";
                                                TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                TempReportingBuffer."EOS Reporting Group 3" := 0;
                                                TempReportingBuffer."EOS Reporting Subject Name" := Vendor.Name;
                                                TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                                TempReportingBuffer."EOS Reporting Date 1" := Level2DueDate;
                                                TempReportingBuffer."EOS Remaining Amount (LCY)" := 0;
                                                TempReportingBuffer."EOS Remaining Amount" := 0;
                                                TempReportingBuffer."EOS Exposure (LCY)" := 0;
                                                TempReportingBuffer.Insert();
                                            until TempAssetsBufferLocal[3].Next() = 0;
                                            // aggiungo la riga totale documento
                                            TempEntryNo += 1;
                                            TempReportingBuffer := TempAssetsBufferLocal[12];
                                            TempReportingBuffer."EOS Level No." := 5;
                                            TempReportingBuffer."EOS Node Linked To" := Level2Node;
                                            TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                            TempReportingBuffer."EOS Reporting Group 1" := TempGenericVendorBuffer."Reporting Group No.";
                                            TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                            TempReportingBuffer."EOS Reporting Group 3" := 0;
                                            TempReportingBuffer."EOS Reporting Subject Name" := Vendor.Name;
                                            TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                            TempReportingBuffer."EOS Reporting Date 1" := Level2DueDate;
                                            TempReportingBuffer."EOS Exposure (LCY)" := 0;
                                            TempReportingBuffer.Insert();
                                        end;
                                    end;
                                end;
                            SortOrderPrmtr::Vendor:
                                begin
                                    case DetailLevelPrmtr of
                                        DetailLevelPrmtr::Vendor:
                                            begin
                                                Clear(TempReportingBuffer);
                                                TempReportingBuffer.SetRange("EOS Salesperson Code", TempAssetsBufferLocal[12]."EOS Salesperson Code");
                                                TempReportingBuffer.SetRange("EOS Source Type", TempAssetsBufferLocal[12]."EOS Source Type");
                                                TempReportingBuffer.SetRange("EOS Source No.", TempAssetsBufferLocal[12]."EOS Source No.");
                                                TempReportingBuffer.SetRange("EOS Currency Code", TempAssetsBufferLocal[12]."EOS Currency Code");

                                                TempAssetsBufferLocal[12]."EOS Document Type" := TempAssetsBufferLocal[12]."EOS Document Type"::" ";
                                                TempAssetsBufferLocal[12]."EOS Document No." := '';
                                                TempAssetsBufferLocal[12]."EOS Bank Receipt Status" := TempReportingBuffer."EOS Bank Receipt Status"::" ";
                                                TempAssetsBufferLocal[12]."EOS Customer Bill No." := '';
                                                TempAssetsBufferLocal[12]."EOS Posting Date" := 0D;
                                                TempAssetsBufferLocal[12]."EOS Due Date" := 0D;
                                                TempAssetsBufferLocal[12]."EOS Payment Method" := '';
                                            end;
                                        DetailLevelPrmtr::Document:
                                            begin
                                                Clear(TempReportingBuffer);
                                                TempReportingBuffer.SetRange("EOS Salesperson Code", TempAssetsBufferLocal[12]."EOS Salesperson Code");
                                                TempReportingBuffer.SetRange("EOS Source Type", TempAssetsBufferLocal[12]."EOS Source Type");
                                                TempReportingBuffer.SetRange("EOS Source No.", TempAssetsBufferLocal[12]."EOS Source No.");
                                                TempReportingBuffer.SetRange("EOS Currency Code", TempAssetsBufferLocal[12]."EOS Currency Code");
                                                TempReportingBuffer.SetRange("EOS Document Type", TempAssetsBufferLocal[12]."EOS Document Type");
                                                TempReportingBuffer.SetRange("EOS Document No.", TempAssetsBufferLocal[12]."EOS Document No.");

                                                TempAssetsBufferLocal[12]."EOS Bank Receipt Status" := TempReportingBuffer."EOS Bank Receipt Status"::" ";
                                                TempAssetsBufferLocal[12]."EOS Customer Bill No." := '';
                                            end;
                                        DetailLevelPrmtr::Duedates:
                                            begin
                                                Clear(TempReportingBuffer);
                                                TempReportingBuffer.SetRange("EOS Source Type", TempAssetsBufferLocal[12]."EOS Source Type");
                                                TempReportingBuffer.SetRange("EOS Source No.", TempAssetsBufferLocal[12]."EOS Source No.");
                                                TempReportingBuffer.SetRange("EOS Document Type", TempAssetsBufferLocal[12]."EOS Document Type");
                                                TempReportingBuffer.SetRange("EOS Document No.", TempAssetsBufferLocal[12]."EOS Document No.");
                                                TempReportingBuffer.SetRange("EOS Occurence No.", TempAssetsBufferLocal[12]."EOS Occurence No.");
                                                TempReportingBuffer.SetRange("EOS Apply Cust. /Vend. Entry", -1); //no grouping
                                            end;
                                    end;
                                    if TempReportingBuffer.FindFirst() then begin
                                        if TempReportingBuffer."EOS Due Date" > TempAssetsBufferLocal[12]."EOS Due Date" then
                                            TempReportingBuffer."EOS Due Date" := TempAssetsBufferLocal[12]."EOS Due Date";
                                        TempReportingBuffer."EOS Original Amount (LCY)" += TempAssetsBufferLocal[12]."EOS Original Amount (LCY)";
                                        TempReportingBuffer."EOS Remaining Amount (LCY)" += TempAssetsBufferLocal[12]."EOS Remaining Amount (LCY)";
                                        TempReportingBuffer."EOS Applied Amount (LCY)" += TempAssetsBufferLocal[12]."EOS Applied Amount (LCY)";
                                        TempReportingBuffer."EOS Original Amount" += TempAssetsBufferLocal[12]."EOS Original Amount";
                                        TempReportingBuffer."EOS Remaining Amount" += TempAssetsBufferLocal[12]."EOS Remaining Amount";
                                        TempReportingBuffer."EOS Applied Amount" += TempAssetsBufferLocal[12]."EOS Applied Amount";
                                        TempReportingBuffer."EOS Exposure (LCY)" += TempAssetsBufferLocal[12]."EOS Exposure (LCY)";
                                        if TempAssetsBufferLocal[12]."EOS Dishonored Entry No." <> 0 then
                                            TempReportingBuffer."EOS Dishonored Entry No." := TempAssetsBufferLocal[12]."EOS Dishonored Entry No.";
                                        TempReportingBuffer.Modify();
                                    end else begin
                                        TempEntryNo += 1;
                                        TempReportingBuffer := TempAssetsBufferLocal[12];
                                        TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                        TempReportingBuffer."EOS Reporting Group 1" := TempGenericVendorBuffer."Reporting Group No.";
                                        TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                        TempReportingBuffer."EOS Reporting Group 3" := 0;
                                        TempReportingBuffer."EOS Reporting Subject Name" := Vendor.Name;
                                        TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                        TempReportingBuffer."EOS Reporting Date 1" := TempAssetsBufferLocal[12]."EOS Due Date";
                                        TempReportingBuffer."EOS Reporting Boolean 1" := false;
                                        TempReportingBuffer.Insert();

                                        if ShowLinkedEntriesPrmtr then begin
                                            // aggiungo le contropartite, agganciandole sotto la partita
                                            Level2Node := TempReportingBuffer."EOS Entry No.";
                                            Level2DueDate := TempReportingBuffer."EOS Due Date";
                                            Clear(TempAssetsBufferLocal[3]);
                                            TempAssetsBufferLocal[3].SetRange("EOS Node Linked To", TempAssetsBufferLocal[12]."EOS Entry No.");
                                            if TempAssetsBufferLocal[3].FindSet() then begin
                                                TempReportingBuffer."EOS Reporting Boolean 1" := true; //add line space
                                                TempReportingBuffer.Modify();
                                                repeat
                                                    TempEntryNo += 1;
                                                    TempReportingBuffer := TempAssetsBufferLocal[3];
                                                    TempReportingBuffer."EOS Node Linked To" := Level2Node;
                                                    TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                                    TempReportingBuffer."EOS Reporting Group 1" := TempGenericVendorBuffer."Reporting Group No.";
                                                    TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                    TempReportingBuffer."EOS Reporting Group 3" := 0;
                                                    TempReportingBuffer."EOS Reporting Subject Name" := Vendor.Name;
                                                    TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                                    TempReportingBuffer."EOS Reporting Date 1" := Level2DueDate;
                                                    TempReportingBuffer."EOS Remaining Amount (LCY)" := 0;
                                                    TempReportingBuffer."EOS Remaining Amount" := 0;
                                                    TempReportingBuffer."EOS Exposure (LCY)" := 0;
                                                    TempReportingBuffer.Insert();
                                                    Level3Node := TempReportingBuffer."EOS Entry No.";
                                                    Clear(TempAssetsBufferLocal[4]);
                                                    TempAssetsBufferLocal[4].SetRange("EOS Node Linked To", TempAssetsBufferLocal[3]."EOS Entry No.");
                                                    if TempAssetsBufferLocal[4].FindSet() then
                                                        repeat
                                                            TempEntryNo += 1;
                                                            TempReportingBuffer := TempAssetsBufferLocal[4];
                                                            TempReportingBuffer."EOS Node Linked To" := Level3Node;
                                                            TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                                            TempReportingBuffer."EOS Reporting Group 1" := TempGenericVendorBuffer."Reporting Group No.";
                                                            TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                            TempReportingBuffer."EOS Reporting Group 3" := 0;
                                                            TempReportingBuffer."EOS Reporting Subject Name" := Vendor.Name;
                                                            TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                                            TempReportingBuffer."EOS Reporting Date 1" := Level2DueDate;
                                                            TempReportingBuffer."EOS Remaining Amount (LCY)" := 0;
                                                            TempReportingBuffer."EOS Remaining Amount" := 0;
                                                            TempReportingBuffer."EOS Exposure (LCY)" := 0;
                                                            TempReportingBuffer.Insert();
                                                            Level3Node := TempReportingBuffer."EOS Entry No.";
                                                        until TempAssetsBufferLocal[4].Next() = 0;
                                                until TempAssetsBufferLocal[3].Next() = 0;
                                                // aggiungo la riga totale documento
                                                TempEntryNo += 1;
                                                TempReportingBuffer := TempAssetsBufferLocal[12];
                                                TempReportingBuffer."EOS Level No." := 5;
                                                TempReportingBuffer."EOS Node Linked To" := Level2Node;
                                                TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                                TempReportingBuffer."EOS Reporting Group 1" := TempGenericVendorBuffer."Reporting Group No.";
                                                TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                TempReportingBuffer."EOS Reporting Group 3" := 0;
                                                TempReportingBuffer."EOS Reporting Subject Name" := Vendor.Name;
                                                TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                                TempReportingBuffer."EOS Reporting Date 1" := Level2DueDate;
                                                TempReportingBuffer."EOS Exposure (LCY)" := 0;
                                                TempReportingBuffer.Insert();
                                            end;
                                        end;
                                    end;
                                end;
                        end;
                    until TempAssetsBufferLocal[2].Next() = 0;

                if ShowLinkedEntriesPrmtr and (SortOrderPrmtr = SortOrderPrmtr::DueDate) and (DetailLevelPrmtr = DetailLevelPrmtr::Duedates) then begin
                    Clear(TempReportingBuffer);
                    TempReportingBuffer.SetCurrentKey("EOS Reporting Group 1", "EOS Reporting Date 1", "EOS Entry No.");
                    if TempReportingBuffer.FindSet(true) then
                        repeat
                            if TempReportingBuffer."EOS Level No." = 5 then
                                if TempReportingBuffer.Next() <> 0 then begin
                                    TempReportingBuffer."EOS Reporting Boolean 1" := true;
                                    TempReportingBuffer.Modify();
                                end;
                        until TempReportingBuffer.Next() = 0;
                end;
                Clear(TempReportingBuffer);

                OnAfterBuildReportingDataset(VendorFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                             StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempAssetsBufferLocal[1],
                                             TempReportingBuffer)
            end;
        }
        dataitem(ReportHeaderValues; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));
            column(CompanyName; CompanyNameText) { }
            column(ApplyedFilters; GetReportParametersText()) { }
        }
        dataitem(Detail; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = filter(1 ..));
            column(PageGroup; TempReportingBuffer."EOS Reporting Group 2") { }
            column(DetailGroup; TempReportingBuffer."EOS Reporting Group 1") { }
            column(LineTypeFormat; GetLineTypeFormat()) { }
            column(AddLineSpaceBefore; TempReportingBuffer."EOS Reporting Boolean 1") { }
            column(Level; TempReportingBuffer."EOS Level No.") { }
            column(VendorNo; TempReportingBuffer."EOS Source No.") { }
            column(VendorName; TempReportingBuffer."EOS Reporting Subject Name") { }
            column(PostingDate; Format(TempReportingBuffer."EOS Posting Date")) { }
            column(DocumentType; GetDocumentTypeAbbreviation(TempReportingBuffer."EOS Document Type")) { }
            column(DocumentNo; TempReportingBuffer."EOS Document No.") { }
            column(ExternalDocumentNo; TempReportingBuffer."EOS External Document No.") { }
            column(PaymentMethod; TempReportingBuffer."EOS Payment Method") { }
            column(DueDate; Format(TempReportingBuffer."EOS Due Date")) { }
            column(CurrencyCode; TempReportingBuffer."EOS Currency Code") { }
            column(RemainingAmount; GetRemainingAmount()) { }
            column(RemainingAmountLCY; GetRemainingAmountLCY()) { }
            column(AmountToPrint; GetAmount()) { }
            column(AmountToPrintLCY; GetAmountLCY()) { }
            column(ShowGroupTotal; GetShowGroupTotal()) { }
            column(GroupTotalText; GetGroupTotalText()) { }
            column(AmountLabelType; GetAmountLabelType()) { }
            column(CustomBoolean1; TempReportingBuffer."EOS Custom Boolean 1") { }
            column(CustomBoolean2; TempReportingBuffer."EOS Custom Boolean 2") { }
            column(CustomDate1; Format(TempReportingBuffer."EOS Custom Date 1")) { }
            column(CustomDate2; Format(TempReportingBuffer."EOS Custom Date 2")) { }
            column(CustomText1; TempReportingBuffer."EOS Custom Text 1") { }
            column(CustomText2; TempReportingBuffer."EOS Custom Text 2") { }

            trigger OnAfterGetRecord();
            begin
                if Number > 1 then
                    if TempReportingBuffer.Next() = 0 then
                        CurrReport.BREAK();
            end;

            trigger OnPreDataItem();
            begin
                Clear(TempReportingBuffer);
                TempReportingBuffer.SetCurrentKey("EOS Reporting Group 3", "EOS Reporting Group 1", "EOS Reporting Date 1", "EOS Entry No.");
                if not TempReportingBuffer.Find('-') then
                    CurrReport.BREAK();
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Only Open Entries" field.';
                }
                field(SortOrder; SortOrderPrmtr)
                {
                    Caption = 'Sort Order';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Sort Order" field.';
                    trigger OnValidate();
                    begin
                        UpdateReqPage();
                    end;
                }
                field(DetailLevel; DetailLevelPrmtr)
                {
                    Caption = 'Detail Level';
                    Enabled = NewPagePerVendorEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Detail Level" field.';
                    trigger OnValidate();
                    begin
                        UpdateReqPage();
                    end;
                }
                field(ShowLinkedEntries; ShowLinkedEntriesPrmtr)
                {
                    Caption = 'Show Linked Entries';
                    Enabled = LinkedEntriesEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Show Linked Entries" field.';
                }
                field(NewPagePerVendor; NewPagePerVendorPrmtr)
                {
                    Caption = 'New Page Per Vendor';
                    Enabled = NewPagePerVendorEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "New Page Per Vendor" field.';
                }
                field(PostingDateFilter; PostingDateFilterPrmtr)
                {
                    Caption = 'Posting Date Filter';
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                field(ShowFilters; ShowFiltersPrmtr)
                {
                    Caption = 'Print Filters';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Print Filters" field.';
                }
            }
        }

        trigger OnOpenPage();
        var
            Parameters: Record "EOS008 CVS Report Parameters";
            AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
        begin
            CurrReport.RequestOptionsPage.Caption := CurrReport.RequestOptionsPage.Caption() + SubscriptionMgt.GetLicenseText();
            OnlyOpenPrmtr := true;
            ShowLinkedEntriesPrmtr := false;
            UpdateReqPage();
            if AdvCustVendStatSharedMem.GetReportParameter(Parameters) then begin
                OnlyOpenPrmtr := Parameters."Only Open";
                SortOrderPrmtr := Parameters."Vendor Detail Order";
                DetailLevelPrmtr := Parameters."Vendor Detail Level";
                ShowLinkedEntriesPrmtr := Parameters."Show Linked Entries";
                NewPagePerVendorPrmtr := Parameters."New Page Per Vendor";
                PostingDateFilterPrmtr := Parameters."Posting Date Filter";
                DueDateFilterPrmtr := Parameters."Due Date Filter";
                PaymentMethodFilterPrmtr := Parameters."Payment Method Filter";
                ShowFiltersPrmtr := Parameters."Print Filters";

                if Parameters."Customer Vendor Table Filter 1" <> '' then begin
                    VendorFilters.Reset();
                    VendorFilters.SetView(Parameters."Customer Vendor Table Filter 1");
                end;
            end;
        end;
    }

    labels
    {
        ReportTitle = 'Payable aging';

        VendorNoLabel = 'Vendor';
        VendorNameLabel = 'Name';
        PostingDateLabel = 'Posting Date';
        DueDateLabel = 'Due Date';
        VendorTotalLabel = 'Vendor Total';
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
    }

    trigger OnInitReport();
    begin
        OnlyOpenPrmtr := true;
        ShowLinkedEntriesPrmtr := false;
    end;

    trigger OnPostReport();
    begin
        Window.Close();
    end;

    trigger OnPreReport();
    var
        AdvCustVendStatRoutines: Codeunit "EOS AdvCustVendStat Routines";
        CVStatEngine: Codeunit "EOS AdvCustVendStat Engine";
    begin
        AdvCustVendStatRoutines.ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
        AdvCustVendStatRoutines.ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);

        Window.Open(TextDialog001Msg);
        CompanyNameText := CVStatEngine.GetCompanyNameForReport(18123351);
    end;

    protected var
        TempGenericVendorBuffer: Record "EOS008 Reporting Buffer" temporary;
        TempReportingBuffer: Record "EOS Statem. Assets Buffer EXT" temporary;
        DueDateFilterPrmtr: Text;
        PostingDateFilterPrmtr: Text;

    var
        AssetsEngine: Codeunit "EOS AdvCustVendStat Engine";
        SubscriptionMgt: Codeunit "EOS AdvCustVendStat Subscript";
        Window: Dialog;
        CompanyNameText: Text;
        NewPagePerVendorPrmtr: Boolean;
        OnlyOpenPrmtr: Boolean;
        ShowFiltersPrmtr: Boolean;
        ShowLinkedEntriesPrmtr: Boolean;
        [InDataSet]
        LinkedEntriesEnabled: Boolean;
        [InDataSet]
        NewPagePerVendorEnabled: Boolean;
        EndingDueDate: Date;
        EndingPostingDate: Date;
        StartingDueDate: Date;
        StartingPostingDate: Date;
        GenericBufferEntryNo: Integer;
        PageGroup: Integer;
        PrevGroup: Integer;
        TempEntryNo: Integer;
        DetailLevelPrmtr: Enum "EOS008 CVD Vend Detail Level";
        SortOrderPrmtr: Enum "EOS008 CVS Vend Detail Order";
        PaymentMethodFilterPrmtr: Text;
        DueDateFilterTextMsg: Label 'Due Date Filter:';
        ExcludingBalanceTextMsg: Label 'without';
        IncludingBalanceTextMsg: Label 'with';
        OnlyOpenTextMsg: Label ' only open entries';
        PaymentFilterTextMsg: Label 'Payment Filter:';
        PostingDateFilterTextMsg: Label 'Posting Date Filter:';
        ReportSortTextMsg: Label 'Sorted By %1 with %2 detail level %3 linked entries';
        TextDialog001Msg: Label 'Vendor #1#######';
        TextTotalTxt: Label 'Total for %1 %2';
        VendorFilterTextMsg: Label 'Vendor Filters:';

    local procedure GetVendorBufferGroup(var BufferAssets: Record "EOS Statem. Assets Buffer EXT" temporary): Text;
    begin
        case SortOrderPrmtr of
            SortOrderPrmtr::Vendor:
                exit(BufferAssets."EOS Source No.");
            SortOrderPrmtr::DueDate:
                exit(Format(BufferAssets."EOS Reporting Date 1", 0, 9));
        end;
    end;

    local procedure GetDocumentTypeAbbreviation(DocumentType: Integer): Text;
    var
        AbreviationsMsg: Label ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund,,,,Dishonored';
    begin
        exit(CopyStr(SelectStr(DocumentType + 1, Format(AbreviationsMsg)), 1, 4));
    end;

    local procedure GetShowGroupTotal(): Text;
    begin
        if (SortOrderPrmtr <> SortOrderPrmtr::Vendor) or
           ((SortOrderPrmtr = SortOrderPrmtr::Vendor) and
            (DetailLevelPrmtr <> DetailLevelPrmtr::Vendor)) then
            exit(Format(true));
    end;

    local procedure GetAmount(): Text;
    begin
        //Se sto mostrando la contropartita allora gli importi sono quelli complessivi e non il residuo
        if not ShowLinkedEntriesPrmtr then
            exit(FormatAmount(TempReportingBuffer."EOS Remaining Amount" + TempReportingBuffer."EOS Exposure (LCY)"))
        else
            case TempReportingBuffer."EOS Level No." of
                2:
                    exit(FormatAmount(TempReportingBuffer."EOS Original Amount"));
                3:
                    exit(FormatAmount(TempReportingBuffer."EOS Applied Amount"));
                5:
                    exit(FormatAmount(TempReportingBuffer."EOS Remaining Amount"));
            end;
    end;

    local procedure GetAmountLCY(): Text;
    begin
        //Se sto mostrando la contropartita allora gli importi sono quelli complessivi e non il residuo
        if not ShowLinkedEntriesPrmtr then
            exit(FormatAmount(TempReportingBuffer."EOS Remaining Amount (LCY)" + TempReportingBuffer."EOS Exposure (LCY)"))
        else
            case TempReportingBuffer."EOS Level No." of
                2:
                    exit(FormatAmount(TempReportingBuffer."EOS Original Amount (LCY)"));
                3:
                    exit(FormatAmount(TempReportingBuffer."EOS Applied Amount (LCY)"));
                5:
                    exit(FormatAmount(TempReportingBuffer."EOS Remaining Amount (LCY)"));
            end;
    end;

    local procedure GetRemainingAmount(): Decimal;
    begin
        if ShowLinkedEntriesPrmtr and (TempReportingBuffer."EOS Level No." = 5) then
            exit(0);

        exit(TempReportingBuffer."EOS Remaining Amount" + TempReportingBuffer."EOS Exposure (LCY)");
    end;

    local procedure GetRemainingAmountLCY(): Decimal;
    begin
        if ShowLinkedEntriesPrmtr and (TempReportingBuffer."EOS Level No." = 5) then
            exit(0);

        exit(TempReportingBuffer."EOS Remaining Amount (LCY)" + TempReportingBuffer."EOS Exposure (LCY)");
    end;

    local procedure GetReportParametersText() Result: Text;
    var
        Vendor2: Record "Vendor";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        EOSLibraryEXT: Codeunit "EOS Library EXT";
        DetailText: Text;
        SortText: Text;
        WithWithoutText: Text;
    begin
        if not ShowFiltersPrmtr then
            exit('');

        Vendor2 := VendorFilters;
        if OnlyOpenPrmtr then
            Vendor2.SetRange("Balance (LCY)");
        if Vendor2.GetFilters() <> '' then
            Result := VendorFilterTextMsg + VendorFilters.GetFilters() + EOSLibraryEXT.NewLine();

        if PostingDateFilterPrmtr <> '' then
            Result += PostingDateFilterTextMsg + PostingDateFilterPrmtr + EOSLibraryEXT.NewLine();

        if DueDateFilterPrmtr <> '' then
            Result += DueDateFilterTextMsg + DueDateFilterPrmtr + EOSLibraryEXT.NewLine();

        if PaymentMethodFilterPrmtr <> '' then
            Result += PaymentFilterTextMsg + PaymentMethodFilterPrmtr + EOSLibraryEXT.NewLine();

        case SortOrderPrmtr of
            SortOrderPrmtr::Vendor:
                SortText := VendorLedgerEntry.FIELDCAPTION("Vendor No.");
            SortOrderPrmtr::DueDate:
                SortText := VendorLedgerEntry.FIELDCAPTION("Due Date");
        end;
        case DetailLevelPrmtr of
            DetailLevelPrmtr::Vendor:
                DetailText := VendorLedgerEntry.FIELDCAPTION("Vendor No.");
            DetailLevelPrmtr::Document:
                DetailText := VendorLedgerEntry.FIELDCAPTION("Document No.");
            DetailLevelPrmtr::Duedates:
                DetailText := VendorLedgerEntry.FIELDCAPTION("Due Date");
        end;
        if ShowLinkedEntriesPrmtr then
            WithWithoutText := IncludingBalanceTextMsg
        else
            WithWithoutText := ExcludingBalanceTextMsg;
        Result += StrSubstNo(ReportSortTextMsg, SortText, DetailText, WithWithoutText);
        if OnlyOpenPrmtr then
            Result += OnlyOpenTextMsg;
    end;

    local procedure GetAmountLabelType(): Text;
    begin
        if ShowLinkedEntriesPrmtr then
            exit('AMOUNT');
    end;

    local procedure GetGroupTotalText(): Text;
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if PrevGroup <> TempReportingBuffer."EOS Reporting Group 1" then begin
            PrevGroup := TempReportingBuffer."EOS Reporting Group 1";
            case SortOrderPrmtr of
                SortOrderPrmtr::Vendor:
                    exit(StrSubstNo(TextTotalTxt, TempReportingBuffer."EOS Source No.", TempReportingBuffer."EOS Reporting Subject Name"));
                SortOrderPrmtr::DueDate:
                    exit(StrSubstNo(TextTotalTxt, VendorLedgerEntry.FIELDCAPTION("Due Date"), TempReportingBuffer."EOS Due Date"));
            end;
        end;
    end;

    local procedure GetLineTypeFormat(): Text;
    begin
        // 10 -> main asset (unused)
        // 20 -> asset level 2
        // 21 -> asset level 2 (Vendorname expanded)
        // 30 -> asset level 3 (Payment)
        // 50 -> asset level 5 (Document Total)

        case TempReportingBuffer."EOS Level No." of
            1:
                exit('10');
            2:

                if (SortOrderPrmtr = SortOrderPrmtr::Vendor) and (DetailLevelPrmtr = DetailLevelPrmtr::Vendor) then
                    exit('21')
                else
                    exit('20');

            3:
                exit('30');
            5:
                exit('50');
        end;
    end;

    local procedure FormatAmount(Value: Decimal): Text;
    begin
        exit(Format(Value, 0, '<Precision,2:2><Standard Format,0>'));
    end;

    local procedure UpdateReqPage();
    begin
        NewPagePerVendorEnabled := SortOrderPrmtr = SortOrderPrmtr::Vendor;
        LinkedEntriesEnabled := ((SortOrderPrmtr = SortOrderPrmtr::Vendor) and (DetailLevelPrmtr = DetailLevelPrmtr::Duedates)) or
                                (SortOrderPrmtr = SortOrderPrmtr::DueDate);

        if not LinkedEntriesEnabled then
            ShowLinkedEntriesPrmtr := false;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildMultiSourceTreeView(SourceView: Text; DateFilterType: Option "Posting Date","Document Date"; StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date; OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text; var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBuildReportingDataset(SourceView: Text; DateFilterType: Option "Posting Date","Document Date"; StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date; OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text; var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT"; var TempReportingBuffer: Record "EOS Statem. Assets Buffer EXT")
    begin
    end;
}

