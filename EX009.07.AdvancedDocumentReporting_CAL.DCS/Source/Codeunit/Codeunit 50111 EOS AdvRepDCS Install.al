codeunit 50111 "EOS AdvRepDCS Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(Database::"DCS AL Buffer", false, CompanyName());
    end;
}