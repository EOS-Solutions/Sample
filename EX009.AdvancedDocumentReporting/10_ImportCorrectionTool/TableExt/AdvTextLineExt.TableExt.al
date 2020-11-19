tableextension 59001 "EOSTOOL AdvTextLine_Ext" extends "EOS009 Doc. Adv. Text Line"
{
    fields
    {
        field(59000; "EOSTOOL Temp Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Temporary Customer No.';
        }
        field(59001; "EOSTOOL Temp Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Temporary Vendor No.';
        }
    }

}