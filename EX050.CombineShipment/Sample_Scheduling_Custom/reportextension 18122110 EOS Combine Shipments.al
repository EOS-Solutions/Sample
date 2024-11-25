reportextension 50100 "EOS050 ReportExt18122300" extends "EOS Combine Shipments" //18122110
{

    requestpage
    {
        layout
        {
            addafter(PostingDate)
            {
                field(GenericCustomPageField; GenericCustomPageField)
                {
                    ApplicationArea = All;
                    ToolTip = 'Generic Custom Page Field';
                }
            }
        }
    }

    var
        GenericCustomPageField: Code[5];

    procedure GetGenericCustomPageField(): Code[5];
    begin
        exit(GenericCustomPageField);
    end;

    procedure SetGenericCustomPageField(pGenericCustomPageField: Code[5])
    begin
        GenericCustomPageField := pGenericCustomPageField;
    end;

    trigger OnPostReport() // any standard trigger
    var
    begin
        // Do something with GenericCustomPageField
    end;
}