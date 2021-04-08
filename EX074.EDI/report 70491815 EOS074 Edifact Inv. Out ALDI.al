report 70491815 "EOS074 Edifact Inv. Out ALDI"
{
    Caption = 'EDI Edifact Eancom Invoice Out Aldi';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(EDIMessageSetup; "EOS074 EDI Message Setup")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Message Type", "EDI Group Code", "Date Filter", "Document No. Filter";

            dataitem(EDIGroup1; "EOS074 EDI Group")
            {
                DataItemLink = "Code" = field("EDI Group Code");

                dataitem(SalesInvHeader; "Sales Invoice Header")
                {
                    // DataItemLink = "EDI Group Code" = field("EDI Group Code");
                    // DataItemTableView = sorting ("EDI Group Code", "Bill-to Customer No.", "Posting Date");

                    DataItemTableView = sorting("Bill-to Customer No.", "Posting Date");

                    RequestFilterFields = "Posting Date";

                    trigger OnAfterGetRecord()
                    var
                        CountryRegion: Record "Country/Region";
                        //SalesInvLine: Record "Sales Invoice Line";
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

                        if SalesInvHeader."Currency Code" = '' then
                            Currency.InitRoundingPrecision()
                        else begin
                            SalesInvHeader.TestField("Currency Factor");
                            Currency.Get(SalesInvHeader."Currency Code");
                            Currency.TestField("Amount Rounding Precision");
                        end;

                        Ins_UNA();
                        // ORG: Ins_UNB();
                        Ins_UNB("Bill-to Country/Region Code");
                        Ins_UNH();
                        Ins_BGM(EDIDocType::"Sales Invoice");
                        Ins_DTM("Document Date", '137');
                        Ins_DTM("Posting Date", '454');
                        Ins_DTM(TODAY, '35');
                        // FTX not required if DTM 35 is insert

                        /*
                        IF ("Bill-to Country/Region Code" = 'DE') OR
                        ("Bill-to Country/Region Code" = 'AT') THEN
                        */

                        if CountryRegion.Get("Bill-to Country/Region Code") then;
                        if CountryRegion."Intrastat Code" <> '' then
                            Ins_FTX('REG', 'IGL', '246', '');
                        //Ins_FTX('AAI','','','Supply Date is equals Invoice Date');


                        //         EDIGroup.TestField("EDI Contract");
                        //         Ins_RFF(EDIGroup."EDI Contract", '', 'CT');
                        //         if EDIGroup."EDI Contract Date" <> 0D then
                        //             Ins_DTM(EDIGroup."EDI Contract Date", '171');

                        // ORG: Ins_NAD("Bill-to Customer No.");
                        Ins_NAD("Bill-to Customer No.", "Ship-to Country/Region Code");
                        Ins_CUX("Currency Code");

                        SalesInvLine.Reset();
                        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                        SalesInvLine.SetRange(SalesInvLine.Type, SalesInvLine.Type::Item);
                        LineNo := 0;
                        if SalesInvLine.FindSet() then
                            repeat
                                Ins_LIN();
                                //Ins_PIA(SalesInvLine."No.", SalesInvLine."Cross-Reference No.",'IN');
                                Ins_PIA(SalesInvLine."No.", SalesInvLine."Cross-Reference No.", 'IN', SalesInvHeader."Sell-to Customer No.");
                                Ins_IMD(CopyStr(SalesInvLine.Description, 1, MaxStrLen(MaxLenght)), SalesInvLine."Description 2");

                                // ORG: Ins_QTY(SalesInvLine.Quantity, SalesInvLine."Unit of Measure Code", SalesInvLine."Unit of Measure (Cross Ref.)");
                                Ins_QTY(SalesInvLine.Quantity, SalesInvLine."Unit of Measure Code", SalesInvLine."Unit of Measure (Cross Ref.)",
                                        SalesInvLine."Cross-Reference No.");
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
                                */
                                if SalesHeader.Get(SalesHeader."Document Type"::Order, "Order No.") then;
                                //Ins_RFF(SalesHeader."Your Reference",'','ON');
                                // ORG. Ins_RFF(SalesHeader."External Document No.",'','ON');
                                Ins_RFF(GetExternalOrderNo(SalesHeader."External Document No."), '', 'ON');
                                Ins_DTM(SalesHeader."Order Date", '171');

                                /*
                                Ins_RFF(SalesShiptHeader."No.",'','DQ');
                                Ins_DTM(SalesShiptHeader."Posting Date",'171');
                                */
                                Ins_TAX(CopyStr(FormatDec(SalesInvLine."VAT %", 2), 1, MaxStrLen(MaxLenght2)), '7', 'VAT'/*, 'S'*/);

                            until SalesInvLine.Next() = 0;


                        Ins_UNS();
                        SalesInvHeader.CalcFields(Amount, "Amount Including VAT");

                        Ins_MOA(SalesInvHeader.Amount, '79');
                        Ins_MOA(SalesInvHeader."Amount Including VAT", '77');
                        Ins_MOA(SalesInvHeader."Amount Including VAT" - SalesInvHeader.Amount, '124');

                        /*
                        VATEntries.SETRANGE(VATEntries."Document No.",SalesInvHeader."No.");
                        IF VATEntries.FINDSET THEN BEGIN
                        REPEAT
                            Ins_TAX(FormatDec(VATEntries."VAT %",2),'7','VAT', '');
                            Ins_MOA(VATEntries.Base, '79');
                            Ins_MOA(VATEntries.Amount,'124');
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

            dataitem(EDIGroup2; "EOS074 EDI Group")
            {
                DataItemLink = "Code" = field("EDI Group Code");

                dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
                {
                    // DataItemLink = "EDI Group Code" = field("EDI Group Code");
                    // DataItemTableView = sorting("EDI Group Code", "Bill-to Customer No.", "Posting Date");

                    DataItemTableView = sorting("Bill-to Customer No.", "Posting Date");

                    RequestFilterFields = "Posting Date";

                    trigger OnAfterGetRecord()
                    var
                        CountryRegion: Record "Country/Region";
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
                        // ORG: Ins_UNB();
                        Ins_UNB("Bill-to Country/Region Code");
                        Ins_UNH();
                        Ins_BGM(EDIDocType::"Sales Invoice");
                        Ins_DTM("Document Date", '137');
                        Ins_DTM("Posting Date", '454');
                        Ins_DTM(TODAY, '35');
                        // FTX not required if DTM 35 is inserted
                        /*
                        IF ("Bill-to Country/Region Code" = 'DE') OR
                           ("Bill-to Country/Region Code" = 'AT') THEN
                        */

                        if CountryRegion.Get("Bill-to Country/Region Code") then;

                        if CountryRegion."Intrastat Code" <> '' then
                            Ins_FTX('REG', 'IGL', '', '246');
                        // ORG: Ins_FTX('AAI','','','Supply Date is equals Invoice Date');

                        // ORG: Ins_NAD("Bill-to Customer No.");
                        Ins_NAD("Bill-to Customer No.", "Ship-to Country/Region Code");
                        Ins_CUX("Currency Code");

                        SalesCrMemoLine.Reset();
                        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                        SalesCrMemoLine.SetRange(SalesCrMemoLine.Type, SalesCrMemoLine.Type::Item);
                        LineNo := 0;
                        if SalesCrMemoLine.FindSet() then
                            repeat
                                Ins_LIN();
                                // ORG: Ins_PIA(SalesCrMemoLine."No.", SalesCrMemoLine."Cross-Reference No.",'IN');
                                Ins_PIA(SalesCrMemoLine."No.", SalesCrMemoLine."Cross-Reference No.", 'IN', SalesCrMemoHeader."Sell-to Customer No.");
                                Ins_IMD(CopyStr(SalesCrMemoLine.Description, 1, MaxStrLen(MaxLenght)), SalesCrMemoLine."Description 2");
                                // ORG: Ins_QTY(SalesCrMemoLine.Quantity, SalesCrMemoLine."Unit of Measure Code", SalesCrMemoLine."Unit of Measure (Cross Ref.)");
                                Ins_QTY(SalesCrMemoLine.Quantity, SalesCrMemoLine."Unit of Measure Code", SalesCrMemoLine."Unit of Measure (Cross Ref.)",
                                        SalesCrMemoLine."Cross-Reference No.");
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
                                Ins_TAX(CopyStr(FormatDec(SalesCrMemoLine."VAT %", MaxStrLen(MaxLenght2)), 1, 10), '7', 'VAT'/*, 'S'*/);

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
                              Ins_MOA(VATEntries.Base, '79');
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
                    ProgressBar.OPEN(EDIGroupProgBarLbl + TableProgBarLbl + DocNoProgBarLbl);
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
        //TempVATAmountLine: Record "VAT Amount Line" temporary;
        //VATEntries: Record "VAT Entry";
        EDIMgt: Codeunit "EOS074 EDI Management";
        ProgressBar: Dialog;
        //CreateEDIHeader: Boolean;
        EDILineNo: Integer;
        //ExtDocType: Integer;
        //Lenght: Integer;
        LineNo: Integer;
        NumberOfSegments: Integer;
        EDIDocType: Enum "EOS074 EDI Document Type";
        CDES: Text[1];
        DES: Text[1];
        DN: Text[1];
        EDIComponent: Text[1024];
        RC: Text[1];
        //Separator: Text[1];
        ST: Text[1];
        //VatNo: Text[30];
        // Text1038: Label '%1 shall not be blank!';
        // Text1039: Label 'EAN-Code is missing or incomplete in Invoice %1, Item %2.';
        // Text1040: Label 'EAN-Code is missing or incomplete in Cr. Memo %1, Item %2.';
        // Text1044: Label 'Lenght of Record %1 excedeed  %2 characters. Field %3.\ %4 characters.';
        // Text1050: Label 'Verify Invoice Discount in %1! ';
        EDIGroupProgBarLbl: Label 'EDI - Group #1########\';
        TableProgBarLbl: Label 'Table      #2########\';
        DocNoProgBarLbl: Label 'Document No. #3########';
        NotDefinedOrdErr: Label 'Impossible to defined Original Order No from %1';
        CustItemIdErr: Label 'Item %1: Impossible to defined Customer Item identifier from %2';
        FieldBlankErr: Label '%1 shall not be blank!';

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
            Error(FieldBlankErr, FieldName);
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

    procedure FormatDec(DecValue: Decimal; DecPlace: Integer): Text[30]
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

    local procedure Ins_UNB(CountryCode: Code[10])
    var
        EDIGrp: Record "EOS074 EDI Group";
        MaxLenght: Text[50];
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

        if CountryCode in ['HU', 'SI'] then
            UpdateEDIComp('UNB.0001', 'UNOD', true, 4)
        else

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

        // ORG: UpdateEDIComp('UNB.0020',EDIHeader."No.",TRUE,14);
        UpdateEDIComp('UNB.0020', CopyStr(GetInterchangeRefCode(EDIHeader."No."), 1, MaxStrLen(MaxLenght)), true, 14);
        UpdateEDILine(false);

        if EDIHeader."Test Stage" then begin
            UpdateEDIComp('UNB.0035', '1', false, 1);
            UpdateEDILine(false);
        end;

        InsertEDILine();
    end;

    procedure Ins_UNH()
    var
        MaxLenght: Text[50];
    begin
        NumberOfSegments := 1;

        InitEDILine();

        EDILine."Record Type" := 'UNH';

        UpdateEDIComp('Segment', 'UNH', true, 3);
        UpdateEDILine(false);
        // ORG: UpdateEDIComp('UNH.0062', EDIHeader."No.",TRUE,14);
        UpdateEDIComp('UNH.0062', CopyStr(GetInterchangeRefCode(EDIHeader."No."), 1, MaxStrLen(MaxLenght)), true, 14);
        UpdateEDILine(false);

        UpdateEDIComp('UNH.0065', 'INVOIC', true, 6);
        UpdateEDIComp('UNH.0052', 'D', true, 3);
        UpdateEDIComp('UNH.0054', '01B', true, 3);
        UpdateEDIComp('UNH.0051', 'UN', true, 2);
        UpdateEDIComp('UNH.0057', 'EAN011', true, 6);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    procedure Ins_BGM(EdiDocTypeP: Enum "EOS074 EDI Document Type")
    var
        DocNo: Code[20];
        DocType: Text[3];
    begin
        NumberOfSegments := NumberOfSegments + 1;

        InitEDILine();

        EDILine."Record Type" := 'BGM';

        case EdiDocTypeP of
            EdiDocTypeP::"Sales Invoice":
                begin
                    DocType := '380';
                    DocNo := SalesInvHeader."No.";
                end;
            EdiDocTypeP::"Sales Cr.Memo":
                begin
                    DocType := '381';
                    DocNo := SalesCrMemoHeader."No.";
                end;
        end;

        UpdateEDIComp('Segment', 'BGM', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('BGM.1001', DocType, true, 3);
        UpdateEDIComp('BGM.1031', '', false, 17);
        UpdateEDIComp('BGM.3055', '', false, 3);
        UpdateEDIComp('BGM.1000', 'TAX INVOIC', true, 35);
        UpdateEDILine(false);

        UpdateEDIComp('BGM.1004', DocNo, true, 30);
        UpdateEDILine(false);

        // spp
        // if (EDIMessageSetup."Message Function Code" <> 0) then
        //     UpdateEDIComp('BGM.1225', Format(EDIMessageSetup."Message Function Code"), true, 3)
        // else
        UpdateEDIComp('BGM.1225', '9', true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    procedure Ins_DTM(DateValue: Date; Qualifier: Text[30])
    var
        TextValueL: Text[30];
    begin
        NumberOfSegments := NumberOfSegments + 1;

        InitEDILine();
        EDILine."Record Type" := 'DTM';

        UpdateEDIComp('Segment', 'DTM', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('DTM.2005', Qualifier, true, 3);
        // ORG: UpdateEDIComp('DTM.2380', FormatDate(DateValue,TRUE) ,TRUE,35);
        TextValueL := CopyStr(FormatDate(DateValue, true) + FormatTime(000100T), 1, MaxStrLen(TextValueL));
        UpdateEDIComp('DTM.2380', TextValueL, true, 35);
        UpdateEDIComp('DTM.2379', '203', true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    procedure Ins_FTX(Qualifier: Text[3]; FreeTxtCode: Code[17]; ResponsibleCode: Code[3]; Text: Text[512])
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'FTX';
        UpdateEDIComp('Segment', 'FTX', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('FTX.4451', Qualifier, true, 3);
        UpdateEDILine(false);
        UpdateEDILine(false);

        case Qualifier of
            'AAI':
                begin
                    UpdateEDILine(false);
                    UpdateEDIComp('FTX.4440', Text, true, 512);
                    UpdateEDILine(false);
                end;
            else begin
                    UpdateEDIComp('FTX.4441', FreeTxtCode, true, 17);
                    UpdateEDIComp('FTX.1131', '', false, 17);
                    UpdateEDIComp('FTX.3055', ResponsibleCode, true, 3);
                    UpdateEDILine(false);
                end;
        end;

        InsertEDILine();
    end;

    procedure Ins_NAD(BillToCode: Code[20]; BillToCountryRegion: Code[10])
    var
        Customer: Record Customer;
        EDIValues: Record "EOS074 EDI Values";
        MaxLengh: Text[20];
    //County: Integer;
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

        Customer.Get(BillToCode);

        EDIValues.FilterByRecord(Customer);

        if EDIValues.FindFirst() then
            if EDIValues."EDI Identifier" <> '' then
                UpdateEDIComp('NAD.3039', EDIValues."EDI Identifier", true, 35);

        UpdateEDIComp('NAD.1131', '', false, 3);
        UpdateEDIComp('NAD.3055', '9', true, 3);
        UpdateEDILine(false);

        UpdateEDILine(false);
        // ORG: UpdateEDIComp('NAD.3036',Cust.Name,FALSE,35);
        UpdateEDIComp('NAD.3036', Customer.Name, true, 35);
        UpdateEDILine(false);

        // ORG: UpdateEDIComp('NAD.3042',Cust.Address,FALSE,35);
        UpdateEDIComp('NAD.3042', Customer.Address, true, 35);
        UpdateEDILine(false);
        
        // ORG: UpdateEDIComp('NAD.3164',Cust.City,FALSE,35);
        UpdateEDIComp('NAD.3164', Customer.City, true, 35);
        UpdateEDILine(false);
        UpdateEDILine(false);
        
        // ORG: UpdateEDIComp('NAD.3251',Cust."Post Code",FALSE,35);
        UpdateEDIComp('NAD.3251', Customer."Post Code", true, 35);
        UpdateEDILine(false);

        UpdateEDIComp('NAD.3207', BillToCountryRegion, true, 3);
        UpdateEDILine(false);

        InsertEDILine();

        if Customer."Country/Region Code" <> 'CH' then
            if CopyStr(Customer."VAT Registration No.", 1, 2) = Customer."Country/Region Code" then
                Ins_RFF(Customer."VAT Registration No.", '', 'VA')
            else
                Ins_RFF(CopyStr(Customer."Country/Region Code" + Customer."VAT Registration No.", 1, MaxStrLen(MaxLengh)), '', 'VA')
        else
            Ins_RFF(Customer."VAT Registration No.", '', 'VA');

        // ------------------------------------------
        // Supplier
        // ------------------------------------------

        NumberOfSegments := NumberOfSegments + 1;

        OnBeforeInitEDILineForInsNAD(Customer);

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

        CompanyInfo.Get();
        UpdateEDILine(false);
        // ORG: UpdateEDIComp('NAD.3036',CompanyInfo.Name,FALSE,35);
        UpdateEDIComp('NAD.3036', CompanyInfo.Name, true, 35);
        UpdateEDILine(false);

        // ORG: UpdateEDIComp('NAD.3042',CompanyInfo.Address,FALSE,35);
        UpdateEDIComp('NAD.3042', CompanyInfo.Address, true, 35);
        UpdateEDILine(false);

        // ORG: UpdateEDIComp('NAD.3164',CompanyInfo.City,FALSE,35);
        UpdateEDIComp('NAD.3164', CompanyInfo.City, true, 35);
        UpdateEDILine(false);
        UpdateEDILine(false);

        // ORG: UpdateEDIComp('NAD.3251',CompanyInfo."Post Code",FALSE,35);
        UpdateEDIComp('NAD.3251', CompanyInfo."Post Code", true, 35);
        UpdateEDILine(false);

        UpdateEDIComp('NAD.3207', CompanyInfo."Country/Region Code", true, 3);
        UpdateEDILine(false);

        InsertEDILine();

        if CopyStr(CompanyInfo."VAT Registration No.", 1, 2) = CompanyInfo."Country/Region Code" then
            Ins_RFF(CompanyInfo."VAT Registration No.", '', 'VA')
        else
            Ins_RFF(CopyStr(CompanyInfo."Country/Region Code" + CompanyInfo."VAT Registration No.", 1, MaxStrLen(MaxLengh)), '', 'VA');

        OnBeforeEndOfInsNAD();

        // RFF+XC1:DE-OEKO-001' ?    // Organic Certification Number (only Europe)
        // RFF+YB7:4049928400857     // Global G.A.P. Number

        //NAD SF???
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

    local procedure Ins_LIN()
    begin
        NumberOfSegments := NumberOfSegments + 1;
        LineNo := LineNo + 1;
        InitEDILine();
        EDILine."Record Type" := 'LIN';

        UpdateEDIComp('Segment', 'LIN', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('LIN.1082', FormatInt(LineNo), true, 6);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_PIA(ItemNo: Code[20]; CrossReferenceNo: Code[20]; Qualifier: Text[30]; CustNo: Code[20])
    var
        CrossRef: Record "Item Cross Reference";
        i: Integer;
        ItemIdentifier: Text;
        MaxLenght: Text[1024];
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'PIA';

        UpdateEDIComp('Segment', 'PIA', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('PIA.4347', '5', true, 3);
        UpdateEDILine(false);

        if CrossReferenceNo <> '' then
            // ORG: UpdateEDIComp('PIA.7140', CrossReferenceNo,TRUE,35)
            ItemIdentifier := CrossReferenceNo;

        if ItemIdentifier = '' then begin
            CrossRef.SetRange("Cross-Reference Type", CrossRef."Cross-Reference Type"::Customer);
            CrossRef.SetRange("Cross-Reference Type No.", CustNo);
            CrossRef.SetRange("Item No.", ItemNo);
            //CrossRef."Unit of Measure"
            if CrossRef.FindFirst() then
                ItemIdentifier := CrossRef."Cross-Reference No.";
        end;

        // ORG: IF NOT (STRLEN(ItemIdentifier) IN [4,5]) THEN
        if not (StrLen(ItemIdentifier) in [4, 5, 6]) then
            Error(CustItemIdErr, ItemNo, ItemIdentifier);
        if not Evaluate(i, ItemIdentifier) then
            Error(CustItemIdErr, ItemNo, ItemIdentifier);

        UpdateEDIComp('PIA.7140', CopyStr(ItemIdentifier, 1, MaxStrLen(MaxLenght)), true, 35);

        UpdateEDIComp('PIA.7143', Qualifier, true, 3);
        UpdateEDIComp('PIA.1131', '', false, 17);
        UpdateEDIComp('PIA.3055', '92', true, 3);
        UpdateEDILine(false);

        InsertEDILine();
    end;

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

        UpdateEDIComp('IMD.7140', ConvertStr(Descr, '''', ' '), true, 256);

        UpdateEDILine(false);

        InsertEDILine();
    end;

    local procedure Ins_QTY(Qty: Decimal; UOM: Code[20]; UOMCrossRef: Code[20]; CrossRef: Code[20])
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

        if CrossRef <> '' then
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

    procedure Ins_MOA(Amount: Decimal; Qualifier: Text[30])
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

    procedure Ins_TAX(TaxCode: Code[10]; Qualifier: Text[30]; Qualifier2: Text[30]/*; Qualifier3: Text[30]*/)
    var
        TaxFeeCategoryCode: Code[1];
        TaxValueDec: Decimal;
    //_PVC_: Integer;
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

        UpdateEDIComp('TAX.5278', '', false, 1);
        UpdateEDIComp('TAX.5278', '', false, 1);
        UpdateEDIComp('TAX.5278', '', false, 1);
        UpdateEDIComp('TAX.5278', TaxCode, true, 15);

        UpdateEDILine(false);
        Evaluate(TaxValueDec, TaxCode);
        if (TaxValueDec = 0) then
            TaxFeeCategoryCode := 'E'
        else
            TaxFeeCategoryCode := 'S';
        UpdateEDIComp('TAX.5305', TaxFeeCategoryCode, false, 1);
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
    var
        MaxLenght: Text[1024];
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'UNT';

        UpdateEDIComp('Segment', 'UNT', true, 3);
        UpdateEDILine(false);

        UpdateEDIComp('UNT.0074', FormatInt(NumberOfSegments), true, 6);
        UpdateEDILine(false);

        // ORG: UpdateEDIComp('UNT.0062',EDIHeader."No.",TRUE,14);
        UpdateEDIComp('UNT.0062', CopyStr(GetInterchangeRefCode(EDIHeader."No."), 1, MaxStrLen(MaxLenght)), true, 14);
        UpdateEDILine(false);

        InsertEDILine();
    end;

    procedure Ins_UNZ()
    var
        MaxLenght: Text[1024];
    begin
        NumberOfSegments := NumberOfSegments + 1;
        InitEDILine();
        EDILine."Record Type" := 'UNZ';

        UpdateEDIComp('Segment', 'UNZ', true, 3);
        UpdateEDILine(false);


        UpdateEDIComp('UNZ.0036', '1', true, 6);
        UpdateEDILine(false);

        // ORG: UpdateEDIComp('UNZ.0020',EDIHeader."No.",TRUE,14);
        UpdateEDIComp('UNZ.0020', CopyStr(GetInterchangeRefCode(EDIHeader."No."), 1, MaxStrLen(MaxLenght)), true, 14);
        UpdateEDILine(false);


        InsertEDILine();
    end;

    local procedure GetExternalOrderNo(DocumentNo: Text[35]) ExternalOrderNo: Text[20]
    var
        i: Integer;
        DX_Txt: Text;
        SX_Txt: Text;
        DocumentNoString: Text;
        DocumentNoValues: List of [Text];
        Separator: List of [Text];
        SeparatorCharLbl: Label '/', Locked = true;
    begin
        /*
        i := STRPOS(DocumentNo, '/');
        IF i > 0 THEN
          // ORG: EXIT(COPYSTR(DocumentNo, i+1));
        BEGIN
          SX_Txt := COPYSTR(DocumentNo, 1, i-1);
          DX_Txt := COPYSTR(DocumentNo, i+1);
          i := STRPOS(SX_Txt, '-');
          IF i > 0 THEN
            DocumentNo := DX_Txt
          ELSE
            DocumentNo := SX_Txt;
        END;
        */

        DocumentNoString := DocumentNo;
        Separator.Add(SeparatorCharLbl);

        DocumentNoValues := DocumentNoString.Split(Separator);


        case DocumentNoValues.Count() of
            2:
                begin
                    SX_Txt := DocumentNoValues.Get(0);
                    DX_Txt := DocumentNoValues.Get(1);
                    i := STRPOS(SX_Txt, '-');
                    if i > 0 then
                        DocumentNo := CopyStr(DX_Txt, 1, MaxStrLen(DocumentNo))
                    else
                        DocumentNo := CopyStr(SX_Txt, 1, MaxStrLen(DocumentNo));
                end;
            4:
                // ORG: DocumentNo := DocumentNoValues.GetValue(2);
                DocumentNo := CopyStr(DocumentNoValues.Get(1), 1, MaxStrLen(DocumentNo));

        end;

        if not (StrLen(DocumentNo) in [5, 6]) then
            Error(NotDefinedOrdErr, DocumentNo);
        if not Evaluate(i, DocumentNo) then
            Error(NotDefinedOrdErr, DocumentNo);

        exit(CopyStr(DocumentNo, 1, MaxStrLen(ExternalOrderNo)));
    end;

    local procedure GetInterchangeRefCode(InterchangeCode: Code[20]): Text
    var
        MaxLen: Integer;
    begin
        MaxLen := 14;
        if StrLen(InterchangeCode) > MaxLen then
            exit(CopyStr(InterchangeCode, StrLen(InterchangeCode) - MaxLen));

        exit(InterchangeCode);
    end;


    /// <summary>
    /// Execute before the end of Ins_NAD function
    /// If you want to add values or methods
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeEndOfInsNAD()
    begin
    end;

    /// <summary>
    /// Execute before init EDI Line in Ins_NAD function
    /// If you want to add values or methods
    /// </summary>
    /// <param name="EDIMsgHeader"></param>
    /// <param name="EDIMessSetup"></param>
    /// <param name="Handled"></param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitEDILineForInsNAD(Customer: record Customer)
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
