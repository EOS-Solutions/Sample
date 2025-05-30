pageextension 50103 "EOS Scanner Ref. List" extends "EOS089 WMS Scanner Ref. List"
{
    layout
    {
        // Hide standard field that contains only selected standard supported activities
        modify("Activity Type")
        {
            Visible = false;
        }
        // Add custom field with standard activities and your custom activities that needs scanner reference management
        addafter("Activity Type")
        {
            field("EOS Activity Type"; Rec."Activity Type")
            {
                ApplicationArea = All;
                ToolTip = 'Activity Type';
                ValuesAllowed = /* This is a sample, please set the property on one line :-)
                                    You can hide standard supported activities. 
                                    If you add other activities, you won't be able to use it! */
                                    "Purchase Receipt", "Sales Return Shipment",
                                    "Sales Shipment", "Purchase Return Shipment",
                                    "Warehouse Receipt", "Warehouse Shipment"
                                    /* Add your custom activities here */
                                    , EOSCreateTransferOrder;
            }
        }
    }
}
