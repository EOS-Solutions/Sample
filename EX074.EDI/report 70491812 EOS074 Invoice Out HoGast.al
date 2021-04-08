report 70491812 "EOS074 Invoice Out HoGast"
{
    Caption = 'EDI Invoice Out HoGast';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(EDIMessageSetup; "EOS074 EDI Message Setup")
        {
            DataItemTableView = where("Message Type" = const("INVOIC OUT"));
            dataitem(SalesInvHeader; "Sales Invoice Header")
            {
                dataitem(ShipmentLoop; "Integer")
                {

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempSalesShptHeader.FindFirst()
                        else
                            TempSalesShptHeader.Next();

                        WriteLine(
                          '3' +
                        Format(GetHoGastCustNo(TempSalesShptHeader."Sell-to Customer No.", TempSalesShptHeader."Ship-to Code")).PadLeft(6, '0') +
                        Format(TempSalesShptHeader."No.").PadRight(10, ' ') +
                        Format(TempSalesShptHeader."Posting Date", 0, '<Day,2>.<Month,2>.<Year4>') +
                        TempSalesShptHeader."Ship-to Name".PadRight(30, ' ') +
                        TempSalesShptHeader."Ship-to Address".PadRight(30, ' ') +
                        TempSalesShptHeader."Ship-to City".PadRight(30, ' '));

                        TempSalesShptLine.Reset();
                        TempSalesShptLine.SetRange("Document No.", TempSalesShptHeader."No.");
                        TempSalesShptLine.SetFilter(Amount, '<>%1', 0);
                        if TempSalesShptLine.FindSet() then
                            repeat
                                WriteLine(
                                  '4' +
                                  Format(TempSalesShptLine."VAT %", 0, '<Integer>').PadLeft(4, '0') +
                                  FormatDec(TempSalesShptLine.Quantity, 6, 2) +
                                  FormatDec(TempSalesShptLine.Amount, 8, 2) +
                                  Format(TempSalesShptLine."No.").PadRight(13, ' ') +
                                  TempSalesShptLine.Description.PadRight(30, ' '));
                            until TempSalesShptLine.Next() = 0;

                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempSalesShptHeader.Count());
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    SalesInvLine: Record "Sales Invoice Line";
                    SalesLine: Record "Sales Line";
                    SalesShptLine: Record "Sales Shipment Line";
                    SalesShptLine2: Record "Sales Shipment Line";
                    LineBuffer: Text;
                begin
                    FindEDIHeader("Posting Date");
                    if EDIHeader.ContainsDocument(Database::"Sales Invoice Header", 0, "No.") then
                        CurrReport.Skip();

                    EDIHeader.CreateLink(Database::"Sales Invoice Header", 0, "No.");

                    CreatePDF(Database::"Sales Invoice Header", "No.");

                    TempVATAmountLine.Reset();
                    TempVATAmountLine.DeleteAll();

                    TempSalesShptLine.Reset();
                    TempSalesShptLine.DeleteAll();

                    SalesInvLine.SetRange("Document No.", "No.");
                    SalesInvLine.SetFilter(Quantity, '<>%1', 0);
                    if SalesInvLine.FindSet() then
                        repeat
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
                            if (TempVATAmountLine."VAT Base" <> 0) or (TempVATAmountLine."VAT Amount" <> 0) or
                               (TempVATAmountLine."Amount Including VAT" <> 0)
                            then
                                TempVATAmountLine.InsertLine();

                            // DocRelMgt.GetSalesDocuments(
                            //   Buffer, 1, Database::"Sales Invoice Line", 0,
                            //   SalesInvLine."Document No.", SalesInvLine."Line No.");

                            // Buffer.SetFilter("Line No.", '<>%1', 0);
                            // Buffer.SetRange("Table ID", Database::"Sales Shipment Line");
                            // if Buffer.FindSet() then
                            // repeat
                            //SalesShptLine.Get(Buffer."Document No.", Buffer."Line No."); 
                            // until Buffer.Next() = 0;

                            if SalesShptLine.Get(SalesInvLine."Shipment No.", SalesInvLine."Shipment Line No.") then
                                InsertTempSalesShptLine(TempSalesShptLine, SalesShptLine, SalesInvLine);

                            SalesShptLine2.SetRange("Order No.", SalesInvLine."Order No.");
                            SalesShptLine2.SetRange("Order Line No.", SalesInvLine."Order Line No.");
                            if SalesLine.FindSet() then
                                repeat
                                    if not TempSalesShptLine.Get(SalesInvLine."Shipment No.", SalesInvLine."Shipment Line No.") then
                                        InsertTempSalesShptLine(TempSalesShptLine, SalesShptLine, SalesInvLine);

                                until SalesLine.Next() = 0;

                        until SalesInvLine.Next() = 0;


                    LineBuffer :=
                      '7' +
                      format(EDIGroup."ID-EDI-SEND1").PadLeft(6, '0') +
                      format("No.").PadLeft(25, ' ') +
                      Format("Posting Date", 0, '<Day,2>.<Month,2>.<Year4>') +
                      '15';

                    if TempVATAmountLine.FindFirst() then
                        repeat
                            if TempVATAmountLine."VAT %" = 0 then
                                TempVATAmountLine."VAT %" := 95;
                            LineBuffer := LineBuffer +
                              Format(TempVATAmountLine."VAT %", 0, '<Integer>').PadLeft(4, '0') +
                              FormatDec(TempVATAmountLine."VAT Base", 8, 2) +
                              FormatDec(TempVATAmountLine."VAT Amount", 8, 2);
                        until TempVATAmountLine.Next() = 0;

                    WriteLine(LineBuffer);

                end;


                trigger OnPreDataItem()
                var
                    EDIValues: Record "EOS074 EDI Values";
                begin
                    if not EDIGroup."Allow Invoice" then
                        CurrReport.Break();

                    EDIValues.FilterByRecord(SalesInvHeader);
                    EDIValues.SetRange("EDI Group Code", EDIGroup.Code);

                    if EDIMessageSetup.GetFilter("Date Filter") <> '' then
                        SetFilter("Posting Date", EDIMessageSetup.GetFilter("Date Filter"));
                    if EDIMessageSetup.GetFilter("Document No. Filter") <> '' then
                        SetFilter("No.", EDIMessageSetup.GetFilter("Document No. Filter"));
                    if not EDIMessageSetup.IsTableAllowed(Database::"Sales Invoice Header") then
                        CurrReport.Break();
                end;
            }
            dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
            {

                trigger OnAfterGetRecord()
                var
                    SalesCrMemoLine: Record "Sales Cr.Memo Line";
                    LineBuffer: Text;
                    Lines: List of [text];
                    Str: Text;
                    Index: Integer;

                begin
                    FindEDIHeader("Posting Date");
                    if EDIHeader.ContainsDocument(Database::"Sales Cr.Memo Header", 0, "No.") then
                        CurrReport.Skip();

                    EDIHeader.CreateLink(Database::"Sales Cr.Memo Header", 0, "No.");

                    CreatePDF(Database::"Sales Cr.Memo Header", "No.");

                    TempVATAmountLine.Reset();
                    TempVATAmountLine.DeleteAll();

                    SalesCrMemoLine.SetRange("Document No.", "No.");
                    SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
                    if SalesCrMemoLine.FindSet() then
                        repeat
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
                            if (TempVATAmountLine."VAT Base" <> 0) or (TempVATAmountLine."VAT Amount" <> 0) or
                               (TempVATAmountLine."Amount Including VAT" <> 0)
                            then
                                TempVATAmountLine.InsertLine();

                            LineBuffer :=
                              '4' +
                              Format(SalesCrMemoLine."VAT %", 0, '<Integer>').PadLeft(4, '0') +
                              FormatDec(-SalesCrMemoLine.Quantity, 6, 2) +
                              FormatDec(-SalesCrMemoLine.Amount, 8, 2) +
                              Format(SalesCrMemoLine."No.").PadRight(13, ' ') +
                              SalesCrMemoLine.Description.PadRight(30, ' ');

                            Lines.add(LineBuffer);

                        until SalesCrMemoLine.Next() = 0;

                    LineBuffer :=
                      '7' +
                      Format(EDIGroup."ID-EDI-SEND1").PadLeft(6, '0') +
                      Format("No.").PadLeft(25, ' ') +
                      Format("Posting Date", 0, '<Day,2>.<Month,2>.<Year4>') +
                      '15';

                    if TempVATAmountLine.FindFirst() then
                        repeat
                            if TempVATAmountLine."VAT %" = 0 then
                                TempVATAmountLine."VAT %" := 95;
                            LineBuffer := LineBuffer +
                              Format(TempVATAmountLine."VAT %", 0, '<Integer>').PadLeft(4, '0') +
                              FormatDec(-TempVATAmountLine."VAT Base", 8, 2) +
                              FormatDec(-TempVATAmountLine."VAT Amount", 8, 2);
                        until TempVATAmountLine.Next() = 0;

                    WriteLine(LineBuffer);

                    WriteLine(
                      '3' +
                      Format(GetHoGastCustNo("Sell-to Customer No.", '')).PadLeft(6, '0') +
                      Format("No.").PadRight(10, ' ') +
                      Format("Posting Date", 0, '<Day,2>.<Month,2>.<Year4>') +
                      "Sell-to Customer Name".PadRight(30, ' ') +
                      "Sell-to Address".PadRight(30, ' ') +
                      "Sell-to City".PadRight(30, ' '));

                    for Index := 1 to Lines.Count do begin
                        Lines.Get(Index, Str);
                        WriteLine(Str);
                    end;


                end;

                trigger OnPreDataItem()
                var
                    EDIValues: Record "EOS074 EDI Values";
                begin
                    if not EDIGroup."Allow Cr.Memo" then
                        CurrReport.Break();

                    EDIValues.FilterByRecord(SalesInvHeader);
                    EDIValues.SetRange("EDI Group Code", EDIGroup.Code);

                    if EDIMessageSetup.GetFilter("Date Filter") <> '' then
                        SetFilter("Posting Date", EDIMessageSetup.GetFilter("Date Filter"));
                    if EDIMessageSetup.GetFilter("Document No. Filter") <> '' then
                        SetFilter("No.", EDIMessageSetup.GetFilter("Document No. Filter"));
                    if not EDIMessageSetup.IsTableAllowed(Database::"Sales Cr.Memo Header") then
                        CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                EDIGroup.Get("EDI Group Code");
                EDIGroup.TestField("ID-EDI-SEND1");
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
        EDIHeader: Record "EOS074 EDI Message Header";
        EDIGroup: Record "EOS074 EDI Group";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempSalesShptHeader: Record "Sales Shipment Header" temporary;
        TempSalesShptLine: Record "Sales Invoice Line" temporary;
        NextLineNo: Integer;


    local procedure CreatePDF(DocType: Integer; DocNo: Code[20])
    var
        //Link: Record "EOS074 EDI Message Document";
        lSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lSalesInvHeader: Record "Sales Invoice Header";
        //os: OutStream;
        DocDate: Date;
        filename: Text;
    begin
        case DocType of
            Database::"Sales Invoice Header":
                begin
                    lSalesInvHeader.Get(DocNo);
                    DocDate := lSalesInvHeader."Posting Date";
                    lSalesInvHeader.SetRecFilter();
                    filename := PrintPDF(lSalesInvHeader);
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    lSalesCrMemoHeader.Get(DocNo);
                    DocDate := lSalesCrMemoHeader."Posting Date";
                    lSalesCrMemoHeader.SetRecFilter();
                    filename := PrintPDF(lSalesCrMemoHeader);
                end;
        end;

        /*spp for system file per il momento niente
        if (File.Exists(filename)) then begin
            Link.Get(EDIHeader."Message Type", EDIHeader."No.", DocType, 0, DocNo);
            Link.Attachment.CreateOutStream(os);
            fs := fs.FileStream(filename, fm.Open);
            CopyStream(os, fs);
            fs.Close();
            File.Erase(filename);

            Link."Attachment Name" :=
              StrSubstNo(
                '%1_%2_%3.pdf',
                EDIGroup."ID-EDI-MITT1",
                Format(DocDate, 0, '<Year4>-<Month,2>-<Day,2>'),
                DocNo);
            Link.Modify();
        end;
        */
    end;

    local procedure PrintPDF(DocVariant: Variant): Text
    var
        ReportSel: Record "Report Selections";
        OutFilename: Text;
    begin
        if FilterBySourceRecord(DocVariant, ReportSel) then begin
            ReportSel.FindFirst();

            //spp
            Commit();

            Report.Run(ReportSel."Report ID", true);
            //Report.SaveAsPdf(ReportSel."Report ID", OutFilename, DocVariant);
        end;
        exit(OutFilename);
    end;

    local procedure FindEDIHeader(PostingDate: Date)
    var
        EDILine: Record "EOS074 EDI Message Line";
        EDIMgt: Codeunit "EOS074 EDI Management";
    begin
        PostingDate := CalcDate('<CM>', PostingDate);

        EDIHeader.SetRange("Message Type", EDIMessageSetup."Message Type");
        EDIHeader.SetRange("EDI Group Code", EDIGroup.Code);
        EDIHeader.SetRange("Reference Type", 0);
        EDIHeader.SetRange("Reference Subtype", 0);
        EDIHeader.SetRange("Reference No.", '');
        EDIHeader.SetRange("Reference Date", PostingDate);
        if not EDIHeader.FindLast() then begin
            EDIMgt.CreateEDIHeader(EDIHeader, EDIMessageSetup, 0, 0, '', PostingDate);
            NextLineNo := 0;
            WriteLine(
              '1' +
              Format(CalcDate('<1D-1M>', PostingDate), 0, '<Day,2>.<Month,2>.<Year4>') +
              Format(PostingDate, 0, '<Day,2>.<Month,2>.<Year4>'));
        end else
            EDIHeader.TestField(Status, 0);

        EDILine.SetRange("Message Type", EDIHeader."Message Type");
        EDILine.SetRange("Message No.", EDIHeader."No.");
        if EDILine.FindLast() then;
        NextLineNo := EDILine."Line No.";
    end;

    local procedure WriteLine(LineText: Text)
    var
        EDILine: Record "EOS074 EDI Message Line";
    begin
        NextLineNo += 100;

        EDILine.Init();
        EDILine."Message Type" := EDIHeader."Message Type";
        EDILine."Message No." := EDIHeader."No.";
        EDILine."Line No." := NextLineNo;
        EDILine.SetText(LineText);
        EDILine.TestField("Message No.");
        EDILine.Insert();
    end;

    procedure GetHoGastCustNo(CustomerNo: Code[20]; ShipToCode: Code[10]) res: Code[20]
    var
        Cust: Record Customer;
        EDIValues: Record "EOS074 EDI Values";
        EDIValues2: Record "EOS074 EDI Values";
        ShipToAddr: Record "Ship-to Address";
    begin
        Cust.Get(CustomerNo);
        EDIValues.FilterByRecord(Cust);
        res := EDIValues."EDI Identifier";

        if ShipToAddr.Get(CustomerNo, ShipToCode) and (ShipToCode <> '') then begin

            EDIValues2.FilterByRecord(ShipToAddr);

            if EDIValues2."EDI Identifier" <> '' then
                res := EDIValues2."EDI Identifier";
        end;

        if res = '' then
            EDIValues.TestField("EDI Identifier");
    end;

    local procedure FormatDec(value: Decimal; int: Integer; dec: Integer): Text
    var
        filler: Text;
    begin
        if value < 0 then
            int -= 1;

        filler := '0';

        exit(Format(abs(value), 0, 2).PadLeft(int + dec + 1, filler[1]));
    end;

    procedure FilterBySourceRecord(DocVariant: Variant; var ReportSelections: Record "Report Selections"): Boolean
    var
        PurchHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
        ServiceHeader: Record "Service Header";
        RecRef: RecordRef;
        tUsage: Integer;
    begin
        tUsage := -1;

        RecRef.GetTable(DocVariant);
        case RecRef.Number of

            Database::"Sales Header":
                begin
                    SalesHeader := DocVariant;
                    case SalesHeader."Document Type" of
                        SalesHeader."Document Type"::Invoice:
                            tUsage := ReportSelections.Usage::"S.Invoice".AsInteger();
                        SalesHeader."Document Type"::Quote:
                            tUsage := ReportSelections.Usage::"S.Quote".AsInteger();
                        SalesHeader."Document Type"::Order:
                            tUsage := ReportSelections.Usage::"S.Order".AsInteger();
                        SalesHeader."Document Type"::"Blanket Order":
                            tUsage := ReportSelections.Usage::"S.Blanket".AsInteger();
                        SalesHeader."Document Type"::"Return Order":
                            tUsage := ReportSelections.Usage::"S.Return".AsInteger();
                    end;
                end;

            Database::"Purchase Header":
                begin
                    PurchHeader := DocVariant;
                    case PurchHeader."Document Type" of
                        PurchHeader."Document Type"::Invoice:
                            tUsage := ReportSelections.Usage::"P.Invoice".AsInteger();
                        PurchHeader."Document Type"::Quote:
                            tUsage := ReportSelections.Usage::"P.Quote".AsInteger();
                        PurchHeader."Document Type"::Order:
                            tUsage := ReportSelections.Usage::"P.Order".AsInteger();
                        PurchHeader."Document Type"::"Blanket Order":
                            tUsage := ReportSelections.Usage::"P.Blanket".AsInteger();
                        PurchHeader."Document Type"::"Return Order":
                            tUsage := ReportSelections.Usage::"P.Return".AsInteger();
                    end;
                end;

            Database::"Sales Shipment Header":
                tUsage := ReportSelections.Usage::"S.Shipment".AsInteger();
            Database::"Sales Invoice Header":
                tUsage := ReportSelections.Usage::"S.Invoice".AsInteger();
            Database::"Return Receipt Header":
                tUsage := ReportSelections.Usage::"S.Ret.Rcpt.".AsInteger();
            Database::"Sales Cr.Memo Header":
                tUsage := ReportSelections.Usage::"S.Cr.Memo".AsInteger();

            Database::"Purch. Rcpt. Header":
                tUsage := ReportSelections.Usage::"P.Receipt".AsInteger();
            Database::"Purch. Inv. Header":
                tUsage := ReportSelections.Usage::"P.Invoice".AsInteger();
            Database::"Return Shipment Header":
                tUsage := ReportSelections.Usage::"P.Ret.Shpt.".AsInteger();
            Database::"Purch. Cr. Memo Hdr.":
                tUsage := ReportSelections.Usage::"P.Cr.Memo".AsInteger();

            Database::"Reminder Header":
                tUsage := ReportSelections.Usage::"Rem.Test".AsInteger();
            Database::"Issued Reminder Header":
                tUsage := ReportSelections.Usage::Reminder.AsInteger();
            Database::"Finance Charge Memo Header":
                tUsage := ReportSelections.Usage::"Fin.Charge".AsInteger();

            Database::"Service Header":
                begin
                    ServiceHeader := DocVariant;
                    case ServiceHeader."Document Type" of
                        ServiceHeader."Document Type"::Quote:
                            tUsage := ReportSelections.Usage::"SM.Quote".AsInteger();
                        ServiceHeader."Document Type"::Order:
                            tUsage := ReportSelections.Usage::"SM.Order".AsInteger();
                    end;
                end;

            Database::"Service Shipment Header":
                tUsage := ReportSelections.Usage::"SM.Shipment".AsInteger();
            Database::"Service Invoice Header":
                tUsage := ReportSelections.Usage::"SM.Invoice".AsInteger();
            Database::"Service Cr.Memo Header":
                tUsage := ReportSelections.Usage::"SM.Credit Memo".AsInteger();
            Database::"Transfer Shipment Header":
                tUsage := ReportSelections.Usage::Inv2.AsInteger();
            Database::"Transfer Receipt Header":
                tUsage := ReportSelections.Usage::Inv3.AsInteger();

        end;

        if tUsage >= 0 then
            ReportSelections.SetRange(Usage, tUsage);
        exit(tUsage >= 0);
    end;

    local procedure InsertTempSalesShptLine(var TempSalesShptLine: Record "Sales Invoice Line" temporary; SalesShptLine: Record "Sales Shipment Line"; SalesInvLine: Record "Sales Invoice Line")
    var
        NextShptLineNo: Integer;
    begin
        NextShptLineNo += 1;
        TempSalesShptLine.Init();
        TempSalesShptLine."Document No." := SalesShptLine."Document No.";
        TempSalesShptLine."Line No." := NextShptLineNo;
        TempSalesShptLine.Type := SalesShptLine.Type;
        TempSalesShptLine."No." := SalesShptLine."No.";
        TempSalesShptLine."Variant Code" := SalesShptLine."Variant Code";
        TempSalesShptLine.Description := SalesShptLine.Description;
        TempSalesShptLine."VAT %" := SalesInvLine."VAT %";
        TempSalesShptLine.Quantity := SalesShptLine.Quantity;
        TempSalesShptLine."Quantity (Base)" := SalesShptLine."Quantity (Base)";
        TempSalesShptLine.Amount :=
        SalesInvLine.Amount / SalesInvLine."Quantity (Base)" * TempSalesShptLine."Quantity (Base)";
        TempSalesShptLine.Insert();

        InsertTempSalesShptDoc(TempSalesShptLine);
    end;

    local procedure InsertTempSalesShptDoc(TempSlsShptLine: Record "Sales Invoice Line" temporary)
    var
        SalesShptHeader: Record "Sales Shipment Header";
    begin

        TempSalesShptHeader.Reset();
        TempSalesShptHeader.DeleteAll();

        TempSalesShptHeader.SetRange("No.", TempSlsShptLine."Document No.");
        if TempSalesShptHeader.IsEmpty() then begin
            SalesShptHeader.Get(TempSlsShptLine."Document No.");
            TempSalesShptHeader := SalesShptHeader;
            TempSalesShptHeader.Insert();
        end;
    end;

}

