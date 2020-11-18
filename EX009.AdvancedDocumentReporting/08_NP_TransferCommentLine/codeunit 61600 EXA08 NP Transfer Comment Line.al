codeunit 61600 "EXA08 NP Transfer Comment Line"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvRpt Std Layout Ext", 'OnAfterApplyFiltersToInventoryCommentLine', '', true, false)]
    local procedure OnAfterApplyFiltersToInventoryCommentLine(RBHeader: Record "EOS Report Buffer Header";
                                                              RBLine: Record "EOS Report Buffer Line";
                                                              HeaderMode: Boolean;
                                                              var InventoryCommentLine: Record "Inventory Comment Line";
                                                              var Handled: Boolean)
    var
        FieldTable: Record Field;
        CommentRecRef: RecordRef;
        DocLineNo: Integer;
    begin
        if Handled then
            exit;

        if not (RBHeader."EOS Source Table ID" in [Database::"Transfer Header", Database::"Transfer Shipment Header", Database::"Transfer Receipt Header"]) then
            exit;

        //NP "Document Line No." is field no. "18004108"
        if not FieldTable.Get(Database::"Inventory Comment Line", 18004108) then
            exit;

        if HeaderMode then
            DocLineNo := 0
        else
            DocLineNo := RBLine."EOS Source Line No.";

        CommentRecRef.GetTable(InventoryCommentLine);
        CommentRecRef.Field(18004108).SetRange(DocLineNo);
        CommentRecRef.SetTable(InventoryCommentLine);

        Handled := true;
    end;
}