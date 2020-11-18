pageextension 61101 "EOSPurch. Request List DTS" extends "EOS Purchase Request List" //18123252
{
    layout
    {

        addfirst(Control1000000000)
        {
            field(EOSDSStatus; Rec."DS Status Code")
            {
                ApplicationArea = all;
                Caption = 'Security Status';
                Editable = false;
                Enabled = DSEnabled;
                Lookup = false;
                StyleExpr = DSStatusColour;
                Visible = DSEnabled;
            }
            field(EOSDSDescription; DSDescription)
            {
                Caption = 'Security Description';
                Editable = false;
                Enabled = DSEnabled;
                StyleExpr = DSStatusColour;
                Visible = DSEnabled;
                ApplicationArea = all;
            }
        }
        addafter(ApprovalFactBox)
        {
            part("DTS Status FactBox"; "EOS DS Record Status FactBox")
            {
                ApplicationArea = All;
                Enabled = DSEnabled;
                SubPageLink = "Table ID" = CONST(18123252), // EOS Purch Request Header
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
        DSUserInterface: Codeunit "EOS DS User Interface";
        DSEnabled: Boolean;
        DSStatus: Code[10];
        DSDescription: Text;
        DSStatusColour: Text;

    trigger OnOpenPage()
    begin
        DSEnabled := DSUserInterface.GetPageDSEnabled(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        if DSEnabled then
            DSUserInterface.GetPageRecordStatus(Rec, DSStatus, DSDescription, DSStatusColour);
    end;
}