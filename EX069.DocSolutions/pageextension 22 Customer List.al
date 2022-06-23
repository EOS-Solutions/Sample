pageextension 18121906 "EOS PageExt18121906" extends "Customer List" //22
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
                SubPageLink = "Source Type" = const(18), "Source GUID" = field(SystemId);
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
        //if isVisible then
        // CurrPage."EOS DCS FactBox".Page.SetCurrRecord(Database::Customer, SystemId);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // if isVisible then
        //  CurrPage."EOS DCS FactBox".Page.SetCurrRecord(Database::Customer, SystemId);
    end;

}