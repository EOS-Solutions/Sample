report 18123350 "EOS Customer Aging"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/Report/report 18123350 EOS Customer Aging.rdlc';
    Caption = 'Customer Aging (CVS)';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(CustomerFilters; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", Name, "Country/Region Code";

            trigger OnPreDataItem();
            begin
                SetReportParameters();
                CurrReport.Break();
            end;
        }
        dataitem(SalespersonFilters; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting(Code);
            RequestFilterFields = "Code";

            trigger OnPreDataItem();
            begin
                SetReportParameters();
                CurrReport.Break();
            end;
        }
        dataitem(DataProcessing; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = const(1));

            trigger OnPreDataItem();
            var
                Customer: Record Customer;
                SalespersonPurchaser: Record "Salesperson/Purchaser";
                TempAssetsBufferLocal: array[12] of Record "EOS Statem. Assets Buffer EXT" temporary;
                Language: Codeunit Language;
                CurrentLanguageCode: Code[10];
                LastCustomer: Code[20];
                LastSalesperson: Code[20];
                Level2DueDate: Date;
                Level2Node: Integer;
                Level3Node: Integer;
                SalespersonFilter: Text;
            begin
                CurrentLanguageCode := Language.GetUserLanguageCode();

                if UseSalespersonFromCustomerPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        CustomerFilters.SetFilter("Salesperson Code", SalespersonFilter);
                    end;

                AssetsEngine.SetForceCustomerSalesperson(UseSalespersonFromCustomerPrmtr);
                AssetsEngine.BuildMultiSourceTreeView(0, CustomerFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempAssetsBufferLocal[1]);

                OnAfterBuildMultiSourceTreeView(CustomerFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
                                                         StartingDueDate, EndingDueDate, OnlyOpenPrmtr, false, '', TempAssetsBufferLocal[1]);

                if ShowLinkedEntriesPrmtr then
                    AssetsEngine.MergeMultipleLevel3Items(TempAssetsBufferLocal[1]);

                Clear(TempAssetsBufferLocal);
                case SortOrderPrmtr of
                    SortOrderPrmtr::SalesPerson:
                        TempAssetsBufferLocal[2].SetCurrentKey("EOS Salesperson Code", "EOS Source No.");
                    SortOrderPrmtr::Customer:
                        TempAssetsBufferLocal[2].SetCurrentKey("EOS Source No.");
                    SortOrderPrmtr::DueDate:
                        TempAssetsBufferLocal[2].SetCurrentKey("EOS Due Date");
                end;

                if not UseSalespersonFromCustomerPrmtr then
                    if SalespersonFilters.GetFilters() <> '' then begin
                        SalespersonFilter := GetSelectionFilterForSalesperson(SalespersonFilters);
                        TempAssetsBufferLocal[2].SetFilter("EOS Salesperson Code", SalespersonFilter);
                    end;

                if SortOrderPrmtr <> SortOrderPrmtr::SalesPerson then
                    TempAssetsBufferLocal[2].ModifyAll("EOS Salesperson Code", '');

                LastSalesperson := 'XYZ123';

                CustomerFilters.CopyFilter("Currency Filter", TempAssetsBufferLocal[2]."EOS Currency Code");
                TempAssetsBufferLocal[2].SetRange("EOS Level No.", 2);
                TempAssetsBufferLocal[2].SetFilter("EOS Payment Method", PaymentMethodFilterPrmtr);
                if TempAssetsBufferLocal[2].FindSet() then
                    repeat
                        TempAssetsBufferLocal[2]."EOS Language Code" := CurrentLanguageCode;

                        TempAssetsBufferLocal[12] := TempAssetsBufferLocal[2];
                        if LastCustomer <> TempAssetsBufferLocal[12]."EOS Source No." then begin
                            LastCustomer := TempAssetsBufferLocal[12]."EOS Source No.";
                            Customer.Get(TempAssetsBufferLocal[12]."EOS Source No.");
                            if (SortOrderPrmtr in [SortOrderPrmtr::SalesPerson, SortOrderPrmtr::Customer]) and NewPagePerCustomerPrmtr then
                                PageGroup += 1;
                            TempProcessedCustomerList := Customer;
                            if TempProcessedCustomerList.Insert() then;
                        end;

                        if LastSalesperson <> TempAssetsBufferLocal[12]."EOS Salesperson Code" then begin
                            LastSalesperson := TempAssetsBufferLocal[12]."EOS Salesperson Code";
                            if not SalespersonPurchaser.Get(TempAssetsBufferLocal[12]."EOS Salesperson Code") then begin
                                Clear(SalespersonPurchaser);
                                SalespersonPurchaser.Name := CopyStr(NoSalespersonTxt, 1, MaxStrLen(SalespersonPurchaser.Name));
                            end;
                            if (SortOrderPrmtr in [SortOrderPrmtr::SalesPerson]) and NewPagePerSalespersonPrmtr then
                                PageGroup += 1;
                        end;

                        if TempAssetsBufferLocal[12]."EOS Level No." > 3 then
                            TempAssetsBufferLocal[12]."EOS Level No." := 3;

                        //definisco un raggruppamento/spaccatura in base al sorting e al dettaglio richiesto. *Customer
                        Clear(TempGenericCustomerBuffer);
                        TempAssetsBufferLocal[12]."EOS Reporting Date 1" := TempAssetsBufferLocal[12]."EOS Due Date";
                        TempGenericCustomerBuffer."Primary Key" := CopyStr(GetCustomerBufferGroup(TempAssetsBufferLocal[12]), 1, 250);
                        if TempGenericCustomerBuffer.Find('=') then begin
                            TempGenericCustomerBuffer.Amount += TempAssetsBufferLocal[12]."EOS Remaining Amount (LCY)";
                            TempGenericCustomerBuffer.Modify();
                        end else begin
                            GenericBufferEntryNo += 1;
                            TempGenericCustomerBuffer."Reporting Group No." := GenericBufferEntryNo;
                            TempGenericCustomerBuffer.Amount += TempAssetsBufferLocal[12]."EOS Remaining Amount (LCY)";
                            TempGenericCustomerBuffer.Insert();
                        end;

                        //definisco un raggruppamento/spaccatura in base al sorting e al dettaglio richiesto. *Customer
                        Clear(TempGenericSalespersonBuffer);
                        TempAssetsBufferLocal[12]."EOS Reporting Date 1" := TempAssetsBufferLocal[12]."EOS Due Date";
                        TempGenericSalespersonBuffer."Primary Key" := CopyStr(GetSalespersonBufferGroup(TempAssetsBufferLocal[12]), 1, 250);
                        if TempGenericSalespersonBuffer.Find('=') then begin
                            TempGenericSalespersonBuffer.Amount += TempAssetsBufferLocal[12]."EOS Remaining Amount (LCY)";
                            TempGenericSalespersonBuffer.Modify();
                        end else begin
                            GenericBufferEntryNo += 1;
                            TempGenericSalespersonBuffer."Reporting Group No." := GenericBufferEntryNo;
                            TempGenericSalespersonBuffer.Amount += TempAssetsBufferLocal[12]."EOS Remaining Amount (LCY)";
                            TempGenericSalespersonBuffer.Insert();
                        end;

                        case SortOrderPrmtr of
                            SortOrderPrmtr::DueDate:
                                begin
                                    TempEntryNo += 1;
                                    TempReportingBuffer := TempAssetsBufferLocal[12];
                                    TempReportingBuffer."EOS Reporting Date 1" := TempAssetsBufferLocal[12]."EOS Due Date";
                                    TempReportingBuffer."EOS Entry No." := TempEntryNo;
                                    TempReportingBuffer."EOS Reporting Group 1" := TempGenericCustomerBuffer."Reporting Group No.";
                                    TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                    TempReportingBuffer."EOS Reporting Group 3" := TempGenericSalespersonBuffer."Reporting Group No.";
                                    TempReportingBuffer."EOS Reporting Subject Name" := Customer.Name;
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
                                                TempReportingBuffer."EOS Reporting Group 1" := TempGenericCustomerBuffer."Reporting Group No.";
                                                TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                TempReportingBuffer."EOS Reporting Group 3" := TempGenericSalespersonBuffer."Reporting Group No.";
                                                TempReportingBuffer."EOS Reporting Subject Name" := Customer.Name;
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
                                            TempReportingBuffer."EOS Reporting Group 1" := TempGenericCustomerBuffer."Reporting Group No.";
                                            TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                            TempReportingBuffer."EOS Reporting Group 3" := TempGenericSalespersonBuffer."Reporting Group No.";
                                            TempReportingBuffer."EOS Reporting Subject Name" := Customer.Name;
                                            TempReportingBuffer."EOS Reporting SalesPerson Name" := SalespersonPurchaser.Name;
                                            TempReportingBuffer."EOS Reporting Date 1" := Level2DueDate;
                                            TempReportingBuffer."EOS Exposure (LCY)" := 0;
                                            TempReportingBuffer.Insert();
                                        end;
                                    end;
                                end;
                            SortOrderPrmtr::SalesPerson,
                            SortOrderPrmtr::Customer:
                                begin
                                    case DetailLevelPrmtr of
                                        DetailLevelPrmtr::Customer:
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
                                        TempReportingBuffer."EOS Reporting Group 1" := TempGenericCustomerBuffer."Reporting Group No.";
                                        TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                        TempReportingBuffer."EOS Reporting Group 3" := TempGenericSalespersonBuffer."Reporting Group No.";
                                        TempReportingBuffer."EOS Reporting Subject Name" := Customer.Name;
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
                                                    TempReportingBuffer."EOS Reporting Group 1" := TempGenericCustomerBuffer."Reporting Group No.";
                                                    TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                    TempReportingBuffer."EOS Reporting Group 3" := TempGenericSalespersonBuffer."Reporting Group No.";
                                                    TempReportingBuffer."EOS Reporting Subject Name" := Customer.Name;
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
                                                            TempReportingBuffer."EOS Reporting Group 1" := TempGenericCustomerBuffer."Reporting Group No.";
                                                            TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                            TempReportingBuffer."EOS Reporting Group 3" := TempGenericSalespersonBuffer."Reporting Group No.";
                                                            TempReportingBuffer."EOS Reporting Subject Name" := Customer.Name;
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
                                                TempReportingBuffer."EOS Reporting Group 1" := TempGenericCustomerBuffer."Reporting Group No.";
                                                TempReportingBuffer."EOS Reporting Group 2" := PageGroup;
                                                TempReportingBuffer."EOS Reporting Group 3" := TempGenericSalespersonBuffer."Reporting Group No.";
                                                TempReportingBuffer."EOS Reporting Subject Name" := Customer.Name;
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

                OnAfterBuildReportingDataset(CustomerFilters.GETVIEW(false), 0, StartingPostingDate, EndingPostingDate,
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
            column(HideSalespersonTotal; HideSalespersonTotalPrmtr) { }
            column(HideMasterTotal; HideMasterTotal) { }
        }
        dataitem(Detail; Integer)
        {
            DataItemTableView = sorting(Number)
                                where(Number = filter(1 ..));
            column(CustomerDetailGroup; TempReportingBuffer."EOS Reporting Group 1") { }
            column(PageGroup; TempReportingBuffer."EOS Reporting Group 2") { }
            column(SalesPersonDetailGroup; TempReportingBuffer."EOS Reporting Group 3") { }
            column(LineTypeFormat; GetLineTypeFormat()) { }
            column(AddLineSpaceBefore; TempReportingBuffer."EOS Reporting Boolean 1") { }
            column(Level; TempReportingBuffer."EOS Level No.") { }
            column(SalespersonCode; TempReportingBuffer."EOS Salesperson Code") { }
            column(SalespersonName; TempReportingBuffer."EOS Reporting SalesPerson Name") { }
            column(CustomerNo; TempReportingBuffer."EOS Source No.") { }
            column(CustomerName; TempReportingBuffer."EOS Reporting Subject Name") { }
            column(PostingDate; Format(TempReportingBuffer."EOS Posting Date")) { }
            column(DocumentType; GetDocumentTypeAbbreviation(TempReportingBuffer."EOS Document Type")) { }
            column(DocumentNo; TempReportingBuffer."EOS Document No.") { }
            column(PaymentMethod; GetPaymentMethod(TempReportingBuffer."EOS Language Code")) { }
            column(DueDate; Format(TempReportingBuffer."EOS Due Date")) { }
            column(CurrencyCode; TempReportingBuffer."EOS Currency Code") { }
            column(RemainingAmount; GetRemainingAmount()) { }
            column(RemainingAmountLCY; GetRemainingAmountLCY()) { }
            column(AmountToPrint; GetAmount()) { }
            column(AmountToPrintLCY; GetAmountLCY()) { }
            column(ExposureLCY; TempReportingBuffer."EOS Exposure (LCY)") { }
            column(BankReceiptStatus; GetBankReceiptAbbreviation()) { }
            column(ShowCustomerGroupTotal; GetShowCustomerGroupTotal()) { }
            column(CustomerGroupTotalText; GetCustomerGroupTotalText()) { }
            column(ShowSalespersonGroupTotal; GetShowSalespersonGroupTotal()) { }
            column(SalespersonGroupTotalText; GetSalespersonGroupTotalText()) { }
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
                        CurrReport.Break();

                ReportLineCount += 1;
            end;

            trigger OnPreDataItem();
            begin
                Clear(TempReportingBuffer);
                TempReportingBuffer.SetCurrentKey("EOS Reporting Group 3", "EOS Reporting Group 1", "EOS Reporting Date 1", "EOS Entry No.");
                if not TempReportingBuffer.Find('-') then
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
                    Enabled = NewPagePerCustomerEnabled;
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
                field(NewPagePerSalesperson; NewPagePerSalespersonPrmtr)
                {
                    Caption = 'New Page Per Salesperson';
                    Editable = NewPagePerSalespersonEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "New Page Per Salesperson" field.';
                    trigger OnValidate();
                    begin
                        UpdateReqPage();
                    end;
                }
                field(NewPagePerCustomer; NewPagePerCustomerPrmtr)
                {
                    Caption = 'New Page Per Customer';
                    Enabled = NewPagePerCustomerEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "New Page Per Customer" field.';
                    trigger OnValidate();
                    begin
                        UpdateReqPage();
                    end;
                }
                field(UseSalespersonFromCustomer; UseSalespersonFromCustomerPrmtr)
                {
                    Caption = 'Use Salesperson from Customer';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Use Salesperson from Customer" field.';
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
                field(HideSalespersonTotal; HideSalespersonTotalPrmtr)
                {
                    Caption = 'Hide Salesperson Total';
                    Enabled = HideSalespersonTotalEnabled;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the "Hide Salesperson Total" field.';
                }
            }
        }

        trigger OnOpenPage();
        begin
            CurrReport.RequestOptionsPage.Caption := CurrReport.RequestOptionsPage.Caption() + SubscriptionMgt.GetLicenseText();
            SetReportParameters();
        end;
    }

    labels
    {
        ReportTitle = 'Customer Aging';
        CustomerNoLabel = 'Customer';
        CustomerNameLabel = 'Name';
        PostingDateLabel = 'Posting Date';
        DueDateLabel = 'Due Date';
        CustomerTotalLabel = 'Customer Total';
        PageNoLabel = 'Page';
        DocumentTypeLabel = 'Type';
        DocumentNoLabel = 'Document';
        ExternalDocumentNo = 'External Document No.';
        PaymentMethodLabel = 'Pmt.';
        RemainingAmountLCYLabel = 'Remaining Amt. (LCY)';
        RemainingAmountLabel = 'Remaining Amount';
        AmountLCYLabel = 'Amount (LCY)';
        AmountLabel = 'Amount';
        CurrencyCodeLabel = 'Curr';
        BankReceiptStatusLabel = 'Bank Rec. (Exposition)';
        TotalAmountLabel = 'Total Report Amount';
    }

    trigger OnInitReport();
    begin
        OnlyOpenPrmtr := true;
        ShowLinkedEntriesPrmtr := false;
        UseSalespersonFromCustomerPrmtr := true;
        SubscriptionActive := SubscriptionMgt.GetSubscriptionIsActive();
    end;

    trigger OnPreReport()
    var
        CVStatEngine: Codeunit "EOS AdvCustVendStat Engine";
    begin
        if not SubscriptionActive then
            CurrReport.quit();

        FixParameters();

        AdvCustVendStatRoutines.ResolveDateFilter(PostingDateFilterPrmtr, StartingPostingDate, EndingPostingDate);
        AdvCustVendStatRoutines.ResolveDateFilter(DueDateFilterPrmtr, StartingDueDate, EndingDueDate);

        CompanyNameText := CVStatEngine.GetCompanyNameForReport(18123350);
    end;

    trigger OnPostReport()
    var
        AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
    begin
        AdvCustVendStatSharedMem.SetReportLineCount(ReportLineCount);
        AdvCustVendStatSharedMem.ClearProcessedCustomerList();
        Clear(TempProcessedCustomerList);
        if TempProcessedCustomerList.FindSet() then
            repeat
                AdvCustVendStatSharedMem.AddCustomerCode(TempProcessedCustomerList."No.");
            until TempProcessedCustomerList.Next() = 0;
    end;

    var
        ParametersBuffer: Record "EOS008 CVS Report Parameters";
        TempGenericCustomerBuffer: Record "EOS008 Reporting Buffer" temporary;
        TempGenericSalespersonBuffer: Record "EOS008 Reporting Buffer" temporary;
        TempProcessedCustomerList: Record Customer temporary;
        TempReportingBuffer: Record "EOS Statem. Assets Buffer EXT" temporary;
        AdvCustVendStatRoutines: Codeunit "EOS AdvCustVendStat Routines";
        AssetsEngine: Codeunit "EOS AdvCustVendStat Engine";
        SubscriptionMgt: Codeunit "EOS AdvCustVendStat Subscript";
        CompanyNameText: Text;
        HideMasterTotal: Boolean;
        HideSalespersonTotalPrmtr: Boolean;
        NewPagePerCustomerPrmtr: Boolean;
        NewPagePerSalespersonPrmtr: Boolean;
        OnlyOpenPrmtr: Boolean;
        ShowFiltersPrmtr: Boolean;
        ShowLinkedEntriesPrmtr: Boolean;
        SubscriptionActive: Boolean;
        UseSalespersonFromCustomerPrmtr: Boolean;
        [InDataSet]
        HideSalespersonTotalEnabled: Boolean;
        [InDataSet]
        LinkedEntriesEnabled: Boolean;
        [InDataSet]
        NewPagePerCustomerEnabled: Boolean;
        [InDataSet]
        NewPagePerSalespersonEnabled: Boolean;
        EndingDueDate: Date;
        EndingPostingDate: Date;
        StartingDueDate: Date;
        StartingPostingDate: Date;
        GenericBufferEntryNo: Integer;
        PageGroup: Integer;
        PrevCustomerGroup: Integer;
        PrevSalespersonGroup: Integer;
        ReportLineCount: Integer;
        TempEntryNo: Integer;
        DetailLevelPrmtr: Enum "EOS008 CVD Cust Detail Level";
        SortOrderPrmtr: Enum "EOS008 CVS Cust Detail Order";
        DueDateFilterPrmtr: Text;
        PaymentMethodFilterPrmtr: Text;
        PostingDateFilterPrmtr: Text;
        CustomerFilterTextTxt: Label 'Customer Filters:';
        DueDateFilterTextTxt: Label 'Due Date Filter:';
        ExcludingBalanceTxt: Label 'without';
        IncludingBalanceTextTxt: Label 'with';
        NoSalespersonTxt: Label 'Without Salesperson';
        OnlyOpenTxt: Label ' only open entries';
        PaymentFilterTextTxt: Label 'Payment Filter:';
        PostingDateFilterTextTxt: Label 'Posting Date Filter:';
        ReportSortTextTxt: Label 'Sorted By %1 with %2 detail level %3 linked entries';
        TotalTxt: Label 'Total for %1 %2';

    local procedure GetSalespersonBufferGroup(var BufferAssets: Record "EOS Statem. Assets Buffer EXT" temporary): Text;
    begin
        case SortOrderPrmtr of
            SortOrderPrmtr::SalesPerson:
                exit(BufferAssets."EOS Salesperson Code");
        end;
    end;

    local procedure GetCustomerBufferGroup(var BufferAssets: Record "EOS Statem. Assets Buffer EXT" temporary): Text;
    begin
        case SortOrderPrmtr of
            SortOrderPrmtr::SalesPerson,
          SortOrderPrmtr::Customer:
                exit(BufferAssets."EOS Source No.");
            SortOrderPrmtr::DueDate:
                exit(Format(BufferAssets."EOS Reporting Date 1", 0, 9));
        end;
    end;

    local procedure GetDocumentTypeAbbreviation(DocumentType: Integer): Text;
    var
        AbreviationsTxt: Label ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund,,,,Dishonored';
    begin
        exit(CopyStr(SelectStr(DocumentType + 1, Format(AbreviationsTxt)), 1, 4));
    end;

    local procedure GetBankReceiptAbbreviation() Result: Text;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        StatusAbreviationsTxt: Label ' ,Not Extracted,Extracted,Bill,Issued';
    begin
        if (SortOrderPrmtr = SortOrderPrmtr::Customer) and
           (DetailLevelPrmtr in [DetailLevelPrmtr::Customer, DetailLevelPrmtr::Document]) then
            if TempReportingBuffer."EOS Exposure (LCY)" <> 0 then
                exit(Format(TempReportingBuffer."EOS Exposure (LCY)"))
            else
                exit('');

        Result := SelectStr(TempReportingBuffer."EOS Bank Receipt Status" + 1, Format(StatusAbreviationsTxt));

        if TempReportingBuffer."EOS Bank Receipt Status" in [TempReportingBuffer."EOS Bank Receipt Status"::Extracted .. TempReportingBuffer."EOS Bank Receipt Status"::"Issued Bill"] then
            Result += ' ' + TempReportingBuffer."EOS Customer Bill No.";

        if TempReportingBuffer."EOS Dishonored Entry No." <> 0 then begin
            CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Dishonored;
            Result := Format(CustLedgerEntry."Document Type");
        end;
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
                3, 4:
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
                3, 4:
                    exit(FormatAmount(TempReportingBuffer."EOS Applied Amount (LCY)"));
                5:
                    exit(FormatAmount(TempReportingBuffer."EOS Remaining Amount (LCY)"));
            end;
    end;

    local procedure GetRemainingAmount(): Decimal;
    begin
        if ShowLinkedEntriesPrmtr and (TempReportingBuffer."EOS Level No." = 5) then
            exit(0);

        exit(TempReportingBuffer."EOS Remaining Amount");
    end;

    local procedure GetRemainingAmountLCY(): Decimal;
    begin
        if ShowLinkedEntriesPrmtr and (TempReportingBuffer."EOS Level No." = 5) then
            exit(0);

        exit(TempReportingBuffer."EOS Remaining Amount (LCY)");
    end;

    local procedure GetPaymentMethod(LanguageCode: Code[10]) Result: Text;
    begin
        Result := AdvCustVendStatRoutines.GetPaymentMethodDescription(TempReportingBuffer."EOS Payment Method", LanguageCode);
        if TempReportingBuffer."EOS Dishonored Entry No." <> 0 then
            Result := '*' + Result;
    end;

    local procedure GetReportParametersText() Result: Text;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer2: Record Customer;
        EOSLibraryEXT: Codeunit "EOS Library EXT";
        DetailText: Text;
        SortText: Text;
        WithWithoutText: Text;
    begin
        if not ShowFiltersPrmtr then
            exit('');

        Customer2 := CustomerFilters;
        if OnlyOpenPrmtr then
            Customer2.SetRange("Balance (LCY)");
        if Customer2.GetFilters() <> '' then
            Result := CustomerFilterTextTxt + CustomerFilters.GetFilters() + EOSLibraryEXT.NewLine();

        if PostingDateFilterPrmtr <> '' then
            Result += PostingDateFilterTextTxt + PostingDateFilterPrmtr + EOSLibraryEXT.NewLine();

        if DueDateFilterPrmtr <> '' then
            Result += DueDateFilterTextTxt + DueDateFilterPrmtr + EOSLibraryEXT.NewLine();

        if PaymentMethodFilterPrmtr <> '' then
            Result += PaymentFilterTextTxt + PaymentMethodFilterPrmtr + EOSLibraryEXT.NewLine();

        case SortOrderPrmtr of
            SortOrderPrmtr::Customer:
                SortText := CustLedgerEntry.FIELDCAPTION("Customer No.");
            SortOrderPrmtr::DueDate:
                SortText := CustLedgerEntry.FIELDCAPTION("Due Date");
        end;
        case DetailLevelPrmtr of
            DetailLevelPrmtr::Customer:
                DetailText := CustLedgerEntry.FIELDCAPTION("Customer No.");
            DetailLevelPrmtr::Document:
                DetailText := CustLedgerEntry.FIELDCAPTION("Document No.");
            DetailLevelPrmtr::Duedates:
                DetailText := CustLedgerEntry.FIELDCAPTION("Due Date");
        end;
        if ShowLinkedEntriesPrmtr then
            WithWithoutText := IncludingBalanceTextTxt
        else
            WithWithoutText := ExcludingBalanceTxt;
        Result += StrSubstNo(ReportSortTextTxt, SortText, DetailText, WithWithoutText);
        if OnlyOpenPrmtr then
            Result += OnlyOpenTxt;
    end;

    local procedure GetAmountLabelType(): Text;
    begin
        if ShowLinkedEntriesPrmtr then
            exit('AMOUNT');
    end;

    local procedure GetShowCustomerGroupTotal(): Text;
    begin
        if not (SortOrderPrmtr in [SortOrderPrmtr::SalesPerson, SortOrderPrmtr::Customer]) then
            exit(Format(true));

        if (SortOrderPrmtr in [SortOrderPrmtr::SalesPerson, SortOrderPrmtr::Customer]) and
           (DetailLevelPrmtr <> DetailLevelPrmtr::Customer) then
            exit(Format(true));
    end;

    local procedure GetCustomerGroupTotalText(): Text;
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if PrevCustomerGroup <> TempReportingBuffer."EOS Reporting Group 1" then begin
            PrevCustomerGroup := TempReportingBuffer."EOS Reporting Group 1";
            case SortOrderPrmtr of
                SortOrderPrmtr::SalesPerson,
              SortOrderPrmtr::Customer:
                    exit(StrSubstNo(TotalTxt, TempReportingBuffer."EOS Source No.", TempReportingBuffer."EOS Reporting Subject Name"));
                SortOrderPrmtr::DueDate:
                    exit(StrSubstNo(TotalTxt, CustLedgerEntry.FIELDCAPTION("Due Date"), TempReportingBuffer."EOS Due Date"));
            end;
        end;
    end;

    local procedure GetShowSalespersonGroupTotal(): Text;
    begin
        if (SortOrderPrmtr in [SortOrderPrmtr::SalesPerson]) then
            exit(Format(true));
    end;

    local procedure GetSalespersonGroupTotalText(): Text;
    begin
        if HideSalespersonTotalPrmtr then
            exit('');

        if PrevSalespersonGroup <> TempReportingBuffer."EOS Reporting Group 3" then begin
            PrevSalespersonGroup := TempReportingBuffer."EOS Reporting Group 3";
            case SortOrderPrmtr of
                SortOrderPrmtr::SalesPerson:
                    exit(StrSubstNo(TotalTxt, TempReportingBuffer."EOS Salesperson Code", TempReportingBuffer."EOS Reporting SalesPerson Name"));
                SortOrderPrmtr::DueDate:
                    exit('');
            end;
        end;
    end;

    local procedure GetLineTypeFormat(): Text;
    begin
        // 10 -> main asset (unused)
        // 20 -> asset level 2
        // 21 -> asset level 2 (customername expanded)
        // 30 -> asset level 3 (Payment) and 4 (Dishonored)
        // 50 -> asset level 5 (Document Total)

        case TempReportingBuffer."EOS Level No." of
            1:
                exit('10');
            2:
                if (SortOrderPrmtr in [SortOrderPrmtr::SalesPerson, SortOrderPrmtr::Customer]) and (DetailLevelPrmtr = DetailLevelPrmtr::Customer) then
                    exit('21')
                else
                    exit('20');
            3, 4:
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
        NewPagePerCustomerEnabled := SortOrderPrmtr in [SortOrderPrmtr::SalesPerson, SortOrderPrmtr::Customer];
        NewPagePerSalespersonEnabled := SortOrderPrmtr = SortOrderPrmtr::SalesPerson;
        LinkedEntriesEnabled := ((SortOrderPrmtr in [SortOrderPrmtr::SalesPerson, SortOrderPrmtr::Customer]) and (DetailLevelPrmtr = DetailLevelPrmtr::Duedates)) or
                                (SortOrderPrmtr = SortOrderPrmtr::DueDate);

        if not LinkedEntriesEnabled then
            ShowLinkedEntriesPrmtr := false;

        if NewPagePerSalespersonPrmtr and NewPagePerCustomerPrmtr and (SortOrderPrmtr = SortOrderPrmtr::SalesPerson) then
            HideSalespersonTotalEnabled := false
        else
            HideSalespersonTotalEnabled := true;
    end;

    local procedure FixParameters();
    begin
        if SortOrderPrmtr <> SortOrderPrmtr::SalesPerson then
            NewPagePerSalespersonPrmtr := false;

        if not (SortOrderPrmtr in [SortOrderPrmtr::SalesPerson, SortOrderPrmtr::Customer]) then
            NewPagePerCustomerPrmtr := false;

        if DetailLevelPrmtr <> DetailLevelPrmtr::Duedates then
            ShowLinkedEntriesPrmtr := false;

        if NewPagePerSalespersonPrmtr and NewPagePerCustomerPrmtr and (SortOrderPrmtr = SortOrderPrmtr::SalesPerson) then
            HideSalespersonTotalPrmtr := true;

        HideMasterTotal := NewPagePerSalespersonPrmtr or NewPagePerCustomerPrmtr or HideSalespersonTotalPrmtr;
    end;

    local procedure SetReportParameters()
    var
        Parameters: Record "EOS008 CVS Report Parameters";
        AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
    begin
        // OnlyOpenPrmtr := true;
        // ShowLinkedEntriesPrmtr := false;

        UpdateReqPage();

        if (ParametersBuffer."Customer Vendor Table Filter 1" <> '') or (ParametersBuffer."SalesPerson Table Filter 1" <> '') then
            AdvCustVendStatSharedMem.SetReportParameter(ParametersBuffer); //allows more than 1 parameters assignation
        if AdvCustVendStatSharedMem.GetReportParameter(Parameters) then begin
            OnlyOpenPrmtr := Parameters."Only Open";
            SortOrderPrmtr := Parameters."Customer Detail Order";
            DetailLevelPrmtr := Parameters."Customer Detail Level";
            ShowLinkedEntriesPrmtr := Parameters."Show Linked Entries";
            NewPagePerSalespersonPrmtr := Parameters."New Page Per Salesperson";
            NewPagePerCustomerPrmtr := Parameters."New Page Per Customer";
            UseSalespersonFromCustomerPrmtr := Parameters."Use Salesperson from Customer";
            PostingDateFilterPrmtr := Parameters."Posting Date Filter";
            DueDateFilterPrmtr := Parameters."Due Date Filter";
            PaymentMethodFilterPrmtr := Parameters."Payment Method Filter";
            ShowFiltersPrmtr := Parameters."Print Filters";
            HideSalespersonTotalPrmtr := Parameters."Hide Salesperson Total";

            if Parameters."Customer Vendor Table Filter 1" <> '' then begin
                CustomerFilters.Reset();
                CustomerFilters.SetView(Parameters."Customer Vendor Table Filter 1");
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
        OnlyOpenPrmtr := Set;
    end;

    procedure SetSortingBySalesPerson();
    begin
        SortOrderPrmtr := SortOrderPrmtr::SalesPerson;
    end;

    procedure SetSortingBySalesCustomer();
    begin
        SortOrderPrmtr := SortOrderPrmtr::Customer;
    end;

    procedure SetSortingBySalesDueDate();
    begin
        SortOrderPrmtr := SortOrderPrmtr::DueDate;
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

    procedure SetShowLinkedEntries(Set: Boolean);
    begin
        ShowLinkedEntriesPrmtr := Set;
    end;

    procedure SetNewPagePerSalesperson(Set: Boolean);
    begin
        NewPagePerSalespersonEnabled := Set;
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

    procedure SetPrintFilters(Set: Boolean);
    begin
        ShowFiltersPrmtr := Set;
    end;

    procedure SetHideTotals(Set: Boolean);
    begin
        HideSalespersonTotalPrmtr := Set;
    end;

    procedure GetReportLineCount(): Integer;
    begin
        exit(ReportLineCount);
    end;

    procedure GetProcessedCustomerList(var List: Record Customer);
    begin
        Clear(List);
        Clear(TempProcessedCustomerList);
        if TempProcessedCustomerList.FindSet() then
            repeat
                List := TempProcessedCustomerList;
                List.Insert();
            until TempProcessedCustomerList.Next() = 0;
    end;

    local procedure GetSelectionFilterForSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser"): Text
    var
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
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
    local procedure OnAfterBuildReportingDataset(SourceView: Text; DateFilterType: Option "Posting Date","Document Date"; StartingDate: Date; EndingDate: Date; StartingDueDate: Date; EndingDueDate: Date; OnlyOpen: Boolean; AllowPartialOpenDoc: Boolean; DocumentFilter: Text; var TempBufferAssets: Record "EOS Statem. Assets Buffer EXT"; var TempReportingBuffer: Record "EOS Statem. Assets Buffer EXT")
    begin
    end;
}

