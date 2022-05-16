page 18122320 "EOS004 FunctionApi Test"
{
    PageType = Card;
    ApplicationArea = All;
    SaveValues = true;
    UsageCategory = Administration;
    Caption = 'EAL FunctionApi Test';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Service Config"; ServiceConfigCode)
                {
                    ApplicationArea = all;
                    TableRelation = "EOS004 Service Config.".Code where(Type = const("EOS FunctionApi"));
                }
                field(Which; Which)
                {
                    ApplicationArea = all;
                }
            }
            group("iStorage")
            {
                field("Storage Type"; StorageType)
                {
                    ApplicationArea = all;
                }

                field(Path1; Path)
                {
                    ApplicationArea = All;
                }
                field(Path2; Path2)
                {
                    ApplicationArea = All;
                }
                field("Force"; force)
                {
                    ApplicationArea = All;
                }
                field("Storage Function"; StorageFunction)
                {
                    ApplicationArea = all;
                }
                field(data; data)
                {
                    ApplicationArea = All;
                }

            }
            group(Barcodes)
            {
                field("Select Function"; BarcodeFunction)
                {
                    ApplicationArea = all;
                }
                field("Encoder Name"; EncoderName)
                {
                    ApplicationArea = All;
                }
                field("Barcode Data"; data)
                {
                    ApplicationArea = All;
                }
                group(OutputSetting)
                {
                    field(OutputDpi; OutputDpi)
                    {
                        ApplicationArea = All;
                    }
                    field(OutputAspectRatio; OutputAspectRatio)
                    {
                        ApplicationArea = All;
                    }
                    field(OutputFormat; OutputFormat)
                    {
                        ApplicationArea = All;
                    }
                    field(OutputFormatQualtity; OutputFormatQualtity)
                    {
                        ApplicationArea = All;
                    }
                    field(OutputTargetHeightInMm; OutputTargetHeightInMm)
                    {
                        ApplicationArea = All;
                    }
                    field(OutputTargetWidthInMm; OutputTargetWidthInMm)
                    {
                        ApplicationArea = All;
                    }

                }

            }

            group("P7M Helper")
            {
                field(inputFile; P7mFilename)
                {
                    ApplicationArea = all;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        is: InStream;
                        os: OutStream;
                    begin
                        P7mFile.CreateOutStream(os);
                        UploadIntoStream('UploadFile', '', '', P7mFilename, is);
                        CopyStream(os, is);
                    end;
                }
                field(skipVerification; skipVerification)
                {
                    ApplicationArea = All;
                }

            }

            group("PDfs")
            {

                field("Select PDF Function"; PdfFunction)
                {
                    ApplicationArea = all;
                }
                field("ProtectPDF Code"; ProtectPDFCode)
                {
                    ApplicationArea = all;
                    TableRelation = "EOS004 PDF Protect Settings".Code;
                }
                field("PdfFile"; PdfFilename)
                {
                    ApplicationArea = all;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        is: InStream;
                        os: OutStream;
                    begin
                        PdfFile.CreateOutStream(os);
                        UploadIntoStream('UploadFile', '', '', PdfFilename, is);
                        CopyStream(os, is);
                    end;
                }
                field("PdfFile2"; PdfFilename2)
                {
                    ApplicationArea = all;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        is: InStream;
                        os: OutStream;
                    begin
                        PdfFile2.CreateOutStream(os);
                        UploadIntoStream('UploadFile', '', '', PdfFilename2, is);
                        CopyStream(os, is);
                    end;
                }
                field("Background Page No"; BackgroundPageNo)
                {
                    ApplicationArea = all;
                }
            }
            group(ResultGrp)
            {
                Caption = 'Result';
                field("Response code"; ResponseCode)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(result; ResultTxt)
                {
                    MultiLine = true;
                    RowSpan = 6;
                    Editable = false;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Execute)
            {
                ApplicationArea = All;
                Image = Start;
                trigger OnAction()
                begin
                    case Which of
                        Which::Barcode:
                            Barcode();
                        Which::Storage:
                            Storage();
                        Which::PDF:
                            PDF();
                        Which::P7M:
                            P7M();
                    end;
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        P7mFilename := 'drilldown to upload';
        PdfFilename := 'drilldown to upload';
        PdfFilename2 := 'drilldown to upload';
    end;

    var
        StorageFunction: Option " ",UploadFile,ReadFile,DeleteFile,RenameFile,CopyFile,MoveFile,GetFiles,CreateFolder,DeleteFolder,MoveFolder;
        BarcodeFunction: Option " ",Encoders,Encode;
        Which: Option Storage,Barcode,PDF,P7M;
        PdfFunction: Option metadata,split,combine,setbackground,protect;
        StorageType: Enum "EOS004 iStorage Type";
        ResponseCode: Enum "EOS004 Storage Response Status";
        ServiceConfigCode, ProtectPDFCode : Code[20];
        force, skipVerification : Boolean;
        Path, Path2, data, EncoderName, ResultTxt, P7mFilename, PdfFilename, PdfFilename2 : Text;
        Encoders: List of [Text];
        OutputDpi, OutputTargetWidthInMm, OutputTargetHeightInMm, OutputAspectRatio, OutputFormatQualtity, BackgroundPageNo : Integer;
        OutputFormat: Enum "EOS004 Barcode Output Format";
        PdfFile, PdfFile2, P7mFile : Codeunit "Temp Blob";

    local procedure PDF()
    var
        ServiceConfig: Record "EOS004 Service Config.";
        DataCompression: Codeunit "Data Compression";
        PDFProtectSettings: Record "EOS004 PDF Protect Settings";
        pdfs: Record "Name/Value Buffer" temporary;
        PDFAPIClient: Codeunit "EOS004 PDF API Client";
        TempBlob: Codeunit "Temp Blob";
        is: InStream;
        Filename: Text;
        out: JsonObject;
    begin
        ServiceConfig.get(ServiceConfigCode);
        PDFAPIClient.Initialize(ServiceConfig);
        case PdfFunction of
            PdfFunction::combine:
                begin
                    pdfs.Reset();
                    pdfs.DeleteAll();
                    pdfs.EOS004AddNewEntry(PdfFilename, PdfFile);
                    pdfs.EOS004AddNewEntry(PdfFilename2, PdfFile2);
                    PDFAPIClient.Combine(pdfs, TempBlob);
                    TempBlob.CreateInStream(is);
                    Filename := 'combined.pdf';
                    DownloadFromStream(is, '', '', '', Filename);
                end;
            PdfFunction::metadata:
                begin
                    PDFAPIClient.Metadata(PdfFile, out);
                    out.WriteTo(ResultTxt);
                end;
            PdfFunction::protect:
                begin
                    PDFProtectSettings.Get(ProtectPDFCode);
                    PDFAPIClient.Protect(PdfFile, PDFProtectSettings, TempBlob);
                    TempBlob.CreateInStream(is);
                    Filename := 'protected.pdf';
                    DownloadFromStream(is, '', '', '', Filename);
                end;
            PdfFunction::setbackground:
                begin
                    PDFAPIClient.SetBackground(PdfFile, PdfFile2, BackgroundPageNo, TempBlob);
                    TempBlob.CreateInStream(is);
                    Filename := 'Background.zip';
                    DownloadFromStream(is, '', '', '', Filename);
                end;
            PdfFunction::split:
                begin
                    pdfs.Reset();
                    pdfs.DeleteAll();
                    PDFAPIClient.Split(PdfFile, pdfs);
                    DataCompression.CreateZipArchive();
                    if pdfs.FindSet() then
                        repeat
                            Clear(is);
                            pdfs.CalcFields("Value BLOB");
                            pdfs."Value BLOB".CreateInStream(is);
                            DataCompression.AddEntry(is, pdfs.Name);
                        until pdfs.Next() = 0;

                    DataCompression.SaveZipArchive(TempBlob);
                    TempBlob.CreateInStream(is);
                    Filename := 'split.zip';
                    DownloadFromStream(is, '', '', '', Filename);

                end;
        end
    end;

    local procedure P7M()
    var
        ServiceConfig: Record "EOS004 Service Config.";
        P7MImpl: Codeunit "EOS004 P7M API Client";
        TempBlob: Codeunit "Temp Blob";
        is: InStream;
        Filename: Text;
    begin
        ServiceConfig.get(ServiceConfigCode);
        P7MImpl.Initialize(ServiceConfig);
        P7MImpl.Extract(P7mFile, skipVerification, TempBlob);
        TempBlob.CreateInStream(is);
        Filename := P7mFilename + '.xml';
        DownloadFromStream(is, '', '', '', Filename);
    end;

    local procedure Barcode()
    var
        ServiceConfig: Record "EOS004 Service Config.";
        BarcodeImpl: Codeunit "EOS004 Barcode API Client";
        TempBlob: Codeunit "Temp Blob";
        tmptext, Filename : Text;
        is: InStream;
    begin
        ServiceConfig.get(ServiceConfigCode);
        BarcodeImpl.Initialize(ServiceConfig);
        case BarcodeFunction of
            BarcodeFunction::Encoders:
                begin
                    ResultTxt := '';
                    Encoders := BarcodeImpl.Encoders();
                    foreach tmptext in Encoders do
                        ResultTxt += tmptext + ' - ';
                end;
            BarcodeFunction::Encode:
                begin
                    BarcodeImpl.AspectRatio(OutputAspectRatio);
                    BarcodeImpl.BarcodeFormat(OutputFormat);
                    BarcodeImpl.Dpi(OutputDpi);
                    BarcodeImpl.FormatQuality(OutputFormatQualtity);
                    BarcodeImpl.TargetHeightInMm(OutputTargetHeightInMm);
                    BarcodeImpl.TargetWidthInMm(OutputTargetWidthInMm);
                    BarcodeImpl.Encode(EncoderName, data, TempBlob);
                    TempBlob.CreateInStream(is);
                    Filename := StrSubstNo('%1.%2', EncoderName, Format(OutputFormat));
                    DownloadFromStream(is, '', '', '', Filename);
                end;
        end;
    end;

    local procedure Storage()
    var
        iStorage: Interface "EOS004 iStorage";
        ServiceConfig: Record "EOS004 Service Config.";
        TempBlob: Codeunit "Temp Blob";
        Result: JsonArray;
        os: OutStream;
    begin
        ServiceConfig.get(ServiceConfigCode);
        iStorage := StorageType;
        iStorage.iStorageInit(ServiceConfig);
        case StorageFunction of
            StorageFunction::" ":
                Message('select a function');
            StorageFunction::UploadFile:
                begin
                    TempBlob.CreateOutStream(os);
                    os.WriteText(data);
                    ResponseCode := iStorage.UploadFile(Path, TempBlob);
                end;
            StorageFunction::ReadFile:
                begin
                    ResponseCode := iStorage.ReadFile(Path, ResultTxt);
                end;
            StorageFunction::DeleteFile:
                begin
                    ResponseCode := iStorage.DeleteFile(Path);
                end;
            StorageFunction::RenameFile:
                begin
                    ResponseCode := iStorage.RenameFile(Path, Path2);
                end;
            StorageFunction::CopyFile:
                begin
                    ResponseCode := iStorage.CopyFile(Path, Path2);
                end;
            StorageFunction::MoveFile:
                begin
                    ResponseCode := iStorage.MoveFile(Path, Path2);
                end;
            StorageFunction::GetFiles:
                begin
                    ResponseCode := iStorage.GetFiles(Path, Result);
                    Result.WriteTo(ResultTxt);
                end;
            StorageFunction::CreateFolder:
                begin
                    ResponseCode := iStorage.CreateFolder(Path);
                end;
            StorageFunction::DeleteFolder:
                begin
                    ResponseCode := iStorage.DeleteFolder(Path, force);
                end;
            StorageFunction::MoveFolder:
                begin
                    ResponseCode := iStorage.MoveFolder(Path, Path2);
                end;
        end;
    end;
}
