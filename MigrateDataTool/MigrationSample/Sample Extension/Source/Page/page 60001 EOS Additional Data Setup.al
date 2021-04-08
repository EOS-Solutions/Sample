page 60001 "EOS Additional Data Setup"
{
    Caption = 'Additional Data Setup (MIG)';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {

    }

    actions
    {
        area(Processing)
        {
            action("Import Data")
            {
                ApplicationArea = All;
                Image = Migration;

                trigger OnAction()
                var
                    DataMigration: Codeunit "EOS Additional Data Migration";
                    JSONImport: Page "EOS JSON Import";
                begin
                    JSONImport.ShowPage(DataMigration.GetImportId());
                end;
            }
        }
    }
}