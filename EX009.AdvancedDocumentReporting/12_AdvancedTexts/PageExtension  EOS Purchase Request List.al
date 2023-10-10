pageextension 71367880 "EOS PageExt71367880" extends "EOS Purchase Request List"
{
    actions
    {
        addlast(navigation)
        {
            action("EOS Adv. Text")
            {
                Caption = 'Advanced text';
                ApplicationArea = all;
                Image = Text;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the EOS Adv. Text action';

                trigger OnAction()
                var
                    AdvTextMngt: Codeunit "EOS009 AdvText Mngt.";
                begin
                    AdvTextMngt.ShowAdvancedText(rec);
                end;
            }
        }
    }

}
