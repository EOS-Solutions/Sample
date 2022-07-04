codeunit 50100 "ChuckNorrisClient"
{

    procedure GetCategories(): List of [Text]
    var
        rc: Codeunit "EOS004 REST Client";
        ja: JsonArray;
        Result: List of [Text];
        jt: JsonToken;
    begin
        // https://api.chucknorris.io/
        rc.BaseUri('https://api.chucknorris.io');
        rc.Method('GET');
        if not rc.SendRequest('jokes/categories') then; // the request failed at transport level
        rc.ThrowIfNotSuccessStatus(); // the request failed at protocol level
        ja := rc.ResponseBodyAsJsonArray();

        foreach jt in ja do
            Result.Add(jt.AsValue().AsText());
        exit(Result);
    end;

    procedure GetRandomFact(var TempResult: Record "Chuck Norris Fact")
    begin
        GetRandomFact('', TempResult);
    end;

    procedure GetRandomFact(Category: Text; var TempResult: Record "Chuck Norris Fact")
    var
        rc: Codeunit "EOS004 REST Client";
        jo: JsonObject;
        Result: List of [Text];
    begin
        // https://api.chucknorris.io/
        rc.BaseUri('https://api.chucknorris.io');
        rc.Method('GET');
        if (Category <> '') then
            rc.AddQueryParam('category', Category);
        if not rc.SendRequest('jokes/random') then; // the request failed at transport level
        rc.ThrowIfNotSuccessStatus(); // the request failed at protocol level
        jo := rc.ResponseBodyAsJsonObject();

        TempResult.Deserialize(jo);
    end;

    procedure Search(term: Text; var TempResult: Record "Chuck Norris Fact"): Integer
    var
        rc: Codeunit "EOS004 REST Client";
        jh: Codeunit "EOS JSON Helper";
        jo: JsonObject;
        ja: JsonArray;
        Result: List of [Text];
        jt: JsonToken;
    begin
        // https://api.chucknorris.io/
        rc.BaseUri('https://api.chucknorris.io');
        rc.Method('GET');
        rc.AddQueryParam('query', term);
        if not rc.SendRequest('jokes/search') then; // the request failed at transport level
        rc.ThrowIfNotSuccessStatus(); // the request failed at protocol level
        jo := rc.ResponseBodyAsJsonObject();

        if (jh.GetInt(jo, 'total') = 0) then
            Error('Nothing here.');

        ja := jh.GetArray(jo, 'result');
        foreach jt in ja do begin
            TempResult.Deserialize(jt.AsObject());
            TempResult.Insert();
        end;

        exit(jh.GetInt(jo, 'total'));
    end;

}