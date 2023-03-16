pageextension 50000 "EOS PageExt18122130" extends "Report Selection - Sales" //306
{
    layout
    {
        addlast(Control1)
        {
            field("EOS50k Comb. PDF on Email Send"; "EOS Combine PDF on Email Send")
            {
                Caption = 'Combine PDF on Email Send';
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the "EOS Combine PDF on Email Send" field.';
            }
        }
    }
}