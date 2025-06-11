tableextension 50000 "EOS Transfer Line" extends "Transfer Line" //5741
{
    fields
    {
        field(50000; "EOS Job Structure Entry No."; Integer)
        {
            AccessByPermission = TableData "M365 Job Structure Line" = R;
            BlankZero = true;
            Editable = false;
            Caption = 'Project Structure Entry No.'; //Nr. mov. struttura progetto
            DataClassification = CustomerContent;
            TableRelation = "M365 Job Structure Line"."Entry No.";
        }
    }
}