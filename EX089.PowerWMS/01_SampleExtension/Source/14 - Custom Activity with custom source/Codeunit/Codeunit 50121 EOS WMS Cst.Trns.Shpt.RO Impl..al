codeunit 50121 "EOS WMS Cst.Trns.Shpt.RO Impl." implements "EOS089 WMS Activity Interface V5", "EOS089 WMS Act. Int. - Alt. Views", "EOS089 WMS Custom Source Interface"
{
    /// <summary>
    /// This codeunit implements the "EOS089 WMS Custom Source Interface" for managing custom activities using actual tables.
    /// This sample is based on standard "Transfer Shipment" implementation.
    /// Custom activities based on actual tables can be set as "Read Only".
    /// DIFFERENCES FROM STANDARD IMPLEMENTATION:
    /// - The activity type is a custom enum (as a custom activity)
    /// - In InitActivity() procedure you must set custom type (mandatory for custom activities) and the Read-Only property if necessary
    /// The interface must implement the "EOS089 WMS Custom Source Interface" interface
    /// Following methods must be used to manage data:
    /// - AllowCustomSource - returns true
    /// - GetSourceTableInfo - edit with right info
    /// - OpenSourceHeaderRecordRef - no needs to change
    /// - FillHeaderData - change field mapping according to your source table
    /// - OpenSourceLineRecordRef - change filter logic on source table
    /// - FillLineData - change field mapping according to your source table
    /// </summary>


    #region InterfaceSettings
    // Change Source Records and Activity Information according to Interface Type
    var
        TransferHeader_Internal: Record "Transfer Header";
        TransferLine_Internal: Record "Transfer Line";
        ReturnValues: JsonObject;

    procedure IsActivity(): Boolean
    begin
        exit(true);
    end;

    procedure IsAllowed(): Boolean
    begin
        exit(true);
    end;

    procedure GetNotAllowedReason(): Text
    var
        EOS089WMSManagement: Codeunit "EOS089 WMS Management";
    begin
        if not EOS089WMSManagement.IsPowerWMSAllowed(false) then
            exit(EOS089WMSManagement.GetMissingSubscriptionErrorText());
    end;

    procedure ActivityVisibility(): Enum "EOS089 WMS Activity Visibility"
    begin
        exit(Enum::"EOS089 WMS Activity Visibility"::PowerWMS);
    end;

    procedure ActivityCategory(): Enum "EOS089 WMS Activity Category";
    begin
        exit(Enum::"EOS089 WMS Activity Category"::"Shipment");
    end;

    procedure ActivityGroup(): Enum "EOS089 WMS Activity Group";
    begin
        exit(Enum::"EOS089 WMS Activity Group"::"Shipment");
    end;

    local procedure ActivityType(): Enum "EOS089 WMS Activity Type"
    begin
        exit(Enum::"EOS089 WMS Activity Type"::EOSTransferShipmentReadOnly);
    end;

    local procedure SourceTable1(): Integer;
    begin
        exit(Database::"Transfer Header");
    end;

    local procedure SourceTable2(): Integer;
    begin
        exit(Database::"Transfer Line");
    end;

    local procedure SourceTableDescription(): Text
    var
        SourceDescLbl: Label 'Transfer Order';
    begin
        exit(SourceDescLbl)
    end;

    local procedure PostedSourceTableDescription(): Text
    var
        PostedSourceDescLbl: Label 'Transfer Shipment';
    begin
        exit(PostedSourceDescLbl)
    end;

    local procedure GetPostedSourceMessage(PostedSourceNo: Text)
    var
        EOS089WMSReturnValuesMgmt: Codeunit "EOS089 WMS Return Values Mgmt.";
        SourcePostedLbl: Label '%1 No. %2 posted successfully', Comment = '%1: Posted Source Type, %2: Posted Source No.';
    begin
        Clear(EOS089WMSReturnValuesMgmt);
        EOS089WMSReturnValuesMgmt.PrepareReturnValues();
        EOS089WMSReturnValuesMgmt.SetMessage(StrSubstNo(SourcePostedLbl, PostedSourceTableDescription(), PostedSourceNo));
        EOS089WMSReturnValuesMgmt.SetResult(Enum::"EOS089 WMS Activity Result"::Completed);
        EOS089WMSReturnValuesMgmt.SetPostedDocumentNo(CopyStr(PostedSourceNo, 1, 20));
        ReturnValues := EOS089WMSReturnValuesMgmt.GetReturnValues();
    end;

    local procedure GetResetSourceMessage(SourceNo: Text)
    var
        EOS089WMSReturnValuesMgmt: Codeunit "EOS089 WMS Return Values Mgmt.";
        SourceResetLbl: Label '%1 No. %2 reset successfully', Comment = '%1: Source Type, %2: Source No.';
    begin
        Clear(EOS089WMSReturnValuesMgmt);
        EOS089WMSReturnValuesMgmt.PrepareReturnValues();
        EOS089WMSReturnValuesMgmt.SetMessage(StrSubstNo(SourceResetLbl, SourceTableDescription(), SourceNo));
        EOS089WMSReturnValuesMgmt.SetResult(Enum::"EOS089 WMS Activity Result"::Completed);
        ReturnValues := EOS089WMSReturnValuesMgmt.GetReturnValues();
    end;

    local procedure FieldListEnabled1(): Boolean
    begin
        exit(true);
    end;

    local procedure FieldListEnabled2(): Boolean
    begin
        exit(true);
    end;

    local procedure FieldDetailsEnabled1(): Boolean
    begin
        exit(true);
    end;

    local procedure FieldDetailsEnabled2(): Boolean
    begin
        exit(true);
    end;
    #endregion

    procedure InitActivity(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        EOS089WMSUserActivityMgmt: Codeunit "EOS089 WMS User Activity Mgmt.";
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        EOS089WMSUserActivity.Category := ActivityCategory();
        EOS089WMSUserActivity.Group := ActivityGroup();
        EOS089WMSUserActivity."Custom Type" := Enum::"EOS089 WMS Act. Custom Type"::Document;
        //EOS089WMSUserActivity."Read-Only" := true;

        EOS089WMSUserActivity."Allow All Inv. Batches" := false;
        EOS089WMSUserActivity."Allow All Jnl. Batches" := false;
        EOS089WMSUserActivity."Allow All Reclass. Batches" := false;

        LocationFilter := EOS089WMSUserActivityMgmt.BuildLocationFilterForActivity(EOS089WMSUserActivity);

        EOS089WMSUserActivity."Enable List Fields 1" := FieldListEnabled1();
        EOS089WMSUserActivity."Enable List Fields 2" := FieldListEnabled2();
        EOS089WMSUserActivity."Enable Detail Fields 1" := FieldDetailsEnabled1();
        EOS089WMSUserActivity."Enable Detail Fields 2" := FieldDetailsEnabled2();

        // View 1
        EOS089WMSUserActivity."Table Id 1" := SourceTable1();
        EOS089WMSUserActivity."Key No. 1" := 1;
        EOS089WMSUserActivity."Key Sort 1" := EOS089WMSUserActivity."Key Sort 1"::Asc;

        TransferHeader_Internal.Reset();

        SetDefaultFilters1(EOS089WMSUserActivity, LocationFilter);

        PageFilterBuilder.AddTable(TransferHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(TransferHeader_Internal.TableCaption(), TransferHeader_Internal.GetView());
        CurrentView := PageFilterBuilder.GetView(TransferHeader_Internal.TableCaption(), false);
        EOS089WMSUserActivity.SetView1(CurrentView);

        EOS089WMSUserActivity.SetLocationFilter1(LocationFilter);

        // View 2
        EOS089WMSUserActivity."Table Id 2" := SourceTable2();
        EOS089WMSUserActivity."Key No. 2" := 1;
        EOS089WMSUserActivity."Key Sort 2" := EOS089WMSUserActivity."Key Sort 2"::Asc;

        TransferLine_Internal.Reset();

        SetDefaultFilters2(EOS089WMSUserActivity, LocationFilter);

        PageFilterBuilder.AddTable(TransferLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(TransferLine_Internal.TableCaption(), TransferLine_Internal.GetView());
        CurrentView := PageFilterBuilder.GetView(TransferLine_Internal.TableCaption(), false);
        EOS089WMSUserActivity.SetView2(CurrentView);

        EOS089WMSUserActivity.SetLocationFilter2(LocationFilter);

        // Source Scans Key
        EOS089WMSUserActivity."Source Scans Key No." := 6;
        EOS089WMSUserActivity."Source Scans Key Sort" := EOS089WMSUserActivity."Source Scans Key Sort"::Desc;
    end;

    procedure EnableActivity(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    begin
        if not IsAllowed() then
            Error(GetNotAllowedReason());
    end;

    procedure ManageUserActivityCardOptions(var Options: JsonObject)
    begin
        Options.Add('showExecutionGroup', true);
        Options.Add('showExecutionMode', true);
        Options.Add('showDefaultAction', true);
        Options.Add('editExecutionMode', true);
        Options.Add('editDefaultAction', true);

        Options.Add('showAllowAllLocations', true);
        Options.Add('showUserIdFilter', true);
        Options.Add('showAllowBlankUserId', true);
        Options.Add('showAllowPosting', true);
        Options.Add('showKey1', true);
        Options.Add('showKeyOrder1', true);
        Options.Add('showKey2', true);
        Options.Add('showKeyOrder2', true);
        Options.Add('showAllowSourceReset', true);
        Options.Add('showAllowAutoTrack', true);
        Options.Add('showAllowScanEdit', true);
        Options.Add('showScanMode', true);
        Options.Add('showFocusOnQuantity', true);
        Options.Add('showStartWithScanAllLines', true);
        Options.Add('showScannerSetup', true);
        Options.Add('showQuantityManagement', true);
        Options.Add('showBlockQuantityEdit', true);
        Options.Add('showSourceScansKey', true);

        Options.Add('editAllowAllLocations', true);
        Options.Add('editUserIdFilter', true);
        Options.Add('editAllowBlankUserId', true);
        Options.Add('editAllowPosting', true);
        Options.Add('editKey1', true);
        Options.Add('editKeyOrder1', true);
        Options.Add('editKey2', true);
        Options.Add('editKeyOrder2', true);
        Options.Add('editAllowSourceReset', true);
        Options.Add('editAllowAutoTrack', true);
        Options.Add('editAllowScanEdit', true);
        Options.Add('editScanMode', true);
        Options.Add('editFocusOnQuantity', true);
        Options.Add('editStartWithScanAllLines', true);
        Options.Add('editScannerSetup', true);
        Options.Add('editQuantityManagement', true);
        Options.Add('editBlockQuantityEdit', true);
        Options.Add('editSourceScansKey', true);
    end;

    procedure GetActivityView1(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; HumanReadable: Boolean): Text
    var
        PageFilterBuilder: FilterPageBuilder;
        ActivityView: Text;
    begin
        PageFilterBuilder.AddTable(TransferHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(TransferHeader_Internal.TableCaption(), EOS089WMSUserActivity.GetView1(true));
        ActivityView := PageFilterBuilder.GetView(TransferHeader_Internal.TableCaption(), HumanReadable);
        exit(ActivityView);
    end;

    procedure SetActivityView1(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        PageFilterBuilder: FilterPageBuilder;
        CurrentView: Text;
    begin
        PageFilterBuilder.AddTable(TransferHeader_Internal.TableCaption(), SourceTable1());
        CurrentView := EOS089WMSUserActivity.GetView1(true);
        if CurrentView <> '' then
            PageFilterBuilder.SetView(TransferHeader_Internal.TableCaption(), CurrentView);

        if PageFilterBuilder.RunModal() then begin
            CurrentView := PageFilterBuilder.GetView(TransferHeader_Internal.TableCaption(), false);
            EOS089WMSUserActivity.SetView1(CurrentView);
            UpdateActivityView1(EOS089WMSUserActivity);
            EOS089WMSUserActivity.Modify(true);
        end;
    end;

    procedure UpdateActivityView1(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        EOS089WMSUserActivityMgmt: Codeunit "EOS089 WMS User Activity Mgmt.";
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        LocationFilter := '';

        // First, apply current view
        TransferHeader_Internal.SetView(EOS089WMSUserActivity.GetView1(true));

        // Then, reset default filters
        LocationFilter := EOS089WMSUserActivityMgmt.BuildLocationFilterForActivity(EOS089WMSUserActivity, TransferHeader_Internal.GetFilter("Location Filter"));

        TransferHeader_Internal.SetRange("Completely Shipped");
        TransferHeader_Internal.SetRange("Location Filter");
        TransferHeader_Internal.SetRange("Assigned User ID");

        SetDefaultFilters1(EOS089WMSUserActivity, LocationFilter);

        // Finally, save updated view
        PageFilterBuilder.AddTable(TransferHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(TransferHeader_Internal.TableCaption(), TransferHeader_Internal.GetView());

        CurrentView := PageFilterBuilder.GetView(TransferHeader_Internal.TableCaption(), false);
        EOS089WMSUserActivity.SetView1(CurrentView);

        EOS089WMSUserActivity.SetLocationFilter1(LocationFilter);
    end;

    procedure SetActivityKey1(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        KeyRec: Record "Key";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        NameValueLookup: Page "Name/Value Lookup";
        KeyNo: Integer;
    begin
        KeyRec.Reset();
        KeyRec.SetLoadFields("No.", "Key");
        KeyRec.SetRange(TableNo, EOS089WMSUserActivity."Table Id 1");

        if KeyRec.FindSet(false) then
            repeat
                NameValueLookup.AddItem(Format(KeyRec."No."), KeyRec."Key");
            until KeyRec.Next() = 0;
        NameValueLookup.LookupMode(true);
        if NameValueLookup.RunModal() = Action::LookupOK then begin
            NameValueLookup.GetRecord(TempNameValueBuffer);
            Evaluate(KeyNo, TempNameValueBuffer.Name);
            EOS089WMSUserActivity.Validate("Key No. 1", KeyNo);
            UpdateActivityView1(EOS089WMSUserActivity);
        end;
    end;

    procedure GetActivityTableCaption1(): Text
    begin
        exit(TransferHeader_Internal.TableCaption());
    end;

    procedure GetActivityView2(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; HumanReadable: Boolean): Text
    var
        PageFilterBuilder: FilterPageBuilder;
        ActivityView: Text;
    begin
        PageFilterBuilder.AddTable(TransferLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(TransferLine_Internal.TableCaption(), EOS089WMSUserActivity.GetView2(true));
        ActivityView := PageFilterBuilder.GetView(TransferLine_Internal.TableCaption(), HumanReadable);
        exit(ActivityView);
    end;

    procedure SetActivityView2(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        PageFilterBuilder: FilterPageBuilder;
        CurrentView: Text;
    begin
        PageFilterBuilder.AddTable(TransferLine_Internal.TableCaption(), SourceTable2());
        CurrentView := EOS089WMSUserActivity.GetView2(true);
        if CurrentView <> '' then
            PageFilterBuilder.SetView(TransferLine_Internal.TableCaption(), CurrentView);

        if PageFilterBuilder.RunModal() then begin
            CurrentView := PageFilterBuilder.GetView(TransferLine_Internal.TableCaption(), false);
            EOS089WMSUserActivity.SetView2(CurrentView);
            UpdateActivityView2(EOS089WMSUserActivity);
            EOS089WMSUserActivity.Modify(true);
        end;
    end;

    procedure UpdateActivityView2(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        EOS089WMSUserActivityMgmt: Codeunit "EOS089 WMS User Activity Mgmt.";
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        LocationFilter := '';

        // First, apply current view
        TransferLine_Internal.SetView(EOS089WMSUserActivity.GetView2(true));

        // Then, reset default filters
        LocationFilter := EOS089WMSUserActivityMgmt.BuildLocationFilterForActivity(EOS089WMSUserActivity, TransferLine_Internal.GetFilter("Transfer-From Code"));

        TransferLine_Internal.SetRange("Completely Shipped");
        TransferLine_Internal.SetRange("Transfer-from Code");
        TransferLine_Internal.SetRange("Derived From Line No.");

        SetDefaultFilters2(EOS089WMSUserActivity, LocationFilter);

        // Finally, save updated view
        PageFilterBuilder.AddTable(TransferLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(TransferLine_Internal.TableCaption(), TransferLine_Internal.GetView());

        CurrentView := PageFilterBuilder.GetView(TransferLine_Internal.TableCaption(), false);
        EOS089WMSUserActivity.SetView2(CurrentView);

        EOS089WMSUserActivity.SetLocationFilter2(LocationFilter);
    end;

    procedure SetActivityKey2(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        KeyRec: Record "Key";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        NameValueLookup: Page "Name/Value Lookup";
        KeyNo: Integer;
    begin
        KeyRec.Reset();
        KeyRec.SetLoadFields("No.", "Key");
        KeyRec.SetRange(TableNo, EOS089WMSUserActivity."Table Id 2");

        if KeyRec.FindSet(false) then
            repeat
                NameValueLookup.AddItem(Format(KeyRec."No."), KeyRec."Key");
            until KeyRec.Next() = 0;
        NameValueLookup.LookupMode(true);
        if NameValueLookup.RunModal() = Action::LookupOK then begin
            NameValueLookup.GetRecord(TempNameValueBuffer);
            Evaluate(KeyNo, TempNameValueBuffer.Name);
            EOS089WMSUserActivity.Validate("Key No. 2", KeyNo);
            UpdateActivityView2(EOS089WMSUserActivity);
        end;
    end;

    procedure GetActivityTableCaption2(): Text
    begin
        exit(TransferLine_Internal.TableCaption());
    end;

    procedure CountActivityRecords(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity"): Integer
    var
        Counter: Integer;
    begin
        if not EOS089WMSUserActivity."Show Record Counter" then
            exit(0);

        TransferHeader_Internal.SetView(EOS089WMSUserActivity.GetView1(true));
        OnAfterSetTransferHeaderFilters(EOS089WMSUserActivity.SystemId, TransferHeader_Internal);
        Counter := TransferHeader_Internal.Count();
        exit(Counter);
    end;

    procedure ShowActivityRecords(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    begin
        if not EOS089WMSUserActivity."Show Record Counter" then
            exit;

        TransferHeader_Internal.SetView(EOS089WMSUserActivity.GetView1(true));
        Page.RunModal(Page::"Transfer Orders", TransferHeader_Internal);
    end;

    procedure GetSourceDetails() Details: JsonObject
    begin
        Clear(Details);

        Details.Add('sourceTableDesc', SourceTableDescription());
        Details.Add('isDocument', true);
        Details.Add('isBatch', false);
    end;

    internal procedure GetActivityFieldsSettings(var TableNos: List of [Integer]; var ListEnabled: List of [Boolean]; var DetailsEnabled: List of [Boolean])
    begin
        Clear(TableNos);
        Clear(ListEnabled);
        Clear(DetailsEnabled);

        TableNos.Add(SourceTable1());
        TableNos.Add(SourceTable2());
        ListEnabled.Add(FieldListEnabled1());
        ListEnabled.Add(FieldListEnabled2());
        DetailsEnabled.Add(FieldDetailsEnabled1());
        DetailsEnabled.Add(FieldDetailsEnabled2());
    end;

    procedure GetDefaultActivityFields(TableNo: Integer; ActivityFieldClass: Enum "EOS089 WMS Act. Field Class"; var Fields: Record "EOS089 WMS Activity Field" temporary)
    var
        LineNo: Integer;
    begin
        if not Fields.IsTemporary() then
            exit;
        Fields.Reset();
        Fields.DeleteAll();

        LineNo := 0;
        case TableNo of
            SourceTable1():
                case ActivityFieldClass of
                    Enum::"EOS089 WMS Act. Field Class"::List:
                        begin
                            if not FieldListEnabled1() then
                                exit;

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("No.");
                            Fields."Show Caption" := false;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Shipment Date");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();
                        end;
                    Enum::"EOS089 WMS Act. Field Class"::Detail:
                        begin
                            if not FieldDetailsEnabled1() then
                                exit;

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from Name");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from Name 2");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from Address");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from Address 2");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from Post Code");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from City");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from County");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Trsf.-from Country/Region Code");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferHeader_Internal.FieldNo("Transfer-from Contact");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();
                        end;
                end;
            SourceTable2():
                case ActivityFieldClass of
                    Enum::"EOS089 WMS Act. Field Class"::Detail:
                        begin
                            if not FieldDetailsEnabled2() then
                                exit;

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferLine_Internal.FieldNo("Transfer-from Code");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferLine_Internal.FieldNo("Transfer-from Bin Code");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();

                            LineNo += 1;
                            Clear(Fields);
                            Fields."Field Type" := Enum::"EOS089 WMS Activity Field Type"::Field;
                            Fields."Field No." := TransferLine_Internal.FieldNo("Description 2");
                            Fields."Show Caption" := true;
                            Fields."Line No." := LineNo;
                            Fields.Insert();
                        end;
                end;
        end;
    end;

    procedure InitActivityActions()
    begin
    end;

    procedure GetActivityInfo(var EOS089WMSActivityInfo: Record "EOS089 WMS Activity Info")
    var
        EOS089WMSManagement: Codeunit "EOS089 WMS Management";
    begin
        EOS089WMSActivityInfo.Init();
        if not IsActivity() then
            exit;

        EOS089WMSActivityInfo.Activity := ActivityType();
        EOS089WMSActivityInfo.Category := ActivityCategory();
        EOS089WMSActivityInfo.Group := ActivityGroup();
        //EOS089WMSActivityInfo.Visibility := Enum::"EOS089 WMS Activity Visibility"::PowerWMS;
        EOS089WMSActivityInfo.Allowed := IsAllowed();
        if not EOS089WMSActivityInfo.Allowed then
            EOS089WMSActivityInfo."Not Allowed Reason" := CopyStr(GetNotAllowedReason(), 1, MaxStrLen(EOS089WMSActivityInfo."Not Allowed Reason"));
        EOS089WMSActivityInfo."Need Warehouse Employee" := false;
        EOS089WMSActivityInfo."App Id" := EOS089WMSManagement.GetAppId();
        EOS089WMSActivityInfo."App Name" := CopyStr(EOS089WMSManagement.GetAppName(), 1, MaxStrLen(EOS089WMSActivityInfo."App Name"));
        EOS089WMSActivityInfo.Insert();
    end;

    procedure CheckSourceAllowedForActivity(SourceType: Integer; SourceSubtype: Integer; ThrowError: Boolean): Boolean
    var
        ActivityNotAllowedErr: Label 'Activity %1 not allowed for Source %2', Comment = '%1: Activity, %2: Source Type';
    begin
        if not (SourceType in [SourceTable1(), SourceTable2()]) then
            if ThrowError then
                Error(ActivityNotAllowedErr, ActivityType(), SourceType)
            else
                exit(false);

        exit(true);
    end;

    procedure ManageActivityParameters(CurrentAction: Enum "EOS089 WMS Interface Action"; var EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; JsonPayload: JsonObject)
    begin
    end;

    procedure ManageActivityScanParameters(var EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan"; JsonObject: JsonObject)
    begin
    end;

    procedure FilterActivityScanParameters(EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan"; var TempEOS089WMSActivityScan: Record "EOS089 WMS Activity Scan" temporary)
    begin
    end;

    procedure ManageInitSourceScan(var EOS089WMSSourceScan: Record "EOS089 WMS Source Scan"; TempEOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail" temporary; TempEOS089WMSSourceInformationLine: Record "EOS089 WMS Source Information" temporary)
    begin
    end;

    procedure InitScanDetail(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan"; ScanId: Guid; var EOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail")
    begin
        EOS089WMSActScanDetail.Init();
        EOS089WMSActScanDetail.TransferFields(EOS089WMSActivityScan);
        EOS089WMSActScanDetail."Line No." := 1;
        EOS089WMSActScanDetail."Source Type" := SourceTable2();
        EOS089WMSActScanDetail."Source Subtype" := EOS089WMSActivityEntry."Source Subtype";
        EOS089WMSActScanDetail."Source ID" := EOS089WMSActivityEntry."Source ID";
        EOS089WMSActScanDetail."Source Batch Name" := EOS089WMSActivityEntry."Source Batch Name";
        EOS089WMSActScanDetail."Source Prod. Order Line" := EOS089WMSActivityEntry."Source Prod. Order Line";
        EOS089WMSActScanDetail."Source Ref. No." := EOS089WMSActivityScan."Source Line No.";
        EOS089WMSActScanDetail."Scan Id" := ScanId;
        EOS089WMSActScanDetail."Location Code" := EOS089WMSActivityScan."Location Code";
    end;

    procedure SetFiltersOn(var RecordRef: RecordRef): Boolean
    begin
        case RecordRef.Number of
            SourceTable1():
                begin
                    RecordRef.SetTable(TransferHeader_Internal);
                    if not SetFiltersOnHeader() then
                        exit(false);
                    RecordRef.GetTable(TransferHeader_Internal);
                    exit(true)
                end;
            SourceTable2():
                begin
                    RecordRef.SetTable(TransferLine_Internal);
                    if not SetFiltersOnLines() then
                        exit(false);
                    RecordRef.GetTable(TransferLine_Internal);
                    exit(true)
                end;
            else
                exit(false);
        end;
    end;

    procedure ManageSourceScans(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; ScanID: Guid)
    var
        EOS089WMSActivityTaskMgmt: Codeunit "EOS089 WMS Activity Task Mgmt.";
    begin
        // Modify
        Clear(EOS089WMSActivityTaskMgmt);
        EOS089WMSActivityTaskMgmt.SetDirection(Enum::"Transfer Direction"::Outbound);
        EOS089WMSActivityTaskMgmt.ManageActivityModifyScans(EOS089WMSActivityEntry, ScanId);

        // Delete
        Clear(EOS089WMSActivityTaskMgmt);
        EOS089WMSActivityTaskMgmt.SetDirection(Enum::"Transfer Direction"::Outbound);
        EOS089WMSActivityTaskMgmt.ManageActivityDeleteScans(EOS089WMSActivityEntry, ScanId);

        // Insert
        Clear(EOS089WMSActivityTaskMgmt);
        EOS089WMSActivityTaskMgmt.SetDirection(Enum::"Transfer Direction"::Outbound);
        EOS089WMSActivityTaskMgmt.ManageActivityInsertScans(EOS089WMSActivityEntry, ScanId);
    end;

#pragma warning disable AA0150
    procedure ManageInsertSourceScan(TempEOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail" temporary; TempEOS089WMSSourceInformation: Record "EOS089 WMS Source Information"; var IsHandled: Boolean)
    begin
    end;

    procedure ManageModifySourceScan(TempEOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail" temporary; var EOS089WMSSourceScan: Record "EOS089 WMS Source Scan"; var IsHandled: Boolean)
    begin
    end;

    procedure ManageDeleteSourceScan(TempEOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail" temporary; var EOS089WMSSourceScan: Record "EOS089 WMS Source Scan"; var IsHandled: Boolean)
    begin
    end;
#pragma warning restore AA0150

    procedure DoSomethingWithScanAfterActionDone(EOS089WMSSourceScan: Record "EOS089 WMS Source Scan"; ScanAction: Enum "EOS089 WMS Scan Action")
    begin
    end;

    procedure PostSource(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; var PostedDocumentNo: Code[20])
    var
        EOS089WMSSourceScan: Record "EOS089 WMS Source Scan";
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        //EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
        EOS089WMSUserActivityMgmt: Codeunit "EOS089 WMS User Activity Mgmt.";
        NothingToPostErr: Label 'Nothing to post';
    begin
        TransferHeader_Internal.Get(EOS089WMSActivityEntry."Source ID");

        EOS089WMSSourceScan.Reset();
        EOS089WMSSourceScan.SetRange("Activity Type", ActivityType());
        EOS089WMSSourceScan.SetRange("Source Subtype As Int", 0);
        EOS089WMSSourceScan.SetRange("Source ID", TransferHeader_Internal."No.");
        if EOS089WMSSourceScan.IsEmpty() then
            Error(NothingToPostErr);

        TransferHeader_Internal.Validate("Posting Date", Today());
        TransferHeader_Internal.Modify(true);

        if FieldDetailsEnabled1() then
            EOS089WMSUserActivityMgmt.CheckMandatoryFields(EOS089WMSActivityEntry."Employee No.", EOS089WMSActivityEntry."Activity Type", TransferHeader_Internal.RecordId());
        if FieldDetailsEnabled2() then
            EOS089WMSUserActivityMgmt.CheckMandatoryFieldsFromSourceScan(EOS089WMSActivityEntry."Employee No.", EOS089WMSActivityEntry."Activity Type", SourceTable2(), EOS089WMSSourceScan);

        TransferPostShipment.SetSuppressCommit(true);
        TransferPostShipment.Run(TransferHeader_Internal);

        TransferHeader_Internal.SetLoadFields("Last Shipment No.");
        TransferHeader_Internal.Get(EOS089WMSActivityEntry."Source ID");
        PostedDocumentNo := TransferHeader_Internal."Last Shipment No.";

        //EOS089WMSActivityManagement.DeleteSourceScansAfterPost(EOS089WMSActivityEntry);

        GetPostedSourceMessage(PostedDocumentNo);
    end;

    procedure DeleteSourceScans(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"): Boolean
    begin
    end;

    procedure ResetSource(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"): Boolean
    var
        TempEOS089WMSSourceInformation: Record "EOS089 WMS Source Information" temporary;
        EOS089WMSTrackingManagement: Codeunit "EOS089 WMS Tracking Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        ItemLedgerEntryType: Enum "Item Ledger Entry Type";
        TrackingType: Enum "EOS089 WMS Tracking Type";
    begin
        GetRecordMapping(EOS089WMSActivityEntry."Source Type", TempEOS089WMSSourceInformation);

        TransferLine_Internal.Reset();
        TransferLine_Internal.SetRange("Document No.", EOS089WMSActivityEntry."Source ID");
        TransferLine_Internal.SetRange("Completely Shipped", false);
        TransferLine_Internal.SetRange("Derived From Line No.", 0);
        if TransferLine_Internal.IsEmpty() then
            exit;

        ItemLedgerEntryType := ItemLedgerEntryType::Transfer;
        RecordRef.Open(SourceTable2());
        RecordRef.SetView(TransferLine_Internal.GetView());

        RecordRef.FindSet();
        repeat
            Clear(EOS089WMSTrackingManagement);
            TempEOS089WMSSourceInformation.TransferInformationFromRecordRef(RecordRef);

            TrackingType := EOS089WMSTrackingManagement.GetItemTrackingTypeByItemNo(TempEOS089WMSSourceInformation."No.", ItemLedgerEntryType, TempEOS089WMSSourceInformation."Outstanding Qty. (Base)" > 0);

            EOS089WMSTrackingManagement.SetDirection(Enum::"Transfer Direction"::Outbound);
            if TrackingType <> TrackingType::None then
                EOS089WMSTrackingManagement.DeleteRecordRefTracking(RecordRef.RecordId());

            FieldRef := RecordRef.Field(TempEOS089WMSSourceInformation."Qty. To Manage Field No.");
            FieldRef.Validate(0);

            RecordRef.Modify(true);
        until RecordRef.Next() = 0;

        RecordRef.Close();

        Commit();

        GetResetSourceMessage(EOS089WMSActivityEntry."Source ID");
    end;

    procedure GetRecordMapping(TableId: Integer; var TempEOS089WMSSourceInformation: Record "EOS089 WMS Source Information" temporary)
    begin
        // Source subtype is managed directly in order to avoid complex management further

        TempEOS089WMSSourceInformation.Init();
        TempEOS089WMSSourceInformation."Source Type" := SourceTable2();
        TempEOS089WMSSourceInformation."Source Subtype" := Enum::"EOS089 WMS Source Subtype"::"0";

        TempEOS089WMSSourceInformation."Source Id Field No." := TransferLine_Internal.FieldNo("Document No.");
        TempEOS089WMSSourceInformation."Source Ref. No. Field No." := TransferLine_Internal.FieldNo("Line No.");
        TempEOS089WMSSourceInformation."Outst. Qty. (Base) Field No." := TransferLine_Internal.FieldNo("Outstanding Qty. (Base)");
        TempEOS089WMSSourceInformation."Qty. To Man. (Base) Field No." := TransferLine_Internal.FieldNo("Qty. to Ship (Base)");
        TempEOS089WMSSourceInformation."Outstanding Quantity Field No." := TransferLine_Internal.FieldNo("Outstanding Quantity");
        TempEOS089WMSSourceInformation."Qty. To Manage Field No." := TransferLine_Internal.FieldNo("Qty. to Ship");
        TempEOS089WMSSourceInformation."Qty. per UoM Field No." := TransferLine_Internal.FieldNo("Qty. per Unit of Measure");
        TempEOS089WMSSourceInformation."Qty.Rndg.Prec.(Base) Field No." := TransferLine_Internal.FieldNo("Qty. Rounding Precision (Base)");
        TempEOS089WMSSourceInformation."Qty. Rounding Prec. Field No." := TransferLine_Internal.FieldNo("Qty. Rounding Precision");
        TempEOS089WMSSourceInformation."Location Code Field No." := TransferLine_Internal.FieldNo("Transfer-from Code");
        TempEOS089WMSSourceInformation."Bin Code Field No." := TransferLine_Internal.FieldNo("Transfer-from Bin Code");
        TempEOS089WMSSourceInformation."Description Field No." := TransferLine_Internal.FieldNo(Description);
        TempEOS089WMSSourceInformation."Description 2 Field No." := TransferLine_Internal.FieldNo("Description 2");
        TempEOS089WMSSourceInformation."Receipt Date Field No." := TransferLine_Internal.FieldNo("Shipment Date");
        TempEOS089WMSSourceInformation."No. Field No." := TransferLine_Internal.FieldNo("Item No.");
        TempEOS089WMSSourceInformation."Unit Of Measure Code Field No." := TransferLine_Internal.FieldNo("Unit of Measure Code");
    end;

    procedure GetRecordRefForScanManagement(EOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail"; var RecordRef: RecordRef): Boolean
    begin
        TransferLine_Internal.Reset();
        TransferLine_Internal.SetRange("Document No.", EOS089WMSActScanDetail."Source ID");
        TransferLine_Internal.SetFilter("EOS WMS Employee No. Filter", '%1', EOS089WMSActScanDetail."Employee No.");
        RecordRef.Open(SourceTable2());
        RecordRef.GetTable(TransferLine_Internal);
        if not SetFiltersOnLines() then begin
            RecordRef.Close();
            exit(false);
        end;
        RecordRef.SetTable(TransferLine_Internal);
        RecordRef.Close();

        if EOS089WMSActScanDetail."Source Line No." <> 0 then
            TransferLine_Internal.SetRange("Line No.", EOS089WMSActScanDetail."Source Line No.");
        TransferLine_Internal.SetRange("Item No.", EOS089WMSActScanDetail."Item No.");
        TransferLine_Internal.SetRange("Variant Code", EOS089WMSActScanDetail."Variant Code");
        TransferLine_Internal.SetFilter("Outstanding Qty. (Base)", '<>%1', 0);
        if EOS089WMSActScanDetail."Source Line No." = 0 then begin
            TransferLine_Internal.SetRange("Transfer-from Code", EOS089WMSActScanDetail."Location Code");
            TransferLine_Internal.SetRange("Transfer-from Bin Code", EOS089WMSActScanDetail."Bin Code");
            TransferLine_Internal.SetRange("Unit Of Measure Code", EOS089WMSActScanDetail."Unit Of Measure Code");
        end;

        RecordRef.Open(SourceTable2());
        RecordRef.SetLoadFields(TransferLine_Internal.FieldNo("Outstanding Qty. (Base)"), TransferLine_Internal.FieldNo("Qty. to Ship (Base)"), TransferLine_Internal.FieldNo(SystemId));
        RecordRef.AddLoadFields(TransferLine_Internal.FieldNo("Document No."), TransferLine_Internal.FieldNo("Line No."), TransferLine_Internal.FieldNo("Qty. per Unit of Measure"),
                                TransferLine_Internal.FieldNo("Transfer-from Code"), TransferLine_Internal.FieldNo(Description), TransferLine_Internal.FieldNo("Shipment Date"));
        RecordRef.SetView(TransferLine_Internal.GetView());

        if RecordRef.IsEmpty() then begin
            RecordRef.Close();
            exit(false);
        end else
            exit(true);
    end;

    procedure ShowSourceEntity(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry")
    var
        TransferOrder: Page "Transfer Order";
    begin
        TransferHeader_Internal.Get(EOS089WMSActivityEntry."Source ID");
        TransferOrder.SetRecord(TransferHeader_Internal);
        TransferOrder.Run();
    end;

    procedure ShowPostedEntity(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry")
    begin
    end;

    procedure GetActivityTrackingSettings(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan"; var ItemLedgerEntryType: Enum "Item Ledger Entry Type"; var IsInbound: Boolean)
    begin
        ItemLedgerEntryType := Enum::"Item Ledger Entry Type"::Transfer;
        IsInbound := false;
    end;

    procedure GetReservationEntries(var EOS089WMSReservationEntry: Record "EOS089 WMS Reservation Entry" temporary): Boolean
    var
        ReservationEntry: Record "Reservation Entry";
        TransferLine: Record "Transfer Line";
        EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
        RecordRef: RecordRef;
        SourceType, SourceSubtype, SourceRefNo, SourceProdOrderLine : Integer;
        EmployeeNo: Code[20];
        SourceId: Code[20];
        SourceBatchName: Code[10];
        InvalidSourceTypeErr: Label 'Provide a valid Source Type';
    begin
        Evaluate(EmployeeNo, EOS089WMSReservationEntry.GetFilter("EOS WMS Employee No. Filter"));
        EOS089WMSActivityManagement.EmployeeAllowed(EmployeeNo, ActivityType(), true);

        if EOS089WMSReservationEntry.GetFilter("Source Type") <> '' then
            Evaluate(SourceType, EOS089WMSReservationEntry.GetFilter("Source Type"));
        if EOS089WMSReservationEntry.GetFilter("Source Subtype") <> '' then
            Evaluate(SourceSubtype, EOS089WMSReservationEntry.GetFilter("Source Subtype"));
        if EOS089WMSReservationEntry.GetFilter("Source Id") <> '' then
            Evaluate(SourceId, EOS089WMSReservationEntry.GetFilter("Source Id"));
        if EOS089WMSReservationEntry.GetFilter("Source Batch Name") <> '' then
            Evaluate(SourceBatchName, EOS089WMSReservationEntry.GetFilter("Source Batch Name"));
        if EOS089WMSReservationEntry.GetFilter("Source Prod. Order Line") <> '' then
            Evaluate(SourceProdOrderLine, EOS089WMSReservationEntry.GetFilter("Source Prod. Order Line"));
        if EOS089WMSReservationEntry.GetFilter("Source Ref. No.") <> '' then
            Evaluate(SourceRefNo, EOS089WMSReservationEntry.GetFilter("Source Ref. No."));

        if SourceType = 0 then
            Error(InvalidSourceTypeErr);

        if SourceRefNo <> 0 then begin
            ReservationEntry.InitSortingAndFilters(true);
            ReservationEntry.SetSourceFilter(SourceType, SourceSubtype, SourceId, SourceRefNo, false);
            ReservationEntry.SetSourceFilter(SourceBatchName, SourceProdOrderLine);

            Clear(EOS089WMSReservationEntry);
            EOS089WMSReservationEntry.Reset();

            EOS089WMSReservationEntry.AddReservationToRecordSet(ReservationEntry);
        end else begin
            TransferLine.Reset();
            TransferLine.SetRange("EOS WMS Activity Type Filter", ActivityType());
            TransferLine.SetRange("EOS WMS Employee No. Filter", EmployeeNo);
            RecordRef.GetTable(TransferLine);
            if not SetFiltersOn(RecordRef) then
                exit(false);
            RecordRef.SetTable(TransferLine);
            TransferLine.SetRange("Document No.", SourceId);
            if TransferLine.FindSet(false) then
                repeat
                    ReservationEntry.InitSortingAndFilters(true);
                    ReservationEntry.SetSourceFilter(SourceType, SourceSubtype, SourceId, TransferLine."Line No.", false);
                    ReservationEntry.SetSourceFilter(SourceBatchName, SourceProdOrderLine);

                    Clear(EOS089WMSReservationEntry);
                    EOS089WMSReservationEntry.Reset();

                    EOS089WMSReservationEntry.AddReservationToRecordSet(ReservationEntry);
                until TransferLine.Next() = 0;
        end;

        EOS089WMSReservationEntry.Reset();
        EOS089WMSReservationEntry.SetRange("EOS WMS Activity Type Filter", ActivityType());
        EOS089WMSReservationEntry.SetRange("EOS WMS Employee No. Filter", EmployeeNo);
        exit(EOS089WMSReservationEntry.FindSet(false));
    end;

    procedure GetActionReturnValues(): JsonObject
    begin
        exit(ReturnValues);
    end;

    procedure OmniSearch(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; SearchValue: Text; var JsonObject: JsonObject): Boolean
    begin
        if StrLen(SearchValue) > MaxStrLen(TransferHeader_Internal."No.") then
            exit(false);

        TransferHeader_Internal.Reset();
        TransferHeader_Internal.SetAutoCalcFields("EOS WMS Pending Activities -S");
        TransferHeader_Internal.SetLoadFields("EOS WMS Pending Activities -S");
        TransferHeader_Internal.SetRange("No.", SearchValue);
        TransferHeader_Internal.SetFilter("EOS WMS Employee No. Filter", EOS089WMSActivityEntry."Employee No.");
        SetFiltersOnHeader();
        if TransferHeader_Internal.Count() = 1 then
            if TransferHeader_Internal.FindFirst() then begin
                JsonObject.Add('activity', Format(ActivityType()));
                JsonObject.Add('activityInt', ActivityType().AsInteger());
                JsonObject.Add('sourceId', TransferHeader_Internal."No.");
                JsonObject.Add('wmsPendingActivities', TransferHeader_Internal."EOS WMS Pending Activities -S");
                exit(true);
            end;

        exit(false);
    end;

    procedure AllowAlternativeViews(): Boolean
    begin
        exit(true);
    end;

    procedure GetActivityView1(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View"; HumanReadable: Boolean): Text
    var
        PageFilterBuilder: FilterPageBuilder;
        ActivityView: Text;
    begin
        PageFilterBuilder.AddTable(TransferHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(TransferHeader_Internal.TableCaption(), EOS089WMAltUsrActView.GetView1(true));
        ActivityView := PageFilterBuilder.GetView(TransferHeader_Internal.TableCaption(), HumanReadable);
        exit(ActivityView);
    end;

    procedure SetActivityView1(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View")
    var
        PageFilterBuilder: FilterPageBuilder;
        CurrentView: Text;
    begin
        PageFilterBuilder.AddTable(TransferHeader_Internal.TableCaption(), SourceTable1());
        CurrentView := EOS089WMAltUsrActView.GetView1(true);
        if CurrentView <> '' then
            PageFilterBuilder.SetView(TransferHeader_Internal.TableCaption(), CurrentView);

        if PageFilterBuilder.RunModal() then begin
            CurrentView := PageFilterBuilder.GetView(TransferHeader_Internal.TableCaption(), false);
            EOS089WMAltUsrActView.SetView1(CurrentView);
            UpdateActivityView1(EOS089WMAltUsrActView);
            EOS089WMAltUsrActView.Modify(true);
        end;
    end;

    procedure UpdateActivityView1(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View")
    var
        EOS089WMAltUsrActViewMgmt: Codeunit "EOS089 WMS User Activity Mgmt.";
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        LocationFilter := '';

        // First, apply current view
        TransferHeader_Internal.SetView(EOS089WMAltUsrActView.GetView1(true));

        // Then, reset default filters
        LocationFilter := EOS089WMAltUsrActViewMgmt.BuildLocationFilterForActivity(EOS089WMAltUsrActView, TransferHeader_Internal.GetFilter("Location Filter"));

        TransferHeader_Internal.SetRange("Completely Shipped");
        TransferHeader_Internal.SetRange("Location Filter");
        TransferHeader_Internal.SetRange("Assigned User ID");

        SetDefaultFilters1(EOS089WMAltUsrActView, LocationFilter);

        // Finally, save updated view
        PageFilterBuilder.AddTable(TransferHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(TransferHeader_Internal.TableCaption(), TransferHeader_Internal.GetView());

        CurrentView := PageFilterBuilder.GetView(TransferHeader_Internal.TableCaption(), false);
        EOS089WMAltUsrActView.SetView1(CurrentView);

        EOS089WMAltUsrActView.SetLocationFilter1(LocationFilter);
    end;

    procedure SetActivityKey1(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View")
    var
        KeyRec: Record "Key";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        NameValueLookup: Page "Name/Value Lookup";
        KeyNo: Integer;
    begin
        KeyRec.Reset();
        KeyRec.SetLoadFields("No.", "Key");
        KeyRec.SetRange(TableNo, EOS089WMAltUsrActView."Table Id 1");

        if KeyRec.FindSet(false) then
            repeat
                NameValueLookup.AddItem(Format(KeyRec."No."), KeyRec."Key");
            until KeyRec.Next() = 0;
        NameValueLookup.LookupMode(true);
        if NameValueLookup.RunModal() = Action::LookupOK then begin
            NameValueLookup.GetRecord(TempNameValueBuffer);
            Evaluate(KeyNo, TempNameValueBuffer.Name);
            EOS089WMAltUsrActView.Validate("Key No. 1", KeyNo);
            UpdateActivityView1(EOS089WMAltUsrActView);
        end;
    end;

    procedure GetActivityView2(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View"; HumanReadable: Boolean): Text
    var
        PageFilterBuilder: FilterPageBuilder;
        ActivityView: Text;
    begin
        PageFilterBuilder.AddTable(TransferLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(TransferLine_Internal.TableCaption(), EOS089WMAltUsrActView.GetView2(true));
        ActivityView := PageFilterBuilder.GetView(TransferLine_Internal.TableCaption(), HumanReadable);
        exit(ActivityView);
    end;

    procedure SetActivityView2(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View")
    var
        PageFilterBuilder: FilterPageBuilder;
        CurrentView: Text;
    begin
        PageFilterBuilder.AddTable(TransferLine_Internal.TableCaption(), SourceTable2());
        CurrentView := EOS089WMAltUsrActView.GetView2(true);
        if CurrentView <> '' then
            PageFilterBuilder.SetView(TransferLine_Internal.TableCaption(), CurrentView);

        if PageFilterBuilder.RunModal() then begin
            CurrentView := PageFilterBuilder.GetView(TransferLine_Internal.TableCaption(), false);
            EOS089WMAltUsrActView.SetView2(CurrentView);
            UpdateActivityView2(EOS089WMAltUsrActView);
            EOS089WMAltUsrActView.Modify(true);
        end;
    end;

    procedure UpdateActivityView2(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View")
    var
        EOS089WMAltUsrActViewMgmt: Codeunit "EOS089 WMS User Activity Mgmt.";
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        LocationFilter := '';

        // First, apply current view
        TransferLine_Internal.SetView(EOS089WMAltUsrActView.GetView2(true));

        // Then, reset default filters
        LocationFilter := EOS089WMAltUsrActViewMgmt.BuildLocationFilterForActivity(EOS089WMAltUsrActView, TransferLine_Internal.GetFilter("Transfer-From Code"));

        TransferLine_Internal.SetRange("Completely Shipped");
        TransferLine_Internal.SetRange("Transfer-from Code");
        TransferLine_Internal.SetRange("Derived From Line No.");

        SetDefaultFilters2(EOS089WMAltUsrActView, LocationFilter);

        // Finally, save updated view
        PageFilterBuilder.AddTable(TransferLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(TransferLine_Internal.TableCaption(), TransferLine_Internal.GetView());

        CurrentView := PageFilterBuilder.GetView(TransferLine_Internal.TableCaption(), false);
        EOS089WMAltUsrActView.SetView2(CurrentView);

        EOS089WMAltUsrActView.SetLocationFilter2(LocationFilter);
    end;

    procedure SetActivityKey2(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View")
    var
        KeyRec: Record "Key";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        NameValueLookup: Page "Name/Value Lookup";
        KeyNo: Integer;
    begin
        KeyRec.Reset();
        KeyRec.SetLoadFields("No.", "Key");
        KeyRec.SetRange(TableNo, EOS089WMAltUsrActView."Table Id 2");

        if KeyRec.FindSet(false) then
            repeat
                NameValueLookup.AddItem(Format(KeyRec."No."), KeyRec."Key");
            until KeyRec.Next() = 0;
        NameValueLookup.LookupMode(true);
        if NameValueLookup.RunModal() = Action::LookupOK then begin
            NameValueLookup.GetRecord(TempNameValueBuffer);
            Evaluate(KeyNo, TempNameValueBuffer.Name);
            EOS089WMAltUsrActView.Validate("Key No. 2", KeyNo);
            UpdateActivityView2(EOS089WMAltUsrActView);
        end;
    end;

    procedure CountActivityRecords(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View"): Integer
    var
        Counter: Integer;
    begin
        if not EOS089WMAltUsrActView."Show Record Counter" then
            exit(0);

        TransferHeader_Internal.SetView(EOS089WMAltUsrActView.GetView1(true));
        OnAfterSetTransferHeaderFilters(EOS089WMAltUsrActView.SystemId, TransferHeader_Internal);
        Counter := TransferHeader_Internal.Count();
        exit(Counter);
    end;

    procedure ShowActivityRecords(var EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View")
    begin
        if not EOS089WMAltUsrActView."Show Record Counter" then
            exit;

        TransferHeader_Internal.SetView(EOS089WMAltUsrActView.GetView1(true));
        Page.RunModal(Page::"Transfer Orders", TransferHeader_Internal);
    end;

    local procedure SetDefaultFilters1(EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; LocationFilter: Text)
    var
        EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
        RecordRef: RecordRef;
    begin
        TransferHeader_Internal.Setrange(Status, TransferHeader_Internal.Status::Released);
        TransferHeader_Internal.SetRange("Completely Shipped", false);
        TransferHeader_Internal.SetFilter("Location Filter", LocationFilter);
        TransferHeader_Internal.SetRange("EOS WMS Line Exists -S", true);

        if EOS089WMSUserActivity."Apply User Id Filter" then begin
            EOS089WMSUserActivity.CalcFields("Linked User Id");
            EOS089WMSUserActivity.TestField("Linked User Id");
            if EOS089WMSUserActivity."Linked User Id" <> '' then begin
                if EOS089WMSUserActivity."Allow Blank User Id" then
                    TransferHeader_Internal.SetFilter("Assigned User ID", '%1|%2', '', EOS089WMSUserActivity."Linked User Id")
                else
                    TransferHeader_Internal.SetRange("Assigned User ID", EOS089WMSUserActivity."Linked User Id")
            end else
                TransferHeader_Internal.SetRange("Assigned User ID", EOS089WMSActivityManagement.GetInvalidUserIdFilter());
        end else
            if EOS089WMSUserActivity."Allow Blank User Id" then
                TransferHeader_Internal.SetFilter("Assigned User ID", '%1', '');

        OnAfterSetDefaultFiltersOnTransferHeader(EOS089WMSUserActivity, TransferHeader_Internal);

        RecordRef.Open(SourceTable1());
        RecordRef.GetTable(TransferHeader_Internal);
        RecordRef.CurrentKeyIndex(EOS089WMSUserActivity."Key No. 1");
        RecordRef.Ascending(EOS089WMSUserActivity."Key Sort 1" = EOS089WMSUserActivity."Key Sort 1"::Asc);
        RecordRef.SetTable(TransferHeader_Internal);
        RecordRef.Close();
    end;

    local procedure SetDefaultFilters2(EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; LocationFilter: Text)
    var
        RecordRef: RecordRef;
    begin
        TransferLine_Internal.SetRange("Completely Shipped", false);
        TransferLine_Internal.SetFilter("Transfer-From Code", LocationFilter);
        TransferLine_Internal.SetRange("Derived From Line No.", 0);

        OnAfterSetDefaultFiltersOnTransferLine(EOS089WMSUserActivity, TransferLine_Internal);

        RecordRef.Open(SourceTable2());
        RecordRef.GetTable(TransferLine_Internal);
        RecordRef.CurrentKeyIndex(EOS089WMSUserActivity."Key No. 2");
        RecordRef.Ascending(EOS089WMSUserActivity."Key Sort 2" = EOS089WMSUserActivity."Key Sort 2"::Asc);
        RecordRef.SetTable(TransferLine_Internal);
        RecordRef.Close();
    end;

    local procedure SetDefaultFilters1(EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View"; LocationFilter: Text)
    var
        EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
        RecordRef: RecordRef;
    begin
        TransferHeader_Internal.Setrange(Status, TransferHeader_Internal.Status::Released);
        TransferHeader_Internal.SetRange("Completely Shipped", false);
        TransferHeader_Internal.SetFilter("Location Filter", LocationFilter);
        TransferHeader_Internal.SetRange("EOS WMS Line Exists -S", true);

        if EOS089WMAltUsrActView."Apply User Id Filter" then begin
            EOS089WMAltUsrActView.CalcFields("Linked User Id");
            EOS089WMAltUsrActView.TestField("Linked User Id");
            if EOS089WMAltUsrActView."Linked User Id" <> '' then begin
                if EOS089WMAltUsrActView."Allow Blank User Id" then
                    TransferHeader_Internal.SetFilter("Assigned User ID", '%1|%2', '', EOS089WMAltUsrActView."Linked User Id")
                else
                    TransferHeader_Internal.SetRange("Assigned User ID", EOS089WMAltUsrActView."Linked User Id")
            end else
                TransferHeader_Internal.SetRange("Assigned User ID", EOS089WMSActivityManagement.GetInvalidUserIdFilter());
        end else
            if EOS089WMAltUsrActView."Allow Blank User Id" then
                TransferHeader_Internal.SetFilter("Assigned User ID", '%1', '');

        OnAfterSetAlternativeDefaultFiltersOnTransferHeader(EOS089WMAltUsrActView, TransferHeader_Internal);

        RecordRef.Open(SourceTable1());
        RecordRef.GetTable(TransferHeader_Internal);
        RecordRef.CurrentKeyIndex(EOS089WMAltUsrActView."Key No. 1");
        RecordRef.Ascending(EOS089WMAltUsrActView."Key Sort 1" = EOS089WMAltUsrActView."Key Sort 1"::Asc);
        RecordRef.SetTable(TransferHeader_Internal);
        RecordRef.Close();
    end;

    local procedure SetDefaultFilters2(EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View"; LocationFilter: Text)
    var
        RecordRef: RecordRef;
    begin
        TransferLine_Internal.SetRange("Completely Shipped", false);
        TransferLine_Internal.SetFilter("Transfer-From Code", LocationFilter);
        TransferLine_Internal.SetRange("Derived From Line No.", 0);

        OnAfterSetAlternativeDefaultFiltersOnTransferLine(EOS089WMAltUsrActView, TransferLine_Internal);

        RecordRef.Open(SourceTable2());
        RecordRef.GetTable(TransferLine_Internal);
        RecordRef.CurrentKeyIndex(EOS089WMAltUsrActView."Key No. 2");
        RecordRef.Ascending(EOS089WMAltUsrActView."Key Sort 2" = EOS089WMAltUsrActView."Key Sort 2"::Asc);
        RecordRef.SetTable(TransferLine_Internal);
        RecordRef.Close();
    end;

    local procedure SetFiltersOnHeader(): Boolean
    var
        EOS089WMSUserActivity: Record "EOS089 WMS User Activity";
        EOS089WMSAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View";
        EOS089WMSAltViewHandler: Codeunit "EOS089 WMS Alt. View Handler";
        CurrentView: Text;
        AltViewCode: Code[20];
        EmployeeNo: Code[20];
        NoFilters: Text;
    begin
        NoFilters := TransferHeader_Internal.GetFilter("No.");
        EmployeeNo := CopyStr(TransferHeader_Internal.GetFilter("EOS WMS Employee No. Filter"), 1, MaxStrLen(EmployeeNo));
        if EmployeeNo = '' then
            exit(false);

        AltViewCode := EOS089WMSAltViewHandler.GetAlternativeViewCode(EmployeeNo, ActivityType());
        if AltViewCode = '' then begin
            EOS089WMSUserActivity.SetAutoCalcFields("Record View 1");
            EOS089WMSUserActivity.SetloadFields("Use Textual View 1", "Record View 1 Text", "Record View 1", SystemId);
            if not EOS089WMSUserActivity.Get(EmployeeNo, ActivityType()) then
                exit(false);
            CurrentView := EOS089WMSUserActivity.GetView1(false)
        end else begin
            EOS089WMSAltUsrActView.SetAutoCalcFields("Record View 1");
            EOS089WMSAltUsrActView.SetLoadFields("Use Textual View 1", "Record View 1 Text", "Record View 1");
            if not EOS089WMSAltUsrActView.Get(EmployeeNo, ActivityType(), AltViewCode) then
                exit(false);
            CurrentView := EOS089WMSAltUsrActView.GetView1(false);
        end;

        TransferHeader_Internal.Reset();
        TransferHeader_Internal.SetView(CurrentView);
        if NoFilters <> '' then
            TransferHeader_Internal.SetFilter("No.", NoFilters);

        TransferHeader_Internal.SetRange("EOS WMS Employee No. Filter", EmployeeNo);
        TransferHeader_Internal.SetRange("EOS WMS Activity Type Filter", ActivityType());

        OnAfterSetTransferHeaderFilters(EOS089WMSUserActivity.SystemId, TransferHeader_Internal);

        exit(true);
    end;

    local procedure SetFiltersOnLines(): Boolean
    var
        EOS089WMSUserActivity: Record "EOS089 WMS User Activity";
        EOS089WMSAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View";
        EOS089WMSAltViewHandler: Codeunit "EOS089 WMS Alt. View Handler";
        CurrentView: Text;
        AltViewCode: Code[20];
        DocumentNo, EmployeeNo : Code[20];
    begin
        DocumentNo := CopyStr(TransferLine_Internal.GetFilter("Document No."), 1, MaxStrLen(DocumentNo));
        EmployeeNo := CopyStr(TransferLine_Internal.GetFilter("EOS WMS Employee No. Filter"), 1, MaxStrLen(EmployeeNo));
        if EmployeeNo = '' then
            exit(false);

        AltViewCode := EOS089WMSAltViewHandler.GetAlternativeViewCode(EmployeeNo, ActivityType());
        if AltViewCode = '' then begin
            EOS089WMSUserActivity.SetAutoCalcFields("Record View 2");
            EOS089WMSUserActivity.SetloadFields("Use Textual View 2", "Record View 2 Text", "Record View 2", SystemId);
            if not EOS089WMSUserActivity.Get(EmployeeNo, ActivityType()) then
                exit(false);
            CurrentView := EOS089WMSUserActivity.GetView2(false)
        end else begin
            EOS089WMSAltUsrActView.SetAutoCalcFields("Record View 2");
            EOS089WMSAltUsrActView.SetLoadFields("Use Textual View 2", "Record View 1 Text", "Record View 2");
            if not EOS089WMSAltUsrActView.Get(EmployeeNo, ActivityType(), AltViewCode) then
                exit(false);
            CurrentView := EOS089WMSAltUsrActView.GetView2(false);
        end;


        TransferLine_Internal.Reset();
        TransferLine_Internal.SetView(EOS089WMSUserActivity.GetView2(false));
        TransferLine_Internal.SetFilter("Document No.", DocumentNo);

        TransferLine_Internal.SetRange("EOS WMS Employee No. Filter", EmployeeNo);
        TransferLine_Internal.SetRange("EOS WMS Activity Type Filter", ActivityType());

        OnAfterSetTransferLineFilters2(EOS089WMSUserActivity.SystemId, TransferLine_Internal);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", OnAfterDeleteEvent, '', false, false)]
    local procedure DeleteSourceScansOnAfterDeleteSourceLine(var Rec: Record "Transfer Line"; RunTrigger: Boolean)
    var
        EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
    begin
        if Rec.IsTemporary() then
            exit;

        if not RunTrigger then
            exit;

        EOS089WMSActivityManagement.DeleteActivityLineSourceScans(ActivityType(), 0, Rec."Document No.", '', 0, Rec."Line No.", '');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDefaultFiltersOnTransferHeader(EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetDefaultFiltersOnTransferLine(EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTransferHeaderFilters(UserActivitySystemId: Guid; var TransferHeader: Record "Transfer Header")
    begin
    end;

    [Obsolete('Wrong signature. Use OnAfterSetTransferLineFilters2 instead', '25.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTransferLineFilters(UserActivitySystemId: Guid; var SalesLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetTransferLineFilters2(UserActivitySystemId: Guid; var TransferLine: Record "Transfer Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", OnAfterTransferOrderPostShipment, '', false, false)]
    local procedure CU5704_OnAfterTransferOrderPostShipment(var TransferHeader: Record "Transfer Header")
    var
        EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
    begin
        EOS089WMSActivityManagement.DeleteSourceScansAfterPost(ActivityType(), 0, TransferHeader."No.", '', '');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetAlternativeDefaultFiltersOnTransferHeader(EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View"; var TransferHeader: Record "Transfer Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetAlternativeDefaultFiltersOnTransferLine(EOS089WMAltUsrActView: Record "EOS089 WMS Alt. Usr.Act. View"; var TransferLine: Record "Transfer Line")
    begin
    end;

    procedure AllowCustomSource(): Boolean
    begin
        exit(true);
    end;

    procedure GetSourceTableInfo(Wich: Option Header,Line; var TableNo: Integer; var TableSubtype: Enum "EOS089 WMS Source Subtype")
    begin
        case Wich of
            Wich::Header:
                TableNo := Sourcetable1();
            Wich::Line:
                TableNo := Sourcetable2();
        end;
        TableSubtype := Enum::"EOS089 WMS Source Subtype"::"0";
    end;

    procedure OpenSourceHeaderRecordRef(EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; TempEOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header" temporary; var SourceRecordRef: RecordRef)
    begin
        SourceRecordRef.Open(SourceTable1());
        SourceRecordRef.SetView(EOS089WMSUserActivity.GetView1(false));
    end;

    procedure FillHeaderData(SourceRecordRef: RecordRef; var TempEOS089WMSCustomActHeader: Record "EOS089 WMS Custom Act. Header" temporary)
    begin
        SourceRecordRef.SetTable(TransferHeader_Internal);
        TempEOS089WMSCustomActHeader.Init();
        TempEOS089WMSCustomActHeader.SystemId := TransferHeader_Internal.SystemId;
        TempEOS089WMSCustomActHeader."No." := TransferHeader_Internal."No.";
        TempEOS089WMSCustomActHeader."Reference Name" := TransferHeader_Internal."Transfer-to Name";
        TempEOS089WMSCustomActHeader."Reference Date" := TransferHeader_Internal."Shipment Date";
        TempEOS089WMSCustomActHeader."Item Ledger Entry Type" := Enum::"Item Ledger Entry Type"::Transfer;
        TempEOS089WMSCustomActHeader.Inbound := false;
        TempEOS089WMSCustomActHeader.Insert(false, true);
    end;

    procedure OpenSourceLineRecordRef(EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; TempEOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line" temporary; var SourceRecordRef: RecordRef)
    begin
        TransferLine_Internal.SetView(EOS089WMSUserActivity.GetView2(false));
        if TempEOS089WMSCustomActLine.GetFilter("Document No.") <> '' then
            TransferLine_Internal.SetFilter("Document No.", '%1', TempEOS089WMSCustomActLine.GetFilter("Document No."));

        SourceRecordRef.Open(SourceTable2());
        SourceRecordRef.SetView(TransferLine_Internal.GetView(false));
    end;

    procedure FillLineData(SourceRecordRef: RecordRef; var TempEOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line" temporary)
    begin
        SourceRecordRef.SetTable(TransferLine_Internal);
        TempEOS089WMSCustomActLine.Init();
        TempEOS089WMSCustomActLine.SystemId := TransferLine_Internal.SystemId;
        TempEOS089WMSCustomActLine."Document No." := TransferLine_Internal."Document No.";
        TempEOS089WMSCustomActLine."Line No." := TransferLine_Internal."Line No.";
        TempEOS089WMSCustomActLine."Item No." := TransferLine_Internal."Item No.";
        TempEOS089WMSCustomActLine."Variant Code 2" := TransferLine_Internal."Variant Code";
        TempEOS089WMSCustomActLine."Description" := TransferLine_Internal."Description";
        TempEOS089WMSCustomActLine."Description 2" := TransferLine_Internal."Description 2";
        TempEOS089WMSCustomActLine."Location Code" := TransferLine_Internal."Transfer-From Code";
        TempEOS089WMSCustomActLine."Bin Code" := TransferLine_Internal."Transfer-From Bin Code";
        TempEOS089WMSCustomActLine."Unit of Measure Code" := TransferLine_Internal."Unit of Measure Code";
        TempEOS089WMSCustomActLine."Outstanding Quantity" := TransferLine_Internal."Outstanding Quantity";
        TempEOS089WMSCustomActLine."Qty. per Unit of Measure" := TransferLine_Internal."Qty. per Unit of Measure";
        TempEOS089WMSCustomActLine."Outstanding Qty. (Base)" := TransferLine_Internal."Outstanding Qty. (Base)";
        TempEOS089WMSCustomActLine."Scan Document No." := '';
        TempEOS089WMSCustomActLine."Free Text 1" := '';
        TempEOS089WMSCustomActLine."Free Text 2" := '';
        TempEOS089WMSCustomActLine."Free Text 3" := '';
        TempEOS089WMSCustomActLine."Free Text 4" := '';
        TempEOS089WMSCustomActLine."Free Text 5" := '';
        TempEOS089WMSCustomActLine."Free Text 6" := '';
        TempEOS089WMSCustomActLine."Free Text 7" := '';
        TempEOS089WMSCustomActLine."Free Text 8" := '';
        TempEOS089WMSCustomActLine."Free Text 9" := '';
        TempEOS089WMSCustomActLine."Free Text 10" := '';
        TempEOS089WMSCustomActLine.Insert(false, true);
    end;
}
