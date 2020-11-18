report 18006540 "EOS Inspection Device List"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\Source\Report\InspectionDeviceList.rdlc';
    ApplicationArea = All;
    Caption = 'Inspection Device List (PQA)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Inspection Device Header"; "EOS Inspection Device Header")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Calibration Type";
            column(CurrReportLanguage; TextNLSLbl)
            {

            }
            column(COMPANYNAME; CompanyName())
            {
            }
            column(Inspection_Device_Header__No__; "No.")
            {
                IncludeCaption = true;
            }
            column(Inspection_Device_Header_Description; Description)
            {
                IncludeCaption = true;
            }
            column(Inspection_Device_Header__Calibration_Type_; "Calibration Type")
            {
                IncludeCaption = true;
            }
            column(Inspection_Device_Header__Calibration_Vendor_No__; "Calibration Vendor No.")
            {
                IncludeCaption = true;
            }
            column(Inspection_Device_Header__Calibration_Regulation_; "Calibration Regulation")
            {
                IncludeCaption = true;
            }
            column(Inspection_Device_Header__Calibration_Frequency_; "Calibration Frequency")
            {
                IncludeCaption = true;
            }
            column(Inspection_Device_Header__Next_Date_of_Calibration_; "Next Date of Calibration")
            {
                IncludeCaption = true;
            }
            column(Inspection_Device_Header__Unit_of_Measure_Code_; "Unit of Measure Code")
            {
                IncludeCaption = true;
            }
            column(ShowLinesName; ShowLines)
            {
            }
            dataitem("Inspection Device Line"; "EOS Inspection Device Line")
            {
                DataItemLink = "Device No." = FIELD("No.");
                DataItemTableView = SORTING("Device No.", "Line No.");
                column(Inspection_Device_Line__Calibration_Date_; "Calibration Date")
                {
                    IncludeCaption = true;
                }
                column(Inspection_Device_Line__Description; Description)
                {
                    IncludeCaption = true;
                }
                column(Inspection_Device_Line__Creation; Creation)
                {
                    IncludeCaption = true;
                }
                column(Inspection_Device_Line__Creation_By_; "Creation By")
                {
                    IncludeCaption = true;
                }
                column(Inspection_Device_Line__Modified_; "Last Modified")
                {
                    IncludeCaption = true;
                }
                column(Inspection_Device_Line__Last_Modified_By_; "Last Modified By")
                {
                    IncludeCaption = true;
                }
                column(Inspection_Device_Line__Device_No_; "Device No.")
                {
                }
                column(Inspection_Device_Line__Line_No_; "Line No.")
                {
                }

                trigger OnPreDataItem()
                begin
                    if not ShowLines then
                        CurrReport.Break();
                end;
            }
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
                    field(ShowLinesName; ShowLines)
                    {
                        ApplicationArea = All;
                        ToolTip = ' ';
                        Caption = 'Show Lines';
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
        PageNoCaptionLbl = 'Page';
        Inspection_Device_HeaderCaptionLbl = 'Inspection Device Header';
    }

    var
        ShowLines: Boolean;
        TextNLSLbl: Label 'en-US';
}

