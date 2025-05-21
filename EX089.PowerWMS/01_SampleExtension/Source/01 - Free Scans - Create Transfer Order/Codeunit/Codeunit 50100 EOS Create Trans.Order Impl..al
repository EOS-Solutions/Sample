codeunit 50100 "EOS Create Trans. Order Impl." implements "EOS089 WMS Activity Interface V5"
{
    Permissions = TableData "EOS089 WMS Custom Act. Header" = im, TableData "EOS089 WMS Custom Act. Line" = im;

    #region InterfaceSettings
    // Change Source Records and Activity Information according to Interface Type
    var
        EOS089WMSCustomActHeader_Internal: Record "EOS089 WMS Custom Act. Header";
        EOS089WMSCustomActLine_Internal: Record "EOS089 WMS Custom Act. Line";
        ReturnValues: JsonObject;   // Don't touch!

    procedure IsActivity(): Boolean
    begin
        exit(true); // Don't touch!
    end;

    procedure IsAllowed(): Boolean
    begin
        exit(true); // Don't touch!
    end;

    procedure GetNotAllowedReason(): Text
    var
        EOS089WMSManagement: Codeunit "EOS089 WMS Management";
    begin
        // Don't touch!
        if not EOS089WMSManagement.IsPowerWMSAllowed(false) then
            exit(EOS089WMSManagement.GetMissingSubscriptionErrorText());
    end;

    procedure ActivityVisibility(): Enum "EOS089 WMS Activity Visibility"
    begin
        exit(Enum::"EOS089 WMS Activity Visibility"::PowerWMS); // Don't touch!
    end;

    procedure ActivityCategory(): Enum "EOS089 WMS Activity Category";
    begin
        exit(Enum::"EOS089 WMS Activity Category"::Shipment);   // Activity Category
    end;

    procedure ActivityGroup(): Enum "EOS089 WMS Activity Group";
    begin
        exit(Enum::"EOS089 WMS Activity Group"::"Custom");   // Activity Group (PowerApp Menu)
    end;

    local procedure ActivityType(): Enum "EOS089 WMS Activity Type"
    begin
        exit(Enum::"EOS089 WMS Activity Type"::EOSCreateTransferOrder);  // Change with the corresponding "Activity Type" value
    end;

    local procedure SourceTable1(): Integer;
    begin
        exit(Database::"EOS089 WMS Custom Act. Header");    // Don't touch!
    end;

    local procedure SourceTable2(): Integer;
    begin
        exit(Database::"EOS089 WMS Custom Act. Line");  // Don't touch!
    end;

    local procedure SourceTableDescription(): Text
    begin
        exit(EOS089WMSCustomActHeader_Internal.TableCaption())  // Don't touch!
    end;

    local procedure GetPostedSourceMessage(PostedSourceNo: Text; SourceId: Text)
    var
        EOS089WMSReturnValuesMgmt: Codeunit "EOS089 WMS Return Values Mgmt.";
        SourcePostedLbl: Label 'Transfer Order No. %1 created successfully', Comment = '%1: Transfer Order No.';    // Change message text
    begin
        Clear(EOS089WMSReturnValuesMgmt);
        EOS089WMSReturnValuesMgmt.PrepareReturnValues();
        EOS089WMSReturnValuesMgmt.SetMessage(StrSubstNo(SourcePostedLbl, SourceId));
        EOS089WMSReturnValuesMgmt.SetResult(Enum::"EOS089 WMS Activity Result"::Completed);
        EOS089WMSReturnValuesMgmt.SetPostedDocumentNo(CopyStr(PostedSourceNo, 1, 20));
        EOS089WMSReturnValuesMgmt.SetActionGoTo(Enum::"EOS089 WMS Action Go To"::List);
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
        exit(true);     // Change for disable custom fields on header list
    end;

    local procedure FieldListEnabled2(): Boolean
    begin
        exit(true);     // Change for disable custom fields on line list
    end;

    local procedure FieldDetailsEnabled1(): Boolean
    begin
        exit(true);     // Change for disable custom fields on header details
    end;

    local procedure FieldDetailsEnabled2(): Boolean
    begin
        exit(true);     // Change for disable custom fields on line details
    end;
    #endregion

    procedure InitActivity(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        EOS089WMSUserActivityMgmt: Codeunit "EOS089 WMS User Activity Mgmt.";
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        // Change at your own risk!
        InitActivityFields();

        EOS089WMSUserActivity.Category := ActivityCategory();
        EOS089WMSUserActivity.Group := ActivityGroup();
        EOS089WMSUserActivity."Custom Type" := Enum::"EOS089 WMS Act. Custom Type"::FreeScans;

        EOS089WMSUserActivity."Apply User Id Filter" := false;
        EOS089WMSUserActivity."Allow Blank User Id" := true;
        EOS089WMSUserActivity."Allow All Locations" := false;
        EOS089WMSUserActivity."Allow All Inv. Batches" := false;
        EOS089WMSUserActivity."Allow All Jnl. Batches" := false;
        EOS089WMSUserActivity."Allow All Reclass. Batches" := false;
        EOS089WMSUserActivity."Allow Scan Edit" := false;
        EOS089WMSUserActivity."Scan Mode" := "EOS089 WMS Scan Mode"::Fast;
        EOS089WMSUserActivity."Allow New Record" := true;

        EOS089WMSUserActivity.CalcFields("Linked User Id", "Warehouse Employee");

        LocationFilter := EOS089WMSUserActivityMgmt.BuildLocationFilterForActivity(EOS089WMSUserActivity);

        EOS089WMSUserActivity."Enable List Fields 1" := FieldListEnabled1();
        EOS089WMSUserActivity."Enable List Fields 2" := FieldListEnabled2();
        EOS089WMSUserActivity."Enable Detail Fields 1" := FieldDetailsEnabled1();
        EOS089WMSUserActivity."Enable Detail Fields 2" := FieldDetailsEnabled2();

        // View 1
        EOS089WMSUserActivity."Table Id 1" := SourceTable1();
        EOS089WMSUserActivity."Key No. 1" := 1;
        EOS089WMSUserActivity."Key Sort 1" := EOS089WMSUserActivity."Key Sort 1"::Asc;

        EOS089WMSCustomActHeader_Internal.Reset();

        SetDefaultFilters1(EOS089WMSUserActivity);

        PageFilterBuilder.AddTable(EOS089WMSCustomActHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(EOS089WMSCustomActHeader_Internal.TableCaption(), EOS089WMSCustomActHeader_Internal.GetView());
        CurrentView := PageFilterBuilder.GetView(EOS089WMSCustomActHeader_Internal.TableCaption(), false);
        EOS089WMSUserActivity.SetView1(CurrentView);

        EOS089WMSUserActivity.SetLocationFilter1(LocationFilter);

        // View 2
        EOS089WMSUserActivity."Table Id 2" := SourceTable2();
        EOS089WMSUserActivity."Key No. 2" := 1;
        EOS089WMSUserActivity."Key Sort 2" := EOS089WMSUserActivity."Key Sort 2"::Asc;

        EOS089WMSCustomActLine_Internal.Reset();

        SetDefaultFilters2(EOS089WMSUserActivity);

        PageFilterBuilder.AddTable(EOS089WMSCustomActLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(EOS089WMSCustomActLine_Internal.TableCaption(), EOS089WMSCustomActLine_Internal.GetView());
        CurrentView := PageFilterBuilder.GetView(EOS089WMSCustomActLine_Internal.TableCaption(), false);
        EOS089WMSUserActivity.SetView2(CurrentView);

        EOS089WMSUserActivity.SetLocationFilter2(LocationFilter);
    end;

    procedure EnableActivity(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    begin
        // Don't touch!
        if not IsAllowed() then
            Error(GetNotAllowedReason());
    end;

    procedure ManageUserActivityCardOptions(var Options: JsonObject)
    begin
        // These settings are general, and must be modified according to desidered behavior (e.g. location filters)
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
        //Options.Add('showScanMode', true);
        Options.Add('showFocusOnQuantity', true);
        Options.Add('showScannerSetup', true);
        Options.Add('showQuantityManagement', true);
        Options.Add('showBlockQuantityEdit', true);
        Options.Add('showAllowNewRecord', true);

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
        //Options.Add('editScanMode', true);
        Options.Add('editFocusOnQuantity', true);
        Options.Add('editScannerSetup', true);
        Options.Add('editQuantityManagement', true);
        Options.Add('editBlockQuantityEdit', true);
        Options.Add('editAllowNewRecord', true);
    end;

    procedure GetActivityView1(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; HumanReadable: Boolean): Text
    var
        PageFilterBuilder: FilterPageBuilder;
        ActivityView: Text;
    begin
        PageFilterBuilder.AddTable(EOS089WMSCustomActHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(EOS089WMSCustomActHeader_Internal.TableCaption(), EOS089WMSUserActivity.GetView1(true));
        ActivityView := PageFilterBuilder.GetView(EOS089WMSCustomActHeader_Internal.TableCaption(), HumanReadable);
        exit(ActivityView);
    end;

    procedure SetActivityView1(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        PageFilterBuilder: FilterPageBuilder;
        CurrentView: Text;
    begin
        PageFilterBuilder.AddTable(EOS089WMSCustomActHeader_Internal.TableCaption(), SourceTable1());
        CurrentView := EOS089WMSUserActivity.GetView1(true);
        if CurrentView <> '' then
            PageFilterBuilder.SetView(EOS089WMSCustomActHeader_Internal.TableCaption(), CurrentView);

        if PageFilterBuilder.RunModal() then begin
            CurrentView := PageFilterBuilder.GetView(EOS089WMSCustomActHeader_Internal.TableCaption(), false);
            EOS089WMSUserActivity.SetView1(CurrentView);
            UpdateActivityView1(EOS089WMSUserActivity);
            EOS089WMSUserActivity.Modify(true);
        end;
    end;

    procedure UpdateActivityView1(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        LocationFilter := '';

        // First, apply current view
        EOS089WMSCustomActHeader_Internal.SetView(EOS089WMSUserActivity.GetView1(true));

        // Then, reset default filters
        SetDefaultFilters1(EOS089WMSUserActivity);

        // Finally, save updated view
        PageFilterBuilder.AddTable(EOS089WMSCustomActHeader_Internal.TableCaption(), SourceTable1());
        PageFilterBuilder.SetView(EOS089WMSCustomActHeader_Internal.TableCaption(), EOS089WMSCustomActHeader_Internal.GetView());

        CurrentView := PageFilterBuilder.GetView(EOS089WMSCustomActHeader_Internal.TableCaption(), false);
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
        exit(EOS089WMSCustomActHeader_Internal.TableCaption());
    end;

    procedure GetActivityView2(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity"; HumanReadable: Boolean): Text
    var
        PageFilterBuilder: FilterPageBuilder;
        ActivityView: Text;
    begin
        PageFilterBuilder.AddTable(EOS089WMSCustomActLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(EOS089WMSCustomActLine_Internal.TableCaption(), EOS089WMSUserActivity.GetView2(true));
        ActivityView := PageFilterBuilder.GetView(EOS089WMSCustomActLine_Internal.TableCaption(), HumanReadable);
        exit(ActivityView);
    end;

    procedure SetActivityView2(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        PageFilterBuilder: FilterPageBuilder;
        CurrentView: Text;
    begin
        PageFilterBuilder.AddTable(EOS089WMSCustomActLine_Internal.TableCaption(), SourceTable2());
        CurrentView := EOS089WMSUserActivity.GetView2(true);
        if CurrentView <> '' then
            PageFilterBuilder.SetView(EOS089WMSCustomActLine_Internal.TableCaption(), CurrentView);

        if PageFilterBuilder.RunModal() then begin
            CurrentView := PageFilterBuilder.GetView(EOS089WMSCustomActLine_Internal.TableCaption(), false);
            EOS089WMSUserActivity.SetView2(CurrentView);
            UpdateActivityView2(EOS089WMSUserActivity);
            EOS089WMSUserActivity.Modify(true);
        end;
    end;

    procedure UpdateActivityView2(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        PageFilterBuilder: FilterPageBuilder;
        LocationFilter: Text;
        CurrentView: Text;
    begin
        LocationFilter := '';

        // First, apply current view
        EOS089WMSCustomActLine_Internal.SetView(EOS089WMSUserActivity.GetView2(true));

        // Then, reset default filters
        SetDefaultFilters2(EOS089WMSUserActivity);

        // Finally, save updated view
        PageFilterBuilder.AddTable(EOS089WMSCustomActLine_Internal.TableCaption(), SourceTable2());
        PageFilterBuilder.SetView(EOS089WMSCustomActLine_Internal.TableCaption(), EOS089WMSCustomActLine_Internal.GetView());

        CurrentView := PageFilterBuilder.GetView(EOS089WMSCustomActLine_Internal.TableCaption(), false);
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
        exit(EOS089WMSCustomActLine_Internal.TableCaption());
    end;

    procedure CountActivityRecords(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity"): Integer
    var
        Counter: Integer;
    begin
        if not EOS089WMSUserActivity."Show Record Counter" then
            exit(0);

        // Change source table to count
        EOS089WMSCustomActHeader_Internal.SetView(EOS089WMSUserActivity.GetView1(true));
        Counter := EOS089WMSCustomActHeader_Internal.Count();
        exit(Counter);
    end;

    procedure ShowActivityRecords(var EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    begin
        if not EOS089WMSUserActivity."Show Record Counter" then
            exit;

        // Change Page to run as source list
        EOS089WMSCustomActHeader_Internal.SetView(EOS089WMSUserActivity.GetView1(true));
        Page.RunModal(Page::"EOS089 WMS Custom Activities", EOS089WMSCustomActHeader_Internal);
    end;

    procedure GetSourceDetails() Details: JsonObject
    begin
        Clear(Details);

        // Change for manage document or batch entity
        Details.Add('sourceTableDesc', SourceTableDescription());
        Details.Add('isDocument', true);
        Details.Add('isBatch', false);
    end;

    procedure GetActivityFieldsSettings(var TableNos: List of [Integer]; var ListEnabled: List of [Boolean]; var DetailsEnabled: List of [Boolean])
    begin
        // Don't touch!
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
        EOS089WMSMiscHelper: Codeunit "EOS089 WMS Misc. Helper";
        LocationLbl: Label 'LOCATIONS', Locked = true;
        BinLbl: Label 'BINS', Locked = true;
    begin
        // Add custom fields here programmatically

        if not Fields.IsTemporary() then
            exit;
        Fields.Reset();
        Fields.DeleteAll();

        case TableNo of
            SourceTable1():
                case ActivityFieldClass of
                    Enum::"EOS089 WMS Act. Field Class"::List:
                        begin
                            if not FieldListEnabled1() then
                                exit;

                            EOS089WMSMiscHelper.ActivityFields_Init();
                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("No."), Fields);
                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("Location Code"), Fields);
                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("Bin Code"), Fields);
                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("EOS To Location Code"), Fields);
                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("EOS To Bin Code"), Fields);
                        end;
                    Enum::"EOS089 WMS Act. Field Class"::Detail:
                        begin
                            if not FieldDetailsEnabled1() then
                                exit;

                            EOS089WMSMiscHelper.ActivityFields_Init();
                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("Location Code"), Fields);
                            Fields."Field Editable" := true;
                            Fields."Field Mandatory" := true;
                            Fields."Validate Field" := true;
                            Fields."LookUp List Code" := LocationLbl;
                            Fields.Modify();

                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("Bin Code"), Fields);
                            Fields."Field Editable" := true;
                            Fields."Field Mandatory" := true;
                            Fields."Validate Field" := true;
                            Fields."LookUp List Code" := BinLbl;
                            Fields.Modify();

                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("EOS To Location Code"), Fields);
                            Fields."Field Editable" := true;
                            Fields."Field Mandatory" := true;
                            Fields."Validate Field" := true;
                            Fields."LookUp List Code" := LocationLbl;
                            Fields.Modify();

                            EOS089WMSMiscHelper.ActivityFields_Insert(EOS089WMSCustomActHeader_Internal.FieldNo("EOS To Bin Code"), Fields);
                            Fields."Field Editable" := true;
                            Fields."Field Mandatory" := true;
                            Fields."Validate Field" := true;
                            Fields."LookUp List Code" := BinLbl;
                            Fields.Modify();
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
        // Don't touch!
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
        // Don't touch!
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
    end;

    procedure SetFiltersOn(var RecordRef: RecordRef): Boolean
    begin
        // Don't touch!
        case RecordRef.Number of
            SourceTable1():
                begin
                    RecordRef.SetTable(EOS089WMSCustomActHeader_Internal);
                    if not SetFiltersOnHeader() then
                        exit(false);
                    RecordRef.GetTable(EOS089WMSCustomActHeader_Internal);
                    exit(true)
                end;
            SourceTable2():
                begin
                    RecordRef.SetTable(EOS089WMSCustomActLine_Internal);
                    if not SetFiltersOnLines() then
                        exit(false);
                    RecordRef.GetTable(EOS089WMSCustomActLine_Internal);
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
        // Don't touch!
        // Modify
        Clear(EOS089WMSActivityTaskMgmt);
        EOS089WMSActivityTaskMgmt.ManageActivityModifyScans(EOS089WMSActivityEntry, ScanId);

        // Delete
        Clear(EOS089WMSActivityTaskMgmt);
        EOS089WMSActivityTaskMgmt.ManageActivityDeleteScans(EOS089WMSActivityEntry, ScanId);

        // Insert
        Clear(EOS089WMSActivityTaskMgmt);
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
        EOS089WMSRegCusActHdr: Record "EOS089 WMS Reg. Cus. Act. Hdr.";
        EOS089WMSCustomActPost: Codeunit "EOS089 WMS Custom Act. - Post";
    begin
        // Manage here the output of the custom activity scans
        EOS089WMSCustomActHeader_Internal.Get(ActivityType(), EOS089WMSActivityEntry."Source ID");

        EOS089WMSCustomActPost.SetEmployee(EOS089WMSActivityEntry."Employee No.");
        EOS089WMSCustomActPost.Run(EOS089WMSCustomActHeader_Internal);

        EOS089WMSRegCusActHdr := EOS089WMSCustomActPost.GetRegisteredDocument();

        PostedDocumentNo := EOS089WMSRegCusActHdr."No.";

        GetPostedSourceMessage(PostedDocumentNo, EOS089WMSRegCusActHdr."Linked Source Id");
    end;

    procedure DeleteSourceScans(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"): Boolean
    begin
    end;

    procedure ResetSource(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"): Boolean
    begin
        // Don't touch!
        EOS089WMSCustomActLine_Internal.Reset();
        EOS089WMSCustomActLine_Internal.SetRange("Activity Type", ActivityType());
        EOS089WMSCustomActLine_Internal.SetRange("Document No.", EOS089WMSActivityEntry."Source ID");
        EOS089WMSCustomActLine_Internal.DeleteAll(true);

        GetResetSourceMessage(EOS089WMSActivityEntry."Source ID");
    end;

    procedure GetRecordMapping(TableId: Integer; var TempEOS089WMSSourceInformation: Record "EOS089 WMS Source Information" temporary)
    begin
        // Don't touch!
        TempEOS089WMSSourceInformation.Init();
        TempEOS089WMSSourceInformation."Source Type" := SourceTable2();
        TempEOS089WMSSourceInformation."Source Subtype" := Enum::"EOS089 WMS Source Subtype"::"0";

        TempEOS089WMSSourceInformation."Source Id Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Document No.");
        TempEOS089WMSSourceInformation."Source Ref. No. Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Line No.");
        TempEOS089WMSSourceInformation."Outst. Qty. (Base) Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Outstanding Qty. (Base)");
        TempEOS089WMSSourceInformation."Qty. To Man. (Base) Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Qty. to Handle (Base)");
        TempEOS089WMSSourceInformation."Outstanding Quantity Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Outstanding Quantity");
        TempEOS089WMSSourceInformation."Qty. To Manage Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Qty. to Handle");
        TempEOS089WMSSourceInformation."Qty. per UoM Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Qty. per Unit of Measure");
        TempEOS089WMSSourceInformation."Qty.Rndg.Prec.(Base) Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Qty. Rounding Precision (Base)");
        TempEOS089WMSSourceInformation."Qty. Rounding Prec. Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Qty. Rounding Precision");
        TempEOS089WMSSourceInformation."Location Code Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Location Code");
        TempEOS089WMSSourceInformation."Bin Code Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Bin Code");
        TempEOS089WMSSourceInformation."Description Field No." := EOS089WMSCustomActLine_Internal.FieldNo(Description);
        TempEOS089WMSSourceInformation."Description 2 Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Description 2");
        TempEOS089WMSSourceInformation."No. Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Item No.");
        TempEOS089WMSSourceInformation."Unit Of Measure Code Field No." := EOS089WMSCustomActLine_Internal.FieldNo("Unit of Measure Code");
    end;

    procedure GetRecordRefForScanManagement(EOS089WMSActScanDetail: Record "EOS089 WMS Act. Scan Detail"; var RecordRef: RecordRef): Boolean
    var
        EOS089WMSCustomActLine: Record "EOS089 WMS Custom Act. Line";
        EOS089WMSCustomActMgmt: Codeunit "EOS089 WMS Custom Act. Mgmt.";
        LineFound, AllowInsert, AllowModify : Boolean;
    begin
        // Manage search and creation of a custom activity line to use as a source for incoming scan
        EOS089WMSActScanDetail.TestField("Item No.");

        EOS089WMSCustomActLine_Internal.Reset();
        EOS089WMSCustomActLine_Internal.SetRange("Activity Type", ActivityType());
        EOS089WMSCustomActLine_Internal.SetRange("Document No.", EOS089WMSActScanDetail."Source ID");
        EOS089WMSCustomActLine_Internal.SetFilter("Employee No. Filter", '%1', EOS089WMSActScanDetail."Employee No.");
        RecordRef.Open(SourceTable2());
        RecordRef.GetTable(EOS089WMSCustomActLine_Internal);
        if not SetFiltersOnLines() then begin
            RecordRef.Close();
            exit(false);
        end;
        RecordRef.SetTable(EOS089WMSCustomActLine_Internal);
        RecordRef.Close();

        EOS089WMSCustomActHeader_Internal.Get(ActivityType(), EOS089WMSActScanDetail."Source ID");

        LineFound := EOS089WMSCustomActMgmt.SearchCustomActivityLine(ActivityType(), EOS089WMSCustomActHeader_Internal, EOS089WMSActScanDetail, EOS089WMSCustomActLine, AllowInsert, AllowModify);
        if not LineFound and AllowInsert then
            EOS089WMSCustomActMgmt.InsertCustomActivityLine(ActivityType(), EOS089WMSCustomActHeader_Internal, EOS089WMSActScanDetail, EOS089WMSCustomActLine);
        if LineFound and AllowModify then
            EOS089WMSCustomActMgmt.ModifyCustomActivityLine(ActivityType(), EOS089WMSCustomActHeader_Internal, EOS089WMSActScanDetail, EOS089WMSCustomActLine);

        // Exit if line not found and not allowed to insert or line found and not allowed to modify
        if (not LineFound and not AllowInsert) or (LineFound and not AllowModify) then
            exit(false);

        EOS089WMSCustomActLine_Internal.Reset();
        EOS089WMSCustomActLine_Internal.SetRange("Activity Type", EOS089WMSCustomActLine."Activity Type");
        EOS089WMSCustomActLine_Internal.SetRange("Document No.", EOS089WMSCustomActLine."Document No.");
        EOS089WMSCustomActLine_Internal.SetRange("Line No.", EOS089WMSCustomActLine."Line No.");

        RecordRef.Open(SourceTable2());
        RecordRef.SetView(EOS089WMSCustomActLine_Internal.GetView());

        if RecordRef.IsEmpty() then begin
            RecordRef.Close();
            exit(false);
        end else
            exit(true);
    end;

    procedure ShowSourceEntity(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry")
    var
        EOS089WMSCustomActCard: Page "EOS089 WMS Custom Act. Card";
    begin
        // Change here the page to run for the source entity
        EOS089WMSCustomActHeader_Internal.Get(EOS089WMSActivityEntry."Activity Type", EOS089WMSActivityEntry."Source ID");
        EOS089WMSCustomActCard.SetRecord(EOS089WMSCustomActHeader_Internal);
        EOS089WMSCustomActCard.RunModal();
    end;

    procedure ShowPostedEntity(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry")
    begin
    end;

    procedure GetActivityTrackingSettings(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; EOS089WMSActivityScan: Record "EOS089 WMS Activity Scan"; var ItemLedgerEntryType: Enum "Item Ledger Entry Type"; var IsInbound: Boolean)
    begin
        ItemLedgerEntryType := ItemLedgerEntryType::Transfer;
        IsInbound := false;
    end;

    procedure GetReservationEntries(var EOS089WMSReservationEntry: Record "EOS089 WMS Reservation Entry" temporary): Boolean
    begin
    end;

    procedure GetActionReturnValues(): JsonObject
    begin
        exit(ReturnValues);
    end;

    procedure OmniSearch(EOS089WMSActivityEntry: Record "EOS089 WMS Activity Entry"; SearchValue: Text; var JsonObject: JsonObject): Boolean
    begin
        // Change here the OmniSearch output
        if StrLen(SearchValue) > MaxStrLen(EOS089WMSCustomActHeader_Internal."No.") then
            exit(false);

        EOS089WMSCustomActHeader_Internal.Reset();
        EOS089WMSCustomActHeader_Internal.SetAutoCalcFields("Pending Activities");
        EOS089WMSCustomActHeader_Internal.SetLoadFields("Pending Activities");
        EOS089WMSCustomActHeader_Internal.SetRange("No.", SearchValue);
        SetFiltersOnHeader();
        if EOS089WMSCustomActHeader_Internal.Count() = 1 then
            if EOS089WMSCustomActHeader_Internal.FindFirst() then begin
                JsonObject.Add('activity', Format(ActivityType()));
                JsonObject.Add('activityInt', ActivityType().AsInteger());
                JsonObject.Add('sourceId', EOS089WMSCustomActHeader_Internal."No.");
                JsonObject.Add('wmsPendingActivities', EOS089WMSCustomActHeader_Internal."Pending Activities");
                exit(true);
            end;

        exit(false);
    end;

    local procedure InitActivityFields()
    var
        EOS089WMSActivityField: Record "EOS089 WMS Activity Field";
        EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
    begin
        // Don't touch!
        EOS089WMSActivityField.Reset();
        EOS089WMSActivityField.SetRange(Activity, ActivityType());
        if EOS089WMSActivityField.IsEmpty() then
            EOS089WMSActivityManagement.InitActivityFields(ActivityType());
    end;

    local procedure SetDefaultFilters1(EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        EOS089WMSActivityManagement: Codeunit "EOS089 WMS Activity Management";
        RecordRef: RecordRef;
    begin
        EOS089WMSCustomActHeader_Internal.Reset();
        EOS089WMSCustomActHeader_Internal.SetRange("Activity Type", ActivityType());

        if EOS089WMSUserActivity."Apply User Id Filter" then begin
            EOS089WMSUserActivity.CalcFields("Linked User Id");
            EOS089WMSUserActivity.TestField("Linked User Id");
            if EOS089WMSUserActivity."Linked User Id" <> '' then begin
                if EOS089WMSUserActivity."Allow Blank User Id" then
                    EOS089WMSCustomActHeader_Internal.SetFilter("Assigned User ID", '%1|%2', '', EOS089WMSUserActivity."Linked User Id")
                else
                    EOS089WMSCustomActHeader_Internal.SetRange("Assigned User ID", EOS089WMSUserActivity."Linked User Id")
            end else
                EOS089WMSCustomActHeader_Internal.SetRange("Assigned User ID", EOS089WMSActivityManagement.GetInvalidUserIdFilter());
        end else
            if not EOS089WMSUserActivity."Allow Blank User Id" then
                EOS089WMSCustomActHeader_Internal.SetFilter("Assigned User ID", '<>%1', '');

        RecordRef.Open(SourceTable1());
        RecordRef.GetTable(EOS089WMSCustomActHeader_Internal);
        RecordRef.CurrentKeyIndex(EOS089WMSUserActivity."Key No. 1");
        RecordRef.Ascending(EOS089WMSUserActivity."Key Sort 1" = EOS089WMSUserActivity."Key Sort 1"::Asc);
        RecordRef.SetTable(EOS089WMSCustomActHeader_Internal);
        RecordRef.Close();
    end;

    local procedure SetDefaultFilters2(EOS089WMSUserActivity: Record "EOS089 WMS User Activity")
    var
        RecordRef: RecordRef;
    begin
        EOS089WMSCustomActLine_Internal.Reset();
        EOS089WMSCustomActLine_Internal.SetRange("Activity Type", ActivityType());

        RecordRef.Open(SourceTable2());
        RecordRef.GetTable(EOS089WMSCustomActLine_Internal);
        RecordRef.CurrentKeyIndex(EOS089WMSUserActivity."Key No. 2");
        RecordRef.Ascending(EOS089WMSUserActivity."Key Sort 2" = EOS089WMSUserActivity."Key Sort 2"::Asc);
        RecordRef.SetTable(EOS089WMSCustomActLine_Internal);
        RecordRef.Close();
    end;

    local procedure SetFiltersOnHeader(): Boolean
    var
        EOS089WMSUserActivity: Record "EOS089 WMS User Activity";
        EmployeeNo: Code[20];
        SystemIdFilter: Guid;
        ApplySystemIdFilter: Boolean;
        NoFilters: Text;
    begin
        EmployeeNo := CopyStr(EOS089WMSCustomActHeader_Internal.GetFilter("Employee No. Filter"), 1, MaxStrLen(EmployeeNo));
        ApplySystemIdFilter := EOS089WMSCustomActHeader_Internal.GetFilter("SystemId") <> '';
        if ApplySystemIdFilter then
            Evaluate(SystemIdFilter, EOS089WMSCustomActHeader_Internal.GetFilter("SystemId"));

        if EmployeeNo = '' then
            exit(false);

        EOS089WMSUserActivity.SetAutoCalcFields("Record View 1");
        EOS089WMSUserActivity.SetloadFields("Use Textual View 1", "Record View 1 Text", "Record View 1", SystemId);
        if not EOS089WMSUserActivity.Get(EmployeeNo, ActivityType()) then
            exit(false);

        NoFilters := EOS089WMSCustomActHeader_Internal.GetFilter("No.");

        EOS089WMSCustomActHeader_Internal.Reset();
        EOS089WMSCustomActHeader_Internal.SetView(EOS089WMSUserActivity.GetView1(false));
        if NoFilters <> '' then
            EOS089WMSCustomActHeader_Internal.SetFilter("No.", NoFilters);
        if ApplySystemIdFilter then
            EOS089WMSCustomActHeader_Internal.SetFilter("SystemId", SystemIdFilter);

        EOS089WMSCustomActHeader_Internal.SetRange("Employee No. Filter", EmployeeNo);
        EOS089WMSCustomActHeader_Internal.SetRange("Activity Type Filter", ActivityType());

        exit(true);
    end;

    local procedure SetFiltersOnLines(): Boolean
    var
        EOS089WMSUserActivity: Record "EOS089 WMS User Activity";
        DocumentNo, EmployeeNo : Code[20];
    begin
        DocumentNo := CopyStr(EOS089WMSCustomActLine_Internal.GetFilter("Document No."), 1, MaxStrLen(DocumentNo));
        EmployeeNo := CopyStr(EOS089WMSCustomActLine_Internal.GetFilter("Employee No. Filter"), 1, MaxStrLen(EmployeeNo));
        if EmployeeNo = '' then
            exit(false);

        EOS089WMSUserActivity.SetAutoCalcFields("Record View 2");
        EOS089WMSUserActivity.SetloadFields("Use Textual View 2", "Record View 2 Text", "Record View 2", SystemId);
        if not EOS089WMSUserActivity.Get(EmployeeNo, ActivityType()) then
            exit(false);

        EOS089WMSCustomActLine_Internal.Reset();
        EOS089WMSCustomActLine_Internal.SetView(EOS089WMSUserActivity.GetView2(false));
        EOS089WMSCustomActLine_Internal.SetFilter("Document No.", DocumentNo);

        EOS089WMSCustomActLine_Internal.SetRange("Employee No. Filter", EmployeeNo);
        EOS089WMSCustomActLine_Internal.SetRange("Activity Type Filter", ActivityType());

        exit(true);
    end;
}
