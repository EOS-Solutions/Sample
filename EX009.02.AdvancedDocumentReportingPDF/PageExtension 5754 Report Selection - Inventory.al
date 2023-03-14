pageextension 50002 "EOS PageExt18122132" extends "Report Selection - Inventory" //5754
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