codeunit 50003 "EOS MES CodeunitInstall"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        NavApp.GetCurrentModuleInfo(mi);
        UpgradeTag.SetApp(mi);
        Install7475();
    end;

    local procedure Install7475()
    var
        EOS070MESSetup: Record "EOS 070 MES Setup";
    begin
        if (UpgradeTag.HasUpgradeTag(7475)) then
            exit;

        if EOS070MESSetup.Get() then
        begin
            EOS070MESSetup."Barcode Generation Method" := Enum::"EOS 070 MES Barcode Method"::OnPrem;
            EOS070MESSetup.Modify();
        end;  

        UpgradeTag.SetUpgradeTag(7475);
    end;

    var
        UpgradeTag: Codeunit "EOS004 Upgrade Tags";
        mi: ModuleInfo;
        
}