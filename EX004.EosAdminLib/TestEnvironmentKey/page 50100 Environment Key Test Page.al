page 50100 "Environment Key Test Page"
{
    ApplicationArea = All;
    Caption = 'Environment Key Test Page';
    PageType = Worksheet;

    layout
    {
        area(content)
        {

        }

    }
    actions
    {
        area(Processing)
        {
            action(DoSomething)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    EOSAPPRunChkConsumer: Codeunit "EOS004 APP Run. Check Consumer";
                begin
                    EOSAPPRunChkConsumer.ExecuteAction();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        EOSAPPRunChkConsumer: Codeunit "EOS004 APP Run. Check Consumer";
    begin
        PageEditable := EOSAPPRunChkConsumer.IsActive();
    end;

    trigger OnAfterGetRecord()
    begin
        CurrPage.Editable := PageEditable;

    end;

    var
        PageEditable: Boolean;
}
