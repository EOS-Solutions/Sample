// examle of how to use the new IFileSystem interface
// this has been extracted into a dedicated page from Page 50000 for better comparability with the legacy iStorage interface

page 50002 "EOS004 FunctionApi FS NEW"
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
                field(FileSystemTypeField; FileSystemType)
                {
                    ApplicationArea = All;
                }
                field("Service Config"; ServiceConfigCode)
                {
                    ApplicationArea = all;
                    TableRelation = "EOS004 Service Config.".Code where(Type = const("EOS FunctionApi"));
                }
            }
            group("iStorage")
            {
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
                field(LastError; GetLastErrorText())
                {
                    MultiLine = true;
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
        FileSystemType: enum "EOS004 FileSystem";
        ServiceConfigCode, ProtectPDFCode : Code[20];
        force, skipVerification : Boolean;
        Path, Path2, data : Text;
        ResultTxt: Text;

    local procedure StorageTest()
    var
        fsw: Codeunit "EOS004 IFileSystem Wrapper";
        ServiceConfig: Record "EOS004 Service Config.";
        TempFSEntry: Record "EOS004 AzFS Entry" temporary;
        TempBlob: Codeunit "Temp Blob";
        Result: JsonArray;
        os: OutStream;
        is: InStream;
        Success: Boolean;
    begin
        ServiceConfig.get(ServiceConfigCode);
        fsw.Initialize(FileSystemType, ServiceConfig);
        case StorageFunction of
            StorageFunction::" ":
                Message('select a function');
            StorageFunction::UploadFile:
                begin
                    TempBlob.CreateOutStream(os);
                    os.WriteText(data);
                    Success := fsw.UploadFile(Path, TempBlob);
                end;
            StorageFunction::ReadFile:
                begin
                    Clear(ResultTxt);
                    Success := fsw.ReadFile(Path, TempBlob);
                    TempBlob.CreateInStream(is);
                    is.ReadText(ResultTxt);
                end;
            StorageFunction::DeleteFile:
                begin
                    Success := fsw.DeleteFile(Path);
                end;
            StorageFunction::RenameFile:
                begin
                    Success := fsw.RenameFile(Path, Path2);
                end;
            StorageFunction::CopyFile:
                begin
                    Success := fsw.CopyFile(Path, Path2);
                end;
            StorageFunction::MoveFile:
                begin
                    Success := fsw.MoveFile(Path, Path2);
                end;
            StorageFunction::GetFiles:
                begin
                    Success := fsw.GetFiles(Path, TempFSEntry);
                    ResultTxt := Format(TempFSEntry.Count());
                end;
            StorageFunction::CreateFolder:
                begin
                    Success := fsw.CreateFolder(Path);
                end;
            StorageFunction::DeleteFolder:
                begin
                    Success := fsw.DeleteFolder(Path, force);
                end;
            StorageFunction::MoveFolder:
                begin
                    Success := fsw.MoveFolder(Path, Path2);
                end;
        end;
        if (not Success) then
            ResultTxt := GetLastErrorText();
    end;
}