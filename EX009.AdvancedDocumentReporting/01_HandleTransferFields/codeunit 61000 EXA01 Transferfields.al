codeunit 61000 "EXA01 Transferfields"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnAfterLineParsing', '', false, true)]
    local procedure OnAfterLineParsing(HeaderRecRef: RecordRef; CurrentLineRecRef: RecordRef; var RBHeader: Record "EOS Report Buffer Header"; var RBLine: Record "EOS Report Buffer Line")
    var 
        SalesLine: Record "Sales Line";
    begin
        if CurrentLineRecRef.Number() <> database::"Sales Line" then
        exit;
        
        //Salesline."EXA MyExtension Field" is field 61000
        //ReportBufferLine."EXA MyExtension Field" is 61010

        RBLine."EXA MyExtension Field" := CurrentLineRecRef.Field(SalesLine.FieldNo("EXA MyExtension Field")).Value();
    end;
}