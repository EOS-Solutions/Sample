// examle of how to use the legacy iStorage interface
// this has been extracted into a dedicated page from Page 50000 for better comparability with the new IFileSystem interface

#pragma warning disable AL0432
page 50001 "EOS004 FunctionApi FS"
{
    PageType = Card;
    ApplicationArea = All;
    SaveValues = true;
    UsageCategory = Administration;
    Caption = 'EAL FunctionApi FS';

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
                    StorageTest();
                    CurrPage.Update();
                end;
            }
        }
    }

    var
        StorageFunction: Option " ",UploadFile,ReadFile,DeleteFile,RenameFile,CopyFile,MoveFile,GetFiles,CreateFolder,DeleteFolder,MoveFolder;
        StorageType: Enum "EOS004 iStorage Type";
        ResponseCode: Enum "EOS004 Storage Response Status";
        ServiceConfigCode, ProtectPDFCode : Code[20];
        force, skipVerification : Boolean;
        Path, Path2, data : Text;
        ResultTxt: Text;

    local procedure StorageTest()
    var
        iStorage: Interface "EOS004 iStorage v2";
        ServiceConfig: Record "EOS004 Service Config.";
        TempBlob: Codeunit "Temp Blob";
        Result: JsonArray;
        os: OutStream;
        is: InStream;
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
                    Clear(ResultTxt);
                    ResponseCode := iStorage.ReadFile(Path, is);
                    is.ReadText(ResultTxt);
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
#pragma warning restore AL0432