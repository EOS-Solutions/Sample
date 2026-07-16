codeunit 50124 "EOS SequentialCustom" implements "EOS089 WMS Custom Barcode Int."
{
    // Sequential barcode check. If Item id Token from PowerApp contains a separator, return Item Id and Variant Code
    // Sequential barcode required.
    // Mandatory:
    // EnumExt for "Barcode Type"
    // Token:
    //  - Free Text 1 (used as "Bin Code")
    //  - Item Id

    procedure Decode(Barcode: Text; var BarcodeTokens: Dictionary of [Enum "EOS089 WMS Barcode Part", Text])
    var
        ja: JsonArray;
        jo: JsonObject;
        jt, jt2 : JsonToken;
        Part: Enum "EOS089 WMS Barcode Part";
        ItemId: Text;
        ItemTokens: List of [Text];
    begin
        ja.ReadFrom(Barcode);
        foreach jt in ja do begin
            jo := jt.AsObject();
            jo.Get('key', jt2);
            Part := Enum::"EOS089 WMS Barcode Part".FromInteger(jt2.AsValue().AsInteger());
            jo.Get('value', jt2);

            case Part of
                Enum::"EOS089 WMS Barcode Part"::"Item Id":
                    begin
                        ItemId := jt2.AsValue().AsText();
                        if ItemId.Contains('|') then begin
                            ItemTokens := ItemId.Split('|');
                            BarcodeTokens.Add(Enum::"EOS089 WMS Barcode Part"::"Item Id", ItemTokens.Get(1));
                            BarcodeTokens.Add(Enum::"EOS089 WMS Barcode Part"::"Variant Code", ItemTokens.Get(2));
                        end else
                            BarcodeTokens.Add(Part, jt2.AsValue().AsText());
                    end;
                Enum::"EOS089 WMS Barcode Part"::LineNo:
                    BarcodeTokens.Add(Part, Format(jt2.AsValue().AsInteger()));
                Enum::"EOS089 WMS Barcode Part"::Quantity:
                    BarcodeTokens.Add(Part, Format(jt2.AsValue().AsDecimal()));
                else
                    BarcodeTokens.Add(Part, jt2.AsValue().AsText());
            end;
        end;

    end;

}
