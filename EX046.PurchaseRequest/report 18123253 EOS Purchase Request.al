report 18123253 "EOS Purchase Request"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/report 18123253 EOS Purchase Request.rdlc';
    Caption = 'Purchase Req. Document';
    UsageCategory = None;

    dataset
    {

        dataitem("EOS Purch. Request Header"; "EOS Purch. Request Header")
        {

            DataItemTableView = sorting("EOS No.");

            column(HeaderImage; TempHeaderImage.Content)
            {
            }
            column(FooterImage; TempFooterImage.Content)
            {
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
            column(DocumentNo; "EOS No.")
            {
            }
            column(UserId; "EOS User ID")
            {
            }
            column(PostingDate; "EOS Creation Date")
            {
            }
            column(Salesperson; Salesperson.Name)
            {
            }
            column(OperatorName; format(Resource.Name))
            {
            }
            column(BuyFromVendNo; Vendor."No.")
            {
            }
            column(BuyFromAddress; BuyFromAddress())
            {
            }
            column(VendorContact; Vendor.Name)
            {
            }
            column(VendorEMail; Vendor."E-Mail")
            {
            }
            /*column(Reason; ReasonCode.GetDescInLanguage(Vendor."Language Code"))
            {
            }*/
            column(VATRegNo; Vendor."VAT Registration No.")
            {
            }
            column(FiscalCode; getFiscalCode())
            {
            }
            column(AddressPosition; Format(Position, 0, 9))
            {
            }
            column(YourReference; "EOS Description")
            {
            }
            column(OrderDate; "EOS Creation Date")
            {
            }
            column(Dim1Name; Dim1Name)
            {
            }
            column(Dim2Name; Dim2Name)
            {
            }
            dataitem("EOS Purch. Request Line"; "EOS Purch. Request Line")
            {
                DataItemLinkReference = "EOS Purch. Request Header";
                DataItemLink = "EOS Purch. Requisition No." = field("EOS No.");

                column(Line_Type; Format("EOS Type", 0, 2))
                {
                }
                column(Line_LineType; Format("EOS Document Type", 0, 2))
                {
                }
                column(Line_LineNo; "EOS Line No.")
                {
                }
                column(Line_ItemNo; "EOS No.")
                {
                }
                column(Line_Description; "EOS Description")
                {
                }
                column(Line_Quantity; "EOS Quantity")
                {
                }
                column(Line_DimValue1; DimValue1Code)
                {
                }
                column(Line_DimValue2; DimValue2Code)
                {
                }
                column(Line_UoMCode; "EOS Unit of Measure Code")
                {
                }
                column(Line_LineDiscountPerc; "EOS Line Discount %")
                {
                }
                column(Line_UnitPrice; "EOS Direct Unit Cost")
                {
                }
                column(Line_Amount; "Line Amount")
                {
                }
                column(Line_Type_Desc; Format("EOS Type"))
                {
                }
                //per line
                trigger OnAfterGetRecord()
                begin
                    DimMgt.UpdateGlobalDimFromDimSetID("EOS Dimension Set ID", DimValue1Code, DimValue2Code);
                end;
            }
            dataitem(VATAmountLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);

                trigger OnAfterGetRecord()
                var
                    recRef: RecordRef;
                    ls: List Of [Text];
                begin
                    if Number <= ArrayLen(VATLine) then begin
                        TempVATAmountLine.GetLine(Number);
                        recRef.Open(Database::"VAT Amount Line");
                        if recRef.FieldExist(12110) then
                            recRef.Field(12110).CalcField();

                        ls.Add(TempVATAmountLine."VAT Identifier");
                        ls.Add(Format(TempVATAmountLine."VAT %"));
                        if recRef.FieldExist(12110) then
                            ls.Add(recRef.Field(12110).Value());
                        ls.Add(Format(TempVATAmountLine."VAT Base", 0, AutoFormat(GetCurrencyCode())));
                        ls.Add(Format(TempVATAmountLine."VAT Amount", 0, AutoFormat(GetCurrencyCode())));
                        ls.Add(Format(TempVATAmountLine."Invoice Discount Amount", 0, AutoFormat(GetCurrencyCode())));
                        VATLine[Number] := Compose(ls);
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, TempVATAmountLine.Count());
                    Clear(VATLine);
                end;
            }
            dataitem(PaymentLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);

                trigger OnAfterGetRecord()
                var
                    ls: List Of [Text];
                begin

                    if Number <= ArrayLen(PaymentLine) then
                        if IsIT then begin
                            if Number = 1 then
                                TmpPaymentLine.FindFirst()
                            else
                                TmpPaymentLine.Next();

                            ls.Add(Format(TmpPaymentLine.Field(8).Value()));
                            ls.Add(Format(TmpPaymentLine.Field(11).Value(), 0, AutoFormat(GetCurrencyCode())));
                            PaymentLine[Number] := Compose(ls);
                        end;
                end;

                trigger OnPreDataItem()
                begin
                    if IsIT then
                        SetRange(Number, 1, TmpPaymentLine.Count())
                    else
                        SetRange(Number, 1);
                    Clear(PaymentLine);

                end;
            }
            dataitem(Totals; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(VATLine1; VATLine[1])
                {
                }
                column(VATLine2; VATLine[2])
                {
                }
                column(VATLine3; VATLine[3])
                {
                }
                column(VATLine4; VATLine[4])
                {
                }
                column(PaymentLine1; PaymentLine[1])
                {
                }
                column(PaymentLine2; PaymentLine[2])
                {
                }
                column(PaymentLine3; PaymentLine[3])
                {
                }
                column(PaymentLine4; PaymentLine[4])
                {
                }
                column(VATLineCurrencyCode; GetCurrencyCode())
                {
                }
                column(VATLineTotal; TempVATAmountLine."VAT Base" + TempVATAmountLine."Invoice Discount Amount")
                {
                }
                column(VATLineInvDiscTotal; TempVATAmountLine."Invoice Discount Amount")
                {
                }
                column(VATLineBaseTotal; TempVATAmountLine."VAT Base")
                {
                }
                column(VATLineAmountTotal; TempVATAmountLine."VAT Amount")
                {
                }
                column(VATLineAmountInclVATTotal; TempVATAmountLine."Amount Including VAT")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    TempVATAmountLine.Reset();
                    TempVATAmountLine.CalcSums(
                      "Invoice Discount Amount",
                      "VAT Base", "VAT Amount",
                      "Amount Including VAT");
                end;
            }


            // per header
            trigger OnAfterGetRecord()
            var
                Dim: Record Dimension;
            begin
                IF NOT Vendor.Get("EOS Purch. Request Header"."EOS Vendor No.") then
                    Clear(Vendor);

                GLSetup.Get();
                if Dim.Get(GLSetup."Global Dimension 1 Code") then
                    Dim1Name := Dim.Name;
                if Dim.Get(GLSetup."Global Dimension 2 Code") then
                    Dim2Name := Dim.Name;

                if not Location.Get("EOS Purch. Request Header"."EOS Location Code") then
                    Clear(Location);
                Clear(ReasonCode);

                if not Salesperson.Get(Vendor."Purchaser Code") then
                    Clear(Salesperson);

                if not Resource.Get("EOS Purch. Request Header"."EOS Requester No.") then
                    Clear(Resource);

            end;

            trigger OnPreDataItem()
            var
            begin
                SetRange("EOS Purch. Request Header"."EOS No.", DocNo);
            end;
        }


    }


    requestpage
    {

        layout
        {
            area(Content)
            {

                group(GroupName)
                {
                    Caption = 'Purchasing Request document';
                    field("EOS No."; DocNo)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Header No.';
                        Caption = 'Header No.';
                    }
                    field("EOS Position"; Position)
                    {
                        ApplicationArea = All;
                        Caption = 'Header Position';
                        OptionCaption = 'Right,Left';
                        ToolTip = 'Header Position';
                    }
                }
            }
        }
    }
    labels
    {
        DocumentNo_Caption = 'No.';
        PostingDate_Caption = 'Date';
        User_Caption = 'User';
        OperatorName_Caption = 'Requester';
        VendorNo_Caption = 'Vendor No.';
        VendorContact_Caption = 'Contact';
        VendorMail_Caption = 'E-Mail';
        PaymentTerms_Caption = 'Payment terms';
        PaymentMethod_Caption = 'Payment method';
        Reason_Caption = 'Transport reason';
        VATRegNo_Caption = 'VAT Reg.';
        FiscalCode_Caption = 'Fiscal code';
        ShptMethod_Caption = 'Shipment meth.';
        ShptBy_Caption = 'Shpt. by';
        ShpAgent_Caption = 'Shipping agent';
        Page_Caption = 'Page';
        Payment_DueDate_Caption = 'Due Date';
        Payment_Amount_Caption = 'Amount';
        YourReference_Caption = 'Description';
        OrderDate_Caption = 'Order Date';
        ShipmentDate_Caption = 'Shpt. Date';
        Line_ItemNo_Caption = 'No.';
        Line_Description_Caption = 'Description';
        Line_Quantity_Caption = 'Quantity';
        Line_UoM_Caption = 'U.M.';
        Line_Amount_Caption = 'Amount';
        Line_UnitPrice_Caption = 'Price';
        Line_LineDiscountPerc_Caption = 'Disc. %';
        Line_VATIdentifier_Caption = 'VAT';
        Line_ShipmentDate_Caption = 'Shpt. Date';
        Line_Type_Descr_Caption = 'Type';
    }

    var
        GLSetup: Record "General Ledger Setup";
        Location: Record Location;
        ReasonCode: Record "Reason Code";
        Resource: Record Resource;
        Vendor: Record Vendor;
        Salesperson: Record "Salesperson/Purchaser";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        CompanyInfo: Record "Company Information";
        TempFooterImage: Record "EOS BlobSpec" temporary;
        TempHeaderImage: Record "EOS BlobSpec" temporary;
        Currency: Record Currency;
        DimMgt: Codeunit DimensionManagement;
        TmpPaymentLine: RecordRef;
        VATLine: array[4] of Text;
        PaymentLine: array[4] of Text;
        DimValue1Code: code[20];
        DimValue2Code: Code[20];
        DocNo: Code[20];
        Dim1Name: Text;
        Dim2Name: Text;
        ReportTitleLbl: Label 'Purchasing Request';
        Position: Option Right,Left;
        IsIT: Boolean;

    trigger OnInitReport()
    begin
        IsIT := HasPostedPaymentLine();
        if CompanyInfo.Get() then begin

            CompanyInfo.CalcFields(Picture);

            TempHeaderImage.Content := CompanyInfo.Picture;
            TempFooterImage.Content := CompanyInfo.Picture;
        end;
    end;



    [TryFunction()]
    local procedure HasPostedPaymentLine()
    begin
        TmpPaymentLine.Open(12171, true);
    end;

    local procedure BuyFromAddress(): Text
    var
        FormatAddr: Codeunit "EOS Format Address";
        AddrArray: array[8] of Text[50];
    begin
        FormatAddr.FormatAddr(
        AddrArray, Vendor.Name, Vendor."Name 2", Vendor.Contact, Vendor.Address,
        Vendor."Address 2", Vendor.City, Vendor."Post Code", Vendor."Country/Region Code",
        Vendor."Country/Region Code");
        EXIT(GetAddressString(AddrArray));
    end;

    local procedure GetAddressString(AddrArray: Array[8] of Text[50]): Text
    var
        EOSLibEXT: Codeunit "EOS Library EXT";
        ResText: Text;
        i: Integer;
    begin
        FOR i := 1 TO ARRAYLEN(AddrArray) DO
            IF AddrArray[i] <> '' THEN
                IF ResText = '' THEN
                    ResText := AddrArray[i]
                ELSE
                    ResText := ResText + EOSLibEXT.NewLine() + AddrArray[i];
        EXIT(ResText);
    end;

    local procedure getFiscalCode(): Text
    var
        recRef: RecordRef;
    begin
        recRef.GetTable(Vendor);
        if recRef.FieldExist(12101) then
            exit(recRef.Field(12101).Value())
        else
            exit('');
    end;

    local procedure GetCurrencyCode(): Text[80]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if GeneralLedgerSetup.Get() then
            exit(GeneralLedgerSetup."LCY Code")
        else
            exit('');
    end;

    local procedure Compose(var ls: List Of [Text]): Text
    var
        res: Text;
        i: Integer;
    begin
        for i := 1 to ls.Count() do
            if res = '' then
                res := Format(ls.Get(i))
            else
                res := res + GetSeparator() + Format(ls.Get(i));

        exit(res);

    end;

    local procedure GetSeparator() Result: Text[1]
    begin
        Result[1] := 177;
    end;

    procedure SetParameter(No: Code[20])
    var
    begin
        DocNo := No;
    end;

    local procedure AutoFormat(AutoFormatExpr: Text[80]): Text[80]
    var
        FormatLbl: Label '<Precision,%1><Standard Format,0>', Locked = true;
    begin
        if AutoFormatExpr = '' then
            exit(STRSUBSTNO(FormatLbl, GLSetup."Amount Decimal Places"));
        if GetCurrency(COPYSTR(AutoFormatExpr, 1, 10)) AND
           (Currency."Amount Decimal Places" <> '')
        then
            exit(STRSUBSTNO(FormatLbl, Currency."Amount Decimal Places"));
        exit(STRSUBSTNO(FormatLbl, GLSetup."Amount Decimal Places"));
    end;

    local procedure GetCurrency(CurrencyCode: Code[10]): Boolean
    begin
        if CurrencyCode = Currency.Code then
            exit(true);
        if CurrencyCode = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision();
            exit(true);
        end;
        exit(Currency.Get(CurrencyCode));
    end;
}