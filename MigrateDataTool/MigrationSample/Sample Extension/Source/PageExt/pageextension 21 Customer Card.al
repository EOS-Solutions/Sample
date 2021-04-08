pageextension 60000 "EOS PageExt60000" extends "Customer Card" //21
{
    layout
    {
        addafter(General)
        {
            group("EOS Additional Data EXT")
            {
                Caption = 'Additional Data EXT';
                field("EOS Additional Code"; "EOS Additional Code")
                {
                }
                field("EOS Additional Description"; "EOS Additional Description")
                {
                }
                field("EOS Additional Ref. No."; "EOS Additional Ref. No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}