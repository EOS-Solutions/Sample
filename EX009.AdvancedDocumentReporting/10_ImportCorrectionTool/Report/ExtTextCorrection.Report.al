report 50080 "EOSTOOL ExtText Correction"
{
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Extended Text Import Corrector [TOOLS]';

    dataset
    {
        dataitem("AdvTextHead"; "EOS009 Doc. Adv. Text Header")
        {
            trigger OnPreDataItem()
            var
                Conf1Lbl: Label 'Do you want to correct extended Text - Header? - Counter: %1';
                Conf2Lbl: Label 'Do you want erease all Extended Text - Header? - Counter: %1';
            begin
                if ExtTextType = ExtTextType::Line then CurrReport.Skip();
                case TableSource of
                    TableSource::Customer:
                        AdvTextHead.SetFilter("EOSTOOL Temp Customer No.", '<>%1', '');
                    TableSource::Vendor:
                        AdvTextHead.SetFilter("EOSTOOL Temp Vendor No.", '<>%1', '');
                end;
                case ActionType of
                    ActionType::Correction:
                        if not Confirm(Conf1Lbl, true, format(AdvTextHead.Count)) then begin
                            CurrReport.Break();
                            Clear(BoolNotProcessed);
                            BoolNotProcessed := True;
                        end;
                    ActionType::Delete:
                        if not Confirm(Conf2Lbl, true, format(AdvTextHead.Count)) then begin
                            CurrReport.Break();
                            Clear(BoolNotProcessed);
                            Clear(RecCount);
                            RecCount := AdvTextHead.COUNT;
                            RecNo := 0;
                            BoolNotProcessed := True;
                        end;
                end;
                Window.OPEN(DialogTxt);
            end;

            trigger OnAfterGetRecord()
            begin
                if ExtTextType = ExtTextType::Line then CurrReport.Skip();
                RecNo += 1;
                case TableSource of
                    TableSource::Customer:
                        Window.UPDATE(1, AdvTextHead."EOSTOOL Temp Customer No.");
                    TableSource::Vendor:
                        Window.UPDATE(1, AdvTextHead."EOSTOOL Temp Vendor No.");
                end;
                Window.UPDATE(2, ROUND(RecNo / RecCount * 10000, 1));
                case ActionType of
                    ActionType::Correction:
                        AdvTextHeaderCorrection(AdvTextHead);
                    ActionType::Delete:
                        AdvTextHead.Delete();
                end;
            end;

            trigger OnPostDataItem()
            var
                Msg1Lbl: Label 'Processed.';
                Msg2Lbl: Label 'Operation cancelled';
            begin
                if ExtTextType = ExtTextType::Line then CurrReport.Skip();
                if BoolNotProcessed = True then
                    Message(Msg2Lbl);
                if BoolNotProcessed = False then
                    Message(Msg1Lbl);
                Window.CLOSE();
            end;
        }
        dataitem("AdvTextLine"; "EOS009 Doc. Adv. Text Line")
        {
            trigger OnPreDataItem()
            var
                Conf1Lbl: Label 'Do you want to correct extended Text - Line? - Counter: %1';
                Conf2Lbl: Label 'Do you want erease all Extended Text - Header? - Counter: %1';
            begin
                if ExtTextType = ExtTextType::Header then CurrReport.Skip();
                case TableSource of
                    TableSource::Customer:
                        AdvTextLine.SetFilter("EOSTOOL Temp Customer No.", '<>%1', '');
                    TableSource::Vendor:
                        AdvTextLine.SetFilter("EOSTOOL Temp Vendor No.", '<>%1', '');
                end;
                case ActionType of
                    ActionType::Correction:
                        if not Confirm(Conf1Lbl, true, format(AdvTextLine.Count)) then begin
                            CurrReport.Break();
                            Clear(BoolNotProcessed);
                            BoolNotProcessed := True;
                        end;
                    ActionType::Delete:
                        if not Confirm(Conf2Lbl, true, format(AdvTextLine.Count)) then begin
                            CurrReport.Break();
                            Clear(BoolNotProcessed);
                            BoolNotProcessed := True;
                        end;
                end;
                RecCount := AdvTextLine.COUNT;
                RecNo := 0;
                Window.OPEN(DialogTxt);
            end;

            trigger OnAfterGetRecord()
            begin
                if ExtTextType = ExtTextType::Header then CurrReport.Skip();
                RecNo += 1;
                case TableSource of
                    TableSource::Customer:
                        Window.UPDATE(1, AdvTextLine."EOSTOOL Temp Customer No.");
                    TableSource::Vendor:
                        Window.UPDATE(1, AdvTextLine."EOSTOOL Temp Vendor No.");
                end;
                Window.UPDATE(2, ROUND(RecNo / RecCount * 10000, 1));
                case ActionType of
                    ActionType::Correction:
                        AdvTextLineCorrection(AdvTextLine);
                    ActionType::Delete:
                        AdvTextLine.Delete();
                end;
            end;

            trigger OnPostDataItem()
            var
                Msg1Lbl: Label 'Processed.';
                Msg2Lbl: Label 'Operation cancelled';
            begin
                if ExtTextType = ExtTextType::Header then CurrReport.Skip();
                if BoolNotProcessed = True then
                    Message(Msg2Lbl);
                if BoolNotProcessed = False then
                    Message(Msg1Lbl);
                Window.CLOSE();
            end;
        }
    }

    requestpage
    {
        ShowFilter = false;
        layout
        {
            area(Content)
            {
                //Start Extend for Vendor
                field(TableSource_; TableSource)
                {
                    Caption = 'Table Source';
                    ToolTip = 'Table Source';
                    OptionCaption = 'Customer, Vendor';
                    ApplicationArea = All;
                }
                //Stop Extend for Vendor
                field("ExtText Type"; ExtTextType)
                {
                    Caption = 'Extended Text Type';
                    ToolTip = 'Extended Text Type';
                    OptionCaption = 'Header,Line';
                    ApplicationArea = All;
                }
                field(ActionType_; ActionType)
                {
                    Caption = 'Action Type';
                    ToolTip = 'Action Type';
                    OptionCaption = 'Correction, Delete';
                    ApplicationArea = All;
                }
            }
        }
    }
    local procedure AdvTextHeaderCorrection(ParAdvTextHead: Record "EOS009 Doc. Adv. Text Header")
    var
        VarCustomer: Record Customer;
        VarVendor: Record Vendor; //extended Vendor Table
    begin
        case TableSource of
            TableSource::Customer:
                if VarCustomer.get(ParAdvTextHead."EOSTOOL Temp Customer No.") then begin
                    ParAdvTextHead."Source GUID" := VarCustomer.id;
                    ParAdvTextHead."EOSTOOL Temp Customer No." := '';
                    ParAdvTextHead.Modify();
                end;
            TableSource::Vendor:
                if VarVendor.get(ParAdvTextHead."EOSTOOL Temp Vendor No.") then begin
                    ParAdvTextHead."Source GUID" := VarVendor.id;
                    ParAdvTextHead."EOSTOOL Temp Vendor No." := '';
                    ParAdvTextHead.Modify();
                end;
        end;
    end;

    local procedure AdvTextLineCorrection(ParAdvTextLine: Record "EOS009 Doc. Adv. Text Line")
    var
        VarCustomer: Record Customer;
        VarVendor: Record Vendor; //extended Vendor Table
    begin
        case TableSource of
            TableSource::Customer:
                if VarCustomer.get(ParAdvTextLine."EOSTOOL Temp Customer No.") then begin
                    ParAdvTextLine."Source GUID" := VarCustomer.id;
                    ParAdvTextLine.SystemId := VarCustomer.SystemId;
                    ParAdvTextLine."EOSTOOL Temp Customer No." := '';
                    ParAdvTextLine.Modify();
                end;
            TableSource::Vendor:
                if VarVendor.get(ParAdvTextLine."EOSTOOL Temp Vendor No.") then begin
                    ParAdvTextLine."Source GUID" := VarVendor.id;
                    ParAdvTextLine.SystemId := VarVendor.SystemId;
                    ParAdvTextLine."EOSTOOL Temp Vendor No." := '';
                    ParAdvTextLine.Modify();
                end;
        end;
    end;

    var
        ExtTextType: Option Header,Line;
        ActionType: Option Correction,Delete;
        TableSource: Option Customer,Vendor; //20201111 Extended for Vendors
        BoolNotProcessed: Boolean;
        Window: Dialog;
        RecNo: Integer;
        RecCount: Integer;
        DialogTxt: label 'ENU=#1########//@2@@@@@@@';
}
