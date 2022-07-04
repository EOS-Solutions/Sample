codeunit 18122159 "EOS003 Blocked Record Mgt."
{
    #region Bank

    // Customer Bank Account (287)
    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeModifyEvent', '', true, true)]
    local procedure "Customer Bank Account_OnBeforeModifyEvent"
    (
        var Rec: Record "Customer Bank Account";
        var xRec: Record "Customer Bank Account";
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Customer: Record Customer;
    begin
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckEditable(RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure "Customer Bank Account_OnBeforeDeleteEvent"
    (
        var Rec: Record "Customer Bank Account";
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Customer: Record Customer;
    begin
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckDeletable(RecRef);
    end;

    // Vendor Bank Account (288)
    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeModifyEvent', '', true, true)]
    local procedure "Vendor Bank Account_OnBeforeModifyEvent"
    (
        var Rec: Record "Vendor Bank Account";
        var xRec: Record "Vendor Bank Account";
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
    begin
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckEditable(RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure "Vendor Bank Account_OnBeforeDeleteEvent"
    (
       var Rec: Record "Vendor Bank Account";
       RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
    begin
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckDeletable(RecRef);
    end;

    #endregion

    #region Addresses

    //Ship-to Address (222)
    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnBeforeModifyEvent', '', true, true)]
    local procedure "Ship-to Address_OnBeforeModifyEvent"
    (
        var Rec: Record "Ship-to Address";
        var xRec: Record "Ship-to Address";
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Customer: Record Customer;
    begin
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckEditable(RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Ship-to Address", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure "Ship-to Address_OnBeforeDeleteEvent"
    (
        var Rec: Record "Ship-to Address";
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Customer: Record Customer;
    begin
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckDeletable(RecRef);
    end;

    //Order Address (224)
    [EventSubscriber(ObjectType::Table, Database::"Order Address", 'OnBeforeModifyEvent', '', true, true)]
    local procedure "Order Address_OnBeforeModifyEvent"
        (
            var Rec: Record "Order Address";
            var xRec: Record "Order Address";
            RunTrigger: Boolean
        )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
    begin
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckEditable(RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Order Address", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure "Order Address_OnBeforeDeleteEvent"
    (
        var Rec: Record "Order Address";
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
    begin
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckDeletable(RecRef);
    end;

    #endregion

    #region Comments

    //Comment Line (97)
    [EventSubscriber(ObjectType::Table, Database::"Comment Line", 'OnBeforeModifyEvent', '', true, true)]
    local procedure "Comment Line_OnBeforeModifyEvent"
            (
                var Rec: Record "Comment Line";
                var xRec: Record "Comment Line";
                RunTrigger: Boolean
            )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        case Rec."Table Name" of
            Rec."Table Name"::Customer:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckEditable(RecRef);
                end;
            Rec."Table Name"::Vendor:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckEditable(RecRef);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Comment Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure "Comment Line_OnBeforeDeleteEvent"
        (
            var Rec: Record "Comment Line";
            RunTrigger: Boolean
        )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        case Rec."Table Name" of
            Rec."Table Name"::Customer:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckDeletable(RecRef);
                end;
            Rec."Table Name"::Vendor:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckDeletable(RecRef);
                end;
        end;
    end;

    #endregion

    #region Dimensions

    // Default Dimension (352)
    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeModifyEvent', '', true, true)]
    local procedure "Default Dimension_OnBeforeModifyEvent"
                (
                    var Rec: Record "Default Dimension";
                    var xRec: Record "Default Dimension";
                    RunTrigger: Boolean
                )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        case Rec."Table ID" of
            18:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckEditable(RecRef);
                end;
            23:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckEditable(RecRef);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure "Default Dimension_OnBeforeDeleteEvent"
                (
                    var Rec: Record "Default Dimension";
                    RunTrigger: Boolean
                )
    var
        RecRef: RecordRef;
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        case Rec."Table ID" of
            18:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckDeletable(RecRef);
                end;
            23:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckDeletable(RecRef);
                end;
        end;
    end;


    #endregion


    procedure CheckEditable(RecRef: RecordRef)
    var
        DataSecurityTableStatus: Record "EOS DS Table Status";
        DataSecurityManagement: Codeunit "EOS DS Management";
    begin
        if DataSecurityTableStatus.Get(RecRef.Number(), DataSecurityManagement.GetRecordPKOptionValue(RecRef), DataSecurityManagement.GetRecordStatus(RecRef)) then
            DataSecurityTableStatus.Testfield("Changes disabled", false);
    end;

    procedure CheckDeletable(RecRef: RecordRef)
    var
        DataSecurityTableStatus: Record "EOS DS Table Status";
        DataSecurityManagement: Codeunit "EOS DS Management";
    begin
        if DataSecurityTableStatus.Get(RecRef.Number(), DataSecurityManagement.GetRecordPKOptionValue(RecRef), DataSecurityManagement.GetRecordStatus(RecRef)) then
            DataSecurityTableStatus.Testfield("Deletion disabled", false);
    end;
}
