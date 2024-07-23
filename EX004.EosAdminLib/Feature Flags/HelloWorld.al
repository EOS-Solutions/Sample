codeunit 50100 FeatureFlagsDemo
{

    local procedure GetAppId(): Guid
    var
        mi: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mi);
        exit(mi.Id);
    end;

    // register your feature flag
    [EventSubscriber(ObjectType::Table, Database::"EOS004 Feature Flag", 'OnCollectFeatureFlags', '', false, false)]
    local procedure RegsiterFeatureFlag(var TempFeatureFlag: Record "EOS004 Feature Flag" temporary)
    begin
        TempFeatureFlag.InitNewRecordForCaller('MYFLAG', 'I make computer go beep boop beep beep boop.');
        TempFeatureFlag."Help URL" := 'http://www.quickmeme.com/img/99/9903c7c14add3fd0758b7b5b80c24d48101f296f13ce34736799a82c71f61bc2.jpg'; // moar help!!!!1111!
        TempFeatureFlag.Reversible := true; // is this flag reversible?
        TempFeatureFlag."Per Company" := true; // can the computer go beep boop beep beep boop only for certain companies?
        TempFeatureFlag.Insert();
    end;

    // implement custom logic to check if a flag can be enabled (or disabled)
    [EventSubscriber(ObjectType::Table, Database::"EOS004 Feature Flag", OnBeforeEnableDisableFeature, '', false, false)]
    local procedure BeforeEnableDisable(AppId: Guid; FeatureCode: Code[20]; NewIsEnabled: Boolean)
    begin
        if ((FeatureCode = 'MYFLAG') and (AppId = GetAppId()) and NewIsEnabled) then begin
            // check if we can make computer go beep boop beep beep boop
            // if not, cancel the operation by raising an error
        end;
    end;

    // implement custom logic to do setup, data preparation a.s.o. after a feature flag has been enabled (or disabled)
    [EventSubscriber(ObjectType::Table, Database::"EOS004 Feature Flag", OnAfterEnableDisableFeature, '', false, false)]
    local procedure AfterEnableDisable(AppId: Guid; FeatureCode: Code[20]; NewIsEnabled: Boolean)
    begin
        if ((FeatureCode = 'MYFLAG') and (AppId = GetAppId()) and NewIsEnabled) then begin
            // do things that are required after enabling the feature
        end;
    end;

    // it's considered best practice to keep all of your feature flags inside a single codeunit and expose them via functions, like below.
    // this way you can abstract the hardcoded feature codes away from the rest of your codebase
    // collecting and reading feature flags should not be too expensive because everything happens in temporary tables.
    // however, you may want to consider to use some sort of cache, depending on your use case to avoud excessive calls to the 'Collect' method.
    local procedure CanBeepBoopBeepBeepBoop(): Boolean
    var
        TempFeatureFlag: Record "EOS004 Feature Flag" temporary;
    begin
        TempFeatureFlag.Collect(false);
        TempFeatureFlag.GetRecordForCaller('MYFLAG');
        exit(TempFeatureFlag.IsEnabled());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure DoTheBeepBoopBeepBeepBoop()
    begin
        if (CanBeepBoopBeepBeepBoop()) then
            Message('Beep Boop Beep Beep Boop!');
    end;

}