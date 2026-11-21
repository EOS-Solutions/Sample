pageextension 50100 "EOS046 ACL Agent Summary" extends "EOS108 AAL Agent Summary"
{
    layout
    {
        addlast(Summary)
        {
            field("EOS046 Total X Created by"; Rec."EOS046 Total X Created by")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of X created by the agent.';
                Visible = Show < CODE > Summary;

                trigger OnDrillDown()
                var
                    PurchReqHeader: Record "EOS Purch. Request Header"; //CHANGEME
                begin
                    PurchReqHeader.SetRange(SystemCreatedBy, Rec."User Security ID"); //CHANGEME
                    Page.Run(Page::"EOS Purchase Request List", PurchReqHeader); //CHANGEME
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RefreshSummaryControls();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        RefreshSummaryControls();
    end;

    var
        AgentUtilities: Codeunit "<EOS0XX CODE> Agent Utilities";
        Show<CODE>Summary: Boolean;

    local procedure RefreshSummaryControls()
    begin
        Show < CODE > Summary := Rec."Agent Capability" = AgentUtilities.GetAgentCapability();
        if Show < CODE > Summary then
            Rec.CalcFields("EOS046 Total Purchase Requests"); //CHANGEME
    end;
}