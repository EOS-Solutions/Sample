/// <summary>Barcode Reason Code</summary>
report 50001 "EOS 070 MES Barcode Reason"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Source/LayoutReport/BarcodeReason.rdlc';
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'MES Barcode Reason Print';
    dataset
    {
        dataitem("MES Setup"; "EOS 070 MES Setup")
        {
            DataItemTableView = sorting("Primary Key");
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);
                column(OutputText_MESSetup; "MES Setup"."Output Text")
                {
                    IncludeCaption = true;
                }
                column(SetupText_MESSetup; "MES Setup"."Setup Text")
                {
                    IncludeCaption = true;
                }
                column(StopTimeText_MESSetup; "MES Setup"."Stop Time Text")
                {
                    IncludeCaption = true;
                }
                column(StartText_MESSetup; "MES Setup"."Start Text")
                {
                    IncludeCaption = true;
                }
                column(EndText_MESSetup; "MES Setup"."End text")
                {
                    IncludeCaption = true;
                }
                column(CreateStaplingText_MESSetup; "MES Setup"."Create Stapling Text")
                {
                    IncludeCaption = true;
                }
                column(AddStaplingText_MESSetup; "MES Setup"."Add Stapling Text")
                {
                    IncludeCaption = true;
                }
                column(RemoveStaplingText_MESSetup; "MES Setup"."Remove Stapling Text")
                {
                    IncludeCaption = true;
                }
                column(TenantMedia_OutputText_MESSetup; TempTenantMedia[1].Content)
                {

                }
                column(TenantMedia_SetupText_MESSetup; TempTenantMedia[2].Content)
                {

                }
                column(TenantMedia_StopTimeText_MESSetup; TempTenantMedia[3].Content)
                {

                }
                column(TenantMedia_StartText_MESSetup; TempTenantMedia[4].Content)
                {

                }
                column(TenantMedia_EndText_MESSetup; TempTenantMedia[5].Content)
                {

                }
                column(TenantMedia_CreateStaplingText_MESSetup; TempTenantMedia[6].Content)
                {

                }
                column(TenantMedia_AddStaplingText_MESSetup; TempTenantMedia[7].Content)
                {

                }
                column(TenantMedia_RemoveStaplingText_MESSetup; TempTenantMedia[8].Content)
                {

                }
                trigger OnPreDataItem()
                var
                begin
                    SetRange(Number, 1, 1 + NrCopies);
                end;
            }
            trigger OnAfterGetRecord()
            var
                EOSMESReportingManagement: Codeunit "EOS MES Reporting Management";
            begin
                EOSMESReportingManagement.GetBarcode("Output Text", "Barcode Type", TempTenantMedia[1]);
                EOSMESReportingManagement.GetBarcode("Setup Text", "Barcode Type", TempTenantMedia[2]);
                EOSMESReportingManagement.GetBarcode("Stop Time Text", "Barcode Type", TempTenantMedia[3]);
                EOSMESReportingManagement.GetBarcode("Start Text", "Barcode Type", TempTenantMedia[4]);
                EOSMESReportingManagement.GetBarcode("End text", "Barcode Type", TempTenantMedia[5]);
                EOSMESReportingManagement.GetBarcode("Create Stapling Text", "Barcode Type", TempTenantMedia[6]);
                EOSMESReportingManagement.GetBarcode("Add Stapling Text", "Barcode Type", TempTenantMedia[7]);
                EOSMESReportingManagement.GetBarcode("Remove Stapling Text", "Barcode Type", TempTenantMedia[8]);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)

                {
                    Caption = 'Options';
                    field("Nr.Copies"; NrCopies)
                    {
                        ApplicationArea = All;
                        Caption = 'No. of Copies';
                        ToolTip = 'Indicates how many copies to print';
                    }
                }
            }
        }
    }

    var
        TempTenantMedia: array[8] of Record "Tenant Media" temporary;
        NrCopies: Integer;
}