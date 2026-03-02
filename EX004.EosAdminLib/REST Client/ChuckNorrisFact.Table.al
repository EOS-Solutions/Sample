table 50100 "Chuck Norris Fact"
{

    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Text[100])
        {
            DataClassification = SystemMetadata;

        }
        field(20; Updated; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(30; Text; Text[2048])
        {
            DataClassification = SystemMetadata;
        }
        field(40; Url; Text[150])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    procedure Deserialize(jo: JsonObject)
    var
        jh: Codeunit "EOS JSON Helper";
    begin
        Id := jh.GetText(jo, 'id');
        Evaluate(Updated, CopyStr(jh.GetText(jo, 'updated_at'), 1, 10), 9);
        Url := CopyStr(jh.GetText(jo, 'url'), 1, MaxStrLen(Url));
        Text := CopyStr(jh.GetText(jo, 'value'), 1, MaxStrLen(Text));
    end;

}