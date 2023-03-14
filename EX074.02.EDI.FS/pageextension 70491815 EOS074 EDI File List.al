pageextension 50001 "EOS074.02 EDI File List Ext." extends "EOS074 EDI File List" //70491815
{
    layout
    {
        addlast(Control1)
        {
            field("EOS074.02 Path"; "EOS074.02 Path")
            {
                ApplicationArea = All;
                Caption = 'Path';
                ToolTip = 'Specifies path';
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action("EOS074.02 Open")
            {
                Caption = 'Open';
                Image = DocumentEdit;
                ApplicationArea=All;
                ToolTip = 'Open EDI file';

                trigger OnAction()
                begin
                    Download();
                end;
            }
        }
    }
}