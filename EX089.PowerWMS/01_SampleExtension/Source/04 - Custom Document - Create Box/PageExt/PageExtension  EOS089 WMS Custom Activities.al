pageextension 50102 "EOS Custom Document" extends "EOS089 WMS Custom Activities"
{
    actions
    {
        addlast(Processing)
        {
            action(EOSCreateCustomDocumentBox)
            {
                ApplicationArea = All;
                Caption = 'Create Custom Document Sample';
                ToolTip = 'Create Custom Document Sample';
                Image = CreateDocument;

                trigger OnAction()
                var
                    EOSCustomDocumentMgmt: Codeunit "EOS Custom Document Mgmt.";
                begin
                    EOSCustomDocumentMgmt.CreateCustomDocument();
                end;
            }
        }
    }
}
