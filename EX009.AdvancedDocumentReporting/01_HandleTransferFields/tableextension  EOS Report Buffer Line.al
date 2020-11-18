tableextension 61001 "EXA ReportBuffer Line Ext" extends "EOS Report Buffer Line"
{
    fields
    {
        field(61010; "EXA MyExtension Field"; Code[10])
        {
            Caption = 'MyExtension Field';
            DataClassification = CustomerContent;
        }
    }
}