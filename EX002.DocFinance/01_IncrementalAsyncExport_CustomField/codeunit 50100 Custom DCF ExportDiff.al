codeunit 50100 "Custom DCF ExportDiff"
{
    trigger OnRun()
    begin

    end;

    // Custom implementation of event subscribers for Diff Mode for the following case:
    // If there is a custom tool that updates the Customer table, the field "SystemModifiedAt" is always updated even if no relevant data for DCF Export is changed.
    // This means that the standard Diff Mode will always export all customers because the filter on "SystemModifiedAt" will always include all records.
    // To avoid this, we add a custom boolean field "Custom DCF ExportDiff" to the Customer table extension that is set to true by the custom tool when relevant data for DCF Export is changed.
    // The event subscribers below set the filter on this field to true when exporting in Diff Mode and reset it to false after export.
    // you need to add the logic to set the field to true in your custom tool when relevant data for DCF Export is changed.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DCF Export MasterData", OnAfterSetFilterCustomerForDiffMode, '', false, false)]
    local procedure "EOS DCF Export MasterData_OnAfterSetFilterCustomerForDiffMode"(var Customer: Record Customer; GlobalLastExportDateTime: DateTime; var Handled: Boolean)
    begin
        Handled := true;
        Customer.SetRange("Custom DCF ExportDiff", true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DCF Export MasterData", OnAfterExportCustomers, '', false, false)]
    local procedure "EOS DCF ExportMasterData_OnAfterExportCustomers"(var Customer: Record Customer; var DocFMasterData: Record "EOS DCF MasterData")
    begin
        Customer.ModifyAll("Custom DCF ExportDiff", false);
    end;


    // Other event subscribers for Diff Mode that do not need custom implementation

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DCF Export MasterData", OnAfterSetFilterGLAccountForDiffMode, '', false, false)]
    local procedure "EOS DCF Export MasterData_OnAfterSetFilterGLAccountForDiffMode"(var GLAccount: Record "G/L Account"; GlobalLastExportDateTime: DateTime; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DCF Export MasterData", OnAfterSetFilterDocFAccountDecodeForDiffMode, '', false, false)]
    local procedure "EOS DCF ExportMasterData_OnAfterSetFilterDocFAccountDecodeForDiffMode"(var DocFinanceAccountDecode: Record "EOS DCF Account Decode"; GlobalLastExportDateTime: DateTime; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DCF Export MasterData", OnAfterSetFilterBankAccountForDiffMode, '', false, false)]
    local procedure "EOS DCF ExportMasterData_OnAfterSetFilterBankAccountForDiffMode"(var BankAccount: Record "Bank Account"; GlobalLastExportDateTime: DateTime; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DCF Export MasterData", OnAfterSetFilterVendorForDiffMode, '', false, false)]
    local procedure "EOS DCF ExportMasterData_OnAfterSetFilterVendorForDiffMode"(var Vendor: Record Vendor; GlobalLastExportDateTime: DateTime; var Handled: Boolean)
    begin
    end;

}