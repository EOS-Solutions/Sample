tableextension 61000 "EXA SalesLine Ext" extends "Sales Line" //37
{
    fields
    {
        field(61000; "EXA MyExtension Field"; Code[10])
        {
            Caption = 'MyExtension Field';
            DataClassification = CustomerContent;
        }
    }
}