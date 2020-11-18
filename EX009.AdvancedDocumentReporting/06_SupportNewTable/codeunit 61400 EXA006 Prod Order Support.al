codeunit 61400 "EXA06 Prod Order Support"
{

    //Support for production order document
    //It is completely different and therefore we will have to support many things

    // Buffer Handling 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnApplyFiltersToDocumentLine', '', false, true)]
    local procedure OnApplyFiltersToDocumentLine(HeaderRecRef: RecordRef;
                                                 var ReportHeader: Record "EOS Report Buffer Header";
                                                 var Lines: RecordRef;
                                                 var Handled: Boolean)
    var
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        if HeaderRecRef.Number() <> Database::"Production Order" then
            exit;

        ProductionOrder.Get(HeaderRecRef.RecordId);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
        DataTypeManagement.GetRecordRef(ProdOrderLine, Lines);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnBeforeHeaderParsing', '', true, true)]
    local procedure OnBeforeHeaderParsing(HeaderRecRef: RecordRef;
                                          var ReportHeader: Record "EOS Report Buffer Header";
                                          var Handled: Boolean)
    var
        ProductionOrder: Record "Production Order";
    begin
        if HeaderRecRef.Number() <> Database::"Production Order" then
            exit;

        if Handled then
            exit;

        ProductionOrder.Get(HeaderRecRef.RecordId);

        ReportHeader.UpdateDefaultReportTitle(HeaderRecRef, HeaderRecRef.Caption);
        ReportHeader."EOS Source Subtype" := 0;
        ReportHeader."EOS Source ID" := ProductionOrder."No.";
        ReportHeader."EOS No." := ProductionOrder."No.";
        ReportHeader."EOS Posting Date" := ProductionOrder."Due Date";

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnBeforeLineParsing', '', false, true)]
    local procedure OnBeforeLineParsing(HeaderRecRef: RecordRef;
                                        CurrentLineRecRef: RecordRef;
                                        var RBHeader: Record "EOS Report Buffer Header";
                                        var RBLine: Record "EOS Report Buffer Line";
                                        var SkipLine: Boolean;
                                        var Handled: Boolean);
    var
        ProductionOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if CurrentLineRecRef.Number() <> Database::"Prod. Order Line" then
            exit;

        if Handled then
            exit;

        ProductionOrder.Get(HeaderRecRef.RecordId);
        ProdOrderLine.Get(CurrentLineRecRef.RecordId);

        RBLine."EOS Source ID" := ProdOrderLine."Prod. Order No.";
        RBLine."EOS Line No." := ProdOrderLine."Line No.";
        RBLine."EOS Type" := RBLine."EOS Type"::Item;
        RBLine."EOS No." := ProdOrderLine."Item No.";

        RBLine."EOS Description" := ProdOrderLine.Description;
        RBLine."EOS Description 2" := ProdOrderLine."Description 2";
        RBLine."EOS Quantity" := ProdOrderLine.Quantity;
        RBLine."EOS Quantity (Base)" := ProdOrderLine."Quantity (Base)";
        RBLine."EOS Qty. per Unit of Measure" := ProdOrderLine."Qty. per Unit of Measure";
        RBLine."EOS Shortcut Dimension 2 Code" := ProdOrderLine."Shortcut Dimension 2 Code";
        RBLine."EOS Unit of Measure Code" := ProdOrderLine."Unit of Measure Code";
        RBLine."EOS Shipment Date" := ProdOrderLine."Due Date";
        Handled := true;
    end;
}