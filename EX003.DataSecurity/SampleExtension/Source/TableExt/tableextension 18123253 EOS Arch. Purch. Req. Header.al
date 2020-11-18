tableextension 61101 "EOSArch. Purch. Req. Hdr. DTS" extends "EOS Arch. Purch. Req. Header" //18123253
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