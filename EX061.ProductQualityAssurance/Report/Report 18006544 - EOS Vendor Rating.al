report 18006566 "EOS Vendor Rating"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\Source\Report\VendorRating.rdlc';
    ApplicationArea = All;
    Caption = 'Vendor Rating (PQA)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(FORMAT_TODAY_0_4_; Format(Today(), 0, 4))
            {
            }
            column(USERID; UserId())
            {
            }
            column(COMPANYNAME; CompanyName())
            {
            }
            column(Vendor_GETFILTERS__; Vendor.GetFilters())
            {
            }
            column(gPlanRcptDateFromName; gPlanRcptDateFrom)
            {
            }
            column(gPlanRcptDateToName; gPlanRcptDateTo)
            {
            }
            column(Vendor__No__; "No.")
            {
            }
            column(Vendor_Name; Name)
            {
            }
            column(Vendor_City; City)
            {
            }
            column(Vendor_RatingCaption; Vendor_RatingCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Vendorfilter_Caption; Vendorfilter_CaptionLbl)
            {
            }
            column(Date_fromCaption; Date_fromCaptionLbl)
            {
            }
            column(Date_toCaption; Date_toCaptionLbl)
            {
            }
            column(LocationCaption; LocationCaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(NumberCaption; NumberCaptionLbl)
            {
            }
            column(CurrReportLanguage; TextNLSLbl)
            {
            }
            dataitem("Vendor Rating Entry"; "EOS Vendor Rating Entry")
            {
                DataItemLink = "Vendor No." = FIELD("No.");
                DataItemTableView = SORTING("Receipt No.", "Line No.");
                column(Vendor_Rating_Entry__Item_No__; "Item No.")
                {
                }
                column(Vendor_Rating_Entry__Delivery_Date_Score_; "Delivery Date Score")
                {
                }
                column(Vendor_Rating_Entry__Quality_Score_; "Quality Score")
                {
                }
                column(Vendor_Rating_Entry__Quantity_Score_; "Quantity Score")
                {
                }
                column(Vendor_Rating_Entry__Total_Score_; "Total Score")
                {
                }
                column(gItem_Description; gItem.Description)
                {
                }
                column(Vendor_Rating_Entry__Receipt_No__; "Receipt No.")
                {
                }
                column(Vendor_Rating_Entry__Arrival_Date_; "Arrival Date")
                {
                }
                column(gCritHardDate; gCritHardDate)
                {
                }
                column(gCritHardQuantity; gCritHardQuantity)
                {
                }
                column(gCritHardQuality; gCritHardQuality)
                {
                }
                column(gCritHard; gCritHard)
                {

                }
                column(Hard_CriteriasCaption; Hard_CriteriasCaptionLbl)
                {
                }
                column(Vendor_Rating_Entry__Item_No__Caption; FieldCaption("Item No."))
                {
                }
                column(Vendor_Rating_Entry__Delivery_Date_Score_Caption; FieldCaption("Delivery Date Score"))
                {
                }
                column(Vendor_Rating_Entry__Quality_Score_Caption; FieldCaption("Quality Score"))
                {
                }
                column(Vendor_Rating_Entry__Quantity_Score_Caption; FieldCaption("Quantity Score"))
                {
                }
                column(Vendor_Rating_Entry__Total_Score_Caption; FieldCaption("Total Score"))
                {
                }
                column(Vendor_Rating_Entry__Name_Caption; NameCaption_Control18Lbl)
                {
                }
                column(Vendor_Rating_Entry__Receipt_No__Caption; FieldCaption("Receipt No."))
                {
                }
                column(Vendor_Rating_Entry__Arrival_Date_Caption; FieldCaption("Arrival Date"))
                {
                }
                column(Total_CriteriasCaption; Total_CriteriasCaptionLbl)
                {
                }
                column(Vendor_Rating_Entry_Line_No_; "Line No.")
                {
                }
                column(Vendor_Rating_Entry_Vendor_No_; "Vendor No.")
                {
                }
                column(Vendor_Rating_Entry_Use_Quality_Criteria_in_Calc; "Vendor Rating Entry"."Use Quality Criteria in Calc.")
                {
                }
                column(Vendor_Rating_Entry_Use_Quantity_Criteria_in_Calc; "Vendor Rating Entry"."Use Quantity Criteria in Calc.")
                {
                }
                column(Vendor_Rating_Entry_Use_Date_Criteria_in_Calc; "Vendor Rating Entry"."Use Date Criteria in Calc.")
                {
                }
                column(Vendor_Rating_Entry_Use_CertVendor_Criteria_in_Calc; "Vendor Rating Entry"."Use Cert. Vendor in Calc.")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if gItem.Get("Vendor Rating Entry"."Item No.") then;

                    gTotalScoreDate += "Delivery Date Score";
                    gCountDate += 1;
                    gTotalScoreQuantity += "Quantity Score";
                    gCountQuantity += 1;
                    gTotalScoreQuality += "Quality Score";
                    gCountQuality += 1;
                    gTotalScoreHard += "Total Score";
                    /*
                                        "Total Score" := Round(("Delivery Date Score" / 100 * "Quality Score" / 100 * "Quantity Score" / 100)
                                                               * 100, 1);


                                        if gCountDate <> 0 then
                                            gCritHardDate := Round(gTotalScoreDate / gCountDate, 1);
                                        if gCountQuantity <> 0 then
                                            gCritHardQuantity := Round(gTotalScoreQuantity / gCountQuantity, 1);
                                        if gCountQuality <> 0 then
                                            gCritHardQuality := Round(gTotalScoreQuality / gCountQuality, 1);

                                        gCritHard := Round((gCritHardDate / 100 * gCritHardQuantity / 100 * gCritHardQuality / 100) * 100, 1);
                    */
                    "Total Score" := "Total Score";
                    gCritHardDate := "Delivery Date Score";
                    gCritHardQuantity := "Quantity Score";
                    gCritHardQuality := "Quality Score";

                    gCritHard := "Total Score";

                    gExistCritHard := true;

                end;

                trigger OnPreDataItem()
                begin
                    gTotalScoreDate := 0;
                    gTotalScoreQuantity := 0;
                    gTotalScoreQuality := 0;
                    gCritHardDate := 0;
                    gCritHardQuantity := 0;
                    gCritHardQuality := 0;
                    gCountDate := 0;
                    gCountQuantity := 0;
                    gCountQuality := 0;
                    gExistCritHard := false;
                    gCritHard := 0;
                    gTotalScoreHard := 0;

                    "Vendor Rating Entry".SetRange("Arrival Date", gPlanRcptDateFrom, gPlanRcptDateTo);
                end;
            }
            dataitem(Summary; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;

                trigger OnAfterGetRecord()
                var
                    ScoreHard: Decimal;
                begin
                    if not (gExistCritHard) then
                        CurrReport.Break()
                    else begin
                        ScoreHard := gCritHard * gRatingHard;
                        if gRatingHard <> 0 then
                            gCritHard := Round((ScoreHard) / (gRatingHard), 1);
                        CreateRatingProposal();
                    end;
                end;
            }

            trigger OnPreDataItem()
            begin
                if (gPlanRcptDateTo = 0D) then
                    Error(gctxErr0001Err);
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
                    field(gCreateRatingProposalName; gCreateRatingProposal)
                    {
                        ApplicationArea = All;
                        ToolTip = ' ';
                        Caption = 'Create Rating Proposal';
                    }
                    field(UpdateVendorName; UpdateVendor)
                    {
                        ApplicationArea = All;
                        ToolTip = ' ';
                        Caption = 'Update Vendor';
                    }
                    field(gPlanRcptDateFromName; gPlanRcptDateFrom)
                    {
                        ApplicationArea = All;
                        ToolTip = ' ';
                        Caption = 'Planned Receipt Date from';
                    }
                    field(gPlanRcptDateToName; gPlanRcptDateTo)
                    {
                        ApplicationArea = All;
                        ToolTip = ' ';
                        Caption = 'Planned Receipt Date to';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            gPlanRcptDateTo := WorkDate();
            gPlanRcptDateFrom := CalcDate('<CM+1D-1M>', gPlanRcptDateTo);
            gPlanRcptDateTo := CalcDate('<CM>', gPlanRcptDateTo);
        end;
    }

    labels
    {
        Vendor_Rating_Entry_Use_Quality_Criteria_in_Calc_Lbl = 'Quality';
        Vendor_Rating_Entry_Use_Quantity_Criteria_in_Calc_Lbl = 'Quantity';
        Vendor_Rating_Entry_Use_Date_Criteria_in_Calc_Lbl = 'Delivery Date';
        Vendor_Rating_Entry_Use_Criteria_Lbl = 'Criteria';
        Vendor_Rating_Entry_Use_CertVendor_Criteria_in_Calc_Lbl = 'Cert. Vendor';
    }

    trigger OnInitReport()
    begin
        gCreateRatingProposal := true;
        gPlanRcptDateFrom := Today();

        gCountRatProp := 0;

        gPurchSetup.Get();
    end;

    trigger OnPreReport()
    begin
        if gPlanRcptDateTo = 0D then
            gPlanRcptDateTo := CalcDate('<CY+1Y>', Today());
    end;

    var
        gPurchSetup: Record "Purchases & Payables Setup";
        gItem: Record Item;
        gCategorisationCode: Record "EOS Vendor Rating";
        gctxErr0001Err: Label 'You must enter Rating Proposal Date to.';
        gCreateRatingProposal: Boolean;
        UpdateVendor: Boolean;
        gPlanRcptDateFrom: Date;
        gPlanRcptDateTo: Date;
        gCritHard: Integer;
        gCritHardDate: Decimal;
        gCritHardQuality: Decimal;
        gCritHardQuantity: Decimal;
        gTotalScoreDate: Integer;
        gTotalScoreQuality: Integer;
        gTotalScoreQuantity: Integer;
        gTotalScoreHard: Integer;
        gCountRatProp: Integer;
        gCountDate: Integer;
        gCountQuality: Integer;
        gCountQuantity: Integer;
        gRatingHard: Decimal;
        gExistCritHard: Boolean;
        Vendor_RatingCaptionLbl: Label 'Vendor Rating';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Vendorfilter_CaptionLbl: Label 'Vendorfilter:';
        Date_fromCaptionLbl: Label 'Date from';
        Date_toCaptionLbl: Label 'Date to';
        LocationCaptionLbl: Label 'Location';
        NameCaptionLbl: Label 'Name';
        NumberCaptionLbl: Label 'Number';
        Hard_CriteriasCaptionLbl: Label 'Hard Criterias';
        NameCaption_Control18Lbl: Label 'Name';
        Total_CriteriasCaptionLbl: Label 'Total Criterias';
        TextNLSLbl: Label 'en-US';

    procedure CreateRatingProposal()
    var
        RatingProposal: Record "EOS Rating Proposal";
    begin
        if gCreateRatingProposal then begin
            if RatingProposal.Get(Vendor."No.", WorkDate()) then
                RatingProposal.Delete();

            RatingProposal.Init();
            RatingProposal."Vendor No." := Vendor."No.";
            RatingProposal."Rating Date" := WorkDate();
            RatingProposal."Total Rating" := Round(gTotalScoreHard / gCountDate, 1);
            RatingProposal."New Classification" := gCategorisationCode.GetCategorisationCodeForScore(Round(gTotalScoreHard / gCountDate, 1));
            RatingProposal."Delivery Date Adherence" := Round(gTotalScoreDate / gCountDate, 1);
            RatingProposal."Quantity Rating" := Round(gTotalScoreQuantity / gCountQuantity, 1);
            RatingProposal."Quality Rating" := Round(gTotalScoreQuality / gCountQuality, 1);
            RatingProposal.Insert();
            if UpdateVendor then begin
                Vendor.Validate("EOS Classification Code", RatingProposal."New Classification");
                Vendor.Modify();
            end;
            gCountRatProp += 1;
        end;
    end;
}
