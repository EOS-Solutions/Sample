tableextension 50000 "EOS TableExt18123138" extends "EOS Outb. Electr. Doc. Setup" //18123040
{
    fields
    {
        field(18123137; "EOS File Path"; Text[250])
        {
            Caption = 'File Path';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EOSFEFileSystemMgt: Codeunit "EOS FE FileSystem Mgt.";
                PathErr: label 'Path %1 is not valid.';
            begin
                IF NOT EOSFEFileSystemMgt.TestRemoteFile("EOS File Path") THEN
                    ERROR(PathErr, "EOS File Path");
            end;
        }
        field(18123138; "EOS Self-Invoice File Path"; Text[250])
        {
            Caption = 'Purch. Self-Invoice File Path';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                EOSFEFileSystemMgt: Codeunit "EOS FE FileSystem Mgt.";
                PathErr: label 'Path %1 is not valid.';
            begin
                IF NOT EOSFEFileSystemMgt.TestRemoteFile("EOS Self-Invoice File Path") THEN
                    ERROR(PathErr, "EOS Self-Invoice File Path");
            end;
        }
        field(18123139; "EOS Service Config Key"; Code[20])
        {
            Caption = 'Service Config Key';
            DataClassification = CustomerContent;
            TableRelation = "EOS004 Service Config.".Code;
        }
    }

}