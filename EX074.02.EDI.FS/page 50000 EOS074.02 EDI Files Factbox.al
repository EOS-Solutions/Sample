page 50000 "EOS074.02 EDI Files Factbox"
{
    Caption = 'Files';
    Editable = false;
    PageType = ListPart;
    SourceTable = "EOS074 EDI File";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Path; "EOS074.02 Path")
                {
                    ApplicationArea=All;
                    Caption = 'Path';
                    ToolTip = 'Specifies path';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Open)
            {
                ApplicationArea=All;
                Caption = 'Open';
                Image = DocumentEdit;
                ToolTip = 'Open EDI file';

                trigger OnAction()
                begin
                    Download();
                end;
            }
        }
    }
}
