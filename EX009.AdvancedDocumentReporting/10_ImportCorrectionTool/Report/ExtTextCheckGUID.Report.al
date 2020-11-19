report 50079 "EOSTOOL ExtText_CheckGUID"
{
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'GUID Corrector [TOOLS]';

    dataset
    {
        dataitem("Customer"; Customer)
        {
            trigger OnPreDataItem()
            var
                Conf1Lbl: Label 'Do you want to correct? - Counter: %1';
                NullGuid: Guid;
            begin
                if SourceType = SourceType::Vendor then CurrReport.Skip();
                Customer.SetFilter(Id, '%1', NullGuid);
                if not Confirm(Conf1Lbl, true, format(Customer.Count)) then
                    CurrReport.Break();
                Clear(RecCount);
                RecCount := Customer.COUNT;
                RecNo := 0;
                Window.OPEN(DialogTxt);
            end;

            trigger OnAfterGetRecord()
            begin
                if SourceType = SourceType::Vendor then CurrReport.Skip();
                RecNo += 1;
                Window.UPDATE(1, Customer."No.");
                Window.UPDATE(2, ROUND(RecNo / RecCount * 10000, 1));
                Customer_GUIDCorrection(Customer);
            end;

            trigger OnPostDataItem()
            begin
                if SourceType = SourceType::Vendor then CurrReport.Skip();
                Window.CLOSE();
            end;
        }
        dataitem(Vendor; Vendor)
        {
            trigger OnPreDataItem()
            var
                Conf1Lbl: Label 'Do you want to correct? - Counter: %1';
                NullGuid: Guid;
            begin
                if SourceType = SourceType::Customer then CurrReport.Skip();
                Vendor.SetFilter(id, '%1', NullGuid);
                if not Confirm(Conf1Lbl, true, Format(Vendor.Count)) then
                    CurrReport.Break();
                RecCount := Vendor.COUNT;
                RecNo := 0;
                Window.OPEN(DialogTxt);
            end;

            trigger OnAfterGetRecord()
            begin
                if SourceType = SourceType::Customer then CurrReport.Skip();
                RecNo += 1;
                Window.UPDATE(1, Vendor."No.");
                Window.UPDATE(2, ROUND(RecNo / RecCount * 10000, 1));
                Vendor_GUIDCorrection(Vendor);
            end;

            trigger OnPostDataItem()
            begin
                if SourceType = SourceType::Customer then CurrReport.Skip();
                Window.CLOSE();
            end;
        }
    }
    requestpage
    {
        ShowFilter = false;
        layout
        {
            area(Content)
            {
                field(SourceType_; SourceType)
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    ToolTip = 'Table Name';
                    OptionCaption = 'Customer,Vendor';
                }
            }
        }
    }
    local procedure Customer_GUIDCorrection(ParCustomer: Record Customer)
    var
        NullGuid: Guid;
    begin
        ParCustomer.Id := CreateGuid();
        if ParCustomer.SystemId = NullGuid then
            ParCustomer.SystemId := CreateGuid();
        ParCustomer.Modify();
    end;

    local procedure Vendor_GUIDCorrection(ParVendor: Record Vendor)
    var
        NullGuid: Guid;
    begin
        ParVendor.Id := CreateGuid();
        if ParVendor.SystemId = NullGuid then
            ParVendor.SystemId := CreateGuid();
        ParVendor.Modify();
    end;

    var
        SourceType: Option Customer,Vendor;
        Window: Dialog;
        RecNo: Integer;
        RecCount: Integer;
        DialogTxt: label 'ENU=#1########//@2@@@@@@@';
}
