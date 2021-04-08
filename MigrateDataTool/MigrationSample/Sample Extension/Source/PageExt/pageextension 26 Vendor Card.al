pageextension 60001 "EOS PageExt60001" extends "Vendor Card" //26
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