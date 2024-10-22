codeunit 50100 "EOS004 APP Run. Check Consumer"
{
    var
        EOSAPPRunChkFacade: Codeunit "EOS004 APP Run. Check Facade";

    /// <summary>
    /// This is the main event Subscriber to let an APP activate for Env. Key Management
    /// APP configuration will then appear on "RuntimeCheck Setup" Page for manual RuntimeCheck and configuration
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS004 APP Run. Check Facade", 'OnBeforeLoadRuntimeCheckSetupSupportedAppList', '', false, false)]
    local procedure AddCurrentAppToList()
    var
        EOSEnvKeyCalcType: Enum "EOS004 Env. Key Calc. Type";
    begin

        EOSAPPRunChkFacade.AddCurrentAppToList(AppId(), EOSEnvKeyCalcType::Default);
    end;

    /// <summary>
    /// Sample function that calls AssertIsActive function to check if the Env. Key check 
    /// is activated and env key is valid in order to perform an action
    /// </summary>
    procedure ExecuteAction()
    begin
        EOSAPPRunChkFacade.AssertIsActive(AppId());

        message('you can do this!');
    end;

    /// <summary>
    /// Sample function that calls IsActive function to check if the Env. Key check
    /// is activated and env key is valid
    /// </summary>
    /// <returns> True if the App is active, False otherwise </returns>
    procedure IsActive(): Boolean
    begin
        exit(EOSAPPRunChkFacade.IsActive(AppId()));
    end;

    local procedure AppId(): Guid
    var
        modInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(modInfo);
        exit(modInfo.Id());
    end;
}


