pageextension 50105 "EOS Custom Act HU" extends "EOS089 WMS Custom Act. Card"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("EOS055.01 HU Factbox"; "EOS055.01 HU Factbox")
            {
                ApplicationArea = All;
                Visible = PartVisible;
                Enabled = PartVisible;
            }
        }

    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage."EOS055.01 HU Factbox".Page.SetSourceDocument(Rec);

        PartVisible := Rec."Activity Type" = Enum::"EOS089 WMS Activity Type"::EOSHUOnCustom;
    end;

    trigger OnAfterGetRecord()
    begin
        PartVisible := Rec."Activity Type" = Enum::"EOS089 WMS Activity Type"::EOSHUOnCustom;
    end;

    var
        PartVisible: Boolean;
}
