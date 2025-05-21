codeunit 50106 "EOS Custom Document Mgmt."
{
    internal procedure CreateCustomDocument()
    var
        EOSCustomActivitySetup: Record "EOS Custom Activity Setup";
        Location: Record Location;
        EOS089WMSCustomActivityHeader: Record "EOS089 WMS Custom Act. Header";
        EOS089WMSCustomActivityLine: Record "EOS089 WMS Custom Act. Line";
        NoOfLines: Integer;
        i, j : Integer;
        LineNo: Integer;
    begin
        EOSCustomActivitySetup.Get();
        EOSCustomActivitySetup.TestField("Location Code");
        if Location.BinMandatory(EOSCustomActivitySetup."Location Code") then
            EOSCustomActivitySetup.TestField("Bin Code");
        EOSCustomActivitySetup.TestField("Item No. 1");
        EOSCustomActivitySetup.TestField("Item No. 2");
        EOSCustomActivitySetup.TestField("Item No. 3");

        EOS089WMSCustomActivityHeader.Init();
        EOS089WMSCustomActivityHeader."Activity Type" := "EOS089 WMS Activity Type"::EOSCreateBox;
        EOS089WMSCustomActivityHeader.Insert(true);
        EOS089WMSCustomActivityHeader.Validate("Location Code", EOSCustomActivitySetup."Location Code");
        if EOSCustomActivitySetup."Bin Code" <> '' then
            EOS089WMSCustomActivityHeader.Validate("Bin Code", EOSCustomActivitySetup."Bin Code");
        EOS089WMSCustomActivityHeader.Modify(true);

        for i := 1 to 3 do begin
            NoOfLines := Random(3);
            for j := 1 to NoOfLines do begin
                LineNo += 10000;
                EOS089WMSCustomActivityLine.Init();
                EOS089WMSCustomActivityLine."Activity Type" := "EOS089 WMS Activity Type"::EOSCreateBox;
                EOS089WMSCustomActivityLine."Document No." := EOS089WMSCustomActivityHeader."No.";
                EOS089WMSCustomActivityLine."Line No." := LineNo;
                case i of
                    1:
                        EOS089WMSCustomActivityLine.Validate("Item No.", EOSCustomActivitySetup."Item No. 1");
                    2:
                        EOS089WMSCustomActivityLine.Validate("Item No.", EOSCustomActivitySetup."Item No. 2");
                    3:
                        EOS089WMSCustomActivityLine.Validate("Item No.", EOSCustomActivitySetup."Item No. 3");
                end;
                EOS089WMSCustomActivityLine."Location Code" := EOSCustomActivitySetup."Location Code";
                EOS089WMSCustomActivityLine."Bin Code" := EOSCustomActivitySetup."Bin Code";
                EOS089WMSCustomActivityLine.Validate(Quantity, Random(10));
                EOS089WMSCustomActivityLine.Insert(true);
            end;
        end;
    end;

    // Init Tracking Fields
    [EventSubscriber(ObjectType::Table, Database::"EOS089 WMS Custom Act. Header", OnBeforeInsertEvent, '', false, false)]
    local procedure T18060040_OnBeforeInsertEvent(var Rec: Record "EOS089 WMS Custom Act. Header"; RunTrigger: Boolean)
    begin
        if Rec."Activity Type" <> Enum::"EOS089 WMS Activity Type"::EOSCreateBox then
            exit;

        Rec."Item Ledger Entry Type" := Rec."Item Ledger Entry Type"::Consumption;
        Rec.Inbound := false;
    end;
}
