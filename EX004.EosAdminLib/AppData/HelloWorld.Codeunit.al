codeunit 50100 HelloWorld
{

    var
        AppData: Codeunit "EOS004 AppData Reader";

    procedure InstallFiles1()
    var
        Language: Codeunit Language;
        ja: JsonArray;
    begin
        // this will download the file from the following URL:
        // https://raw.githubusercontent.com/EOS-Solutions/Defaults/master/AppData/<your-app-id>/it/some-folder/some-file.json

        // this will our custom app as the app id
        AppData.SetAppFromCaller();
        // download things in italian
        AppData.LanguageById(1040);
        // download the file and parse it as a JSON array
        AppData.DownloadFileAsJsonArray('some-folder', 'some-file.json', ja);
    end;

    procedure InstallFiles2()
    var
        Language: Codeunit Language;
        TempBlob: Codeunit "Temp Blob";
    begin
        // this will download the file from the following URL:
        // https://raw.githubusercontent.com/EOS-Solutions/Defaults/master/AppData/<your-app-id>/de/some-pdf.pdf

        // this will our custom app as the app id
        AppData.SetAppFromCaller();
        // download things in german
        AppData.LanguageByCode('DEU');
        // download the file as a BLOB
        AppData.DownloadFileAsBlob('', 'some-pdf.pdf', TempBlob);
    end;

    procedure InstallFiles3()
    var
        Language: Codeunit Language;
        Result: Text;
        mi: ModuleInfo;
    begin
        // this will download the file from the following URL:
        // https://raw.githubusercontent.com/EOS-Solutions/Defaults/preview/AppData/<your-app-id>/subfolder/readme.md

        // get the current app metadata
        NavApp.GetCurrentModuleInfo(mi);
        AppData.App(mi);
        // we want to access preview data, and not only the master branch
        AppData.BranchName('preview');
        // download the file as plain text
        AppData.DownloadFileAsText('subfolder', 'readme.md', Result);
    end;

}