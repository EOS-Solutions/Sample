pageextension 50101 "EOS RCAHC-Create Trans. Order" extends "EOS089 WMS Reg. Cus. Act. Card"
{
    layout
    {
        addafter("Bin Code")
        {
            field("EOS To Location Code"; Rec."EOS To Location Code")
            {
                ApplicationArea = All;
                ToolTip = 'To Location Code';
            }
            field("EOS To Bin Code"; Rec."EOS To Bin Code")
            {
                ApplicationArea = All;
                ToolTip = 'To Bin Code';
            }
        }
    }
}
