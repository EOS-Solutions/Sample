pageextension 18121905 "EOS PageExt18121905" extends "Sales Order" //42
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
                    DocSolutionsManagement: Codeunit "EOS069 DocSolutions Management";
                    RecRef: recordref;
                begin
                    RecRef.GETTABLE(Rec);
                    DocSolutionsManagement.PrintAndUpload(RecRef);
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

            isVisible := DocSolutionsManagement.IsEnabledForRecord(rec);
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