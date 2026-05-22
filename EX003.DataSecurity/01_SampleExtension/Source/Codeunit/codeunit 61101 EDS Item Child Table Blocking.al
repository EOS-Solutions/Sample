codeunit 50100 "EDS Item Child Table Blocking"
{
    // Example: Extend EDS child table blocking to support the Item table.
    // When the Item record has "Changes disabled" or "Deletion disabled" set on its EDS status,
    // modifications/deletions on the <child table> will be blocked accordingly.

    #region Child Table Event Subscribers

    // <child table> - Block modifications
    [EventSubscriber(ObjectType::Table, Database::<child table>, 'OnBeforeModifyEvent', '', true, true)]
    local procedure "<child table>_OnBeforeModifyEvent"
    (
        var Rec: Record <child table>;
        var xRec: Record <child table>;
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Item: Record Item;
        BlockedRecordMgt: Codeunit "EOS003 Blocked Record Mgt.";
        Skip: Boolean;
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        OnBeforeCheckEdit<child table>(Rec, Skip);
        if Skip then
            exit;

        if Item.Get(Rec."Item No.") then begin
            RecRef.Get(Item.RecordId);
            BlockedRecordMgt.CheckEditable(RecRef, Database::<child table>);
        end;
    end;

    // <child table> - Block deletions
    [EventSubscriber(ObjectType::Table, Database::<child table>, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure "<child table>_OnBeforeDeleteEvent"
    (
        var Rec: Record <child table>;
        RunTrigger: Boolean
    )
    var
        RecRef: RecordRef;
        Item: Record Item;
        BlockedRecordMgt: Codeunit "EOS003 Blocked Record Mgt.";
        Skip: Boolean;
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;

        OnBeforeCheckDelete<child table>(Rec, Skip);
        if Skip then
            exit;

        if Item.Get(Rec."Item No.") then begin
            RecRef.Get(Item.RecordId);
            BlockedRecordMgt.CheckDeletable(RecRef, Database::<child table>);
        end;
    end;

    #endregion

    #region EDS Setup Integration

    // Register Item as a table that supports child table blocking.
    // This makes the "Child Tables" action work (show records) for Item table statuses.
    [EventSubscriber(ObjectType::Table, Database::"EOS DS Table Status", 'OnBeforeFilterTableForChildTableBlocking', '', false, false)]
    local procedure OnBeforeFilterTableForChildTableBlocking(var TableIdList: List of [Integer])
    begin
        if not TableIdList.Contains(Database::Item) then
            TableIdList.Add(Database::Item);
    end;

    // Add the <child table> table to the child table setup list when opening "Child Tables" for an Item status.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS DS Insert Def. Data Mgmt", 'OnAfterGenerateChildTableSetup', '', false, false)]
    local procedure OnAfterGenerateChildTableSetup(var TempChildTableSetup: Record "EOS003 Child Table Setup" temporary; TableStatus: Record "EOS DS Table Status")
    var
        InsertDefDataMgmt: Codeunit "EOS DS Insert Def. Data Mgmt";
    begin
        if TableStatus."Table ID" <> Database::Item then
            exit;

        InsertDefDataMgmt.InsertChildTableSetup(TempChildTableSetup, TableStatus, Database::<child table>);
    end;

    #endregion

    #region Extensibility Events

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckEdit<child table>(Rec: Record <child table>; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDelete<child table>(Rec: Record <child table>; var Skip: Boolean)
    begin
    end;

    #endregion
}
