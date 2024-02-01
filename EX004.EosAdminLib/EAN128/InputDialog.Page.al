page 50101 "EAN128 Dialog"
{

    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Options';

                field(EANStringField; _EANString)
                {
                    ApplicationArea = All;
                    Caption = 'EAN128 String';
                }
            }
        }
    }

    var
        _EANString: Text;

    procedure EAN128String(): Text
    begin
        exit(_EANString);
    end;

}