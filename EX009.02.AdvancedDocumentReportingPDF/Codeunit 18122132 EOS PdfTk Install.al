codeunit 50002 "EOS PdfTk Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        EOSReportSetup: Record "EOS Report Setup";
        AdvancedReportingMngt: Codeunit "EOS Advanced Reporting Mngt";
    begin
        EOSReportSetup.Get(AdvancedReportingMngt.CreateSystemReportSetup());
        EOSReportSetup.UpdateLayout();
        EOSReportSetup.UpdateProcessors();
    end;
}