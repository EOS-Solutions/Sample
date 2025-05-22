page 50100 "EOS Custom Activity Setup"
{
    ApplicationArea = All;
    Caption = 'Custom Activity Setup (WMS)';
    PageType = Card;
    SourceTable = "EOS Custom Activity Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(CreateBox)
            {
                Caption = 'Create Box';

                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the "Location Code" field', Comment = '%';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ToolTip = 'Specifies the value of the "Bin Code" field', Comment = '%';
                }
                field("Item No. 1"; Rec."Item No. 1")
                {
                    ToolTip = 'Specifies the value of the "Item No. 1" field', Comment = '%';
                }
                field("Item No. 2"; Rec."Item No. 2")
                {
                    ToolTip = 'Specifies the value of the "Item No. 2" field', Comment = '%';
                }
                field("Item No. 3"; Rec."Item No. 3")
                {
                    ToolTip = 'Specifies the value of the "Item No. 3" field', Comment = '%';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
