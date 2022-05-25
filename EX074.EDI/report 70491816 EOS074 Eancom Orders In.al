report 70491816 "EOS074 Eancom Orders In"
{
    Caption = 'EDI Eancom Orders In Mpreis';

    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(EDIHeader; "EOS074 EDI Message Header")
        {
            DataItemTableView = sorting("Message Type", "No.") ORDER(Ascending) where("Message Type" = const("ORDERS IN"));
            dataitem(EDILine; "EOS074 EDI Message Line")
            {
                DataItemLink = "Message Type" = field("Message Type"), "Message No." = field("No.");
                DataItemTableView = sorting("Message Type", "Message No.", "Line No.") ORDER(Ascending);

                trigger OnAfterGetRecord()
                var
                    RecordType: Text[30];
                begin
                    RecordType := CopyStr(EDIMgt.ReadTokenFix(EDILine, 1, 3), 1, MaxStrLen(RecordType));
                    case RecordType of
                        'UNA':
                            begin
                                CDES := CopyStr(EDILine."Field 1", 4, 1);
                                DES := CopyStr(EDILine."Field 1", 5, 1);
                            end;

                        'UNB',
                      'UNH':
                            CheckSegment(EDIHeader, EDILine, RecordType);

                        'BGM',
                      'RFF',
                      'DTM',
                      'NAD',
                      'CUX',
                      'TDT',
                      'LIN',
                      'PIA',
                      'IMD',
                      'MEA',
                      'QTY',
                      'FTX',
                      'PRI',
                      'UNS',
                      'MOA',
                      'CNT',
                      'UNT',
                      //'UNS',
                      'UNZ':
                            HandleSegment(EDIHeader, EDILine, RecordType, SalesHeader, SalesLine);

                        else
                            if DELCHR(RecordType, '<>', ' ') <> '' then
                                Error(NoValidRecErr, RecordType);
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                EDIGroup.Get("EDI Group Code");
                EDIMessageSetup.Get("Message Type", "EDI Group Code");

                if not EDIMessageSetup.IsTableAllowed(Database::"Sales Header") then
                    CurrReport.Break();
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed() then
                    Message(OrdGeneratedMsg, OrdersCreated);
            end;
        }
    }

    requestpage
    {

        layout
        {
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
        CompanyInfo: Record "Company Information";
    begin
        EDIGroup.SetFilter(EDIGroup.Code, EDIHeader.GETFILTER("EDI Group Code"));

        GLSetup.Get();
        CompanyInfo.Get();

        CDES := ':';
        DES := '+';
        DN := '.';
        RC := '?';
        ST := '''';
    end;

    var
        EDIGroup: Record "EOS074 EDI Group";
        EDIMessageSetup: Record "EOS074 EDI Message Setup";
        //EDIExtractDoc: Record "EOS074 EDI Message Document";
        //Cust: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        //Shipto: Record "Ship-to Address";
        GLSetup: Record "General Ledger Setup";
        //Item: Record Item;
        //EDIMapping: Record "EOS074 EDI Mapping";
        EDIMgt: Codeunit "EOS074 EDI Management";
        //ProgressBar: Dialog;
        CDES: Text[1];
        DES: Text[1];
        DN: Text[1];
        RC: Text[1];
        ST: Text[1];
        SegmentType: enum "EOS074 Segment Type";
        OrdersCreated: Integer;
        ReqHeaderDeliveryDate: Date;
        IsNewOrder: Boolean;
        //DeliveryDate: Date;
        //DeliveryTime: Time;
        NoValidRecErr: Label 'No valid record type %1.';
        //Text001: Label 'GLN of the document %1 is differnt than the company GLN %2.';
        MsgTypeErr: Label 'Message Type is not ORDERS but %1.';
        DocTypeErr: Label 'The document is not an order.';
        //Text004: Label 'Document %1 already exists';
        GLNCustErr: Label 'Customer with GLN %1 does not exist.';
        //Text011: Label 'Customer GLN is not specified.';
        ItemExistErr: Label 'Item does not exist: %1 %2.';
        //Text020: Label 'New Order %1 (%2), received form EDI';
        //Text50000: Label 'EDI - Group #1########\';
        //Text50001: Label 'Table      #2########\';
        //Text50002: Label 'Document No. #3########';
        ExtDocErr: Label 'External Document %1 not Found';
        //Text50004: Label 'ENU=Impossible to find Order';
        //Text50010: Label '%1 shall not be blank!';
        OrdGeneratedMsg: Label '%1 orders generated.';

    procedure CheckSegment(EDIHeader: Record "EOS074 EDI Message Header"; EDILine: Record "EOS074 EDI Message Line"; RecordType: Text[30]);
    var
        EDIGrp: Record "EOS074 EDI Group";
        //SegmentData: Text[250];
        MessageType: Text[30];
        InterchangeCode: Code[20];
        InterchangePartnerCode: Code[20];
    begin
        case RecordType of
            'UNB':
                begin
                    InterchangePartnerCode := CopyStr(EDIMgt.ReadTokenField(EDILine, 3, 1, DES, CDES), 1, MaxStrLen(InterchangePartnerCode));
                    InterchangeCode := CopyStr(EDIMgt.ReadTokenField(EDILine, 4, 1, DES, CDES), 1, MaxStrLen(InterchangeCode));
                    EDIGrp.Get(EDIHeader."EDI Group Code");
                    EDIGrp.TestField("Interchange Code", InterchangeCode);
                    EDIGrp.TestField("Interchange Partner Code", InterchangePartnerCode);
                end;

            'UNH':
                begin
                    MessageType := CopyStr(EDIMgt.ReadTokenField(EDILine, 3, 1, DES, CDES), 1, MaxStrLen(MessageType));
                    if UPPERCASE(MessageType) <> 'ORDERS' then
                        Error(MsgTypeErr, MessageType);
                end;
        end;
    end;

    procedure HandleSegment(var EDIHeader: Record "EOS074 EDI Message Header"; EDILine: Record "EOS074 EDI Message Line"; RecordType: Text[30]; var SalesHeader: Record 36; var SalesLine: Record 37);
    var
    //customer: Record Customer;
    begin
        case true of
            (RecordType = 'BGM'):
                begin
                    SegmentType := SegmentType::BGM;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'NAD'):
                begin
                    SegmentType := SegmentType::NAD;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'CTA'):
                begin
                    SegmentType := SegmentType::CTA;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'COM'):
                begin
                    SegmentType := SegmentType::CTA;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'DTM'):
                case SegmentType of
                    SegmentType::BGM:
                        UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                    SegmentType::LIN:
                        UpdateSalesOrderLine(EDIHeader, EDILine, RecordType, SalesHeader, SalesLine);
                end;

            (RecordType = 'LIN'):
                begin
                    SegmentType := SegmentType::LIN;
                    UpdateSalesOrderLine(EDIHeader, EDILine, RecordType, SalesHeader, SalesLine);
                end;

            (RecordType = 'FTX'):
                case SegmentType of
                    SegmentType::BGM:
                        UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                    SegmentType::LIN:
                        UpdateSalesOrderLine(EDIHeader, EDILine, RecordType, SalesHeader, SalesLine);
                end;

            (RecordType = 'PIA') or
          (RecordType = 'QTY'):
                case SegmentType of
                    SegmentType::LIN:
                        UpdateSalesOrderLine(EDIHeader, EDILine, RecordType, SalesHeader, SalesLine);
                end;
        end;
    end;

    procedure UpdateSalesOrder(var EDIHeader: Record "EOS074 EDI Message Header"; EDILine: Record "EOS074 EDI Message Line"; RecordType: Text[30]; var SalesHeader: Record 36);
    var
        CompanyInfo: Record "Company Information";
        Cust: Record Customer;
        EDIValues: Record "EOS074 EDI Values";
        //EDILine2: Record "EOS074 EDI Message Line";
        //ShipToAddr: Record 222;
        //EDIMappingValue: Record "EOS074 EDI Mapping";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        //RefTransport: Code[20];
        CustId: Code[20];
        DocumentType: Text[30];
        DocumentDate: Date;
        //ShipmentDate: Date;
        TestDocument: Boolean;
        //NextDocLineNo: Integer;
        //i: Integer;
        DocumentTime: Time;
        FormatQualifier: Text[3];
        //_PVC_: Integer;
        ExternalOrderNo: Text[50];
    begin
        CompanyInfo.Get();

        case RecordType of
            'BGM':
                begin
                    DocumentType := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES), 1, MaxStrLen(DocumentType));
                    // ORG: IF DocumentType <> '220' THEN
                    if not (DocumentType in ['220', '230']) then
                        Error(DocTypeErr);

                    IsNewOrder := (DocumentType = '220');
                    ExternalOrderNo := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(ExternalOrderNo));

                    if IsNewOrder then begin
                        TestDocument := EDIHeader."Test Stage" = true;

                        SalesHeader.SetHideValidationDialog(true);
                        SalesHeader.Init();
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;

                        // {
                        // if EDIHeader."Document No. Series" <> '' then begin
                        //             SalesHeader."No. Series" := EDIHeader."Document No. Series";
                        //             SalesHeader."No." :=
                        //               NoSeriesMgt.GetNextNo(SalesHeader."No. Series", TODAY, true);
                        //         end else
                        //             SalesHeader."No." := '';
                        // }
                        SalesHeader."No." := '';
                        SalesHeader.Insert(true);

                        OrdersCreated := OrdersCreated + 1;

                        // "Your Reference"
                        SalesHeader."External Document No." := CopyStr(EDIMgt.ReadTokenField(EDILine, 3, 1, DES, CDES), 1, MaxStrLen(SalesHeader."External Document No."));
                        if TestDocument then
                            SalesHeader."External Document No." := CopyStr('TEST ' + SalesHeader."External Document No.", 1, MaxStrLen(SalesHeader."External Document No."));

                        SalesHeader.Modify();

                    end else begin
                        SalesHeader.SETCURRENTKEY("Sell-to Customer No.", "External Document No.");
                        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                        //SalesHeader.setRange("Sell-to Customer No."
                        SalesHeader.SetRange("External Document No.", ExternalOrderNo);

                        EDIValues.Reset();
                        EDIValues.FilterByRecord(SalesHeader);
                        EDIValues.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                        if EDIValues.IsEmpty() then
                            Error(ExtDocErr, ExternalOrderNo);

                        if SalesHeader.Status = SalesHeader.Status::Released then
                            ReleaseSalesDocument.Reopen(SalesHeader);

                        SalesHeader.Modify();
                    end;
                    EDIHeader.Description := SalesHeader."No.";

                    EDIHeader."Reference Type" := Database::"Sales Header";
                    EDIHeader."Reference Subtype" := SalesHeader."Document Type".AsInteger();
                    EDIHeader."Reference No." := SalesHeader."No.";
                    EDIHeader.Modify();

                    EDIHeader.CreateLink(EDIHeader."Reference Type", EDIHeader."Reference Subtype", EDIHeader."Reference No.");
                end;

            'DTM':
                begin
                    FormatQualifier := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 3, DES, CDES), 1, MaxStrLen(FormatQualifier));
                    case EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES) of

                        '137':  // order date
                            begin
                                FormatDateTime(CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(DocumentType)), DocumentDate, DocumentTime, FormatQualifier);
                                if IsNewOrder then begin
                                    SalesHeader."Document Date" := DocumentDate;
                                    SalesHeader."Order Date" := DocumentDate;
                                    SalesHeader.Validate("Posting Date", DocumentDate);
                                    SalesHeader.Modify();
                                end;

                                EDIHeader."Reference Date" := DocumentDate;
                                EDIHeader.Modify();

                            end;

                        '2':  // Delivery date
                            begin
                                FormatDateTime(CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(DocumentType)), DocumentDate, DocumentTime, FormatQualifier);
                                SalesHeader."Requested Delivery Date" := DocumentDate;
                                // spp SalesHeader."Requested Delivery Time" := DocumentTime;
                                SalesHeader.Modify();
                                ReqHeaderDeliveryDate := DocumentDate;
                            end;
                    end;
                end;

            'NAD':
                begin
                    CustId := CopyStr(EDIMgt.ReadTokenField(EDILine, 3, 1, DES, CDES), 1, MaxStrLen(CustId));
                    case EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES) of

                        'BY':  // buyer
                            begin
                                EDIValues.Reset();
                                EDIValues.FilterByRecord(Cust);
                                EDIValues.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                                EDIValues.SetRange("EDI Identifier", CustId);
                                if EDIValues.IsEmpty() then
                                    Error(GLNCustErr, CustId);

                                if not Cust.get(EDIValues."Source ID") then
                                    Error(GLNCustErr, CustId);

                                if IsNewOrder then begin
                                    if SalesHeader."Sell-to Customer No." <> Cust."No." then begin
                                        SalesHeader.Validate("Sell-to Customer No.", Cust."No.");
                                        SalesHeader.Modify();
                                    end;
                                    if SalesHeader."Bill-to Customer No." <> Cust."No." then begin
                                        SalesHeader.Validate("Bill-to Customer No.", Cust."No.");
                                        SalesHeader.Modify();
                                    end;
                                end
                                else
                                    SalesHeader.TestField("Sell-to Customer No.", Cust."No.");
                            end;

                        'DP':  // deposite
                            begin
                                // EDIMappingValue.Reset();
                                // EDIMappingValue.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                                // EDIMappingValue.SetRange(Type, EDIMappingValue.Type::"Ship-to");
                                // EDIMappingValue.SetRange("External Code", CustId);
                                // if EDIMappingValue.FindFirst() then begin
                                //     Cust.Get(EDIMappingValue."NAV-Code");
                                //     if SalesHeader."Sell-to Customer No." <> Cust."No." then
                                //         SalesHeader.Validate("Sell-to Customer No.", Cust."No.");
                                //     if (EDIMappingValue."NAV-Code 2" <> '') and
                                //        (SalesHeader."Ship-to Code" <> EDIMappingValue."NAV-Code 2")
                                //     then
                                //         // Start RI-TDAG12431-001/sdi
                                //         if IsNewOrder then
                                //             // Stop RI-TDAG12431-001/sdi
                                //             SalesHeader.Validate("Ship-to Code", EDIMappingValue."NAV-Code 2")
                                //         // Start RI-TDAG12431-001/sdi
                                //         else
                                //             SalesHeader.TestField("Ship-to Code", EDIMappingValue."NAV-Code 2");
                                //     // Stop RI-TDAG12431-001/sdi
                                //     SalesHeader.Modify();
                                // end else begin
                                //     EDIMappingValue.SetRange(Type, EDIMappingValue.Type::"Sell-to");
                                //     EDIMappingValue.SetRange("External Code", CustId);
                                //     if EDIMappingValue.FindFirst() then
                                //         Cust.Get(EDIMappingValue."NAV-Code")
                                //     else begin

                                EDIValues.Reset();
                                EDIValues.FilterByRecord(Cust);
                                EDIValues.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                                EDIValues.SetRange("EDI Identifier", CustId);

                                if EDIValues.IsEmpty() then
                                    Error(GLNCustErr, CustId);

                                if not Cust.get(EDIValues."Source ID") then
                                    Error(GLNCustErr, CustId);

                                if SalesHeader."Sell-to Customer No." <> Cust."No." then begin
                                    if IsNewOrder then
                                        SalesHeader.Validate("Sell-to Customer No.", Cust."No.")
                                    else
                                        SalesHeader.TestField("Sell-to Customer No.", Cust."No.");

                                    SalesHeader.Modify();
                                end;
                            end;
                    end;
                end;
        end;
    end;

    procedure UpdateSalesOrderLine(EDIHeader: Record "EOS074 EDI Message Header"; EDILine: Record "EOS074 EDI Message Line"; RecordType: Text[30]; var SalesHeader: Record 36; var SalesLine: Record 37);
    var
        //AnalyzedItem: Record 27;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        EDIMappingValue: Record "EOS074 EDI Mapping";
        TempSalesLine: Record "Sales Line" temporary;
        //UOMMgt: Codeunit "Unit of Measure Management";
        ProdCodeType: Code[10];
        ProductCode: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ISOUnitOfMeasureCode: Code[10];
        UnitOfMeasureCode: Code[10];
        ItemCrossReferenceCode: Code[20];
        LineDescription: Text[50];
        ItemFound: Boolean;
        OrderQuantity: Decimal;
        //NetPrice: Decimal;
        LineNo: Integer;
        ReqLineDeliveryDate: Date;
        ReqLineDeliveryTime: Time;
        //OldYear: Integer;
        //ProdQualified: Code[10];
        //SalesUOM: Code[10];
        //SalesQty: Decimal;
        FormatQualifier: Text[3];
        MaxLenght: text[30];
        LastLineNo: Integer;
    begin
        case RecordType of
            'LIN':
                begin
                    LineNo :=
                      FormatInteger(
                        CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES), 1, MaxStrLen(MaxLenght)));

                    ProductCode := CopyStr(EDIMgt.ReadTokenField(EDILine, 4, 1, DES, CDES), 1, MaxStrLen(ProductCode));
                    ProdCodeType := CopyStr(EDIMgt.ReadTokenField(EDILine, 4, 2, DES, CDES), 1, MaxStrLen(ProdCodeType));

                    if IsNewOrder then begin

                        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange("Document No.", SalesHeader."No.");

                        if SalesLine.FindLast() then
                            LastLineNo := SalesLine."Line No.";

                        SalesLine.Init();
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine."Line No." := LastLineNo + 10000;
                        SalesLine.Insert(true);
                    end
                    else begin
                        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                        SalesLine.SetRange("Document No.", SalesHeader."No.");
                        SalesLine.FindSet();
                    end;

                    case ProdCodeType of
                        'EN':
                            begin
                                ItemCrossReferenceCode := ProductCode;
                                ItemReference.Reset();
                                ItemReference.SETCURRENTKEY(
                                  "Reference No.", "Reference Type", "Reference Type No.");
                                ItemReference.SetRange("Reference No.", ProductCode);
                                ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Customer);
                                ItemReference.SetRange("Reference Type No.", SalesHeader."Sell-to Customer No.");
                                ItemFound := ItemReference.FindFirst();
                                if ItemFound then begin
                                    ItemNo := ItemReference."Item No.";
                                    VariantCode := ItemReference."Variant Code";
                                    if (ItemReference."Unit of Measure" <> '') and
                                       (UnitOfMeasureCode = '')
                                    then
                                        UnitOfMeasureCode := ItemReference."Unit of Measure";

                                    ItemCrossReferenceCode := ProductCode;
                                end;
                            end;
                        else
                            ItemNo := '';

                    end;

                    if (not ItemFound) and (ItemNo <> '') then
                        ItemFound := Item.Get(ItemNo);

                    if (not ItemFound) and (SalesLine."No." = '') then
                        Error(ItemExistErr, ProdCodeType, ProductCode);

                    // save previous values on current sales line.
                    TempSalesLine := SalesLine;
                    if (SalesLine."No." = '') then begin
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                        SalesLine.Validate("No.", ItemNo);
                        SalesLine.Validate("Variant Code", VariantCode);
                        SalesLineNoOnValidate();
                    end;
                    //IF (UnitOfMeasureCode <> '') AND
                    //   (SalesLine."Unit of Measure Code" <> UnitOfMeasureCode)
                    //THEN
                    //  SalesLine.VALIDATE("Unit of Measure Code",UnitOfMeasureCode);
                    if ItemCrossReferenceCode <> '' then begin
                        SalesLine.Validate("Item Reference No.", ItemCrossReferenceCode);
                        SalesLineNoOnValidate();
                    end;

                    SalesLine.Modify();
                end;

            'IMD':
                begin
                    ProdCodeType := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES), 1, MaxStrLen(ProdCodeType));

                    case ProdCodeType of
                        'F':
                            LineDescription := CopyStr(EDIMgt.ReadTokenField(EDILine, 4, 4, DES, CDES), 1, MaxStrLen(LineDescription));
                    end;
                end;

            'QTY':
                begin
                    SalesLine.TestField("No.");

                    //SalesUOM := SalesLine."Unit of Measure Code";

                    ISOUnitOfMeasureCode := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 3, DES, CDES), 1, MaxStrLen(ISOUnitOfMeasureCode));
                    OrderQuantity :=
                      EDIMgt.FormatDec(
                        CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(MaxLenght)));

                    if (ISOUnitOfMeasureCode <> '') AND (SalesLine."Unit of Measure Code" <> '') then begin
                        EDIMappingValue.Reset();
                        EDIMappingValue.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                        EDIMappingValue.SetRange(Type, EDIMappingValue.Type::"Unit Of Measure");
                        EDIMappingValue.SetRange("External Code", ISOUnitOfMeasureCode);
                        if EDIMappingValue.FindFirst() then
                            ISOUnitOfMeasureCode := CopyStr(EDIMappingValue."NAV-Code", 1, MaxStrLen(ISOUnitOfMeasureCode));
                    end;

                    if (ISOUnitOfMeasureCode <> '') and (ISOUnitOfMeasureCode <> SalesLine."Unit of Measure Code") then
                        OrderQuantity := EDIMgt.ConvertQty(SalesLine."No.", ISOUnitOfMeasureCode, SalesLine."Unit of Measure Code", OrderQuantity);
                    // ORG: SalesLine.VALIDATE("Unit of Measure Code", ISOUnitOfMeasureCode);

                    SalesLine.Validate(Quantity, OrderQuantity);
                    SalesLine.Modify();
                end;

            'DTM':
                begin
                    FormatQualifier := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES), 1, MaxStrLen(FormatQualifier));
                    case FormatQualifier of
                        '2':  // delivery date
                            begin
                                FormatDateTime(CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(MaxLenght)), ReqLineDeliveryDate, ReqLineDeliveryTime, FormatQualifier);
                                SalesLine."Requested Delivery Date" := ReqLineDeliveryDate;
                                SalesLine.Modify();
                                if ReqLineDeliveryDate > ReqHeaderDeliveryDate then
                                    ReqHeaderDeliveryDate := ReqLineDeliveryDate;
                            end;
                    end;
                end;

            'FTX':  // Packaging Information

                SalesLine.TestField("No.");
        //SalesLine.MODIFY;

        end;
    end;

    procedure FormatDateTime(DateTimeTxt: Text[30]; var NewDate: Date; var NewTime: Time; FormatQualifier: Text[3]);
    var
    //DateOK: Boolean;
    //TimeOK: Boolean;
    begin
        Clear(NewDate);
        Clear(NewTime);

        if Evaluate(
            NewDate,
            CopyStr(DateTimeTxt, 7, 2) +
            CopyStr(DateTimeTxt, 5, 2) +
            CopyStr(DateTimeTxt, 1, 4)) then
            ;

        if FormatQualifier = '203' then
            if Evaluate(NewTime, CopyStr(DateTimeTxt, 9, 4)) then;
    end;

    procedure FormatInteger(IntTxt: Text[30]) Int: Integer;
    begin
        if Evaluate(Int, IntTxt) then;
    end;

    procedure SalesLineNoOnValidate();
    begin
        SalesLineInsertExtendedText(false);
    end;

    procedure SalesLineInsertExtendedText(Unconditionally: Boolean);
    var
        TransferExtendedText: Codeunit "Transfer Extended Text";
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, Unconditionally) then
            TransferExtendedText.InsertSalesExtText(SalesLine);

    end;

}