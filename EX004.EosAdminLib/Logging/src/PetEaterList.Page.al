page 50200 PetEaterList
{

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                Caption = 'What are they eating?';
                trigger OnAction()
                var
                    EatingThePets: Codeunit PetEeater;
                begin
                    EatingThePets.Run(Rec);
                end;
            }
        }
    }
}