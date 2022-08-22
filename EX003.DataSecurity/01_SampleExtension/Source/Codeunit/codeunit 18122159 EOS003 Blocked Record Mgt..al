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
        Skip: Boolean;
    begin
        OnBeforeCheckEditCustomerBankAccount(Rec, Skip);
        if Skip then
            exit;
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckEditable(RecRef, Database::"Customer Bank Account");
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
        Skip: Boolean;
    begin
        OnBeforeCheckDeleteCustomerBankAccount(Rec, Skip);
        if Skip then
            exit;
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckDeletable(RecRef, Database::"Customer Bank Account");
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
        Skip: Boolean;
    begin
        OnBeforeCheckEditVendorBankAccount(Rec, Skip);
        if Skip then
            exit;
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckEditable(RecRef, Database::"Vendor Bank Account");
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
        Skip: Boolean;
    begin
        OnBeforeCheckDeleteVendorBankAccount(Rec, Skip);
        if Skip then
            exit;
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckDeletable(RecRef, Database::"Vendor Bank Account");
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
        Skip: Boolean;
    begin
        OnBeforeCheckEditShiptoAddress(Rec, Skip);
        if Skip then
            exit;
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckEditable(RecRef, Database::"Ship-to Address");
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
        Skip: Boolean;
    begin
        OnBeforeCheckDeleteShiptoAddress(Rec, Skip);
        if Skip then
            exit;
        Customer.Get(Rec."Customer No.");
        RecRef.Get(Customer.RecordId);
        CheckDeletable(RecRef, Database::"Ship-to Address");
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
        Skip: Boolean;
    begin
        OnBeforeCheckEditOrderAddress(Rec, Skip);
        if Skip then
            exit;
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckEditable(RecRef, Database::"Order Address");
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
        Skip: Boolean;
    begin
        OnBeforeCheckDeleteOrderAddress(Rec, Skip);
        if Skip then
            exit;
        Vendor.Get(Rec."Vendor No.");
        RecRef.Get(Vendor.RecordId);
        CheckDeletable(RecRef, Database::"Order Address");
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
        Skip: Boolean;
    begin
        OnBeforeCheckEditCommentLine(Rec, Skip);
        if Skip then
            exit;
        case Rec."Table Name" of
            Rec."Table Name"::Customer:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckEditable(RecRef, Database::"Comment Line");
                end;
            Rec."Table Name"::Vendor:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckEditable(RecRef, Database::"Comment Line");
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
        Skip: Boolean;
    begin
        OnBeforeCheckDeleteCommentLine(Rec, Skip);
        if Skip then
            exit;
        case Rec."Table Name" of
            Rec."Table Name"::Customer:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckDeletable(RecRef, Database::"Comment Line");
                end;
            Rec."Table Name"::Vendor:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckDeletable(RecRef, Database::"Comment Line");
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
        Skip: Boolean;
    begin
        OnBeforeCheckEditDefaultDimension(Rec, Skip);
        if Skip then
            exit;
        case Rec."Table ID" of
            18:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckEditable(RecRef, Database::"Default Dimension");
                end;
            23:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckEditable(RecRef, Database::"Default Dimension");
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
        Skip: Boolean;
    begin
        OnBeforeCheckDeleteDefaultDimension(Rec, Skip);
        if Skip then
            exit;
        case Rec."Table ID" of
            18:
                begin
                    Customer.Get(Rec."No.");
                    RecRef.Get(Customer.RecordId);
                    CheckDeletable(RecRef, Database::"Default Dimension");
                end;
            23:
                begin
                    Vendor.Get(Rec."No.");
                    RecRef.Get(Vendor.RecordId);
                    CheckDeletable(RecRef, Database::"Default Dimension");
                end;
        end;
    end;


    #endregion
    [Obsolete('Replaced by procedure CheckEditable(RecRef: RecordRef; TableIDtoCheck: Integer)"')]
    procedure CheckEditable(RecRef: RecordRef)
    var
        DataSecurityTableStatus: Record "EOS DS Table Status";
        DataSecurityManagement: Codeunit "EOS DS Management";
    begin
        CheckEditable(RecRef, 0);
    end;

    [Obsolete('Replaced by procedure CheckDeletable(RecRef: RecordRef; TableIDtoCheck: Integer)"')]
    procedure CheckDeletable(RecRef: RecordRef)
    var
        DataSecurityTableStatus: Record "EOS DS Table Status";
        DataSecurityManagement: Codeunit "EOS DS Management";
    begin
        CheckDeletable(RecRef, 0);
    end;

    procedure CheckEditable(RecRef: RecordRef; TableIDtoCheck: Integer)
    var
        DataSecurityTableStatus: Record "EOS DS Table Status";
        ChildTableSetup: Record "EOS003 Child Table Setup";
        DataSecurityManagement: Codeunit "EOS DS Management";
    begin
        if DataSecurityTableStatus.Get(RecRef.Number(), DataSecurityManagement.GetRecordPKOptionValue(RecRef), DataSecurityManagement.GetRecordStatus(RecRef)) then begin
            if ChildTableSetup.Get(DataSecurityTableStatus."Table ID", DataSecurityTableStatus."Table Option Type", DataSecurityTableStatus."Status Code", TableIDtoCheck) then begin
                if not ChildTableSetup."Disable Edit Control" then
                    DataSecurityTableStatus.Testfield("Changes disabled", false);
            end else
                DataSecurityTableStatus.Testfield("Changes disabled", false);
        end;
    end;

    procedure CheckDeletable(RecRef: RecordRef; TableIDtoCheck: Integer)
    var
        DataSecurityTableStatus: Record "EOS DS Table Status";
        ChildTableSetup: Record "EOS003 Child Table Setup";
        DataSecurityManagement: Codeunit "EOS DS Management";
    begin
        if DataSecurityTableStatus.Get(RecRef.Number(), DataSecurityManagement.GetRecordPKOptionValue(RecRef), DataSecurityManagement.GetRecordStatus(RecRef)) then begin
            if ChildTableSetup.Get(DataSecurityTableStatus."Table ID", DataSecurityTableStatus."Table Option Type", DataSecurityTableStatus."Status Code", TableIDtoCheck) then begin
                if not ChildTableSetup."Disable Delete Control" then
                    DataSecurityTableStatus.Testfield("Deletion disabled", false);
            end else
                DataSecurityTableStatus.Testfield("Deletion disabled", false);
        end;
    end;

    /// <summary>
    /// Raised before check editability of Customer Bank Account record
    /// </summary>
    /// <param name="Rec">Current Customer Bank Account record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEditCustomerBankAccount(Rec: Record "Customer Bank Account"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check deletable of Customer Bank Account record
    /// </summary>
    /// <param name="Rec">Current Customer Bank Account record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDeleteCustomerBankAccount(Rec: Record "Customer Bank Account"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check editability of Vendor Bank Account record
    /// </summary>
    /// <param name="Rec">Current Vendor Bank Account record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEditVendorBankAccount(Rec: Record "Vendor Bank Account"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check deletable of Vendor Bank Account record
    /// </summary>
    /// <param name="Rec">Current Vendor Bank Account record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDeleteVendorBankAccount(Rec: Record "Vendor Bank Account"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check editability of Ship-to Address record
    /// </summary>
    /// <param name="Rec">Current Ship-to Address record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEditShiptoAddress(Rec: Record "Ship-to Address"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check deletable of Ship-to Address record
    /// </summary>
    /// <param name="Rec">Current Ship-to Address record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDeleteShiptoAddress(Rec: Record "Ship-to Address"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check editability of Order Address record
    /// </summary>
    /// <param name="Rec">Current Order Address record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEditOrderAddress(Rec: Record "Order Address"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check deletable of Order Address record
    /// </summary>
    /// <param name="Rec">Current Order Address record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDeleteOrderAddress(Rec: Record "Order Address"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check editability of Comment Line record
    /// </summary>
    /// <param name="Rec">Current Comment Line record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEditCommentLine(Rec: Record "Comment Line"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check deletable of Comment Line record
    /// </summary>
    /// <param name="Rec">Current Comment Line record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDeleteCommentLine(Rec: Record "Comment Line"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check editability of Default Dimension record
    /// </summary>
    /// <param name="Rec">Current Default Dimension record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEditDefaultDimension(Rec: Record "Default Dimension"; var Skip: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before check deletable of Default Dimension record
    /// </summary>
    /// <param name="Rec">Current Default Dimension record</param>
    /// <param name="Skip">If it is set to true then skip the controls</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDeleteDefaultDimension(Rec: Record "Default Dimension"; var Skip: Boolean)
    begin
    end;
}
