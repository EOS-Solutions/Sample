codeunit 60001 "EOS Additional Data Migration"
{
    TableNo = "EOS JSON Import Buffer";
    trigger OnRun()
    begin
        EOSImportMgt.StartProgress(Rec);
        Overwrite := Rec.Overwrite;
        case Rec."Table Id" of
            18:
                Customer();
            23:
                Vendor();
            50000:
                AditionalTable();
        end;
    end;

    var
        EOSImportMgt: Codeunit "EOS JSON Import Helper";
        Overwrite: Boolean;

    procedure GetImportId(): Guid
    var
        modInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(modInfo);
        exit(modInfo.Id());
    end;

    procedure SetSender(var newSender: Codeunit "EOS JSON Import Helper")
    begin
        EOSImportMgt := newSender;
    end;

    local procedure AditionalTable()
    var
        recRef: RecordRef;
        runTrigger: Boolean;
    begin
        runTrigger := false;
        recRef.Open(Database::"EOS Additional Table");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recRef);
            EOSImportMgt.InsertData(recRef, Overwrite, runTrigger);
        end;
    end;

    local procedure Customer()
    var
        DbRec: Record Customer;
        recRef: RecordRef;
    begin
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1)) then begin
                    recRef.GetTable(DbRec);
                    AddValue(recRef, 50000, DbRec.FieldNo("EOS Additional Code"));
                    AddValue(recRef, 50001, DbRec.FieldNo("EOS Additional Description"));
                    AddValue(recRef, 50002, DbRec.FieldNo("EOS Additional Ref. No."));
                    if Overwrite then
                        DbRec.Modify();
                end;
            end;
    end;

    local procedure Vendor()
    var
        DbRec: Record Vendor;
        recRef: RecordRef;
    begin
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1)) then begin
                    recRef.GetTable(DbRec);
                    AddValue(recRef, 50000, DbRec.FieldNo("EOS Additional Code"));
                    AddValue(recRef, 50001, DbRec.FieldNo("EOS Additional Description"));
                    AddValue(recRef, 50002, DbRec.FieldNo("EOS Additional Ref. No."));
                    if Overwrite then
                        DbRec.Modify();
                end;
            end;
    end;
}