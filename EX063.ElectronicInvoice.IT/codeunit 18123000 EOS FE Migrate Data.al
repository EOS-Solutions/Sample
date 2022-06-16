codeunit 18123000 "EOS FE Migrate Data"
{
    TableNo = "EOS JSON Import Buffer";
    trigger OnRun()
    begin
        EOSImportMgt.StartProgress(Rec);
        DoOverwrite := Rec.Overwrite;// Rec.flag
        case Rec."Table Id" of
            18008094:
                EDocStatusLog();
            18008155:
                EDocRelDocs();
            18008409:
                Transliteration();
            18123007:
                OutbDoc();
            18123008:
                OutbDocLot();
            18123009:
                OutbDocNotification();
            18123011:
                InbDocLot();
            18123012:
                InbDoc();
            18123013:
                InbDocNotif();
            18123014:
                IXFELog();
            18123062:
                ErrorMessage();
            18123068:
                InbLog();
            18123069:
                InbLogDet();
            18123071:
                InbDocFile();
            18123080:
                InbDocHeader();
            18123081:
                InbDocLine();
            18123082:
                InbDocAttachment();
            18123083:
                InbDocLineDetail();
            18123090:
                InbDocPrevHeader();
            18123091:
                InbDocPrevLine();
            18004155:
                EDocRecipient();
            18:
                Customer();
            36:
                SalesHeader();
            38:
                PurchHeader();
            110:
                SalesShipHeader();
            112:
                SalesInvHeader();
            114:
                SalesCmemoHeader();
            122:
                PurchInvHeader();
            124:
                PurchCMemoHeader();
            308:
                NoSerie();
            325:
                VatPostingSetup();
            5900:
                ServiceHeader();
            5990:
                ServiceShipHeader();
            5992:
                ServiceInvHeader();
            5994:
                ServiceCmemoHeader();
            18004293:
                OutbElectrDocSetup();
            18008156:
                OutbElectrDocSetupGroup();
            18008157:
                OutbEDocCustSetup();
            18123006:
                IXFESetup();
            18123063:
                InbEDocChecks();
            18123060:
                InbEDocSetup();
            18123064:
                InbEDocRating();
            18123065:
                InbEDocSetupGroup();
            18123066:
                InbEDocVendorSetup();
            18123067:
                InbEDocUM();
            18123072:
                InbEDocCashTypeSetup();
            18004108:
                DutyStampSetup();
        end;
    end;

    var
        EOSImportMgt: Codeunit "EOS JSON Import Helper";
        DoOverwrite: Boolean;

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

    local procedure EDocStatusLog()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Outb. EDoc. Status Log");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure EDocRelDocs()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Outb. EDoc. Related Docs.");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure Transliteration()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Transliteration");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure OutbDoc()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Outb. Document");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure OutbDocLot()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Outb. Document Lot");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDoc()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Inb. Document");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocLot()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Inb. Document Lot");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocNotif()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Inb. Doc. Notif.");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure IXFELog()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Log");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbLog()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Log");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbLogDet()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Log Detailed");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocFile()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. File");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocHeader()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Header");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocLine()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Line");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocAttachment()
    var
        DbRec: Record "EOS Inb. EDoc. Attachments";
        DbRec2: Record "EOS Inb. EDoc. Attachments";
        os: OutStream;
        tmpText: Text;
    begin
        with EOSImportMgt do
            while EOSImportMgt.ReadNext() do begin
                DbRec.Init();
                DbRec."EOS Entry No." := GetFieldValueAsInteger(1);
                DbRec."EOS Parent Entry No." := GetFieldValueAsInteger(5);
                DbRec."EOS File Name" := Copystr(GetFieldValueAsText(15), 1, MaxStrLen(DbRec."EOS File Name"));
                DbRec."EOS 2.5.1_NomeAttachment" := Copystr(GetFieldValueAsText(2510000), 1, MaxStrLen(DbRec."EOS 2.5.1_NomeAttachment"));
                DbRec."EOS 2.5.3_FormatoAttachment" := Copystr(GetFieldValueAsText(2530000), 1, MaxStrLen(DbRec."EOS 2.5.3_FormatoAttachment"));
                DbRec."EOS 2.5.4_DescrAttachment" := Copystr(GetFieldValueAsText(2540000), 1, MaxStrLen(DbRec."EOS 2.5.4_DescrAttachment"));
                Clear(os);
                Clear(tmpText);
                DbRec."EOS 2.5.5_Attachment".CreateOutStream(os);
                tmpText := GetFieldValueAsText(2550000);
                //tmpText := tmpText.Replace('\', '');
                os.WriteText(tmpText);
                if DbRec2.Get(DbRec.RecordId()) then begin
                    if DoOverwrite then
                        DbRec.Modify()
                end else
                    DbRec.Insert();

                if not DbRec.Insert() then
                    if DoOverwrite then
                        DbRec.Modify();
            end;

    end;

    local procedure InbDocLineDetail()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Line Detail");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure EDocRecipient()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Electr. Document Recipient");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocPrevHeader()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Preview Header");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbDocPrevLine()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Preview Line");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure OutbDocNotification()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Outb. Doc. Notif.");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure SalesShipHeader()
    var
        DbRec: Record "Sales Shipment Header";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        is: InStream;
        os: OutStream;
    begin
        /*
        Enabled	Field No.	Field Name	Data Type	Length	Description
         Yes	18004190	PA-E-Document XML	BLOB		TD29847-001
         Yes	18004191	PA-Electronic Document Sent	Boolean		TD29847-001
         Yes	18004192	PA-Electronic Document Filen.	Text	30	TD29847-001
         Yes	18004194	PA - Data Type	Option		TD31765-001
         Yes	18004195	PA - Reference No.	Code	20	TD31765-001
         Yes	18004196	PA - Reference Date	Date		TD31765-001
         Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
         Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
         No	18004199	Placeholder 18004199	Code	10	TDAG00919
         Yes	18004202	Electronic Document Format	Option		TDAG08043
         Yes	18004205	Electr. Doc. Related Docs.	Integer		TDAG27143
        */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);

                    AddValue(RecRef, 18004190, DbRec.FieldNo("EOS EDoc. XML File"));
                    AddValue(RecRef, 18004191, DbRec.FieldNo("EOS Elect. Doc. Created"));
                    AddValue(RecRef, 18004192, DbRec.FieldNo("EOS Elect. Doc. File Name"));
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));

                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure SalesInvHeader()
    var
        DbRec: Record "Sales Invoice Header";
        RecRef: RecordRef;
    begin
        /*
        Enabled	Field No.	Field Name	Data Type	Length	Description
         Yes	18004190	PA-E-Document XML	BLOB		TD29847-001
         Yes	18004191	PA-Electronic Document Sent	Boolean		TD29847-001
         Yes	18004192	PA-Electronic Document Filen.	Text	30	TD29847-001
         Yes	18004194	PA - Data Type	Option		TD31765-001
         Yes	18004195	PA - Reference No.	Code	20	TD31765-001
         Yes	18004196	PA - Reference Date	Date		TD31765-001
         Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
         Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
         No	18004199	Placeholder 18004199	Code	10	TDAG00919
         Yes	18004202	Electronic Document Format	Option		TDAG08043
         Yes	18008091	Electr. Document Status	Code	50	TDAG26229
        */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);

                    AddValue(RecRef, 18004190, DbRec.FieldNo("EOS EDoc. XML File"));
                    AddValue(RecRef, 18004191, DbRec.FieldNo("EOS Elect. Doc. Created"));
                    AddValue(RecRef, 18004192, DbRec.FieldNo("EOS Elect. Doc. File Name"));
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004199, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004201, DbRec.FieldNo("Fattura Project Code"));
                    AddValue(RecRef, 18004200, DbRec.FieldNo("Fattura Tender Code"));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure SalesCmemoHeader()
    var
        DbRec: Record "Sales Cr.Memo Header";
        RecRef: RecordRef;
    begin
        /*
        Enabled	Field No.	Field Name	Data Type	Length	Description
         Yes	18004190	PA-E-Document XML	BLOB		TD29847-001
         Yes	18004191	PA-Electronic Document Sent	Boolean		TD29847-001
         Yes	18004192	PA-Electronic Document Filen.	Text	30	TD29847-001
         Yes	18004194	PA - Data Type	Option		TD31765-001
         Yes	18004195	PA - Reference No.	Code	20	TD31765-001
         Yes	18004196	PA - Reference Date	Date		TD31765-001
         Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
         Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
         No	18004199	Placeholder 18004199	Code	10	TDAG00919
         Yes	18004202	Electronic Document Format	Option		TDAG08043
         Yes	18008091	Electr. Document Status	Code	50	TDAG26229
        */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);

                    AddValue(RecRef, 18004190, DbRec.FieldNo("EOS EDoc. XML File"));
                    AddValue(RecRef, 18004191, DbRec.FieldNo("EOS Elect. Doc. Created"));
                    AddValue(RecRef, 18004192, DbRec.FieldNo("EOS Elect. Doc. File Name"));
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004199, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004201, DbRec.FieldNo("Fattura Project Code"));
                    AddValue(RecRef, 18004200, DbRec.FieldNo("Fattura Tender Code"));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure PurchInvHeader()
    var
        DbRec: Record "Purch. Inv. Header";
        RecRef: RecordRef;
    begin
        /**/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18123060, DbRec.FieldNo("EOS Electr. Document Entry No."));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    AddValue(RecRef, 18004204, DbRec.FieldNo("EOS Applies-to Vendor No."));
                    AddValue(RecRef, 18004209, DbRec.FieldNo("EOS Applies-to ID SDI"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Applies-to Document No."));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure PurchCMemoHeader()
    var
        DbRec: Record "Purch. Cr. Memo Hdr.";
        RecRef: RecordRef;
    begin
        /**/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18123060, DbRec.FieldNo("EOS Electr. Document Entry No."));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    AddValue(RecRef, 18004204, DbRec.FieldNo("EOS Applies-to Vendor No."));
                    AddValue(RecRef, 18004209, DbRec.FieldNo("EOS Applies-to ID SDI"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Applies-to Document No."));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure Customer()
    var
        DbRec: Record Customer;
        RecRef: RecordRef;
    begin
        /**/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004143, DbRec.FieldNo("EOS No Electr. Doc. Mgt."));
                    AddValue(RecRef, 18004144, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004146, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18059930, DbRec.FieldNo("PEC E-Mail Address"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure NoSerie()
    var
        DbRec: Record "No. Series";
        RecRef: RecordRef;
    begin
        /**/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004129, DbRec.FieldNo("EOS Abletech IX VAT Register"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure VatPostingSetup()
    var
        DbRec: Record "VAT Posting Setup";
        RecRef: RecordRef;
    begin
        /**/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1), GetFieldValueAsText(2)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004180, DbRec.FieldNo("EOS Flag Print Stamp Duty"));
                    AddValue(RecRef, 18004105, DbRec.FieldNo("EOS Split Payment"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure SalesHeader()
    var
        DbRec: Record "Sales Header";
        RecRef: RecordRef;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
             Yes	18004194	PA - Data Type	Option		TD31765-001
             Yes	18004195	PA - Reference No.	Code	20	TD31765-001
             Yes	18004196	PA - Reference Date	Date		TD31765-001
             Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
             Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
             Yes	18004199	Unique Office Code	Code	10	TDAG00919
             Yes	18004202	Electronic Document Format	Option		TDAG08043
             */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(1), GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004199, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004201, DbRec.FieldNo("Fattura Project Code"));
                    AddValue(RecRef, 18004200, DbRec.FieldNo("Fattura Tender Code"));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    AddValue(RecRef, 18004204, DbRec.FieldNo("EOS Keep Electr. Doc. Type"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure PurchHeader()
    var
        DbRec: Record "Purchase Header";
        RecRef: RecordRef;
    begin
        /**/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(1), GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18123060, DbRec.FieldNo("EOS Electr. Document Entry No."));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    AddValue(RecRef, 18004204, DbRec.FieldNo("EOS Applies-to Vendor No."));
                    AddValue(RecRef, 18004205, DbRec.FieldNo("EOS Keep Electr. Doc. Type"));
                    AddValue(RecRef, 18004209, DbRec.FieldNo("EOS Applies-to ID SDI"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Applies-to Document No."));

                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure ServiceHeader()
    var
        DbRec: Record "Service Header";
        RecRef: RecordRef;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
             Yes	18004194	PA - Data Type	Option		TD31765-001
             Yes	18004195	PA - Reference No.	Code	20	TD31765-001
             Yes	18004196	PA - Reference Date	Date		TD31765-001
             Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
             Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
             Yes	18004199	Unique Office Code	Code	10	TDAG00919
             Yes	18004202	Electronic Document Format	Option		TDAG08043
             */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(1), GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004199, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004201, DbRec.FieldNo("Fattura Project Code"));
                    AddValue(RecRef, 18004200, DbRec.FieldNo("Fattura Tender Code"));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    AddValue(RecRef, 18004204, DbRec.FieldNo("EOS Keep Electr. Doc. Type"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure ServiceShipHeader()
    var
        DbRec: Record "Service Shipment Header";
        RecRef: RecordRef;
    begin
        /*
        Enabled	Field No.	Field Name	Data Type	Length	Description
         Yes	18004190	PA-E-Document XML	BLOB		TD29847-001
         Yes	18004191	PA-Electronic Document Sent	Boolean		TD29847-001
         Yes	18004192	PA-Electronic Document Filen.	Text	30	TD29847-001
         Yes	18004194	PA - Data Type	Option		TD31765-001
         Yes	18004195	PA - Reference No.	Code	20	TD31765-001
         Yes	18004196	PA - Reference Date	Date		TD31765-001
         Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
         Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
         No	18004199	Placeholder 18004199	Code	10	TDAG00919
         Yes	18004202	Electronic Document Format	Option		TDAG08043
         Yes	18004205	Electr. Doc. Related Docs.	Integer		TDAG27143
        */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004190, DbRec.FieldNo("EOS EDoc. XML File"));
                    AddValue(RecRef, 18004191, DbRec.FieldNo("EOS Elect. Doc. Created"));
                    AddValue(RecRef, 18004192, DbRec.FieldNo("EOS Elect. Doc. File Name"));
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004199, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure ServiceInvHeader()
    var
        DbRec: Record "Service Invoice Header";
        RecRef: RecordRef;
    begin
        /*
        Enabled	Field No.	Field Name	Data Type	Length	Description
         Yes	18004190	PA-E-Document XML	BLOB		TD29847-001
         Yes	18004191	PA-Electronic Document Sent	Boolean		TD29847-001
         Yes	18004192	PA-Electronic Document Filen.	Text	30	TD29847-001
         Yes	18004194	PA - Data Type	Option		TD31765-001
         Yes	18004195	PA - Reference No.	Code	20	TD31765-001
         Yes	18004196	PA - Reference Date	Date		TD31765-001
         Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
         Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
         No	18004199	Placeholder 18004199	Code	10	TDAG00919
         Yes	18004202	Electronic Document Format	Option		TDAG08043
         Yes	18008091	Electr. Document Status	Code	50	TDAG26229
        */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004190, DbRec.FieldNo("EOS EDoc. XML File"));
                    AddValue(RecRef, 18004191, DbRec.FieldNo("EOS Elect. Doc. Created"));
                    AddValue(RecRef, 18004192, DbRec.FieldNo("EOS Elect. Doc. File Name"));
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004199, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    AddValue(RecRef, 18004201, DbRec.FieldNo("Fattura Project Code"));
                    AddValue(RecRef, 18004200, DbRec.FieldNo("Fattura Tender Code"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure ServiceCmemoHeader()
    var
        DbRec: Record "Service Cr.Memo Header";
        RecRef: RecordRef;
    begin
        /*
        Enabled	Field No.	Field Name	Data Type	Length	Description
         Yes	18004190	PA-E-Document XML	BLOB		TD29847-001
         Yes	18004191	PA-Electronic Document Sent	Boolean		TD29847-001
         Yes	18004192	PA-Electronic Document Filen.	Text	30	TD29847-001
         Yes	18004194	PA - Data Type	Option		TD31765-001
         Yes	18004195	PA - Reference No.	Code	20	TD31765-001
         Yes	18004196	PA - Reference Date	Date		TD31765-001
         Yes	18004197	PA - Doc.Ref. Line No.	Code	20	TD31765-001
         Yes	18004198	PA - Code Contract/Order/Conv.	Text	100	TD31765-001
         No	18004199	Placeholder 18004199	Code	10	TDAG00919
         Yes	18004202	Electronic Document Format	Option		TDAG08043
         Yes	18008091	Electr. Document Status	Code	50	TDAG26229
        */

        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    RecRef.GetTable(DbRec);
                    AddValue(RecRef, 18004190, DbRec.FieldNo("EOS EDoc. XML File"));
                    AddValue(RecRef, 18004191, DbRec.FieldNo("EOS Elect. Doc. Created"));
                    AddValue(RecRef, 18004192, DbRec.FieldNo("EOS Elect. Doc. File Name"));
                    AddValue(RecRef, 18004194, DbRec.FieldNo("EOS EDoc. Data Type"));
                    AddValue(RecRef, 18004195, DbRec.FieldNo("EOS EDoc. Reference No."));
                    AddValue(RecRef, 18004196, DbRec.FieldNo("EOS EDoc. Reference Date"));
                    AddValue(RecRef, 18004197, DbRec.FieldNo("EOS EDoc. Doc. Ref. Line No."));
                    AddValue(RecRef, 18004198, DbRec.FieldNo("EOS EDoc. Contract/Order/Conv."));
                    AddValue(RecRef, 18004199, DbRec.FieldNo("EOS Electr. Doc. Recipient"));
                    AddValue(RecRef, 18004202, DbRec.FieldNo("EOS Electronic Document Format"));
                    AddValue(RecRef, 18004201, DbRec.FieldNo("Fattura Project Code"));
                    AddValue(RecRef, 18004200, DbRec.FieldNo("Fattura Tender Code"));
                    AddValue(RecRef, 18004203, DbRec.FieldNo("EOS Electr. Doc. Type"));
                    if DoOverwrite then
                        RecRef.Modify();
                end;
            end;
    end;

    local procedure ErrorMessage()
    var
        DbRec: Record "EOS Inb. EDoc. Error Msg.";
        recID: RecordId;
        Id: Integer;
    begin
        /*
        Yes	1	ID	Integer	
        Yes	2	Record ID	RecordID	
        Yes	3	Field Number	Integer	
        Yes	4	Message Type	Option	
        Yes	5	Description	Text	250
        Yes	6	Additional Information	Text	250
        Yes	7	Support Url	Text	250
        Yes	8	Table Number	Integer	
        Yes	10	Context Record ID	RecordID	
        Yes	11	Field Name	Text	80 NO
        Yes	12	Table Name	Text	80 NO
        Yes	13	Message Code	Code	10	
        */
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(1)) then begin
                    Evaluate(recID, TranscodeRecID(GetFieldValueAsText(2)));
                    DbRec."Record ID" := recID;
                    DbRec."Field Number" := GetFieldValueAsInteger(3);
                    DbRec."Message Type" := GetFieldValueAsInteger(4);
                    DbRec.Description := Copystr(GetFieldValueAsText(5), 1, MaxStrLen(DbRec.Description));
                    DbRec."Additional Information" := Copystr(GetFieldValueAsText(6), 1, MaxStrLen(DbRec."Additional Information"));
                    DbRec."Support Url" := Copystr(GetFieldValueAsText(7), 1, MaxStrLen(DbRec."Support Url"));
                    DbRec."Table Number" := GetFieldValueAsInteger(8);

                    Clear(recID);
                    Evaluate(recID, TranscodeRecID(GetFieldValueAsText(10)));
                    DbRec."Context Record ID" := recID;

                    DbRec."Message Code" := Copystr(GetFieldValueAsText(13), 1, MaxStrLen(DbRec."Message Code"));
                    if DoOverwrite then
                        DbRec.Modify();
                end else begin
                    Id := 1;
                    DbRec.Reset();
                    IF DbRec.FINDLAST() THEN
                        Id := DbRec.ID + 1;

                    DbRec.Init();
                    DbRec.ID := Id;
                    Evaluate(recID, TranscodeRecID(GetFieldValueAsText(2)));
                    DbRec."Record ID" := recID;
                    DbRec."Field Number" := GetFieldValueAsInteger(3);
                    DbRec."Message Type" := GetFieldValueAsInteger(4);
                    DbRec.Description := Copystr(GetFieldValueAsText(5), 1, MaxStrLen(DbRec.Description));
                    DbRec."Additional Information" := Copystr(GetFieldValueAsText(6), 1, MaxStrLen(DbRec."Additional Information"));
                    DbRec."Support Url" := Copystr(GetFieldValueAsText(7), 1, MaxStrLen(DbRec."Support Url"));
                    DbRec."Table Number" := GetFieldValueAsInteger(8);

                    Clear(recID);
                    Evaluate(recID, TranscodeRecID(GetFieldValueAsText(10)));
                    DbRec."Context Record ID" := recID;

                    DbRec."Message Code" := Copystr(GetFieldValueAsText(13), 1, MaxStrLen(DbRec."Message Code"));

                    if DoOverwrite then
                        DbRec.Insert();
                end;

            end;
    end;

    local procedure TranscodeRecID(RecID: Text): Text
    begin
        if RecID.Contains('Inc. Electr. Doc. Header') then
            Exit(RecID.Replace('Inc. Electr. Doc. Header', 'EOS Inb. EDoc. Header'))
        else
            if RecID.Contains('Electronic Doc. Preview Header') then
                Exit(RecID.Replace('Electronic Doc. Preview Header', 'EOS Inb. EDoc. Preview Header'))
            else
                if RecID.Contains('Electronic Doc. Preview Line') then
                    Exit(RecID.Replace('Electronic Doc. Preview Line', 'EOS Inb. EDoc. Preview Line'))
                else
                    Error('Table Not Supported: %1', RecID);
    end;


    local procedure OutbElectrDocSetup()
    var
        DbRec: Record "EOS Outb. Electr. Doc. Setup";
        DbRec2: Record "EOS Duty Stamp Setup";
        RecRef: RecordRef;
    begin
        with EOSImportMgt do
            while ReadNext() do begin

                if not DbRec.Get() then begin
                    DbRec.Init();
                    DbRec.Insert(true);
                end;
                RecRef.GetTable(DbRec);
                AddValue(RecRef, 10, DbRec.FieldNo("EOS Fax No."));
                AddValue(RecRef, 12100, DbRec.FieldNo("EOS Fiscal Code"));
                AddValue(RecRef, 12104, DbRec.FieldNo("EOS REA No."));
                AddValue(RecRef, 12127, DbRec.FieldNo("EOS Shareholder Status"));
                AddValue(RecRef, 18004109, DbRec.FieldNo("EOS Add Comment Line"));
                AddValue(RecRef, 18004110, DbRec.FieldNo("EOS Add Item Code"));
                AddValue(RecRef, 18004120, DbRec.FieldNo("EOS Skip attachments export"));
                AddValue(RecRef, 18004130, DbRec.FieldNo("EOS File ID Starting No."));
                AddValue(RecRef, 18004131, DbRec.FieldNo("EOS Last File ID Used"));
                AddValue(RecRef, 18004132, DbRec.FieldNo("EOS Last Date Used"));
                AddValue(RecRef, 18004145, DbRec.FieldNo("EOS CONAI text"));
                AddValue(RecRef, 18004147, DbRec.FieldNo("EOS Foreign Currency Mgt."));
                AddValue(RecRef, 18004150, DbRec.FieldNo("EOS Electr. Inv. Start Date"));
                AddValue(RecRef, 18004151, DbRec.FieldNo("EOS Country Code Field No."));
                AddValue(RecRef, 18004170, DbRec.FieldNo("EOS Paid-In Capital"));
                AddValue(RecRef, 19, DbRec.FieldNo("EOS VAT Registration No."));
                AddValue(RecRef, 2, DbRec.FieldNo("EOS Name"));
                AddValue(RecRef, 3, DbRec.FieldNo("EOS Name 2"));
                AddValue(RecRef, 30, DbRec.FieldNo("EOS Post Code"));
                AddValue(RecRef, 31, DbRec.FieldNo("EOS County"));
                AddValue(RecRef, 34, DbRec.FieldNo("EOS E-Mail"));
                AddValue(RecRef, 36, DbRec.FieldNo("EOS Country/Region Code"));
                AddValue(RecRef, 4, DbRec.FieldNo("EOS Address"));
                AddValue(RecRef, 5, DbRec.FieldNo("EOS Address 2"));
                AddValue(RecRef, 6, DbRec.FieldNo("EOS City"));
                AddValue(RecRef, 7, DbRec.FieldNo("EOS Phone No."));
                AddValue(RecRef, 18004106, DbRec.FieldNo("EOS Registry Office Province"));
                RecRef.Field(DbRec.FieldNo("EOS Liquidation Status")).Value := GetFieldValueAsInteger(18004107) + 1;
                AddValue(RecRef, 18004152, DbRec.FieldNo("EOS Data Tag Mgt."));
                AddValue(RecRef, 18004153, DbRec.FieldNo("EOS Ecobonus text"));
                AddValue(RecRef, 18004155, DbRec.FieldNo("Export Format"));
                AddValue(RecRef, 18004156, DbRec.FieldNo("Format 1.6 Start Date"));
                AddValue(RecRef, 18004170, DbRec.FieldNo("EOS Paid-In Capital"));

                if DoOverwrite then
                    RecRef.Modify();


                if not DbRec2.Get() then begin
                    DbRec2.Init();
                    DbRec2.Insert();
                end;
                RecRef.GetTable(DbRec2);
                AddValue(RecRef, 18004146, DbRec2.FieldNo("EDoc. Causale text"));
                if DoOverwrite then
                    RecRef.Modify();
            end;
    end;

    local procedure OutbElectrDocSetupGroup()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Outb. EDoc. Group Setup");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbEDocChecks()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Checks");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure OutbEDocCustSetup()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Outb. EDoc. Cust. Setup");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure IXFESetup()
    var
        DbRec: Record "EOS IXFE Setup";
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS IXFE Setup");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
            if DbRec.Get(recref.RecordId()) then begin
                DbRec.validate("EOS IXFE AOO", '');

                if DoOverwrite then
                    DbRec.Modify();
            end;
        end;
    end;

    local procedure InbEDocSetup()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Setup");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, true);
        end;
    end;

    local procedure InbEDocRating()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Rating");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbEDocSetupGroup()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Setup Group");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbEDocVendorSetup()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Vendor Setup");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbEDocUM()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. UM");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure InbEDocCashTypeSetup()
    var
        recref: RecordRef;
    begin
        recref.Open(Database::"EOS Inb. EDoc. Cash Type Setup");
        while EOSImportMgt.ReadNext() do begin
            EOSImportMgt.FillTable(recref);
            EOSImportMgt.InsertData(recref, DoOverwrite, false);
        end;
    end;

    local procedure DutyStampSetup()
    var
        DbRec: Record "EOS Duty Stamp Setup";
        RecRef: RecordRef;
    begin
        with EOSImportMgt do
            while ReadNext() do begin

                if not DbRec.Get() then begin
                    DbRec.Init();
                    DbRec.Insert();
                end;
                RecRef.GetTable(DbRec);
                AddValue(RecRef, 1700, DbRec.FieldNo("Minimum Amount (LCY)"));
                AddValue(RecRef, 1701, DbRec.FieldNo("Start Data Validity Stamp Duty"));
                AddValue(RecRef, 1702, DbRec.FieldNo("Duty Stamp Amount"));
                AddValue(RecRef, 1703, DbRec.FieldNo("Duty G/L Account"));
                AddValue(RecRef, 1705, DbRec.FieldNo("Duty Gen. Bus. Posting Group"));
                AddValue(RecRef, 1706, DbRec.FieldNo("Duty Gen. Prod. Posting Group"));
                AddValue(RecRef, 1707, DbRec.FieldNo("Duty VAT Bus. Posting Group"));
                AddValue(RecRef, 1708, DbRec.FieldNo("Duty VAT Prod. Posting Group"));

                if DoOverwrite then
                    RecRef.Modify();
            end;
    end;

}
