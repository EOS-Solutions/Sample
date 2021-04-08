report 70491813 "EOS074 Euritmo Invoice Out"
{
    Caption = 'EDI Euritmo Invoice Out';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(EDIMessageSetup; "EOS074 EDI Message Setup")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Message Type", "EDI Group Code", "Date Filter", "Document No. Filter";
            dataitem(EDIValues1; "EOS074 EDI Values")
            {

                dataitem(SalesInvHeader; "Sales Invoice Header")
                {
                    DataItemLink = "No." = field("Source ID");
                    DataItemTableView = sorting("Bill-to Customer No.", "Posting Date");
                    RequestFilterFields = "Posting Date";

                    trigger OnAfterGetRecord()
                    begin
                        ProgressBar.Update(3, "No.");

                        EDIDocType := EDIDocType::"Sales Invoice";

                        if not EDIMgt.CreateEDIHeader(EDIHeader, EDIMessageSetup, Database::"Sales Invoice Header", 0, "No.", "Posting Date") then
                            CurrReport.Skip();

                        SalesInvLine.Reset();
                        SalesInvLine.SetRange("Document No.", "No.");
                        SalesInvLine.SetRange("Bill-to Customer No.", "Bill-to Customer No.");
                        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                        SalesInvLine.SetFilter(Quantity, '<>%1', 0);
                        if SalesInvLine.IsEmpty() then
                            CurrReport.Skip();

                        if SalesInvHeader."Currency Code" = '' then
                            Currency.InitRoundingPrecision()
                        else begin
                            SalesInvHeader.TestField("Currency Factor");
                            Currency.Get(SalesInvHeader."Currency Code");
                            Currency.TestField("Amount Rounding Precision");
                        end;

                        Ins_BGM(EDIDocType::"Sales Invoice");

                        DETLineNo := 1;
                        if SalesInvLine.FindSet() then
                            repeat
                                Ins_DET(EDIDocType::"Sales Invoice");
                            until SalesInvLine.Next() = 0;

                        Ins_SUM(EDIDocType::"Sales Invoice");
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not EDIGroup."Allow Invoice" then
                            CurrReport.break();

                        ProgressBar.Update(2, TableCaption());

                        if EDIMessageSetup.GETFILTER("Date Filter") <> '' then
                            SetFilter("Posting Date", EDIMessageSetup.GETFILTER("Date Filter"));
                        if EDIMessageSetup.GETFILTER("Document No. Filter") <> '' then
                            SetFilter("No.", EDIMessageSetup.GETFILTER("Document No. Filter"));

                        if not EDIMessageSetup.IsTableAllowed(Database::"Sales Invoice Header") then
                            CurrReport.break();
                    end;
                }
            }

            dataitem(EDIValues2; "EOS074 EDI Values")
            {
                dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
                {
                    DataItemLink = "No." = field("Source ID");
                    DataItemTableView = sorting("Bill-to Customer No.", "Posting Date");

                    RequestFilterFields = "Posting Date";

                    trigger OnAfterGetRecord()
                    begin
                        ProgressBar.Update(3, "No.");

                        EDIDocType := EDIDocType::"Sales Cr.Memo";

                        if not EDIMgt.CreateEDIHeader(EDIHeader, EDIMessageSetup, Database::"Sales Invoice Header", 0, "No.", "Posting Date") then
                            CurrReport.Skip();

                        SalesCrMemoLine.Reset();
                        SalesCrMemoLine.SetRange("Document No.", "No.");
                        SalesCrMemoLine.SetRange("Bill-to Customer No.", "Bill-to Customer No.");
                        SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
                        if SalesCrMemoLine.IsEmpty() then
                            CurrReport.Skip();

                        if SalesCrMemoHeader."Currency Code" = '' then
                            Currency.InitRoundingPrecision()
                        else begin
                            SalesCrMemoHeader.TestField("Currency Factor");
                            Currency.Get(SalesCrMemoHeader."Currency Code");
                            Currency.TestField("Amount Rounding Precision");
                        end;

                        Ins_BGM(EDIDocType::"Sales Cr.Memo");

                        DETLineNo := 1;
                        if SalesCrMemoLine.Find('-') then
                            repeat
                                Ins_DET(EDIDocType::"Sales Cr.Memo");
                            until SalesCrMemoLine.Next() = 0;

                        Ins_SUM(EDIDocType::"Sales Cr.Memo");
                    end;

                    trigger OnPreDataItem()
                    begin
                        if not EDIGroup."Allow Cr.Memo" then
                            CurrReport.Break();

                        ProgressBar.Update(2, TableCaption());

                        if EDIMessageSetup.GETFILTER("Date Filter") <> '' then
                            SetFilter("Posting Date", EDIMessageSetup.GETFILTER("Date Filter"));
                        if EDIMessageSetup.GETFILTER("Document No. Filter") <> '' then
                            SetFilter("No.", EDIMessageSetup.GETFILTER("Document No. Filter"));

                        if not EDIMessageSetup.IsTableAllowed(Database::"Sales Cr.Memo Header") then
                            CurrReport.Break();
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed() then
                    ProgressBar.Update(1, "EDI Group Code");

                TestField("Message Type", "Message Type"::"INVOIC OUT");
                EDIGroup.Get("EDI Group Code");
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed() then
                    ProgressBar.Close();
            end;

            trigger OnPreDataItem()
            begin
                if GuiAllowed() then
                    ProgressBar.OPEN(EdiGroupLbl + TableLbl + DocNoLbl);
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

    trigger OnInitReport()
    begin
        EDIGroup.SetFilter(EDIGroup.Code, EDIHeader.GETFILTER("EDI Group Code"));

        GLSetup.Get();
        CompanyInfo.Get();
    end;

    trigger OnPreReport()
    begin
        TmpSeparator := 9;
        Separator := Format(TmpSeparator);
    end;

    var
        EDIGroup: Record "EOS074 EDI Group";
        EDIHeader: Record "EOS074 EDI Message Header";
        EDILine: Record "EOS074 EDI Message Line";
        EDIExtractDoc: Record "EOS074 EDI Message Document";
        CompanyInfo: Record "Company Information";
        Cust: Record Customer;
        CustInvoice: Record Customer;
        Shipto: Record "Ship-to Address";
        GLSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesShiptHeader: Record "Sales Shipment Header";
        EDICrossTable: Record "EOS074 EDI Mapping";
        ReturnRcptHeader: Record "Return Receipt Header";
        SRSetup: Record "Sales & Receivables Setup";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        EDIMgt: Codeunit "EOS074 EDI Management";
        EDIDocType: enum "EOS074 EDI Document Type";
        LineNo: Integer;
        ProgressBar: Dialog;
        TmpInteger: Integer;
        TempField: Text[30];
        TempRecord: Text[350];
        TempDecimal: Decimal;
        TmpSeparator: Char;
        Separator: Text[1];
        VatNo: Text[30];
        DETLineNo: Integer;
        DocAmount: Decimal;
        DocVat: Decimal;
        DocTotal: Decimal;
        TmpDocNo: Integer;
        DiscountTxt: array[4] of Code[20];
        DiscountVal: array[4] of Decimal;
        // DiscountNo: Integer;
        DocDiscAmount: Decimal;
        PaymentDiscAmount: Decimal;
        InvoiceDiscAmount: Decimal;
        DiscountSeqNo: Integer;
        FTTRecordNo: Integer;
        NotBlankErr: Label '%1 shall not be blank!';
        LenghtRecExcErr: Label 'Lenght of Record %1 excedeed  %2 characters. Field %3.\ %4 characters.';
        EdiGroupLbl: Label 'EDI - Group #1########\';
        TableLbl: Label 'Table      #2########\';
        DocNoLbl: Label 'Document No. #3########';
        IlnCodeErr: Label 'ILN %1 code must be numeric.';
        ConaiTxt: Label 'CONAI contribution paid where necessary';
        TooManyCharsErr: Label 'Too many chars.';

    procedure InitEDILine()
    begin
        LineNo := LineNo + 10000;

        EDILine.Init();
        EDILine."Message Type" := EDIHeader."Message Type";
        EDILine."Message No." := EDIHeader."No.";
        EDILine."Line No." := LineNo;
    end;

    procedure InsertEdiLine(FixedFileP: Boolean; MaxLenRecordP: Integer)
    begin
        if EDILine."Record Type" = 'FTT' then begin
            FTTRecordNo += 1;
            if FTTRecordNo > 5 then
                exit;
        end;
        if EDILine."Record Type" = 'BGM' then
            FTTRecordNo := 0;

        if FixedFileP then
            if (StrLen(EDILine."Field 1") + StrLen(EDILine."Field 2") + StrLen(EDILine."Field 3")) > MaxLenRecordP then
                Error(LenghtRecExcErr, EDILine."Record Type", MaxLenRecordP,
                                                     EDILine."Record Type",
                                                     StrLen(EDILine."Field 1") +
                                                     StrLen(EDILine."Field 2") +
                                                     StrLen(EDILine."Field 3"));
        EDILine.Insert();
    end;

    // procedure "Belegtypeníbergabe"(BelegtypLoc: Code[10])
    // begin
    //     Belegtyp := BelegtypLoc;
    // end;

    // procedure DeciStr(NrP: Decimal; LenghtP: Integer; DecimalsP: Integer; NullZeroP: Boolean) NumString: Text[15]
    // begin
    //     if (NrP = 0) and NullZeroP then
    //         exit('')
    //     else
    //         case DecimalsP of
    //             0:
    //                 exit(Format(NrP, Lenght));
    //             2:
    //                 exit(Format(NrP, Lenght, '<Precision,2><Standard Format,2>'));
    //             3:
    //                 exit(Format(NrP, Lenght, '<Precision,3><Standard Format,2>'));
    //             6:
    //                 exit(Format(NrP, Lenght, '<Precision,6><Standard Format,2>'));
    //         end;
    // end;

    procedure DateFormat(DateP: Date) DateResult: Text[8]
    begin
        if DateP = 0D then
            exit('        ')
        else
            exit(Format(DateP, 8, '<year4><month,2><day,2>'));
    end;

    procedure FormatNumDecBiFront(NrP: Decimal; LengthP: Integer; DecimalsP: Integer): Text[100]
    var
        FormatStr: Text[50];
        DecText: Text[100];
        StringLbl: Label '<Integer,%1><Filler,0><Decimals>', Locked = true;
    begin
        FormatStr := StrSubstNo(StringLbl, LengthP - DecimalsP);
        DecText := Format(NrP, 0, FormatStr);
        DecText := DELCHR(DecText, '=', ',.');
        if DecimalsP > 0 then
            DecText := CopyStr(PADSTR(DecText, LengthP, '0'), 1, MaxStrLen(DecText));
        exit(DecText);
    end;

    procedure SignText(ValueP: Decimal; TempRecordP: Text[30]): Text[30]
    var
        TempRecordLoc: Text[30];
    begin
        if ValueP >= 0 then
            TempRecordLoc := CopyStr('+' + TempRecordP, 1, MaxStrLen(TempRecordLoc))
        else
            TempRecordLoc := CopyStr('-' + TempRecordP, 1, MaxStrLen(TempRecordLoc));

        exit(TempRecordLoc);
    end;

    procedure MaxValue(Num1P: Integer; Num2P: Integer) MaxNum: Integer
    begin
        if Num1P > Num2P then
            exit(Num1P)
        else
            exit(Num2P);
    end;

    procedure MinValue(Num1P: Integer; Num2P: Integer) MinNum: Integer
    begin
        if Num1P < Num2P then
            exit(Num1P)
        else
            exit(Num2P);
    end;

    procedure InsDocExtracts(EDIDocType: enum "EOS074 EDI Document Type"; "Doc No.": Code[20])
    begin
        EDIExtractDoc.Init();
        EDIExtractDoc."Message Type" := EDIHeader."Message Type";
        EDIExtractDoc."Message No." := EDIHeader."No.";
        EDIExtractDoc."Table ID" := EDIDocType.AsInteger();
        EDIExtractDoc."Document No." := "Doc No.";
        EDIExtractDoc.Insert();
    end;

    procedure EDIInsRow(FieldNameP: Text[100]; TextP: Text[1024]; NotEmptyAllowedP: Boolean; FixFormatP: Boolean; MaxLenghtP: Integer; SpaceInZeroP: Boolean)
    var
        LenghtF1Loc: Integer;
        LenghtF2Loc: Integer;
        LenghtF3Loc: Integer;
        RestLeghtLoc: Integer;
        TextLenghtLoc: Integer;
        TextLoc: Text[1024];
    begin
        if NotEmptyAllowedP and (TextP = '') then
            Error(NotBlankErr, FieldNameP);

        if FixFormatP then begin
            TextLoc := PADSTR(TextP, MaxLenghtP) + '|';
            TextP := CopyStr(PADSTR(TextP, MaxLenghtP), 1, MaxStrLen(TextP));
        end else begin
            TextLoc := CopyStr(TextP + '|', 1, MaxStrLen(TextLoc));
            TextP := CopyStr(TextP + Separator, 1, MaxStrLen(TextP));
        end;

        if SpaceInZeroP then begin
            TextP := ConvertStr(TextP, ' ', '0');
            TextLoc := ConvertStr(TextLoc, ' ', '0');
        end;

        LenghtF1Loc := StrLen(EDILine."Field 1");
        LenghtF2Loc := StrLen(EDILine."Field 2");
        LenghtF3Loc := StrLen(EDILine."Field 3");
        TextLenghtLoc := StrLen(TextP);
        RestLeghtLoc := MAXSTRLEN(EDILine."Field 1") - LenghtF1Loc;

        if RestLeghtLoc > 0 then begin
            EDILine."Field 1" := EDILine."Field 1" + CopyStr(TextP, 1, MinValue(RestLeghtLoc, TextLenghtLoc));
            if TextLenghtLoc > RestLeghtLoc then begin
                TextP := CopyStr(TextP, MinValue(RestLeghtLoc, TextLenghtLoc) + 1, MaxStrLen(TextP));
                TextLenghtLoc := StrLen(TextP);
            end else
                TextLenghtLoc := 0;
        end;

        RestLeghtLoc := MAXSTRLEN(EDILine."Field 2") - LenghtF2Loc;

        if (RestLeghtLoc > 0) and
           (TextLenghtLoc > 0)
        then begin
            EDILine."Field 2" := EDILine."Field 2" + CopyStr(TextP, 1, MinValue(RestLeghtLoc, TextLenghtLoc));
            if TextLenghtLoc > RestLeghtLoc then begin
                TextP := CopyStr(TextP, MinValue(RestLeghtLoc, TextLenghtLoc) + 1, MaxStrLen(TextP));
                TextLenghtLoc := StrLen(TextP);
            end else
                TextLenghtLoc := 0;

        end;

        RestLeghtLoc := MAXSTRLEN(EDILine."Field 3") - LenghtF3Loc;

        if (RestLeghtLoc > 0) and
           (TextLenghtLoc > 0)
        then begin
            EDILine."Field 3" := EDILine."Field 3" + CopyStr(TextP, 1, MinValue(RestLeghtLoc, TextLenghtLoc));
            if TextLenghtLoc > RestLeghtLoc then begin
                TextP := CopyStr(TextP, MinValue(RestLeghtLoc, TextLenghtLoc) + 1, MaxStrLen(TextP));
                TextLenghtLoc := StrLen(TextP);
            end else
                TextLenghtLoc := 0;
        end;

        if TextLenghtLoc > 0 then
            Error(TooManyCharsErr);

        EDILine."No. of Fields" += 1;
    end;

    procedure FormatILN(ILNP: Text[30]): Text[30]
    begin
        if not Evaluate(TmpInteger, ILNP) then
            Error(IlnCodeErr, ILNP);
        exit(CopyStr(FormatNumDecBiFront(TmpInteger, 7, 0), 1, MaxStrLen(ILNP)));
    end;

    procedure MakeInfoLine(EdiDocTypeP: enum "EOS074 EDI Document Type")
    begin
    end;

    procedure MakeSummaryFooter(EdiDocTypeP: enum "EOS074 EDI Document Type")
    begin
    end;

    procedure Ins_BGM(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        CustLedgerEntryLoc: Record "Cust. Ledger Entry";
        EDIValues: Record "EOS074 EDI Values";
        EDIGr: Record "EOS074 EDI Group";
        RoutingNoLoc: Text[30];
        DocTypeLoc: Text[30];
        DocNoLoc: Code[20];
        DateLoc: Date;
        TimeLoc: Time;
        PaymTermLoc: Code[10];
    begin
        DocAmount := 0;
        DocVat := 0;
        DocTotal := 0;
        DocDiscAmount := 0;
        InvoiceDiscAmount := 0;
        PaymentDiscAmount := 0;
        LineNo := 0;

        case EdiDocTypeP of
            EDIDocType::"Sales Invoice":
                begin
                    Cust.Get(SalesInvHeader."Sell-to Customer No.");
                    CustInvoice.Get(SalesInvHeader."Bill-to Customer No.");

                    if SalesInvHeader."VAT Registration No." <> '' then
                        VatNo := StripCountryCode(SalesInvHeader."VAT Registration No.")
                    else
                        VatNoAssignementForInsBGM(CustInvoice, VatNo);

                    SalesInvLine.Find('+');
                    if GetShipmentNo() then
                        DocTypeLoc := 'INVOIC'
                    else
                        DocTypeLoc := 'NOTADD';
                    DateLoc := SalesInvHeader."Posting Date";
                    case EDIGroup."Document Nos." of
                        EDIGroup."Document Nos."::Alphanumeric:

                            DocNoLoc := SalesInvHeader."No.";

                        EDIGroup."Document Nos."::Numeric:
                            begin
                                Evaluate(TmpDocNo, TakeNr(SalesInvHeader."No."));
                                DocNoLoc := Format(TmpDocNo);
                            end;
                    end;
                    RoutingNoLoc := '';
                    TimeLoc := 0T;

                    //PAT
                    PaymTermLoc := SalesInvHeader."Payment Terms Code";
                    CustLedgerEntryLoc.Reset();
                    CustLedgerEntryLoc.SETCURRENTKEY("Document Type", "Customer No.", "Posting Date", "Document No.");
                    CustLedgerEntryLoc.SetRange("Document No.", SalesInvHeader."No.");
                    CustLedgerEntryLoc.SetRange("Document Type", CustLedgerEntryLoc."Document Type"::Invoice);
                    CustLedgerEntryLoc.SetRange("Customer No.", SalesInvHeader."Bill-to Customer No.");
                    CustLedgerEntryLoc.SetRange("Posting Date", SalesInvHeader."Posting Date");

                end;
            EDIDocType::"Sales Cr.Memo":
                begin
                    Cust.Get(SalesCrMemoHeader."Sell-to Customer No.");
                    CustInvoice.Get(SalesCrMemoHeader."Bill-to Customer No.");


                    if SalesCrMemoHeader."VAT Registration No." <> '' then
                        VatNo := StripCountryCode(SalesCrMemoHeader."VAT Registration No.")
                    else
                        VatNoAssignementForInsBGM(CustInvoice, VatNo);



                    DocTypeLoc := 'NOTACC';
                    case EDIGroup."Document Nos." of
                        EDIGroup."Document Nos."::Alphanumeric:

                            DocNoLoc := SalesCrMemoHeader."No.";

                        EDIGroup."Document Nos."::Numeric:
                            begin
                                Evaluate(TmpDocNo, TakeNr(SalesCrMemoHeader."No."));
                                DocNoLoc := Format(TmpDocNo);
                            end;
                    end;
                    DateLoc := SalesCrMemoHeader."Posting Date";
                    RoutingNoLoc := '';
                    TimeLoc := 0T;

                    //PAT
                    PaymTermLoc := SalesCrMemoHeader."Payment Terms Code";
                    CustLedgerEntryLoc.Reset();
                    CustLedgerEntryLoc.SETCURRENTKEY("Document Type", "Customer No.", "Posting Date", "Document No.");
                    CustLedgerEntryLoc.SetRange("Document No.", SalesCrMemoHeader."No.");
                    CustLedgerEntryLoc.SetRange("Document Type", CustLedgerEntryLoc."Document Type"::"Credit Memo");
                    CustLedgerEntryLoc.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
                    CustLedgerEntryLoc.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");

                end;
        end;

        InitEDILine();
        EDILine."Record Type" := 'BGM';

        TempField := 'TIPOREC';
        TempRecord := 'BGM';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        EDIValues.Reset();
        EDIValues.FilterByRecord(CompanyInfo);

        case EDIGroup."EDI-SEND Out" of
            EDIGroup."EDI-SEND Out"::VAT:
                begin
                    TempField := 'ID-EDI-MITT-1';
                    TempRecord := StripCountryCode(CompanyInfo."VAT Registration No.");
                    EDIInsRow(TempField, TempRecord, true, true, 35, false);

                    TempField := 'ID-EDI-MITT-2';
                    TempRecord := 'ZZ';
                    EDIInsRow(TempField, TempRecord, true, true, 4, false);
                end;

            EDIGroup."EDI-SEND Out"::ILN:
                begin
                    TempField := 'ID-EDI-MITT-1';

                    if EDIValues.FindSet() then
                        TempRecord := EDIValues."EDI Identifier";

                    EDIInsRow(TempField, TempRecord, true, true, 35, false);

                    TempField := 'ID-EDI-MITT-2';
                    TempRecord := '14';
                    EDIInsRow(TempField, TempRecord, true, true, 4, false);
                end;

            EDIGroup."EDI-SEND Out"::"Fixed Company Info":
                begin
                    TempField := 'ID-EDI-MITT-1';

                    if EDIValues.FindSet() then
                        if EDIGr.Get(EDIValues."EDI Group Code") then
                            TempRecord := EDIGr."ID-EDI-SEND1";

                    EDIInsRow(TempField, TempRecord, true, true, 35, false);

                    TempField := 'ID-EDI-MITT-2';

                    if EDIValues.FindSet() then
                        if EDIGr.Get(EDIValues."EDI Group Code") then
                            TempRecord := EDIGr."ID-EDI-SEND2";

                    EDIInsRow(TempField, TempRecord, true, true, 4, false);
                end;
        end;

        TempField := 'ID-EDI-MITT-3';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 14, false);

        EDIValues.Reset();
        EDIValues.FilterByRecord(CustInvoice);

        case EDIGroup."EDI-RECI Out" of
            EDIGroup."EDI-RECI Out"::VAT:
                begin
                    TempField := 'ID-EDI-DEST-1';
                    TempRecord := StripCountryCode(CustInvoice."VAT Registration No.");
                    EDIInsRow(TempField, TempRecord, true, true, 35, false);
                    TempField := 'ID-EDI-DEST-2';
                    TempRecord := 'ZZ';
                    EDIInsRow(TempField, TempRecord, true, true, 4, false);
                end;
            EDIGroup."EDI-RECI Out"::ILN:
                begin
                    TempField := 'ID-EDI-DEST-1';

                    if EDIValues.FindFirst() then
                        TempRecord := EDIValues."EDI Identifier";

                    EDIInsRow(TempField, TempRecord, true, true, 35, false);
                    TempField := 'ID-EDI-DEST-2';
                    TempRecord := '14';
                    EDIInsRow(TempField, TempRecord, true, true, 4, false);
                end;
            EDIGroup."EDI-RECI Out"::Fixed:
                begin
                    TempField := 'ID-EDI-DEST-1';
                    TempRecord := EDIGroup."ID-EDI-RECI1";
                    EDIInsRow(TempField, TempRecord, true, true, 35, false);
                    TempField := 'ID-EDI-DEST-2';
                    TempRecord := EDIGroup."ID-EDI-RECI2";
                    EDIInsRow(TempField, TempRecord, true, true, 4, false);
                end;
        end;

        TempField := 'ID-EDI-DEST-3';
        TempRecord := RoutingNoLoc;
        EDIInsRow(TempField, TempRecord, false, true, 14, false);

        TempField := 'TIPODOC';
        TempRecord := DocTypeLoc;
        EDIInsRow(TempField, TempRecord, true, true, 6, false);

        TempField := 'NUMDOC';
        TempRecord := DocNoLoc;
        EDIInsRow(TempField, TempRecord, true, true, 35, false);

        TempField := 'DATADOC';
        TempRecord := DateFormat(DateLoc);
        EDIInsRow(TempField, TempRecord, true, true, 8, false);

        TempField := 'ORADOC';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 4, false);

        TempField := 'FILLER';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 6, false);

        InsertEdiLine(true, 168);

        Ins_NAS(EdiDocTypeP);
        Ins_NAI(EdiDocTypeP);
        //Ins_NAP(EdiDocTypeP);
        //Ins_NAA(EdiDocTypeP);
        //Ins_NAT(EdiDocTypeP);
        Ins_FTX_Standard(EdiDocTypeP);

        if CustLedgerEntryLoc.Find('-') then
            repeat
                Ins_PAT(EdiDocTypeP,
                        PaymTermLoc,
                        CustLedgerEntryLoc);
            until CustLedgerEntryLoc.Next() = 0;
    end;

    procedure Ins_NAS(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        EDIValues: Record "EOS074 EDI Values";
        EDIGr: Record "EOS074 EDI Group";
        DivisionCode: Code[20];
    begin
        case EdiDocTypeP of
            EdiDocTypeP::"Sales Invoice":

                DivisionCode := SalesInvHeader."Shortcut Dimension 2 Code";

            EdiDocTypeP::"Sales Cr.Memo":

                DivisionCode := SalesCrMemoHeader."Shortcut Dimension 2 Code";

        end;

        InitEDILine();
        EDILine."Record Type" := 'NAS';

        TempField := 'TIPOREC';
        TempRecord := 'NAS';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        EDIValues.Reset();
        EDIValues.FilterByRecord(CompanyInfo);

        case EDIGroup."EDI-SUPP Out" of
            EDIGroup."EDI-SUPP Out"::VA:
                begin
                    TempField := 'CODFORN';
                    TempRecord := StripCountryCode(CompanyInfo."VAT Registration No.");
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODFORN';
                    TempRecord := 'VA';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);

                end;
            EDIGroup."EDI-SUPP Out"::ILN:
                begin
                    TempField := 'CODFORN';

                    if EDIValues.FindFirst() then
                        TempRecord := EDIValues."EDI Identifier";

                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODFORN';
                    TempRecord := '14';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
            EDIGroup."EDI-SUPP Out"::Fixed:
                begin
                    TempField := 'CODFORN';
                    TempRecord := EDIGroup."ID-EDI-SUPP1";
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODFORN';
                    TempRecord := EDIGroup."ID-EDI-SUPP2";
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
        end;

        if EDIValues.FindFirst() then
            if not EDIGr.Get(EDIValues."EDI Group Code") then
                Clear(EDIGr);

        TempField := 'RAGSOCF';
        TempRecord := CompanyInfo.Name;
        EDIInsRow(TempField, TempRecord, true, true, 70, false);

        TempField := 'INDIRF';
        TempRecord := CompanyInfo.Address;
        EDIInsRow(TempField, TempRecord, true, true, 70, false);

        TempField := 'CITTAF';
        TempRecord := CompanyInfo.City;
        EDIInsRow(TempField, TempRecord, true, true, 35, false);

        TempField := 'PROVF';
        TempRecord := CompanyInfo.County;
        EDIInsRow(TempField, TempRecord, true, true, 9, false);

        TempField := 'CAPF';
        TempRecord := CompanyInfo."Post Code";
        EDIInsRow(TempField, TempRecord, true, true, 9, false);

        TempField := 'NAZIOF';
        TempRecord := CompanyInfo."Country/Region Code";
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'PIVANAZF';
        TempRecord := StripCountryCode(CompanyInfo."VAT Registration No.");
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'TRIBUNALE';
        TempRecord := EDIGr."ID-EDI-Court"; // Ex Testo 2
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'LICIMPEXP';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        EDIInsertDecriptionRowForInsNAS(CompanyInfo);

        TempField := 'CAPSOC';
        TempRecord := EDIGr."ID-EDI-CAPSOC"; // EX Testo 3
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        EDIInsertDecriptionRowForInsNAS(CompanyInfo);

        TempField := 'PIVAINT';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'TELEFONO';
        TempRecord := CompanyInfo."Phone No.";
        EDIInsRow(TempField, TempRecord, false, true, 25, false);

        TempField := 'TELEFAX';
        TempRecord := CompanyInfo."Fax No.";
        EDIInsRow(TempField, TempRecord, false, true, 25, false);

        TempField := 'TELEX';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 25, false);

        TempField := 'EMAIL';
        TempRecord := CompanyInfo."E-Mail";
        EDIInsRow(TempField, TempRecord, false, true, 70, false);

        OnBeforeInsertEDILineForInsNAS(CompanyInfo, EDIGr);

        InsertEdiLine(true, 609);
    end;

    procedure Ins_NAI(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        EDIValues: Record "EOS074 EDI Values";
    begin
        // case EdiDocTypeP of
        //     EDIDocType::"Sales Invoice":
        //         begin
        //         end;
        //     EDIDocType::"Sales Cr.Memo":
        //         begin
        //         end;
        // end;

        InitEDILine();
        EDILine."Record Type" := 'NAI';

        TempField := 'TIPOREC';
        TempRecord := 'NAI';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        EDIValues.Reset();
        EDIValues.FilterByRecord(CustInvoice);

        case EDIGroup."EDI-CODFATT Out" of
            EDIGroup."EDI-CODFATT Out"::VAT:
                begin
                    TempField := 'CODFATT';
                    TempRecord := VatNo;
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODFATT';
                    TempRecord := 'VA';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
            EDIGroup."EDI-CODFATT Out"::"14":
                begin
                    TempField := 'CODFATT';

                    if EDIValues.FindFirst() then
                        TempRecord := EDIValues."EDI Identifier";

                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODFATT';
                    TempRecord := '14';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
            EDIGroup."EDI-CODFATT Out"::"91":
                begin
                    TempField := 'CODFATT';
                    if EDIValues.FindFirst() then
                        TempRecord := EDIValues."EDI Identifier";
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODFATT';
                    TempRecord := '91';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
            EDIGroup."EDI-CODFATT Out"::"92":
                begin
                    TempField := 'CODFATT';
                    if EDIValues.FindFirst() then
                        TempRecord := EDIValues."EDI Identifier";
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODFATT';
                    TempRecord := '92';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
        end;

        TempField := 'RAGSOCI';
        TempRecord := CustInvoice.Name;
        EDIInsRow(TempField, TempRecord, true, true, 70, false);

        TempField := 'INDIRI';
        TempRecord := CustInvoice.Address;
        EDIInsRow(TempField, TempRecord, true, true, 70, false);

        TempField := 'CITTAI';
        TempRecord := CustInvoice.City;
        EDIInsRow(TempField, TempRecord, true, true, 35, false);

        TempField := 'PROVI';
        TempRecord := CustInvoice.County;

        if CustInvoice."Country/Region Code" = 'IT' then
            EDIInsRow(TempField, TempRecord, true, true, 9, false)
        else
            EDIInsRow(TempField, TempRecord, false, true, 9, false);

        TempField := 'CAPI';
        TempRecord := CustInvoice."Post Code";
        EDIInsRow(TempField, TempRecord, true, true, 9, false);

        TempField := 'NAZIOI';
        TempRecord := CustInvoice."Country/Region Code";
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'PIVANAZI';
        TempRecord := VatNo;
        EDIInsRow(TempField, TempRecord, true, true, 35, false);

        TempField := 'FILLER';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 51, false);

        InsertEdiLine(true, 305);
    end;

    // procedure Ins_NAP(EdiDocTypeP: Option " ",,"Sales Order","Sales Shipment",,"Sales Invoice","Sales Cr.Memo",Zentralregulierungsbeleg)
    // begin
    //     exit; // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":
    //             begin
    //                 SalesInvHeader.TestField("Bill-to Customer No.", SalesInvHeader."Sell-to Customer No.");
    //             end;
    //         EdiDocTypeP::"Sales Cr.Memo":
    //             begin
    //                 SalesCrMemoHeader.TestField("Bill-to Customer No.", SalesCrMemoHeader."Sell-to Customer No.");
    //             end;
    //     end;

    //     InitEDILine();
    //     EDILine."Record Type" := 'NAP';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAP';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     InsertEdiLine(true, 305);
    // end;

    // procedure Ins_NAA(EdiDocTypeP: Option " ",,"Sales Order","Sales Shipment",,"Sales Invoice","Sales Cr.Memo",Zentralregulierungsbeleg)
    // begin
    //     exit; // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":
    //             begin
    //             end;
    //         EdiDocTypeP::"Sales Cr.Memo":
    //             begin
    //             end;
    //     end;

    //     InitEDILine;
    //     EDILine."Record Type" := 'NAA';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAA';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     TempField := 'CODFATA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 175, false);

    //     TempField := 'QCODFATA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 175, false);

    //     TempField := 'RAGSOCA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 70, false);

    //     TempField := 'INDIRA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 70, false);

    //     TempField := 'CITTAA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 35, false);

    //     TempField := 'PROVA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 9, false);

    //     TempField := 'CAPA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 9, false);

    //     TempField := 'NAZIOA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     TempField := 'PIVANAZA';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 35, false);

    //     TempField := 'FILLER';
    //     TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, false, true, 51, false);

    //     InsertEdiLine(true, 305);
    // end;

    // procedure Ins_NAT(EdiDocTypeP: Option " ",,"Sales Order","Sales Shipment",,"Sales Invoice","Sales Cr.Memo",Zentralregulierungsbeleg)
    // begin
    //     exit;  // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":
    //             begin
    //             end;
    //         EdiDocTypeP::"Sales Cr.Memo":
    //             begin
    //             end;
    //     end;

    //     InitEDILine;
    //     EDILine."Record Type" := 'NAT';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAT';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     InsertEdiLine(true, 305);
    // end;

    procedure Ins_FTX_Standard(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        CommentText: Text[350];
        StartPos: Integer;
    begin
        //Header comments from Sales Comment Line

        // case EdiDocTypeP of
        //     EdiDocTypeP::"Sales Invoice":
        //         begin
        //         end;
        //     EdiDocTypeP::"Sales Cr.Memo":
        //         begin
        //         end;
        // end;

        InitEDILine();
        EDILine."Record Type" := 'FTX';

        TempField := 'TIPOREC';
        TempRecord := 'FTX';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'DIVISA';
        TempRecord := 'EUR';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'NOTE';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 150, false);

        InsertEdiLine(true, 356);

        CommentText := CopyStr(CreateHeaderCommentStd(), 1, MaxStrLen(CommentText));
        if (CommentText = '') then
            exit;

        InitEDILine();
        EDILine."Record Type" := 'FTX';

        TempField := 'TIPOREC';
        TempRecord := 'FTX';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'DIVISA';
        TempRecord := 'EUR';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'NOTE';
        StartPos := 1;
        repeat
            TempRecord := CopyStr(CommentText, StartPos, 50);
            EDIInsRow(TempField, TempRecord, false, true, 50, false);
            StartPos := StartPos + 50;
        until (StartPos > 350);

        InsertEdiLine(true, 356);
    end;

    procedure Ins_PAT(EdiDocTypeP: enum "EOS074 EDI Document Type"; PaymTermsP: Code[10]; var CustLedgerEntryP: Record "Cust. Ledger Entry")
    var
        PaymTermsLoc: Record "Payment Terms";
        PaymMethodLoc: Record "Payment Method";
        CustBankAccLoc: Record "Customer Bank Account";
    begin
        case EdiDocTypeP of
            EDIDocType::"Sales Invoice":
                begin
                    PaymTermsLoc.Get(PaymTermsP);

                    if SalesInvHeader."Payment Method Code" <> '' then
                        PaymMethodLoc.Get(SalesInvHeader."Payment Method Code")
                    else
                        PaymMethodLoc.Init();

                    EDICrossTable.Reset();
                    EDICrossTable.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                    EDICrossTable.SetRange(Type, EDICrossTable.Type::Payments);
                    EDICrossTable.SetRange("NAV-Code", PaymTermsP);
                    EDICrossTable.SetRange("NAV-Code 2", SalesInvHeader."Payment Method Code");
                    EDICrossTable.FindLast();
                    EDICrossTable.TestField("External Code");
                end;

            EDIDocType::"Sales Cr.Memo":
                begin
                    PaymTermsLoc.Get(PaymTermsP);

                    if SalesCrMemoHeader."Payment Method Code" <> '' then
                        PaymMethodLoc.Get(SalesCrMemoHeader."Payment Method Code")
                    else
                        PaymMethodLoc.Init();

                    EDICrossTable.Reset();
                    EDICrossTable.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                    EDICrossTable.SetRange(Type, EDICrossTable.Type::Payments);
                    EDICrossTable.SetRange("NAV-Code", PaymTermsP);
                    //ORG:EDICrossTable.SETRANGE("NAV-Code 2",SalesInvHeader."Payment Method Code");
                    EDICrossTable.SetRange("NAV-Code 2", SalesCrMemoHeader."Payment Method Code");
                    EDICrossTable.FindLast();
                    EDICrossTable.TestField("External Code");
                end;
        end;

        OnBeforeInitEDILineForInsPAT(SalesInvHeader, SalesCrMemoHeader, EDIDocType);

        InitEDILine();
        EDILine."Record Type" := 'PAT';

        TempField := 'TIPOREC';
        TempRecord := 'PAT';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        EDIInsertDecriptionRowForInsPAT(EDIDocType);

        TempField := 'DATASCAD';
        TempRecord := DateFormat(CustLedgerEntryP."Due Date");
        EDIInsRow(TempField, TempRecord, true, true, 8, false);

        TempField := 'RIFTERMP';
        TempRecord := '5';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'RELTERMP';
        TempRecord := '1';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'UNTEMP';
        TempRecord := 'D';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'NUNTEMP';
        TempRecord := FormatNumDecBiFront((CustLedgerEntryP."Due Date" - CustLedgerEntryP."Posting Date")
          + 1
          , 3, 0);
        EDIInsRow(TempField, TempRecord, true, true, 3, true);

        TempField := 'IMPORTO';
        CustLedgerEntryP.CalcFields("Original Amount");
        TempRecord := FormatNumDecBiFront(CustLedgerEntryP."Original Amount", 15, 3);
        EDIInsRow(TempField, SignText(CustLedgerEntryP."Original Amount", CopyStr(TempRecord, 1, MaxStrLen(TempField))), true, true, 16, true);

        TempField := 'DIVISA';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'PERC';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, false, true, 7, false);

        TempField := 'DESCRIZ';
        TempRecord := PaymMethodLoc.Description;
        if PaymTermsLoc.Description <> '' then
            if PaymMethodLoc.Description <> '' then
                TempRecord := CopyStr(TempRecord + ' ' + PaymTermsLoc.Description, 1, MaxStrLen(TempRecord))
            else
                TempRecord := PaymTermsLoc.Description;
        EDIInsRow(TempField, TempRecord, true, true, 35, false);

        TempField := 'BANCACOD';
        //TempRecord := CustBankAccLoc.ABI + '-' + CustBankAccLoc.CAB + '-' + CustBankAccLoc."Bank Account No.";
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'BANCADESC';
        TempRecord := CustBankAccLoc.Name;
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'FACTOR';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'CODPAG';
        if EDICrossTable."Direct Payment" then
            TempRecord := '1'
        else
            TempRecord := '35';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'MEZZOPAG';
        TempRecord := EDICrossTable."External Code";
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        OnBeforeInsertEDILineForInsPAT(CustLedgerEntryP, PaymMethodLoc);

        InsertEdiLine(true, 198);
    end;

    procedure Ins_DET(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        lRecItem: Record Item;
        SalesInvLineLoc: Record "Sales Invoice Line";
        SalesCrMemoLineLoc: Record "Sales Cr.Memo Line";
        EanCodeLoc: Code[20];
        TipoDocCuLoc: Text[30];
        UmLoc: Text[30];
        CodDistuLoc: Text[35];
        InsDiscLoc: Boolean;
        EanCodeTU: Code[20];
        lIntItemNo: Integer;
        ConsTransType: Enum "EOS074 Consumer/Transport Type";
    begin
        case EdiDocTypeP of
            EdiDocTypeP::"Sales Invoice":
                begin
                    TempVATAmountLine.DeleteAll();

                    EanCodeLoc := '';
                    TipoDocCuLoc := '';
                    CodDistuLoc := '';

                    TempVATAmountLine.Init();
                    TempVATAmountLine."VAT Identifier" := SalesInvLine."VAT Identifier";
                    TempVATAmountLine."VAT Calculation Type" := SalesInvLine."VAT Calculation Type";
                    TempVATAmountLine."Tax Group Code" := SalesInvLine."Tax Group Code";
                    TempVATAmountLine."VAT %" := SalesInvLine."VAT %";
                    TempVATAmountLine."VAT Base" := SalesInvLine.Amount;
                    TempVATAmountLine."Amount Including VAT" := SalesInvLine."Amount Including VAT";
                    TempVATAmountLine."Line Amount" := SalesInvLine."Line Amount";
                    if SalesInvLine."Allow Invoice Disc." then
                        TempVATAmountLine."Inv. Disc. Base Amount" := SalesInvLine."Line Amount";
                    TempVATAmountLine."Invoice Discount Amount" := SalesInvLine."Inv. Discount Amount";
                    TempVATAmountLine.InsertLine();

                    InsDiscLoc := (SalesInvLine."Line Discount Amount" <> 0);

                    if SalesInvLine.Type = SalesInvLine.Type::Item then begin
                        TipoDocCuLoc := 'EN';
                        EDICrossTable.Reset();
                        EDICrossTable.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                        EDICrossTable.SetRange(Type, EDICrossTable.Type::"Unit Of Measure");
                        EDICrossTable.SetRange("NAV-Code", SalesInvLine."Unit of Measure Code");
                        EDICrossTable.Find('+');
                        EDICrossTable.TestField("External Code");
                        UmLoc := EDICrossTable."External Code";

                        EanCodeLoc := EDIMgt.GetEAN(SalesInvLine."No.", SalesInvLine."Variant Code", ConsTransType::Consumer);
                        EanCodeTU := EDIMgt.GetEAN(SalesInvLine."No.", SalesInvLine."Variant Code", ConsTransType::Transport);
                    end else begin
                        EanCodeLoc := '';
                        TipoDocCuLoc := '';
                        UmLoc := 'PCE';
                        EanCodeTU := '';
                    end;
                    InitEDILine();
                    EDILine."Record Type" := 'DET';

                    TempField := 'TIPOREC';
                    TempRecord := 'DET';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);

                    TempField := 'NUMRIGA';
                    TempRecord := FormatNumDecBiFront(DETLineNo, 6, 0);
                    EDIInsRow(TempField, TempRecord, true, true, 6, true);

                    TempField := 'IDSOTTOR';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'NUMSRIGA';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 6, false);

                    TempField := 'CODEANCU';
                    TempRecord := EanCodeLoc;
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'TIPCODCU';
                    if EanCodeLoc = '' then
                        TempRecord := ' '
                    else
                        TempRecord := TipoDocCuLoc;
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'CODEANTU';
                    TempRecord := EanCodeTU;
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'CODFORTU';
                    TempRecord := SalesInvLine."No.";
                    if Evaluate(lIntItemNo, TempRecord) then
                        TempRecord := Format(lIntItemNo);
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'CODDISTU';
                    TempRecord := EDIMgt.GetCustCrossReference(SalesInvLine."No.", SalesInvLine."Variant Code", SalesInvLine."Unit of Measure Code", SalesInvLine."Sell-to Customer No.");
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'TIPQUANT';
                    TempRecord := 'L01';

                    if SalesInvLine."Line Amount" = 0 then
                        TempRecord := 'L09'; // sconto merce

                    //Free Gift Management ToDo
                    //IF SalesInvLine."free gift" THEN
                    //  TempRecord := 'L03';

                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    case true of
                        (SalesInvLine.Type = SalesInvLine.Type::Item) and
                        (EDIGroup."DET Quantity Out" = EDIGroup."DET Quantity Out"::Parcels):
                            begin
                                TempField := 'QTACONS';
                                TempRecord := FormatNumDecBiFront(SalesInvLine.Quantity, 15, 3);
                                EDIInsRow(TempField, SignText(SalesInvLine.Quantity, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);

                                TempField := 'UDMQCONS';
                                TempRecord := 'CT';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                                TempField := 'QTAFATT';
                                TempRecord := FormatNumDecBiFront(SalesInvLine.Quantity, 15, 3);
                                EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);

                                TempField := 'UDMQFATT';
                                if SalesCrMemoLine.Type = SalesInvLine.Type::Item then
                                    TempRecord := UmLoc
                                else
                                    TempRecord := '';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);
                            end;

                        else begin
                                TempField := 'QTACONS';
                                TempRecord := FormatNumDecBiFront(SalesInvLine.Quantity, 15, 3);
                                EDIInsRow(TempField, SignText(SalesInvLine.Quantity, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);

                                TempField := 'UDMQCONS';
                                if SalesInvLine.Type = SalesInvLine.Type::Item then
                                    TempRecord := UmLoc
                                else
                                    TempRecord := '';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                                TempField := 'QTAFATT';
                                TempRecord := FormatNumDecBiFront(SalesInvLine."Quantity (Base)", 15, 3);
                                EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);
                                // Unit of Measure of Trade Unit
                                TempField := 'UDMQFATT';
                                if SalesInvLine.Type = SalesInvLine.Type::Item then
                                    TempRecord := 'PCE'
                                else
                                    TempRecord := '';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);
                            end;

                    end;

                    // Consumer Units per Trade Unit
                    TempField := 'NRCUINTU';
                    TempDecimal := SalesInvLine."Qty. per Unit of Measure";
                    TempDecimal := TempDecimal * SalesInvLine.Quantity;
                    TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                    EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                    TempField := 'UDMNRCUINTU';
                    TempRecord := 'CU';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'PRZUNI';
                    TempDecimal :=
                      Round(SalesInvLine."Unit Price" / SalesInvLine."Qty. per Unit of Measure"
                      , GLSetup."Unit-Amount Rounding Precision");
                    TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                    EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                    if not InsDiscLoc then begin  // (Netto)
                        TempField := 'TIPOPRZ';
                        TempRecord := 'AAA';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);
                    end else begin                // (Lordo)
                        TempField := 'TIPOPRZ';
                        TempRecord := 'AAB';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);
                    end;

                    TempField := 'UDMPRZUN';
                    TempRecord := 'PCE';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    if not InsDiscLoc then begin
                        // TIPOPRZ 'AAA' (Netto)
                        TempField := 'PRZUN2';
                        TempRecord := '';
                        EDIInsRow(TempField, TempRecord, false, true, 16, false);

                        TempField := 'TIPOPRZ2';
                        TempRecord := '';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);

                        TempField := 'UDMPRZUN2';
                        TempRecord := '';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);
                    end else begin
                        // TIPOPRZ 'AAB' (Lordo)
                        TempField := 'PRZUN2';
                        TempDecimal :=
                          Round(SalesInvLine."Line Amount" / SalesInvLine."Quantity (Base)"
                          , GLSetup."Unit-Amount Rounding Precision");
                        TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                        EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                        TempField := 'TIPOPRZ2';
                        TempRecord := 'AAA';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);

                        TempField := 'UDMPRZUN2';
                        TempRecord := 'PCE';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);
                    end;

                    TempField := 'IMPORTO';
                    case EDIGroup."Line Amount Out" of
                        EDIGroup."Line Amount Out"::Gross:
                            TempDecimal := SalesInvLine."Line Amount" + SalesInvLine."Line Discount Amount";
                        EDIGroup."Line Amount Out"::Net:
                            TempDecimal := SalesInvLine."Line Amount";
                    end;

                    /*
                    IF (SalesInvLine."Line Amount" = 0) THEN BEGIN  // sconto merce
                      PostedLineDiscSeq.SETRANGE("Document Type", PostedLineDiscSeq."Document Type"::Invoice);
                      PostedLineDiscSeq.SETRANGE("Document No.", SalesInvLine."Document No.");
                      PostedLineDiscSeq.SETRANGE("Document Line No.", SalesInvLine."Line No.");
                      PostedLineDiscSeq.SETRANGE("Discount %", 100.0);
                      FullDiscount := NOT PostedLineDiscSeq.ISEMPTY;

                      IF FullDiscount THEN BEGIN
                        TempDecimal := 0;
                        PostedLineDiscSeq.SETRANGE("Discount %");
                        IF PostedLineDiscSeq.FINDSET(FALSE, FALSE) THEN
                          REPEAT
                            TempDecimal += PostedLineDiscSeq."Discount Amount";
                          UNTIL (PostedLineDiscSeq.NEXT = 0);
                      END;
                    END;
                    */

                    TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                    EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                    TempField := 'DIVRIGA';
                    TempRecord := 'EUR';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'IMPORTO2';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 16, false);

                    TempField := 'DIVRIGA2';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    InsertEdiLine(true, 303);

                    DETLineNo += 1;
                end;

            EdiDocTypeP::"Sales Cr.Memo":
                begin
                    TempVATAmountLine.DeleteAll();

                    EanCodeLoc := '';
                    TipoDocCuLoc := '';
                    CodDistuLoc := '';

                    TempVATAmountLine.Init();
                    TempVATAmountLine."VAT Identifier" := SalesCrMemoLine."VAT Identifier";
                    TempVATAmountLine."VAT Calculation Type" := SalesCrMemoLine."VAT Calculation Type";
                    TempVATAmountLine."Tax Group Code" := SalesCrMemoLine."Tax Group Code";
                    TempVATAmountLine."VAT %" := SalesCrMemoLine."VAT %";
                    TempVATAmountLine."VAT Base" := SalesCrMemoLine.Amount;
                    TempVATAmountLine."Amount Including VAT" := SalesCrMemoLine."Amount Including VAT";
                    TempVATAmountLine."Line Amount" := SalesCrMemoLine."Line Amount";
                    if SalesCrMemoLine."Allow Invoice Disc." then
                        TempVATAmountLine."Inv. Disc. Base Amount" := SalesCrMemoLine."Line Amount";
                    TempVATAmountLine."Invoice Discount Amount" := SalesCrMemoLine."Inv. Discount Amount";
                    TempVATAmountLine.InsertLine();

                    InsDiscLoc := (SalesCrMemoLine."Line Discount Amount" <> 0);

                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then begin
                        TipoDocCuLoc := 'EN';
                        EDICrossTable.Reset();
                        EDICrossTable.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                        EDICrossTable.SetRange(Type, EDICrossTable.Type::"Unit Of Measure");
                        EDICrossTable.SetRange("NAV-Code", SalesCrMemoLine."Unit of Measure Code");
                        EDICrossTable.Find('+');
                        EDICrossTable.TestField("External Code");
                        UmLoc := EDICrossTable."External Code";

                        EanCodeLoc := EDIMgt.GetEAN(SalesCrMemoLine."No.", SalesCrMemoLine."Variant Code", ConsTransType::Consumer);
                        EanCodeTU := EDIMgt.GetEAN(SalesCrMemoLine."No.", SalesCrMemoLine."Variant Code", ConsTransType::Transport);
                    end else begin
                        EanCodeLoc := '';
                        TipoDocCuLoc := '';
                        UmLoc := 'PCE';
                        EanCodeTU := '';
                    end;

                    InitEDILine();
                    EDILine."Record Type" := 'DET';

                    TempField := 'TIPOREC';
                    TempRecord := 'DET';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);

                    TempField := 'NUMRIGA';
                    TempRecord := FormatNumDecBiFront(DETLineNo, 6, 0);
                    EDIInsRow(TempField, TempRecord, true, true, 6, true);

                    TempField := 'IDSOTTOR';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'NUMSRIGA';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 6, false);

                    TempField := 'CODEANCU';
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                        TempRecord := EanCodeLoc
                    else
                        TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'TIPCODCU';
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                        TempRecord := TipoDocCuLoc
                    else
                        TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'CODEANTU';
                    TempRecord := EanCodeTU;
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'CODFORTU';
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                        TempRecord := SalesCrMemoLine."No."
                    else
                        TempRecord := '';
                    if Evaluate(lIntItemNo, TempRecord) then
                        TempRecord := Format(lIntItemNo);
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'CODDISTU';
                    TempRecord := EDIMgt.GetCustCrossReference(SalesCrMemoLine."No.", SalesCrMemoLine."Variant Code", SalesCrMemoLine."Unit of Measure Code", SalesCrMemoLine."Sell-to Customer No.");

                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'TIPQUANT';

                    EDICrossTable.Reset();
                    EDICrossTable.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                    EDICrossTable.SetRange(Type, EDICrossTable.Type::"Return Reasons");
                    EDICrossTable.SetRange("NAV-Code", SalesCrMemoHeader."Reason Code");
                    if not (EDICrossTable.Find('+')) or (SalesCrMemoHeader."Reason Code" = '') then
                        TempRecord := 'L02'
                    else begin
                        EDICrossTable.TestField("External Code");
                        TempRecord := EDICrossTable."External Code";
                    end;
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    case true of
                        (SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item) and
                        (EDIGroup."DET Quantity Out" = EDIGroup."DET Quantity Out"::Parcels):
                            begin
                                TempField := 'QTACONS';
                                TempRecord := FormatNumDecBiFront(SalesCrMemoLine.Quantity, 15, 3);
                                EDIInsRow(TempField, SignText(SalesCrMemoLine.Quantity, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);

                                TempField := 'UDMQCONS';
                                TempRecord := 'CT';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                                TempField := 'QTAFATT';
                                TempRecord := FormatNumDecBiFront(SalesCrMemoLine.Quantity, 15, 3);
                                EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);

                                TempField := 'UDMQFATT';
                                TempRecord := 'CT';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);
                            end;

                        else begin
                                TempField := 'QTACONS';
                                TempRecord := FormatNumDecBiFront(SalesCrMemoLine.Quantity, 15, 3);
                                EDIInsRow(TempField, SignText(SalesCrMemoLine.Quantity, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);

                                TempField := 'UDMQCONS';
                                if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                                    TempRecord := UmLoc
                                else
                                    TempRecord := '';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                                TempField := 'QTAFATT';
                                TempRecord := FormatNumDecBiFront(SalesCrMemoLine."Quantity (Base)", 15, 3);
                                EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, true);

                                // Unit of Measure of Trade Unit
                                TempField := 'UDMQFATT';
                                if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                                    TempRecord := 'PCE'
                                else
                                    TempRecord := '';
                                EDIInsRow(TempField, TempRecord, false, true, 3, false);
                            end;

                    end;

                    // Consumer Units per Trade Unit
                    TempField := 'NRCUINTU';
                    TempDecimal := SalesCrMemoLine."Qty. per Unit of Measure";
                    TempDecimal := TempDecimal * SalesCrMemoLine.Quantity;
                    TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                    EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                    TempField := 'UDMNRCUINTU';
                    TempRecord := 'CU';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'PRZUNI';
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                        TempDecimal := Round(SalesCrMemoLine."Unit Price" / SalesCrMemoLine."Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision")
                    else
                        TempDecimal := SalesCrMemoLine."Unit Price";

                    TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                    EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then begin
                        if not InsDiscLoc then begin
                            TempField := 'TIPOPRZ';
                            TempRecord := 'AAA';
                            EDIInsRow(TempField, TempRecord, false, true, 3, false);
                        end else begin
                            TempField := 'TIPOPRZ';
                            TempRecord := 'AAB';
                            EDIInsRow(TempField, TempRecord, false, true, 3, false);
                        end;
                    end else begin
                        TempField := 'TIPOPRZ';
                        TempRecord := 'AAA';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);
                    end;

                    TempField := 'UDMPRZUN';
                    TempRecord := 'PCE';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then begin
                        if not InsDiscLoc then begin
                            // TIPOPRZ 'AAA' (Netto)
                            TempField := 'PRZUN2';
                            TempRecord := '';
                            EDIInsRow(TempField, TempRecord, false, true, 16, false);

                            TempField := 'TIPOPRZ2';
                            TempRecord := '';
                            EDIInsRow(TempField, TempRecord, false, true, 3, false);

                            TempField := 'UDMPRZUN2';
                            TempRecord := '';
                            EDIInsRow(TempField, TempRecord, false, true, 3, false);
                        end else begin // DiscLoc
                                       // TIPOPRZ 'AAB' (Lordo)
                            TempField := 'PRZUN2';
                            TempDecimal :=
                              Round(SalesCrMemoLine."Line Amount" / SalesCrMemoLine."Quantity (Base)"
                              , GLSetup."Unit-Amount Rounding Precision");
                            if not lRecItem.Get(SalesCrMemoLine."No.") then
                                lRecItem.Init();
                            TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                            EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                            TempField := 'TIPOPRZ2';
                            TempRecord := 'AAA';
                            EDIInsRow(TempField, TempRecord, false, true, 3, false);

                            TempField := 'UDMPRZUN2';
                            TempRecord := 'PCE';
                            EDIInsRow(TempField, TempRecord, false, true, 3, false);
                        end;  // DiscLoc

                    end else begin
                        TempField := 'PRZUN2';
                        TempDecimal := SalesCrMemoLine."Unit Price";
                        TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                        ;
                        EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                        TempField := 'TIPOPRZ2';
                        TempRecord := 'AAA';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);

                        TempField := 'UDMPRZUN2';
                        TempRecord := 'PCE';
                        EDIInsRow(TempField, TempRecord, false, true, 3, false);
                    end;

                    TempField := 'IMPORTO';
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then
                        case EDIGroup."Line Amount Out" of
                            EDIGroup."Line Amount Out"::Gross:
                                TempDecimal := SalesCrMemoLine."Line Amount" + SalesCrMemoLine."Line Discount Amount";
                            EDIGroup."Line Amount Out"::Net:
                                TempDecimal := SalesCrMemoLine."Line Amount";
                        end
                    else
                        TempDecimal := SalesCrMemoLine."Line Amount";

                    TempRecord := FormatNumDecBiFront(TempDecimal, 15, 3);
                    EDIInsRow(TempField, SignText(TempDecimal, CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                    TempField := 'DIVRIGA';
                    TempRecord := 'EUR';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    TempField := 'IMPORTO2';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 16, false);

                    TempField := 'DIVRIGA2';
                    TempRecord := '';
                    EDIInsRow(TempField, TempRecord, false, true, 3, false);

                    /*
                    IF SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item THEN BEGIN
                      IF NOT InsDiscLoc THEN BEGIN
                        TempField := 'IMPORTO2';
                        TempRecord := '';
                        EDIInsRow(TempField,TempRecord,FALSE,TRUE,16,FALSE);

                        TempField := 'DIVRIGA2';
                        TempRecord := '';
                        EDIInsRow(TempField,TempRecord,FALSE,TRUE,3,FALSE);
                      END ELSE BEGIN
                        TempField := 'IMPORTO2';
                        TempDecimal := SalesCrMemoLine."Line Amount";
                        TempRecord := FormatNumDecBiFront(TempDecimal,15,3);
                        EDIInsRow(TempField,SignText(TempDecimal,TempRecord),FALSE,TRUE,16,FALSE);

                        TempField := 'DIVRIGA2';
                        TempRecord := 'EUR';
                        EDIInsRow(TempField,TempRecord,FALSE,TRUE,3,FALSE);
                      END;
                    END ELSE BEGIN
                      TempField := 'IMPORTO2';
                      TempDecimal := SalesCrMemoLine."Line Amount";
                      TempRecord := FormatNumDecBiFront(TempDecimal,15,3);
                      EDIInsRow(TempField,SignText(TempDecimal,TempRecord),FALSE,TRUE,16,FALSE);

                      TempField := 'DIVRIGA2';
                      TempRecord := 'EUR';
                      EDIInsRow(TempField,TempRecord,FALSE,TRUE,3,FALSE);
                    END;
                    */

                    InsertEdiLine(true, 303);

                    DETLineNo += 1;

                end; // DocType::"Cr. Memo"
        end;

        Ins_DES(EdiDocTypeP);

        case EdiDocTypeP of
            EdiDocTypeP::"Sales Invoice":

                if SalesInvLineLoc."Attached to Line No." <> 0 then begin
                    SalesInvLineLoc.Reset();
                    SalesInvLineLoc.SetRange("Document No.", SalesInvLine."Document No.");
                    SalesInvLineLoc.SetRange("Sell-to Customer No.", SalesInvLineLoc."Sell-to Customer No.");
                    SalesInvLineLoc.SetRange("Attached to Line No.", SalesInvLine."Attached to Line No.");
                    if SalesInvLineLoc.Find('-') then
                        repeat
                            Ins_DES(EdiDocTypeP);
                        until SalesInvLineLoc.Next() = 0;
                end;

            EdiDocTypeP::"Sales Cr.Memo":

                if SalesCrMemoLineLoc."Attached to Line No." <> 0 then begin
                    SalesCrMemoLineLoc.Reset();
                    SalesCrMemoLineLoc.SetRange("Document No.", SalesCrMemoLineLoc."Document No.");
                    SalesCrMemoLineLoc.SetRange("Sell-to Customer No.", SalesCrMemoLineLoc."Sell-to Customer No.");
                    SalesCrMemoLineLoc.SetRange("Attached to Line No.", SalesCrMemoLineLoc."Attached to Line No.");
                    if SalesCrMemoLineLoc.Find('-') then
                        repeat
                            Ins_DES(EdiDocTypeP);
                        until SalesCrMemoLineLoc.Next() = 0;
                end;

        end;

        Ins_RFN(EdiDocTypeP);
        Ins_TAX(EdiDocTypeP);

        DiscountSeqNo := 0;
        Ins_ALD(EdiDocTypeP);

        Ins_NAD(EdiDocTypeP);
        //Ins_NAE(EdiDocTypeP);
        //Ins_NAR(EdiDocTypeP);
        //Ins_NAM(EdiDocTypeP);
        //Ins_NAF(EdiDocTypeP);
        //Ins_NAX(EdiDocTypeP);

    end;

    procedure Ins_DES(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        DescLoc: Text[250];
    begin
        case EdiDocTypeP of
            EDIDocType::"Sales Invoice":

                DescLoc := SalesInvLine.Description + ' ' + SalesInvLine."Description 2";

            EDIDocType::"Sales Cr.Memo":

                DescLoc := SalesCrMemoLine.Description + ' ' + SalesCrMemoLine."Description 2";

        end;

        InitEDILine();
        EDILine."Record Type" := 'DES';

        TempField := 'TIPOREC';
        TempRecord := 'DES';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'DESCR';
        TempRecord := DescLoc;
        EDIInsRow(TempField, TempRecord, true, true, 175, false);

        InsertEdiLine(true, 178);
    end;

    procedure Ins_RFN(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        lRecSalesInvoiceHeader: Record "Sales Invoice Header";
        IsReturnShpt: Boolean;
        InvoiceNo: Code[20];
    begin
        if ((DETLineNo - 1) <> 1) then
            exit;

        case EdiDocTypeP of
            EDIDocType::"Sales Invoice":
                exit;
        // EDIDocType::"Sales Cr.Memo":
        //     begin
        //     end;
        end;

        IsReturnShpt := false;

        InitEDILine();
        EDILine."Record Type" := 'RFN';

        TempField := 'TIPOREC';
        TempRecord := 'RFN';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'TIPORIF';
        if IsReturnShpt then
            TempRecord := 'ALQ'
        else
            TempRecord := 'IV';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'RIFACCADD';
        if SalesCrMemoHeader."Applies-to Doc. No." <> '' then
            TempRecord := SalesCrMemoHeader."Applies-to Doc. No.";
        InvoiceNo := CopyStr(TempRecord, 1, MaxStrLen(InvoiceNo));
        EDIInsRow(TempField, TempRecord, true, true, 35, false);

        TempField := 'DATARIF';
        if lRecSalesInvoiceHeader.Get(TempRecord) then
            TempRecord := DateFormat(lRecSalesInvoiceHeader."Posting Date")
        else
            TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 8, false);

        InsertEdiLine(true, 49);
    end;

    procedure Ins_NAD(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        EDIValues1: Record "EOS074 EDI Values";
        EDIValues2: Record "EOS074 EDI Values";
        IlnCodeLoc: Text[30];
        HasAddressLoc: Boolean;
        DocNoLoc: Code[20];
        DateLoc: Date;
        YourRefLoc: Text[35];
        YourDateLoc: Date;
    begin
        if ((DETLineNo - 1) <> 1) then
            exit;

        HasAddressLoc := false;

        EDIValues2.FilterByRecord(Cust);

        case EdiDocTypeP of
            EdiDocTypeP::"Sales Invoice":
                begin
                    HasAddressLoc := false;
                    if GetShipmentNo() then begin
                        if SalesShiptHeader."Ship-to Code" <> '' then begin
                            Shipto.Get(SalesShiptHeader."Sell-to Customer No.", SalesShiptHeader."Ship-to Code");
                            EDIValues1.FilterByRecord(Shipto);
                            if EDIValues1.FindSet() then
                                if EDIValues1."EDI Identifier" = '' then begin
                                    if EDIValues2.FindSet() then begin
                                        EDIValues2.TestField("EDI Identifier");
                                        IlnCodeLoc := EDIValues2."EDI Identifier";
                                    end;
                                end else begin
                                    EDIValues1.TestField("EDI Identifier");
                                    IlnCodeLoc := EDIValues1."EDI Identifier";
                                end;
                            HasAddressLoc := true;
                        end else
                            if EDIValues2.FindSet() then begin
                                EDIValues2.TestField("EDI Identifier");
                                IlnCodeLoc := EDIValues2."EDI Identifier";
                            end;

                        case EDIGroup."Document Nos." of
                            EDIGroup."Document Nos."::Alphanumeric:

                                DocNoLoc := SalesShiptHeader."No.";

                            EDIGroup."Document Nos."::Numeric:
                                begin
                                    Evaluate(TmpDocNo, TakeNr(SalesShiptHeader."No."));
                                    DocNoLoc := Format(TmpDocNo);
                                end;
                        end;
                        DateLoc := SalesShiptHeader."Posting Date";
                        //ORG:        IF SalesShiptHeader."External Document No." <> '' THEN
                        //ORG:           YourRefLoc := SalesShiptHeader."External Document No."
                        //ORG:        ELSE
                        YourRefLoc := SalesShiptHeader."Your Reference";
                        YourDateLoc := SalesShiptHeader."Order Date";
                    end else begin
                        //Cust.TESTFIELD("ILN Code");
                        if EDIValues2.FindSet() then
                            IlnCodeLoc := EDIValues2."EDI Identifier";

                        if SalesInvHeader."Ship-to Code" <> '' then begin
                            if Shipto.Get(SalesInvHeader."Sell-to Customer No.", SalesShiptHeader."Ship-to Code") then begin
                                EDIValues1.Reset();
                                EDIValues1.FilterByRecord(Shipto);
                                if EDIValues1.FindSet() then
                                    if EDIValues1."EDI Identifier" <> '' then
                                        IlnCodeLoc := EDIValues1."EDI Identifier";
                            end;
                        end else
                            IlnCodeLoc := EDIValues2."EDI Identifier";

                        case EDIGroup."Document Nos." of
                            EDIGroup."Document Nos."::Alphanumeric:

                                DocNoLoc := SalesInvHeader."No.";

                            EDIGroup."Document Nos."::Numeric:
                                begin
                                    Evaluate(TmpDocNo, TakeNr(SalesInvHeader."No."));
                                    DocNoLoc := Format(TmpDocNo);
                                end;
                        end;
                        DateLoc := SalesInvHeader."Posting Date";
                        YourRefLoc := SalesInvHeader."Your Reference";
                        YourDateLoc := SalesInvHeader."Order Date";
                    end;
                end;
            EdiDocTypeP::"Sales Cr.Memo":

                if GetReceiptNo() then begin
                    if SalesCrMemoHeader."Ship-to Code" <> '' then begin
                        Shipto.Get(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code");
                        EDIValues1.FilterByRecord(Shipto);
                        if EDIValues1.FindSet() then
                            if EDIValues1."EDI Identifier" = '' then begin
                                if EDIValues2.FindSet() then begin
                                    EDIValues2.TestField("EDI Identifier");
                                    IlnCodeLoc := EDIValues2."EDI Identifier";
                                end;
                            end else begin
                                EDIValues1.TestField("EDI Identifier");
                                IlnCodeLoc := EDIValues1."EDI Identifier";
                            end;
                        HasAddressLoc := true;
                    end else
                        if EDIValues2.FindSet() then begin
                            EDIValues2.TestField("EDI Identifier");
                            IlnCodeLoc := EDIValues2."EDI Identifier";
                        end;

                    case EDIGroup."Document Nos." of
                        EDIGroup."Document Nos."::Alphanumeric:

                            DocNoLoc := ReturnRcptHeader."No.";

                        EDIGroup."Document Nos."::Numeric:
                            begin
                                Evaluate(TmpDocNo, TakeNr(ReturnRcptHeader."No."));
                                DocNoLoc := Format(TmpDocNo);
                            end;
                    end;
                    DateLoc := ReturnRcptHeader."Posting Date";
                    YourRefLoc := ReturnRcptHeader."Your Reference";
                    YourDateLoc := ReturnRcptHeader."Order Date";
                end else begin
                    if SalesCrMemoHeader."Ship-to Code" <> '' then begin
                        Shipto.Get(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code");
                        EDIValues1.FilterByRecord(Shipto);
                        if EDIValues1.FindSet() then
                            if EDIValues1."EDI Identifier" = '' then begin
                                if EDIValues2.FindSet() then begin
                                    EDIValues2.TestField("EDI Identifier");
                                    IlnCodeLoc := EDIValues2."EDI Identifier";
                                end;
                            end else begin
                                EDIValues1.TestField("EDI Identifier");
                                IlnCodeLoc := EDIValues1."EDI Identifier";
                            end;
                        HasAddressLoc := true;
                    end else
                        if EDIValues2.FindSet() then begin
                            EDIValues2.TestField("EDI Identifier");
                            IlnCodeLoc := EDIValues2."EDI Identifier";
                        end;

                    case EDIGroup."Document Nos." of
                        EDIGroup."Document Nos."::Alphanumeric:

                            DocNoLoc := SalesCrMemoHeader."No.";

                        EDIGroup."Document Nos."::Numeric:
                            begin
                                Evaluate(TmpDocNo, TakeNr(SalesCrMemoHeader."No."));
                                DocNoLoc := Format(TmpDocNo);
                            end;
                    end;
                    DateLoc := SalesCrMemoHeader."Posting Date";
                    YourRefLoc := SalesCrMemoHeader."Your Reference";
                    YourDateLoc := SalesCrMemoHeader."Shipment Date";
                end;

        end;

        if (YourDateLoc = 0D) then
            YourRefLoc := '';
        if (YourRefLoc = '') then
            YourDateLoc := 0D;

        InitEDILine();
        EDILine."Record Type" := 'NAD';

        TempField := 'TIPOREC';
        TempRecord := 'NAD';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        // Block below has been adjusted for new Option in EDI Group Setup
        case EDIGroup."EDI-DELIV Out" of
            EDIGroup."EDI-DELIV Out"::VAT:
                begin
                    TempField := 'CODCONS';
                    TempRecord := StripCountryCode(Cust."VAT Registration No.");
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODCONS';
                    TempRecord := 'VA';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
            EDIGroup."EDI-DELIV Out"::"14":
                begin
                    TempField := 'CODCONS';
                    TempRecord := IlnCodeLoc;
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODCONS';
                    TempRecord := '14';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
            EDIGroup."EDI-DELIV Out"::"91":
                begin
                    TempField := 'CODCONS';
                    TempRecord := IlnCodeLoc;
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODCONS';
                    TempRecord := '91';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
            EDIGroup."EDI-DELIV Out"::"92":
                begin
                    TempField := 'CODCONS';
                    TempRecord := IlnCodeLoc;
                    EDIInsRow(TempField, TempRecord, true, true, 17, false);

                    TempField := 'QCODCONS';
                    TempRecord := '92';
                    EDIInsRow(TempField, TempRecord, true, true, 3, false);
                end;
        end;

        if HasAddressLoc then begin
            TempField := 'RAGSOCD';
            TempRecord := Shipto.Name;
            EDIInsRow(TempField, TempRecord, true, true, 70, false);

            TempField := 'INDIRD';
            TempRecord := Shipto.Address;
            EDIInsRow(TempField, TempRecord, true, true, 70, false);

            TempField := 'CITTAD';
            TempRecord := Shipto.City;
            EDIInsRow(TempField, TempRecord, true, true, 35, false);

            TempField := 'PROVD';
            TempRecord := Shipto.County;
            EDIInsRow(TempField, TempRecord, true, true, 9, false);

            TempField := 'CAPD';
            TempRecord := Shipto."Post Code";
            EDIInsRow(TempField, TempRecord, true, true, 9, false);

            TempField := 'NAZIOD';
            TempRecord := Shipto."Country/Region Code";
            EDIInsRow(TempField, TempRecord, false, true, 3, false);

        end else begin
            TempField := 'RAGSOCD';
            TempRecord := Cust.Name;
            EDIInsRow(TempField, TempRecord, true, true, 70, false);

            TempField := 'INDIRD';
            TempRecord := Cust.Address;
            EDIInsRow(TempField, TempRecord, true, true, 70, false);

            TempField := 'CITTAD';
            TempRecord := Cust.City;
            EDIInsRow(TempField, TempRecord, true, true, 35, false);

            TempField := 'PROVD';
            TempRecord := Cust.County;
            if Cust."Country/Region Code" = 'IT' then
                EDIInsRow(TempField, TempRecord, true, true, 9, false)
            else
                EDIInsRow(TempField, TempRecord, false, true, 9, false);
            TempField := 'CAPD';
            TempRecord := Cust."Post Code";
            EDIInsRow(TempField, TempRecord, true, true, 9, false);

            TempField := 'NAZIOD';
            TempRecord := Cust."Country/Region Code";
            EDIInsRow(TempField, TempRecord, false, true, 3, false);

        end;

        case EdiDocTypeP of
            EdiDocTypeP::"Sales Invoice":
                begin
                    TempField := 'NUMBOLLA';
                    TempRecord := DocNoLoc;
                    EDIInsRow(TempField, TempRecord, true, true, 35, false);

                    TempField := 'DATABOLLA';
                    TempRecord := DateFormat(DateLoc);
                    EDIInsRow(TempField, TempRecord, true, true, 8, false);
                end;

            EdiDocTypeP::"Sales Cr.Memo":
                begin
                    TempField := 'NUMBOLLA';
                    TempRecord := DocNoLoc;
                    EDIInsRow(TempField, TempRecord, false, true, 35, false);

                    TempField := 'DATABOLLA';
                    TempRecord := DateFormat(DateLoc);
                    EDIInsRow(TempField, TempRecord, false, true, 8, false);
                end;
        end;

        TempField := 'NUMORD';
        TempRecord := YourRefLoc;
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'DATAORD';
        TempRecord := DateFormat(YourDateLoc);
        EDIInsRow(TempField, TempRecord, false, true, 8, false);

        InsertEdiLine(true, 305);
    end;

    procedure Ins_TAX(EdiDocTypeP: enum "EOS074 EDI Document Type")
    begin
        // case EdiDocTypeP of
        //     EdiDocTypeP::"Sales Invoice":
        //         begin
        //         end;
        //     EdiDocTypeP::"Sales Cr.Memo":
        //         begin
        //         end;
        // end;

        if TempVATAmountLine.FindSet(false, false) then
            repeat
                InitEDILine();
                EDILine."Record Type" := 'TAX';

                TempField := 'TIPOREC';
                TempRecord := 'TAX';
                EDIInsRow(TempField, TempRecord, true, true, 3, false);

                TempField := 'TIPOTASS';
                TempRecord := 'VAT';
                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                EDIInsertDecriptionRowForInsTAX(TempVATAmountLine);

                TempField := 'CATIMP';

                EDICrossTable.Reset();
                EDICrossTable.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                EDICrossTable.SetRange(Type, EDICrossTable.Type::Vat);
                EDICrossTable.SetRange("NAV-Code", TempVATAmountLine."VAT Identifier");
                if EDICrossTable.FindLast() then
                    EDICrossTable.TestField("External Code")
                else
                    EDICrossTable.Init();

                TempRecord := EDICrossTable."External Code";
                if (TempRecord = '') and (TempVATAmountLine."VAT %" <> 0) then
                    TempRecord := 'S';

                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                TempField := 'ALIQIVA';
                TempRecord := FormatNumDecBiFront(TempVATAmountLine."VAT %", 7, 4);
                EDIInsRow(TempField, TempRecord, false, true, 7, false);

                TempField := 'IMPORTO';
                TempRecord := FormatNumDecBiFront(TempVATAmountLine."VAT Amount", 15, 3);
                EDIInsRow(TempField, SignText(TempVATAmountLine."VAT Amount", CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                OnBeforeInsertEDILineForInsTAX(TempVATAmountLine, EDIHeader);

                InsertEdiLine(true, 67);

            until TempVATAmountLine.Next() = 0;
    end;

    procedure Ins_ALD(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        DDDEventDispatcher: Codeunit "EOS066 DDD Event Dispatcher";
        TmpPercentLoc: Decimal;
        TmpAmountLoc: Decimal;
        DiscTypeL: enum "EOS074 Discount Type";
        DiscSeqNo: Integer;
        FullDiscount: Boolean;
        QtyDiscL: Decimal;
        DiscountText: Text;
    begin
        DiscTypeL := DiscTypeL::Percent;

        case EdiDocTypeP of
            EdiDocTypeP::"Sales Invoice":
                begin
                    if (SalesInvLine."Unit Price" = 0.0) then
                        exit;
                    TmpAmountLoc := SalesInvLine."Line Discount Amount";
                    TmpPercentLoc := SalesInvLine."Line Discount %";
                    QtyDiscL := SalesInvLine.Quantity;
                end;
            EdiDocTypeP::"Sales Cr.Memo":
                begin
                    if (SalesCrMemoLine."Unit Price" = 0.0) then
                        exit;
                    TmpAmountLoc := SalesCrMemoLine."Line Discount Amount";
                    TmpPercentLoc := SalesCrMemoLine."Line Discount %";
                    QtyDiscL := SalesCrMemoLine.Quantity;
                end;
        end;

        // Check Total Discount on the Sales Line
        case DiscTypeL of
            DiscTypeL::Percent:
                if (TmpPercentLoc = 0) then
                    exit;
        end;

        // Export Discount Sequence
        FullDiscount := TmpPercentLoc = 100;

        if FullDiscount then begin
            TmpAmountLoc := 0;
            case EdiDocTypeP of
                EdiDocTypeP::"Sales Invoice":
                    TmpAmountLoc := SalesInvLine."Line Discount Amount";
                EdiDocTypeP::"Sales Cr.Memo":
                    TmpAmountLoc := SalesCrMemoLine."Line Discount Amount";
            end;

            InitEDILine();
            EDILine."Record Type" := 'ALD';

            TempField := 'TIPOREC';
            TempRecord := 'ALD';
            EDIInsRow(TempField, TempRecord, true, true, 3, false);

            TempField := 'INDSCADD';
            TempRecord := 'A';
            EDIInsRow(TempField, TempRecord, true, true, 3, false);

            TempField := 'DESCR';
            TempRecord := 'ESCLUSO ART. 15 DPR 26/10/72 n.633';
            EDIInsRow(TempField, TempRecord, false, true, 35, false);

            TempField := 'INDSEQ';
            TempRecord := '100';
            EDIInsRow(TempField, TempRecord, false, true, 3, true);

            TempField := 'TIPOSCADD';
            TempRecord := 'E05';
            EDIInsRow(TempField, TempRecord, false, true, 6, false);

            TempField := 'IMPORTO';
            TempRecord := ' ';
            EDIInsRow(TempField, TempRecord, false, true, 16, false);

            TempField := 'PERC';
            TempRecord := FormatNumDecBiFront(TmpPercentLoc, 7, 4);
            EDIInsRow(TempField, TempRecord, false, true, 7, false);

            TempField := 'FLGPRZUN';
            TempRecord := '';  // Blank = Line Discount
            EDIInsRow(TempField, TempRecord, false, true, 3, false);

            InsertEdiLine(true, 76);
        end;

        if not FullDiscount then begin
            DiscSeqNo := 1;
            TmpAmountLoc := 0;
            TmpAmountLoc := 0;

            DiscountText := '';

            case EdiDocTypeP of
                EdiDocTypeP::"Sales Invoice":
                    begin
                        TmpPercentLoc := SalesInvLine."Line Discount %";
                        DiscountText := DDDEventDispatcher.GetDtldLineDiscountString(SalesInvLine, 2);
                    end;
                EdiDocTypeP::"Sales Cr.Memo":
                    begin
                        TmpPercentLoc := SalesCrMemoLine."Line Discount %";
                        DiscountText := DDDEventDispatcher.GetDtldLineDiscountString(SalesCrMemoLine, 2);
                    end;
            end;



            if TmpPercentLoc <> 0 then begin
                InitEDILine();
                EDILine."Record Type" := 'ALD';

                TempField := 'TIPOREC';
                TempRecord := 'ALD';
                EDIInsRow(TempField, TempRecord, true, true, 3, false);

                TempField := 'INDSCADD';
                TempRecord := 'A';
                EDIInsRow(TempField, TempRecord, true, true, 3, false);

                TempField := 'DESCR';
                TempRecord := 'Sconto';
                if DiscountText <> '' then
                    TempRecord := TempRecord + ' ' + DiscountText;

                EDIInsRow(TempField, TempRecord, false, true, 35, false);

                TempField := 'INDSEQ';
                DiscountSeqNo += 1;
                TempRecord := FormatNumDecBiFront(DiscountSeqNo * 100, 3, 0);
                EDIInsRow(TempField, TempRecord, false, true, 3, true);

                TempField := 'TIPOSCADD';
                TempRecord := 'TD';
                EDIInsRow(TempField, TempRecord, false, true, 6, false);


                TempField := 'IMPORTO';
                TempRecord := '+';
                EDIInsRow(TempField, TempRecord, false, true, 16, false);

                TempField := 'PERC';
                TempRecord := FormatNumDecBiFront(TmpPercentLoc, 7, 4);
                EDIInsRow(TempField, TempRecord, false, true, 7, false);

                TempField := 'FLGPRZUN';
                TempRecord := '';  // Blank = Line Discount
                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                InsertEdiLine(true, 76);
            end;
        end;
    end;


    // procedure Ins_NAE(EdiDocTypeP: enum "EOS074 EDI Document Type")
    // begin
    //     exit; // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":

    //         EdiDocTypeP::"Sales Cr.Memo":
    //     end;

    //     InitEDILine;
    //     EDILine."Record Type" := 'NAE';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAE';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     InsertEdiLine(true, 305);
    // end;


    // procedure Ins_NAR(EdiDocTypeP: enum "EOS074 EDI Document Type")
    // begin
    //     exit; // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":
    //             begin
    //             end;
    //         EdiDocTypeP::"Sales Cr.Memo":
    //             begin
    //             end;
    //     end;

    //     InitEDILine();

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAR';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     InsertEdiLine(true, 305);
    // end;

    // procedure Ins_NAM(EdiDocTypeP: enum "EOS074 EDI Document Type")
    // begin
    //     exit; // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":
    //             begin
    //             end;
    //         EdiDocTypeP::"Sales Cr.Memo":
    //             begin
    //             end;
    //     end;

    //     InitEDILine();
    //     EDILine."Record Type" := 'NAM';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAM';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     InsertEdiLine(true, 305);
    // end;

    // procedure Ins_NAF(EdiDocTypeP: enum "EOS074 EDI Document Type")
    // begin
    //     exit; // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":
    //             begin
    //             end;
    //         EdiDocTypeP::"Sales Cr.Memo":
    //             begin
    //             end;
    //     end;

    //     InitEDILine();
    //     EDILine."Record Type" := 'NAF';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAF';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     InsertEdiLine(true, 76);
    // end;

    // procedure Ins_NAX(EdiDocTypeP: enum "EOS074 EDI Document Type")
    // begin
    //     exit; // TODO

    //     case EdiDocTypeP of
    //         EdiDocTypeP::"Sales Invoice":
    //             begin
    //             end;
    //         EdiDocTypeP::"Sales Cr.Memo":
    //             begin
    //             end;
    //     end;

    //     InitEDILine;
    //     EDILine."Record Type" := 'NAX';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'NAX';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     InsertEdiLine(true, 305);
    // end;

    procedure Ins_SUM(EdiDocTypeP: enum "EOS074 EDI Document Type")
    begin
        CalcSummaries();

        Ins_FTT(EdiDocTypeP);

        Ins_ALT_TD(EdiDocTypeP);
        Ins_ALT_X01(EdiDocTypeP);

        Ins_IVA(EdiDocTypeP);
        Ins_TMA(EdiDocTypeP);
    end;

    procedure Ins_FTT(EdiDocTypeP: enum "EOS074 EDI Document Type")
    begin
        // case EdiDocTypeP of
        //     EdiDocTypeP::"Sales Invoice":

        //     EdiDocTypeP::"Sales Cr.Memo":
        // end;

        InitEDILine();
        EDILine."Record Type" := 'FTT';

        TempField := 'TIPOREC';
        TempRecord := 'FTT';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'TIPONOTA';
        TempRecord := 'AAI';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'NOTE';
        TempRecord := ConaiTxt;
        EDIInsRow(TempField, TempRecord, true, true, 150, false);

        TempField := 'NOTE1';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 150, false);

        TempField := 'NOTE2';
        // Org TempRecord := 'Contributo CONAI Assolto Ove Dovuto.';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 50, false);

        InsertEdiLine(true, 356);
    end;

    procedure Ins_ALT_TD(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        MaxLenght: Text[30];
    begin
        // case EdiDocTypeP of
        //     EdiDocTypeP::"Sales Invoice":

        //     EdiDocTypeP::"Sales Cr.Memo":
        // end;

        //OBBLIGATORIO SE NEL SOMMARIO DELLA FATTURA CARTACEA á PRESENTE UNO SCONTO/MAGGIORAZIONE

        if (InvoiceDiscAmount = 0.0) then
            exit;

        InitEDILine();
        EDILine."Record Type" := 'ALT';

        TempField := 'TIPOREC';
        TempRecord := 'ALT';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'INDSCADD';
        TempRecord := 'A';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'DESCR';
        TempRecord := 'Sconto fattura';
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'INDSEQ';
        TempRecord := '1';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'TIPOSCADD';
        TempRecord := 'TD';
        EDIInsRow(TempField, TempRecord, false, true, 6, false);

        TempField := 'IMPORTO';
        if (InvoiceDiscAmount = 0.0) then
            TempRecord := ''
        else
            TempRecord := SignText(InvoiceDiscAmount, CopyStr(FormatNumDecBiFront(InvoiceDiscAmount, 15, 3), 1, MaxStrLen(MaxLenght)));
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'PERC';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 7, false);

        InsertEdiLine(true, 73);
    end;

    procedure Ins_ALT_X01(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        MaxLenght: Text[30];
    begin
        // case EdiDocTypeP of
        //     EdiDocTypeP::"Sales Invoice":

        //     EdiDocTypeP::"Sales Cr.Memo":
        // end;

        //OBBLIGATORIO SE NEL SOMMARIO DELLA FATTURA CARTACEA á PRESENTE UNO SCONTO PAGAMENTO

        if (PaymentDiscAmount = 0.0) then
            exit;

        InitEDILine();
        EDILine."Record Type" := 'ALT';

        TempField := 'TIPOREC';
        TempRecord := 'ALT';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'INDSCADD';
        TempRecord := 'A';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'DESCR';
        TempRecord := 'Sconto pagamento';
        EDIInsRow(TempField, TempRecord, false, true, 35, false);

        TempField := 'INDSEQ';
        TempRecord := '1';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'TIPOSCADD';
        TempRecord := 'X01';
        EDIInsRow(TempField, TempRecord, false, true, 6, false);

        TempField := 'IMPORTO';
        if (PaymentDiscAmount = 0.0) then
            TempRecord := ''
        else
            TempRecord := SignText(PaymentDiscAmount, CopyStr(FormatNumDecBiFront(PaymentDiscAmount, 15, 3), 1, MaxStrLen(MaxLenght)));
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'PERC';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 7, false);

        InsertEdiLine(true, 73);
    end;

    procedure Ins_IVA(EdiDocTypeP: enum "EOS074 EDI Document Type")
    begin
        if TempVATAmountLine.Find('-') then
            repeat
                InitEDILine();
                EDILine."Record Type" := 'IVA';

                TempField := 'TIPOREC';
                TempRecord := 'IVA';
                EDIInsRow(TempField, TempRecord, true, true, 3, false);

                TempField := 'TIPOTASS';
                TempRecord := 'VAT';
                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                EDIInsertDecriptionRowForInsIVA(TempVATAmountLine);

                EDICrossTable.Reset();
                EDICrossTable.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
                EDICrossTable.SetRange(Type, EDICrossTable.Type::Vat);

                EDICrossTable.SetRange("NAV-Code", TempVATAmountLine."VAT Identifier");

                if EDICrossTable.Find('+') then
                    EDICrossTable.TestField("External Code")
                else
                    if TempVATAmountLine."VAT %" <> 0 then
                        EDICrossTable.Init()
                    else
                        EDICrossTable.Find('+');

                TempField := 'CATIMP';
                TempRecord := EDICrossTable."External Code";
                if (TempRecord = '') and
                   (TempVATAmountLine."VAT %" <> 0)
                then
                    TempRecord := 'S';
                EDIInsRow(TempField, TempRecord, false, true, 3, false);

                TempField := 'ALIQIVA';
                TempRecord := FormatNumDecBiFront(TempVATAmountLine."VAT %", 7, 4);
                EDIInsRow(TempField, TempRecord, false, true, 7, false);

                TempField := 'SIMPONIB';
                TempRecord := FormatNumDecBiFront(TempVATAmountLine."VAT Base", 15, 3);
                EDIInsRow(TempField, SignText(TempVATAmountLine."VAT Base", CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                TempField := 'SIMPORTO';
                TempRecord := FormatNumDecBiFront(TempVATAmountLine."VAT Amount", 15, 3);
                EDIInsRow(TempField, SignText(TempVATAmountLine."VAT Amount", CopyStr(TempRecord, 1, MaxStrLen(TempField))), false, true, 16, false);

                OnBeforeInsertEDILineForInsIVA(TempVATAmountLine, EDIHeader);

                InsertEdiLine(true, 83);

            until TempVATAmountLine.Next() = 0;
    end;

    procedure Ins_TMA(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        MaxLenght: Text[30];
    begin
        // case EdiDocTypeP of
        //     EdiDocTypeP::"Sales Invoice":

        //     EdiDocTypeP::"Sales Cr.Memo":
        // end;

        InitEDILine();
        EDILine."Record Type" := 'TMA';

        TempField := 'TIPOREC';
        TempRecord := 'TMA';
        EDIInsRow(TempField, TempRecord, true, true, 3, false);

        TempField := 'TOTDOC1';
        TempRecord := SignText(DocTotal, CopyStr(FormatNumDecBiFront(DocTotal, 15, 3), 1, MaxStrLen(MaxLenght)));
        EDIInsRow(TempField, TempRecord, true, true, 16, false);

        TempField := 'IMPOSTA1';
        TempRecord := SignText(DocTotal, CopyStr(FormatNumDecBiFront(DocVat, 15, 3), 1, MaxStrLen(MaxLenght)));
        EDIInsRow(TempField, TempRecord, true, true, 16, false);

        TempField := 'IMPONIB1';
        TempRecord := SignText(DocTotal, CopyStr(FormatNumDecBiFront(DocAmount, 15, 3), 1, MaxStrLen(MaxLenght)));
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'TOTRIGHE1';
        TempRecord := SignText(DocTotal, CopyStr(FormatNumDecBiFront(DocAmount, 15, 3), 1, MaxStrLen(MaxLenght)));
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'TOTANT1';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'TOTPAG1';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'DIVISA1';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        TempField := 'TOTDOC2';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, true, true, 16, false);

        TempField := 'IMPOSTA2';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, true, true, 16, false);

        TempField := 'IMPONIB2';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'TOTRIGHE2';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'TOTANT2';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'TOTPAG2';
        TempRecord := ' ';
        EDIInsRow(TempField, TempRecord, false, true, 16, false);

        TempField := 'DIVISA2';
        TempRecord := '';
        EDIInsRow(TempField, TempRecord, false, true, 3, false);

        InsertEdiLine(true, 201);
    end;

    /*
    procedure SplitDiscountsCustom()
    begin
        case EDIDocType of
            EDIDocType::"Sales Invoice":

                SplitInvoiceDiscountsCustom();

            EDIDocType::"Sales Cr.Memo":

                SplitCrMemoDiscountsCustom();

        end;
    end;

    procedure SplitInvoiceDiscountsCustom()
    var
        j: Integer;
        n: Integer;
    begin
        DiscountNo := 0;
        
        CASE SalesInvLine."Line Disc. Group Method" OF
          SalesInvLine."Line Disc. Group Method"::"Contract first":
            BEGIN
              CASE SalesInvLine."Contract Disc. Calc. Method" OF
                SalesInvLine."Contract Disc. Calc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','TD',SalesInvLine."Contract Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesInvLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesInvLine."Contract Disc. Calc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesInvLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','TD',SalesInvLine."Contract Line Disc. Amount",0.0,FALSE);
                  END;
              END;
              CASE SalesInvLine."Promotion Line Disc. Method" OF
                SalesInvLine."Promotion Line Disc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','PAD',SalesInvLine."Promotion Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesInvLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesInvLine."Promotion Line Disc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesInvLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','PAD',SalesInvLine."Promotion Line Disc. Amount",0.0,FALSE);
                  END;
              END;
            END;
          SalesInvLine."Line Disc. Group Method"::"Promotion first":
            BEGIN
              CASE SalesInvLine."Promotion Line Disc. Method" OF
                SalesInvLine."Promotion Line Disc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','PAD',SalesInvLine."Promotion Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesInvLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesInvLine."Promotion Line Disc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesInvLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','PAD',SalesInvLine."Promotion Line Disc. Amount",0.0,FALSE);
                  END;
              END;
              CASE SalesInvLine."Contract Disc. Calc. Method" OF
                SalesInvLine."Contract Disc. Calc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','TD',SalesInvLine."Contract Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesInvLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesInvLine."Contract Disc. Calc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesInvLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','TD',SalesInvLine."Contract Line Disc. Amount",0.0,FALSE);
                  END;
              END;
            END;
        END;
        

    end;*/

    // procedure Ins_ALD_Custom(OperationType: Text[3]; DiscountType: Text[6]; DiscAmount: Decimal; DiscPercent: Decimal; UnitBased: Boolean)
    // var
    //     TmpDiscLoc: Decimal;
    //     TmpAmountLoc: Decimal;
    //     MaxLenght: Text[30];
    // begin
    //     if (DiscAmount = 0.0) and (DiscPercent = 0.0) then
    //         exit;

    //     DiscountNo := DiscountNo + 1;
    //     InitEDILine();
    //     EDILine."Record Type" := 'ALD';

    //     TempField := 'TIPOREC';
    //     TempRecord := 'ALD';
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     TempField := 'INDSCADD';
    //     TempRecord := OperationType;
    //     EDIInsRow(TempField, TempRecord, true, true, 3, false);

    //     TempField := 'DESCR';
    //     case OperationType of
    //         'A':
    //             TempRecord := 'Sconto';
    //         'C':
    //             TempRecord := 'Addebito';
    //         'N':
    //             TempRecord := 'Cond. Speciale';
    //     end;
    //     EDIInsRow(TempField, TempRecord, true, true, 35, false);

    //     TempField := 'INDSEQ';
    //     TempRecord := FormatNumDecBiFront(DiscountNo, 3, 0);
    //     EDIInsRow(TempField, TempRecord, true, true, 3, true);

    //     TempField := 'TIPOSCADD';
    //     // 'TD' for Commercial Discount
    //     // 'PAD' for Promotional Discount
    //     if OperationType in ['A', 'N'] then
    //         TempRecord := DiscountType
    //     else
    //         TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, true, true, 6, false);

    //     TmpAmountLoc := DiscAmount;
    //     TempField := 'IMPORTO';
    //     if (TmpAmountLoc = 0.0) then
    //         TempRecord := ''
    //     else
    //         TempRecord := SignText(TmpAmountLoc, CopyStr(FormatNumDecBiFront(TmpAmountLoc, 15, 3), 1, MaxStrLen(MaxLenght)));
    //     EDIInsRow(TempField, TempRecord, false, true, 16, false);

    //     TmpDiscLoc := DiscPercent;
    //     TempField := 'PERC';
    //     if (TmpDiscLoc = 0.0) then
    //         TempRecord := ''
    //     else
    //         TempRecord := FormatNumDecBiFront(TmpDiscLoc, 7, 4);
    //     EDIInsRow(TempField, TempRecord, false, true, 7, false);

    //     TempField := 'FLGPRZUN';
    //     if UnitBased then
    //         TempRecord := 'X31'
    //     else
    //         TempRecord := '';
    //     EDIInsRow(TempField, TempRecord, false, true, 3, false);

    //     InsertEdiLine(true, 76);
    // end;

    procedure ConvertText2Discount(DiscountText: Code[20]) DiscountDec: Decimal
    var
        DiscountValue: Code[20];
        OK: Boolean;
        i: Integer;
        j: Integer;
        PlusLbl: Label '+', Locked = true;
        DiscountErr: Label 'Discount has Errors: %1';
    begin
        Clear(DiscountTxt);
        Clear(DiscountVal);

        // Select individual discounts in an array of length 3 
        DiscountValue := ConvertStr(DiscountText, '%.', ' ,');
        i := STRPOS(DiscountValue, PlusLbl);
        j := 1;
        Clear(DiscountTxt);
        if i = 0 then
            DiscountTxt[1] := DiscountValue
        else
            while (j < ARRAYLEN(DiscountTxt)) and
              (i <> 0)
            do begin
                DiscountTxt[j] := CopyStr(CopyStr(DiscountValue, 1, i - 1), 1, MaxStrLen(DiscountTxt[j]));
                DiscountTxt[j + 1] := CopyStr(CopyStr(DiscountValue, i + 1), 1, MaxStrLen(DiscountTxt[j + 1]));
                DiscountValue := CopyStr(CopyStr(DiscountValue, i + 1), 1, MaxStrLen(DiscountValue));
                i := STRPOS(DiscountValue, PlusLbl);
                j := j + 1;
            end;

        // Check for any errors
        OK := true;
        for j := 1 to ARRAYLEN(DiscountTxt) do begin
            DiscountValue := DiscountTxt[j];
            for i := 1 to StrLen(DiscountValue) do
                if not (DiscountValue[i] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ',']) then
                    OK := false;
        end;
        if not OK then
            Error(DiscountErr, DiscountText);

        // Convert the individual cash discounts into numerical values and then calculate the effective cash discount value.
        for i := 1 to ARRAYLEN(DiscountTxt) do
            if DiscountTxt[i] <> '' then begin
                OK := Evaluate(DiscountVal[i], DiscountTxt[i]);
                if not OK then
                    Error(DiscountErr, DiscountText);
            end;

        DiscountDec := (1 - (1 - DiscountVal[1] / 100) * (1 - DiscountVal[2] / 100) * (1 - DiscountVal[3] / 100) * (1 - DiscountVal[4] / 100)) * 100;
    end;

    procedure CalcSummaries()
    begin
        SRSetup.Get();

        case EDIDocType of
            EDIDocType::"Sales Invoice":
                begin
                    SalesInvLine.Reset();
                    SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                    SalesInvLine.SetRange("Sell-to Customer No.", SalesInvHeader."Sell-to Customer No.");
                    SalesInvLine.SetFilter(Quantity, '<>%1', 0);
                    TempVATAmountLine.DeleteAll();
                    if SalesInvLine.FindSet(false, false) then
                        repeat
                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := SalesInvLine."VAT Identifier";
                            TempVATAmountLine."VAT Calculation Type" := SalesInvLine."VAT Calculation Type";
                            TempVATAmountLine."Tax Group Code" := SalesInvLine."Tax Group Code";
                            TempVATAmountLine."VAT %" := SalesInvLine."VAT %";
                            TempVATAmountLine."VAT Base" := SalesInvLine.Amount;
                            TempVATAmountLine."Amount Including VAT" := SalesInvLine."Amount Including VAT";
                            TempVATAmountLine."Line Amount" := SalesInvLine."Line Amount";
                            if SalesInvLine."Allow Invoice Disc." then begin
                                TempVATAmountLine."Inv. Disc. Base Amount" := SalesInvLine."Line Amount";
                                TempVATAmountLine."Invoice Discount Amount" := SalesInvLine."Inv. Discount Amount";
                            end;
                            TempVATAmountLine.InsertLine();
                        until SalesInvLine.Next() = 0;
                end;
            EDIDocType::"Sales Cr.Memo":
                begin
                    SalesCrMemoLine.Reset();
                    SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SetRange("Sell-to Customer No.", SalesCrMemoHeader."Sell-to Customer No.");
                    SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
                    TempVATAmountLine.DeleteAll();
                    if SalesCrMemoLine.FindSet(false, false) then
                        repeat
                            TempVATAmountLine.Init();
                            TempVATAmountLine."VAT Identifier" := SalesCrMemoLine."VAT Identifier";
                            TempVATAmountLine."VAT Calculation Type" := SalesCrMemoLine."VAT Calculation Type";
                            TempVATAmountLine."Tax Group Code" := SalesCrMemoLine."Tax Group Code";
                            TempVATAmountLine."VAT %" := SalesCrMemoLine."VAT %";
                            TempVATAmountLine."VAT Base" := SalesCrMemoLine.Amount;
                            TempVATAmountLine."Amount Including VAT" := SalesCrMemoLine."Amount Including VAT";
                            TempVATAmountLine."Line Amount" := SalesCrMemoLine."Line Amount";
                            if SalesCrMemoLine."Allow Invoice Disc." then begin
                                TempVATAmountLine."Inv. Disc. Base Amount" := SalesCrMemoLine."Line Amount";
                                TempVATAmountLine."Invoice Discount Amount" := SalesCrMemoLine."Inv. Discount Amount";
                            end;
                            TempVATAmountLine.InsertLine();
                        until SalesCrMemoLine.Next() = 0;
                end;
        end;

        if TempVATAmountLine.FindSet(false, false) then
            repeat
                DocVat := DocVat + TempVATAmountLine."VAT Amount";
                DocAmount := DocAmount + TempVATAmountLine."VAT Base";
                DocTotal := DocAmount + DocVat;
                DocDiscAmount := DocDiscAmount + TempVATAmountLine."Invoice Discount Amount";
            until (TempVATAmountLine.Next() = 0);
    end;
    /*
    procedure SplitCrMemoDiscountsCustom()
    var
        j: Integer;
        n: Integer;
    begin
        DiscountNo := 0;
        
        CASE SalesCrMemoLine."Line Disc. Group Method" OF
          SalesCrMemoLine."Line Disc. Group Method"::"Contract first":
            BEGIN
              CASE SalesCrMemoLine."Contract Disc. Calc. Method" OF
                SalesCrMemoLine."Contract Disc. Calc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','TD',SalesCrMemoLine."Contract Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesCrMemoLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesCrMemoLine."Contract Disc. Calc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesCrMemoLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','TD',SalesCrMemoLine."Contract Line Disc. Amount",0.0,FALSE);
                  END;
              END;
              CASE SalesCrMemoLine."Promotion Line Disc. Method" OF
                SalesCrMemoLine."Promotion Line Disc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','PAD',SalesCrMemoLine."Promotion Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesCrMemoLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesCrMemoLine."Promotion Line Disc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesCrMemoLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','PAD',SalesCrMemoLine."Promotion Line Disc. Amount",0.0,FALSE);
                  END;
              END;
            END;
          SalesCrMemoLine."Line Disc. Group Method"::"Promotion first":
            BEGIN
              CASE SalesCrMemoLine."Promotion Line Disc. Method" OF
                SalesCrMemoLine."Promotion Line Disc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','PAD',SalesCrMemoLine."Promotion Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesCrMemoLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesCrMemoLine."Promotion Line Disc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesCrMemoLine."Promotion Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','PAD',SalesCrMemoLine."Promotion Line Disc. Amount",0.0,FALSE);
                  END;
              END;
              CASE SalesCrMemoLine."Contract Disc. Calc. Method" OF
                SalesCrMemoLine."Contract Disc. Calc. Method"::"Amount First":
                  BEGIN
                    InsALDRecordMO('A','TD',SalesCrMemoLine."Contract Line Disc. Amount",0.0,FALSE);
                    ConvertText2Discount(SalesCrMemoLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                  END;
                SalesCrMemoLine."Contract Disc. Calc. Method"::"Percent First":
                  BEGIN
                    ConvertText2Discount(SalesCrMemoLine."Contract Line Discount");
                    FOR j := 1 TO ARRAYLEN(DiscountVal) DO
                      InsALDRecordMO('A','TD',0.0,DiscountVal[j],FALSE);
                    InsALDRecordMO('A','TD',SalesCrMemoLine."Contract Line Disc. Amount",0.0,FALSE);
                  END;
              END;
            END;
        END;
        

    end;*/

    procedure StripCountryCode(TextIn: Text[30]) TextOut: Text[30]
    begin
        if (CopyStr(UPPERCASE(TextIn), 1, 1) in ['A' .. 'Z']) then
            TextOut := TextIn
        else
            exit(TextIn);
        exit(TextOut);
    end;

    local procedure TakeNr(Nr: Code[20]): Code[20]
    var
        IniPos: Integer;
        EndPos: Integer;
    begin
        TakeInteger(Nr, IniPos, EndPos);
        if IniPos <> 0 then
            exit(Nr);
    end;

    local procedure TakeInteger(Nr: Code[20]; var IniPos: Integer; var EndPos: Integer)
    var
        IsDigit: Boolean;
        i: Integer;
    begin
        IniPos := 0;
        EndPos := 0;
        if Nr <> '' then begin
            i := StrLen(Nr);
            repeat
                IsDigit := Nr[i] in ['0' .. '9'];
                if IsDigit then begin
                    if EndPos = 0 then
                        EndPos := i;
                    IniPos := i;
                end;
                i := i - 1;
            until (i = 0) or (IniPos <> 0) and not IsDigit;
        end;
    end;

    procedure GetShipmentNo(): Boolean
    begin
        if SalesShiptHeader.Get(SalesInvLine."Document No.") then
            exit(true);

        if SalesInvLine."Shipment No." <> '' then begin
            if SalesShiptHeader.Get(SalesInvLine."Shipment No.") then;
            exit(true);
        end;

        Clear(SalesShiptHeader);
        exit(false);
    end;


    procedure GetReceiptNo(): Boolean
    begin
        if (SalesCrMemoLine."Return Receipt No." <> '') then begin
            ReturnRcptHeader.Get(SalesCrMemoLine."Return Receipt No.");
            exit(true);
        end;

        //IF (SalesCrMemoHeader."Last Return Receipt No." <> '') THEN BEGIN
        //  ReturnRcptHeader.GET(SalesCrMemoHeader."Last Return Receipt No.");
        //  EXIT(TRUE);
        //END;

        Clear(ReturnRcptHeader);
        exit(false);
    end;

    procedure CreateHeaderCommentStd(): Text[1024]
    var
        lRecSalesInvoiceLine: Record "Sales Invoice Line";
        lRecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCommentLine: Record "Sales Comment Line";
        TempText: Text[1024];
        CommentText: Text[350];
    begin
        case EDIDocType of
            EDIDocType::"Sales Invoice":
                begin
                    lRecSalesInvoiceLine.SetRange("Document No.", SalesInvHeader."No.");
                    lRecSalesInvoiceLine.SetRange(Type, lRecSalesInvoiceLine.Type::" ");
                    if lRecSalesInvoiceLine.Find('-') then
                        repeat
                            TempText := CopyStr(TempText + lRecSalesInvoiceLine.Description + ' ', 1, MaxStrLen(TempText));
                        until (lRecSalesInvoiceLine.Next() = 0);
                    SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Invoice");
                    SalesCommentLine.SetRange("No.", SalesInvHeader."No.");
                    if SalesCommentLine.Find('-') then
                        repeat
                            TempText := CopyStr(TempText + SalesCommentLine.Comment + ' ', 1, MaxStrLen(TempText));
                        until (SalesCommentLine.Next() = 0);
                end;
            EDIDocType::"Sales Cr.Memo":
                begin
                    lRecSalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    lRecSalesCrMemoLine.SetRange(Type, lRecSalesCrMemoLine.Type::" ");
                    if lRecSalesCrMemoLine.Find('-') then
                        repeat
                            TempText := CopyStr(TempText + lRecSalesCrMemoLine.Description + ' ', 1, MaxStrLen(TempText));
                        until (lRecSalesCrMemoLine.Next() = 0);
                    SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Credit Memo");
                    SalesCommentLine.SetRange("No.", SalesCrMemoHeader."No.");
                    if SalesCommentLine.Find('-') then
                        repeat
                            TempText := CopyStr(TempText + SalesCommentLine.Comment + ' ', 1, MaxStrLen(TempText));
                        until (SalesCommentLine.Next() = 0);
                end;
        end;
        if (TempText > '') then
            CommentText := PADSTR(TempText, 350, ' ');
        exit(CopyStr(CommentText, 1, 350));
    end;

    // procedure GetInvoiceVATED(SalesInvoiceHeader: Record "Sales Invoice Header"; var VATDEText: Text[1024])
    // var
    //     SalesInvoiceLine: Record "Sales Invoice Line";
    //     TextDeclarationTxt: Label 'Dichiarazione d''Intento nr. %1 (prot. %2).';
    //     VATED: Record Table18004170; //VAT Exclusion Declaration
    // begin
    //     Clear(VATDEText);
    //     if SalesInvoiceHeader."VAT Excl. Decl. Register No." <> '' then begin
    //         Clear(SalesInvoiceLine);
    //         SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
    //         SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
    //         if not SalesInvoiceLine.IsEmpty() then begin
    //             Clear(VATED);
    //             VATED.SETCURRENTKEY("Source Type", "VAT Excl. Decl. Register No.");
    //             VATED.SetRange("Source Type", VATED."Source Type"::"0");
    //             VATED.SetRange("VAT Excl. Decl. Register No.", SalesInvoiceHeader."VAT Excl. Decl. Register No.");
    //             VATED.FindFirst();
    //             VATDEText := StrSubstNo(TextDeclarationTxt, SalesInvoiceHeader."VAT Excl. Decl. No."
    //                                                        , SalesInvoiceHeader."VAT Excl. Decl. Register No."
    //                                                        , VATED."Emission Date", VATED."Receipt Date");
    //         end;
    //     end;
    // end;

    // procedure GetCrMemoVATED(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var VATDEText: Text[1024])
    // var
    //     
    //     SalesCrMemoLine: Record "Sales Cr.Memo Line";
    //     TextDeclarationTxt: Label 'DI No. %1 (Reg. No. %2) at date %3 and received %4.';
    //     VATED: Record Table18004170;
    // begin
    //     Clear(VATDEText);
    //     if SalesCrMemoHeader."VAT Excl. Decl. Register No." <> '' then begin
    //         Clear(SalesCrMemoLine);
    //         SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
    //         SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
    //         if not SalesCrMemoLine.IsEmpty() then begin
    //             Clear(VATED);
    //             VATED.SETCURRENTKEY("Source Type", "VAT Excl. Decl. Register No.");
    //             VATED.SetRange("Source Type", VATED."Source Type"::"0");
    //             VATED.SetRange("VAT Excl. Decl. Register No.", SalesCrMemoHeader."VAT Excl. Decl. Register No.");
    //             VATED.FindFirst();
    //             VATDEText := StrSubstNo(TextDeclarationTxt, SalesCrMemoHeader."VAT Excl. Decl. No."
    //                                                        , SalesCrMemoHeader."VAT Excl. Decl. Register No."
    //                                                        , VATED."Emission Date", VATED."Receipt Date");
    //         end;
    //     end;
    // end;

    /// <summary>
    /// Execute before insert EDI Line for Ins_NAS
    /// If you want to add EDI Rows 
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertEDILineForInsNAS(CompanyInfo: Record "Company Information"; EDIGroup: Record "EOS074 EDI Group")
    begin
    end;

    /// <summary>
    /// Execute before insert EDI Line for Ins_TAX
    /// If you want to add EDI Rows
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertEDILineForInsTAX(VATAmountLine: Record "VAT Amount Line"; EDIHeader: Record "EOS074 EDI Message Header")
    begin
    end;

    /// <summary>
    /// Execute before insert EDI Line for Ins_IVA
    /// If you want to add EDI Rows
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertEDILineForInsIVA(VATAmountLine: Record "VAT Amount Line"; EDIHeader: Record "EOS074 EDI Message Header")
    begin
    end;

    /// <summary>
    /// Execute before insert EDI Line for Ins_PAT
    /// If you want to add EDI Rows
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertEDILineForInsPAT(CustLedgerEntry: Record "Cust. Ledger Entry"; PaymentMethod: Record "Payment Method")
    begin
    end;

    /// <summary>
    /// Execute before init EDI Line
    /// If you want to add filters
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitEDILineForInsPAT(SalesInvHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; EDIDocType: Enum "EOS074 EDI Document Type")
    begin
    end;

    /// <summary>
    /// Execute between insert of EDI description row
    /// Used for add EDI description row 
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure EDIInsertDecriptionRowForInsTAX(VATAmountLine: Record "VAT Amount Line");
    begin
    end;

    /// <summary>
    /// Execute between insert of EDI description row
    /// Used for add EDI description row 
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure EDIInsertDecriptionRowForInsNAS(CompanyInfo: Record "Company Information");
    begin
    end;

    /// <summary>
    /// Execute between insert of EDI description row
    /// Used for add EDI description row 
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure EDIInsertDecriptionRowForInsIVA(VATAmountLine: Record "VAT Amount Line");
    begin
    end;

    /// <summary>
    /// Execute between insert of EDI description row
    /// Used for add EDI description row 
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure EDIInsertDecriptionRowForInsPAT(EDIDocType: Enum "EOS074 EDI Document Type");
    begin
    end;

    /// <summary>
    /// Execute between insert of EDI description row
    /// Used for VatNo assignement 
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure VatNoAssignementForInsBGM(CustInvoice: Record Customer; var VatNo: Text[30])
    begin
    end;
}

