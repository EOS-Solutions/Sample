report 18122365 "EOS CWS - Shipment"
{
    DefaultLayout = RDLC;
    //RDLCLayout = './Source/Report/EOSCWSShipment.rdlc';
    RDLCLayout = './Source/Report/EOSCWSShipment.rdl';
    Caption = 'Shipment';
    PreviewMode = PrintLayout;
    // ApplicationArea = All;
    UsageCategory = None;

    dataset
    {
        dataitem("Sales Shipment Header"; "EOS CWS Shipment Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Destination No.", "No. Printed";
            RequestFilterHeading = 'CWS Posted Shipment';
            column(No_SalesShptHeader; "No.")
            {
            }
            column(PageCaption; PageCaptionCapLbl)
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(CompanyInfo2Picture; CompanyInfo2.Picture)
                    {
                    }
                    column(CompanyInfo1Picture; CompanyInfo1.Picture)
                    {
                    }
                    column(CompanyInfo3Picture; CompanyInfo3.Picture)
                    {
                    }
                    column(SalesShptCopyText; StrSubstNo(Text002Lbl, CopyText))
                    {
                    }
                    column(ShipToAddr1; ShipToAddr[1])
                    {
                    }
                    column(CompanyAddr1; CompanyAddr[1])
                    {
                    }
                    column(ShipToAddr2; ShipToAddr[2])
                    {
                    }
                    column(CompanyAddr2; CompanyAddr[2])
                    {
                    }
                    column(ShipToAddr3; ShipToAddr[3])
                    {
                    }
                    column(CompanyAddr3; CompanyAddr[3])
                    {
                    }
                    column(ShipToAddr4; ShipToAddr[4])
                    {
                    }
                    column(CompanyAddr4; CompanyAddr[4])
                    {
                    }
                    column(ShipToAddr5; ShipToAddr[5])
                    {
                    }
                    column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
                    {
                    }
                    column(ShipToAddr6; ShipToAddr[6])
                    {
                    }
                    column(CompanyInfoHomePage; CompanyInfo."Home Page")
                    {
                    }
                    column(CompanyInfoEmail; CompanyInfo."E-Mail")
                    {
                    }
                    column(CompanyInfoFaxNo; CompanyInfo."Fax No.")
                    {
                    }
                    column(CompanyInfoVATRegtnNo; CompanyInfo."VAT Registration No.")
                    {
                    }
                    column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
                    {
                    }
                    column(CompanyInfoBankName; CompanyInfo."Bank Name")
                    {
                    }
                    column(CompanyInfoBankAccountNo; CompanyInfo."Bank Account No.")
                    {
                    }
                    column(SelltoCustNo_SalesShptHeader; "Sales Shipment Header"."Destination No.")
                    {
                    }
                    column(DocDate_SalesShptHeader; Format("Sales Shipment Header"."Document Date", 0, 4))
                    {
                    }
                    column(SalesPersonText; SalesPersonText)
                    {
                    }
                    column(SalesPurchPersonName; SalesPurchPerson.Name)
                    {
                    }
                    column(ReferenceText; ReferenceText)
                    {
                    }
                    column(YourRef_SalesShptHeader; "Sales Shipment Header"."Your Reference")
                    {
                    }
                    column(ShipToAddr7; ShipToAddr[7])
                    {
                    }
                    column(ShipToAddr8; ShipToAddr[8])
                    {
                    }
                    column(CompanyAddr5; CompanyAddr[5])
                    {
                    }
                    column(CompanyAddr6; CompanyAddr[6])
                    {
                    }
                    column(ShptDate_SalesShptHeader; Format("Sales Shipment Header"."Shipment Date"))
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    column(ItemTrackingAppendixCaption; ItemTrackingAppendixCaptionLbl)
                    {
                    }
                    column(PhoneNoCaption; PhoneNoCaptionLbl)
                    {
                    }
                    column(VATRegNoCaption; VATRegNoCaptionLbl)
                    {
                    }
                    column(GiroNoCaption; GiroNoCaptionLbl)
                    {
                    }
                    column(BankNameCaption; BankNameCaptionLbl)
                    {
                    }
                    column(BankAccNoCaption; BankAccNoCaptionLbl)
                    {
                    }
                    column(ShipmentNoCaption; ShipmentNoCaptionLbl)
                    {
                    }
                    column(ShipmentDateCaption; ShipmentDateCaptionLbl)
                    {
                    }
                    column(HomePageCaption; HomePageCaptionLbl)
                    {
                    }
                    column(EmailCaption; EmailCaptionLbl)
                    {
                    }
                    column(DocumentDateCaption; DocumentDateCaptionLbl)
                    {
                    }
                    column(SelltoCustNo_SalesShptHeaderCaption; "Sales Shipment Header".FieldCaption("Destination No."))
                    {
                    }
                    column(OrderNoCaption_SalesShptHeader; OurDocumentNoLbl)
                    {
                    }
                    column(OrderNo_SalesShptHeader; "Sales Shipment Header"."External Document No.")
                    {
                    }
                    /* column(ExternalDocumentNoCaption_SalesShptHeader; 'Purchase Order No.')
                    {
                    } */
                    column(ExternalDocumentNo_SalesShptHeader; "Sales Shipment Header"."External Document No.")
                    {
                    }
                    dataitem(DimensionLoop1; "Integer")
                    {
                        DataItemLinkReference = "Sales Shipment Header";
                        DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                        column(DimText; DimText)
                        {
                        }
                        column(HeaderDimensionsCaption; HeaderDimensionsCaptionLbl)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not DimSetEntry1.FindSet() then
                                    CurrReport.Break();
                            end else
                                if not Continue then
                                    CurrReport.Break();

                            Clear(DimText);
                            Continue := false;
                            repeat
                                OldDimText := CopyStr(DimText, 1, MaxStrLen(OldDimText));
                                if DimText = '' then
                                    DimText := StrSubstNo('%1 - %2', DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code")
                                else
                                    DimText :=
                                      CopyStr(StrSubstNo(
                                        '%1; %2 - %3', DimText,
                                        DimSetEntry1."Dimension Code", DimSetEntry1."Dimension Value Code"), 1, MaxStrLen(DimText));
                                if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                    DimText := OldDimText;
                                    Continue := true;
                                    exit;
                                end;
                            until DimSetEntry1.Next() = 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowInternalInfo then
                                CurrReport.Break();
                        end;
                    }
                    dataitem("Sales Shipment Line"; "EOS CWS Shipment Line")
                    {
                        DataItemLink = "Document No." = FIELD("No.");
                        DataItemLinkReference = "Sales Shipment Header";
                        DataItemTableView = SORTING("Document No.", "Line No.");
                        column(Description_SalesShptLine; Description)
                        {
                        }
                        column(ShowInternalInfo; ShowInternalInfo)
                        {
                        }
                        column(ShowCorrectionLines; ShowCorrectionLines)
                        {
                        }
                        column(Type_SalesShptLine; Format(Type, 0, 2))
                        {
                        }
                        column(AsmHeaderExists; AsmHeaderExists)
                        {
                        }
                        column(DocumentNo_SalesShptLine; "Document No.")
                        {
                        }
                        column(LinNo; LinNo)
                        {
                        }
                        column(Qty_SalesShptLine; Quantity)
                        {
                        }
                        column(UOM_SalesShptLine; "Unit of Measure")
                        {
                        }
                        column(No_SalesShptLine; "No.")
                        {
                        }
                        column(LineNo_SalesShptLine; "Line No.")
                        {
                        }
                        column(Description_SalesShptLineCaption; FieldCaption(Description))
                        {
                        }
                        column(Qty_SalesShptLineCaption; FieldCaption(Quantity))
                        {
                        }
                        column(UOM_SalesShptLineCaption; FieldCaption("Unit of Measure"))
                        {
                        }
                        column(No_SalesShptLineCaption; FieldCaption("No."))
                        {
                        }
                        dataitem(DimensionLoop2; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
                            column(DimText1; DimText)
                            {
                            }
                            column(LineDimensionsCaption; LineDimensionsCaptionLbl)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if Number = 1 then begin
                                    if not DimSetEntry2.FindSet() then
                                        CurrReport.Break();
                                end else
                                    if not Continue then
                                        CurrReport.Break();

                                Clear(DimText);
                                Continue := false;
                                repeat
                                    OldDimText := CopyStr(DimText, 1, MaxStrLen(OldDimText));
                                    if DimText = '' then
                                        DimText := StrSubstNo('%1 - %2', DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code")
                                    else
                                        DimText :=
                                          CopyStr(StrSubstNo(
                                            '%1; %2 - %3', DimText,
                                            DimSetEntry2."Dimension Code", DimSetEntry2."Dimension Value Code"), 1, MaxStrLen(DimText));
                                    if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                                        DimText := OldDimText;
                                        Continue := true;
                                        exit;
                                    end;
                                until DimSetEntry2.Next() = 0;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not ShowInternalInfo then
                                    CurrReport.Break();
                            end;
                        }
                        dataitem(DisplayAsmInfo; "Integer")
                        {
                            DataItemTableView = SORTING(Number);
                            column(PostedAsmLineItemNo; BlanksForIndent() + PostedAsmLine."No.")
                            {
                            }
                            column(PostedAsmLineDescription; BlanksForIndent() + PostedAsmLine.Description)
                            {
                            }
                            column(PostedAsmLineQuantity; PostedAsmLine.Quantity)
                            {
                                DecimalPlaces = 0 : 5;
                            }
                            column(PostedAsmLineUOMCode; GetUnitOfMeasureDescr(PostedAsmLine."Unit of Measure Code"))
                            {
                            }

                            trigger OnAfterGetRecord()
                            var
                                ItemTranslation: Record "Item Translation";
                            begin
                                if Number = 1 then
                                    PostedAsmLine.FindSet()
                                else
                                    PostedAsmLine.Next();

                                if ItemTranslation.Get(PostedAsmLine."No.",
                                     PostedAsmLine."Variant Code",
                                     "Sales Shipment Header"."Language Code")
                                then
                                    PostedAsmLine.Description := ItemTranslation.Description;
                            end;

                            trigger OnPreDataItem()
                            begin
                                if not DisplayAssemblyInformation then
                                    CurrReport.Break();
                                if not AsmHeaderExists then
                                    CurrReport.Break();

                                PostedAsmLine.SetRange("Document No.", PostedAsmHeader."No.");
                                SetRange(Number, 1, PostedAsmLine.Count());
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            LinNo := "Line No.";
                            if not ShowCorrectionLines and Correction then
                                CurrReport.Skip();

                            DimSetEntry2.SetRange("Dimension Set ID", "Dimension Set ID");
                            if DisplayAssemblyInformation then
                                AsmHeaderExists := AsmToShipmentExists(PostedAsmHeader);
                        end;

                        trigger OnPostDataItem()
                        var
                            CWSShipmentLine: Record "EOS CWS Shipment Line";
                            SalesShipmentHeader: Record "Sales Shipment Header";
                            ReturnShipmentHeader: Record "Return Shipment Header";
                            TransferShipmentHeader: record "Transfer Shipment Line";
                            ServiceShipmentHeader: Record "Service Shipment Header";
                            TrackingSpecBuffer2: Record "Tracking Specification" temporary;
                            TrackingSpecEntryNo: Integer;
                            TrackingSpecCount2: integer;
                        begin
                            if ShowLotSN then begin
                                CWSShipmentLine.Reset();
                                CWSShipmentLine.SetRange("Document No.", "Sales Shipment Header"."No.");
                                case "Posted Source Document" of
                                    "Posted Source Document"::"Posted Shipment":
                                        begin
                                            if CWSShipmentLine.FindSet() then
                                                repeat
                                                    if SalesShipmentHeader.Get(CWSShipmentLine."Posted Source No.") then
                                                        SalesShipmentHeader.Mark(true);
                                                until CWSShipmentLine.Next() = 0;
                                            SalesShipmentHeader.MarkedOnly(true);
                                            if SalesShipmentHeader.FindSet() then
                                                repeat
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(true);
                                                    TrackingSpecCount2 := ItemTrackingDocMgt.RetrieveDocumentItemTracking(TrackingSpecBuffer2,
                                                    SalesShipmentHeader."No.", DATABASE::"Sales Shipment Header", 0);
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(false);

                                                    TrackingSpecCount := TrackingSpecCount + TrackingSpecCount2;
                                                    TrackingSpecBuffer2.Reset();
                                                    if TrackingSpecBuffer2.FindSet() then
                                                        repeat
                                                            TrackingSpecEntryNo := TrackingSpecEntryNo + 1;
                                                            TrackingSpecBuffer.TransferFields(TrackingSpecBuffer2);
                                                            TrackingSpecBuffer."Entry No." := TrackingSpecEntryNo;
                                                            TrackingSpecBuffer.Insert();

                                                            CWSShipmentLine.SetRange("Posted Source Document", CWSShipmentLine."Posted Source Document"::"Posted Shipment");
                                                            CWSShipmentLine.SetRange("Posted Source No.", TrackingSpecBuffer."Source ID");
                                                            CWSShipmentLine.SetRange("Posted Source Line No.", TrackingSpecBuffer."Source Ref. No.");
                                                            if CWSShipmentLine.FindSet() then begin
                                                                TrackingSpecBuffer."Source ID" := CWSShipmentLine."Document No.";
                                                                TrackingSpecBuffer."Source Ref. No." := CWSShipmentLine."Line No.";
                                                                TrackingSpecBuffer.Modify();
                                                            end;
                                                        until TrackingSpecBuffer2.Next() = 0;
                                                until SalesShipmentHeader.Next() = 0;
                                        end;
                                    "Posted Source Document"::"Posted Return Shipment":
                                        begin
                                            if CWSShipmentLine.FindSet() then
                                                repeat
                                                    if ReturnShipmentHeader.Get(CWSShipmentLine."Posted Source No.") then
                                                        ReturnShipmentHeader.Mark(true);
                                                until CWSShipmentLine.Next() = 0;
                                            ReturnShipmentHeader.MarkedOnly(true);
                                            if ReturnShipmentHeader.FindSet() then
                                                repeat
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(true);
                                                    TrackingSpecCount2 := ItemTrackingDocMgt.RetrieveDocumentItemTracking(TrackingSpecBuffer2,
                                                    ReturnShipmentHeader."No.", DATABASE::"Return Shipment Header", 0);
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(false);

                                                    TrackingSpecCount := TrackingSpecCount + TrackingSpecCount2;
                                                    TrackingSpecBuffer2.Reset();
                                                    if TrackingSpecBuffer2.FindSet() then
                                                        repeat
                                                            TrackingSpecEntryNo := TrackingSpecEntryNo + 1;
                                                            TrackingSpecBuffer.TransferFields(TrackingSpecBuffer2);
                                                            TrackingSpecBuffer."Entry No." := TrackingSpecEntryNo;
                                                            TrackingSpecBuffer.Insert();

                                                            CWSShipmentLine.SetRange("Posted Source Document", CWSShipmentLine."Posted Source Document"::"Posted Return Shipment");
                                                            CWSShipmentLine.SetRange("Posted Source No.", TrackingSpecBuffer."Source ID");
                                                            CWSShipmentLine.SetRange("Posted Source Line No.", TrackingSpecBuffer."Source Ref. No.");
                                                            if CWSShipmentLine.FindSet() then begin
                                                                TrackingSpecBuffer."Source ID" := CWSShipmentLine."Document No.";
                                                                TrackingSpecBuffer."Source Ref. No." := CWSShipmentLine."Line No.";
                                                                TrackingSpecBuffer.Modify();
                                                            end;
                                                        until TrackingSpecBuffer2.Next() = 0;
                                                until ReturnShipmentHeader.Next() = 0;
                                        end;
                                    "Posted Source Document"::"Posted Transfer Shipment":
                                        begin
                                            if CWSShipmentLine.FindSet() then
                                                repeat
                                                    if TransferShipmentHeader.Get(CWSShipmentLine."Posted Source No.") then
                                                        TransferShipmentHeader.Mark(true);
                                                until CWSShipmentLine.Next() = 0;
                                            TransferShipmentHeader.MarkedOnly(true);
                                            if TransferShipmentHeader.FindSet() then
                                                repeat
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(true);
                                                    TrackingSpecCount2 := ItemTrackingDocMgt.RetrieveDocumentItemTracking(TrackingSpecBuffer2,
                                                    TransferShipmentHeader."Document No.", DATABASE::"Transfer Shipment Header", 0);
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(false);

                                                    TrackingSpecCount := TrackingSpecCount + TrackingSpecCount2;
                                                    TrackingSpecBuffer2.Reset();
                                                    if TrackingSpecBuffer2.FindSet() then
                                                        repeat
                                                            TrackingSpecEntryNo := TrackingSpecEntryNo + 1;
                                                            TrackingSpecBuffer.TransferFields(TrackingSpecBuffer2);
                                                            TrackingSpecBuffer."Entry No." := TrackingSpecEntryNo;
                                                            TrackingSpecBuffer.Insert();

                                                            CWSShipmentLine.SetRange("Posted Source Document", CWSShipmentLine."Posted Source Document"::"Posted Transfer Shipment");
                                                            CWSShipmentLine.SetRange("Posted Source No.", TrackingSpecBuffer."Source ID");
                                                            CWSShipmentLine.SetRange("Posted Source Line No.", TrackingSpecBuffer."Source Ref. No.");
                                                            if CWSShipmentLine.FindSet() then begin
                                                                TrackingSpecBuffer."Source ID" := CWSShipmentLine."Document No.";
                                                                TrackingSpecBuffer."Source Ref. No." := CWSShipmentLine."Line No.";
                                                                TrackingSpecBuffer.Modify();
                                                            end;
                                                        until TrackingSpecBuffer2.Next() = 0;
                                                until SalesShipmentHeader.Next() = 0;
                                        end;
                                    "Posted Source Document"::"Posted Service Shipment":
                                        begin
                                            if CWSShipmentLine.FindSet() then
                                                repeat
                                                    if ServiceShipmentHeader.Get(CWSShipmentLine."Posted Source No.") then
                                                        ServiceShipmentHeader.Mark(true);
                                                until CWSShipmentLine.Next() = 0;
                                            ServiceShipmentHeader.MarkedOnly(true);
                                            if ServiceShipmentHeader.FindSet() then
                                                repeat
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(true);
                                                    TrackingSpecCount2 := ItemTrackingDocMgt.RetrieveDocumentItemTracking(TrackingSpecBuffer2,
                                                    ServiceShipmentHeader."No.", DATABASE::"Service Shipment Header", 0);
                                                    ItemTrackingDocMgt.SetRetrieveAsmItemTracking(false);

                                                    TrackingSpecCount := TrackingSpecCount + TrackingSpecCount2;
                                                    TrackingSpecBuffer2.Reset();
                                                    if TrackingSpecBuffer2.FindSet() then
                                                        repeat
                                                            TrackingSpecEntryNo := TrackingSpecEntryNo + 1;
                                                            TrackingSpecBuffer.TransferFields(TrackingSpecBuffer2);
                                                            TrackingSpecBuffer."Entry No." := TrackingSpecEntryNo;
                                                            TrackingSpecBuffer.Insert();

                                                            CWSShipmentLine.SetRange("Posted Source Document", CWSShipmentLine."Posted Source Document"::"Posted Service Shipment");
                                                            CWSShipmentLine.SetRange("Posted Source No.", TrackingSpecBuffer."Source ID");
                                                            CWSShipmentLine.SetRange("Posted Source Line No.", TrackingSpecBuffer."Source Ref. No.");
                                                            if CWSShipmentLine.FindSet() then begin
                                                                TrackingSpecBuffer."Source ID" := CWSShipmentLine."Document No.";
                                                                TrackingSpecBuffer."Source Ref. No." := CWSShipmentLine."Line No.";
                                                                TrackingSpecBuffer.Modify();
                                                            end;
                                                        until TrackingSpecBuffer2.Next() = 0;
                                                until ServiceShipmentHeader.Next() = 0;
                                        end;
                                end;
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            MoreLines := Find('+');
                            while MoreLines and (Description = '') and ("No." = '') and (Quantity = 0) do
                                MoreLines := Next(-1) <> 0;
                            if not MoreLines then
                                CurrReport.Break();
                            SetRange("Line No.", 0, "Line No.");
                        end;
                    }
                    dataitem(Total; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    }
                    dataitem(Total2; "Integer")
                    {
                        DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                        column(BilltoCustNo_SalesShptHeader; "Sales Shipment Header"."Bill/Pay-to No.")
                        {
                        }
                        column(CustAddr1; CustAddr[1])
                        {
                        }
                        column(CustAddr2; CustAddr[2])
                        {
                        }
                        column(CustAddr3; CustAddr[3])
                        {
                        }
                        column(CustAddr4; CustAddr[4])
                        {
                        }
                        column(CustAddr5; CustAddr[5])
                        {
                        }
                        column(CustAddr6; CustAddr[6])
                        {
                        }
                        column(CustAddr7; CustAddr[7])
                        {
                        }
                        column(CustAddr8; CustAddr[8])
                        {
                        }
                        column(BilltoAddressCaption; BilltoAddressCaptionLbl)
                        {
                        }
                        column(BilltoCustNo_SalesShptHeaderCaption; "Sales Shipment Header".FieldCaption("Bill/Pay-to No."))
                        {
                        }

                        trigger OnPreDataItem()
                        begin
                            if not ShowCustAddr then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(ItemTrackingLine; "Integer")
                    {
                        DataItemTableView = SORTING(Number);
                        column(TrackingSpecBufferNo; TrackingSpecBuffer."Item No.")
                        {
                        }
                        column(TrackingSpecBufferDesc; TrackingSpecBuffer.Description)
                        {
                        }
                        column(TrackingSpecBufferLotNo; TrackingSpecBuffer."Lot No.")
                        {
                        }
                        column(TrackingSpecBufferSerNo; TrackingSpecBuffer."Serial No.")
                        {
                        }
                        column(TrackingSpecBufferQty; TrackingSpecBuffer."Quantity (Base)")
                        {
                        }
                        column(ShowTotal; ShowTotal)
                        {
                        }
                        column(ShowGroup; ShowGroup)
                        {
                        }
                        column(QuantityCaption; QuantityCaptionLbl)
                        {
                        }
                        column(SerialNoCaption; SerialNoCaptionLbl)
                        {
                        }
                        column(LotNoCaption; LotNoCaptionLbl)
                        {
                        }
                        column(DescriptionCaption; DescriptionCaptionLbl)
                        {
                        }
                        column(NoCaption; NoCaptionLbl)
                        {
                        }
                        dataitem(TotalItemTracking; "Integer")
                        {
                            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                            column(Quantity1; TotalQty)
                            {
                            }
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TrackingSpecBuffer.FindSet()
                            else
                                TrackingSpecBuffer.Next();

                            if not ShowCorrectionLines and TrackingSpecBuffer.Correction then
                                CurrReport.Skip();
                            if TrackingSpecBuffer.Correction then
                                TrackingSpecBuffer."Quantity (Base)" := -TrackingSpecBuffer."Quantity (Base)";

                            ShowTotal := false;
                            if ItemTrackingAppendix.IsStartNewGroup(TrackingSpecBuffer) then
                                ShowTotal := true;

                            ShowGroup := false;
                            if (TrackingSpecBuffer."Source Ref. No." <> OldRefNo) or
                               (TrackingSpecBuffer."Item No." <> OldNo)
                            then begin
                                OldRefNo := TrackingSpecBuffer."Source Ref. No.";
                                OldNo := TrackingSpecBuffer."Item No.";
                                TotalQty := 0;
                            end else
                                ShowGroup := true;
                            TotalQty += TrackingSpecBuffer."Quantity (Base)";
                        end;

                        trigger OnPreDataItem()
                        begin
                            if TrackingSpecCount = 0 then
                                CurrReport.Break();
                            SetRange(Number, 1, TrackingSpecCount);
                            TrackingSpecBuffer.SetCurrentKey("Source ID", "Source Type", TrackingSpecBuffer."Source Subtype", TrackingSpecBuffer."Source Batch Name",
                              TrackingSpecBuffer."Source Prod. Order Line", TrackingSpecBuffer."Source Ref. No.");
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        // Item Tracking:
                        if ShowLotSN then begin
                            TrackingSpecCount := 0;
                            OldRefNo := 0;
                            ShowGroup := false;
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then begin
                        CopyText := FormatDocument.GetCOPYText();
                        OutputNo += 1;
                    end;
                    TotalQty := 0;           // Item Tracking
                end;

                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        CODEUNIT.Run(CODEUNIT::"EOS CWS Shpt.-Printed", "Sales Shipment Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := 1 + Abs(NoOfCopies);
                    CopyText := '';
                    SetRange(Number, 1, NoOfLoops);
                    OutputNo := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");

                FormatAddressFields("Sales Shipment Header");
                FormatDocumentFields("Sales Shipment Header");

                DimSetEntry1.SetRange("Dimension Set ID", 0); //On Header no Dimensions //Eventualmente cancellare il DataItem //TO DO
            end;

            trigger OnPostDataItem()
            begin
                OnAfterPostDataItem("Sales Shipment Header");
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopies1; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies how many copies of the document to print.';
                    }
                    field(ShowInternalInfo1; ShowInternalInfo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Internal Information';
                        ToolTip = 'Specifies if the document shows internal information.';
                    }
                    //NON SI PUO' GESTIRE PER ORA
                    /*  field(LogInteraction; LogInteraction)
                     {
                         ApplicationArea = Basic, Suite;
                         Caption = 'Log Interaction';
                         Enabled = LogInteractionEnable;
                         ToolTip = 'Specifies if you want to record the reports that you print as interactions.';
                     } */
                    field("Show Correction Lines"; ShowCorrectionLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Correction Lines';
                        ToolTip = 'Specifies if the correction lines of an undoing of quantity posting will be shown on the report.';
                    }
                    field(ShowLotSN1; ShowLotSN)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Serial/Lot Number Appendix';
                        ToolTip = 'Specifies if you want to print an appendix to the shipment report showing the lot and serial numbers in the shipment.';
                    }
                    field(DisplayAsmInfo; DisplayAssemblyInformation)
                    {
                        ApplicationArea = Assembly;
                        Caption = 'Show Assembly Components';
                        ToolTip = 'Specifies if you want the report to include information about components that were used in linked assembly orders that supplied the item(s) being sold.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction();
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    var
        OurDocumentNoLbl: label 'Our Document No.';

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        SalesSetup.Get();
        FormatDocument.SetLogoPosition(SalesSetup."Logo Position on Documents", CompanyInfo1, CompanyInfo2, CompanyInfo3);

        OnAfterInitReport();
    end;

    trigger OnPostReport()
    begin
        //NON SI PUO' GESTIRE PER ORA
        /*  if LogInteraction and not IsReportInPreviewMode then
             if "Sales Shipment Header".FindSet then
                 repeat
                     SegManagement.LogDocument(
                       5, "Sales Shipment Header"."No.", 0, 0, DATABASE::Customer, "Sales Shipment Header"."Source No.",
                       "Sales Shipment Header"."Salesperson Code", '', //TO DO "Sales Shipment Header"."Campaign No.",
                       "Sales Shipment Header"."Posting Description", '');
                 until "Sales Shipment Header".Next = 0; */
    end;

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage() then
            InitLogInteraction();
        AsmHeaderExists := false;
    end;

    var
        SalesPurchPerson: Record "Salesperson/Purchaser";
        CompanyInfo: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        SalesSetup: Record "Sales & Receivables Setup";
        DimSetEntry1: Record "Dimension Set Entry";
        DimSetEntry2: Record "Dimension Set Entry";
        TrackingSpecBuffer: Record "Tracking Specification" temporary;
        PostedAsmHeader: Record "Posted Assembly Header";
        PostedAsmLine: Record "Posted Assembly Line";
        RespCenter: Record "Responsibility Center";
        ItemTrackingAppendix: Report "Item Tracking Appendix";
        Language: Codeunit Language;
        FormatAddr: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        SegManagement: Codeunit SegManagement;
        ItemTrackingDocMgt: Codeunit "Item Tracking Doc. Management";
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        CompanyAddr: array[8] of Text[100];
        SalesPersonText: Text[50];
        ReferenceText: Text[80];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        OutputNo: Integer;
        NoOfLoops: Integer;
        TrackingSpecCount: Integer;
        OldRefNo: Integer;
        OldNo: Code[20];
        CopyText: Text[30];
        ShowCustAddr: Boolean;
        DimText: Text[120];
        OldDimText: Text[75];
        ShowInternalInfo: Boolean;
        Continue: Boolean;
        LogInteraction: Boolean;
        ShowCorrectionLines: Boolean;
        ShowLotSN: Boolean;
        ShowTotal: Boolean;
        ShowGroup: Boolean;
        TotalQty: Decimal;
        [InDataSet]
        LogInteractionEnable: Boolean;
        DisplayAssemblyInformation: Boolean;
        AsmHeaderExists: Boolean;
        LinNo: Integer;
        ItemTrackingAppendixCaptionLbl: Label 'Item Tracking - Appendix';
        PhoneNoCaptionLbl: Label 'Phone No.';
        VATRegNoCaptionLbl: Label 'VAT Reg. No.';
        GiroNoCaptionLbl: Label 'Giro No.';
        BankNameCaptionLbl: Label 'Bank';
        BankAccNoCaptionLbl: Label 'Account No.';
        ShipmentNoCaptionLbl: Label 'Shipment No.';
        ShipmentDateCaptionLbl: Label 'Shipment Date';
        HomePageCaptionLbl: Label 'Home Page';
        EmailCaptionLbl: Label 'Email';
        DocumentDateCaptionLbl: Label 'Document Date';
        HeaderDimensionsCaptionLbl: Label 'Header Dimensions';
        LineDimensionsCaptionLbl: Label 'Line Dimensions';
        BilltoAddressCaptionLbl: Label 'Bill-to Address';
        QuantityCaptionLbl: Label 'Quantity';
        SerialNoCaptionLbl: Label 'Serial No.';
        LotNoCaptionLbl: Label 'Lot No.';
        DescriptionCaptionLbl: Label 'Description';
        NoCaptionLbl: Label 'No.';
        PageCaptionCapLbl: Label 'Page %1 of %2';
        Text002Lbl: Label 'Shipment %1', Comment = '%1 = Document No.';

    procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractTmplCode(5) <> '';
    end;

    procedure InitializeRequest(NewNoOfCopies: Integer; NewShowInternalInfo: Boolean; NewLogInteraction: Boolean; NewShowCorrectionLines: Boolean; NewShowLotSN: Boolean; DisplayAsmInfo: Boolean)
    begin
        NoOfCopies := NewNoOfCopies;
        ShowInternalInfo := NewShowInternalInfo;
        LogInteraction := NewLogInteraction;
        ShowCorrectionLines := NewShowCorrectionLines;
        ShowLotSN := NewShowLotSN;
        DisplayAssemblyInformation := DisplayAsmInfo;
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview() or MailManagement.IsHandlingGetEmailBody());
    end;

    //TO DO
    local procedure FormatAddressFields(ShipmentHeader: Record "EOS CWS Shipment Header") //TO DO
    var
        SalesShipmentHeader: record "Sales Shipment Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        TransferShipmentHeader: record "Transfer Shipment Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        CWSSalesMgmt: Codeunit "EOS CWS Sales Mgmt";
        CWSReturnMgmt: Codeunit "EOS CWS Return Mgmt";
        CWSTransferMgmt: Codeunit "EOS CWS Transfer Mgmt";
        CWSServiceMgmt: codeunit "EOS CWS Service Mgmt";
    begin
        case ShipmentHeader."Source Document" of
            ShipmentHeader."Source Document"::"Sales Order":
                begin
                    CWSSalesMgmt.TransferAddressFieldsToSourceHeader(ShipmentHeader, SalesShipmentHeader);
                    FormatAddr.GetCompanyAddr(ShipmentHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
                    FormatAddr.SalesShptShipTo(ShipToAddr, SalesShipmentHeader);
                    ShowCustAddr := FormatAddr.SalesShptBillTo(CustAddr, ShipToAddr, SalesShipmentHeader);
                end;
            ShipmentHeader."Source Document"::"Purchase Return Order":
                begin
                    CWSReturnMgmt.TransferAddressFieldsToSourceHeader(ShipmentHeader, ReturnShipmentHeader);
                    FormatAddr.GetCompanyAddr(ShipmentHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
                    FormatAddr.PurchShptBuyFrom(ShipToAddr, ReturnShipmentHeader);
                    FormatAddr.PurchShptShipTo(CustAddr, ReturnShipmentHeader);
                end;
            ShipmentHeader."Source Document"::"Outbound Transfer":
                begin
                    CWSTransferMgmt.TransferAddressFieldsToSourceHeader(ShipmentHeader, TransferShipmentHeader);
                    FormatAddr.GetCompanyAddr(ShipmentHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
                    FormatAddr.TransferShptTransferTo(ShipToAddr, TransferShipmentHeader);
                    FormatAddr.TransferShptTransferTo(CustAddr, TransferShipmentHeader);
                end;
            ShipmentHeader."Source Document"::"Service Order":
                begin
                    CWSServiceMgmt.TransferAddressFieldsToSourceHeader(ShipmentHeader, ServiceShipmentHeader);
                    FormatAddr.GetCompanyAddr(ShipmentHeader."Responsibility Center", RespCenter, CompanyInfo, CompanyAddr);
                    FormatAddr.ServiceShptShipTo(ShipToAddr, ServiceShipmentHeader);
                    ShowCustAddr := FormatAddr.ServiceShptBillTo(CustAddr, ShipToAddr, ServiceShipmentHeader);
                end;
        end;
    end;

    local procedure FormatDocumentFields(ShipmentHeader: Record "EOS CWS Shipment Header")
    begin
        FormatDocument.SetSalesPerson(SalesPurchPerson, ShipmentHeader."Salesperson Code", SalesPersonText);
        ReferenceText := FormatDocument.SetText(ShipmentHeader."Your Reference" <> '', Copystr(ShipmentHeader.FieldCaption("Your Reference"), 1, 80));
    end;

    local procedure GetUnitOfMeasureDescr(UOMCode: Code[10]): Text[50]
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UOMCode) then
            exit(UOMCode);
        exit(UnitOfMeasure.Description);
    end;

    procedure BlanksForIndent(): Text[10]
    begin
        exit(PadStr('', 2, ' '));
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterInitReport()
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterPostDataItem(var SalesShipmentHeader: Record "EOS CWS Shipment Header")
    begin
    end;
}

