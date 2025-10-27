codeunit 9999990 "EOSxxx Upgrade" // replace xxx with your 3 digit extension code and assign a correct ID
{

    SubType = Upgrade;
    Access = Internal; // no need for the outside world to access this codeunit

    var
        UpgTag: Codeunit "EOS004 Upgrade Tags"; // this Codeunit is in "EOS Administration Library"


    /// <summary>
    /// This will intialize your codeunit and set globals.
    /// </summary>
    local procedure InitCodeunit(perDatabase: Boolean)
    var
        ModInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModInfo);
        UpgTag.SetApp(ModInfo, perDatabase);
    end;

    #region percompany-things

    // Helper function that returns all tags.
    internal procedure GetCompanyUpgradeTags() result: List of [Code[250]]
    begin
        InitCodeunit(false);
        result.Add(UpgTag.FormatTag(<workitem1>));
        result.Add(UpgTag.FormatTag(<workitem2>));
    end;

    // Event that makes sure that all upgrade tags for the currently installed version are also created when new companies are created.
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    // Makes use of 'GetCompanyUpgradeTags' to get all tags to create.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', true, false)]
    local procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.AddRange(GetCompanyUpgradeTags());
    end;

    // The obvious trigger that actually executes your upgrade.
    trigger OnUpgradePerCompany()
    begin
        InitCodeunit(false);

        // replace this below with your actual upgrade methods
        RunUpgradeProcedure_One();
        RunUpgradeProcedure_Two();
    end;

    #endregion

    #region perdatabase-things

    // Helper function that returns all tags.
    internal procedure GetDatabaseUpgradeTags() result: List of [Code[250]]
    begin
        InitCodeunit(true);
        result.Add(UpgTag.FormatTag(<workitem3>));
    end;

    // Event that makes sure that all upgrade tags for the currently installed version are also created.
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    // Makes use of 'GetDatabaseUpgradeTags' to get all tags to create.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", OnGetPerCompanyUpgradeTags, '', true, false)]
    local procedure OnGetPerDatabaseUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.AddRange(GetCompanyUpgradeTags());
    end;

    // The obvious trigger that actually executes your upgrade.
    trigger OnUpgradePerDatabase()
    begin
        InitCodeunit(false);

        // replace this below with your actual upgrade methods
        RunUpgradeProcedure_Three();
    end;

    #endregion


    // Everything below here is your job.
    // Write a method for each upgrade task. Use the pattern like below.
    // Make sure you have properly called 'InitCodeunit' (with isDatabase parameter correctly set) before any of this is run.
    // But if you followed this boilerplate, it is so.

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