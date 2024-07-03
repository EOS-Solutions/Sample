report 18122011 "EOS Reminder Document"
{

    Caption = 'EOS Reminder Document (ADR)';
    Permissions = TableData "VAT Clause" = r,
                  TableData "VAT Clause Translation" = r;
    PreviewMode = PrintLayout;
    UsageCategory = None;
    DefaultRenderingLayout = Default;

    dataset
    {
        dataitem(FakeReminderHeader; "Reminder Header")
        {
            DataItemTableView = sorting("No.");
            Description = 'Fake Reminder Header, Only for Report Selection Integration';
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(FakeIssuedReminderHeader; "Issued Reminder Header")
        {
            DataItemTableView = sorting("No.");
            Description = 'Fake Issued Reminder Header, Only for Report Selection Integration';
            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
        dataitem(HeaderLoop; "EOS Report Buffer Header")
        {
            UseTemporary = true;
            DataItemTableView = sorting("EOS No.");
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(IsDeliveryReminder; false) { }
                column(HeaderImage; HeaderLoop."EOS Header Image") { }
                column(FooterImage; HeaderLoop."EOS Footer Image") { }
                column(ReportTitle; HeaderLoop."EOS Report Title") { }
                column(CopyNo; Number) { }
                column(DocumentNo; HeaderLoop."EOS No.") { }
                column(PostingDate; HeaderLoop."EOS Posting Date") { }
                column(Salesperson; Salesperson.Name) { }
                column(OperatorName; Employee.FullName()) { }
                column(SellToCustNo; HeaderLoop."EOS Sell-to/Buy-From No.") { }
                column(SellToAddress; HeaderLoop.GetSellToBuyFromAddr()) { }
                column(BillToNo; HeaderLoop."EOS Bill-to/Pay-to No.") { }
                column(BillToAddress; HeaderLoop.GetBillToPayToAddr()) { }
                column(ReminderLevel; HeaderLoop."EOS Reminder Level") { }
                column(CustomerContact; SellToContact.Name) { }
                column(CustomerEMail; SellToContact."E-Mail") { }
                column(VATRegNo; HeaderLoop."EOS VAT Registration No.") { }
                column(FiscalCode; HeaderLoop."EOS Fiscal Code") { }
                column(AddressPosition; Format(ReportSetup."EOS Address Position", 0, 9)) { }

                column(CstmHdrTxt1; HeaderLoop.GetCustomFieldTextValue('CustomText1')) { }
                column(CstmHdrTxt2; HeaderLoop.GetCustomFieldTextValue('CustomText2')) { }
                column(CstmHdrTxt3; HeaderLoop.GetCustomFieldTextValue('CustomText3')) { }
                column(CstmHdrTxt4; HeaderLoop.GetCustomFieldTextValue('CustomText4')) { }
                column(CstmHdrTxt5; HeaderLoop.GetCustomFieldTextValue('CustomText5')) { }
                column(CstmHdrTxt6; HeaderLoop.GetCustomFieldTextValue('CustomText6')) { }
                column(CstmHdrTxt7; HeaderLoop.GetCustomFieldTextValue('CustomText7')) { }
                column(CstmHdrTxt8; HeaderLoop.GetCustomFieldTextValue('CustomText8')) { }
                column(CstmHdrTxt9; HeaderLoop.GetCustomFieldTextValue('CustomText9')) { }
                column(CstmHdrTxt10; HeaderLoop.GetCustomFieldTextValue('CustomText10')) { }
                column(CstmHdrTxt11; HeaderLoop.GetCustomFieldTextValue('CustomText11')) { }
                column(CstmHdrTxt12; HeaderLoop.GetCustomFieldTextValue('CustomText12')) { }
                column(CstmHdrTxt13; HeaderLoop.GetCustomFieldTextValue('CustomText13')) { }
                column(CstmHdrTxt14; HeaderLoop.GetCustomFieldTextValue('CustomText14')) { }
                column(CstmHdrTxt15; HeaderLoop.GetCustomFieldTextValue('CustomText15')) { }
                column(CstmHdrTxt16; HeaderLoop.GetCustomFieldTextValue('CustomText16')) { }
                column(CstmHdrTxt17; HeaderLoop.GetCustomFieldTextValue('CustomText17')) { }
                column(CstmHdrTxt18; HeaderLoop.GetCustomFieldTextValue('CustomText18')) { }
                column(CstmHdrTxt19; HeaderLoop.GetCustomFieldTextValue('CustomText19')) { }
                column(CstmHdrTxt20; HeaderLoop.GetCustomFieldTextValue('CustomText20')) { }
                column(CstmHdrTxt21; HeaderLoop.GetCustomFieldTextValue('CustomText21')) { }
                column(CstmHdrTxt22; HeaderLoop.GetCustomFieldTextValue('CustomText22')) { }
                column(CstmHdrTxt23; HeaderLoop.GetCustomFieldTextValue('CustomText23')) { }
                column(CstmHdrTxt24; HeaderLoop.GetCustomFieldTextValue('CustomText24')) { }
                column(CstmHdrTxt25; HeaderLoop.GetCustomFieldTextValue('CustomText25')) { }
                column(CstmHdrTxt26; HeaderLoop.GetCustomFieldTextValue('CustomText26')) { }
                column(CstmHdrTxt27; HeaderLoop.GetCustomFieldTextValue('CustomText27')) { }
                column(CstmHdrTxt28; HeaderLoop.GetCustomFieldTextValue('CustomText28')) { }
                column(CstmHdrTxt29; HeaderLoop.GetCustomFieldTextValue('CustomText29')) { }
                column(CstmHdrTxt30; HeaderLoop.GetCustomFieldTextValue('CustomText30')) { }
                column(CstmHdrDec1; HeaderLoop.GetCustomFieldDecimalValue('CustomDecimal1')) { }
                column(CstmHdrDec2; HeaderLoop.GetCustomFieldDecimalValue('CustomDecimal2')) { }
                column(CstmHdrDec3; HeaderLoop.GetCustomFieldDecimalValue('CustomDecimal3')) { }
                column(CstmHdrDec4; HeaderLoop.GetCustomFieldDecimalValue('CustomDecimal4')) { }
                column(CstmHdrDec5; HeaderLoop.GetCustomFieldDecimalValue('CustomDecimal5')) { }
                column(CstmHdrInt1; HeaderLoop.GetCustomFieldIntegerValue('CustomInteger1')) { }
                column(CstmHdrInt2; HeaderLoop.GetCustomFieldIntegerValue('CustomInteger2')) { }
                column(CstmHdrInt3; HeaderLoop.GetCustomFieldIntegerValue('CustomInteger3')) { }
                column(CstmHdrInt4; HeaderLoop.GetCustomFieldIntegerValue('CustomInteger4')) { }
                column(CstmHdrInt5; HeaderLoop.GetCustomFieldIntegerValue('CustomInteger5')) { }

                column(CstmHdrFieldLabel1; HeaderLoop.GetCustomFieldTextValue('CustomFieldLabel1')) { }
                column(CstmHdrFieldValue1; HeaderLoop.GetCustomFieldTextValue('CustomFieldValue1')) { }
                column(CstmHdrFieldLabel2; HeaderLoop.GetCustomFieldTextValue('CustomFieldLabel2')) { }
                column(CstmHdrFieldValue2; HeaderLoop.GetCustomFieldTextValue('CustomFieldValue2')) { }

                dataitem(LineLoop; "EOS Report Buffer Line")
                {
                    DataItemLinkReference = HeaderLoop;
                    DataItemLink = "EOS Entry ID" = field("EOS Entry ID");
                    DataItemTableView = sorting("EOS Entry ID", "EOS Line No.");
                    UseTemporary = true;

                    column(Line_Type; Format(LineLoop."EOS Type", 0, 2)) { }
                    column(Line_LineType; Format(LineLoop."EOS Line type", 0, 2)) { }
                    column(Line_Style; Format("EOS Line Style", 0, 2)) { }
                    column(Line_ExtensionCode; LineLoop."EOS Extension Code") { }
                    column(Line_LineNo; LineLoop."EOS Line No.") { }
                    column(Line_ItemNo; LineLoop.GetItemNo()) { }
                    column(Line_Description; LineLoop.GetDescription()) { }
                    column(Line_Description2; LineLoop."EOS Description 2") { }
                    column(Line_ReminderLevel; LineLoop."EOS Reminder Level") { }
                    column(Line_DocumentNo; LineLoop."EOS Order No.") { }
                    column(Line_PostingDate; LineLoop."EOS Posting Date") { }
                    column(Line_DueDate; LineLoop."EOS Shipment Date") { }
                    column(Line_DocDate; LineLoop."EOS Document Date") { }
                    column(Line_OriginalAmount; LineLoop."EOS Original Amount") { }
                    column(Line_OriginalQuantity; LineLoop."EOS Quantity") { }
                    column(Line_RemainingAmount; LineLoop."EOS Remaining Amount") { }
                    column(Line_RemainingQuantity; LineLoop."EOS Outstanding Quantity") { }
                    column(Line_Amount; LineLoop."EOS Amount") { }
                    column(Line_LineAmount; LineLoop."EOS Line Amount") { }
                    column(Line_ReminderLineType; Format(LineLoop."EOS Reminder Line Type", 0, 2)) { }
                    column(Line_SourceID; LineLoop."EOS Source ID") { }
                    column(Line_LineGroupID; LineLoop."EOS Line Group ID") { }
                    column(CstmLneTxt1; LineLoop.GetCustomFieldTextValue('CustomText1')) { }
                    column(CstmLneTxt2; LineLoop.GetCustomFieldTextValue('CustomText2')) { }
                    column(CstmLneTxt3; LineLoop.GetCustomFieldTextValue('CustomText3')) { }
                    column(CstmLneTxt4; LineLoop.GetCustomFieldTextValue('CustomText4')) { }
                    column(CstmLneTxt5; LineLoop.GetCustomFieldTextValue('CustomText5')) { }
                    column(CstmLneTxt6; LineLoop.GetCustomFieldTextValue('CustomText6')) { }
                    column(CstmLneTxt7; LineLoop.GetCustomFieldTextValue('CustomText7')) { }
                    column(CstmLneTxt8; LineLoop.GetCustomFieldTextValue('CustomText8')) { }
                    column(CstmLneTxt9; LineLoop.GetCustomFieldTextValue('CustomText9')) { }
                    column(CstmLneTxt10; LineLoop.GetCustomFieldTextValue('CustomText10')) { }
                    column(CstmLneTxt11; LineLoop.GetCustomFieldTextValue('CustomText11')) { }
                    column(CstmLneTxt12; LineLoop.GetCustomFieldTextValue('CustomText12')) { }
                    column(CstmLneTxt13; LineLoop.GetCustomFieldTextValue('CustomText13')) { }
                    column(CstmLneTxt14; LineLoop.GetCustomFieldTextValue('CustomText14')) { }
                    column(CstmLneTxt15; LineLoop.GetCustomFieldTextValue('CustomText15')) { }
                    column(CstmLneTxt16; LineLoop.GetCustomFieldTextValue('CustomText16')) { }
                    column(CstmLneTxt17; LineLoop.GetCustomFieldTextValue('CustomText17')) { }
                    column(CstmLneTxt18; LineLoop.GetCustomFieldTextValue('CustomText18')) { }
                    column(CstmLneTxt19; LineLoop.GetCustomFieldTextValue('CustomText19')) { }
                    column(CstmLneTxt20; LineLoop.GetCustomFieldTextValue('CustomText20')) { }
                    column(CstmLneTxt21; HeaderLoop.GetCustomFieldTextValue('CustomText21')) { }
                    column(CstmLneTxt22; HeaderLoop.GetCustomFieldTextValue('CustomText22')) { }
                    column(CstmLneTxt23; HeaderLoop.GetCustomFieldTextValue('CustomText23')) { }
                    column(CstmLneTxt24; HeaderLoop.GetCustomFieldTextValue('CustomText24')) { }
                    column(CstmLneTxt25; HeaderLoop.GetCustomFieldTextValue('CustomText25')) { }
                    column(CstmLneTxt26; HeaderLoop.GetCustomFieldTextValue('CustomText26')) { }
                    column(CstmLneTxt27; HeaderLoop.GetCustomFieldTextValue('CustomText27')) { }
                    column(CstmLneTxt28; HeaderLoop.GetCustomFieldTextValue('CustomText28')) { }
                    column(CstmLneTxt29; HeaderLoop.GetCustomFieldTextValue('CustomText29')) { }
                    column(CstmLneTxt30; HeaderLoop.GetCustomFieldTextValue('CustomText30')) { }
                    column(CstmLneDec1; LineLoop.GetCustomFieldDecimalValue('CustomDecimal1')) { }
                    column(CstmLneDec2; LineLoop.GetCustomFieldDecimalValue('CustomDecimal2')) { }
                    column(CstmLneDec3; LineLoop.GetCustomFieldDecimalValue('CustomDecimal3')) { }
                    column(CstmLneDec4; LineLoop.GetCustomFieldDecimalValue('CustomDecimal4')) { }
                    column(CstmLneDec5; LineLoop.GetCustomFieldDecimalValue('CustomDecimal5')) { }
                    column(CstmLneInt1; LineLoop.GetCustomFieldIntegerValue('CustomInteger1')) { }
                    column(CstmLneInt2; LineLoop.GetCustomFieldIntegerValue('CustomInteger2')) { }
                    column(CstmLneInt3; LineLoop.GetCustomFieldIntegerValue('CustomInteger3')) { }
                    column(CstmLneInt4; LineLoop.GetCustomFieldIntegerValue('CustomInteger4')) { }
                    column(CstmLneInt5; LineLoop.GetCustomFieldIntegerValue('CustomInteger5')) { }
                    trigger OnAfterGetRecord()
                    begin
                        if ImagesSent then begin
                            Clear(HeaderLoop."EOS Header Image");
                            Clear(HeaderLoop."EOS Footer Image");
                        end else
                            ImagesSent := true;
                    end;
                }
                dataitem(Totals; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(VAT_Identifier1; VAT_Identifier[1]) { }
                    column(VAT_Perc1; VAT_Perc[1]) { }
                    column(VAT_Description1; VAT_Description[1]) { }
                    column(VAT_Base1; VAT_Base[1]) { }
                    column(VAT_Amount1; VAT_Amount[1]) { }
                    column(VAT_InvoiceDiscountAmount1; VAT_InvoiceDiscountAmount[1]) { }
                    column(VAT_ClauseCode1; VAT_ClauseCode[1]) { }
                    column(VAT_ClauseDescription1; VAT_ClauseDescription[1]) { }
                    column(VAT_Identifier2; VAT_Identifier[2]) { }
                    column(VAT_Perc2; VAT_Perc[2]) { }
                    column(VAT_Description2; VAT_Description[2]) { }
                    column(VAT_Base2; VAT_Base[2]) { }
                    column(VAT_Amount2; VAT_Amount[2]) { }
                    column(VAT_InvoiceDiscountAmount2; VAT_InvoiceDiscountAmount[2]) { }
                    column(VAT_ClauseCode2; VAT_ClauseCode[2]) { }
                    column(VAT_ClauseDescription2; VAT_ClauseDescription[2]) { }
                    column(VAT_Identifier3; VAT_Identifier[3]) { }
                    column(VAT_Perc3; VAT_Perc[3]) { }
                    column(VAT_Description3; VAT_Description[3]) { }
                    column(VAT_Base3; VAT_Base[3]) { }
                    column(VAT_Amount3; VAT_Amount[3]) { }
                    column(VAT_InvoiceDiscountAmount3; VAT_InvoiceDiscountAmount[3]) { }
                    column(VAT_ClauseCode3; VAT_ClauseCode[3]) { }
                    column(VAT_ClauseDescription3; VAT_ClauseDescription[3]) { }
                    column(VAT_Identifier4; VAT_Identifier[4]) { }
                    column(VAT_Perc4; VAT_Perc[4]) { }
                    column(VAT_Description4; VAT_Description[4]) { }
                    column(VAT_Base4; VAT_Base[4]) { }
                    column(VAT_Amount4; VAT_Amount[4]) { }
                    column(VAT_InvoiceDiscountAmount4; VAT_InvoiceDiscountAmount[4]) { }
                    column(VAT_ClauseCode4; VAT_ClauseCode[4]) { }
                    column(VAT_ClauseDescription4; VAT_ClauseDescription[4]) { }
                    column(ShowVATClauseTab; VAT_ClauseCode[1] + VAT_ClauseCode[2] + VAT_ClauseCode[3] + VAT_ClauseCode[4] <> '') { }
                    column(PaymentLine_DueDate1; PaymentLine_DueDate[1]) { }
                    column(PaymentLine_Amount1; PaymentLine_Amount[1]) { }
                    column(PaymentLine_DueDate2; PaymentLine_DueDate[2]) { }
                    column(PaymentLine_Amount2; PaymentLine_Amount[2]) { }
                    column(PaymentLine_DueDate3; PaymentLine_DueDate[3]) { }
                    column(PaymentLine_Amount3; PaymentLine_Amount[3]) { }
                    column(PaymentLine_DueDate4; PaymentLine_DueDate[4]) { }
                    column(PaymentLine_Amount4; PaymentLine_Amount[4]) { }
                    column(VATLineCurrencyCode; HeaderLoop."EOS Currency Code") { }
                    column(VATLineTotal; VATLineTotal) { }
                    column(VATLineInvDiscTotal; VATLineInvDiscTotal) { }
                    column(VATLineBaseTotal; VATLineBaseTotal) { }
                    column(VATLineAmountTotal; VATLineAmountTotal) { }
                    column(VATLineAmountInclVATTotal; VATLineAmountInclVATTotal) { }
                    column(PrintVat; PrintVAT) { }
                }

                trigger OnAfterGetRecord()
                begin
                    if not HeaderLoop."EOS Hide Prices" then begin
                        HeaderLoop.GetVATAmountLines(LineLoop,
                                                    VAT_Identifier,
                                                    VAT_Perc,
                                                    VAT_Description,
                                                    VAT_Base,
                                                    VAT_Amount,
                                                    VAT_InvoiceDiscountAmount,
                                                    VAT_ClauseCode,
                                                    VAT_ClauseDescription,
                                                    VATLineTotal,
                                                    VATLineInvDiscTotal,
                                                    VATLineBaseTotal,
                                                    VATLineAmountTotal,
                                                    VATLineAmountInclVATTotal);
                        HeaderLoop.GetPaymentLines(PaymentLine_DueDate, PaymentLine_Amount)
                    end;
                    if not CurrReport.Preview() then
                        HeaderLoop.CountPrinted();
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, 1 + HeaderLoop."EOS No. of Copies");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not ReportSetup.Get(HeaderLoop."EOS Report Setup Code") then
                    ReportSetup.Init();

                if not Salesperson.Get(HeaderLoop."EOS Salesperson Code") then
                    Clear(Salesperson);

                if not Employee.Get(HeaderLoop."EOS Operator No.") then
                    Clear(Employee);

                if not BuyFromContact.Get(HeaderLoop."EOS Sell-to Contact No.") then
                    Clear(BuyFromContact);

                if not SellToContact.Get(HeaderLoop."EOS Sell-to Contact No.") then
                    Clear(SellToContact);

                if ReportSetup."EOS Print Logos" then
                    HeaderLoop.PopulateHeaderFooterImages();

                if not CurrReport.Preview() then
                    HeaderLoop.LogInteraction();
            end;
        }
    }

    requestpage
    {
        Caption = 'Options';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(ReportSetupCodeFld; ReportSetupCode)
                    {
                        Caption = 'Report Setup Code';
                        TableRelation = "EOS Report Setup";
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value for the field Report Setup Code';
                        trigger OnValidate()
                        begin
                            if ReportSetup.Get(ReportSetupCode) then begin
                                LogInteraction := ReportSetup."EOS Log Interaction";
                                UpdateLocalCopies();
                                RequestOptionsPage.Update(false);
                            end;
                        end;
                    }
                    field(NoofCopiesFld; NoOfCopies)
                    {
                        Caption = 'No. of Copies';
                        ApplicationArea = All;
                        Editable = NoofCopiesEditable;
                        ToolTip = 'Specifies the value for the field No. of Copies';
                    }
                    field(LogInteractionFld; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value for the field Log Interaction';
                    }
                    // field(PrintVAT; PrintVAT)
                    // {
                    //     Caption = 'Hide VAT';
                    //     ApplicationArea = All;
                    // }
                }
            }
        }

        trigger OnOpenPage()
        var
            SubscriptionMgt: Codeunit "EOS EX009 Subscription";
        begin
            RequestOptionsPage.Caption := RequestOptionsPage.Caption() + SubscriptionMgt.GetLicenseText(true);

            DetectCurrentDocument();
        end;
    }

    rendering
    {
        layout(Default)
        {
            Type = RDLC;
            LayoutFile = '.\Source\Report\Report 18122011 - EOS Reminder Document.rdlc';
            Caption = 'Default Layout', Locked = true;
        }
        layout(DefaultV2)
        {
            Type = RDLC;
            LayoutFile = '.\Source\Report\Report 18122011 - EOS Reminder Document - v2.rdlc';
            Caption = 'Default Layout (v2)', Locked = true;
        }
    }

    labels
    {
        BillToAddr_Caption = 'Billing address';
        DocumentNo_Caption = 'No.';
        PostingDate_Caption = 'Date';
        Salesperson_Caption = 'Salesperson';
        Purchaser_Caption = 'Purchaser';
        Operator_Caption = 'Contact';
        CustomerNo_Caption = 'Customer No.';
        VendorNo_Caption = 'Vendor No.';
        CustomerContact_Caption = 'Contact';
        CustomerMail_Caption = 'E-Mail';
        Reason_Caption = 'Transport reason';
        VATRegNo_Caption = 'VAT Reg.';
        FiscalCode_Caption = 'Fiscal code';
        Page_Caption = 'Page';
        ReminderLevel_Caption = 'Level';
        Line_ItemNo_Caption = 'No.';
        Line_Description_Caption = 'Description';
        Line_DocumentNo_Caption = 'Doc. No.';
        Line_PostingDate_Caption = 'Doc. Date';
        Line_TotalAmount_Caption = 'Total Amount';
        Line_TotalQuantity_Caption = 'Total Quantity';
        Line_RemAmount_Caption = 'Rem. Amount';
        Line_RemQuantity_Caption = 'Rem. Quantity';
        Line_Amount_Caption = 'Amount';
        Line_ReminderLevel_Caption = 'Level';
        Line_DueDate_Caption = 'Due Date';
        TotalText = 'Total';
    }

    trigger OnInitReport()
    begin
    end;

    trigger OnPreReport()
    var
        AdvancedReportingMngt: Codeunit "EOS Advanced Reporting Mngt";
        AdvRptStdRemindExt: Codeunit "EOS AdvRpt Std Remind Ext";
        AdvRptDebug: Codeunit "EOS AdvRpt Debug";
        StopExecution: Boolean;
    begin
        AdvRptDebug.AddEventLog('OnPreReport', 'Start', '');
        DetectCurrentDocument();

        HeaderLoop."EOS No. of Copies" := NoOfCopies;
        HeaderLoop."EOS Log Interaction" := LogInteraction;

        SetupLanguage(DocVariantToPrint);
        AdvancedReportingMngt.PrepareBuffer(DocVariantToPrint, ReportSetupCode, HeaderLoop, LineLoop, CurrReport.ObjectId(false), ForcedLanguageID);

        AdvRptStdRemindExt.CompressParagraph(LineLoop);

        OnBeforePrintingReport(HeaderLoop, LineLoop, NoOfCopies, LogInteraction, PrintVAT, StopExecution);
        if StopExecution then
            CurrReport.Quit();

        ReportSetup.Get(HeaderLoop."EOS Report Setup Code");
        AdvRptDebug.AddEventLog('OnPreReport', 'Stop', '');
    end;

    trigger OnPostReport()
    var
        AdvRptDebug: Codeunit "EOS AdvRpt Debug";
    begin
        AdvRptDebug.AddEventLog('OnPostReport', 'Stop', '');
    end;

    local procedure SetupLanguage(DocVariant: Variant)
    var
        AdvancedReportingMngt: Codeunit "EOS Advanced Reporting Mngt";
        AdvRptSharedMemory: Codeunit "EOS AdvRpt SharedMemory";
    begin
        if ForcedLanguageID = 0 then
            ForcedLanguageID := AdvRptSharedMemory.GetReportLanguage();

        if ForcedLanguageID <> 0 then
            CurrReport.LANGUAGE := ForcedLanguageID
        else
            CurrReport.LANGUAGE := AdvancedReportingMngt.GetReportLanguageID(DocVariant, CurrReport.ObjectId(false), ReportSetupCode);
    end;

    procedure SetForcedLanguageID(LangID: Integer)
    begin
        ForcedLanguageID := LangID;
    end;

    local procedure UpdateLocalCopies()
    begin
        NoofCopiesEditable := true;
        if ReportSetupCode = '' then
            exit;
        ReportSetup.Get(ReportSetupCode);
        if ReportSetup."EOS No. of Copies Source" = ReportSetup."EOS No. of Copies Source"::" " then
            NoOfCopies := ReportSetup."EOS No. of Copies"
        else begin
            NoOfCopies := 0;
            NoofCopiesEditable := false;
        end;
    end;

    local procedure DetectCurrentDocument()
    var
        AdvRptDefaultSetup: Record "EOS AdvRpt Default Setup";
        AdvancedReportingMngt: Codeunit "EOS Advanced Reporting Mngt";
        AdvRptDefSetup: Codeunit "EOS AdvRpt Def Setup";
        AdvRptRoutines: Codeunit "EOS AdvRpt Routines";
        AdvRptSharedMemory: Codeunit "EOS AdvRpt SharedMemory";
        Found: Boolean;
        ReportID: Integer;
    begin
        if Format(DocVariantToPrint) <> '' then
            exit;

        if not AdvRptSharedMemory.GetCustomReportDocument(DocVariantToPrint) then begin
            Found := false;
            AdvRptRoutines.GetDocumentToPrint(FakeReminderHeader, DocVariantToPrint, Found);
            AdvRptRoutines.GetDocumentToPrint(FakeIssuedReminderHeader, DocVariantToPrint, Found);
            if not Found then
                Error(UnknowDocumentToPrintErr, CurrReport.ObjectId(false), CurrReport.ObjectId(true));
        end;

        if ReportSetupCode = '' then begin
            if AdvancedReportingMngt.TryDecodeReportName(CurrReport.ObjectId(false), ReportID) then;
            AdvRptDefSetup.GetDefaultDocumentSetup(DocVariantToPrint, ReportID, true, AdvRptDefaultSetup);
            ReportSetupCode := AdvRptDefaultSetup."EOS Default Report Setup";
            UpdateLocalCopies();
        end;
    end;

    procedure GetPrintValues(var ReportRBHeader: Record "EOS Report Buffer Header" temporary;
                                   var ReportRBLine: Record "EOS Report Buffer Line" temporary;
                                   var ReportReportSetupCode: Code[10];
                                   var ReportNoOfCopies: Integer;
                                   var ReportLogInteraction: Boolean;
                                   var ReportPrintVAT: Boolean)
    var
        AdvancedReportingMngt: Codeunit "EOS Advanced Reporting Mngt";
    begin
        HeaderLoop.Reset();
        if HeaderLoop.IsEmpty() then begin
            DetectCurrentDocument();

            HeaderLoop."EOS No. of Copies" := NoOfCopies;
            HeaderLoop."EOS Log Interaction" := LogInteraction;

            SetupLanguage(DocVariantToPrint);
            AdvancedReportingMngt.PrepareBuffer(DocVariantToPrint, ReportSetupCode, HeaderLoop, LineLoop, CurrReport.ObjectId(false), ForcedLanguageID);
        end;

        ReportRBHeader.Copy(HeaderLoop, true);
        ReportRBLine.Copy(LineLoop, true);
        ReportReportSetupCode := ReportSetupCode;
        ReportNoOfCopies := NoOfCopies;
        ReportLogInteraction := LogInteraction;
        ReportPrintVAT := ReportPrintVAT;
    end;

    /// <summary>This event is reaised after building Header and line buffer but before sending data to Report Viewer</summary>
    /// <param name="RBHeader">Document header</param>
    /// <param name="RBLine">Document Lines</param>
    /// <param name="NoOfCopies">Current No. of Copies</param>
    /// <param name="LogInteraction">Log interaction flag</param>
    /// <param name="PrintVAT">Print VAT Flag</param>
    /// <param name="StopExecution">Returning true will be executed CurrReport.Quit method</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintingReport(var RBHeader: Record "EOS Report Buffer Header" temporary;
                                           var RBLine: Record "EOS Report Buffer Line" temporary;
                                           var NoOfCopies: Integer;
                                           var LogInteraction: Boolean;
                                           var PrintVAT: Boolean;
                                           var StopExecution: Boolean)
    begin
    end;

    var
        BuyFromContact: Record Contact;
        Employee: Record Employee;
        ReportSetup: Record "EOS Report Setup";
        Salesperson: Record "Salesperson/Purchaser";
        SellToContact: Record Contact;
        ImagesSent: Boolean;
        LogInteraction: Boolean;
        [InDataSet]
        NoofCopiesEditable: Boolean;
        PrintVAT: Boolean;
        ReportSetupCode: Code[10];
        VAT_ClauseCode: array[10] of Code[10];
        VAT_Identifier: array[10] of Code[20];
        PaymentLine_DueDate: array[10] of Date;
        PaymentLine_Amount: array[10] of Decimal;
        VATLineAmountInclVATTotal: Decimal;
        VATLineAmountTotal: Decimal;
        VATLineBaseTotal: Decimal;
        VATLineInvDiscTotal: Decimal;
        VATLineTotal: Decimal;
        VAT_Amount: array[10] of Decimal;
        VAT_Base: array[10] of Decimal;
        VAT_InvoiceDiscountAmount: array[10] of Decimal;
        VAT_Perc: array[10] of Decimal;
        ForcedLanguageID: Integer;
        NoOfCopies: Integer;
        VAT_ClauseDescription: array[10] of Text;
        VAT_Description: array[10] of Text;
        DocVariantToPrint: Variant;
        UnknowDocumentToPrintErr: Label 'Report %1 (%2): unable to recognize document to print';
}

