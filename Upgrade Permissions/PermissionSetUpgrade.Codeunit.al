codeunit 18004155 "EOSxxx Permissions Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgTag: Codeunit "EOS004 Upgrade Tags";
        ModInfo: ModuleInfo;

    // Event that makes sure that all database upgrade tags for the currently installed version are also created
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', true, false)]
    local procedure OnGetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        InitCodeunit();
        PerDatabaseUpgradeTags.Add(UpgTag.FormatTag(<workitem-id>)); // work item ID for 'UpgradePermissionSets'
    end;

    local procedure InitCodeunit()
    begin
        NavApp.GetCurrentModuleInfo(ModInfo);
        UpgTag.SetApp(ModInfo, true);
    end;

    // This is an utilty function that is used in the installation codeunit.
    internal procedure CreateUpgradeTags()
    begin
        InitCodeunit();
        UpgTag.SetUpgradeTagIfNotExists(<workitem-id>); // work item ID for 'UpgradePermissionSets'
    end;


    trigger OnUpgradePerDatabase()
    begin
        InitCodeunit();
        UpgradePermissionSets();
    end;

    local procedure UpgradePermissionSets()
    begin
        if (not UpgTag.BeginUpgrade(<workitem-id>)) then exit; // work item ID for 'UpgradePermissionSets'
        UpgTag.MigratePermissionSet('OLD XML PERMISSION NAME', 'NEW AL PERMISSION NAME', ModInfo); // EOS Admin Lib procedure to migrate permission sets
        UpgTag.EndUpgrade();
    end;
}