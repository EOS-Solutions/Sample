pageextension 61105 "EOS PageExt18122193" extends "Administrator Main Role Center" //8900
{
    // Needed only in BC14 version

    layout
    {
        addlast(RoleCenter)
        {
            part("EOS SummPurch1"; "EOS Summary DS Purchase 1")
            {
                ApplicationArea = All;
            }
            part("EOS SummPurch2"; "EOS Summary DS Purchase 2")
            {
                ApplicationArea = All;
            }
            part("EOS SummPurch3"; "EOS Summary DS Purchase 3")
            {
                ApplicationArea = All;
            }
            part("EOS SummSales1"; "EOS Summary DS Sales 1")
            {
                ApplicationArea = All;
            }
            part("EOS SummSales2"; "EOS Summary DS Sales 2")
            {
                ApplicationArea = All;
            }
            part("EOS SummSales3"; "EOS Summary DS Sales 3")
            {
                ApplicationArea = All;
            }
            part("EOS SummCustom1"; "EOS Summary DS Custom 1")
            {
                ApplicationArea = All;
            }
            part("EOS SummCustom2"; "EOS Summary DS Custom 2")
            {
                ApplicationArea = All;
            }
            part("EOS SummCustom3"; "EOS Summary DS Custom 3")
            {
                ApplicationArea = All;
            }
            part("EOS SummCustom4"; "EOS Summary DS Custom 4")
            {
                ApplicationArea = All;
            }
        }
    }
}