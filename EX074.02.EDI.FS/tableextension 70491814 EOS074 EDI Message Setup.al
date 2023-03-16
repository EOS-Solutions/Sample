tableextension 50000 "EOS074.02 EDI Mess. Setup Ext." extends "EOS074 EDI Message Setup" //70491814
{
    fields
    {
        field(50000; "EOS074.02 File System Path"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'File System Path';
        }
    }
}