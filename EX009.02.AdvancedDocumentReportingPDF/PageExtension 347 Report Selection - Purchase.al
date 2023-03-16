pageextension 50001 "EOS PageExt18122131" extends "Report Selection - Purchase" //374
{
    layout
    {
        addlast(Control1)
        {
            field("EOS50k Comb. PDF on Email Send"; "EOS Combine PDF on Email Send")
            {
                ApplicationArea = All;
                ToolTip='Specifies the value of the "EOS Combine PDF on Email Send" field.';
            }
        }
    }
}