report 18123357 "EOS Send fin. rpt to salesp"
{
    Caption = 'Send financial reports to salesperson (CVS)';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    //AdditionalSearchTerms = 'customer vendor statement, partitario, scadenzario';     // only with runtime version 3.0

    dataset
    {
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting(Code);
            RequestFilterFields = "Code", Name;

            trigger OnAfterGetRecord();
            var
                Customer: Record Customer;
                CustomerList: List of [code[20]];
                CustomerList2: List of [code[20]];
                SalesPersonBasePath: Text;
                CustomerBasePath: Text;
                FileName: Text;
                Handled: Boolean;
                CustomerNo: Code[20];
            begin
                OnBeforeProcessSalesperson("Salesperson/Purchaser", DataCompression, EnumProcTypePrmtr, Handled);
                if Handled then
                    CurrReport.Skip();

                Window.Update(1, Code);

                SalesPersonBasePath := ServerBasePath + FileManagement.StripNotsupportChrInFileName(Code + ' ' + Name) + '\';
                FileName := SalesPersonBasePath + FileManagement.StripNotsupportChrInFileName(StrSubstNo(SalesPersonSummaryTxt, Code, Name)) + '.pdf';

                Clear(CustomerList);
                if (CreateLineAgingWithCheck('', DetailLevelPrmtr::Customer, FileName, CustomerList, true) = 0) or (CustomerList.Count = 0) then
                    CurrReport.Skip();

                if OnePDFperCustomerPrmtr then
                    foreach CustomerNo in CustomerList do begin
                        Customer.Get(CustomerNo);
                        Clear(CustomerList2);
                        CustomerBasePath := SalesPersonBasePath + FileManagement.StripNotsupportChrInFileName(CustomerNo + ' ' + Customer.Name) + '\';

                        if ProcessLineAgingPrmtr then begin
                            FileName := CustomerBasePath + FileManagement.StripNotsupportChrInFileName(AgingTxt) + '.pdf';
                            CreateLineAging(CustomerNo, DetailLevelPrmtr, FileName, CustomerList2);
                        end;

                        if ProcessColumnAgingPrmtr then begin
                            FileName := CustomerBasePath + FileManagement.StripNotsupportChrInFileName(ColumnAgingTxt) + '.pdf';
                            CreateColumnAging(CustomerNo, DetailLevelPrmtr, FileName);
                        end;

                        SetLanguage(Customer."Language Code");
                        if ProcessStatementPrmtr then begin
                            FileName := CustomerBasePath + FileManagement.StripNotsupportChrInFileName(StatementTxt) + '.pdf';
                            CreateStatement(CustomerNo, DetailLevelPrmtr, FileName);
                        end;
                        ResetLanguage();
                    end
                else begin
                    if ProcessLineAgingPrmtr then begin
                        FileName := SalesPersonBasePath + FileManagement.StripNotsupportChrInFileName(AgingTxt) + '.pdf';
                        CreateLineAging('', DetailLevelPrmtr, FileName, CustomerList2);
                    end;

                    if ProcessColumnAgingPrmtr then begin
                        FileName := SalesPersonBasePath + FileManagement.StripNotsupportChrInFileName(ColumnAgingTxt) + '.pdf';
                        CreateColumnAging('', DetailLevelPrmtr, FileName);
                    end;

                    if ProcessStatementPrmtr then begin
                        FileName := SalesPersonBasePath + FileManagement.StripNotsupportChrInFileName(StatementTxt) + '.pdf';
                        CreateStatement('', DetailLevelPrmtr, FileName);
                    end;
                end;

                OnAfterProcessSalespersonPurchaser("Salesperson/Purchaser");
                OnManageProcessingTypeForSalespersonPurchaser("Salesperson/Purchaser", DataCompression, EnumProcTypePrmtr, ReportSetupPrmtr, Handled);
                if Handled then
                    CurrReport.Skip();

                /*if BatchProcessingType = BatchProcessingType::Send then begin
                    ZipFileName := CreateZipFile(ServerBasePath);
                    //SendZip("Vendor No.", ZipFileName);
                    MailProcessed += 1;
                end;*/
            end;

            trigger OnPostDataItem();
            var
                ClientFileName: Text;
                Handled: Boolean;
            begin

                OnPostDataItemSalespersonPurchaser_ManageEnumProcType(EnumProcTypePrmtr, Handled);
                if not Handled then
                    case EnumProcTypePrmtr of
                        EnumProcTypePrmtr::SaveToFile:
                            begin
                                DataCompression.SaveZipArchive(outStreamZip);
                                ClientFileName := AgingTxt + '.zip';
                                ZipBlob.CreateInStream(inStreamZip);
                                DownloadFromStream(inStreamZip, SaveAsTxt, '', 'Zip File (*.zip)|*.zip', ClientFileName);
                                DataCompression.CloseZipArchive();
                            end;
                    end;
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
                group(Allgemein)
                {
                    Caption = 'General';
                    field(EnumProcType; EnumProcTypePrmtr)
                    {
                        Caption = 'Batch processing type';
                        ApplicationArea = All;

                        trigger OnValidate();
                        begin
                            UpdateRequestPage();
                        end;
                    }
                    group(ReportSetupGroup)
                    {
                        ShowCaption = false;
                        Visible = ReportSetupEnabled;
                        field(ReportSetup; ReportSetupPrmtr)
                        {
                            Caption = 'Report Setup';
                            Enabled = ReportSetupEnabled;
                            ApplicationArea = All;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                exit(tryOpenLookupPage(Text));
                            end;
                        }
                    }
                    field(OnePDFperCustomer; OnePDFperCustomerPrmtr)
                    {
                        Caption = 'One PDF per Customer';
                        ApplicationArea = All;
                    }
                    field(ProcessLineAging; ProcessLineAgingPrmtr)
                    {
                        Caption = 'Process Line Aging';
                        ApplicationArea = All;

                        trigger OnValidate();
                        begin
                            UpdateRequestPage();
                        end;
                    }
                    field(ProcessColumnAging; ProcessColumnAgingPrmtr)
                    {
                        Caption = 'Process Column Aging';
                        ApplicationArea = All;

                        trigger OnValidate();
                        begin
                            UpdateRequestPage();
                        end;
                    }
                    field(ProcessStatement; ProcessStatementPrmtr)
                    {
                        Caption = 'Process Account Statement';
                        ApplicationArea = All;

                        trigger OnValidate();
                        begin
                            UpdateRequestPage();
                        end;
                    }
                    field(OnlyOpen; OnlyOpenPrmtr)
                    {
                        Caption = 'Only Open Entries';
                        ApplicationArea = All;
                    }
                    field(DetailLevel; DetailLevelPrmtr)
                    {
                        Caption = 'Detail Level';
                        ApplicationArea = All;

                        trigger OnValidate();
                        begin
                            UpdateRequestPage();
                        end;
                    }
                    field(ShowLinkedEntries; ShowLinkedEntriesPrmtr)
                    {
                        Caption = 'Show Linked Entries';
                        Enabled = ShowLinkedEntriesEnabled;
                        ApplicationArea = All;
                    }
                    field(UseSalespersonFromCustomer; UseSalespersonFromCustomerPrmtr)
                    {
                        Caption = 'Use Salesperson from Customer';
                        ApplicationArea = All;
                    }
                    field(PostingDateFilter; PostingDateFilterPrmtr)
                    {
                        Caption = 'Posting Date Filter';
                        ApplicationArea = All;
                    }
                    field(DueDateFilter; DueDateFilterPrmtr)
                    {
                        Caption = 'Due Date Filter';
                        ApplicationArea = All;
                    }
                    field(PaymentMethodFilter; PaymentMethodFilterPrmtr)
                    {
                        Caption = 'Payment Method Filter';
                        TableRelation = "Payment Method";
                        ApplicationArea = All;
                    }
                }
                group("Fälligkeitsregister in Spalte")
                {
                    Caption = 'Column Aging';
                    field(DueDateAt; DueDateAtPrmtr)
                    {
                        Caption = 'Aged As Of';
                        Enabled = ColumnFieldsEnabled;
                        ApplicationArea = All;
                    }
                    field(PeriodLength; PeriodLengthPrmtr)
                    {
                        Caption = 'Period Length';
                        Enabled = ColumnFieldsEnabled;
                        ApplicationArea = All;
                    }
                    field(PrintAmountInLCY; PrintAmountInLCYPrmtr)
                    {
                        Caption = 'Print Amounts in LCY';
                        Enabled = ColumnFieldsEnabled;
                        ApplicationArea = All;
                    }
                    field(ColumnLayout; ColumnLayoutPrmtr)
                    {
                        Caption = 'Column Count due/to be due';
                        Enabled = ColumnFieldsEnabled;
                        ApplicationArea = All;
                    }
                }
            }
        }

        trigger OnOpenPage();
        begin
            CurrReport.RequestOptionsPage.Caption := CurrReport.RequestOptionsPage.Caption() + SubscriptionMgt.GetLicenseText();
            UpdateRequestPage();
        end;
    }

    trigger OnPostReport();
    var
        Handled: Boolean;
    begin
        Window.Close();

        OnPostReport_OnBeforeManageEnumProcType(EnumProcTypePrmtr, Handled);
        if not Handled then
            case EnumProcTypePrmtr of
                EnumProcTypePrmtr::SaveToFile:
                    Message(CompletedTxt);
            //BatchProcessingType::Send:
            //    MESSAGE(MailSentTxt, MailProcessed);
            end;

    end;

    trigger OnInitReport()
    begin
        DataCompression.CreateZipArchive();
    end;

    trigger OnPreReport();
    begin
        ValidateParameters();

        Window.OPEN('#1#############');

        ZipBlob.CreateOutStream(outStreamZip);
    end;

    var
        Language: Record "Language";
        ZipBlob: Codeunit "Temp Blob";
        DataCompression: Codeunit "Data Compression";
        FileManagement: Codeunit "File Management";
        SubscriptionMgt: Codeunit "EOS AdvCustVendStat Subscript";
        PeriodLengthPrmtr: DateFormula;
        Window: Dialog;
        ProcessLineAgingPrmtr: Boolean;
        ProcessColumnAgingPrmtr: Boolean;
        ProcessStatementPrmtr: Boolean;
        ReportSetupPrmtr: Code[20];
        PostingDateFilterPrmtr: Text;
        DueDateFilterPrmtr: Text;
        PaymentMethodFilterPrmtr: Text;
        DetailLevelPrmtr: Enum "EOS008 CVD Cust Detail Level";
        OnlyOpenPrmtr: Boolean;
        ShowLinkedEntriesPrmtr: Boolean;
        UseSalespersonFromCustomerPrmtr: Boolean;
        DueDateAtPrmtr: Date;
        ColumnLayoutPrmtr: enum "EOS008 CVD Cust Column setup";
        PrintAmountInLCYPrmtr: Boolean;
        ServerBasePath: Text;
        SalesPersonSummaryTxt: Label 'Summary %1 %2';
        AgingTxt: Label 'Aging';
        //BatchProcessingType: Option Save,Send;
        EnumProcTypePrmtr: Enum "EOS AdvCustVendStat BatchProcType";
        OnePDFperCustomerPrmtr: Boolean;
        ColumnAgingTxt: Label 'Column Aging';
        StatementTxt: Label 'Account statement';
        SaveAsTxt: Label 'Save as...';
        [InDataSet]
        ColumnFieldsEnabled: Boolean;
        [InDataSet]
        ShowLinkedEntriesEnabled: Boolean;
        NothingToDoTxt: Label 'You must select at least one report to process.';
        MissingParameterTxt: Label 'You must specify %1.';
        DueDateTxt: Label '"Aged As Of"';
        PeriodLengthTxt: Label '"Period Length"';
        [InDataSet]
        ReportSetupEnabled: Boolean;
        CompletedTxt: Label 'Operation completed.';
        //MailSentTxt: Label 'Sent %1 E-Mails. To verify the success or failure see the log.';
        OldLanguage: Integer;
        outStreamReport: OutStream;
        inStreamReport: InStream;

        outStreamZip: OutStream;
        inStreamZip: InStream;

    local procedure UpdateRequestPage();
    begin
        ColumnFieldsEnabled := ProcessColumnAgingPrmtr;
        ShowLinkedEntriesEnabled := (DetailLevelPrmtr = DetailLevelPrmtr::Duedates) and
                                    (ProcessLineAgingPrmtr or ProcessStatementPrmtr);

        OnUpdateRequestPage(EnumProcTypePrmtr, ReportSetupEnabled);
        //ReportSetupEnabled := BatchProcessingType = BatchProcessingType::Send;
    end;

    local procedure ValidateParameters();
    begin
        if (not ProcessLineAgingPrmtr) and (not ProcessColumnAgingPrmtr) and (not ProcessStatementPrmtr) then
            Error(NothingToDoTxt);

        if ProcessColumnAgingPrmtr then begin
            if DueDateAtPrmtr = 0D then
                Error(MissingParameterTxt, DueDateTxt);
            if Format(PeriodLengthPrmtr) = '' then
                Error(MissingParameterTxt, PeriodLengthTxt);
        end;
    end;

    [TryFunction]
    local procedure tryOpenLookupPage(var pText: Text)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        VarRecord: Variant;
    begin
        RecRef.Open(18122007);
        VarRecord := RecRef;
        if Page.RunModal(0, VarRecord) = Action::LookupOK then begin
            RecRef.GetTable(VarRecord);
            FldRef := RecRef.field(1);
            pText := FldRef.Value();
        end;
    end;

    local procedure CreateLineAging(CustomerNo: Code[20]; DetailLevel2: Enum "EOS008 CVD Cust Detail Level"; FileName: Text; var ProcessedCustomerList: List of [code[20]]): Integer;
    begin
        CreateLineAgingWithCheck(CustomerNo, DetailLevel2, FileName, ProcessedCustomerList, false);
    end;

    local procedure CreateLineAgingWithCheck(CustomerNo: Code[20]; DetailLevel2: Enum "EOS008 CVD Cust Detail Level"; FileName: Text; var ProcessedCustomerList: List of [code[20]]; CheckExistingLinesExecutions: Boolean): Integer;
    // CheckExistingLinesExecutions: if this parameter is true, this means that we check existing lines before inserting the File to the Stream
    var
        SalespersonPurchaser2: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        ReportBlob: Codeunit "Temp Blob";
        handled: Boolean;
        CVSReportParameters: Record "EOS008 CVS Report Parameters";
        AdvCustVendStatSetup: Record "EOS AdvCustVendStat Setup EXT";
        AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
        DataTypeManagement: Codeunit "Data Type Management";
        ReportLineCount: Integer;
        CustRecRef: RecordRef;
    begin
        //        NPCustomerAging: Report "EOS Customer Aging";
        AdvCustVendStatSetup.Get();
        AdvCustVendStatSetup.InitializeReportID(false);

        SalespersonPurchaser2 := "Salesperson/Purchaser";
        SalespersonPurchaser2.SETRECFILTER();

        // NPCustomerAging.SetTableView(SalespersonPurchaser2);

        if CustomerNo <> '' then begin
            Customer.Get(CustomerNo);
            Customer.SETRECFILTER();
            // NPCustomerAging.SetTableView(Customer);
        end else begin
            Customer.Reset();
            // NPCustomerAging.SetTableView(Customer);
        end;

        Handled := false;
        onBeforeCreateLineAging(Customer, EnumProcTypePrmtr, Handled);
        if Handled then
            exit;

        DataTypeManagement.GetRecordRef(Customer, CustRecRef);

        SetGlobalReportParameter(CVSReportParameters);
        CVSReportParameters."Customer Detail Level" := DetailLevel2;
        CVSReportParameters."Customer Vendor Table Filter 1" := CopyStr(Customer.GetView(false), 1, MaxStrLen(CVSReportParameters."Customer Vendor Table Filter 1"));
        CVSReportParameters."SalesPerson Table Filter 1" := CopyStr(SalespersonPurchaser2.GetView(false), 1, MaxStrLen(CVSReportParameters."SalesPerson Table Filter 1"));
        AdvCustVendStatSharedMem.SetReportParameter(CVSReportParameters);

        ReportBlob.CreateOutStream(outStreamReport);
        //NPCustomerAging.SaveAs(Report.RunRequestPage(Report::"EOS Customer Aging EXT"), ReportFormat::Pdf, outStreamReport);
        Report.SaveAs(AdvCustVendStatSetup."Customer Aging Report ID", '', ReportFormat::Pdf, outStreamReport);

        AdvCustVendStatSharedMem.GetProcessedCustomerList(ProcessedCustomerList);
        ReportLineCount := AdvCustVendStatSharedMem.GetReportLineCount();

        If CheckExistingLinesExecutions AND (ReportLineCount <> 0) AND (ProcessedCustomerList.Count <> 0) then begin
            ReportBlob.CreateInStream(inStreamReport);
            DataCompression.AddEntry(inStreamReport, FileName);
        end;

        If (NOT CheckExistingLinesExecutions) AND (ReportLineCount <> 0) AND (ProcessedCustomerList.Count <> 0) then begin
            ReportBlob.CreateInStream(inStreamReport);
            DataCompression.AddEntry(inStreamReport, FileName);
        end;

        exit(ReportLineCount);
    end;

    local procedure CreateColumnAging(CustomerNo: Code[20]; DetailLevel2: Enum "EOS008 CVD Cust Detail Level"; FileName: Text): Integer;
    var
        SalespersonPurchaser2: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        ReportBlob: Codeunit "Temp Blob";
        handled: Boolean;
        CVSReportParameters: Record "EOS008 CVS Report Parameters";
        AdvCustVendStatSetup: Record "EOS AdvCustVendStat Setup EXT";
        AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
    begin
        AdvCustVendStatSetup.Get();
        AdvCustVendStatSetup.InitializeReportID(false);

        SalespersonPurchaser2 := "Salesperson/Purchaser";
        SalespersonPurchaser2.SETRECFILTER();

        Handled := false;
        OnBeforeCreateColumnAging(Customer, EnumProcTypePrmtr, Handled);
        if Handled then
            exit;

        if CustomerNo <> '' then begin
            Customer.Get(CustomerNo);
            Customer.SETRECFILTER();
        end;

        SetGlobalReportParameter(CVSReportParameters);
        CVSReportParameters."Customer Detail Level" := DetailLevel2;
        CVSReportParameters."Customer Vendor Table Filter 1" := CopyStr(Customer.GetView(false), 1, MaxStrLen(CVSReportParameters."Customer Vendor Table Filter 1"));
        CVSReportParameters."SalesPerson Table Filter 1" := CopyStr(SalespersonPurchaser2.GetView(false), 1, MaxStrLen(CVSReportParameters."SalesPerson Table Filter 1"));
        AdvCustVendStatSharedMem.SetReportParameter(CVSReportParameters);

        ReportBlob.CreateOutStream(outStreamReport);
        //NPCustomerAgingInColumn.SaveAs(Report.RunRequestPage(Report::"EOS Cust Aging In Column EXT"), ReportFormat::Pdf, outStreamReport);
        Report.SaveAs(AdvCustVendStatSetup."Vendor Aging Col Report ID", '', ReportFormat::Pdf, outStreamReport);
        ReportBlob.CreateInStream(inStreamReport);
        DataCompression.AddEntry(inStreamReport, FileName);

        exit(AdvCustVendStatSharedMem.GetReportLineCount());
    end;

    local procedure CreateStatement(CustomerNo: Code[20]; DetailLevel2: Enum "EOS008 CVD Cust Detail Level"; FileName: Text);
    var
        SalespersonPurchaser2: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        ReportBlob: Codeunit "Temp Blob";
        handled: Boolean;
        CVSReportParameters: Record "EOS008 CVS Report Parameters";
        AdvCustVendStatSetup: Record "EOS AdvCustVendStat Setup EXT";
        AdvCustVendStatSharedMem: Codeunit "EOS AdvCustVendStat SharedMem";
    begin
        //        NPCustomerStatement: Report "EOS Customer Statement";       
        AdvCustVendStatSetup.Get();
        AdvCustVendStatSetup.InitializeReportID(false);

        // Clear(NPCustomerStatement);

        SalespersonPurchaser2 := "Salesperson/Purchaser";
        SalespersonPurchaser2.SETRECFILTER();

        Handled := false;
        onBeforeCreateStatement(Customer, EnumProcTypePrmtr, Handled);
        if Handled then
            exit;

        if CustomerNo <> '' then begin
            Customer.Get(CustomerNo);
            Customer.SETRECFILTER();
        end;

        SetGlobalReportParameter(CVSReportParameters);
        CVSReportParameters."Customer Detail Level" := DetailLevel2;
        CVSReportParameters."Customer Vendor Table Filter 1" := CopyStr(Customer.GetView(false), 1, MaxStrLen(CVSReportParameters."Customer Vendor Table Filter 1"));
        CVSReportParameters."SalesPerson Table Filter 1" := CopyStr(SalespersonPurchaser2.GetView(false), 1, MaxStrLen(CVSReportParameters."SalesPerson Table Filter 1"));
        AdvCustVendStatSharedMem.SetReportParameter(CVSReportParameters);

        ReportBlob.CreateOutStream(outStreamReport);

        // Temporary fix, because running the report with this paramter empty caused the NAV crash
        //ReportParameters := '<?xml version="1.0" standalone="yes"?><ReportParameters name="EOS Customer Statement EXT" id="18004255"><Options><Field name="OnlyOpen">false</Field><Field name="ShowLinkedEntries">true</Field><Field name="PostingDateFilter" /><Field name="DueDateFilter" /><Field name="PaymentMethodFilter" /><Field name="UseSalespersonFromCustomer">true</Field><Field name="SupportedOutputMethod">0</Field><Field name="ChosenOutputMethod">1</Field></Options><DataItems><DataItem name="Customer">VERSION(1) SORTING(Field1)</DataItem><DataItem name="SalespersonFilters">VERSION(1) SORTING(Field1)</DataItem><DataItem name="ReportHeaderValues">VERSION(1) SORTING(Field1)</DataItem><DataItem name="DataProcessing">VERSION(1) SORTING(Field1)</DataItem><DataItem name="CustomerPrint">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Detail">VERSION(1) SORTING(Field1)</DataItem><DataItem name="DueDetail">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>';
        Report.SaveAs(AdvCustVendStatSetup."Customer Statement Report ID", '', ReportFormat::Pdf, outStreamReport);
        ReportBlob.CreateInStream(inStreamReport);
        DataCompression.AddEntry(inStreamReport, FileName);
    end;

    local procedure CreateZipFile(BasePath: Text): Text;
    var
    begin
        /*FileCount := EOSLibrary.GenerateFolderFilesList(BasePath, '*.*', TRUE, TRUE);
        if FileCount = 0 then
            exit('');

        ZipFileName := FileManagement2.CreateZipArchiveObject;

        for i := 1 TO FileCount do begin
            FileName := EOSLibrary.GetFilenameFromFileList(i);
            FileManagement2.AddFileToZipArchive(FileName, COPYSTR(FileName, STRLEN(BasePath) + 1));
        end;

        FileManagement2.CloseZipArchive;
        exit(ZipFileName);*/
    end;

    local procedure SendZip(VendorNo: Code[20]; ZipFileName: Text);
    var
    //PDFQueueMgt: Codeunit 18006528;
    //PDFQueueRequest: Record 18004161;
    /*Vendor: Record "Vendor";
    TempBlob: Record 99008535;
    WorkFile: File;
    RecRef: RecordRef;
    IStream: InStream;
    OStream: OutStream;
    AllObjWithCaption: Record 2000000058;*/
    begin
        /*Vendor.GET(VendorNo);

        RecRef.GETTABLE(Vendor);
        RecRef.SETRECFILTER;

        WorkFile.WRITEMODE(false);
        WorkFile.TEXTMODE(false);
        WorkFile.OPEN(ZipFileName);
        WorkFile.CREATEINSTREAM(IStream);
        TempBlob.Blob.CREATEOUTSTREAM(OStream);
        COPYSTREAM(OStream, IStream);
        WorkFile.CLOSE;

        if EVALUATE(AllObjWithCaption."Object ID", CurrReport.OBJECTID(false)) then begin
            AllObjWithCaption."Object Type" := AllObjWithCaption."Object Type"::Report;
            AllObjWithCaption.SETRECFILTER;
            AllObjWithCaption.Find('=');
        end;

        PDFQueueRequest."Custom Attachment" := TempBlob.Blob;
        PDFQueueRequest."Custom Attachment Format" := 'ZIP';
        PDFQueueRequest."Document Description" := COPYSTR(AllObjWithCaption."Object Caption", 1, MAXSTRLEN(PDFQueueRequest."Document Description"));
        PDFQueueMgt.CreatePDFQueueRequest(PDFQueueRequest, RecRef, PDFQueueRequest.Type::Mail, FALSE);

        PDFQueueRequest.VALIDATE("Report Setup Code", ReportSetup);

        PDFQueueRequest.Execute(false);*/
    end;

    local procedure SetGlobalReportParameter(var CVSReportParameters: Record "EOS008 CVS Report Parameters")
    begin
        CVSReportParameters.Init();
        CVSReportParameters."Only Open" := OnlyOpenPrmtr;
        CVSReportParameters."Show Linked Entries" := ShowLinkedEntriesPrmtr;
        CVSReportParameters."Period Length" := PeriodLengthPrmtr;
        CVSReportParameters."Aged As Of" := DueDateAtPrmtr;
        CVSReportParameters."Posting Date Filter" := CopyStr(PostingDateFilterPrmtr, 1, MaxStrLen(CVSReportParameters."Posting Date Filter"));
        CVSReportParameters."Due Date Filter" := CopyStr(DueDateFilterPrmtr, 1, MaxStrLen(CVSReportParameters."Due Date Filter"));
        CVSReportParameters."Payment Method Filter" := CopyStr(PaymentMethodFilterPrmtr, 1, MaxStrLen(CVSReportParameters."Payment Method Filter"));
        CVSReportParameters."Use Salesperson from Customer" := UseSalespersonFromCustomerPrmtr;
    end;


    local procedure SetLanguage(LanguageCode: Code[10]);
    begin
        if Language.Get(LanguageCode) then begin
            OldLanguage := GLOBALLANGUAGE();
            GLOBALLANGUAGE := Language."Windows Language ID";
        end;
    end;

    procedure ResetLanguage();
    begin
        if (GLOBALLANGUAGE() <> OldLanguage) and
           (OldLanguage <> 0)
        then begin
            GLOBALLANGUAGE := OldLanguage;
            OldLanguage := 0;
        end;
    end;

    procedure SetProcessingTypeSave();
    begin
        EnumProcTypePrmtr := EnumProcTypePrmtr::SaveToFile;
    end;

    /// <summary>Event to manage what to do when the Salesperson/Purchase has been processed</summary>
    /// <parameter name="SalespersonPurchaser">the salesperson/purchaser processed</parameter>
    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessSalespersonPurchaser(var SalespersonPurchaser: Record "Salesperson/Purchaser")
    begin
    end;

    /// <summary>Event executed OnAfterProcessSalespersonPurchaser, this allows to manage procedures run for each Salesperson/Purchaser.</summary>
    /// <param name="SalespersonPurchaser">Record "Salesperson/Purchaser"</param>
    /// <param name="ZipBlob">Record "TempBlob" temporary</param>
    /// <param name="EnumProcType">Enum "EOS AdvCustVendStat BatchProcType"</param>
    /// <param name="Handled">Boolean</param>
    [IntegrationEvent(false, false)]
    // local procedure OnManageProcessingTypeForSalespersonPurchaser(var SalespersonPurchaser: Record "Salesperson/Purchaser"; var ZipBlob: Record TempBlob; EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; ReportSetup: Code[20]; var Handled: Boolean)
    local procedure OnManageProcessingTypeForSalespersonPurchaser(var SalespersonPurchaser: Record "Salesperson/Purchaser"; var ZipArchive: Codeunit "Data Compression"; EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; ReportSetup: Code[20]; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Event exexuted in the onPostDataItem of the SalespersonPurchaser data item.
    /// There is possible to execute functions at the end of the run of the data item.
    /// Set Handled a true to disable the handling of EnumProcessType bt the default code.
    /// </summary>
    /// <param name="EnumProcType">Enum "EOS AdvCustVendStat BatchProcType"</param>
    /// <param name="Handled">Boolean</param>
    [IntegrationEvent(false, false)]
    local procedure OnPostDataItemSalespersonPurchaser_ManageEnumProcType(EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Event execute OnPostReport before the standard management of Enum "EOS AdvCustVendStat BatchProcType"
    /// There is possibile to execute something at the end of the report.
    /// </summary>
    /// <param name="EnumProcType">Enum "EOS AdvCustVendStat BatchProcType"</param>
    /// <param name="Handled">Boolean</param>
    [IntegrationEvent(false, false)]
    local procedure OnPostReport_OnBeforeManageEnumProcType(EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; var Handled: Boolean)
    begin
    end;

    /// <summary>Event to edit the ReqestPage based on Enum "EOS AdvCustVendStat BatchProcType"</summary>
    /// <param name="EnumProcType">Enum "EOS AdvCustVendStat BatchProcType"</param>
    /// <param name="ReportSetupEnabled">Boolean</param>
    [IntegrationEvent(false, false)]
    local procedure OnUpdateRequestPage(EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; var ReportSetupEnabled: Boolean);
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure onBeforeCreateLineAging(Customer: Record Customer; EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; var handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateColumnAging(Customer: Record Customer; EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; var handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure onBeforeCreateStatement(Customer: Record Customer; EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; var handled: Boolean);
    begin
    end;

    /// <summary>Event executed before the beginning of processing of the customer, this allows to manage procedures run for each Customer.</summary>
    /// <param name="Customer">Record Customer</param>
    /// <param name="ZipBlob">Record "TempBlob" temporary</param>
    /// <param name="outStreamZip"></param>
    /// <param name="EnumProcType">Enum "EOS AdvCustVendStat BatchProcType"</param>
    /// <param name="Handled">Allows you to skip the processing of this customer</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessSalesperson(var SalespersonPurchaser: Record "Salesperson/Purchaser"; var ZipArchive: Codeunit "Data Compression"; EnumProcType: Enum "EOS AdvCustVendStat BatchProcType"; var Handled: Boolean)
    begin
    end;
}

