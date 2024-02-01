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
            part("EOS003 Record Status FactBox"; "EOS003 Rec. Status FactBox")
            {
                SubPageLink = "Table ID" = const(18123252), "Table Rec. SystemId" = field(SystemId);
                SubPageView = SORTING("Table ID", "Table Rec. SystemId", "Factbox Line No.");
                ApplicationArea = All;
                Visible = DSEnabledSystemId;
                Enabled = DSEnabled;
                UpdatePropagation = Both;
            }
            part("EOS003 Status Log Factbox"; "EOS003 Status Log Factbox")
            {
                SubPageLink = "Table ID" = const(18123252), "Table Rec. SystemId" = field(SystemId);
                SubPageView = SORTING("Table ID", "Table Rec. SystemId", "Factbox Line No.");
                ApplicationArea = All;
                Visible = DSEnabledSystemId;
                Enabled = DSEnabled;
                UpdatePropagation = Both;
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
                UpdatePropagation = Both;
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
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
    }

    var
        DSSetup: Record "EOS DS Setup";
        DSEnabled: Boolean;
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
        DSStatusEditable := DSUserInterface.SetPageAsDSEditable(Rec)  
    end;
    
    trigger OnNewRecord(BelowxRec: Boolean)    
    begin        
        DSStatusEditable := TRUE;    
    end;
}
