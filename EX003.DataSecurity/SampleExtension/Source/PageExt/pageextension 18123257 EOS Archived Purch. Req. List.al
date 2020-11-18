pageextension 61103 "EOSArc. Purch. Req. List DTS" extends "EOS Archived Purch. Req. List" //18123257
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
                Lookup = false;
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