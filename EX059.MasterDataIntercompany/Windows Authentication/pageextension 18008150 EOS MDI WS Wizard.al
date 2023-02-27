pageextension 50000 "EOS PageExt50000" extends "EOS MDI WS Wizard" //18008150
{
    layout
    {
        // Add changes to page layout here
        modify(WSServerName)
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                ServerInstance: Record "Server Instance";
                MDIGenericLibrary: Codeunit "EOS MDI Generic Library";
                Choice: Integer;
                OptionList: Text;
            begin
                OptionList := DistinctValues(ServerInstance, ServerInstance.FIELDNO("Server Computer Name"));
                Choice := StrMenu(OptionList, 1);
                if Choice = 0 then
                    exit;
                text := SelectStr(Choice, OptionList);
                exit(true);
            end;
        }
        modify(WSInstanceName)
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                ServerInstance: Record "Server Instance";
                MDIGenericLibrary: Codeunit "EOS MDI Generic Library";
                Choice: Integer;
                OptionList: Text;
            begin
                OptionList := DistinctValues(ServerInstance, ServerInstance.FIELDNO("Service Name"));
                Choice := StrMenu(OptionList, 1);
                if Choice = 0 then
                    exit;
                Text := SelectStr(Choice, OptionList);
                exit(true);
            end;
        }
    }

    local procedure DistinctValues(SourceTable: Variant; FieldNo: Integer) Result: Text
    var
        DataTypeManagement: Codeunit "Data Type Management";
        FiRef: FieldRef;
        RecRef: RecordRef;
        BufferList: List of [Text];
        Value: Text;
    begin
        DataTypeManagement.GetRecordRef(SourceTable, RecRef);

        if RecRef.FindSet() then
            repeat
                FiRef := RecRef.Field(FieldNo);
                Value := Format(FiRef);
                if not BufferList.Contains(Value) then
                    BufferList.Add(Value);
            until RecRef.Next() = 0;

        foreach Value in BufferList do
            Result += Value + ',';

        Result := DelChr(Result, '<>', ',');
    end;
}