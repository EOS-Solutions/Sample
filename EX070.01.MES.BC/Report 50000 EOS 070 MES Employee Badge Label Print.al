/// <summary>Employee's Barcode</summary>
report 50000 "EOS 070 MES Employee Badge"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Source/LayoutReport/EmployeeBadge.rdlc';
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Employee Badge - Label Print';

    dataset
    {
        dataitem(Employee; Employee)
        {
            DataItemTableView = sorting("No.") where("EOS Badge No." = filter(<> ''));
            RequestFilterFields = "No.", "EOS Badge No.";
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);
                column(No; Employee."No.")
                {

                }
                column(Description; Employee.FullName())
                {

                }
                column(HeaderTxt; HeaderText)
                {

                }
                column(TenantMedia; TempTenantMedia.Content)
                {

                }
                column(QrFormat; QrFormat)
                {

                }
                trigger OnPreDataItem()
                var
                begin
                    SetRange(Number, 1, 1 + NrCopies);
                end;
            }
            trigger OnPreDataItem()
            var
                EOS070MESSetup: Record "EOS 070 MES Setup";
            begin
                EOS070MESSetup.get();
                QrFormat := EOS070MESSetup."Barcode Type" in [EOS070MESSetup."Barcode Type"::QRCode];
            end;

            trigger OnAfterGetRecord()
            var
                EOSMESReportingManagement: Codeunit "EOS MES Reporting Management";
            begin
                EOSMESReportingManagement.FormatBarcodeEmplLabel(Employee, TempTenantMedia);
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
                    field("Header Text"; HeaderText)
                    {
                        ApplicationArea = all;
                        Caption = 'Header Text';
                        ToolTip = 'Header Text of the society';
                    }
                }
            }
        }
        trigger OnOpenPage()
        var
            CompanyInformation: Record "Company Information";
        begin
            CompanyInformation.get();
            HeaderText := CompanyInformation.Name;
        end;
    }

    var
        TempTenantMedia: Record "Tenant Media" temporary;
        HeaderText: Text;
        QrFormat: Boolean;
        NrCopies: Integer;
}