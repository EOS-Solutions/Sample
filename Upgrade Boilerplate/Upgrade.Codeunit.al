codeunit 9999990 "EOSxxx Upgrade" // replace xxx with your 3 digit extension code and assign a correct ID
{

    SubType = Upgrade;
    Access = Internal; // no need for the outside world to access this codeunit

    var
        UpgTag: Codeunit "EOS004 Upgrade Tags"; // this Codeunit is in "EOS Administration Library"


    // Event that makes sure that all upgrade tags for the currently installed version are also created when new companies are created.
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', true, false)]
    local procedure OnGetPerCompanyUpgradeTags()
    begin
        CreateUpgradeTags();
    end;


    local procedure InitCodeunit()
    var
        mi: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mi);
        UpgTag.SetApp(mi);
    end;


    // This is an utilty function that is used here (see event subscriber above) as well as in the installation codeunit.
    // Remember to add any new upgrades you implement here as well
    internal procedure CreateUpgradeTags()
    begin
        InitCodeunit();

        UpgTag.SetUpgradeTagIfNotExists(<workitem-id-1>); // work item ID for 'RunUpgradeProcedureOne'
        UpgTag.SetUpgradeTagIfNotExists(<workitem-id-1>); // work item ID for 'RunUpgradeProcedureTwo'
        UpgTag.SetUpgradeTagIfNotExists(<workitem-id-1>); // work item ID for 'RunUpgradeProcedureThree'
        // ...
    end;


    trigger OnUpgradePerCompany()
    begin
        InitCodeunit();

        RunUpgradeProcedureOne(<workitem-id-1>); // work item ID for 'RunUpgradeProcedureOne'
        RunUpgradeProcedureTwo(<workitem-id-1>); // work item ID for 'RunUpgradeProcedureTwo'
        RunUpgradeProcedureThree(<workitem-id-1>); // work item ID for 'RunUpgradeProcedureThree'
        // ...
    end;

    local procedure RunUpgradeProcedureOne(WorkItemID: Integer)
    begin
        if (not UpgTag.SetUpgradeTagIfNotExists(WorkItemID)) then exit;

        // do stuff
    end;

    local procedure RunUpgradeProcedureTwo(WorkItemID: Integer)
    begin
        if (not UpgTag.SetUpgradeTagIfNotExists(WorkItemID)) then exit;

        // do stuff
    end;

    local procedure RunUpgradeProcedureThree(WorkItemID: Integer)
    begin
        if (not UpgTag.SetUpgradeTagIfNotExists(WorkItemID)) then exit;

        // do stuff
    end;

}