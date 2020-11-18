codeunit 61700 "EXA09 Custom Images on lines"
{

    // This example requires at least ADR version 1.0.228, 14.0.56 or 15.0.44

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnLineCustomFields', '', true, false)]
    local procedure OnLineCustomFields(HeaderRecRef: RecordRef;
                                           CurrentLineRecRef: RecordRef;
                                           var RBHeader: Record "EOS Report Buffer Header";
                                           var RBLine: Record "EOS Report Buffer Line";
                                           var TempAdvRptCustomFields: Record "EOS AdvRpt Custom Fields")
    var
        Item: Record Item;
        MediaID: Guid;
        TenantMedia: Record "Tenant Media";
        iStream: InStream;
        DotNet_Array: Codeunit DotNet_Array;
        DotNet_BinaryReader: Codeunit DotNet_BinaryReader;
        DotNet_Stream: Codeunit DotNet_Stream;
        DotNet_Convert: Codeunit DotNet_Convert;
        B64Text: Text;
    begin
        if RBHeader."EOS Report ID" <> report::"EOS Sales Document" then
            exit;

        if RBLine."EOS Type" <> RBLine."EOS Type"::Item then
            exit;
        if RBLine."EOS No." = '' then
            exit;

        if not Item.Get(RBLine."EOS No.") then
            exit;

        if item.Picture.Count = 0 then
            exit;

        MediaID := Item.Picture.Item(1);

        //Converting a picture stream to base 64 encoding without dotnet require some processing 
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);
        TenantMedia.Content.CreateInStream(iStream);

        //Converting from BC inStream to a generic dotnet stream
        DotNet_Stream.FromInStream(iStream);

        //Setup the binary reader to read from our dotnet stream
        DotNet_BinaryReader.BinaryReader(DotNet_Stream);

        //read all bytes from our dotnet stream with our binary reader to a dotnet array
        DotNet_BinaryReader.ReadBytes(DotNet_Stream.Length(), DotNet_Array);

        //converting the dotnetarray to a base64 encoded string
        B64Text := DotNet_Convert.ToBase64String(DotNet_Array);

        TempAdvRptCustomFields.InsertTextNameValue('CustomText20', B64Text);
    end;
}