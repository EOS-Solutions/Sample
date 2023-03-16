pageextension 50000 "EOS PageExt18123139" extends "EOS Outb. Electr. Doc. Setup" //18123040
{
    layout
    {
        addafter(FileOptions)
        {
            group("EOS File System")
            {
                Caption = 'File System';
                field("EOS File Path"; Rec."EOS File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies where the created xml have to be exported';
                }
                field("EOS Self-Invoice File Path"; Rec."EOS Self-Invoice File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies where the created xml for Self Invoice are stored';
                }
                field("EOS Service Config Key"; Rec."EOS Service Config Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Config Key field.';
                }
            }
        }
    }

    actions
    {
    }
}