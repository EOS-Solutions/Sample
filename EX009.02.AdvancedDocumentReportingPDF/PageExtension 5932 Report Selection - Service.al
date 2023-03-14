pageextension 50003 "EOS PageExt18122133" extends "Report Selection - Service" //5932
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