codeunit 50100 "ChuckNorrisClient" implements "EOS004 IServiceConnection"
{

    var
        GlobalServiceConfig: Record "EOS004 Service Config.";

    procedure InitRestClient(var rc: Codeunit "EOS004 REST Client")
    var
        auth: Interface "Http Authentication";
    begin
        Clear(rc);

        // When setting the service config, the client will automatically pick up any configuration settings (like timeout a.s.o.). 
        // This will also enable you to use the integrated request logging.
        rc.SetServiceConfig(GlobalServiceConfig.Code);

        // If your API requires authentication, create the right authentication object and set it on the client.
        // This uses the BC authentication interface.
        rc.UseAuthentication(CreateAuthentication(0));

        // Specify a base URL to use.
        rc.BaseUri(GlobalServiceConfig."Endpoint Uri");
    end;

    local procedure CreateAuthentication(AuthType: Option Anonymous,Basic,ApiKey,OAuth): Interface "Http Authentication"
    var
        AnonynmousAuth: Codeunit "Http Authentication Anonymous";
        BasicAuth: Codeunit "Http Authentication Basic";
        OAuthAuth: Codeunit HttpAuthOAuthClientCredentials;
        ApiKeyAuth: Codeunit "EOS004 API Key Authentication";
        OAuthScopes: List of [Text];
        secretText: SecretText;
        NonSecretText: Text;
    begin
        case AuthType of
            AuthType::Basic:
                begin
                    NonsecretText := 'password';
                    secretText := NonSecretText;
                    BasicAuth.Initialize('username', '', secretText);
                    exit(BasicAuth);
                end;
            AuthType::ApiKey:
                begin
                    ApiKeyAuth.Initialize('x-api-key', GlobalServiceConfig.GetSettingValueAsSecret('api-key', true));
                    exit(ApiKeyAuth);
                end;
            AuthType::OAuth:
                begin
                    NonsecretText := '<client_secret>';
                    secretText := NonSecretText;
                    OAuthAuth.Initialize('<authority_url>', '<client_id>', secretText, OAuthScopes);
                    exit(OAuthAuth);
                end;
            else
                exit(AnonynmousAuth)
        end;
    end;

    procedure GetCategories(): List of [Text]
    var
        rc: Codeunit "EOS004 REST Client";
        ja: JsonArray;
        Result: List of [Text];
        jt: JsonToken;
    begin
        // Create the REST client
        InitRestClient(rc);
        // Specify the method to use.
        rc.Method('GET');
        // Specify the resource to sent the request to. The actual API URL will be constructed from the base URL specified earlier and this resource string.
        if not rc.SendRequest('jokes/categories') then; // the request failed at transport level
        rc.ThrowIfNotSuccessStatus(); // the request failed at protocol level
        // return the response as a JSON array
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
        // Create the REST client
        InitRestClient(rc);
        // Specify the method to use.
        rc.Method('GET');

        // Add a query parameter, if the category was configured either in the service config or passed in as parameter.
        if (Category = '') then
            Category := GlobalServiceConfig.GetSettingValue('category', true);
        if (Category <> '') then
            rc.AddQueryParam('category', Category);

        // Specify the resource to sent the request to. The actual API URL will be constructed from the base URL specified earlier and this resource string.
        if not rc.SendRequest('jokes/random') then; // the request failed at transport level
        rc.ThrowIfNotSuccessStatus(); // the request failed at protocol level
        // return the response as a JSON object
        jo := rc.ResponseBodyAsJsonObject();

        TempResult.Deserialize(jo);
    end;

    procedure Search(term: Text; var TempResult: Record "Chuck Norris Fact"): Integer
    var
        rc: Codeunit "EOS004 REST Client";
        jo: JsonObject;
        ja: JsonArray;
        Result: List of [Text];
        jt: JsonToken;
    begin
        // Create the REST client
        InitRestClient(rc);
        // Specify the method to use.
        rc.Method('GET');

        // Add a query parameter for the search term
        rc.AddQueryParam('query', term);
        // Specify the resource to sent the request to. The actual API URL will be constructed from the base URL specified earlier and this resource string.
        if not rc.SendRequest('jokes/search') then; // the request failed at transport level
        rc.ThrowIfNotSuccessStatus(); // the request failed at protocol level
        jo := rc.ResponseBodyAsJsonObject();

        if (jo.GetInteger('total') = 0) then
            Error('Nothing here.');

        ja := jo.GetArray('result');
        foreach jt in ja do begin
            TempResult.Deserialize(jt.AsObject());
            TempResult.Insert();
        end;

        exit(jo.GetInteger('total'));
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