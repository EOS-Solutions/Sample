pageextension 50100 "CustomerCardExt" extends "Customer Card" //17
{
    layout
    {
        modify("EOS DocFinance")
        {
            Editable = EDSEditable;
        }
    }

    var
        EDSEditable: Boolean;

    trigger OnAfterGetRecord();
    var
        ExtEDS: Codeunit "EOS066 EX003 EDS";
    begin
        EDSEditable := ExtEDS.EDS_GetEditable(Rec);
    end;
}