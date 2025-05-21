enumextension 50102 "EOS Create Whse. Shipments" extends "EOS089 WMS Activity Type"
{
    value(50102; EOSCreateWhseShipments)
    {
        Caption = 'Create Warehouse Shipments';
        Implementation = "EOS089 WMS Activity Interface V5" = "EOS Create Whse. Ships. Impl.";
    }
}
