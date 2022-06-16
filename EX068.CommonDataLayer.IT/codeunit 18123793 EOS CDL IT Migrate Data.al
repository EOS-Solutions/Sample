codeunit 18123793 "EOS CDL IT Migrate Data"
{
    TableNo = "EOS JSON Import Buffer";
    trigger OnRun()
    begin
        EOSImportMgt.StartProgress(Rec);
        case Rec."Table Id" of
            27:
                Vendor();
            38:
                PurchHeader();
            120:
                PurchRcptHdr();
            122:
                PurchInvHdr();
            124:
                PurchCMemoHdr();
            167:
                Job();
            5050:
                Contact();
            12111:
                CompWithTax();
            12113:
                TmpWithContrib();
            12116:
                WithTax();
            12137:
                PurchWithContrib();
            12182:
                VendBillLine();
            12184:
                PostVendBillLine();
            12185:
                VendorBillWithTax();
        end;
    end;

    var
        EOSImportMgt: Codeunit "EOS JSON Import Helper";

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

    local procedure PurchHeader()
    var
        DbRec: Record "Purchase Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004200	CIG Code	Code	20	TDAG16469
        Yes	18004201	CUP Code	Code	20	TDAG16469*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(1), GetFieldValueAsText(3)) then begin
                    DbRec."EOS Fattura Tender Code" := Copystr(GetFieldValueAsText(18004200), 1, MaxStrLen(DbRec."EOS Fattura Tender Code"));
                    DbRec."EOS Fattura Project Code" := Copystr(GetFieldValueAsText(18004201), 1, MaxStrLen(DbRec."EOS Fattura Project Code"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure PurchRcptHdr()
    var
        DbRec: Record "Purch. Rcpt. Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004200	CIG Code	Code	20	TDAG16469
        Yes	18004201	CUP Code	Code	20	TDAG16469*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    DbRec."EOS Fattura Tender Code" := Copystr(GetFieldValueAsText(18004200), 1, MaxStrLen(DbRec."EOS Fattura Tender Code"));
                    DbRec."EOS Fattura Project Code" := Copystr(GetFieldValueAsText(18004201), 1, MaxStrLen(DbRec."EOS Fattura Project Code"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure PurchInvHdr()
    var
        DbRec: Record "Purch. Inv. Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004200	CIG Code	Code	20	TDAG16469
        Yes	18004201	CUP Code	Code	20	TDAG16469*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    DbRec."EOS Fattura Tender Code" := Copystr(GetFieldValueAsText(18004200), 1, MaxStrLen(DbRec."EOS Fattura Tender Code"));
                    DbRec."EOS Fattura Project Code" := Copystr(GetFieldValueAsText(18004201), 1, MaxStrLen(DbRec."EOS Fattura Project Code"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure PurchCMemoHdr()
    var
        DbRec: Record "Purch. Cr. Memo Hdr.";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004200	CIG Code	Code	20	TDAG16469
        Yes	18004201	CUP Code	Code	20	TDAG16469*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(3)) then begin
                    DbRec."EOS Fattura Tender Code" := Copystr(GetFieldValueAsText(18004200), 1, MaxStrLen(DbRec."EOS Fattura Tender Code"));
                    DbRec."EOS Fattura Project Code" := Copystr(GetFieldValueAsText(18004201), 1, MaxStrLen(DbRec."EOS Fattura Project Code"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure Job()
    var
        DbRec: Record Job;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004200	CIG Code	Code	20	TDAG16469
        Yes	18004201	CUP Code	Code	20	TDAG16469*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1)) then begin
                    DbRec."EOS Fattura Tender Code" := Copystr(GetFieldValueAsText(18004200), 1, MaxStrLen(DbRec."EOS Fattura Tender Code"));
                    DbRec."EOS Fattura Project Code" := Copystr(GetFieldValueAsText(18004201), 1, MaxStrLen(DbRec."EOS Fattura Project Code"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure CompWithTax()
    var
        DbRec: Record "Computed Withholding Tax";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18008100	Professional Tax Amount	Decimal		TDAG20590*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(4), GetFieldValueAsDate(1), GetFieldValueAsText(2)) then begin
                    DbRec."EOS Professional Tax Amount" := GetFieldValueAsDecimal(18008100);
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure TmpWithContrib()
    var
        DbRec: Record "Tmp Withholding Contribution";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18008100	Professional Tax Amount	Decimal		TDAG20590*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(100), GetFieldValueAsText(101), GetFieldValueAsText(102)) then begin
                    DbRec."EOS Professional Tax Amount" := GetFieldValueAsDecimal(18008100);
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure WithTax()
    var
        DbRec: Record "Withholding Tax";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18008100	Professional Tax Amount	Decimal		TDAG20590*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(1)) then begin
                    DbRec."EOS Professional Tax Amount" := GetFieldValueAsDecimal(18008100);
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure PurchWithContrib()
    var
        DbRec: Record "Purch. Withh. Contribution";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18008100	Professional Tax Amount	Decimal		TDAG20590*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(1), GetFieldValueAsText(2)) then begin
                    DbRec."EOS Professional Tax Amount" := GetFieldValueAsDecimal(18008100);
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure VendBillLine()
    var
        DbRec: Record "Vendor Bill Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004200	CIG Code	Code	20	TDAG16469
        Yes	18004201	CUP Code	Code	20	TDAG16469*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1), GetFieldValueAsInteger(2)) then begin
                    DbRec."EOS Fattura Tender Code" := Copystr(GetFieldValueAsText(18004200), 1, MaxStrLen(DbRec."EOS Fattura Tender Code"));
                    DbRec."EOS Fattura Project Code" := Copystr(GetFieldValueAsText(18004201), 1, MaxStrLen(DbRec."EOS Fattura Project Code"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure PostVendBillLine()
    var
        DbRec: Record "Posted Vendor Bill Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004200	CIG Code	Code	20	TDAG16469
        Yes	18004201	CUP Code	Code	20	TDAG16469*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1), GetFieldValueAsInteger(2)) then begin
                    DbRec."EOS Fattura Tender Code" := Copystr(GetFieldValueAsText(18004200), 1, MaxStrLen(DbRec."EOS Fattura Tender Code"));
                    DbRec."EOS Fattura Project Code" := Copystr(GetFieldValueAsText(18004201), 1, MaxStrLen(DbRec."EOS Fattura Project Code"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure VendorBillWithTax()
    var
        DbRec: Record "Vendor Bill Withholding Tax";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18008100	Professional Tax Amount	Decimal		TDAG20590*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsInteger(100), GetFieldValueAsText(103)) then begin
                    DbRec."EOS Professional Tax Amount" := GetFieldValueAsDecimal(18008100);
                    DbRec.Modify();
                end;
            end;
    end;


    local procedure Vendor()
    var
        DbRec: Record Vendor;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18059930	PEC MAIL	text	80	*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1)) then begin
                    DbRec."EOS PEC-Mail" := Copystr(GetFieldValueAsText(18059930), 1, MaxStrLen(DbRec."EOS PEC-Mail"));
                    DbRec.Modify();
                end;
            end;
    end;

    local procedure Contact()
    var
        DbRec: Record Contact;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18059930	PEC MAIL	text	80	*/
        with EOSImportMgt do
            while ReadNext() do begin
                DbRec.Reset();
                if DbRec.Get(GetFieldValueAsText(1)) then begin
                    DbRec."EOS PEC-Mail" := Copystr(GetFieldValueAsText(18059930), 1, MaxStrLen(DbRec."EOS PEC-Mail"));
                    DbRec.Modify();
                end;
            end;
    end;
}