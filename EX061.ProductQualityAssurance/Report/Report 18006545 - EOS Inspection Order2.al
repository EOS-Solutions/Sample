report 18006545 "EOS Inspection Order2"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\Source\Report\InspectionOrder2.rdlc';

    Caption = 'Inspection Order (PQA)';
    PreviewMode = PrintLayout;
    UsageCategory = None;

    dataset
    {
        dataitem("Inspection Order Header"; "EOS Inspection Order Header")
        {
            DataItemTableView = SORTING("Inspection Type", "Item No.", "Customer/Vendor No.", "Date of Inspection Result") ORDER(Ascending);
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(Title; Title)
            {
            }
            column(HeaderImage; CompanyInformation.Picture)
            {
            }
            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(CurrReport_PAGENO; '')
            {
            }
            column(USERID; USERID)
            {
            }
            column(Inspection_Order_Header__No__; "No.")
            {
            }
            column(Inspection_Order_Header__Inspection_Type_; "Inspection Type")
            {
            }
            column(Inspection_Order_Header__Ref__Document_No__; "Ref. Document No.")
            {
            }
            column(Inspection_Order_Header__Ref__Line_No__; "Ref. Line No.")
            {
            }
            column(Inspection_Order_Header__Posting_Date_; "Posting Date")
            {
            }
            column(Inspection_Order_Header__Document_Date_; "Document Date")
            {
            }
            column(Inspection_Order_Header__Item_No__; "Item No.")
            {
            }
            column(Inspection_Order_Header__Item_Descr__; Item.Description)
            {
            }
            column(Inspection_Order_Header__Variant_Code_; "Variant Code")
            {
            }
            column(Inspection_Order_Header__Location_Code_; "Location Code" + ' ' + Location.Name)
            {
            }
            column(Inspection_Order_Header__Lot_No__; "Lot No.")
            {
            }
            column(Inspection_Order_Header__Serial_No__; "Serial No.")
            {
            }
            column(Inspection_Order_Header__Inspection_Result_; "Inspection Result")
            {
            }
            column(Inspection_Order_Header__Date_of_Inspection_Result_; "Date of Inspection Result")
            {
            }
            column(Inspection_Order_Header__Inspection_Result_by_; "Inspection Result by")
            {
            }
            column(Inspection_Order_Header_Certificate; Certificate)
            {
            }
            column(Inspection_Order_Header__Quality_Number_; "Quality Number")
            {
            }
            column(Inspection_Order_Header__Inspection_Plan_No__; "Inspection Plan No.")
            {
            }
            column(Inspection_Order_Header_Quantity; Quantity)
            {
            }
            column(Inspection_Order_Header_ActualQuantity; GetActualQuantity())
            {
                DecimalPlaces = 0 : 5;
            }
            column(Inspection_Order_Header__Inspection_Order_Header__Description; "Inspection Order Header".Description)
            {
            }
            column(Inspection_Order_Header__Sample_Size_; "Sample Size")
            {
            }
            column(Inspection_Order_HeaderCaption; Inspection_Order_HeaderCaptionLbl)
            {
            }
            column(CustomerVendorNo_InspectionOrderHeader; "Inspection Order Header"."Customer/Vendor No." + ' ' + Vendor.Name)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Inspection_Order_Header__No__Caption; FIELDCAPTION("No."))
            {
            }
            column(Inspection_Order_Header__Inspection_Type_Caption; FIELDCAPTION("Inspection Type"))
            {
            }
            column(Inspection_Order_Header__Ref__Document_No__Caption; FIELDCAPTION("Ref. Document No."))
            {
            }
            column(Inspection_Order_Header__Ref__Line_No__Caption; FIELDCAPTION("Ref. Line No."))
            {
            }
            column(Inspection_Order_Header__Posting_Date_Caption; FIELDCAPTION("Posting Date"))
            {
            }
            column(Inspection_Order_Header__Document_Date_Caption; FIELDCAPTION("Document Date"))
            {
            }
            column(Inspection_Order_Header__Item_No__Caption; FIELDCAPTION("Item No."))
            {
            }
            column(Inspection_Order_Header__Variant_Code_Caption; FIELDCAPTION("Variant Code"))
            {
            }
            column(Inspection_Order_Header__Location_Code_Caption; FIELDCAPTION("Location Code"))
            {
            }
            column(Inspection_Order_Header__Lot_No__Caption; FIELDCAPTION("Lot No."))
            {
            }
            column(Inspection_Order_Header__Serial_No__Caption; FIELDCAPTION("Serial No."))
            {
            }
            column(Inspection_Order_Header__Inspection_Result_Caption; FIELDCAPTION("Inspection Result"))
            {
            }
            column(Inspection_Order_Header__Date_of_Inspection_Result_Caption; FIELDCAPTION("Date of Inspection Result"))
            {
            }
            column(Inspection_Order_Header__Inspection_Result_by_Caption; FIELDCAPTION("Inspection Result by"))
            {
            }
            column(Inspection_Order_Header_CertificateCaption; FIELDCAPTION(Certificate))
            {
            }
            column(Inspection_Order_Header__Quality_Number_Caption; FIELDCAPTION("Quality Number"))
            {
            }
            column(Inspection_Order_Header__Inspection_Plan_No__Caption; FIELDCAPTION("Inspection Plan No."))
            {
            }
            column(Inspection_Order_Header_QuantityCaption; FIELDCAPTION(Quantity))
            {
            }
            column(DescriptionCaption; DescriptionCaptionLbl)
            {
            }
            column(Inspection_Order_Header__Sample_Size_Caption; FIELDCAPTION("Sample Size"))
            {
            }
            column(Inspection_Order_Header_Show_Lines; ShowLines)
            {
            }
            column(CurrReportLanguage; TextNLSLbl)
            {

            }
            column(HeaderComment; GetCommentString(TRUE))
            {
            }
            column(NonComplianceNo_InspectionOrderHeader; "Inspection Order Header"."Non-Compliance No.")
            {
                IncludeCaption = true;
            }
            column(YourReference_InspectionOrderHeader; "Inspection Order Header"."Your Reference")
            {
                IncludeCaption = true;
            }
            column(VendorShipmentNo_InspectionOrderHeader; "Inspection Order Header"."Vendor Shipment No.")
            {
                IncludeCaption = true;
            }
            column(VendorShipmentDate_InspectionOrderHeader; "Inspection Order Header"."Posting Date")
            {
                IncludeCaption = true;
            }
            column(BlanketOrderNo_InspectionOrderHeader; DocumentNo)
            {
            }
            column(New_Title_Caption; New_Title_CaptionLbl)
            {
            }
            dataitem("Inspection Order Line"; "EOS Inspection Order Line")
            {
                DataItemLink = "Inspection Order No." = FIELD("No.");
                DataItemTableView = SORTING("Inspection Order No.", "Line No.");
                column(Inspection_Order_Line__Inspection_Order_Line__Position; "Inspection Order Line".Position)
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Parameter_No__; "Inspection Order Line"."Parameter No.")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line__Description; "Inspection Order Line".Description)
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line__Findings; "Inspection Order Line".Findings)
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Inspection_Result_; "Inspection Order Line"."Inspection Result")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Unit_of_Measure_Code_; "Inspection Order Line"."Unit of Measure Code")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line__Attribute; "Inspection Order Line".Attribute)
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Expected_Value_; "Inspection Order Line"."Expected Value")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Minimal_Value_; "Inspection Order Line"."Minimal Value")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Maximal_Value_; "Inspection Order Line"."Maximal Value")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___No__of_Results_; "Inspection Order Line"."No. of Results")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___No__of_Failures_; "Inspection Order Line"."No. of Failures")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Actual_Min__Value_; "Inspection Order Line"."Actual Min. Value")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Actual_Max__Value_; "Inspection Order Line"."Actual Max. Value")
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line___Actual_Avg__Value_; "Inspection Order Line"."Actual Avg. Value")
                {
                }
                column(Inspection_Device__Description; "Inspection Device".Description)
                {
                }
                column(PositionCaption; PositionCaptionLbl)
                {
                }
                column(Parameter_No_Caption; Parameter_No_CaptionLbl)
                {
                }
                column(Inspection_Order_Line__Inspection_Order_Line__DescriptionCaption; Inspection_Order_Line__Inspection_Order_Line__DescriptionCaptionLbl)
                {
                }
                column(FindingsCaption; FindingsCaptionLbl)
                {
                }
                column(Inspection_ResulyCaption; Inspection_ResulyCaptionLbl)
                {
                }
                column(Unit_of_MeasureCaption; Unit_of_MeasureCaptionLbl)
                {
                }
                column(AttributeCaption; AttributeCaptionLbl)
                {
                }
                column(Expected_ValueCaption; Expected_ValueCaptionLbl)
                {
                }
                column(Minimal_ValueCaption; Minimal_ValueCaptionLbl)
                {
                }
                column(Maximal_ValueCaption; Maximal_ValueCaptionLbl)
                {
                }
                column(No__of_ResultsCaption; No__of_ResultsCaptionLbl)
                {
                }
                column(No__of_FailuresCaption; No__of_FailuresCaptionLbl)
                {
                }
                column(Actual_Min__ValueCaption; Actual_Min__ValueCaptionLbl)
                {
                }
                column(Actual_Max__ValueCaption; Actual_Max__ValueCaptionLbl)
                {
                }
                column(Actual_Avg__ValueCaption; Actual_Avg__ValueCaptionLbl)
                {
                }
                column(Inspection_DeviceCaption; Inspection_DeviceCaptionLbl)
                {
                }
                column(Inspection_Order_Line_Inspection_Order_No_; "Inspection Order No.")
                {
                }
                column(Inspection_Order_Line_Line_No_; "Line No.")
                {
                }
                column(LastActualValue; LastActualValue)
                {
                }
                column(LineComment; GetCommentString(FALSE))
                {
                }
                column(LineOperator; GetLastOperator())
                {
                }

                trigger OnAfterGetRecord()
                begin
                    IF NOT "Inspection Device".GET("Inspection Order Line"."Inspection Device No.") THEN
                        "Inspection Device".INIT();

                    LastActualValue := 0;
                    LastActualValue := GetLastActualValue();
                end;
            }

            trigger OnAfterGetRecord()
            // var
                // PurchaseHeader: Record "Purchase Header";
            begin

                IF NOT Location.GET("Inspection Order Header"."Location Code") THEN
                    CLEAR(Location);
                IF NOT Item.GET("Inspection Order Header"."Item No.") THEN
                    CLEAR(Item);
                IF NOT Vendor.GET("Inspection Order Header"."Customer/Vendor No.") THEN
                    CLEAR(Vendor);

                IF "Inspection Order Header"."Inspection Order Type" = "Inspection Order Header"."Inspection Order Type"::"Inspection Order" THEN
                    Title := Text001Lbl
                ELSE
                    Title := Text002Lbl;

            end;

            trigger OnPreDataItem()
            begin
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Opzioni)
                {
                    Caption = 'Options';
                    Visible = false;
                    field(gOptShow; gOptShow)
                    {
                        ApplicationArea = all;
                        ToolTip = ' ';
                        Caption = 'Inspection Status';
                        OptionCaption = 'Completed,Not Completed';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        LastActualValue_Caption = 'Last Actual Value';
        Comment_Caption = 'Comments';
        Analysis_Caption = 'PHISYCAL ANALISYS:';
        AttrAnalysis_Caption = 'VISUAL ANALISYS:';
        HeaderComment_Caption = 'COMMENTS:';
        Operator_Caption = 'Operator';
        ActualQuantity_Caption = 'Actual Quantity';
        Vendor_Caption = 'Vendor';
        Contract_Caption = 'Nr. contratto';
        Caption1 = 'Redatto da:';
        Caption2 = 'Verificato da:';
        Caption3 = 'Approvato da:';
        Caption4 = 'Data:';
        Caption5 = 'Rif.';
        Caption6 = 'Ed.';
        Caption7 = 'Rev.';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.GET();
        CompanyInformation.CALCFIELDS(Picture);
    end;

    var
        "Inspection Device": Record "EOS Inspection Device Header";
        CompanyInformation: Record "Company Information";
        Location: Record Location;
        Item: Record Item;
        Vendor: Record Vendor;
        ShowLines: Boolean;
        gOptShow: Option Completed,"Not completed";
        Inspection_Order_HeaderCaptionLbl: Label 'Inspection Order Header';
        CurrReport_PAGENOCaptionLbl: Label 'Pag.';
        DescriptionCaptionLbl: Label 'Description';
        PositionCaptionLbl: Label 'Position';
        Parameter_No_CaptionLbl: Label 'Parameter No.';
        Inspection_Order_Line__Inspection_Order_Line__DescriptionCaptionLbl: Label 'Description';
        FindingsCaptionLbl: Label 'Findings';
        Inspection_ResulyCaptionLbl: Label 'Inspection Resuly';
        Unit_of_MeasureCaptionLbl: Label 'Unit of Measure';
        AttributeCaptionLbl: Label 'Attribute';
        Expected_ValueCaptionLbl: Label 'Expected Value';
        Minimal_ValueCaptionLbl: Label 'Minimal Value';
        Maximal_ValueCaptionLbl: Label 'Maximal Value';
        No__of_ResultsCaptionLbl: Label 'No. of Results';
        No__of_FailuresCaptionLbl: Label 'No. of Failures';
        Actual_Min__ValueCaptionLbl: Label 'Actual Min. Value';
        Actual_Max__ValueCaptionLbl: Label 'Actual Max. Value';
        Actual_Avg__ValueCaptionLbl: Label 'Actual Avg. Value';
        Inspection_DeviceCaptionLbl: Label 'Inspection Device';
        Inspection_Result__Inspection_Result__PositionCaptionLbl: Label 'Position';
        Inspection_Result__Inspection_Result___Actual_Value_CaptionLbl: Label 'Actual Value';
        Inspection_Result__Inspection_Result___Value_Operator_CaptionLbl: Label 'Value Operator';
        Inspection_Result__Inspection_Result__DeviationCaptionLbl: Label 'Deviation';
        Inspection_Result__Inspection_Result___Attribute_Fulfilled_CaptionLbl: Label 'Attribute Fulfilled';
        Inspection_Result__Inspection_Result___Failure_No__CaptionLbl: Label 'Failure No.';
        TextNLSLbl: Label 'en-US';
        LastActualValue: Decimal;
        Text001Lbl: Label 'VERBALE CONTROLLO';
        Text002Lbl: Label 'NON CONFORMITA''';
        Title: Text;
        DocumentNo: Text;
        New_Title_CaptionLbl: Label 'Rapporto di non Conformità';

    local procedure GetCommentString(IsHeader: Boolean): Text
    var
        InspectionCommentLine: Record "EOS Inspection Comment Line";
        EOSLibraryEXT: Codeunit "EOS Library EXT";
        AddrArray: array[8] of Text[50];
        ResText: Text;
        i: Integer;
    begin
        IF IsHeader THEN BEGIN
            InspectionCommentLine.SETRANGE("Source Table", InspectionCommentLine."Source Table"::Order);
            InspectionCommentLine.SETRANGE("Source No.", "Inspection Order Header"."No.");
            InspectionCommentLine.SETRANGE("Source Line No.", 0);
        END ELSE BEGIN
            InspectionCommentLine.SETRANGE("Source Table", InspectionCommentLine."Source Table"::Order);
            InspectionCommentLine.SETRANGE("Source No.", "Inspection Order Line"."Inspection Order No.");
            InspectionCommentLine.SETRANGE("Source Line No.", "Inspection Order Line"."Line No.");
        END;
        IF InspectionCommentLine.FINDSET(FALSE, FALSE) THEN
            REPEAT
                i += 1;
                IF ResText = '' THEN
                    ResText := InspectionCommentLine.Comment
                ELSE
                    ResText := ResText + EOSLibraryEXT.NewLine() + InspectionCommentLine.Comment;
            UNTIL InspectionCommentLine.NEXT() = 0;

        EXIT(ResText);
    end;

    procedure GetLastOperator(): Code[35]
    var
        InspResult: Record "EOS Inspection Result";
    begin
        IF "Inspection Order Line".Attribute THEN BEGIN
            EXIT("Inspection Order Line"."Last Modified By");
        END ELSE BEGIN
            InspResult.SETRANGE("Inspection Order No.", "Inspection Order Line"."Inspection Order No.");
            InspResult.SETRANGE("Inspection Order Line No.", "Inspection Order Line"."Line No.");
            InspResult.SETCURRENTKEY(Creation);
            IF InspResult.FINDLAST() THEN
                EXIT(InspResult."Creation By");
        END;
    end;

    local procedure GetActualQuantity(): Decimal
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
        PostWhseRcptLine: Record "Posted Whse. Receipt Line";
    begin
        CASE "Inspection Order Header"."Ref. Type" OF

            DATABASE::"Purch. Rcpt. Line":
                BEGIN
                    IF PurchRcptLine.GET("Inspection Order Header"."Ref. Document No.", "Inspection Order Header"."Ref. Line No.") THEN
                        EXIT(PurchRcptLine.Quantity);
                END;

            DATABASE::"Warehouse Receipt Line":
                BEGIN
                    PostWhseRcptLine.SETRANGE("Posted Source Document", PostWhseRcptLine."Posted Source Document"::"Posted Receipt");
                    PostWhseRcptLine.SETRANGE("Whse. Receipt No.", "Inspection Order Header"."Ref. Document No.");
                    PostWhseRcptLine.SETRANGE("Whse Receipt Line No.", "Inspection Order Header"."Ref. Line No.");
                    PostWhseRcptLine.SETFILTER(Quantity, '<>%1', 0);
                    IF PostWhseRcptLine.FINDFIRST() THEN
                        IF PurchRcptLine.GET(PostWhseRcptLine."Posted Source No.", "Inspection Order Header"."Ref. Line No.") THEN
                            EXIT(PurchRcptLine.Quantity)
                        ELSE BEGIN
                        END
                    ELSE
                        IF WarehouseReceiptLine.GET("Inspection Order Header"."Ref. Document No.", "Inspection Order Header"."Ref. Line No.") THEN
                            EXIT(WarehouseReceiptLine."Qty. to Receive");
                END;

        END;
    end;
}

