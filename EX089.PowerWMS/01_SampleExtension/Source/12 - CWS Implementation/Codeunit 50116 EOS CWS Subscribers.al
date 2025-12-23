codeunit 50116 "EOS CWS Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS CWS Receipt Mgmt", OnBeforeConfirmWhseReceiptPost, '', false, false)]
    local procedure CU18122382_OnBeforeConfirmWhseReceiptPost(var WhseReceiptLine: Record "Warehouse Receipt Line"; var HideDialog: Boolean; var IsPosted: Boolean; PrintOption: Option None,Print,"Pr. Pos.")
    var
        TempEOS089WMSSourceInformation: Record "EOS089 WMS Source Information" temporary;
        EOS089WMSIntActionInfo: Codeunit "EOS089 WMS Int. Action Info";
    begin
        if not EOS089WMSIntActionInfo.IsPowerWMS() then
            exit;

        if EOS089WMSIntActionInfo.GetCurrentAction() <> Enum::"EOS089 WMS Interface Action"::PostSource then
            exit;

        if EOS089WMSIntActionInfo.GetCurrentActivity() <> Enum::"EOS089 WMS Activity Type"::"Warehouse Receipt" then
            exit;

        TempEOS089WMSSourceInformation := EOS089WMSIntActionInfo.GetCurrentSourceInfo();
        if TempEOS089WMSSourceInformation."Source Type" <> Database::"Warehouse Receipt Header" then
            exit;

        if TempEOS089WMSSourceInformation."Source ID" <> WhseReceiptLine."No." then
            exit;

        HideDialog := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS CWS Shipment Mgmt", OnBeforeConfirmWhseShipmentPost, '', false, false)]
    local procedure CU18122370_OnBeforeConfirmWhseShipmentPost(var WhseShptLine: Record "Warehouse Shipment Line"; var HideDialog: Boolean; var Invoice: Boolean; var IsPosted: Boolean)
    var
        TempEOS089WMSSourceInformation: Record "EOS089 WMS Source Information" temporary;
        EOS089WMSIntActionInfo: Codeunit "EOS089 WMS Int. Action Info";
    begin
        if not EOS089WMSIntActionInfo.IsPowerWMS() then
            exit;

        if EOS089WMSIntActionInfo.GetCurrentAction() <> Enum::"EOS089 WMS Interface Action"::PostSource then
            exit;

        if EOS089WMSIntActionInfo.GetCurrentActivity() <> Enum::"EOS089 WMS Activity Type"::"Warehouse Shipment" then
            exit;

        TempEOS089WMSSourceInformation := EOS089WMSIntActionInfo.GetCurrentSourceInfo();
        if TempEOS089WMSSourceInformation."Source Type" <> Database::"Warehouse Shipment Header" then
            exit;

        if TempEOS089WMSSourceInformation."Source ID" <> WhseShptLine."No." then
            exit;

        HideDialog := true;
    end;
}
