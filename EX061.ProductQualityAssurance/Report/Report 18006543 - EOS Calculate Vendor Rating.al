report 18006565 "EOS Calculate Vendor Rating"
{
    ApplicationArea = All;
    Caption = 'Calculate Vendor Rating (PQA)';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
        {
            RequestFilterFields = "Buy-from Vendor No.";

            trigger OnAfterGetRecord()
            var
                VendorRatingEntry: Record "EOS Vendor Rating Entry";
                VendorRatingParam: Record "EOS Vendor Rating Parameter";
                PurchLine: Record "Purchase Line";
                PurchRcptHeader: Record "Purch. Rcpt. Header";
                PurchRcptLine: Record "Purch. Rcpt. Line";
                QualRatCode: Record "EOS Quality Rating";
                VendorGlobalServices: Record "EOS Vendor Global Services";
                RatingDateAndQuantity: Boolean;
                Value: Decimal;
            begin
                if VendorRatingEntry.Get("Document No.", "Line No.") then
                    CurrReport.Skip();

                if Type <> Type::Item then
                    CurrReport.Skip();

                if (Quantity <= 0) or Correction then
                    CurrReport.Skip();

                if not "EOS Subject to Vendor Rating" then
                    CurrReport.Skip();

                RatingDateAndQuantity := true;
                if not PurchLine.Get(PurchLine."Document Type"::Order, "Order No.", "Order Line No.") then begin
                    Clear(PurchLine);
                    PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.");
                    PurchRcptLine.SetRange("Order No.", "Order No.");
                    PurchRcptLine.SetRange("Order Line No.", "Order Line No.");
                    PurchRcptLine.SetFilter(Quantity, '<>0');
                    if PurchRcptLine.Find('-') then
                        repeat
                            if PurchRcptLine."Prod. Order No." <> '' then
                                PurchLine."Quantity (Base)" := PurchLine."Quantity (Base)" + PurchRcptLine.Quantity
                            else
                                PurchLine."Quantity (Base)" := PurchLine."Quantity (Base)" + PurchRcptLine."Quantity (Base)";
                        until PurchRcptLine.Next() = 0;
                    if "Document No." <> PurchRcptLine."Document No." then
                        RatingDateAndQuantity := false;
                end else
                    if PurchLine."Outstanding Quantity" = 0 then begin
                        PurchRcptLine.SetCurrentKey("Order No.", "Order Line No.");
                        PurchRcptLine.SetRange("Order No.", "Order No.");
                        PurchRcptLine.SetRange("Order Line No.", "Order Line No.");
                        PurchRcptLine.SetFilter(Quantity, '<>0');
                        PurchRcptLine.Find('+');
                        if "Document No." <> PurchRcptLine."Document No." then
                            RatingDateAndQuantity := false;
                    end;

                PurchRcptHeader.Get("Document No.");

                VendorRatingEntry.Init();
                VendorRatingEntry."Receipt No." := "Document No.";
                VendorRatingEntry."Line No." := "Line No.";
                VendorRatingEntry."Vendor No." := PurchRcptHeader."Buy-from Vendor No.";
                VendorRatingEntry."Item No." := "No.";
                VendorRatingEntry."Delivery Date Score" := 100;
                VendorRatingEntry."Quality Score" := 100;
                VendorRatingEntry."Quantity Score" := 100;

                VendorRatingEntry."Arrival Date" := PurchRcptHeader."Posting Date";

                if RatingDateAndQuantity then begin
                    if ("Promised Receipt Date" <> 0D) then begin
                        Value := VendorRatingEntry."Arrival Date" - "Promised Receipt Date";
                        if Type = Type::Item then begin
                            VendorRatingParam.Reset();
                            VendorRatingParam.SetRange(Type, VendorRatingParam.Type::"Appointed Time");
                            VendorRatingParam.SetRange("Item Category Code", "Item Category Code");
                            VendorRatingParam.SetFilter("To Value", '<=%1', Value);
                            if VendorRatingParam.Find('+') then
                                VendorRatingEntry."Delivery Date Score" := VendorRatingParam.Score
                            else begin
                                VendorRatingParam.Reset();
                                VendorRatingParam.SetRange(Type, VendorRatingParam.Type::"Appointed Time");
                                VendorRatingParam.SetRange("Item Category Code", '');
                                VendorRatingParam.SetFilter("To Value", '<=%1', Value);
                                if VendorRatingParam.Find('+') then
                                    VendorRatingEntry."Delivery Date Score" := VendorRatingParam.Score
                                else begin
                                    VendorRatingParam.Reset();
                                    VendorRatingParam.SetRange(Type, VendorRatingParam.Type::"Appointed Time");
                                    VendorRatingParam.SetRange("Item Category Code", "Item Category Code");
                                    VendorRatingParam.SetFilter("To Value", '>%1', Value);
                                    if VendorRatingParam.FindFirst() then
                                        VendorRatingEntry."Delivery Date Score" := VendorRatingParam.Score
                                    else begin
                                        VendorRatingParam.Reset();
                                        VendorRatingParam.SetRange(Type, VendorRatingParam.Type::"Appointed Time");
                                        VendorRatingParam.SetRange("Item Category Code", '');
                                        VendorRatingParam.SetFilter("To Value", '>%1', Value);
                                        if VendorRatingParam.FindFirst() then
                                            VendorRatingEntry."Delivery Date Score" := VendorRatingParam.Score
                                    end;
                                end;
                            end
                        end else begin
                            VendorRatingParam.Reset();
                            VendorRatingParam.SetRange(Type, VendorRatingParam.Type::"Appointed Time");
                            VendorRatingParam.SetRange("Item Category Code", '');
                            VendorRatingParam.SetFilter("To Value", '<=%1', Value);
                            if VendorRatingParam.Find('+') then
                                VendorRatingEntry."Delivery Date Score" := VendorRatingParam.Score
                            else begin
                                VendorRatingParam.Reset();
                                VendorRatingParam.SetRange(Type, VendorRatingParam.Type::"Appointed Time");
                                VendorRatingParam.SetRange("Item Category Code", '');
                                VendorRatingParam.SetFilter("To Value", '>%1', Value);
                                if VendorRatingParam.FindFirst() then
                                    VendorRatingEntry."Delivery Date Score" := VendorRatingParam.Score
                            end;
                        end
                    end else
                        VendorRatingEntry."Delivery Date Score" := 100;

                    if (PurchLine."Outstanding Quantity" = 0) and ("EOS Quantity (Decl.)" <> 0) then begin

                        Value := (PurchLine."Quantity (Base)" - "EOS Quantity (Decl.)" * "Qty. per Unit of Measure") /
                                 Abs("EOS Quantity (Decl.)" * "Qty. per Unit of Measure") * 100;

                        if Type = Type::Item then begin
                            VendorRatingParam.Reset();
                            VendorRatingParam.SetRange(Type, VendorRatingParam.Type::Quantity);
                            VendorRatingParam.SetRange("Item Category Code", "Item Category Code");
                            VendorRatingParam.SetFilter("To Value", '<=%1', Value);
                            if VendorRatingParam.Find('+') then
                                VendorRatingEntry."Quantity Score" := VendorRatingParam.Score
                            else begin
                                VendorRatingParam.Reset();
                                VendorRatingParam.SetRange(Type, VendorRatingParam.Type::Quantity);
                                VendorRatingParam.SetRange("Item Category Code", '');
                                VendorRatingParam.SetFilter("To Value", '<=%1', Value);
                                if VendorRatingParam.Find('+') then
                                    VendorRatingEntry."Quantity Score" := VendorRatingParam.Score
                                else
                                    VendorRatingEntry."Quantity Score" := 100;
                            end
                        end else begin
                            VendorRatingParam.Reset();
                            VendorRatingParam.SetRange(Type, VendorRatingParam.Type::Quantity);
                            VendorRatingParam.SetRange("Item Category Code", '');
                            VendorRatingParam.SetFilter("To Value", '<=%1', Value);
                            if VendorRatingParam.Find('+') then
                                VendorRatingEntry."Quantity Score" := VendorRatingParam.Score
                            else
                                VendorRatingEntry."Quantity Score" := 100;
                        end
                    end;
                end;

                if "EOS Subject to Vendor Rating" then begin
                    Value := 0;
                    if "EOS Quality Rating Code" <> '' then begin
                        if QualRatCode.Get("EOS Quality Rating Code") then
                            Value := (QualRatCode.Percent / 100);
                    end else
                        if gScore100ForMissingQCRating then
                            Value := 1
                        else
                            TestField("EOS Quality Rating Code");

                    VendorRatingEntry."Quality Score" := Round(Value * 100, 1);
                end;

                if UseQualityCriteriainCalc then
                    QualityCriteriaValue := VendorRatingEntry."Quality Score" / 100
                else
                    QualityCriteriaValue := 1;

                if UseQuantityCriteriainCalc then
                    QuantityCriteriaValue := VendorRatingEntry."Quantity Score" / 100
                else
                    QuantityCriteriaValue := 1;

                if UseDateCriteriainCalc then
                    DateCriteriaValue := VendorRatingEntry."Delivery Date Score" / 100
                else
                    DateCriteriaValue := 1;

                VendorRatingEntry."Total Score" := Round(DateCriteriaValue * QualityCriteriaValue * QuantityCriteriaValue * 100, 1);

                VendorRatingEntry."Use Quality Criteria in Calc." := UseQualityCriteriainCalc;
                VendorRatingEntry."Use Quantity Criteria in Calc." := UseQuantityCriteriainCalc;
                VendorRatingEntry."Use Date Criteria in Calc." := UseDateCriteriainCalc;

                IF InspectionSetup."Vendor Certificazion Value" <> 0 THEN BEGIN

                    Vendor.GET("Purch. Rcpt. Line"."Buy-from Vendor No.");
                    IF Vendor."EOS Certified Vendor" THEN BEGIN
                        VendorCertValue := InspectionSetup."Vendor Certificazion Value" / 100;
                        VendorRatingEntry."Certification Score" := ROUND(VendorCertValue * 100, 1);
                    END;

                    IF UseVendorCertinCalc THEN BEGIN
                        VendorRatingEntry."Total Score" := ROUND(VendorRatingEntry."Total Score" * (1 + VendorCertValue), 1);
                        IF VendorRatingEntry."Total Score" > 100 THEN
                            VendorRatingEntry."Total Score" := 100;
                    END;
                END;

                VendorRatingEntry."Use Cert. Vendor in Calc." := UseVendorCertinCalc;

                //VendorRatingEntry."Total Score" := ROUND(VendorRatingEntry."Delivery Date Score" / 100 *
                //                                      VendorRatingEntry."Quality Score" / 100 *
                //                                      VendorRatingEntry."Quantity Score" / 100 * 100, 1);

                IF not Vendor.GET("Purch. Rcpt. Line"."Buy-from Vendor No.") then
                    vendor.init();
                IF NOT VendorGlobalServices.GET(Vendor."EOS Global Service Code") THEN
                    CLEAR(VendorGlobalServices);
                IF VendorGlobalServices.Percentage <> 0 THEN BEGIN
                    VendorGlobalServiceValue := VendorGlobalServices.Percentage / 100;

                    VendorRatingEntry."Global Service Score" := ROUND(VendorGlobalServiceValue * 100, 1);

                    IF UseVendorGlobalServiceCalc THEN BEGIN
                        VendorRatingEntry."Total Score" := ROUND(VendorRatingEntry."Total Score" * (1 + VendorGlobalServiceValue), 1);
                        IF VendorRatingEntry."Total Score" > 100 THEN
                            VendorRatingEntry."Total Score" := 100;
                    END;
                END;

                VendorRatingEntry."Use Global Service in Calc." := UseVendorGlobalServiceCalc;


                VendorRatingEntry.Insert();
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
                    field(gScore100ForMissingQCRatingName; gScore100ForMissingQCRating)
                    {
                        ApplicationArea = All;
                        ToolTip = ' ';
                        Caption = '100 Points for missing QC Rating';
                    }
                    group("Criteri calcolo")
                    {
                        Caption = 'Calculation Criteria';
                        field(UseQualityCriteriainCalcName; UseQualityCriteriainCalc)
                        {
                            ApplicationArea = All;
                            ToolTip = ' ';
                            Caption = 'Use Quality Criteria in Calc.';
                        }
                        field(UseQuantityCriteriainCalcName; UseQuantityCriteriainCalc)
                        {
                            ApplicationArea = All;
                            ToolTip = ' ';
                            Caption = 'Use Quantity Criteria in Calc.';
                        }
                        field(UseDateCriteriainCalcName; UseDateCriteriainCalc)
                        {
                            ApplicationArea = All;
                            ToolTip = ' ';
                            Caption = 'Use Date Criteria in Calc.';
                        }
                        field(UseVendorCertinCalcNAme; UseVendorCertinCalc)
                        {
                            ApplicationArea = All;
                            ToolTip = ' ';
                            Caption = 'Use Cert. Vendor in Calc.';
                        }
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
    }

    trigger OnInitReport()
    begin
        IF not InspectionSetup.Get() THEN
            InspectionSetup.init();
        UseQualityCriteriainCalc := InspectionSetup."Use Quality Criteria in Calc.";
        UseQuantityCriteriainCalc := InspectionSetup."Use Quantity Criteria in Calc.";
        UseDateCriteriainCalc := InspectionSetup."Use Date Criteria in Calc.";
        UseVendorCertinCalc := InspectionSetup."Use Cert. Vendor in Calc.";
        UseVendorGlobalServiceCalc := InspectionSetup."Use Global Service in Calc.";
    end;

    trigger OnPostReport()
    begin
        if GuiAllowed() then
            Message(Text001Msg);
    end;

    var
        InspectionSetup: Record "EOS Inspection Setup";
        Vendor: Record Vendor;
        gScore100ForMissingQCRating: Boolean;
        UseQualityCriteriainCalc: Boolean;
        UseQuantityCriteriainCalc: Boolean;
        UseDateCriteriainCalc: Boolean;
        UseVendorCertinCalc: Boolean;
        QualityCriteriaValue: Decimal;
        QuantityCriteriaValue: Decimal;
        DateCriteriaValue: Decimal;
        Text001Msg: Label 'Process completed.';
        VendorCertValue: Decimal;
        VendorGlobalServiceValue: Decimal;
        UseVendorGlobalServiceCalc: Boolean;
}

