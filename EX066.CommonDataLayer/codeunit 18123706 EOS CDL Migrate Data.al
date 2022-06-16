codeunit 18123706 "EOS CDL Migrate Data"
{
    TableNo = "EOS JSON Import Buffer";
    trigger OnRun()
    begin
        EOSImportMgt.StartProgress(Rec);
        case Rec."Table Id" of
            18:
                Customer();
            21:
                CustLedgEntry();
            23:
                Vendor();
            25:
                VendLedgEntry();
            36:
                SalesHeader();
            37:
                SalesLine();
            38:
                PurchHeader();
            39:
                PurchLine();
            81:
                GenJnlLine();
            110:
                SalesShipHdr();
            111:
                SalesShipLine();
            112:
                SalesInvHdr();
            113:
                SalesInvLine();
            114:
                SalesCMemoHdr();
            115:
                SalesCMemoLine();
            122:
                PurchInvHdr();
            123:
                PurchInvLine();
            124:
                PurchCMemoHdr();
            125:
                PurchCMemoLine();
            222:
                ShipToAddress();
            225:
                PostCode();
            260:
                TariffNumber();
            325:
                VATPostingSetup();
            5050:
                Contact();
            5107:
                SalesHeaderArchive();
            5108:
                SalesLineArchive();
            5109:
                PurchaseHeaderArchive();
            5110:
                PurchaseLineArchive();
            5900:
                ServiceHeader();
            5902:
                ServiceLine();
            5990:
                ServiceShipHeader();
            5991:
                ServiceShipLine();
            5992:
                ServiceInvHeader();
            5993:
                ServiceInvLine();
            5994:
                ServiceCMemoHeader();
            5995:
                ServiceCMemoLine();
            6660:
                ReturnRcptHeader();
            6661:
                ReturnRcptLine();
            18090628:
                City();
            18004135:
                County();
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

    local procedure Customer()
    var
        DbRec: Record Customer;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004136	No VAT Reg. No.	Boolean		PE02-011-001
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1)) then begin
                DbRec."EOS No VAT Reg. No." := EOSImportMgt.GetFieldValueAsBoolean(18004136);
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure CustLedgEntry()
    var
        DbRec: Record "Cust. Ledger Entry";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure Vendor()
    var
        DbRec: Record Vendor;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
        Yes	18004136	No VAT Reg. No.	Boolean		PE02-011-001
        Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1)) then begin
                DbRec."EOS No VAT Reg. No." := EOSImportMgt.GetFieldValueAsBoolean(18004136);
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure VendLedgEntry()
    var
        DbRec: Record "Vendor Ledger Entry";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesHeader()
    var
        DbRec: Record "Sales Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesLine()
    var
        DbRec: Record "Sales Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004120	Tariff No.	Code	20	TD39610
            Yes	18004152	Source Code	Code	10	TDAG09527*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PurchHeader()
    var
        DbRec: Record "Purchase Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PurchLine()
    var
        DbRec: Record "Purchase Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004120	Tariff No.	Code	20	TD39610*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure GenJnlLine()
    var
        DbRec: Record "Gen. Journal Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1), EOSImportMgt.GetFieldValueAsText(51), EOSImportMgt.GetFieldValueAsInteger(2)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesShipHdr()
    var
        DbRec: Record "Sales Shipment Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesShipLine()
    var
        DbRec: Record "Sales Shipment Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            No	18004120	Tariff No.	Code	20	TD39610
            Yes	18004152	Source Code	Code	10	TDAG09527*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesInvHdr()
    var
        DbRec: Record "Sales Invoice Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesInvLine()
    var
        DbRec: Record "Sales Invoice Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            No	18004120	Tariff No.	Code	20	TD39610
            Yes	18004152	Source Code	Code	10	TDAG09527*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesCMemoHdr()
    var
        DbRec: Record "Sales Cr.Memo Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesCMemoLine()
    var
        DbRec: Record "Sales Cr.Memo Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            No	18004120	Tariff No.	Code	20	TD39610
            Yes	18004152	Source Code	Code	10	TDAG09527*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
    end;

    /*local procedure PurchRcptHdr()
    var
        DbRec: Record "Purch. Rcpt. Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
    /*with EOSImportMgt do
        while ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
end;

local procedure PurchRcptLine()
var
    DbRec: Record "Purch. Rcpt. Line";
begin
    /*Enabled	Field No.	Field Name	Data Type	Length	Description
        No	18004120	Tariff No.	Code	20	TD39610*/
    /*with EOSImportMgt do
        while ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(GetFieldValueAsText(3), GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
end;*/

    local procedure PurchInvHdr()
    var
        DbRec: Record "Purch. Inv. Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PurchInvLine()
    var
        DbRec: Record "Purch. Inv. Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            No	18004120	Tariff No.	Code	20	TD39610*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PurchCMemoHdr()
    var
        DbRec: Record "Purch. Cr. Memo Hdr.";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PurchCMemoLine()
    var
        DbRec: Record "Purch. Cr. Memo Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            No	18004120	Tariff No.	Code	20	TD39610*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ShipToAddress()
    var
        DbRec: Record "Ship-to Address";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004190	Store Code	Code	20	TDAG29286
            Yes	18004191	Store Description	Text	50	TDAG29286*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1), EOSImportMgt.GetFieldValueAsText(2)) then begin
                DbRec."EOS Store Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004190), 1, MaxStrLen(DbRec."EOS Store Code"));
                DbRec."EOS Store Description" := Copystr(EOSImportMgt.GetFieldValueAsText(18004191), 1, MaxStrLen(DbRec."EOS Store Description"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PostCode()
    var
        DbRec: Record "Post Code";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18090627	Territory Code	Code	10	
            Yes	18090628	ISTAT City Code	Code	10	*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1), EOSImportMgt.GetFieldValueAsText(2)) then begin
                DbRec."EOS Territory Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18090627), 1, MaxStrLen(DbRec."EOS Territory Code"));
                DbRec."EOS ISTAT City Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18090628), 1, MaxStrLen(DbRec."EOS ISTAT City Code"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure TariffNumber()
    var
        DbRec: Record "Tariff Number";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004102	Tariff No. Type	Option		PE01-021-001*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1)) then begin
                DbRec."EOS Tariff No. Type" := EOSImportMgt.GetFieldValueAsInteger(18004102);
                DbRec.Modify();
            end;
        end;
    end;

    local procedure VATPostingSetup()
    var
        DbRec: Record "VAT Posting Setup";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004105	Split Payment	Boolean		TD33618*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1), EOSImportMgt.GetFieldValueAsText(2)) then begin
                DbRec."EOS Split Payment" := EOSImportMgt.GetFieldValueAsBoolean(18004105);
                DbRec.Modify();
            end;
        end;
    end;

    local procedure Contact()
    var
        DbRec: Record Contact;
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004136	No VAT Reg. No.	Boolean		PE02-011-001
            No	18004141	Our Bank Account	Code	20	*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(1)) then begin
                DbRec."EOS No VAT Reg. No." := EOSImportMgt.GetFieldValueAsBoolean(18004136);
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesHeaderArchive()
    var
        DbRec: Record "Sales Header Archive";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(5048), EOSImportMgt.GetFieldValueAsInteger(5047)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure SalesLineArchive()
    var
        DbRec: Record "Sales Line Archive";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004120	Tariff No.	Code	20	TD39610
            Yes	18004152	Source Code	Code	10	TDAG09527*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(5048), EOSImportMgt.GetFieldValueAsInteger(5047), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PurchaseHeaderArchive()
    var
        DbRec: Record "Purchase Header Archive";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(5048), EOSImportMgt.GetFieldValueAsInteger(5047)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure PurchaseLineArchive()
    var
        DbRec: Record "Purchase Line Archive";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004120	Tariff No.	Code	20	TD39610*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(5048), EOSImportMgt.GetFieldValueAsInteger(5047), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceHeader()
    var
        DbRec: Record "Service Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceLine()
    var
        DbRec: Record "Service Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004120	Tariff No.	Code	20	TDAG11677
            Yes	18004152	Source Code	Code	10	TDAG16869*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsInteger(1), EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceShipHeader()
    var
        DbRec: Record "Service Shipment Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceShipLine()
    var
        DbRec: Record "Service Shipment Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004152	Source Code	Code	10	TDAG16869*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceInvHeader()
    var
        DbRec: Record "Service Invoice Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceInvLine()
    var
        DbRec: Record "Service Invoice Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004152	Source Code	Code	10	TDAG16869*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceCMemoHeader()
    var
        DbRec: Record "Service Cr.Memo Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ServiceCMemoLine()
    var
        DbRec: Record "Service Cr.Memo Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004152	Source Code	Code	10	TDAG16869*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Tariff No." := Copystr(EOSImportMgt.GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec.Modify();
            end;
        end;
    end;

    /*local procedure ReturnShptHeader()
    var
        DbRec: Record "Return Shipment Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
    /*with EOSImportMgt do
        while ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
end;*/

    /*local procedure ReturnShptLine()
    var
        DbRec: Record "Return Shipment Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004152	Source Code	Code	10	TDAG16869*/
    /* with EOSImportMgt do
         while ReadNext() do begin
             DbRec.Reset();
             if DbRec.Get(GetFieldValueAsText(3), GetFieldValueAsInteger(4)) then begin
                 DbRec."EOS Tariff No." := Copystr(GetFieldValueAsText(18004120), 1, MaxStrLen(DbRec."EOS Tariff No."));
                 DbRec.Modify();
             end;
         end;
 end;*/
    local procedure ReturnRcptHeader()
    var
        DbRec: Record "Return Receipt Header";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004141	Our Bank Account	Code	20	TD26098*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3)) then begin
                DbRec."EOS Our Bank Account" := Copystr(EOSImportMgt.GetFieldValueAsText(18004141), 1, MaxStrLen(DbRec."EOS Our Bank Account"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure ReturnRcptLine()
    var
        DbRec: Record "Return Receipt Line";
    begin
        /*Enabled	Field No.	Field Name	Data Type	Length	Description
            Yes	18004152	Source Code	Code	10	TDAG16869*/
        while EOSImportMgt.ReadNext() do begin
            DbRec.Reset();
            if DbRec.Get(EOSImportMgt.GetFieldValueAsText(3), EOSImportMgt.GetFieldValueAsInteger(4)) then begin
                DbRec."EOS Source Code" := Copystr(EOSImportMgt.GetFieldValueAsText(18004152), 1, MaxStrLen(DbRec."EOS Source Code"));
                DbRec.Modify();
            end;
        end;
    end;

    local procedure City()
    var
        DbRec: Record "EOS City";
        recref: RecordRef;
    begin
        while EOSImportMgt.ReadNext() do begin
            recref.GetTable(DbRec);
            EOSImportMgt.FillTable(recref);
            recref.SetTable(DbRec);
            DbRec.Insert();
        end;
    end;

    local procedure County()
    var
        DbRec: Record "EOS County";
        recref: RecordRef;
    begin
        while EOSImportMgt.ReadNext() do begin
            recref.GetTable(DbRec);
            EOSImportMgt.FillTable(recref);
            recref.SetTable(DbRec);
            DbRec.Insert();
        end;
    end;
}