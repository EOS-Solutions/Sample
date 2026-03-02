page 50101 ChuckNorrisFacts
{

    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Chuck Norris Fact";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {

                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                }
                field(Url; Rec.Url)
                {
                    ApplicationArea = All;
                }
                field("Text"; Rec."Text")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        Message(Rec.Text);
                    end;
                }
                field(Updated; Rec.Updated)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(GetCategories)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    cl: Codeunit ChuckNorrisClient;
                    el: Codeunit "EOS Library EXT";
                    categories: List of [Text];
                begin
                    categories := cl.GetCategories();
                    Message(el.JoinText(categories, ' '));
                end;
            }
            action(GetRandomFactAction)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    GetRandomFact();
                end;
            }
        }
    }

    local procedure GetRandomFact()
    var
        TempResult: Record "Chuck Norris Fact";
        sc: Record "EOS004 Service Config.";
        cl: Codeunit "ChuckNorrisClient";
    begin
        sc.Get('CHUCK');
        cl.Initialize(sc);
        cl.GetRandomFact(TempResult);
        Rec := TempResult;
        if Rec.Insert() then;
    end;

}