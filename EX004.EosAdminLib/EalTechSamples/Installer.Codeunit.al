codeunit 50102 "Installer"
{

    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        CreateFeatures();
    end;

    internal procedure CreateFeatures()
    var
        fm: Record "EOS004 Feature Management";
        fm2: Record "EOS004 Feature Management";
    begin
        fm.Id := '43933a15-44a9-4a1f-ae86-90f88f2130f2';
        if not fm2.Get(fm.Id) then begin
            fm.Description := 'ChuckNorris API v2';
            fm.Insert();
        end;
    end;

}