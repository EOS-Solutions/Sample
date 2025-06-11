pageextension 50000 "EOS Subcontr.Transf. Ord. Sub." extends "Subcontr.Transfer Ord. Subform" //12155
{
    layout
    {
        addlast(Control1130000)
        {
            field("EOS Job Structure Entry No."; Rec."EOS Job Structure Entry No.")
            {
                ApplicationArea = All;
                ToolTip = 'Shows the project structure entry no.'; //Mostra il "Nr. mov. struttura progetto"
                Visible = EngineeringActive;
            }
        }
    }

    trigger OnOpenPage()
    var
        EngineeringSetup: Record "M365 Engineering Setup";
    begin
        if EngineeringSetup.Get() then
            EngineeringActive := EngineeringSetup."Modus Engineering Active";
    end;

    var
        EngineeringActive: Boolean;
}