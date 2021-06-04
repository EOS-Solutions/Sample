pageextension 61102 "EOSArchived Purch. Req. DTS" extends "EOS Archived Purch. Request" //18123255
{
    layout
    {
        addlast(General)
        {
            field("EOSDS Status Code"; "DS Status Code")
            {
                ApplicationArea = All;
                Visible = DSEnabled;
            }
        }
    }

    actions
    {
    }


    var
        DSEnabled: Boolean;

    trigger OnOpenPage()
    var
        PurchaseRequest: Record "EOS Purch. Request Header";
        DSUserInterface: Codeunit "EOS DS User Interface";
    begin
        DSEnabled := DSUserInterface.GetPageDSEnabled(PurchaseRequest);
    end;
}