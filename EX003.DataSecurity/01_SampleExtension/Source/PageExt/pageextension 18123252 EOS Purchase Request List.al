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
             part("EOS003 Record Status FactBox"; "EOS003 Rec. Status FactBox")
            {
                SubPageLink = "Table ID" = const(18123252), "Table Rec. SystemId" = field(SystemId);
                SubPageView = SORTING("Table ID", "Table Rec. SystemId", "Factbox Line No.");
                ApplicationArea = All;
                Visible = DSEnabledSystemId;
                Enabled = DSEnabled;
            }
            part("EOS003 Status Log Factbox"; "EOS003 Status Log Factbox")
            {
                SubPageLink = "Table ID" = const(18123252), "Table Rec. SystemId" = field(SystemId);
                SubPageView = SORTING("Table ID", "Table Rec. SystemId", "Factbox Line No.");
                ApplicationArea = All;
                Visible = DSEnabledSystemId;
                Enabled = DSEnabled;
            }
            part("EOS DTS Status Factbox"; "EOS DS Record Status FactBox")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by "EOS003 Record Status FactBox"';
                ObsoleteTag = '20.0';
                ApplicationArea = All;
                Enabled = DSEnabled;
                SubPageLink = "Table ID" = const(18123252), // EOS Purch Request Header
                  "No." = FIELD("EOS No.");
                SubPageView = SORTING("Table ID", "Document Type", "No.", "Line No.", "Factbox Line No.");
                Visible = DSEnabledNoSystemId;
            }
            part("EOS DTS Status Log Factbox"; "EOS DS Status Log Factbox")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by "EOS003 Status Log Factbox"';
                ObsoleteTag = '20.0';
                ApplicationArea = All;
                Enabled = DSEnabled;
                SubPageLink = "Table ID" = CONST(18123252), // EOS Purch Request Header
                  "No." = FIELD("EOS No.");
                SubPageView = SORTING("Table ID", "Document Type", "No.", "Line No.", "Factbox Line No.");
                Visible = DSEnabledNoSystemId;
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
        DSSetup: Record "EOS DS Setup";
        DSEnabledSystemId: Boolean;
        DSEnabledNoSystemId: Boolean;

    trigger OnOpenPage()
    var
        DSUserInterface: Codeunit "EOS DS User Interface";
    begin
        DSSetup.Get();
        DSEnabled := DSUserInterface.GetPageDSEnabled(Rec);
        DSEnabledSystemId := DSEnabled and DSSetup."Moved To SystemId";
        DSEnabledNoSystemId := DSEnabled and not DSSetup."Moved To SystemId";
    end;

    trigger OnAfterGetRecord()
    begin
        if DSEnabled then
            DSUserInterface.GetPageRecordStatus(Rec, DSStatus, DSDescription, DSStatusColour);
    end;
}
