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

        UpgTag.SetUpgradeTagIfNotExists(<workitem-id-1>); // work item ID for 'RunUpgradeProcedure_One'
        UpgTag.SetUpgradeTagIfNotExists(<workitem-id-2>); // work item ID for 'RunUpgradeProcedure_Two'
        UpgTag.SetUpgradeTagIfNotExists(<workitem-id-3>); // work item ID for 'RunUpgradeProcedure_Three'
        // ...
    end;


    trigger OnUpgradePerCompany()
    begin
        InitCodeunit();

        RunUpgradeProcedure_One(); // work item ID for 'RunUpgradeProcedureOne'
        RunUpgradeProcedure_Two(); // work item ID for 'RunUpgradeProcedureTwo'
        RunUpgradeProcedure_Three(); // work item ID for 'RunUpgradeProcedureThree'
        // ...
    end;

    local procedure RunUpgradeProcedureOne()
    begin
        if (not UpgTag.BeginUpgrade(<workitem-id-1>)) then exit;
        // do stuff
        UpgTag.EndUpgrade();
    end;

    local procedure RunUpgradeProcedureTwo()
    begin
        if (not UpgTag.BeginUpgrade(<workitem-id-2>)) then exit;
        // do stuff
        UpgTag.EndUpgrade();
    end;

    local procedure RunUpgradeProcedureThree()
    begin
        if (not UpgTag.BeginUpgrade(<workitem-id-3>)) then exit;
        // do stuff
        UpgTag.EndUpgrade();
    end;

}