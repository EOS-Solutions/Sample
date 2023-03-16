pageextension 50000 "EOS074.02 EDI Mess. Setup Ext." extends "EOS074 EDI Message Setup" //70491811
{
    layout
    {
        addlast(Control1)
        {
            field("EOS074.02 File System Path"; "EOS074.02 File System Path")
            {
                ApplicationArea = All;
                Caption = 'File System Path';
                ToolTip = 'Insert a path for file, available placeholders are: <DOC>: DocumentNumber, <DATE>: Current Date, <DATETIME>: Current DateTime, <INCR,LENGHT>: Auto increment number, no. of digits';
            }
        }
    }
}