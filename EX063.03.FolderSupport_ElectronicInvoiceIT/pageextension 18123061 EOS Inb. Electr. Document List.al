pageextension 50002 "EOS PageExt18123138" extends "EOS Inb. Electr. Document List" //18123061
{
    layout
    {

    }

    actions
    {
        addafter(ImportIXFE)
        {
            action(EOSImportFolderFS)
            {
                Caption = 'Import Folder';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Imports a folder. (From Inb. Setup - "Import Folder")';
                ApplicationArea = All;

                trigger OnAction()
                var
                    EOSInbEDocSetup: Record "EOS Inb. EDoc. Setup";
                    EOSInbEDocFS: Codeunit "EOS Inb. EDoc. FS";
                begin
                    EOSInbEDocSetup.Read();
                    CLEAR(EOSInbEDocFS);
                    EOSInbEDocSetup.testfield("EOS Import Folder");
                    EOSInbEDocFS.ImportFolder(EOSInbEDocSetup."EOS Import Folder");
                end;

            }
        }
    }
}