pageextension 18122012 "EOS PageExt18122012" extends "Purchase Order"//50
{

    actions
    {
        addlast(Processing)
        {
            group(EOSAdvReporting)
            {
                Caption = 'Advanced Reporting';
                Image = Save;
                Action("EOS Advanced Reporting Send")
                {
                    ApplicationArea = All;
                    Caption = 'Send';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = SendEmailPDF;
                    Visible = EOSShowSendAction;
                    ToolTip = 'Executes the action Send';
                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                        AdvDocMngt: Codeunit "EOS AdvDoc Mngt";
                    begin
                        CurrPage.SetSelectionFilter(PurchaseHeader);
                        AdvDocMngt.ShowSendDialog(PurchaseHeader);
                    end;
                }

                Action("EOS Advanced Reporting Save")
                {
                    ApplicationArea = All;
                    Caption = 'Save';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Save;
                    Visible = EOSShowSaveAction;
                    ToolTip = 'Executes the action Save';
                    trigger OnAction()
                    var
                        PurchaseHeader: Record "Purchase Header";
                        AdvDocMngt: Codeunit "EOS AdvDoc Mngt";
                    begin
                        CurrPage.SetSelectionFilter(PurchaseHeader);
                        AdvDocMngt.ShowSaveDialog(PurchaseHeader);
                    end;
                }
            }
        }
    }

    var
        EOSAdvRptUserInterface: Codeunit "EOS AdvRpt User Interface";

        EOSShowDocumentStatusField: Boolean;
        EOSShowSaveAction: Boolean;
        EOSShowSendAction: Boolean;

    trigger OnOpenPage()
    begin
        EOSAdvRptUserInterface.GetPageActionsVisibility(Rec.TableName(), CurrPage.ObjectId(false), EOSShowSaveAction, EOSShowSendAction, EOSShowDocumentStatusField);
    end;
}