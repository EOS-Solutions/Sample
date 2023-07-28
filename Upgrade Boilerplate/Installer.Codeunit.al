codeunit 9999991 "EOSxxx Installer" // replace xxx with your 3 digit extension code and assign a correct ID
{

    SubType = Install;
    Access = Internal; // no need for the outside world to access this codeunit

    // Entry point that makes sure that all past upgrade tags for the app being installed are created.
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    trigger OnInstallAppPerCompany()
    var
        Upgrade: Codeunit "EOSxxx Upgrade";
    begin
        Upgrade.CreateUpgradeTags();
    end;

}