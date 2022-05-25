report 70491814 "EOS074 Edifact Eancom OrdersIn"
{
    Caption = 'EDI Edifact Eancom Orders In';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(EDIHeader; "EOS074 EDI Message Header")
        {
            DataItemTableView = sorting("Message Type", "No.") order(Ascending) where("Message Type" = const("ORDERS IN"));
            dataitem(EDILine; "EOS074 EDI Message Line")
            {
                DataItemLink = "Message Type" = field("Message Type"), "Message No." = field("No.");
                DataItemTableView = sorting("Message Type", "Message No.", "Line No.") ORDER(Ascending);

                trigger OnAfterGetRecord()
                var
                    RecordType: Text[30];
                //DocCount: Integer;
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
                      'CTA', // TODO
                      'COM', // TODO
                      'CUX',
                      'LIN',
                      'PIA',
                      'IMD',
                      'MEA',
                      'QTY',
                      'FTX',
                      'PRI',
                      'UNS',
                      'MOA',
                      'CNT', // TODO
                      'UNT',
                      'UNZ',
                      'NAS',
                      'NAB'://spp
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

                EDIMessageDocument.Reset();
                EDIMessageDocument.SetRange("Message Type", "Message Type");
                EDIMessageDocument.SetRange("Message No.", "No.");
                EDIMessageDocument.SetRange("Table ID", Database::"Sales Header");
                EDIMessageDocument.SetRange("Document Type", 1);
                if EDIMessageDocument.FindSet() then
                    CurrReport.Skip();
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

    var
        EDIGroup: Record "EOS074 EDI Group";
        EDIMessageSetup: Record "EOS074 EDI Message Setup";
        EDIMessageDocument: Record "EOS074 EDI Message Document";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        //EDIExtractDoc: Record "EOS074 EDI Message Document";
        //CompanyInfo: Record "Company Information";
        //Cust: Record Customer;
        //Shipto: Record "Ship-to Address";
        // GLSetup: Record "General Ledger Setup";
        // Item: Record Item;
        // EDIMapping: Record "EOS074 EDI Mapping";
        EDIMgt: Codeunit "EOS074 EDI Management";
        //ProgressBar: Dialog;
        CDES: Text[1];
        DES: Text[1];
        // DN: Text[1];
        // RC: Text[1];
        // ST: Text[1];
        SegmentType: enum "EOS074 Segment Type";
        OrdersCreated: Integer;
        IsNewOrder: Boolean;
        // DeliveryDate: Date;
        // DeliveryTime: Time;
        NoValidRecErr: label 'No valid record type %1.';
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
        FindOrdErr: Label 'Impossible to find Order';
        DocShipErr: Label 'Document %1 already shipped';
        CustFoundErr: Label 'Customer %1: DP with GLN %2 does not found.';
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

    procedure HandleSegment(var EDIHeader: Record "EOS074 EDI Message Header"; EDILine: Record "EOS074 EDI Message Line"; RecordType: Text[30]; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
    //Customer: Record 18;
    begin
        case true of
            RecordType = 'BGM':
                begin
                    SegmentType := SegmentType::BGM;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'NAD'):
                begin
                    SegmentType := SegmentType::NAD;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'CTA'): // TODO
                begin
                    SegmentType := SegmentType::CTA;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'COM'): // TODO
                begin
                    SegmentType := SegmentType::CTA;
                    UpdateSalesOrder(EDIHeader, EDILine, RecordType, SalesHeader);
                end;

            (RecordType = 'RFF'):
                case SegmentType of
                    SegmentType::BGM:

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

            (RecordType = 'PIA') or
          (RecordType = 'FTX') or
          (RecordType = 'QTY'):
                case SegmentType of
                    SegmentType::LIN:
                        UpdateSalesOrderLine(EDIHeader, EDILine, RecordType, SalesHeader, SalesLine);
                end;
        end;
    end;

    procedure UpdateSalesOrder(var EDIHeader: Record "EOS074 EDI Message Header"; EDILine: Record "EOS074 EDI Message Line"; RecordType: Text[30]; var SalesHeader: Record "Sales Header")
    var
        CompanyInfo: Record "Company Information";
        Cust: Record Customer;
        //ShipToAddr: Record "Ship-to Address";
        //EDIMappingValue: Record "EOS074 EDI Mapping";
        EDILine2: Record "EOS074 EDI Message Line";
        EDIValues: Record "EOS074 EDI Values";
        ReleaseSalesDocument: Codeunit "Release Sales Document";
        //RefTransport: Code[20];
        CustId: Code[20];
        DocumentType: Text[30];
        DocumentDate: Date;
        //ShipmentDate: Date;
        //TestDocument: Boolean;
        //NextDocLineNo: Integer;
        //i: Integer;
        DocumentTime: Time;
        //_PVC_: Integer;
        ExternalOrderNo: Text[50];
    //NAD_CustIdFound: Boolean;
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
                    if IsNewOrder then begin

                        //TestDocument := EDIHeader."Test Stage" = true;

                        SalesHeader.SetHideValidationDialog(true);
                        SalesHeader.Init();
                        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;

                        // {
                        // if EDIHeader."Document No. Series" <> '' then begin
                        //                 SalesHeader."No. Series" := EDIHeader."Document No. Series";
                        //                 SalesHeader."No." :=
                        //                   NoSeriesMgt.GetNextNo(SalesHeader."No. Series", TODAY, true);
                        //             end else
                        //                 SalesHeader."No." := '';
                        // }

                        SalesHeader."No." := '';
                        SalesHeader.Insert(true);

                        OrdersCreated := OrdersCreated + 1;

                        /* Provinco non usa questo campo
                          // SalesHeader."Your Reference" := EDIMgt.ReadTokenField(EDILine,3,1,DES,CDES);
                        // IF TestDocument THEN
                        //  SalesHeader."Your Reference" := 'TEST ' + SalesHeader."Your Reference";
                        */

                        SalesHeader.Modify();

                        EDIHeader.Description := SalesHeader."No.";

                        EDIHeader."Reference Type" := Database::"Sales Header";
                        EDIHeader."Reference Subtype" := SalesHeader."Document Type".AsInteger();
                        EDIHeader."Reference No." := SalesHeader."No.";
                        EDIHeader.Modify();

                        EDIHeader.CreateLink(EDIHeader."Reference Type", EDIHeader."Reference Subtype", EDIHeader."Reference No.");
                    end
                    else begin
                        EDILine2.Reset();
                        EDILine2.SetRange("Message Type", EDIHeader."Message Type");
                        EDILine2.SetRange("Message No.", EDIHeader."No.");
                        EDILine2.SetRange("Record Type", 'RFF');
                        //forse solo aldi
                        EDILine2.SetRange("Record SubType", 'SZ');
                        if EDILine2.FindSet() then
                            UpdateSalesOrder(EDIHeader, EDILine2, EDILine2."Record Type", SalesHeader)
                        else
                            Error(FindOrdErr);
                    end;
                end;

            'DTM':

                case EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES) of
                    '137':  // order date
                        begin
                            FormatDateTime(CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(DocumentType)), DocumentDate, DocumentTime);
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
                            FormatDateTime(CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(DocumentType)), DocumentDate, DocumentTime);
                            SalesHeader."Requested Delivery Date" := DocumentDate;
                            // spp SalesHeader."Requested Delivery Time" := DocumentTime;
                            SalesHeader.Modify();
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
                                // Start PV-00000-001/sdi
                                // NAD_CustIdFound := false;
                                // // Start PV-00000-001/sdi
                                // EDIMappingValue.Reset();
                                // EDIMappingValue.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                                // EDIMappingValue.SetRange(Type, EDIMappingValue.Type::"Ship-to");
                                // EDIMappingValue.SetRange("External Code", CustId);
                                // if EDIMappingValue.FindFirst() then begin
                                //     Cust.Get(EDIMappingValue."NAV-Code");
                                //     // Start PV-00000-001/sdi
                                //     NAD_CustIdFound := SalesHeader."Sell-to Customer No." = Cust."No.";
                                //     if NAD_CustIdFound then begin
                                //         // Stop PV-00000-001/sdi

                                //         // Start PV-00000-001/sdi
                                //         // {
                                //         // // Stop PV-00000-001/sdi
                                //         // if SalesHeader."Sell-to Customer No." <> Cust."No." then
                                //         //                         SalesHeader.Validate("Sell-to Customer No.", Cust."No.");
                                //         // // Start PV-00000-001/sdi
                                //         // }
                                //         // Stop PV-00000-001/sdi
                                //         if (EDIMappingValue."NAV-Code 2" <> '') and
                                //            (SalesHeader."Ship-to Code" <> EDIMappingValue."NAV-Code 2")
                                //         then
                                //             // Start RI-TDAG12431-001/sdi
                                //             if IsNewOrder then begin
                                //                 // Stop RI-TDAG12431-001/sdi
                                //                 SalesHeader.Validate("Ship-to Code", EDIMappingValue."NAV-Code 2");
                                //                 EDIValues.Reset();
                                //                 EDIValues.FilterByRecord(SalesHeader);
                                //                 if EDIValues.FindFirst() then
                                //                     EDIValues."EDI Group Code" := EDIGroup.Code;
                                //                 // Start RI-TDAG12431-001/sdi

                                //                 EDIValues.Modify();
                                //             end else
                                //                 SalesHeader.TestField("Ship-to Code", EDIMappingValue."NAV-Code 2");
                                //         // Stop RI-TDAG12431-001/sdi
                                //         SalesHeader.Modify();
                                //         // Start PV-00000-001/sdi
                                //     end;
                                //     // Stop PV-00000-001/sdi
                                //     // Start PV-00000-001/sdi
                                //     // ORG: END ELSE BEGIN
                                // end;

                                // if not NAD_CustIdFound then begin

                                EDIValues.Reset();
                                EDIValues.FilterByRecord(Cust);
                                EDIValues.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                                EDIValues.SetRange("EDI Identifier", CustId);

                                if EDIValues.IsEmpty() then
                                    Error(CustFoundErr, SalesHeader."Sell-to Customer No.", CustId);

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

            'RFF':

                if SegmentType = SegmentType::BGM then
                    case EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES) of
                        'SZ':
                            begin
                                ExternalOrderNo := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES), 1, MaxStrLen(ExternalOrderNo));
                                if IsNewOrder then begin
                                    SalesHeader."External Document No." := CopyStr(ExternalOrderNo, 1, MaxStrLen(SalesHeader."External Document No."));
                                    SalesHeader.Modify();
                                end
                                else begin
                                    SalesHeader.SETCURRENTKEY("Sell-to Customer No.", "External Document No.");
                                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                                    // SalesHeader.SETRANGE("External Document No.", ExternalOrderNo);
                                    SalesHeader.SetFilter("External Document No.", '*' + ExternalOrderNo + '*');

                                    EDIValues.Reset();
                                    EDIValues.FilterByRecord(SalesHeader);
                                    EDIValues.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                                    if EDIValues.IsEmpty() then
                                        Error(ExtDocErr, ExternalOrderNo);

                                    EDIHeader.Description := SalesHeader."No.";

                                    EDIHeader."Reference Type" := Database::"Sales Header";
                                    EDIHeader."Reference Subtype" := SalesHeader."Document Type".AsInteger();
                                    EDIHeader."Reference No." := SalesHeader."No.";
                                    EDIHeader.Modify();

                                    EDIHeader.CreateLink(EDIHeader."Reference Type", EDIHeader."Reference Subtype", EDIHeader."Reference No.");

                                    if SalesHeader.Status = SalesHeader.Status::Released then
                                        ReleaseSalesDocument.Reopen(SalesHeader);

                                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                                    SalesLine.SetFilter("Quantity Shipped", '>%1', 0);
                                    if SalesLine.IsEmpty() then begin
                                        // SalesLine.DELETEALL(TRUE)
                                        SalesLine.SetRange("Quantity Shipped");
                                        if SalesLine.FindSet() then
                                            repeat
                                                SalesLine.Delete(true);
                                            until SalesLine.Next() = 0;
                                    end
                                    else
                                        Error(DocShipErr, SalesHeader."No.");

                                    SalesHeader.Modify();
                                end;
                            end;
                    end;

        end;
    end;

    procedure UpdateSalesOrderLine(EDIHeader: Record "EOS074 EDI Message Header"; EDILine: Record "EOS074 EDI Message Line"; RecordType: Text[30]; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line");
    var
        //AnalyzedItem: Record "Item";
        Item: Record "Item";
        EDIMappingValue: Record "EOS074 EDI Mapping";
        TempSalesLine: Record "Sales Line" temporary;
        ItemReference: Record "Item Reference";
        ProdCodeType: Code[10];
        ProductCode: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        ISOUnitOfMeasureCode: Code[10];
        UnitOfMeasureCode: Code[10];
        ItemCrossReferenceCode: Code[20];
        LineDescription: Text[50];
        MaxLenght: Text[30];
        ItemFound: Boolean;
        OrderQuantity: Decimal;
        //NetPrice: Decimal;
        LineNo: Integer;
        //ReqLineDeliveryDate: Date;
        //OldYear: Integer;
        ProdQualified: Code[10];
        //SalesUOM: Code[10];
        //SalesQty: Decimal;
        LastLineNo: Integer;
    begin
        case RecordType of
            'LIN':
                begin
                    LineNo :=
                      FormatInteger(
                        CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES), 1, MaxStrLen(MaxLenght)));

                    SalesLine.Reset();
                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange("Document No.", SalesHeader."No.");

                    if SalesLine.FindLast() then
                        LastLineNo := SalesLine."Line No.";

                    SalesLine.Init();
                    SalesLine."Document Type" := SalesHeader."Document Type";
                    SalesLine."Document No." := SalesHeader."No.";
                    SalesLine."Line No." := LastLineNo + 10000;
                    SalesLine.Insert(true);

                end;

            //   {
            //     'DTM':
            //       begin
            //             case EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES) of
            //                 '2':  // delivery date
            //                     begin
            //                         ReqLineDeliveryDate :=
            //                           EDIMgt.FormatDate(
            //                             EDIMgt.ReadTokenField(EDILine, 2, 2, DES, CDES));
            //                         SalesLine."Requested Delivery Date" := ReqLineDeliveryDate;
            //                         SalesLine.Modify();
            //                         if ReqLineDeliveryDate > ReqHeaderDeliveryDate then
            //                             ReqHeaderDeliveryDate := ReqLineDeliveryDate;
            //                     end;
            //             end;
            //         end;
            //   }

            'PIA':
                begin
                    ProdQualified := CopyStr(EDIMgt.ReadTokenField(EDILine, 2, 1, DES, CDES), 1, MaxStrLen(ProdQualified));
                    ProductCode := CopyStr(EDIMgt.ReadTokenField(EDILine, 3, 1, DES, CDES), 1, MaxStrLen(ProductCode));
                    ProdCodeType := CopyStr(EDIMgt.ReadTokenField(EDILine, 3, 2, DES, CDES), 1, MaxStrLen(ProdCodeType));

                    case ProdQualified of
                        '5':  // Product Identification (ALDI Product Code)

                            case ProdCodeType of
                                'IN':
                                    begin
                                        ItemCrossReferenceCode := ProductCode;
                                        ItemReference.Reset();
                                        ItemReference.SETCURRENTKEY(
                                          "Reference No.", "Reference Type", "Reference Type No.");
                                        ItemReference.SetRange("Reference No.", ProductCode);
                                        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Customer);
                                        ItemReference.SetRange("Reference Type No.", SalesHeader."Sell-to Customer No.");
                                        // ORG: ItemFound := ItemCrossRef.FINDFIRST;
                                        if ItemReference.FindSet() then
                                            repeat
                                                Item.Get(ItemReference."Item No.");
                                                ItemFound := not Item.Blocked;
                                                if ItemFound then begin
                                                    ItemNo := ItemReference."Item No.";
                                                    VariantCode := ItemReference."Variant Code";
                                                    if (ItemReference."Unit of Measure" <> '') and
                                                       (UnitOfMeasureCode = '')
                                                    then
                                                        UnitOfMeasureCode := ItemReference."Unit of Measure";

                                                    ItemCrossReferenceCode := ProductCode;
                                                end;
                                            until (ItemReference.Next() = 0) or ItemFound
                                    end;
                                else
                                    ItemNo := '';

                            end;

                        '1':  // Additional Identification (Contract Number)

                            case ProdCodeType of
                                'XY8':   // Supplier assigned (Contract Number)

                                    ItemNo := ProductCode;

                                else
                                    ItemNo := '';

                            end;

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

                LineDescription := CopyStr(EDIMgt.ReadTokenField(EDILine, 4, 4, DES, CDES), 1, MaxStrLen(LineDescription));


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
            'FTX':  // Packaging Information

                SalesLine.TestField("No.");
        //SalesLine.MODIFY;

        end;
    end;

    procedure FormatDateTime(DateTimeTxt: Text[30]; var NewDate: Date; var NewTime: Time);
    var
    // DateOK: Boolean;
    // TimeOK: Boolean;
    begin
        Clear(NewDate);
        Clear(NewTime);

        if Evaluate(
            NewDate,
            CopyStr(DateTimeTxt, 7, 2) +
            CopyStr(DateTimeTxt, 5, 2) +
            CopyStr(DateTimeTxt, 1, 4)) then
            ;

        if Evaluate(NewTime, CopyStr(DateTimeTxt, 9, 4)) then;
    end;

    procedure FormatInteger(IntTxt: Text[30]) Int: Integer;
    begin
        if Evaluate(Int, IntTxt) then;
    end;

    procedure SalesLineNoOnValidate();
    var
    begin
        SalesLineInsertExtendedText(false);
    end;

    procedure SalesLineInsertExtendedText(Unconditionally: Boolean);
    var
        TransferExtendedText: Codeunit 378;
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, Unconditionally) then
            TransferExtendedText.InsertSalesExtText(SalesLine);
    end;

}