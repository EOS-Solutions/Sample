codeunit 50000 "EOS DCS Sample"
{

    local procedure ReadFile(RecRef: RecordRef)
    var
        TempCurrRec: Record "EOS Record Ident. Buffer" temporary;
        DocSolutionsDocLibrary: Record "EOS069 DocLibrary";
        DCSLibraryTableLink: Record "EOS069 Library Table Link";
        DCSFileBuffer: Record "EOS069 File Buffer" temporary;
        iStorage: interface "EOS069 DCS IStorage v2";
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
        iStorage: interface "EOS069 DCS IStorage v2";
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
        iStorage.SetMetadata(FileUpload, TempCurrRec);
        iStorage.UploadFile(FileUpload);
    end;

    local procedure TransferAttachmentsBetweenRec(SourceDocument: Variant; Document: Variant)
    var
        FromRecIdBuf: Record "EOS Record Ident. Buffer";
        ToRecIdBuf: Record "EOS Record Ident. Buffer";
        DocSolutionsManagement: Codeunit "EOS069 DocSolutions Management";
        recRef: RecordRef;
    begin
        FromRecIdBuf.GetTable(SourceDocument);
        ToRecIdBuf.GetTable(Document);

        if IsNullGuid(FromRecIdBuf."Source GUID") then begin
            recRef.GetTable(SourceDocument);
            FromRecIdBuf."Source GUID" := recRef.Field(recRef.SystemIdNo()).Value();
            //FromRecIdBuf.Modify();
            recRef.Close();
        end;
        if IsNullGuid(ToRecIdBuf."Source GUID") then begin
            recRef.GetTable(Document);
            ToRecIdBuf."Source GUID" := recRef.Field(recRef.SystemIdNo()).Value();
            // ToRecIdBuf.Modify();
            recRef.Close();
        end;


        DocSolutionsManagement.TransferMetadata(FromRecIdBuf, ToRecIdBuf);
    end;
}
