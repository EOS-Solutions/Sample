tableextension 61100 "EOSPurch. Request Header DST" extends "EOS Purch. Request Header" //18123252
{
    fields
    {
        field(61100; "DS Status Code"; Code[10])
        {
            Caption = 'DS Status Code';
            TableRelation = "EOS DS Status";
            DataClassification = SystemMetadata;
        }

    }
}