tableextension 50002 "EOS074.02 Doc. Check Buf. Ext." extends "EOS074 EDI Docum. Check Buffer" //70491818
{
    fields
    {
        field(50000; "EOS074.02 FILE - File Path"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'FILE - File Path Name';
        }
    }
}