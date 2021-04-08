report 70491818 "EOS074 Euritmo Orders In"
{
    Caption = 'EDI Euritmo Orders In';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem("EDI Message Header"; "EOS074 EDI Message Header")
        {
            DataItemTableView = sorting("Message Type", "No.") order(ascending) where("Message Type" = const("ORDERS IN"));
            dataitem("EDI Message Line"; "EOS074 EDI Message Line")
            {
                DataItemLink = "Message Type" = field("Message Type"), "Message No." = field("No.");
                DataItemTableView = sorting("Message Type", "Message No.", "Line No.") order(ascending);

                trigger OnAfterGetRecord()
                var
                    LineType: Text[3];
                    lLineNo: Integer;
                begin
                    LineBuffer := "Field 1" + "Field 2" + "Field 3";

                    LineType := CopyStr("Field 1", 1, 3);
                    case LineType of
                        'BGM':
                            BGMHandle();
                        'NAS':
                            NASHandle();
                        'NAB':
                            NABHandle();
                        'NAD':
                            NADHandle();
                        'NAI':
                            NAIHandle();
                        'DTM':
                            DTMHandle();
                        'LIN':
                            begin
                                Evaluate(lLineNo, CopyStr("Field 1", 4, 6));
                                CreateSalesLine(lLineNo);
                                LINHandle();
                            end;
                    end;
                end;

                trigger OnPostDataItem()
                var
                    SalesLine2: Record "Sales Line";
                begin
                    SalesLine2.Reset();
                    SalesLine2.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine2.SetRange("Document No.", SalesHeader."No.");
                    if SalesLine2.FindSet() then
                        repeat
                            if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine2, true) then
                                //CurrPage.SAVERECORD;
                                //COMMIT;
                                TransferExtendedText.InsertSalesExtText(SalesLine2);

                        until SalesLine2.Next() = 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                EDIGroup.Get("EDI Group Code");

                EDIMessageSetup.Get("Message Type", "EDI Group Code");
            end;

            trigger OnPostDataItem()
            begin
                Message(OrdersGeneratedMsg, OrdersCreated);
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
        Customer: Record Customer;
        Customer2: Record Customer;
        CompanyInformation: Record "Company Information";
        ShiptoAddress: Record "Ship-to Address";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        EDIGroup: Record "EOS074 EDI Group";
        EDIMessageSetup: Record "EOS074 EDI Message Setup";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        OrdersCreated: Integer;
        OrdersGeneratedMsg: Label '%1 orders generated.';
        LineBuffer: Text;
        LastLineNo: Integer;
    // EanCodeUsedErr: Label '%1 EAN code for %2 equipment group code and document date %3 is used more than once!';
    // Text1021: Label '%1 EAN code is used more than once!';
    // ItemNotExistErr: Label 'Item with %1 EAN does not exist!';
    // Text1023: Label '% 1 orders generated.';

    procedure CreateSalesHeader()
    var
        EDIMessageDocument: Record "EOS074 EDI Message Document";
        //spp
        // DataSecurityManagement: Codeunit UnknownCodeunit18006600;
        RecRef: RecordRef;
    begin
        CompanyInformation.Get();

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."document type"::Order;
        SalesHeader."No." := '';

        //spp
        // SalesHeader."Document Category Code" := EDIMessageSetup."Document Category Code";

        SalesHeader.Insert(true);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Modify();

        RecRef.GetTable(SalesHeader);

        //spp
        // Clear(DataSecurityManagement);
        // if DataSecurityManagement.GetDSEnabled(RecRef) then
        //     DataSecurityManagement.SetFirstStatus(RecRef);

        OrdersCreated := OrdersCreated + 1;

        EDIMessageDocument.Init();
        EDIMessageDocument."Message Type" := "EDI Message Header"."Message Type";
        EDIMessageDocument."Message No." := "EDI Message Header"."No.";
        EDIMessageDocument."Table ID" := Database::"Sales Header";
        EDIMessageDocument."Document Type" := EDIMessageDocument."Document Type";
        EDIMessageDocument."Document No." := SalesHeader."No.";
        EDIMessageDocument.Insert();

        LastLineNo := 0;
    end;

    procedure CreateSalesLine(LineNo: Integer)
    var
    // EANCode: Code[20];
    // Bestellmenge: Decimal;
    // VKPreis: Decimal;
    // ZeilenrabProz: Decimal;
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        LastLineNo := LastLineNo + 10000;
        SalesLine."Line No." := LastLineNo;
        //em
        //InsertExtendedText(TRUE);
        SalesLine.Insert(true);
    end;

    procedure BGMHandle()
    var
        EDIValues: Record "EOS074 EDI Values";
        "ID-EDI-MITT1": Text[50];
        "ID-EDI-MITT2": Text[50];
        NUMDOC: Text[50];
        DATADOC: Date;
    begin
        CreateSalesHeader();

        //"ID-EDI-MITT1" := ExtractAlphaNumeric(4,35);
        "ID-EDI-MITT1" := CopyStr(LineBuffer, 4, 35);
        //"ID-EDI-MITT2" := ExtractAlphaNumeric(39,4);
        "ID-EDI-MITT2" := CopyStr(LineBuffer, 39, 4);

        case "ID-EDI-MITT2" of
            'EN', '14':
                begin
                    // Customer.Reset();
                    // Customer.SetCurrentkey("EDI Identifier");
                    // Customer.SetRange("EDI Identifier", "ID-EDI-MITT1");
                    // if Customer.FindFirst() then begin
                    //     Customer.TestField("EDI Identifier");
                    //     SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
                    //     SalesHeader.Modify();
                    // end;

                    EDIValues.FilterByRecord(Customer);
                    EDIValues.SetCurrentKey("EDI Identifier");

                    EDIValues.SetRange("EDI Identifier", "ID-EDI-MITT1");
                    if EDIValues.FindFirst() then begin
                        EDIValues.TestField("EDI Identifier");
                        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
                        SalesHeader.Modify();
                    end;
                end;
            'ZZ':
                begin
                    Customer.Reset();
                    Customer.SetCurrentkey("VAT Registration No.");
                    Customer.SetRange("VAT Registration No.", "ID-EDI-MITT1");
                    if Customer.FindFirst() then begin
                        Customer.TestField("VAT Registration No.");
                        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
                        SalesHeader.Modify();
                    end;
                end;
        end;

        NUMDOC := ExtractAlphaNumeric(116, 35);
        if (NUMDOC <> '') then begin
            //SalesHeader."External Document No." := COPYSTR(NUMDOC,1,20);
            SalesHeader."Your Reference" := CopyStr(NUMDOC, 1, 20);
            SalesHeader.Modify();
        end;

        DATADOC := ExtractDate(151, 8);

        if DATADOC > WorkDate() then
            DATADOC := WorkDate();

        if (DATADOC <> 0D) then begin
            SalesHeader.Validate("Document Date", DATADOC);
            SalesHeader.Modify();
        end;
    end;

    procedure NASHandle()
    var
    // EDIValues: Record "EOS074 EDI Values";
    // CODFORN: Text[50];
    // QCODFORN: Text[10];
    begin
        exit;

        // CODFORN := ExtractAlphaNumeric(4, 17);
        // QCODFORN := CopyStr(ExtractAlphaNumeric(21, 3), 1, MaxStrLen(QCODFORN));

        // case QCODFORN of
        //     'VA':
        //         CompanyInformation.TestField("VAT Registration No.", CODFORN);
        //     '14':
        //         begin
        //             EDIValues.FilterByRecord(CompanyInformation);
        //             if EDIValues.FindFirst() then
        //               EDIValues.TestField("EDI Identifier", CODFORN);
        //         end;
        //     'ZZ':
        //         CompanyInformation.TestField("VAT Registration No.", CODFORN);

        // end;
    end;

    procedure NABHandle()
    var
        CODBUYER: Text[50];
        QCODBUY: Text[50];
    begin
        // Buyer - mandatory record
        CODBUYER := ExtractAlphaNumeric(4, 17);
        QCODBUY := ExtractAlphaNumeric(21, 3);

        //CODBUYER:=CODBUYER;

        exit;

        /*
        CASE QCODBUY OF
          '14':
            BEGIN
              Customer2.RESET;
              Customer2.SETCURRENTKEY("edi identifier");
              Customer2.SETRANGE("edi identifier", CODBUYER);
              Customer2.FIND('-');
              Customer2.TESTFIELD("edi identifier");
        
              SalesHeader.VALIDATE("Bill-to Customer No.", Customer2."No.");
              SalesHeader.MODIFY;
            END;
          'VA':
            BEGIN
              Customer2.RESET;
              Customer2.SETCURRENTKEY("VAT Registration No.");
              Customer2.SETRANGE("VAT Registration No.", CODBUYER);
              Customer2.FIND('-');
              Customer2.TESTFIELD("VAT Registration No.");
        
              SalesHeader.VALIDATE("Bill-to Customer No.", Customer2."No.");
              SalesHeader.MODIFY;
            END;
        END;
        */

    end;

    procedure NADHandle()
    var
        EDIValues: Record "EOS074 EDI Values";
        CODCONS: Text[50];
        QCODCONS: Text[50];
    begin
        // Delivery Point - mandatory record
        CODCONS := ExtractAlphaNumeric(4, 17);
        QCODCONS := ExtractAlphaNumeric(21, 3);

        case QCODCONS of
            //ORG: '14':
            '14', '92':
                begin
                    /*
                    Customer2.RESET;
                    Customer2.SETCURRENTKEY("EDI Identifier");
                    Customer2.SETRANGE("EDI Identifier", CODCONS);
                    Customer2.FINDFIRST;
                    Customer2.TESTFIELD("EDI Identifier");
                    */

                    // ShiptoAddress.Reset();
                    //em
                    //ShiptoAddress.SETCURRENTKEY("ILN Code");
                    // ShiptoAddress.SetCurrentkey("EDI Identifier");
                    //ShiptoAddress.SETRANGE("ILN Code",CODCONS);
                    // ShiptoAddress.SetRange("EDI Identifier", CODCONS);
                    // ShiptoAddress.FindFirst();
                    //ShiptoAddress.TESTFIELD("ILN Code");
                    // ShiptoAddress.TestField("EDI Identifier");

                    // EDIValues.FilterByRecord(ShiptoAddress);
                    EDIValues.SetRange("EDI Identifier", CODCONS);
                    EDIValues.SetRange("Source Type", Database::"Ship-to Address");
                    EDIValues.FindFirst();

                    EDIValues.TestField("EDI Identifier");
                    ShiptoAddress.Get(EDIValues."Source ID", EDIValues."Source Batch Name");

                    SalesHeader.Validate("Sell-to Customer No.", ShiptoAddress."Customer No.");
                    SalesHeader.Validate("Ship-to Code", ShiptoAddress.Code);
                    SalesHeader.Modify();
                end;
            'VA':
                begin
                    Customer2.Reset();
                    Customer2.SetCurrentkey("VAT Registration No.");
                    Customer2.SetRange("VAT Registration No.", CODCONS);
                    Customer2.FindFirst();
                    Customer2.TestField("VAT Registration No.");

                    SalesHeader.Validate("Sell-to Customer No.", Customer2."No.");
                    SalesHeader.Modify();
                end;
        /*
        '92':
           BEGIN
             Customer2.RESET;
             Customer2.SETCURRENTKEY("EDI Identifier");
             Customer2.SETRANGE("EDI Identifier", CODCONS);
             IF Customer2.FINDFIRST THEN
               BEGIN
                 Customer2.TESTFIELD("EDI Identifier");
                 SalesHeader.VALIDATE("Sell-to Customer No.", Customer2."No.");
                 SalesHeader.MODIFY;
               END ELSE BEGIN
               CODCONS:='101';
               Customer2.RESET;
               Customer2.SETCURRENTKEY("EDI Identifier");
               Customer2.SETRANGE("EDI Identifier", CODCONS);
               Customer2.FINDFIRST;
               Customer2.TESTFIELD("EDI Identifier");
               SalesHeader.VALIDATE("Sell-to Customer No.", Customer2."No.");
               SalesHeader.MODIFY;
               END;
           END;
         */

        end;

    end;

    procedure NAIHandle()
    var
    // CODFATT: Text[50];
    // QCODFATT: Text[50];
    begin
        // Invoice Customer - optional record

        exit;

        /*
        QCODFATT := ExtractAlphaNumeric(21,3);
        CODFATT := ExtractAlphaNumeric(4,17);
        CASE QCODFATT OF
          '14':
            BEGIN
              CustomerBill.RESET;
              CustomerBill.SETCURRENTKEY("EDI Identifier");
              CustomerBill.SETRANGE("EDI Identifier", CODFATT);
              CustomerBill.FINDFIRST;
              CustomerBill.TESTFIELD("EDI Identifier");
              SalesHeader.VALIDATE("Bill-to Customer No.", CustomerBill."No.");
            END;
          'VA':
            BEGIN
              CustomerBill.RESET;
              CustomerBill.SETCURRENTKEY("VAT Registration No.");
              CustomerBill.SETRANGE("VAT Registration No.", CODFATT);
              CustomerBill.FINDFIRST;
              CustomerBill.TESTFIELD("VAT Registration No.");
              SalesHeader.VALIDATE("Bill-to Customer No.", CustomerBill."No.");
            END;
        END;
        */

    end;

    procedure DTMHandle()
    var
        DATACONS: Date;
    // ORACONS: Time;
    begin
        // Requested Delivery Date - mandatory record
        DATACONS := ExtractDate(4, 8);
        if (DATACONS <> 0D) then begin
            SalesHeader.Validate("Requested Delivery Date", DATACONS);
            SalesHeader.Validate("Promised Delivery Date", DATACONS);
            SalesHeader.Modify();
        end;
        // ORACONS := ExtractTime(12, 4);
        // if (ORACONS <> 0T) then begin
        //spp: SalesHeader.Validate("Promised Delivery Time", ORACONS);
        //     SalesHeader.Modify();
        // end;
    end;

    procedure LINHandle()
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        // ItemEquipment: Record UnknownRecord5040597;
        // ItemLabelsEquipment: Record UnknownRecord5040595;
        // UoMMgt: Codeunit "Unit of Measure Management";
        TIPCODCU: Text[50];
        CODEANCU: Text[50];
        CODEANCT: Text[50];
        QTAORD: Decimal;
        UDMQORD: Text[50];
        CODDISTU: Text[50];
        NRCUINTU: Decimal;
        // BASEQTY: Decimal;
        PRZUNI: Decimal;
        // ItemNo: Code[20];
        CODEANTU: Text[50];
        EAN: Text[50];
        EANCustomer: Code[20];
        Counter: Integer;
        UDMPRZUN: Text[50];
        //CheckItemEAN001Err: Label 'ITA="Non è presente nessun articolo con EAN = ''%1'' e ''%3'' = ''%4'' (nè per il cliente ''%2'', nè comune a tutti i clienti)"';
        // CheckItemEAN001Err: Label 'There is no items with EAN Code = %1 and %3 = %4 (neither for %2 customer, nor for all customers)';
        //CheckItemEAN002Err: Label 'ITA="Sono presenti ''%5'' articoli con EAN = ''%1'' per il cliente ''%2'' e con ''%3'' = ''%4''"';
        // CheckItemEAN002Err: Label 'There are %5 items with EAN Code = %1 for %2 customer and with %3 = %4';
        //CheckItemEAN003Err: Label 'ITA="Sono presenti ''%4'' articoli con EAN = ''%1'' e ''%2'' = ''%3'' comune a tutti i clienti"';
        // CheckItemEAN003Err: Label 'There are %4 items with EAN Code = %1 and %2 = %3 common to all customers';
        //UnitOfMeasure001Err: label 'ITA=Articolo ''%1''\Unit… di misura ''%2'' non utilizzabile nel flusso EDI';
        UnitOfMeasure001Err: label 'Item %1 with UoM %2 not usable for EDI';
    begin
        SalesLine.Validate(Type, SalesLine.Type::Item);

        TIPCODCU := ExtractAlphaNumeric(45, 3);
        CODEANCU := ExtractAlphaNumeric(10, 35);
        CODEANCT := ExtractAlphaNumeric(118, 35);

        if CODEANCU = '' then
            CODEANCU := ExtractAlphaNumeric(118, 35);

        CODDISTU := ExtractAlphaNumeric(118, 35);

        if TIPCODCU <> 'EN' then begin
            CODEANTU := ExtractAlphaNumeric(48, 35);
            EAN := CODEANTU;
        end else
            EAN := CODEANCU;

        EANCustomer := SalesHeader."Sell-to Customer No.";

        ItemCrossReference.Reset();
        ItemCrossReference.SetRange("Cross-Reference Type No.", EANCustomer);

        //spp
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Customer);

        //ORG:ItemCrossReference.SETRANGE("Cross-Reference No.", CODEANCU);

        ItemCrossReference.SetRange("Cross-Reference No.", EAN);
        ItemCrossReference.FindFirst();

        Counter := ItemCrossReference.Count();

        //spp
        // if Counter > 1 then
        //     Error(CheckItemEAN002Err, CODEANCU, EANCustomer, ItemCrossReference.FIELDCAPTION("Cross-Reference Type"), ItemCrossReference."Cross-Reference Type"::EAN, Counter);

        // if not ItemCrossReference.FindFirst() then begin
        //     //ORG:ItemCrossReference.SETRANGE("Cross-Reference Type No.");
        //     ItemCrossReference.SetRange("Cross-Reference Type No.", '');

        //     Counter := ItemCrossReference.Count();
        //     if Counter > 1 then
        //         Error(CheckItemEAN003Err, CODEANCU, ItemCrossReference.FIELDCAPTION("Cross-Reference Type"), ItemCrossReference."Cross-Reference Type"::EAN, Counter);

        //     if not ItemCrossReference.FindFirst() then
        //         Error(CheckItemEAN001Err, CODEANCU, EANCustomer, ItemCrossReference.FIELDCAPTION("Cross-Reference Type"), ItemCrossReference."Cross-Reference Type"::EAN);
        // end;

        Item.Get(ItemCrossReference."Item No.");

        // CheckItemDivision(Item."No.", CODEANCU);

        SalesLine.Validate("No.", Item."No.");

        UDMQORD := ExtractAlphaNumeric(206, 3);
        QTAORD := ExtractDecimal(191, 15);
        CheckOrderdQuantity(QTAORD, SalesLine.FIELDCAPTION(Quantity));

        NRCUINTU := ExtractDecimal(230, 15);
        PRZUNI := ExtractDecimal(209, 15);

        UDMPRZUN := ExtractAlphaNumeric(227, 3);
        if UDMQORD = '' then
            UDMQORD := 'CT';

        case UDMQORD of
            'CT', 'TU':
                begin
                    //QTAORD:=QTAORD/NRCUINTU;
                    QTAORD := QTAORD;
                    CheckPackageNumber(NRCUINTU, SalesLine."No.", UDMPRZUN, SalesLine."Unit of Measure Code");
                end;
            'PCE':
                QTAORD := QTAORD;
            else
                Error(UnitOfMeasure001Err, SalesLine."No.", UDMQORD);
        //  'KGM':
        //    BEGIN
        //     // QTAORD:=QTAORD/NRCUINTU;
        //    END;
        //  'CU':
        //    BEGIN
        //      //QTAORD:=QTAORD/NRCUINTU;
        //    END;
        //  'TU':
        //    BEGIN
        //      //QTAORD:=QTAORD/NRCUINTU;
        //    END;
        //  'LTR':
        //    BEGIN
        //      //  QTAORD:=QTAORD/NRCUINTU;
        //    END;
        //  'MTR':
        //    BEGIN
        //      // QTAORD:=QTAORD/NRCUINTU;
        //    END;
        end;

        // SalesLine.Validate("EDI Order In EAN Original", EAN);

        SalesLine.Validate(Quantity, QTAORD);
        // SalesLine.Validate("Orig. Entered Quantity", QTAORD);
        // SalesLine.Validate("Original Accounting Unit Price", PRZUNI);
        SalesLine.UpdateAmounts();
        SalesLine.Modify();

    end;

    procedure ExtractAlphaNumeric(StartPos: Integer; NumChars: Integer) ReturnText: Text[50]
    begin
        exit(CopyStr(DelChr(CopyStr(LineBuffer, StartPos, NumChars), '><', ' '), 1, MaxStrLen(ReturnText)));
    end;

    procedure ExtractDecimal(StartPos: Integer; NumChars: Integer): Decimal
    var
        t: Text[50];
        d: Decimal;
    begin
        t := CopyStr(CopyStr(LineBuffer, StartPos, NumChars), 1, MaxStrLen(t));
        // fixed lenght format always 12 + 3
        Evaluate(d, CopyStr(t, 1, 12) + DelChr(Format(1.1), '=', '1') + CopyStr(t, 13, 3));
        exit(d);
    end;

    procedure ExtractDate(StartPos: Integer; NumChars: Integer): Date
    var
        t: Text[8];
        d: Date;
        Year: Integer;
        Month: Integer;
        Day: Integer;
    begin
        d := 0D;
        t := CopyStr(ExtractAlphaNumeric(StartPos, NumChars), 1, MaxStrLen(t));
        if Evaluate(Year, CopyStr(t, 1, 4)) then
            if Evaluate(Month, CopyStr(t, 5, 2)) then
                if Evaluate(Day, CopyStr(t, 7, 2)) then
                    d := Dmy2date(Day, Month, Year);
        exit(d);
    end;

    procedure ExtractTime(StartPos: Integer; NumChars: Integer): Time
    var
        t: Text[50];
        tm: Time;
    begin
        tm := 0T;
        t := ExtractAlphaNumeric(StartPos, NumChars);
        if (t <> '00:00') then
            if Evaluate(tm, t) then;
        exit(tm);
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.SalesCheckIfAnyExtText(SalesLine, Unconditionally) then
            TransferExtendedText.InsertSalesExtText(SalesLine);

    end;

    // local procedure CheckItemDivision(ItemNo: Code[20]; EANCode: Text);
    // var
    // ItemDivisionLocal: Record 50007;
    // FirstInsert: Boolean;
    // DivisionError: Boolean;
    // CheckItemDivision002Err: Label 'ITA=Nessuna divisione comune a tutti gli articoli';        
    // CheckItemDivision001Err: Label 'ITA="Nessuna divisione per l''articolo ''%1'' con EAN = ''%2''"';
    // begin
    //     TempItemDivision.Reset();
    //     if TempItemDivision.IsEmpty() then begin
    //         FirstInsert := true;
    //         DivisionError := false;
    //     end else begin
    //         FirstInsert := false;
    //         DivisionError := true;
    //     end;

    //     ItemDivisionLocal.Reset();
    //     ItemDivisionLocal.SetRange("Item No.", ItemNo);
    //     ItemDivisionLocal.SetRange("Exclude from EDI", false);

    //     if ItemDivisionLocal.FindSet() then
    //         repeat
    //             if FirstInsert then begin
    //                 TempItemDivision.Init();
    //                 TempItemDivision."Item No." := ItemDivisionLocal."Item No.";
    //                 TempItemDivision."Division No." := ItemDivisionLocal."Division No.";
    //                 TempItemDivision.Insert();
    //             end else begin
    //                 TempItemDivision.Reset();
    //                 TempItemDivision.SetRange("Division No.", ItemDivisionLocal."Division No.");
    //                 if TempItemDivision.FindFirst() then
    //                     DivisionError := false;
    //             end;
    //         until (ItemDivisionLocal.Next() = 0) or (DivisionError);

    //     if ItemDivisionLocal.IsEmpty() then
    //         Error(CheckItemDivision001Err, ItemNo, EANCode);

    //     if DivisionError then
    //         Error(CheckItemDivision002Err);
    // end;

    local procedure CheckOrderdQuantity(Quantity: Decimal; FiedName: Text);
    var
        CheckOrderdQuantity001Err: Label '%1 = %2 with decimal places';
    begin
        if (Quantity mod 1) <> 0 then
            Error(CheckOrderdQuantity001Err, FiedName, Quantity);
    end;

    local procedure CheckPackageNumber(NRCUINTU: Decimal; ItemNoV: Code[20]; UOMCodeV: Code[10]; UOMCodeNewV: Code[10]);
    var
        // UOMMgt: Codeunit "Unit of Measure Management";
        EDIManagement: Codeunit "EOS074 EDI Management";
        Qty: decimal;
        QuantityPerUM: Decimal;
        CheckPackageNumber001Err: Label 'Item %1. \ Nr. Packages = %2 per inconsistent cartonCardboard \ Expected value = %3';
    begin
        if NRCUINTU = 0 then
            exit;

        Qty := 1;

        QuantityPerUM := EDIManagement.ConvertQty(ItemNoV, UoMCodeV, UOMCodeNewV, Qty);

        if QuantityPerUM <> NRCUINTU then;
            Error(CheckPackageNumber001Err, ItemNoV, NRCUINTU, QuantityPerUM);
    end;
}

