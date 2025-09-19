enumextension 50106 "EOS HU Management" extends "EOS089 WMS Activity Type"
{

    value(50106; EOSHUOnCustom)
    {
        Caption = 'Handling Units On Custom';
        Implementation = "EOS089 WMS Activity Interface V5" = "EOS HU On Custom Impl.";
    }
}
