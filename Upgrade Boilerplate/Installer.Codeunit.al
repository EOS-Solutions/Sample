codeunit 9999991 "EOSxxx Installer" // replace xxx with your 3 digit extension code and assign a correct ID
{

    SubType = Install;
    Access = Internal; // no need for the outside world to access this codeunit

    var
        Upgrade: Codeunit "EOSxxx Upgrade"; // this is your upgrade codeunit
        UpgTags: Codeunit "EOS004 Upgrade Tags";

    // Entry point that makes sure that all past upgrade tags for the app being installed are created.
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    // Do per-database things here.
    trigger OnInstallAppPerDatabase()
    begin
        UpgTags.CreateTags(Upgrade.GetDatabaseUpgradeTags(), true);
    end;

    // Entry point that makes sure that all past upgrade tags for the app being installed are created.
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    // Do per-company things here.
    trigger OnInstallAppPerCompany()
    begin
        UpgTags.CreateTags(Upgrade.GetCompanyUpgradeTags(), false);
    end;

}