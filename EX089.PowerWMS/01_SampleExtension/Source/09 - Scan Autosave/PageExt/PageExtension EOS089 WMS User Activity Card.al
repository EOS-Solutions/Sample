pageextension 50104 "EOS Scan Autosave" extends "EOS089 WMS User Activity Card"
{
    layout
    {
        addlast(AllowedActions)
        {
            group(EOSScanAutosave)
            {
                ShowCaption = false;
                Visible = ShowScanAutosave;
                Editable = EditScanAutosave;

                field("EOS Scan Autosave"; Rec."Scan Autosave")
                {
                    ApplicationArea = All;
                    ToolTip = 'Automatically save the scan results.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetScanAutosaveSettings();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetScanAutosaveSettings();
    end;

    local procedure SetScanAutosaveSettings()
    begin
        ShowScanAutosave := Rec.Activity = Enum::"EOS089 WMS Activity Type"::InvtMovement;
        EditScanAutosave := Rec.Activity = Enum::"EOS089 WMS Activity Type"::InvtMovement;
    end;

    var
        ShowScanAutosave: Boolean;
        EditScanAutosave: Boolean;
}
