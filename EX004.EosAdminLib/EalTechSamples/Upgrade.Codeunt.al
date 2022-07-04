codeunit 50103 Upgrade
{

    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        inst: Codeunit Installer;
    begin
        inst.CreateFeatures();
    end;

}