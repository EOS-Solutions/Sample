// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 50100 "EOS PageExt50100" extends "EOS Purchase Request"
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
                    TempRecordIdentBuffer: Record "EOS Record Ident. Buffer" temporary;
                    TempFileBuffer: Record "EOS069 File Buffer" temporary;
                    ControlAddinMgt: Codeunit "EOS069 ControlAddin Mgt.";
                    PurchaseRequest: Report "EOS Purchase Request";
                    os: OutStream;
                begin
                    RecRef.GETTABLE(Rec);

                    TempRecordIdentBuffer.DecodeRecord(RecRef);
                    TempRecordIdentBuffer."Source GUID" := RecRef.Field(RecRef.SystemIdNo()).Value();
                    ControlAddinMgt.Init(TempRecordIdentBuffer);
                    TempFileBuffer.Init();
                    TempFileBuffer."Entry No." := TempFileBuffer.NextEntryNo();
                    TempFileBuffer."File Name" := CopyStr('test.pdf', 1, MaxStrLen(TempFileBuffer."File Name"));
                    TempFileBuffer."Source Subtype" := TempRecordIdentBuffer."Source Subtype";
                    TempFileBuffer."Source Type" := TempRecordIdentBuffer."Source Type";
                    TempFileBuffer."System ID" := TempRecordIdentBuffer."Source GUID";
                    TempFileBuffer."File Content".CreateOutStream(os);

                    RecRef.SetRecFilter();
                    PurchaseRequest.SetParameter(rec."EOS No.");
                    PurchaseRequest.SaveAs('', ReportFormat::Pdf, os, RecRef);
                    //Report.SaveAs(Report::"EOS Purchase Request", PurchaseRequest.RunRequestPage(), ReportFormat::Pdf, os, RecRef);

                    TempFileBuffer.Insert();
                    ControlAddinMgt.AfterFileDropped(TempFileBuffer);
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
            CurrPage."EOS DCS FactBox".Page.SetCurrRecord(Database::"EOS Purch. Request Header", Rec.SystemId);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if isVisible then
            CurrPage."EOS DCS FactBox".Page.SetCurrRecord(Database::"EOS Purch. Request Header", Rec.SystemId);
    end;

}