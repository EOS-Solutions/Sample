codeunit 50101 "ChuckNorrisClient v2" implements "EOS004 IServiceConnection"
{

    var
        GlobalServiceConfig: Record "EOS004 Service Config.";

    procedure InitRestClient(var rc: Codeunit "EOS004 REST Client")
    begin
        Clear(rc);
        rc.SetServiceConfig(GlobalServiceConfig.Code);
        rc.SetHeader('X-API-Key', GlobalServiceConfig.GetSettingValue('api-key', true, true));
        rc.BaseUri(GlobalServiceConfig."Endpoint Uri");
    end;

    procedure GetCategories(): List of [Text]
    var
        rc: Codeunit "EOS004 REST Client";
        ja: JsonArray;
        Result: List of [Text];
        jt: JsonToken;
    begin
        InitRestClient(rc);
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
        InitRestClient(rc);
        rc.Method('GET');

        if (Category = '') then
            Category := GlobalServiceConfig.GetSettingValue('category');

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
        InitRestClient(rc);
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

    procedure GetConfigurationKeys(): List of [Text[250]];
    var
        Result: List of [Text[250]];
    begin
        Result.Add('category');
        exit(Result);
    end;

    procedure GetSecretConfigurationKeys(): List of [Text[250]];
    var
        Result: List of [Text[250]];
    begin
        Result.Add('api-key');
        exit(Result);
    end;

    procedure Initialize(ServiceConfig: Record "EOS004 Service Config.");
    begin
        GlobalServiceConfig := ServiceConfig;
    end;

}