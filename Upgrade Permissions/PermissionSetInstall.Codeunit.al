codeunit 18004157 "EOSxxx Permissions Install"
{
    Access = Internal; // no need for the outside world to access this codeunit
    Subtype = Install;

    // Entry point that makes sure that all past upgrade tags for the app being installed are created.
    // If this is not done, the first time a new version of this app is installed in the future (and therefore upgrades start running),
    // all upgrades will run, even if they (probabily) should not.
    trigger OnInstallAppPerDatabase()
    var
        EOSPermissionSetUpgrade: Codeunit "EOSxxx Permissions Upgrade";
    begin
        EOSPermissionSetUpgrade.CreateUpgradeTags();
    end;
}