tableextension 50001 "EOS074.02 EDI File Ext." extends "EOS074 EDI File" //70491816
{
    fields
    {
        field(50000; "EOS074.02 Path"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Path';
        }
    }

    procedure Download()
    var
        FileMgt: Codeunit "File Management";
        Res: Text;
    begin
        Res := FileMgt.DownloadTempFile("EOS074.02 Path");
        HyperLink(Res);
    end;
}