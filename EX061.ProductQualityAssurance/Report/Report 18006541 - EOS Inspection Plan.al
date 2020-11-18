report 18006541 "EOS Inspection Plan"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\Source\Report\InspectionPlan.rdlc';
    ApplicationArea = All;
    Caption = 'Inspection Plan (PQA)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Inspection Plan Header"; "EOS Inspection Plan Header")
        {
            DataItemTableView = SORTING("No.", "Version No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Version No.";
            column(FORMAT_TODAY_0_3_; Format(Today(), 0, 3))
            {
            }
            column(COMPANYNAME; CompanyName())
            {
            }
            column(CurrReport_PAGENO; '')
            {
            }
            column(USERID; UserId())
            {
            }
            column(Inspection_Plan_Header__No__; "No.")
            {
                IncludeCaption = true;
            }
            column(Inspection_Plan_Header__Version_No__; "Version No.")
            {
                IncludeCaption = true;
            }
            column(Inspection_Plan_Header_Description; Description)
            {
                IncludeCaption = true;
            }
            column(Inspection_Plan_Header__Description_2_; "Description 2")
            {
                IncludeCaption = true;
            }
            column(Inspection_Plan_Header__Starting_Date_; "Starting Date")
            {
                IncludeCaption = true;
            }
            column(Inspection_Plan_Header__Drawing_No__; "Drawing No.")
            {
                IncludeCaption = true;
            }
            column(Inspection_Plan_Header_Status; Status)
            {
                IncludeCaption = true;
            }
            dataitem("Inspection Plan Line"; "EOS Inspection Plan Line")
            {
                DataItemLink = "Plan No." = FIELD("No."), "Version No." = FIELD("Version No.");
                DataItemTableView = SORTING("Plan No.", "Version No.", "Line No.");
                column(Posizione_; "Inspection Plan Line".Position)
                {
                }
                column(Inspection_Plan_Line__Inspection_Plan_Line___Parameter_No__; "Inspection Plan Line"."Parameter No.")
                {
                }
                column(Inspection_Plan_Line__Inspection_Plan_Line__Description; "Inspection Plan Line".Description)
                {
                }
                column(Inspection_Plan_Line__Inspection_Plan_Line___Unit_of_Measure_Code_; "Inspection Plan Line"."Unit of Measure Code")
                {
                }
                column(Inspection_Plan_Line__Inspection_Plan_Line__Attribute; "Inspection Plan Line".Attribute)
                {
                }
                column(Inspection_Plan_Line__Inspection_Plan_Line___Expected_Value_; "Inspection Plan Line"."Expected Value")
                {
                }
                column(Inspection_Plan_Line__Inspection_Plan_Line___Minimal_Value_; "Inspection Plan Line"."Minimal Value")
                {
                }
                column(Inspection_Plan_Line__Inspection_Plan_Line___Maximal_Value_; "Inspection Plan Line"."Maximal Value")
                {
                }
                column(gRecInspectionDeviceHeader_Description; gRecInspectionDeviceHeader.Description)
                {
                }
                column(PositionCaption; PositionCaptionLbl)
                {
                }
                column(Parameter_No_Caption; Parameter_No_CaptionLbl)
                {
                }
                column(DescriptionCaption; DescriptionCaptionLbl)
                {
                }
                column(Unit_of_Measure_Caption; Unit_of_Measure_CaptionLbl)
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
                column(Inspection_deviceCaption; Inspection_deviceCaptionLbl)
                {
                }
                column(Inspection_Plan_Line_Plan_No_; "Plan No.")
                {
                }
                column(Inspection_Plan_Line_Version_No_; "Version No.")
                {
                }
                column(Inspection_Plan_Line_Line_No_; "Line No.")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not gRecInspectionDeviceHeader.Get("Inspection Plan Line"."Inspection Device No.") then
                        gRecInspectionDeviceHeader.Init();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                VersionCode := gCduInspectionManagement.GetPlanVersion("Inspection Plan Header"."No.", "Calc.Date", false);
                if "Inspection Plan Header"."Version No." <> VersionCode then
                    CurrReport.Skip();
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
                    field(CalculationDate; "Calc.Date")
                    {
                        ApplicationArea = All;
                        ToolTip = ' ';
                        Caption = 'Calculation Date';
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
        Inspection_Plan_HeaderCaptionLbl = 'Inspection Plan Header';
        CurrReport_PAGENOCaptionLbl = 'Page';
    }

    trigger OnInitReport()
    begin
        "Calc.Date" := WorkDate();
    end;

    var
        gRecInspectionDeviceHeader: Record "EOS Inspection Device Header";
        gCduInspectionManagement: Codeunit "EOS Inspection Management";
        "Calc.Date": Date;
        VersionCode: Code[10];
        PositionCaptionLbl: Label 'Position';
        Parameter_No_CaptionLbl: Label 'Parameter No.';
        DescriptionCaptionLbl: Label 'Description';
        Unit_of_Measure_CaptionLbl: Label 'Unit of Measure ';
        AttributeCaptionLbl: Label 'Attribute';
        Expected_ValueCaptionLbl: Label 'Expected Value';
        Minimal_ValueCaptionLbl: Label 'Minimal Value';
        Maximal_ValueCaptionLbl: Label 'Maximal Value';
        Inspection_deviceCaptionLbl: Label 'Inspection device';
}

