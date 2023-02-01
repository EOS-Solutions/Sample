codeunit 50000 "EOS DCS Sample"
{

    local procedure ReadFile(RecRef: RecordRef)
    var
        TempCurrRec: Record "EOS Record Ident. Buffer" temporary;
        DocSolutionsDocLibrary: Record "EOS069 DocLibrary";
        DCSLibraryTableLink: Record "EOS069 Library Table Link";
        DCSFileBuffer: Record "EOS069 File Buffer" temporary;
        iStorage: interface "EOS069 DCS iStorage";
    begin
        TempCurrRec.GetTable(RecRef);

        //workaround for older version of Administration Library
        if IsNullGuid(TempCurrRec."Source GUID") then begin
            TempCurrRec."Source GUID" := recRef.Field(recRef.SystemIdNo()).Value();
            recRef.Close();
        end;

        DCSFileBuffer.Reset();
        DCSFileBuffer.DeleteAll();

        DCSLibraryTableLink.SetRange("Table ID", TempCurrRec."Source Type");
        DCSLibraryTableLink.SetRange("Table Option Type", TempCurrRec."Source Subtype");
        DCSLibraryTableLink.SetAutoCalcFields(Enabled, "Storage Type");
        if DCSLibraryTableLink.FindSet() then
            repeat
                if (DCSLibraryTableLink."Storage Type" <> DCSLibraryTableLink."Storage Type"::" ") and DCSLibraryTableLink.Enabled then
                    DocSolutionsDocLibrary.Get(DCSLibraryTableLink."Library Code");

                iStorage := DocSolutionsDocLibrary."Storage Type";
                iStorage.SetCurrDocLibrary(DocSolutionsDocLibrary);
                iStorage.GetFiles(DCSFileBuffer, TempCurrRec, false);
            until DCSLibraryTableLink.Next() = 0;
    end;

    local procedure OtherOperations(RecRef: RecordRef)
    var
        DCSFileBuffer, FileUpload : Record "EOS069 File Buffer" temporary;
        iStorage: interface "EOS069 DCS iStorage";
        TempCurrRec: Record "EOS Record Ident. Buffer" temporary;
        DocSolutionsDocLibrary: Record "EOS069 DocLibrary";


        Base64Convert: Codeunit "Base64 Convert";
        os: OutStream;
    begin
        TempCurrRec.GetTable(RecRef);

        //workaround for older version of Administration Library
        if IsNullGuid(TempCurrRec."Source GUID") then begin
            TempCurrRec."Source GUID" := recRef.Field(recRef.SystemIdNo()).Value();
            recRef.Close();
        end;

        iStorage := DocSolutionsDocLibrary."Storage Type";
        iStorage.SetCurrDocLibrary(DocSolutionsDocLibrary);

        iStorage.DeleteFile(DCSFileBuffer);


        FileUpload.Init();
        FileUpload."Entry No." := FileUpload.NextEntryNo();
        FileUpload."Source Type" := TempCurrRec."Source Type";
        FileUpload."Source Subtype" := TempCurrRec."Source Subtype";
        FileUpload."System ID" := TempCurrRec."Source GUID";
        FileUpload."File Name" := CopyStr('a filename.txt', 1, MaxStrLen(FileUpload."File Name"));
        FileUpload."File Content".CreateOutStream(os);
        //Base64Convert.FromBase64(Base64Blob, os);
        //UploadIntoStream()
        FileUpload.Insert(true);
        iStorage.SetMetadata(DCSFileBuffer, TempCurrRec);
        iStorage.UploadFile(DCSFileBuffer);
    end;
}
