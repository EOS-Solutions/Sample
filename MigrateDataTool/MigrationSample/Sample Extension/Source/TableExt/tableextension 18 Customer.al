tableextension 60000 "EOS TableExt60000" extends Customer //18
{
    fields
    {
        field(60000; "EOS Additional Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Additional Code';
        }
        field(60001; "EOS Additional Description"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Additional Description';
        }
        field(60002; "EOS Additional Ref. No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Additional Ref. No.';
        }
    }

}