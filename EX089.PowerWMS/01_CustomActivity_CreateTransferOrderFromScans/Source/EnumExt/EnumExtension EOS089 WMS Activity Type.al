enumextension 50000 "EOS Custom Activity" extends "EOS089 WMS Activity Type"
{
    value(50000; EOSCreateTransferOrder)
    {
        Caption = 'Create Transfer Order';
        Implementation = "EOS089 WMS Activity Interface V5" = "EOS Create Trans. Order Impl.";
    }
}
