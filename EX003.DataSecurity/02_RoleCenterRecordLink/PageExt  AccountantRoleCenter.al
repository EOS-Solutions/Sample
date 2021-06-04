pageextension 50150 "EOS AccountantRole" extends "Accountant Role Center"
{
    layout
    {
        addlast(rolecenter)
        {
            part("EOS My Notes"; "EOS My Notes")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }
}