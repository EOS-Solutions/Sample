pageextension 61100 "EOSPurchasing Request DTS" extends "EOS Purchase Request" //18123250
{
    layout
    {
        modify(General)
        {
            Editable = DSStatusEditable;
        }

        addafter(ApprovalFactBox)
        {
            part("DTS Status Factbox"; "EOS DS Record Status FactBox")
            {
                ApplicationArea = All;
                Enabled = DSEnabled;
                SubPageLink = "Table ID" = const(18123252), // EOS Purch Request Header
                  "No." = FIELD("EOS No.");
                SubPageView = SORTING("Table ID", "Document Type", "No.", "Line No.", "Factbox Line No.");
                Visible = DSEnabled;
            }
            part("DTS Status Log Factbox"; "EOS DS Status Log Factbox")
            {
                ApplicationArea = All;
                Enabled = DSEnabled;
                SubPageLink = "Table ID" = CONST(18123252), // EOS Purch Request Header
                  "No." = FIELD("EOS No.");
                SubPageView = SORTING("Table ID", "Document Type", "No.", "Line No.", "Factbox Line No.");
                Visible = DSEnabled;
            }
        }
    }

    actions
    {
    }

    var
        DSEnabled: Boolean;
        DSStatusEditable: Boolean;

    trigger OnOpenPage()
    var
        DSUserInterface: Codeunit "EOS DS User Interface";
    begin
        DSEnabled := DSUserInterface.GetPageDSEnabled(Rec);
    end;

    trigger OnAfterGetRecord()
    var
        DSUserInterface: Codeunit "EOS DS User Interface";
    begin
        DSStatusEditable := DSUserInterface.SetPageAsDSEditable(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        DSStatusEditable := TRUE;
    end;
}