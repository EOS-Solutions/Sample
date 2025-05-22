codeunit 50104 "EOS Custom Barcode Switch" implements "EOS089 WMS Custom Barcode Int."
{

    procedure Decode(Barcode: Text; var BarcodeTokens: Dictionary of [Enum "EOS089 WMS Barcode Part", Text])
    var
        ListOfStrings: List of [Text];
        SingleText: Text;
    begin
        if Barcode.Contains('$') then begin
            ListOfStrings := Barcode.Split('$');
            ListOfStrings.Get(1, SingleText);
            BarcodeTokens.Add(Enum::"EOS089 WMS Barcode Part"::"Item Id", SingleText);
            ListOfStrings.Get(2, SingleText);
            BarcodeTokens.Add(Enum::"EOS089 WMS Barcode Part"::Tracking, SingleText);
            ListOfStrings.Get(3, SingleText);
            BarcodeTokens.Add(Enum::"EOS089 WMS Barcode Part"::Quantity, SingleText);
        end else
            BarcodeTokens.Add(Enum::"EOS089 WMS Barcode Part"::EOSHandlingUnitNo, Barcode);
    end;

}
