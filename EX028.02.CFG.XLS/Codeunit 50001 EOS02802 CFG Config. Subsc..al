Codeunit 50001 "EOS02802 CFG Config. Subsc."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS028 CFG For Other Apps", 'EosEX02802ProductCfgForExcel', '', false, false)]
    procedure C18091276_EosEX02802ProductCfgForExcel(var IsHandled: Boolean; var EosEX02802ProductCfgForExcelGuid: Guid)
    begin
        IsHandled := true;
        EosEX02802ProductCfgForExcelGuid := 'b0ad1e80-f1e0-4089-b097-af1d7d6bce63';
    end;
}
