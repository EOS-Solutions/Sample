enumextension 50101 "EOS Create Trans. Order" extends "EOS089 WMS Activity Type"
{
    value(50101; EOSCreateTransferOrder)
    {
        Caption = 'Create Transfer Order';
        Implementation = "EOS089 WMS Activity Interface V5" = "EOS Create Trans. Order Impl.";
    }
}
