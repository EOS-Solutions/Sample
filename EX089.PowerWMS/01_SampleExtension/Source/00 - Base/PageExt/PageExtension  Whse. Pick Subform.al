pageextension 50106 "EOS Whse. Pick Subform Ext" extends "Whse. Pick Subform"
{
    layout
    {
        addafter(Description)
        {
            field("EOS Lot No."; Rec."Lot No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the lot number for the warehouse pick line.';
            }
            field("EOS Serial No."; Rec."Serial No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the serial number for the warehouse pick line.';
            }
            field("EOS Package No."; Rec."Package No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the package number for the warehouse pick line.';
            }
        }
    }
}
