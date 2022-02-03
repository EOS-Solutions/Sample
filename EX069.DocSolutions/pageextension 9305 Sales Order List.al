pageextension 18121928 "EOS PageExt18121928" extends "Sales Order List" //9305
{
    layout
    {
        // Add changes to page layout here

        addfirst(factboxes)
        {
            part("EOS DCS FactBox"; "EOS069 DCS FactBox")
            {
                Enabled = isVisible;
                Visible = isVisible;
                ApplicationArea = all;
                UpdatePropagation = SubPart;
            }
        }
    }
    actions
    {
        addlast(reporting)
        {
            action("EOS Print & Upload")
            {
                Enabled = isVisible;
                ToolTip = 'Will save the related report to Docsolutions.';
                ApplicationArea = All;
                Caption = 'Print & Upload (DCS)';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SendToMultiple;

                trigger OnAction()
                var
                    Selection: Record "Sales Header";
                    DocSolutionsManagement: Codeunit "EOS069 DocSolutions Management";
                    RecRef: recordref;
                begin
                    CurrPage.SetSelectionFilter(Selection);
                    if Selection.FindSet() then
                        repeat
                            RecRef.GETTABLE(Selection);
                            DocSolutionsManagement.PrintAndUpload(RecRef);
                        until Selection.Next() = 0;
                    CurrPage.Update();
                    CurrPage."EOS DCS FactBox".Page.AddinRefresh();
                end;
            }
        }
    }

    var
        isVisible: Boolean;
        alreadyChecked: Boolean;

    trigger OnAfterGetRecord()
    var
        DocSolutionsManagement: Codeunit "EOS069 DocSolutions Management";
    begin
        if not alreadyChecked then begin
            alreadyChecked := true;

            isVisible := DocSolutionsManagement.IsEnabledForRecordList(rec);
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if isVisible then
            CurrPage."EOS DCS FactBox".Page.SetCurrRecord(Database::"Sales Header", Rec."Document Type".AsInteger(), Rec.SystemId);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if isVisible then
            CurrPage."EOS DCS FactBox".Page.SetCurrRecord(Database::"Sales Header", Rec."Document Type".AsInteger(), Rec.SystemId);
    end;
}