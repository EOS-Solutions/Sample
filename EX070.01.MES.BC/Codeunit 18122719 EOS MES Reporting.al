/// <summary>Codeunit used to create Barcode</summary>
dotnet
{
    assembly(Eos.Lib.BarcodeEncoder)
    {
        type(Eos.Lib.BarcodeEncoder.BarcodeEncoder; "EOS BarcodeEconder") { }
        type(Eos.Lib.BarcodeEncoder.BarcodeType; "EOS BarcodeType") { }
    }
    assembly(System.Drawing)
    {
        type(System.Drawing.Bitmap; "EOS Bitmap") { }
        type(System.Drawing.Imaging.ImageFormat; "EOS BitmapFormat") { }
    }
}


codeunit 50000 "EOS MES Reporting Management"
{
    procedure FormatBarcodeEmplLabel(Employee: Record Employee; VAR TenantMedia: Record "Tenant Media" temporary)
    var
        EOS070MESSetup: Record "EOS 070 MES Setup";
    begin
        if Employee."EOS Badge No." = '' then
            exit;
        EOS070MESSetup.Get();
        GetBarcode(Employee."EOS Badge No.", EOS070MESSetup."Barcode Type", TenantMedia);
    end;

    procedure FormatBarcodeRoutingLine(ProdOrderRoutingLine: Record "Prod. Order Routing Line"; var TenantMedia: Record "Tenant Media" temporary)
    var
        EOS070MESSetup: Record "EOS 070 MES Setup";
        FormatBarcodeTxt: Label '%1%4%2%4%3';
    begin
        EOS070MESSetup.get();
        GetBarcode(STRSUBSTNO(FormatBarcodeTxt, ProdOrderRoutingLine."Prod. Order No.", ProdOrderRoutingLine."Routing Reference No.", ProdOrderRoutingLine."Operation No.",
          EOS070MESSetup.Separator), EOS070MESSetup."Barcode Type", TenantMedia);
    end;

    procedure GetBarcode(BarcodeString: Text; BarcodeTypeOpt: Enum "EOS 070 MES Barcode Type"; var TenantMedia: Record "Tenant Media" temporary)
    var
        FileManagement: Codeunit "File Management";
        BarcodeEncoder: dotnet "EOS BarcodeEconder";
        BarcodeType: dotnet "EOS BarcodeType";
        // BitMap: DotNet Bitmap;
        BitmapFormat: dotnet "EOS BitmapFormat";
        FileNameBmp: Text;
        Result: Boolean;
    begin
        BarcodeEncoder := BarcodeEncoder.BarcodeEncoder();
        CASE BarcodeTypeOpt OF
            BarcodeTypeOpt::Code39:
                BarcodeEncoder.Encode(BarcodeType.Code39, BarcodeString);
            BarcodeTypeOpt::Code128:
                BarcodeEncoder.Encode(BarcodeType.Code128, BarcodeString);
            BarcodeTypeOpt::Interleaved2of5:
                BarcodeEncoder.Encode(BarcodeType.Interleaved2of5, BarcodeString);
            BarcodeTypeOpt::EAN13:
                BarcodeEncoder.Encode(BarcodeType.EAN13, BarcodeString);
            BarcodeTypeOpt::QRCode:
                BarcodeEncoder.Encode(BarcodeType.QRCode, BarcodeString);
        END;
        EOS070MESReporPublicEvent.OnBeforeGetBarcode(BarcodeEncoder, BarcodeString);
        FileNameBmp := FileManagement.ServerTempFileName('jpg');
        // Bitmap := BarcodeEncoder.BitmapDataScaled();
        // Bitmap.Save(FileNameBmp, BitmapFormat.Jpeg);
        TenantMedia.Content.Import(FileNameBmp);
        if TenantMedia.Content.HasValue then
            result := true;
    end;

    var
        EOS070MESReporPublicEvent: Codeunit "EOS 070 MES Repor.Public Event";
}