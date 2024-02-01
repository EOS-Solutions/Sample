page 50100 "EAN128 Test"
{

    PageType = List;
    Caption = 'apiPageName';
    SourceTable = "EOS004 EAN128 Buffer";
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(AICode; Rec."AI Code")
                {
                    TableRelation = "EOS004 EAN128 Appl. Ident.".Code;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(AIDescription; GetAIDescription())
                {
                    Caption = 'AI Description';
                }
                field(AIDataType; GetAIDataType())
                {
                    Caption = 'AI Data Type';
                }
                field("Decimal Places"; Rec."Decimal Places")
                {
                    Enabled = DecimalPlacesEnabled;
                }
                field(AIValue; GetAIValue())
                {
                    Editable = false;
                    Caption = 'Value';

                    trigger OnAssistEdit()
                    begin
                        ShowSetValueDialog();
                    end;
                }
                field(EncodedValue; Rec.GetRawValue())
                {
                    Caption = 'Raw Value';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ClearPage)
            {
                Caption = 'Clear';
                Image = ClearLog;

                trigger OnAction()
                begin
                    ResetInstance();
                end;
            }
            action(Decode)
            {
                Caption = 'Decode';
                Image = BOM;

                trigger OnAction()
                var
                    InputDialog: Page "EAN128 Dialog";
                begin
                    if (InputDialog.RunModal() = Action::OK) then begin
                        Rec.Decode(InputDialog.EAN128String());
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
    }

    var
        AI: Record "EOS004 EAN128 Appl. Ident.";
        DecimalPlacesEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        GetAI();
        DecimalPlacesEnabled := (AI."Data Type" = Ai."Data Type"::Numeric) and (AI."Supports Decimal Places");
    end;

    local procedure ResetInstance()
    var
        Rec2: Record "EOS004 EAN128 Buffer";
    begin
        Rec.Copy(Rec2, true);
        CurrPage.Update(false);
    end;

    local procedure GetAI()
    begin
        if (AI.Code <> Rec."AI Code") then
            if (AI.Get(Rec."AI Code")) then;
    end;

    local procedure GetAIDescription(): Text
    begin
        GetAI();
        exit(AI.Description);
    end;

    local procedure GetAIDataType(): Enum EOS004_EAN128DataType
    begin
        GetAI();
        exit(AI."Data Type");
    end;

    local procedure GetAIValue(): Text
    var
        Result: Text;
    begin
        if (Rec.HasValue()) then
            if (TryGetAIValue(Result)) then
                exit(Result);
        exit('');
    end;

    [TryFunction]
    local procedure TryGetAIValue(var TextValue: Text)
    var
        DecimalVal: Decimal;
    begin
        if (Rec.DataType() = enum::EOS004_EAN128DataType::Date) then begin
            TextValue := Format(Rec.GetValueAsDate());
            exit;
        end;

        if (Rec.DataType() = Enum::EOS004_EAN128DataType::Numeric) then begin
            TextValue := Format(Rec.GetValueAsDecimal());
            exit;
        end;

        TextValue := Rec.GetValueAsText();
    end;

    local procedure ShowSetValueDialog()
    var
        SetValueDialog: Page SetValueDialog;
        DecimalValue: Decimal;
        DateValue: Date;
        NewValue: Variant;
    begin
        case Rec.DataType() of
            Enum::EOS004_EAN128DataType::"Alphanumeric Text",
            Enum::EOS004_EAN128DataType::"Numeric Text":
                SetValueDialog.Initialize(Rec.DataType(), Rec.GetValueAsText());
            Enum::EOS004_EAN128DataType::"Numeric":
                begin
                    if (Rec.TryGetValueAsDecimal(DecimalValue)) then;
                    SetValueDialog.Initialize(DecimalValue, Rec."Decimal Places");
                end;
            Enum::EOS004_EAN128DataType::"Date":
                begin
                    if Rec.TryGetValueAsDate(DateValue) then;
                    SetValueDialog.Initialize(DateValue);
                end;
        end;
        if (SetValueDialog.RunModal() = Action::OK) then begin
            NewValue := SetValueDialog.GetValue();
            if (NewValue.IsDecimal) then begin
                DecimalValue := NewValue;
                Rec.SetValue(DecimalValue, SetValueDialog.GetDecimalPlaces());
            end else
                Rec.SetValue(NewValue);
            Rec.Modify();
            CurrPage.Update(false);
        end;
    end;

}