pageextension 50003 "EOS074.02 EDI Mess. Card Ext." extends "EOS074 EDI Message Card" //70491820
{
    layout
    {
        addlast(factboxes)
        {
            part("EOS074.02 Control1101318001"; "EOS074.02 EDI Files Factbox")
            {
                SubPageLink = "Message Type" = field("Message Type"),
                              "Message No." = field("No.");
                ApplicationArea = All;
            }
        }
    }
}