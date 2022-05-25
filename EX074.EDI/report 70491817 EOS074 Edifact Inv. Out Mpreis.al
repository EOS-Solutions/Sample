report 70491817 "EOS074 Edifact Inv. Out Mpreis"
{
    Caption = 'EDI Edifact Eancom Invoice Out Mpreis';
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
                DataItemLink = "EDI Group Code" = field("EDI Group Code");

                dataitem(SalesInvHeader; "Sales Invoice Header")
                {
                    DataItemTableView = sorting("Bill-to Customer No.", "Posting Date");
                    RequestFilterFields = "Posting Date";

                    trigger OnAfterGetRecord()
                    var
                        MaxLenght: Text[50];
                        MaxLenght2: Text[10];
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


                        TempVatAmountLine.Reset();
                        TempVatAmountLine.DeleteAll();

                        SalesInvLine.Reset();
                        SalesInvLine.SetRange("Document No.", "No.");
                        if SalesInvLine.FindSet() then
                            repeat
                                if (SalesInvLine."No." <> '') and
                                   (SalesInvLine.Quantity <> 0)
                                then begin
                                    TempVatAmountLine.Init();
                                    TempVatAmountLine."VAT Identifier" := SalesInvLine."VAT Identifier";
                                    TempVatAmountLine."VAT Calculation Type" := SalesInvLine."VAT Calculation Type";
                                    TempVatAmountLine."Tax Group Code" := SalesInvLine."Tax Group Code";
                                    TempVatAmountLine."VAT %" := SalesInvLine."VAT %";
                                    TempVatAmountLine."VAT Base" := SalesInvLine.Amount;
                                    TempVatAmountLine."Amount Including VAT" := SalesInvLine."Amount Including VAT";
                                    TempVatAmountLine."Line Amount" := SalesInvLine."Line Amount";
                                    if SalesInvLine."Allow Invoice Disc." then
                                        TempVatAmountLine."Inv. Disc. Base Amount" := SalesInvLine."Line Amount";
                                    TempVatAmountLine."Invoice Discount Amount" := SalesInvLine."Inv. Discount Amount";
                                    TempVatAmountLine.InsertLine();
                                end;
                            until SalesInvLine.Next() = 0;


                        if SalesInvHeader."Currency Code" = '' then
                            Currency.InitRoundingPrecision()
                        else begin
                            SalesInvHeader.TestField("Currency Factor");
                            Currency.Get(SalesInvHeader."Currency Code");
                            Currency.TestField("Amount Rounding Precision");
                        end;

                        Ins_UNA();
                        Ins_UNB();
                        Ins_UNH();
                        Ins_BGM(EDIDocType::"Sales Invoice");
                        Ins_DTM("Posting Date", '137', '102');
                        Ins_DTM(TODAY, '35', '102');
                        Ins_FTX();
                        Ins_FTX_ZZZ();
                        Ins_RFFDTM();
                        // ORG: Ins_NAD("Bill-to Customer No.");
                        Ins_NAD("Bill-to Customer No.", "Sell-to Customer No.");
                        Ins_CUX("Currency Code");

                        // PAT optional

                        SalesInvLine.Reset();
                        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                        SalesInvLine.SetRange(SalesInvLine.Type, SalesInvLine.Type::Item);
                        LineNo := 0;
                        if SalesInvLine.FindSet() then
                            repeat
                                if (SalesInvLine."No." <> '') and
                                   (SalesInvLine.Quantity <> 0) then begin

                                    Ins_LIN(SalesInvLine."No.", SalesInvLine."Sell-to Customer No.");

                                    /*    // NOT used
                                    IF SalesInvLine."Cross-Reference No." <> '' THEN
                                      Ins_PIA(SalesInvLine."No.", SalesInvLine."Cross-Reference No.",'IN', '92');
                                    Ins_PIA(SalesInvLine."No.", SalesInvLine."No.",'SA', '91');
                                    */

                                    Ins_IMD(CopyStr(SalesInvLine.Description, 1, MaxStrLen(MaxLenght)), SalesInvLine."Description 2");

                                    Ins_QTY(SalesInvLine.Quantity, SalesInvLine."Unit of Measure Code", SalesInvLine."Item Reference Unit of Measure");
                                    //Ins_FTX('REG','',294,''); // TAX ? todo
                                    Ins_MOA(SalesInvLine.Amount, '203');

                                    Ins_PRI(SalesInvLine."Unit Price", SalesInvLine.Quantity, SalesInvLine."Line Amount", 'AAA');
                                    Ins_PRI(SalesInvLine."Unit Price", SalesInvLine.Quantity, SalesInvLine."Line Amount", 'AAB');

                                    Clear(SalesShiptHeader);
                                    Clear(SalesHeader);

                                    /*
                                    SalesShiptLine.RESET;
                                    IF SalesShiptLine.GET(SalesInvLine."Shipment No.", SalesInvLine."Shipment Line No.") THEN BEGIN
                                      IF SalesShiptHeader.GET(SalesInvLine."Shipment No.") THEN;
                                      IF SalesHeader.GET(SalesHeader."Document Type"::Order, SalesShiptLine."Order No.") THEN;

                                    END;

                                    IF SalesHeader.GET(SalesHeader."Document Type"::Order, "Order No.") THEN;
                                    //Ins_RFF(SalesHeader."Your Reference",'','ON');
                                    Ins_RFF(SalesHeader."External Document No.",'','ON');
                                    Ins_DTM(SalesHeader."Order Date", '171', '102');

                                    Ins_RFF(SalesHeader."No.",'','VN');
                                    Ins_DTM(SalesHeader."Order Date", '171', '102');

                                    Ins_RFF(SalesShiptHeader."No.",'','DQ');
                                    Ins_DTM(SalesShiptHeader."Posting Date",'171');
                                    */

                                    Ins_TAX(CopyStr(FormatDec(SalesInvLine."VAT %", 2), 1, MaxStrLen(MaxLenght2)), '7', 'VAT'/*, 'S'*/);

                                    if (SalesInvLine."Line Discount %" <> 0) then begin
                                        Ins_ALC(1, 'A', 'DI');
                                        Ins_PCD(SalesInvLine."Line Discount %", '12');
                                        Ins_ALC(0, 'A', 'DI');
                                        Ins_MOA(SalesInvLine."Line Discount Amount", '204');
                                    end;

                                end;
                            until SalesInvLine.Next() = 0;


                        Ins_UNS();
                        SalesInvHeader.CalcFields(Amount, "Amount Including VAT");
                        Ins_MOA(SalesInvHeader.Amount, '79');
                        Ins_MOA(SalesInvHeader."Amount Including VAT", '39');
                        Ins_MOA(SalesInvHeader."Amount Including VAT" - SalesInvHeader.Amount, '176');

                        /*
                        VATEntries.SETRANGE(VATEntries."Document No.",SalesInvHeader."No.");
                        IF VATEntries.FINDSET THEN BEGIN
                           REPEAT
                              Ins_TAX(FormatDec(VATEntries."VAT %",2),'7','VAT', '');
                              Ins_MOA(VATEntries.Amount,'124');
                              Ins_MOA(VATEntries.Base, '125');
                           UNTIL VATEntries.NEXT = 0;
                        END;
                        */

                        OnBeforeInsUNTForSalesInvoiceHeader(SalesInvHeader);

                        Ins_UNT();
                        Ins_UNZ();

                    end;

                    trigger OnPreDataItem()
                    begin
                        if not EDIGroup."Allow Invoice" then
                            CurrReport.Break();

                        ProgressBar.Update(2, TableCaption());

                        if EDIMessageSetup.GETFILTER("Date Filter") <> '' then
                            SetFilter("Posting Date", EDIMessageSetup.GETFILTER("Date Filter"));

                        if EDIMessageSetup.GETFILTER("Document No. Filter") <> '' then
                            SetFilter("No.", EDIMessageSetup.GETFILTER("Document No. Filter"));

                        if not EDIMessageSetup.IsTableAllowed(Database::"Sales Invoice Header") then
                            CurrReport.Break();
                    end;
                }
            }

            dataitem(EDIValues2; "EOS074 EDI Values")
            {
                DataItemLink = "EDI Group Code" = field("EDI Group Code");

                dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
                {
                    // DataItemLink = "EDI Group Code" = field("EDI Group Code");
                    // DataItemTableView = sorting("EDI Group Code", "Bill-to Customer No.", "Posting Date");

                    DataItemTableView = sorting("Bill-to Customer No.", "Posting Date");
                    RequestFilterFields = "Posting Date";

                    trigger OnAfterGetRecord()
                    var
                        MaxLenght: Text[50];
                        MaxLenght2: Text[10];
                    begin
                        ProgressBar.Update(3, "No.");

                        EDIDocType := EDIDocType::"Sales Cr.Memo";

                        if not EDIMgt.CreateEDIHeader(EDIHeader, EDIMessageSetup, Database::"Sales Invoice Header", 0, "No.", "Posting Date") then
                            CurrReport.Skip();

                        SalesCrMemoLine.Reset();
                        SalesCrMemoLine.SetRange("Document No.", "No.");
                        SalesCrMemoLine.SetRange("Bill-to Customer No.", "Bill-to Customer No.");
                        SalesCrMemoLine.SetRange(Type, SalesInvLine.Type::Item);
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

                        if SalesCrMemoHeader."Currency Code" = '' then
                            Currency.InitRoundingPrecision()
                        else begin
                            SalesCrMemoHeader.TestField("Currency Factor");
                            Currency.Get(SalesCrMemoHeader."Currency Code");
                            Currency.TestField("Amount Rounding Precision");
                        end;

                        Ins_UNA();
                        Ins_UNB();
                        Ins_UNH();
                        Ins_BGM(EDIDocType::"Sales Invoice");
                        Ins_DTM("Document Date", '137', '102');
                        Ins_DTM("Posting Date", '454', '102');
                        Ins_DTM(TODAY, '35', '102');
                        // Ins_FTX('AAI','','','Supply Date is equals Invoice Date');
                        // ORG: Ins_NAD("Bill-to Customer No.");
                        Ins_NAD("Bill-to Customer No.", "Sell-to Customer No.");
                        Ins_CUX("Currency Code");

                        SalesCrMemoLine.Reset();
                        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                        SalesCrMemoLine.SetRange(SalesCrMemoLine.Type, SalesCrMemoLine.Type::Item);
                        LineNo := 0;
                        if SalesCrMemoLine.FindSet() then
                            repeat
                                Ins_LIN(SalesCrMemoLine."No.", SalesCrMemoLine."Sell-to Customer No.");
                                Ins_IMD(CopyStr(SalesCrMemoLine.Description, 1, MaxStrLen(MaxLenght)), SalesCrMemoLine."Description 2");

                                Ins_QTY(SalesCrMemoLine.Quantity, SalesCrMemoLine."Unit of Measure Code", SalesCrMemoLine."Item Reference Unit of Measure");
                                Ins_MOA(SalesCrMemoLine.Amount, '203');

                                Ins_PRI(SalesCrMemoLine."Unit Price", SalesCrMemoLine.Quantity, SalesCrMemoLine."Line Amount", 'AAA');
                                Ins_PRI(SalesCrMemoLine."Unit Price", SalesCrMemoLine.Quantity, SalesCrMemoLine."Line Amount", 'AAB');

                                Clear(SalesCrMemoHeader);
                                Clear(SalesHeader);
                                /*
                                SalesShiptLine.RESET;
                                IF SalesShiptLine.GET(SalesCrMemoLine."Shipment No.", SalesCrMemoLine."Shipment Line No.") THEN BEGIN
                                  IF SalesCrMemoHeader.GET(SalesCrMemoLine."Shipment No.") THEN;
                                  IF SalesHeader.GET(SalesHeader."Document Type"::Order, SalesShiptLine."Order No.") THEN;
                                END;

                                Ins_RFF(SalesHeader."Your Reference",'','ON');
                                Ins_DTM(SalesHeader."Order Date", '171');

                                Ins_RFF(SalesCrMemoHeader."No.",'','DQ');
                                Ins_DTM(SalesCrMemoHeader."Posting Date",'171');
                                */
                                Ins_TAX(CopyStr(FormatDec(SalesCrMemoLine."VAT %", 2), 1, MaxStrLen(MaxLenght2)), '7', 'VAT'/*, 'S'*/);

                                if (SalesCrMemoLine."Line Discount %" <> 0) then begin
                                    Ins_ALC(1, 'A', 'DI');
                                    Ins_PCD(SalesCrMemoLine."Line Discount %", '12');
                                    Ins_ALC(0, 'A', 'DI');
                                    Ins_MOA(SalesCrMemoLine."Line Discount Amount", '204');
                                end;

                            until SalesCrMemoLine.Next() = 0;


                        Ins_UNS();
                        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT");
                        Ins_MOA(SalesCrMemoHeader.Amount, '79');
                        Ins_MOA(SalesCrMemoHeader."Amount Including VAT", '77');
                        Ins_MOA(SalesCrMemoHeader."Amount Including VAT" - SalesCrMemoHeader.Amount, '124');

                        /*
                        VATEntries.SETRANGE(VATEntries."Document No.",SalesCrMemoHeader."No.");
                        IF VATEntries.FINDSET THEN BEGIN
                           REPEAT
                              Ins_TAX(FormatDec(VATEntries."VAT %",2),'7','VAT', '');
                              Ins_MOA(VATEntries.Amount,'124');
                           UNTIL VATEntries.NEXT = 0;
                        END;
                        */

                        OnBeforeInsUNTForSalesCrMemoHeader(SalesCrMemoHeader);

                        Ins_UNT();
                        Ins_UNZ();

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

        CDES := ':';
        DES := '+';
        DN := '.';
        RC := '?';
        ST := '''';
    end;

    trigger OnPreReport()
    begin
        Separator[1] := 9;
    end;

    var
        CompanyInfo: Record "Company Information";
        //Country: Record "Country/Region";
        Currency: Record Currency;
        //Cust: Record Customer;
        //CustInvoice: Record Customer;
        //EDIExtractDoc: Record "EOS074 EDI Message Document";
        EDIGroup: Record "EOS074 EDI Group";
        EDIHeader: Record "EOS074 EDI Message Header";
        EDILine: Record "EOS074 EDI Message Line";
        EDIMapping: Record "EOS074 EDI Mapping";
        GLSetup: Record "General Ledger Setup";
        //Item: Record Item;
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesHeader: Record "Sales Header";
        SalesInvLine: Record "Sales Invoice Line";
        SalesShiptHeader: Record "Sales Shipment Header";
        //SalesShiptLine: Record "Sales Shipment Line";
        //Shipto: Record "Ship-to Address";
        TempVatAmountLine: Record "VAT Amount Line" temporary;
        EDIMgt: Codeunit "EOS074 EDI Management";
        ProgressBar: Dialog;
        //CreateEDIHeader: Boolean;
        EDILineNo: Integer;
        //ExtDocType: Integer;
        //Lenght: Integer;
        LineNo: Integer;
        NumberOfSegments: Integer;
        EDIDocType: enum "EOS074 EDI Document Type";
        CDES: Text[1];
        DES: Text[1];
        DN: Text[1];
        EDIComponent: Text[1024];
        RC: Text[1];
        Separator: Text[1];
        ST: Text[1];
        //VatNo: Text[30];
        //Text1038: Label '%1 shall not be blank!';
        //Text1039: Label 'EAN-Code is missing or incomplete in Invoice %1, Item %2.';
        //Text1040: Label 'EAN-Code is missing or incomplete in Cr. Memo %1, Item %2.';
        //Text1044: Label 'Lenght of Record %1 excedeed  %2 characters. Field %3.\ %4 characters.';
        //Text1050: Label 'Verify Invoice Discount in %1! ';
        EdiGroupLbl: Label 'EDI - Group #1########\';
        TableLbl: Label 'Table      #2########\';
        DocNoLbl: Label 'Document No. #3########';
        NotBlankErr: Label '%1 shall not be blank!';

    procedure InitEDILine()
    begin
        EDILineNo := EDILineNo + 10000;

        EDILine.Init();
        EDILine."Message Type" := EDIHeader."Message Type";
        EDILine."Message No." := EDIHeader."No.";
        EDILine."Line No." := EDILineNo;
    end;

    procedure InsertEDILine()
    begin
        UpdateEDILine(true);
        EDILine.Insert();
    end;

    procedure UpdateEDILine(Terminator: Boolean)
    var
        LengthF1: Integer;
        LengthF2: Integer;
        LengthF3: Integer;
        RemLength: Integer;
        TextLength: Integer;
        TextValue: Text[1024];
    begin
        if Terminator then
            TextValue := ST
        else begin
            EDIComponent := CopyStr(CopyStr(EDIComponent, 2), 1, MaxStrLen(EDIComponent));
            if EDILine."No. of Fields" > 0 then
                TextValue := CopyStr(DES + EDIComponent, 1, MaxStrLen(TextValue))
            else
                TextValue := EDIComponent;
        end;

        EDIComponent := '';

        LengthF1 := StrLen(EDILine."Field 1");
        LengthF2 := StrLen(EDILine."Field 2");
        LengthF3 := StrLen(EDILine."Field 3");
        TextLength := StrLen(TextValue);

        RemLength := MAXSTRLEN(EDILine."Field 1") - LengthF1;
        if RemLength > 0 then begin
            EDILine."Field 1" := EDILine."Field 1" + CopyStr(TextValue, 1, MinValue(RemLength, TextLength));
            if TextLength > RemLength then begin
                TextValue := CopyStr(CopyStr(TextValue, MinValue(RemLength, TextLength) + 1), 1, MaxStrLen(TextValue));
                TextLength := StrLen(TextValue);
            end else
                TextLength := 0;
        end;

        RemLength := MAXSTRLEN(EDILine."Field 2") - LengthF2;
        if (RemLength > 0) and (TextLength > 0) then begin
            EDILine."Field 2" := EDILine."Field 2" + CopyStr(TextValue, 1, MinValue(RemLength, TextLength));
            if TextLength > RemLength then begin
                TextValue := CopyStr(CopyStr(TextValue, MinValue(RemLength, TextLength) + 1), 1, MaxStrLen(TextValue));
                TextLength := StrLen(TextValue);
            end else
                TextLength := 0;
        end;

        RemLength := MAXSTRLEN(EDILine."Field 3") - LengthF3;
        if (RemLength > 0) and (TextLength > 0) then begin
            EDILine."Field 3" := EDILine."Field 3" + CopyStr(TextValue, 1, MinValue(RemLength, TextLength));
            if TextLength > RemLength then begin
                TextValue := CopyStr(CopyStr(TextValue, MinValue(RemLength, TextLength) + 1), 1, MaxStrLen(TextValue));
                TextLength := StrLen(TextValue);
            end else
                TextLength := 0;
        end;

        if TextLength > 0 then
            Error('Troppi caratteri');

        EDILine."No. of Fields" := EDILine."No. of Fields" + 1;
    end;

    procedure UpdateEDIComp(FieldName: Text[100]; TextValue: Text[1024]; MandatoryField: Boolean; MaxLength: Integer)
    begin
        if MandatoryField and (TextValue = '') then
            Error(NotBlankErr, FieldName);
        TextValue := CopyStr(CopyStr(TextValue, 1, MaxLength), 1, MaxStrLen(TextValue));
        EDIComponent := CopyStr(EDIComponent + CDES + TextValue, 1, MaxStrLen(EDIComponent));
    end;

    local procedure FormatDate(DateValue: Date; WithCentury: Boolean): Text[30]
    begin
        if WithCentury then
            exit(Format(DateValue, 0, '<Year4><Month,2><Day,2>'))
        else
            exit(Format(DateValue, 0, '<Year><Month,2><Day,2>'));
    end;

    local procedure FormatTime(TimeValue: Time): Text[30]
    begin
        exit(Format(TimeValue, 0, '<Hours24,2><Filler Character,0><Minutes,2>'));
    end;

    local procedure FormatInt(IntValue: Integer): Text[30]
    begin
        exit(Format(IntValue, 0, '<Integer>'));
    end;

    local procedure FormatDec(DecValue: Decimal; DecPlace: Integer): Text[30]
    var
        TxtValue: Text[30];
    begin
        TxtValue := Format(DecValue, 0, '<Precision,' + Format(DecPlace) + '><Integer><Decimals>');
        TxtValue := ConvertStr(TxtValue, ',', '.');
        exit(TxtValue);
    end;

    local procedure MinValue(Value1: Integer; Value2: Integer): Integer
    begin
        if Value1 < Value2 then
            exit(Value1)
        else
            exit(Value2);
    end;

    local procedure Ins_UNA()
    begin
        CDES := ':';
        DES := '+';
        DN := '.';
        RC := '?';
        ST := '''';

        Clear(EDILine);

        InitEDILine();

        EDILine."Record Type" := 'UNA';

        UpdateEDIComp('Segment', 'UNA' + CDES + DES + DN + RC + ' ', true, 8);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_UNB()
    var
        EDIGrp: Record "EOS074 EDI Group";
    begin
        EDIGrp.Get(EDIHeader."EDI Group Code");

        EDIGrp.TestField("Interchange Code");
        EDIGrp.TestField("Interchange Qualifier");
        EDIGrp.TestField("Interchange Partner Code");
        EDIGrp.TestField("Interchange Partner Qualifier");

        InitEDILine();

        EDILine."Record Type" := 'UNB';

        UpdateEDIComp('Segment', 'UNB', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('UNB.0001', 'UNOC', true, 4);
        UpdateEDIComp('UNB.0002', '3', true, 1);
        UpdateEDILine(false);

        UpdateEDIComp('UNB.0004', EDIGrp."Interchange Code", true, 35);
        UpdateEDIComp('UNB.0007', EDIGrp."Interchange Qualifier", true, 4);
        UpdateEDILine(false);

        UpdateEDIComp('UNB.0010', EDIGrp."Interchange Partner Code", true, 35);
        UpdateEDIComp('UNB.0007', EDIGrp."Interchange Partner Qualifier", true, 4);
        UpdateEDILine(false);

        UpdateEDIComp('UNB.0017', FormatDate(TODAY, false), true, 6);
        UpdateEDIComp('UNB.0019', FormatTime(Time), true, 4);
        UpdateEDILine(false);

        UpdateEDIComp('UNB.0020', EDIHeader."No.", true, 14);
        UpdateEDILine(false);

        if EDIHeader."Test Stage" then begin
            UpdateEDIComp('UNB.0035', '1', false, 1);
            UpdateEDILine(false);
        end;

        InsertEDILine();
    end;

    procedure Ins_UNH()
    begin
        NumberOfSegments := 1;

        InitEDILine();

        EDILine."Record Type" := 'UNH';

        UpdateEDIComp('Segment', 'UNH', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('UNH.0062', EDIHeader."No.", true, 14);
        UpdateEDILine(false);

        UpdateEDIComp('UNH.0065', 'INVOIC', true, 6);
        UpdateEDIComp('UNH.0052', 'D', true, 3);
        UpdateEDIComp('UNH.0054', '96A', true, 3);
        UpdateEDIComp('UNH.0051', 'UN', true, 2);
        UpdateEDIComp('UNH.0057', 'EAN009', true, 6);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    procedure Ins_BGM(EdiDocTypeP: enum "EOS074 EDI Document Type")
    var
        DocNo: Code[20];
        DocType: Text[3];
    begin
        NumberOfSegments := NumberOfSegments + 1;

        InitEDILine();
        EDILine."Record Type" := 'BGM';

        case EdiDocTypeP of
            EDIDocType::"Sales Invoice":
                begin
                    DocType := '380';
                    DocNo := SalesInvHeader."No.";
                end;
            EDIDocType::"Sales Cr.Memo":
                begin
                    DocType := '381';
                    DocNo := SalesCrMemoHeader."No.";
                end;
        end;

        UpdateEDIComp('Segment', 'BGM', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('BGM.1001', DocType, true, 3);
        //UpdateEDIComp('BGM.1031', '',FALSE,17);
        //UpdateEDIComp('BGM.3055', '',FALSE,3);
        //UpdateEDIComp('BGM.1000', 'Rechnung',TRUE,35);
        UpdateEDILine(false);

        UpdateEDIComp('BGM.1004', DocNo, true, 30);
        UpdateEDILine(false);

        UpdateEDIComp('BGM.1225', '9', true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;


    procedure Ins_DTM(DateValue: Date; Qualifier: Text[30]; FormatQualifier: Text[30])
    begin
        NumberOfSegments := NumberOfSegments + 1;

        InitEDILine();
        EDILine."Record Type" := 'DTM';

        UpdateEDIComp('Segment', 'DTM', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('DTM.2005', Qualifier, true, 3);
        UpdateEDIComp('DTM.2380', FormatDate(DateValue, true), true, 35);
        UpdateEDIComp('DTM.2379', FormatQualifier, true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;


    procedure Ins_FTX_ZZZ()
    var
    //Cust: Record Customer;
    //County: Integer;
    begin
        NumberOfSegments := NumberOfSegments + 1;

        InitEDILine();

        EDILine."Record Type" := 'FTX';
        UpdateEDIComp('Segment', 'FTX', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('FTX.4451', 'ZZZ', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('FTX.4453', '1', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('FTX.4441', 'EEV', true, 3);
        UpdateEDILine(false);


        InsertEDILine();
    end;

    local procedure Ins_FTX()
    var
        //VatIdentifier: Record "VAT Identifier";
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        TempVatAmountLine.Reset();
        TempVatAmountLine.SetRange(Positive, true);
        TempVatAmountLine.SetRange("VAT %", 0);
        if TempVatAmountLine.FindSet() then
            repeat
                VatPostingSetup.Reset();
                VatPostingSetup.SetRange("VAT Bus. Posting Group", SalesInvHeader."VAT Bus. Posting Group");
                VatPostingSetup.SetRange("VAT Identifier", TempVatAmountLine."VAT Identifier");
                VatPostingSetup.SetFilter("Sales VAT Account", '<>%1', '');
                if not VatPostingSetup.IsEmpty() then begin

                    NumberOfSegments := NumberOfSegments + 1;

                    InitEDILine();
                    EDILine."Record Type" := 'FTX';

                    UpdateEDIComp('Segment', 'FTX', true, 3);
                    UpdateEDILine(false);

                    UpdateEDIComp('FTX.4451', 'REG', true, 3);
                    UpdateEDILine(false);

                    UpdateEDIComp('FTX.4453', '1', true, 3);
                    UpdateEDILine(false);

                    UpdateEDIComp('FTX.4441', 'IGL', true, 3);
                    UpdateEDILine(false);

                    OnBeforeInsertEDILineForInsFTX(TempVatAmountLine);

                    InsertEDILine();
                end;

            until TempVatAmountLine.Next() = 0;
    end;

    local procedure Ins_RFFDTM()
    var
        SlsHeader: Record "Sales Header";
        SlsInvLine: Record "Sales Invoice Line";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesShptLine: Record "Sales Shipment Line";
        TempSalesHeader: Record "Sales Header" temporary;
        TempSalesShptHeader: Record "Sales Shipment Header" temporary;
    begin
        if SalesInvHeader."Order No." <> '' then
            if SlsHeader.Get(SlsHeader."Document Type"::Order, SalesInvHeader."Order No.") then begin
                if not TempSalesHeader.Get(SlsHeader."Document Type", SlsHeader."No.") then begin
                    TempSalesHeader.Init();
                    TempSalesHeader := SlsHeader;
                    TempSalesHeader.Insert();
                end;

                if SlsHeader."Last Shipping No." <> '' then
                    if not TempSalesShptHeader.Get(SlsHeader."Last Shipping No.") then begin
                        SalesShptHeader.Get(SlsHeader."Last Shipping No.");
                        TempSalesShptHeader.Init();
                        TempSalesShptHeader."No." := SalesShptHeader."No.";
                        TempSalesShptHeader."Posting Date" := SalesShptHeader."Posting Date";
                        TempSalesShptHeader.Insert();
                    end;
            end;

        SlsInvLine.Reset();
        SlsInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SlsInvLine.FindSet() then
            repeat
                if not SalesShptLine.Get(SlsInvLine."Shipment No.", SlsInvLine."Shipment Line No.") then
                    Clear(SalesShptLine);
                if SlsInvLine."Shipment No." <> '' then
                    if not TempSalesShptHeader.Get(SlsInvLine."Shipment No.") then begin
                        SalesShptHeader.Get(SlsInvLine."Shipment No.");
                        TempSalesShptHeader.Init();
                        TempSalesShptHeader."No." := SalesShptHeader."No.";
                        TempSalesShptHeader."Posting Date" := SalesShptHeader."Posting Date";
                        TempSalesShptHeader.Insert();
                    end;

                if SalesShptLine."Order No." <> '' then
                    if SlsHeader.Get(SlsHeader."Document Type"::Order, SalesShptLine."Order No.") then
                        if not TempSalesHeader.Get(SlsHeader."Document Type", SlsHeader."No.") then begin
                            TempSalesHeader.Init();
                            TempSalesHeader := SlsHeader;
                            TempSalesHeader.Insert();
                        end;
            until SlsInvLine.Next() = 0;

        TempSalesShptHeader.Reset();
        if TempSalesShptHeader.FindSet() then
            repeat
                NumberOfSegments := NumberOfSegments + 1;
                InitEDILine();
                EDILine."Record Type" := 'RFF';

                UpdateEDIComp('Segment', 'RFF', true, 3);
                UpdateEDILine(false);

                UpdateEDIComp('RFF-DTM.1153', 'DQ', true, 3);
                UpdateEDIComp('RFF-DTM.1154', TempSalesShptHeader."No.", true, 35);
                UpdateEDILine(false);

                InsertEDILine();

                if TempSalesShptHeader."Posting Date" <> 0D then
                    Ins_DTM(TempSalesShptHeader."Posting Date", '171', '102');
            until TempSalesShptHeader.Next() = 0;

        TempSalesHeader.Reset();
        if TempSalesHeader.FindSet() then
            repeat
                if TempSalesHeader."External Document No." <> '' then begin
                    NumberOfSegments := NumberOfSegments + 1;
                    InitEDILine();
                    EDILine."Record Type" := 'RFF';

                    UpdateEDIComp('Segment', 'RFF', true, 3);
                    UpdateEDILine(false);

                    UpdateEDIComp('RFF-DTM.1153', 'ON', true, 3);
                    UpdateEDIComp('RFF-DTM.1154', TempSalesHeader."External Document No.", true, 35);
                    UpdateEDILine(false);

                    InsertEDILine();

                    if TempSalesHeader."Order Date" <> 0D then
                        Ins_DTM(TempSalesHeader."Order Date", '171', '102');

                    NumberOfSegments := NumberOfSegments + 1;
                    InitEDILine();
                    EDILine."Record Type" := 'RFF';

                    UpdateEDIComp('Segment', 'RFF', true, 3);
                    UpdateEDILine(false);

                    UpdateEDIComp('RFF-DTM.1153', 'VN', true, 3);
                    UpdateEDIComp('RFF-DTM.1154', TempSalesHeader."No.", true, 35);
                    UpdateEDILine(false);

                    InsertEDILine();

                    if TempSalesHeader."Order Date" <> 0D then
                        Ins_DTM(TempSalesHeader."Order Date", '171', '102');

                end;
            until TempSalesHeader.Next() = 0;
    end;


    procedure Ins_NAD(BillToCode: Code[20]; SellToCode: Code[20])
    var
        Cust: Record Customer;
        EDIValues: Record "EOS074 EDI Values";
        //County: Integer;
        MaxLenght: Text[20];
    begin
        // ------------------------------------------
        // Buyer
        // ------------------------------------------
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'NAD';
        UpdateEDIComp('Segment', 'NAD', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('NAD.3035', 'BY', true, 3);
        UpdateEDILine(false);

        Cust.Get(BillToCode);
        EDIValues.Reset();
        EDIValues.FilterByRecord(Cust);
        if EDIValues.FindFirst() then
            if EDIValues."EDI Identifier" <> '' then
                UpdateEDIComp('NAD.3039', EDIValues."EDI Identifier", true, 35);

        UpdateEDIComp('NAD.1131', '', false, 3);
        UpdateEDIComp('NAD.3055', '9', true, 3);
        UpdateEDILine(false);

        /*
        UpdateLineEDI(FALSE);
        
        UpdateCompEDI('NAD.3036',
          COPYSTR(SalesInvHeader."Bill-to Name" + ' ' + SalesInvHeader."Bill-to Name 2",1,35),
          TRUE,35);
        IF STRLEN(SalesInvHeader."Bill-to Name" + ' ' + SalesInvHeader."Bill-to Name 2") > 35 THEN
          UpdateCompEDI('NAD.3036',
            COPYSTR(SalesInvHeader."Bill-to Name" + ' ' + SalesInvHeader."Bill-to Name 2",36,35),
            FALSE,35);
        UpdateLineEDI(FALSE);
        
        UpdateCompEDI('NAD.3042',
          COPYSTR(SalesInvHeader."Bill-to Address" + ' ' + SalesInvHeader."Bill-to Address 2",1,35),
          TRUE,35);
        IF STRLEN(SalesInvHeader."Bill-to Address" + ' ' + SalesInvHeader."Bill-to Address 2") > 35 THEN
          UpdateCompEDI('NAD.3042',
            COPYSTR(SalesInvHeader."Bill-to Address" + ' ' + SalesInvHeader."Bill-to Address 2",36,35),
            FALSE,35);
        UpdateLineEDI(FALSE);
        
        UpdateCompEDI('NAD.3164',SalesInvHeader."Bill-to City",FALSE,35);
        UpdateLineEDI(FALSE);
        
        UpdateLineEDI(FALSE);
        
        UpdateCompEDI('NAD.3251',SalesInvHeader."Bill-to Post Code",FALSE,9);
        UpdateLineEDI(FALSE);
        
        UpdateCompEDI('NAD.3207',SalesInvHeader."Bill-to Country/Region Code",FALSE,3);
        UpdateLineEDI(FALSE);        
        */

        InsertEDILine();

        if CopyStr(Cust."VAT Registration No.", 1, 2) = Cust."Country/Region Code" then
            Ins_RFF(Cust."VAT Registration No.", '', 'VA')
        else
            Ins_RFF(CopyStr(Cust."Country/Region Code" + Cust."VAT Registration No.", 1, MaxStrLen(MaxLenght)), '', 'VA');

        // ------------------------------------------
        // Supplier
        // ------------------------------------------
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'NAD';

        UpdateEDIComp('Segment', 'NAD', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('NAD.3035', 'SU', true, 3);
        UpdateEDILine(false);

        EDIGroup.Get(EDIHeader."EDI Group Code");
        EDIGroup.TestField("Interchange Code");
        UpdateEDIComp('NAD.3039', EDIGroup."Interchange Code", true, 35);
        UpdateEDIComp('NAD.1131', '', false, 3);
        UpdateEDIComp('NAD.3055', '9', true, 3);
        UpdateEDILine(false);

        InsertEDILine();

        if CopyStr(CompanyInfo."VAT Registration No.", 1, 2) = CompanyInfo."Country/Region Code" then
            Ins_RFF(CompanyInfo."VAT Registration No.", '', 'VA')
        else
            Ins_RFF(CopyStr(CompanyInfo."Country/Region Code" + CompanyInfo."VAT Registration No.", 1, MaxStrLen(MaxLenght)), '', 'VA');

        // --------------------------------------------
        // Delivery address
        // --------------------------------------------
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'NAD';

        UpdateEDIComp('Segment', 'NAD', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('NAD.3035', 'DP', true, 3);
        UpdateEDILine(false);


        Cust.Get(SellToCode);

        EDIValues.Reset();
        EDIValues.FilterByRecord(Cust);
        if EDIValues.FindFirst() then
            if EDIValues."EDI Identifier" <> '' then
                UpdateEDIComp('NAD.3039', EDIValues."EDI Identifier", true, 35);

        UpdateEDIComp('NAD.1131', '', false, 3);
        UpdateEDIComp('NAD.3055', '9', true, 3);
        UpdateEDILine(false);

        InsertEDILine();

        if CopyStr(Cust."VAT Registration No.", 1, 2) = Cust."Country/Region Code" then
            Ins_RFF(Cust."VAT Registration No.", '', 'VA')
        else
            Ins_RFF(CopyStr(Cust."Country/Region Code" + Cust."VAT Registration No.", 1, MaxStrLen(MaxLenght)), '', 'VA');

    end;


    procedure Ins_RFF(ReferenceNo: Code[20]; ReferenceNo2: Code[20]; Qualifier: Text[30])
    begin
        NumberOfSegments := NumberOfSegments + 1;

        InitEDILine();

        EDILine."Record Type" := 'RFF';
        UpdateEDIComp('Segment', 'RFF', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('RFF.1153', Qualifier, true, 3);
        UpdateEDIComp('RFF.1154', ReferenceNo, true, 20);
        if ReferenceNo2 <> '' then
            UpdateEDIComp('RFF.1156', ReferenceNo2, true, 20);
        UpdateEDILine(false);

        InsertEDILine();
    end;


    procedure Ins_CUX(CurrencyCode: Code[10])
    var
        CurrencyISOCode: Code[10];
    begin
        NumberOfSegments := NumberOfSegments + 1;

        InitEDILine();

        EDILine."Record Type" := 'CUX';
        UpdateEDIComp('Segment', 'CUX', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('CUX.6347', '2', true, 3);

        if CurrencyCode = '' then begin
            GLSetup.Get();
            CurrencyCode := GLSetup."LCY Code";
        end;
        // use ISO field on Currency?
        CurrencyISOCode := CurrencyCode;

        UpdateEDIComp('CUX.6345', CurrencyISOCode, true, 3);
        UpdateEDIComp('CUX.6343', '4', true, 3);

        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_LIN(ItemNo: Code[20]; SellToCust: Code[20])
    var
        ItemReference: Record "Item Reference";
    begin
        NumberOfSegments := NumberOfSegments + 1;
        LineNo := LineNo + 1;
        InitEDILine();
        EDILine."Record Type" := 'LIN';

        UpdateEDIComp('Segment', 'LIN', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('LIN.1082', FormatInt(LineNo), true, 6);
        UpdateEDILine(false);

        UpdateEDILine(false);

        ItemReference.Reset();
        ItemReference.SetRange("Item No.", ItemNo);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference Type No.", '');
        if not ItemReference.FindFirst() then begin
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Customer);
            ItemReference.SetRange("Reference Type No.", SellToCust);
            if not ItemReference.FindFirst() then
                Clear(ItemReference);
        end;

        if ItemReference."Reference No." = '' then
            ItemReference."Reference No." := ItemNo;

        UpdateEDIComp('LIN.7140', ItemReference."Reference No.", true, 35);
        UpdateEDIComp('LIN.7143', 'EN', true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    // local procedure Ins_PIA(ItemNo: Code[20]; CrossReferenceNo: Code[20]; Qualifier: Text[30]; ResponsibleAgency: Code[3])
    // begin
    //     NumberOfSegments := NumberOfSegments + 1;
    //     InitEDILine();
    //     EDILine."Record Type" := 'PIA';

    //     UpdateEDIComp('Segment', 'PIA', true, 3);
    //     UpdateEDILine(false);

    //     UpdateEDIComp('PIA.4347', '5', true, 3);
    //     UpdateEDILine(false);

    //     if CrossReferenceNo <> '' then
    //         UpdateEDIComp('PIA.7140', CrossReferenceNo, true, 35)
    //     else begin
    //         EDIMapping.Reset();
    //         EDIMapping.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
    //         EDIMapping.SetRange(Type, EDIMapping.Type::Item);
    //         EDIMapping.SetRange("NAV-Code", ItemNo);
    //         EDIMapping.FindFirst();
    //         UpdateEDIComp('PIA.7140', EDIMapping."External Code", true, 35);
    //     end;

    //     UpdateEDIComp('PIA.7143', Qualifier, true, 3);
    //     // Start RI-TDAG01318-002/sdi
    //     UpdateEDIComp('PIA.1131', '', false, 17);
    //     // Stop RI-TDAG01318-002/sdi
    //     UpdateEDIComp('PIA.3055', ResponsibleAgency, true, 3);
    //     UpdateEDILine(false);

    //     InsertEDILine();
    // end;

    local procedure Ins_IMD(Description: Text[50]; Description2: Text[50])
    var
        Descr: Text[1024];
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'IMD';

        UpdateEDIComp('Segment', 'IMD', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('IMD.7077', 'F', true, 3);
        UpdateEDILine(false);

        UpdateEDILine(false);

        UpdateEDIComp('IMD.7009', '', false, 17);
        UpdateEDIComp('IMD.1131', '', false, 17);
        UpdateEDIComp('IMD.3055', '', false, 3);

        Descr := Description;
        if Description2 <> '' then
            Descr := CopyStr(Descr + ' ' + Description2, 1, MaxStrLen(Descr));

        Descr := ConvertStr(Descr, '''', ' ');

        UpdateEDIComp('IMD.7008', Descr, true, 35);
        if StrLen(Descr) > 35 then
            UpdateEDIComp('IMD.7008', CopyStr(CopyStr(Descr, 36), 1, MaxStrLen(Descr)), true, 35);

        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_QTY(Qty: Decimal; UOM: Code[20]; UOMCrossRef: Code[20])
    var
        UOMCode: Code[20];
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'QTY';

        UpdateEDIComp('Segment', 'QTY', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('QTY.6063', '47', true, 3);
        UpdateEDIComp('QTY.6060', FormatDec(Qty, 3), true, 15);

        UOMCode := UOMCrossRef;
        if UOMCode = '' then
            UOMCode := UOM;

        EDIMapping.Reset();
        EDIMapping.SetRange("EDI Group Code", EDIHeader."EDI Group Code");
        EDIMapping.SetRange(Type, EDIMapping.Type::"Unit Of Measure");
        EDIMapping.SetRange("NAV-Code", UOMCode);
        EDIMapping.FindFirst();
        if EDIMapping.FindFirst() then
            UpdateEDIComp('QTY.6411', EDIMapping."External Code", true, 3)
        else
            UpdateEDIComp('QTY.6411', UOMCode, true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_PRI(UnitPrice: Decimal; Qty: Decimal; LineAmount: Decimal; Identifier: Code[3])
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'PRI';
        UpdateEDIComp('Segment', 'PRI', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('PRI.5125', Identifier, true, 3);
        if Identifier = 'AAA' then
            UpdateEDIComp(
              'PRI.5118',
              FormatDec(
                Round(
                  (LineAmount / Qty),
                  Currency."Unit-Amount Rounding Precision"), 4),
              true, 15)
        else
            UpdateEDIComp(
              'PRI.5118',
              FormatDec(
                Round(
                  (UnitPrice),
                  Currency."Unit-Amount Rounding Precision"), 4),
              true, 15);

        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_MOA(Amount: Decimal; Qualifier: Text[30])
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'MOA';

        UpdateEDIComp('Segment', 'MOA', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('MOA.5025', Qualifier, true, 3);
        UpdateEDIComp('MOA.5004', FormatDec(Amount, 2), true, 35);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_TAX(TaxCode: Code[10]; Qualifier: Text[30]; Qualifier2: Text[30]/*; Qualifier3: Text[30]*/)
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'TAX';

        UpdateEDIComp('Segment', 'TAX', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('TAX.5283', Qualifier, true, 1);
        UpdateEDILine(false);

        UpdateEDIComp('TAX.5183', Qualifier2, true, 3);
        UpdateEDILine(false);
        UpdateEDILine(false);
        UpdateEDILine(false);

        UpdateEDIComp('TAX.5278', '', false, 7);
        UpdateEDIComp('TAX.5278', '', false, 3);
        UpdateEDIComp('TAX.5278', '', false, 3);
        UpdateEDIComp('TAX.5278', TaxCode, true, 15);
        UpdateEDILine(false);

        //UpdateEDIComp('TAX.5305',Qualifier3,TRUE,3);
        //UpdateEDILine(FALSE);

        InsertEDILine();
    end;


    procedure Ins_UNS()
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'UNS';

        UpdateEDIComp('Segment', 'UNS', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('UNS.0081', 'S', true, 1);
        UpdateEDILine(false);

        InsertEDILine();
    end;


    procedure Ins_UNT()
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'UNT';

        UpdateEDIComp('Segment', 'UNT', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('UNT.0074', FormatInt(NumberOfSegments), true, 6);
        UpdateEDILine(false);

        UpdateEDIComp('UNT.0062', EDIHeader."No.", true, 14);
        UpdateEDILine(false);

        InsertEDILine();
    end;


    procedure Ins_UNZ()
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'UNZ';

        UpdateEDIComp('Segment', 'UNZ', true, 3);
        UpdateEDILine(false);


        UpdateEDIComp('UNZ.0036', '1', true, 6);
        UpdateEDILine(false);

        UpdateEDIComp('UNZ.0020', EDIHeader."No.", true, 14);
        UpdateEDILine(false);


        InsertEDILine();
    end;


    procedure __PVC__()
    begin
    end;

    local procedure Ins_ALC(Index: Integer; Qualifier: Text[30]; Service: Text[30])
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'ALC';

        UpdateEDIComp('Segment', 'ALC', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('ALC.5463', Qualifier, true, 3);
        UpdateEDILine(false);
        UpdateEDILine(false);
        UpdateEDILine(false);

        if (Index <> 0) then
            UpdateEDIComp('ALC.1227', Format(Index), true, 3);

        UpdateEDILine(false);
        UpdateEDIComp('ALC.7161', Service, true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_PCD(Amount: Decimal; Qualifier: Text[30])
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'PCD';

        UpdateEDIComp('Segment', 'PCD', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('PCD.5245', Qualifier, true, 3);
        UpdateEDIComp('PCD.5482', FormatDec(Amount, 2), true, 35);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    /// <summary>
    /// Execute before insert EDI line in Ins_FTX function
    /// If you want to add values or methods
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertEDILineForInsFTX(TempVatAmountLine: Record "VAT Amount Line" temporary)
    begin
    end;

    /// <summary>
    /// Execute before run Ins_UNT for Sales Invoice Header
    /// If you want to add values or methods
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsUNTForSalesInvoiceHeader(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
    end;

    /// <summary>
    /// Execute before run Ins_UNT for Sales Cr. Memo Header
    /// If you want to add values or methods
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsUNTForSalesCrMemoHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
    end;
}
