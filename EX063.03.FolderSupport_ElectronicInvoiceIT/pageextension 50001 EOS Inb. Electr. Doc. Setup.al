pageextension 50001 "EOS PageExt18123137" extends "EOS Inb. Electr. Doc. Setup" //18123050
{
    layout
    {
        addafter("3 Purchase Header")
        {
            group("EOS File System")
            {
                Caption = 'File System';
                field("EOS Import Folder"; Rec."EOS Import Folder")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies where the files to import are stored';
                }
                field("EOS Archive Folder"; Rec."EOS Archive Folder")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies where the correctly imported files have to be moved';
                }
                field("EOS Rejected Folder"; Rec."EOS Rejected Folder")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies where the rejected files have to be moved';
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
        addfirst(Creation)
        {
            Action("EOS Test Path")
            {
                PromotedCategory = Process;
                Promoted = true;
                PromotedIsBig = true;
                Image = TestFile;
                ApplicationArea = all;
                Caption = 'Test File Paths';

                trigger OnAction()
                var
                    EOSFEFileSystemMgt: Codeunit "EOS FE FileSystem Mgt.";
                begin
                    CurrPage.Update(true);
                    Commit();
                    EOSFEFileSystemMgt.TestRemoteFilePath(Rec);
                end;
            }
        }
    }
}