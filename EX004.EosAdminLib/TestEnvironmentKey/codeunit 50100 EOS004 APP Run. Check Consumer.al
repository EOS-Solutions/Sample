codeunit 50100 "EOS004 APP Access Check Consumer"
{


    /// <summary>
    /// This is the main event Subscriber to let an APP activate for Env. Key Management
    /// APP configuration will then appear on "Access Check Setup" Page for manual Check and configuration
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS004 APP Access Check Facade", 'OnBeforeLoadAccessCheckSetupSupportedAppList', '', false, false)]
    local procedure AddCurrentAppToList(sender: Codeunit "EOS004 APP Access Check Facade")
    var
        EOSEnvKeyCalcType: Enum "EOS004 Env. Key Calc. Type";
    begin

        sender.AddCurrentAppToList(AppId(), EOSEnvKeyCalcType::Default);
    end;

    /// <summary>
    /// Sample function that calls AssertIsActive function to check if the Env. Key check 
    /// is activated and env key is valid in order to perform an action
    /// </summary>
    procedure ExecuteAction()
    var
        EOSAPPAccessChkFacade: Codeunit "EOS004 APP Access Check Facade";
    begin
        EOSAPPAccessChkFacade.AssertIsActive(AppId());

        message('you can do this!');
    end;

    /// <summary>
    /// Sample function that calls IsActive function to check if the Env. Key check
    /// is activated and env key is valid
    /// </summary>
    /// <returns> True if the App is active, False otherwise </returns>
    procedure IsActive(): Boolean
    begin
        exit(EOSAPPAccessChkFacade.IsActive(AppId()));
    end;

    /// <summary>
    /// Utility function to get the current AppId
    /// </summary>
    /// <returns>Guid</returns>
    local procedure AppId(): Guid
    var
        modInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(modInfo);
        exit(modInfo.Id());
    end;
}