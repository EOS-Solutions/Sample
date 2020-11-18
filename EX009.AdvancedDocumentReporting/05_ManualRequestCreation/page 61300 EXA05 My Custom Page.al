page 61300 "EXA05 My Custom Page"
{
    PageType = List;
    SourceTable = "EXA005 My Custom Table";
    Caption = 'EXA005 My Custom Page';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("SalesPerson Code"; "SalesPerson Code")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Language Code"; "Language Code")
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
            action(CreateRequestWithDocument)
            {
                ApplicationArea = All;
                Caption = 'Create Request With Document';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SendAsPDF;

                trigger OnAction()
                var
                    ManualRequestCreation: Codeunit "EXA05 Manual Request Creation";
                begin
                    ManualRequestCreation.CreateManualRequestWithDocument(Rec);
                end;
            }

            action(CreateRequestMultiDocument)
            {
                ApplicationArea = All;
                Caption = 'Create Request "multi document"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SendAsPDF;

                trigger OnAction()
                var
                    ManualRequestCreation: Codeunit "EXA05 Manual Request Creation";
                begin
                    ManualRequestCreation.CreateAuthomaticRequestWithMultiDocuments(Rec);
                end;
            }
        }
    }

}
