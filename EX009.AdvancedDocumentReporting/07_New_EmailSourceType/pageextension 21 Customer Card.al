pageextension 61500 "EXA Page61500" extends "Customer Card" //21
{
    layout
    {
        addlast(ContactDetails)
        {
            field("Email 2 Example"; "EXA Email 2 Example")
            {
                ApplicationArea = All;
            }
        }
    }
}