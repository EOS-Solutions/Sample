tableextension 50001 "EOS TableExt18123137" extends "EOS Inb. EDoc. Setup" //18123050
{
    fields
    {
        field(18123137; "EOS Import Folder"; Text[150])
        {
            Caption = 'Import Folder';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EOSFileSystemMgt: Codeunit "EOS FE FileSystem Mgt.";
            begin
                if not EOSFileSystemMgt.TestRemoteFile("EOS Import Folder") then
                    Error(PathErr, "EOS Import Folder");
            end;
        }
        field(18123138; "EOS Archive Folder"; Text[150])
        {
            Caption = 'Archive Folder';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EOSFileSystemMgt: Codeunit "EOS FE FileSystem Mgt.";
            begin
                if not EOSFileSystemMgt.TestRemoteFile("EOS Archive Folder") then
                    Error(PathErr, "EOS Archive Folder");
            end;
        }
        field(18123139; "EOS Rejected Folder"; Text[150])
        {

            Caption = 'Rejected Folder';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EOSFileSystemMgt: Codeunit "EOS FE FileSystem Mgt.";
            begin
                if not EOSFileSystemMgt.TestRemoteFile("EOS Rejected Folder") then
                    Error(PathErr, "EOS Rejected Folder");
            end;
        }
        field(18123140; "EOS Service Config Key"; Code[20])
        {
            Caption = 'Service Config Key';
            DataClassification = CustomerContent;
            TableRelation = "EOS004 Service Config.".Code;
        }
    }

    var
        PathErr: Label 'Path %1 is not valid.';

}