pageextension 61400 "EOS PageExt61400" extends "Released Production Order"//99000831
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(Reporting)
        {
            action(CustomReport)
            {
                Caption = 'Custom Report';
                Image = PrintReport;
                Promoted = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    AdvRptSharedMemory: Codeunit "EOS AdvRpt SharedMemory";
                    ProductionOrder: Record "Production Order";
                    DocVariant: Variant;
                begin
                    ProductionOrder := Rec;
                    ProductionOrder.SetRecFilter();
                    DocVariant := ProductionOrder;
                    clear(AdvRptSharedMemory);
                    AdvRptSharedMemory.SetCustomReportDocument(DocVariant);
                    AdvRptSharedMemory.SetReportSetup('DEFAULT');
                    report.RunModal(Report::"EOS Sales Document", true, false);
                end;

            }
        }
    }

    var
        myInt: Integer;
}