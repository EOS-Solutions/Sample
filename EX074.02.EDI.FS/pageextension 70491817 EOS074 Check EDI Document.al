pageextension 50002 "EOS074.02 Check EDI Doc. Ext." extends "EOS074 Check EDI Document" //70491817
{
    layout
    {
        addlast(Group)
        {
            field("EOS074.02 FILE - File Path"; "EOS074.02 FILE - File Path")
            {
                Style = Unfavorable;
                StyleExpr = StyleWarning;
                ApplicationArea = All;
                Caption = 'FILE - File Path';
                ToolTip = 'Specifies file path';
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        StyleWarning := "Has Error";
    end;

    var
        StyleWarning: Boolean;
}