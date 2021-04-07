report 18008300 "EOS Commission Prospect"
{
    Caption = 'Commission Prospect';
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './Source/Report/EOS Commission Prospect.rdlc';

    dataset
    {
        dataitem(ProspectHeader; "EOS Commission Prospect Header")
        {
            RequestFilterFields = "No.", "Salesperson Code", "Commission Period Code";
            column(PH_AgentNo; "Salesperson Code")
            {
                IncludeCaption = true;
            }
            column(PH_AgentName; "Salesperson Name")
            {
                IncludeCaption = true;
            }
            column(PH_PeriodCode; "Commission Period Code")
            {
                IncludeCaption = true;
            }
            column(PH_ProspectNo; "No.")
            {
                IncludeCaption = true;
            }
            dataitem(ProspectLine; "EOS Commission Prospect Line")
            {
                DataItemLink = "Commission Period Code" = field("Commission Period Code"),
                                "Salesperson Code" = field("Salesperson Code");

                column(PL_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(PL_ReasonDescription; ReasonCode.Description)
                {

                }

                dataitem(PostedCommissionEntry; "EOS Commission Ledger Entry")
                {
                    DataItemLink = "Salesperson" = FIELD("Salesperson Code");
                    DataItemTableView = where("Table ID" = Filter(<> 18008306));
                    column(Manual; Manual)
                    {
                    }
                    column(DocumentType; SalesDocType)
                    {
                        //*campo formattato
                        Caption = 'Document Type';
                        OptionCaption = 'Quote,Blanket Order,Order,Invoice,Return Order,Credit Memo,Posted Shipment,Posted Invoice,Posted Return Receipt,Posted Credit Memo,Arch. Quote,Arch. Order,Arch. Blanket Order,Arch. Return Order';
                    }
                    column(DocumentNo; "Document No.")
                    {
                        IncludeCaption = true;
                    }
                    column(PostingDate; "Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(CustomerNo; CustomerNo)
                    {
                    }
                    column(CustomerName; CustomerName)
                    {
                    }
                    column(Amount; "Commission Base Amount (LCY)")
                    {
                        IncludeCaption = true;
                    }
                    column(CommissionAmount; "Commission Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(CommissionPercent; "Commission %")
                    {
                        IncludeCaption = true;
                    }
                    column(PayableAmountCommission; "Payable (LCY)")
                    {
                        IncludeCaption = true;
                    }
                    column(CommissionLineAmount; "Total Commission Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(CashedPerc; "Cashed %")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if CommissionsSetup."Get Salesperson From" = CommissionsSetup."Get Salesperson From"::"Bill-to Customer" then begin
                            CustomerNo := PostedCommissionEntry."Bill-to No.";
                            CustomerName := PostedCommissionEntry."Bill-to Name";
                        end else begin
                            CustomerNo := PostedCommissionEntry."Sell-to No.";
                            CustomerName := PostedCommissionEntry."Sell-to Name";
                        end;

                        if PostedCommissionEntry."Table ID" = Database::"EOS Commission Jnl. Line" then
                            Manual := true
                        else
                            Manual := false;

                        SalesDocType := CommissionUtilities.EncodeSalesDocType("Sales Document Type", "Table ID", false);
                    end;

                    trigger OnPreDataItem()
                    begin
                        CommissionUtilities.CollectCommLedgerEntryFromProspect(PostedCommissionEntry, ProspectLine);

                        //* solo quelli con causale vuota
                        //* aggiungere colonna PostedCommissionEntry."Commission Amount" vicino al totale
                        //* aggiungere % incassata PostedCommissionEntry."Cashed %"
                        PostedCommissionEntry.SetFilter("Reason Code", '%1', '');
                        PostedCommissionEntry.SetFilter("Table ID", '<>%1', Database::"EOS Commission Jnl. Line");
                    end;
                }

                dataitem(PostedCommissionEntry_Manual; "EOS Commission Ledger Entry")
                {
                    DataItemLink = "Salesperson" = FIELD("Salesperson Code"), "Reason Code" = field("Reason Code");
                    DataItemTableView = where("Table ID" = const(18008306));
                    column(Manual_Manual; Manual)
                    {
                    }

                    column(DocumentNo_Manual; "Document No.")
                    { }
                    column(ReasonCode_Manual; "Reason Code")
                    {
                        IncludeCaption = true;
                    }
                    column(PostingDate_Manual; "Posting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(Amount_Manual; "Commission Base Amount (LCY)")
                    {
                        IncludeCaption = true;
                    }
                    column(CommissionAmount_Manual; "Commission Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(CommissionPercent_Manual; "Commission %")
                    {
                        IncludeCaption = true;
                    }
                    column(PayableAmountCommission_Manual; "Payable (LCY)")
                    {
                        IncludeCaption = true;
                    }
                    column(CommissionLineAmount_Manual; "Total Commission Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_Manual; Description)
                    {
                        IncludeCaption = true;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if PostedCommissionEntry_Manual."Table ID" = Database::"EOS Commission Jnl. Line" then
                            Manual := true
                        else
                            Manual := false;
                    end;

                    trigger OnPreDataItem()
                    var
                    begin
                        CommissionUtilities.CollectCommLedgerEntryFromProspect(PostedCommissionEntry_Manual, ProspectLine);
                        PostedCommissionEntry_Manual.SetRange("Table ID", Database::"EOS Commission Jnl. Line");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if ReasonCode.Get(ProspectLine."Reason Code") then;

                end;


            }
        }
    }
    requestpage
    {
        trigger OnOpenPage()
        begin
            ProspectHeader.SetFilter("No.", TmpCommissionProspectHeader."No.");
            ProspectHeader.SetFilter("Salesperson Code", TmpCommissionProspectHeader."Salesperson Code");
            ProspectHeader.SetFilter("Commission Period Code", TmpCommissionProspectHeader."Commission Period Code");
        end;
    }

    labels
    {
        CustomerNo_Caption = 'Customer No.';
        CustomerName_Caption = 'Customer Name';
        DocumentType_Caption = 'Document Type';
        BaseAmount_Caption = 'Base Amount (LCY)';
        CommAmount_Caption = 'Fixed comm. amount (LCY)';
        CommPerc_Caption = 'Comm. %';
        TotCommAmount_Caption = 'Tot. comm. amnt. (LCY)';
        PL_ReasonDescription_Caption = 'Reason Code';
    }

    var
        ReasonCode: Record "EOS Commission Reason Code";
        CommissionsSetup: Record "EOS Commissions Setup";
        TmpCommissionProspectHeader: Record "EOS Commission Prospect Header";
        CommissionUtilities: Codeunit "EOS Commission Utilities";
        CustomerNo: Code[20];
        CustomerName: Text;
        Manual: Boolean;
        SalesDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo","Arch. Quote","Arch. Order","Arch. Blanket Order","Arch. Return Order";

    trigger OnPreReport()
    begin
        CommissionsSetup.Read(false);

        ProspectHeader.SetFilter("No.", TmpCommissionProspectHeader."No.");
        ProspectHeader.SetFilter("Salesperson Code", TmpCommissionProspectHeader."Salesperson Code");
        ProspectHeader.SetFilter("Commission Period Code", TmpCommissionProspectHeader."Commission Period Code");
    end;

    /* trigger OnInitReport()
     begin
         ProspectHeader.SetFilter("No.", TmpCommissionProspectHeader."No.");
         ProspectHeader.SetFilter("Salesperson Code", TmpCommissionProspectHeader."Salesperson Code");
         ProspectHeader.SetFilter("Commission Period Code", TmpCommissionProspectHeader."Commission Period Code");
     end;*/

    procedure SetReqFilter(ProspectHeader: Record "EOS Commission Prospect Header")
    begin
        TmpCommissionProspectHeader.Copy(ProspectHeader);
    end;
}