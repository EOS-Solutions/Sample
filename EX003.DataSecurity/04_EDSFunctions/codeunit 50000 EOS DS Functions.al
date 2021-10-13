codeunit 50000 "EOS DS Functions"
{

    trigger OnRun()
    begin
    end;

    var
        BlockCustomerLbl: Label 'Block Customer';
        UnblockCustomerLbl: Label 'Unblock Customer';
        CheckCustomerDimensionsLbl: Label 'Check Customer Dimensions';
        BlockVendorLbl: Label 'Block Vendor';
        UnblockVendorLbl: Label 'Unblock Vendor';
        CheckVendorDimensionsLbl: Label 'Check Vendor Dimensions';
        BlockItemLbl: Label 'Block Item';
        UnblockItemLbl: Label 'Unblock Item';
        CheckItemDimensionsLbl: Label 'Check Item Dimensions';
        ItemMessageLbl: Label 'Item Message';
        BlockJobLbl: Label 'Block Job';
        UnblockJobLbl: Label 'Unblock Job';
        CheckJobDimensionsLbl: Label 'Check Job Dimensions';
        // Sales ------------------------------------------------------------
        ReleasedSalesQuoteLbl: Label 'Release Sales Quote';
        ReleasedSalesOrderLbl: Label 'Release Sales Order';
        ReleasedSalesInvoiceLbl: Label 'Release Sales Invoice';
        ReleasedSalesCreditMemoLbl: Label 'Release Sales Credit Memo';
        ReleasedSalesBlanketOrderLbl: Label 'Release Sales Blanket Order';
        ReleasedSalesReturnOrderBLbl: Label 'Release Sales Return Order';
        ReopenSalesQuoteLbl: Label 'Reopen Sales Quote';
        ReopenSalesOrderLbl: Label 'Reopen Sales Order';
        ReopenSalesInvoiceLbl: Label 'Reopen Sales Invoice';
        ReopenSalesCreditMemoLbl: Label 'Reopen Sales Credit Memo';
        ReopenSalesBlanketOrderLbl: Label 'Reopen Sales Blanket Order';
        ReopenSalesReturnOrderBLbl: Label 'Reopen Sales Return Order';
        // Purchase ---------------------------------------------------------
        ReleasedPurchaseQuoteLbl: Label 'Release Sales Quote';
        ReleasedPurchaseOrderLbl: Label 'Release Purchase Order';
        ReleasedPurchaseInvoiceLbl: Label 'Release Purchase Invoice';
        ReleasedPurchaseCreditMemoLbl: Label 'Release Purchase Credit Memo';
        ReleasedPurchaseBlanketOrderLbl: Label 'Release Purchase Blanket Order';
        ReleasedPurchaseReturnOrderBLbl: Label 'Release Purchase Return Order';
        ReopenPurchaseQuoteLbl: Label 'Reopen Purchase Quote';
        ReopenPurchaseOrderLbl: Label 'Reopen Purchase Order';
        ReopenPurchaseInvoiceLbl: Label 'Reopen Purchase Invoice';
        ReopenPurchaseCreditMemoLbl: Label 'Reopen Purchase Credit Memo';
        ReopenPurchaseBlanketOrderLbl: Label 'Reopen Purchase Blanket Order';
        ReopenPurchaseReturnOrderBLbl: Label 'Reopen Purchase Return Order';
        // Other ------------------------------------------------------------
        BlockGLAccountLbl: Label 'Block G/L Account';
        UnblockGLAccountLbl: Label 'Unblock G/L Account';
        VATRegistrationcheckwarningLbl: Label 'VAT Registration check warning';
        VATRegistrationcheckblockLbl: Label 'VAT Registration check block';
        // Service ----------------------------------------------------------
        ReleasedServiceQuoteLbl: Label 'Release Service Quote';
        ReleasedServiceOrderLbl: Label 'Release Service Order';
        ReleasedServiceInvoiceLbl: Label 'Release Service Invoice';
        ReleasedServiceCreditMemoLbl: Label 'Release Service Credit Memo';
        ReopenServiceQuoteLbl: Label 'Reopen Service Quote';
        ReopenServiceOrderLbl: Label 'Reopen Service Order';
        ReopenServiceInvoiceLbl: Label 'Reopen Service Invoice';
        ReopenServiceCreditMemoLbl: Label 'Reopen Service Credit Memo';


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DS Management", 'OnDiscoverDSFunctions', '', true, true)]
    local procedure DataSecurityManagement_OnDiscoverDSFunctions(var DataSecurityFunctions: Record "EOS DS Functions")
    begin
        InjectDSFunctions(DataSecurityFunctions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DS Management", 'OnExecuteDSFunction', '', true, true)]
    local procedure DataSecurityManagement_OnExecuteFunction(var DataSecurityFunctions: Record "EOS DS Functions"; var RecRef: RecordRef; TableOptionType: Integer; UseOptionType: Boolean; var ContinueExecution: Boolean)
    begin
        ContinueExecution := ExecuteFunction(DataSecurityFunctions, RecRef, TableOptionType, UseOptionType);
    end;

    local procedure InjectDSFunctions(var DSFunctions: Record "EOS DS Functions")
    begin
        // SAMPLE
        //CreateDSFunction(DSFunctions, 'BLOCK_CUSTOMER', DATABASE::Customer, 0, BlockCustomerLbl);
    end;

    procedure CreateDSFunction(var DSFunctions: Record "EOS DS Functions"; FunctionCode: Code[20]; TableID: Integer; TableOptionType: Option "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"; FunctionDescription: Text[50])
    begin
        DSFunctions.Init();
        DSFunctions.Code := FunctionCode;
        if DSFunctions.Get() then;

        DSFunctions."Table ID" := TableID;
        DSFunctions."Table Option Type" := TableOptionType;
        DSFunctions.Description := FunctionDescription;
        if not DSFunctions.Insert() then
            DSFunctions.Modify();
    end;

    procedure ExecuteFunction(var DSFunctions: Record "EOS DS Functions"; var RecRef: RecordRef; TableOptionType: Option "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"; UseOptionType: Boolean): Boolean
    var
        DSMailMgmt: Codeunit "EOS DS Mail Management";
    begin
        if DSFunctions.Code = '' then
            exit(true);

        case DSFunctions.Type of
            DSFunctions.Type::Exec:
                case DSFunctions.Code of
                    //--SAMPLE
                    //'BLOCK_CUSTOMER':
                    //    exit(BLOCKUNBLOCK_CUSTOMER(RecRef, true));
                    
                end;
        end;

        exit(true);
    end;

    // Customer functions

    local procedure BLOCKUNBLOCK_CUSTOMER(var vRrfRecord: RecordRef; iBlnBlock: Boolean): Boolean
    var
        Customer: Record Customer;
        FldRef: FieldRef;
        FldRef2: FieldRef;
        OldBlockStatus: Integer;
    begin
        FldRef := vRrfRecord.Field(Customer.FieldNo(Blocked));
        OldBlockStatus := vRrfRecord.Field(Customer.FieldNo("EOS Old Blocked (DS)")).Value();
        if not iBlnBlock then begin
            if OldBlockStatus = Customer.Blocked::All then
                FldRef.Value := Customer.Blocked::" "
            else
                FldRef.Value := OldBlockStatus
        end
        else begin
            FldRef2 := vRrfRecord.Field(Customer.FieldNo("EOS Old Blocked (DS)"));
            FldRef2.Value := FldRef.Value();
            FldRef.Value := Customer.Blocked::All;
        end;
        exit(true);
    end;

    local procedure CheckDim_Customer(var vRrfRecord: RecordRef): Boolean
    var
        lFrfKeyFieldNo: FieldRef;
        lFrfField: FieldRef;
        lKrfKey: KeyRef;
        iIntKeyCount: Integer;
        lCodKeyCodValue: Code[20];
        lIntKeyOptionFieldNo: Integer;
        lIntKeyCodFieldNo: Integer;
        lIntKeyIntFieldNo: Integer;
    begin
        //CHECKDIM_ITEM Table 18 Option Type 0
        lKrfKey := vRrfRecord.KeyIndex(1);
        for iIntKeyCount := 1 to lKrfKey.FieldCount() do begin
            lFrfKeyFieldNo := lKrfKey.FieldIndex(iIntKeyCount);
            case UpperCase(Format(lFrfKeyFieldNo.Type())) of
                'OPTION':
                    begin
                        lIntKeyOptionFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyOptionFieldNo);
                    end;
                'CODE':
                    begin
                        lIntKeyCodFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyCodFieldNo);
                        lCodKeyCodValue := lFrfField.Value();
                    end;
                'INTEGER':
                    begin
                        lIntKeyIntFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
                    end;
                else
                    Error('Unexpected Field Type!');
            end;
        end;
        CheckDimension(18, lCodKeyCodValue);
        exit(true);
    end;

    // Vendor functions

    local procedure BLOCKUNBLOCK_VENDOR(var vRrfRecord: RecordRef; iBlnBlock: Boolean): Boolean
    var
        Vendor: Record Vendor;
        FldRef: FieldRef;
        FldRef2: FieldRef;
        OldBlockStatus: Integer;
    begin
        FldRef := vRrfRecord.Field(Vendor.FieldNo(Blocked));
        OldBlockStatus := vRrfRecord.Field(Vendor.FieldNo("EOS Old Blocked (DS)")).Value();
        if not iBlnBlock then begin
            if OldBlockStatus = Vendor.Blocked::All then
                FldRef.Value := Vendor.Blocked::" "
            else
                FldRef.Value := OldBlockStatus
        end
        else begin
            FldRef2 := vRrfRecord.Field(Vendor.FieldNo("EOS Old Blocked (DS)"));
            FldRef2.Value := FldRef.Value();
            FldRef.Value := Vendor.Blocked::All;
        end;
        exit(true);
    end;

    local procedure CheckDim_Vendor(var vRrfRecord: RecordRef): Boolean
    var
        lFrfField: FieldRef;
        lFrfKeyFieldNo: FieldRef;
        lKrfKey: KeyRef;
        lCodKeyCodValue: Code[20];
        iIntKeyCount: Integer;
        lIntKeyCodFieldNo: Integer;
        lIntKeyIntFieldNo: Integer;
        lIntKeyOptionFieldNo: Integer;
    begin
        //CHECKDIM_ITEM Table 23 Option Type 0
        lKrfKey := vRrfRecord.KeyIndex(1);
        for iIntKeyCount := 1 to lKrfKey.FieldCount() do begin
            lFrfKeyFieldNo := lKrfKey.FieldIndex(iIntKeyCount);
            case UpperCase(Format(lFrfKeyFieldNo.Type())) of
                'OPTION':
                    begin
                        lIntKeyOptionFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyOptionFieldNo);
                    end;
                'CODE':
                    begin
                        lIntKeyCodFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyCodFieldNo);
                        lCodKeyCodValue := lFrfField.Value();
                    end;
                'INTEGER':
                    begin
                        lIntKeyIntFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
                    end;
                else
                    Error('Unexpected Field Type!');
            end;
        end;
        CheckDimension(23, lCodKeyCodValue);
        exit(true);
    end;

    // Item functions
    local procedure BLOCKUNBLOCK_ITEM(var vRrfRecord: RecordRef; iBlnBlock: Boolean): Boolean
    var
        lFrfField: FieldRef;
        lIntKeyIntFieldNo: Integer;
    begin
        //BLOCKUNBLOCK_ITEM Table 27 Option Type 0
        lIntKeyIntFieldNo := 54;
        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
        lFrfField.Value := iBlnBlock;
        exit(true);
    end;

    local procedure CheckDim_Item(var vRrfRecord: RecordRef): Boolean
    var
        lFrfField: FieldRef;
        lFrfKeyFieldNo: FieldRef;
        lKrfKey: KeyRef;
        iIntKeyCount: Integer;
        lIntKeyIntValue: Integer;
        lIntKeyCodFieldNo: Integer;
        lIntKeyIntFieldNo: Integer;
        lIntKeyOptionValue: Integer;
        lIntKeyOptionFieldNo: Integer;
        lCodKeyCodValue: Code[20];
    begin
        //CHECKDIM_ITEM Table 27 Option Type 0
        lKrfKey := vRrfRecord.KeyIndex(1);
        for iIntKeyCount := 1 to lKrfKey.FieldCount() do begin
            lFrfKeyFieldNo := lKrfKey.FieldIndex(iIntKeyCount);
            case UpperCase(Format(lFrfKeyFieldNo.Type())) of
                'OPTION':
                    begin
                        lIntKeyOptionFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyOptionFieldNo);
                    end;
                'CODE':
                    begin
                        lIntKeyCodFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyCodFieldNo);
                        lCodKeyCodValue := lFrfField.Value();
                    end;
                'INTEGER':
                    begin
                        lIntKeyIntFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
                    end;
                else
                    Error('Unexpected Field Type!');
            end;
        end;
        CheckDimension(27, lCodKeyCodValue);
        exit(true);
    end;

    local procedure Message_Item(var vRrfRecord: RecordRef): Boolean
    var
        lCduDSManagement: Codeunit "EOS DS Management";
        lCtxText18122140Msg: Label 'Item EDS Status is %1.';
    begin
        //Message_ITEM Table 27 Option Type 0
        Message(lCtxText18122140Msg, lCduDSManagement.GetRecordStatus(vRrfRecord));
        exit(true);
    end;

    // General
    local procedure BLOCKUNBLOCK_GLACCOUNT(var vRrfRecord: RecordRef; iBlnBlock: Boolean): Boolean
    var
        lFrfField: FieldRef;
        lIntKeyIntFieldNo: Integer;
    begin
        //BLOCKUNBLOCK_GLACCOUNT Table 15 Option Type 0
        lIntKeyIntFieldNo := 13;
        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
        lFrfField.Value := iBlnBlock;
        exit(true);
    end;

    local procedure CheckDimension(iIntTableID: Integer; iCodPKcode: Code[20]): Boolean
    var
        lRecDefaultDimension: Record "Default Dimension";
        lRecDefaultDimension2: Record "Default Dimension";
        lRecRefTable: RecordRef;
        Txt001Err: Label 'Dimension %1 is mandatory for %2 %3.';
        Txt002Err: Label '%1 must be %2 and %3 must be %4 for %5 %6.';
        Txt003Err: Label '%1 cannot be set for %2 %3.';
    begin
        lRecRefTable.Open(iIntTableID, true);
        case iIntTableID of
            DATABASE::Customer,
            DATABASE::Vendor,
            DATABASE::Item,
            DATABASE::Job:
                begin
                    lRecDefaultDimension.SetRange("Table ID", iIntTableID);
                    lRecDefaultDimension.SetRange("No.", '');
                    lRecDefaultDimension.SetFilter("Value Posting", '%1|%2|3', lRecDefaultDimension."Value Posting"::"Same Code",
                                                                                lRecDefaultDimension."Value Posting"::"Code Mandatory",
                                                                                lRecDefaultDimension."Value Posting"::"No Code");
                    if lRecDefaultDimension.Find('-') then
                        repeat
                            lRecDefaultDimension2.SetRange("Table ID", iIntTableID);
                            lRecDefaultDimension2.SetRange("No.", iCodPKcode);
                            lRecDefaultDimension2.SetRange("Dimension Code", lRecDefaultDimension."Dimension Code");
                            case lRecDefaultDimension."Value Posting" of
                                lRecDefaultDimension."Value Posting"::"Code Mandatory":
                                    if not lRecDefaultDimension2.Find('-') then
                                        Error(Txt001Err,
                                        lRecDefaultDimension."Dimension Code",
                                        lRecRefTable.Caption(),
                                        iCodPKcode
                                        );
                                lRecDefaultDimension."Value Posting"::"Same Code":
                                    begin
                                        lRecDefaultDimension2.SetRange("Dimension Value Code", lRecDefaultDimension."Dimension Value Code");
                                        lRecDefaultDimension2.SetRange("Value Posting", lRecDefaultDimension."Value Posting");
                                        if not lRecDefaultDimension2.Find('-') then
                                            Error(Txt002Err,
                                            lRecDefaultDimension."Dimension Code",
                                            lRecDefaultDimension."Dimension Value Code",
                                            lRecDefaultDimension.FieldCaption(lRecDefaultDimension."Value Posting"),
                                            lRecDefaultDimension."Value Posting",
                                            lRecRefTable.Caption(),
                                            iCodPKcode
                                            );
                                    end;
                                lRecDefaultDimension."Value Posting"::"No Code":
                                    if lRecDefaultDimension2.IsEmpty() then
                                        Error(Txt003Err,
                                        lRecDefaultDimension."Dimension Code",
                                        lRecRefTable.Caption(),
                                        iCodPKcode
                                        );
                            end;
                        until lRecDefaultDimension.Next() = 0;
                end;
        end;
    end;

    local procedure CHKVATREGNO(var vRrfRecord: RecordRef; iOptTableOptionType: Option "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"; Block: Boolean): Boolean
    var
    /*TODO-lma VATRegistrationCheckEntry: Record "VAT Registration Check Entry" temporary;
    VATRegistrationCheck: Codeunit "VAT Registration Check";*/
    /*ReturnMsg: Text;
    ErrorMsg: Text;
    Txt001Err: Label 'VAT Registration check status: %1';
    Txt002Err: Label ' (%1)';*/
    begin
        /*TODO-lma
        VATRegistrationCheckEntry.Status := VATRegistrationCheck.CheckVATRegistrationByRec(vRrfRecord, ReturnMsg, true);
        case VATRegistrationCheckEntry.Status of
            VATRegistrationCheckEntry.Status::Invalid,
            VATRegistrationCheckEntry.Status::"Not Verified":
                begin
                    ErrorMsg := StrSubstNo(Txt001Err, VATRegistrationCheckEntry.Status);
                    if ReturnMsg <> '' then
                        ErrorMsg += StrSubstNo(Txt002Err, ReturnMsg);
                end;
        end;

        if ErrorMsg <> '' then
            if Block then
                Error(ErrorMsg)
            else
                Message(ErrorMsg);

        exit(true);*/
    end;

    // Job

    local procedure BLOCKUNBLOCK_JOB(var vRrfRecord: RecordRef; iBlnBlock: Boolean): Boolean
    var
        Job: Record Job;
        FldRef: FieldRef;
        FldRef2: FieldRef;
        OldBlockStatus: Integer;
    begin
        FldRef := vRrfRecord.Field(Job.FieldNo(Blocked));
        OldBlockStatus := vRrfRecord.Field(Job.FieldNo("EOS Old Blocked (DS)")).Value();
        if not iBlnBlock then
            FldRef.Value := OldBlockStatus
        else begin
            FldRef2 := vRrfRecord.Field(Job.FieldNo("EOS Old Blocked (DS)"));
            FldRef2.Value := FldRef.Value();
            FldRef.Value := Job.Blocked::All;
        end;
        exit(true);
    end;

    local procedure CheckDim_Job(var vRrfRecord: RecordRef): Boolean
    var
        lFrfField: FieldRef;
        lFrfKeyFieldNo: FieldRef;
        lKrfKey: KeyRef;
        iIntKeyCount: Integer;
        lCodKeyCodValue: Code[20];
        lIntKeyOptionFieldNo: Integer;
        lIntKeyCodFieldNo: Integer;
        lIntKeyIntFieldNo: Integer;
    begin
        //CHECKDIM_JOB Table 167 Option Type 0
        lKrfKey := vRrfRecord.KeyIndex(1);
        for iIntKeyCount := 1 to lKrfKey.FieldCount() do begin
            lFrfKeyFieldNo := lKrfKey.FieldIndex(iIntKeyCount);
            case UpperCase(Format(lFrfKeyFieldNo.Type())) of
                'OPTION':
                    begin
                        lIntKeyOptionFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyOptionFieldNo);
                    end;
                'CODE':
                    begin
                        lIntKeyCodFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyCodFieldNo);
                        lCodKeyCodValue := lFrfField.Value();
                    end;
                'INTEGER':
                    begin
                        lIntKeyIntFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
                    end;
                else
                    Error('Unexpected Field Type!');
            end;
        end;
        CheckDimension(167, lCodKeyCodValue);
        exit(true);
    end;

    // Document
    procedure DOCRELEASE(var vRrfRecord: RecordRef; iOptTableOptionType: Option "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"; iOptSourceType: Option Sales,Purchase,Service): Boolean
    var
        lRecSalesHeader: Record "Sales Header";
        lRecPurchaseHeader: Record "Purchase Header";
        lRecServiceHeader: Record "Service Header";

        lCduReleaseSalesDocument: Codeunit "Release Sales Document";
        lCduReleasePurchaseDocument: Codeunit "Release Purchase Document";
        lCduReleaseServiceDocument: Codeunit "Release Service Document";

        lFrfKeyFieldNo: FieldRef;
        lFrfField: FieldRef;
        lKrfKey: KeyRef;
        lCodKeyCodValue: Code[20];
        iIntKeyCount: Integer;
        lIntKeyIntValue: Integer;
        lIntKeyIntFieldNo: Integer;
        lIntKeyCodFieldNo: Integer;
        lIntKeyOptionValue: Integer;
        lIntKeyOptionFieldNo: Integer;
    begin
        lKrfKey := vRrfRecord.KeyIndex(1);
        for iIntKeyCount := 1 to lKrfKey.FieldCount() do begin
            lFrfKeyFieldNo := lKrfKey.FieldIndex(iIntKeyCount);
            case UpperCase(Format(lFrfKeyFieldNo.Type())) of
                'OPTION':
                    begin
                        lIntKeyOptionFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyOptionFieldNo);
                    end;
                'CODE':
                    begin
                        lIntKeyCodFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyCodFieldNo);
                        lCodKeyCodValue := lFrfField.Value();
                    end;
                'INTEGER':
                    begin
                        lIntKeyIntFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
                    end;
                else
                    Error('Unexpected Field Type!');
            end;
        end;

        case iOptSourceType of
            iOptSourceType::Sales:
                begin
                    lRecSalesHeader.Get(iOptTableOptionType, lCodKeyCodValue);
                    lCduReleaseSalesDocument.Run(lRecSalesHeader);
                end;
            iOptSourceType::Purchase:
                begin
                    lRecPurchaseHeader.Get(iOptTableOptionType, lCodKeyCodValue);
                    lCduReleasePurchaseDocument.Run(lRecPurchaseHeader);
                end;
            iOptSourceType::Service:
                begin
                    lRecServiceHeader.Get(iOptTableOptionType, lCodKeyCodValue);
                    lCduReleaseServiceDocument.Run(lRecServiceHeader);
                end;
        end;
        vRrfRecord.Get(vRrfRecord.RecordId());
        exit(true);
    end;

    procedure DOCREOPEN(var vRrfRecord: RecordRef; iOptTableOptionType: Option "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19"; iOptSourceType: Option Sales,Purchase,Service): Boolean
    var
        lRecSalesHeader: Record "Sales Header";
        lRecPurchaseHeader: Record "Purchase Header";
        lRecServiceHeader: Record "Service Header";

        lCduReleaseSalesDocument: Codeunit "Release Sales Document";
        lCduReleasePurchaseDocument: Codeunit "Release Purchase Document";
        lCduReleaseServiceDocument: Codeunit "Release Service Document";

        lFrfField: FieldRef;
        lFrfKeyFieldNo: FieldRef;
        lKrfKey: KeyRef;
        lCodKeyCodValue: Code[20];
        iIntKeyCount: Integer;
        lIntKeyCodFieldNo: Integer;
        lIntKeyIntFieldNo: Integer;
        lIntKeyOptionFieldNo: Integer;
    begin
        lKrfKey := vRrfRecord.KeyIndex(1);
        for iIntKeyCount := 1 to lKrfKey.FieldCount() do begin
            lFrfKeyFieldNo := lKrfKey.FieldIndex(iIntKeyCount);
            case UpperCase(Format(lFrfKeyFieldNo.Type())) of
                'OPTION':
                    begin
                        lIntKeyOptionFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyOptionFieldNo);
                    end;
                'CODE':
                    begin
                        lIntKeyCodFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyCodFieldNo);
                        lCodKeyCodValue := lFrfField.Value();
                    end;
                'INTEGER':
                    begin
                        lIntKeyIntFieldNo := lFrfKeyFieldNo.Number();
                        lFrfField := vRrfRecord.Field(lIntKeyIntFieldNo);
                    end;
                else
                    Error('Unexpected Field Type!');
            end;
        end;

        case iOptSourceType of
            iOptSourceType::Sales:
                begin
                    lRecSalesHeader.Get(iOptTableOptionType, lCodKeyCodValue);
                    lCduReleaseSalesDocument.Reopen(lRecSalesHeader);
                end;
            iOptSourceType::Purchase:
                begin
                    lRecPurchaseHeader.Get(iOptTableOptionType, lCodKeyCodValue);
                    lCduReleasePurchaseDocument.Reopen(lRecPurchaseHeader);
                end;
            iOptSourceType::Service:
                begin
                    lRecServiceHeader.Get(iOptTableOptionType, lCodKeyCodValue);
                    lCduReleaseServiceDocument.Reopen(lRecServiceHeader);
                end;
        end;
        vRrfRecord.Get(vRrfRecord.RecordId());
        exit(true);
    end;
}
