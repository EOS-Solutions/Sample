/// <summary>
/// Gather all functions that handles specific hook code (i.e. GDO) specified in group setup
/// </summary>
codeunit 18123040 "EOS Outb. EDoc. Hook Handler"
{

    var
        OutbElectrDocSetupGroup: Record "EOS Outb. EDoc. Group Setup";
        TmpSalesHeader: Record "Sales Header" temporary;
        TmpShipHeader: Record "Sales Shipment Header" temporary;
        ReturnReceiptHeaderTMP: Record "Return Receipt Header" temporary;
        TmpServiceHeader: Record "Service Header" temporary;
        TmpServShipHeader: Record "Service Shipment Header" temporary;
        EOSEDocSetupMgt: Codeunit "EOS EDoc. Setup Management";
        DataTypeManagement: Codeunit "Data Type Management";
        EOSFEData: Codeunit "EOS FE Data";
        EOS066OptionalFeatureMgt: Codeunit "EOS066 Optional Feature Mgt.";
        ItemReferenceTok: Label 'ItemReference', Locked = true;

    procedure SetSalesInvoiceTmpBuffer(var inTmpSalesHeader: Record "Sales Header" temporary; var inTmpShipHeader: Record "Sales Shipment Header" temporary)
    begin
        if inTmpSalesHeader.FindSet(false, false) then
            repeat
                TmpSalesHeader := inTmpSalesHeader;
                TmpSalesHeader.Insert();
            until inTmpSalesHeader.Next() = 0;

        if inTmpShipHeader.FindSet(false, false) then
            repeat
                TmpShipHeader := inTmpShipHeader;
                TmpShipHeader.Insert();
            until inTmpShipHeader.Next() = 0;
    end;

    procedure SetSalesCrMemoTmpBuffer(var inReturnReceiptHeaderTMP: Record "Return Receipt Header" temporary)
    begin
        if inReturnReceiptHeaderTMP.FindSet(false, false) then
            repeat
                ReturnReceiptHeaderTMP := inReturnReceiptHeaderTMP;
                ReturnReceiptHeaderTMP.Insert();
            until inReturnReceiptHeaderTMP.Next() = 0;
    end;

    procedure SetServiceInvoiceTmpBuffer(var inTmpServiceHeader: Record "Service Header" temporary; var inTmpServShipHeader: Record "Service Shipment Header" temporary)
    begin
        if inTmpServiceHeader.FindSet(false, false) then
            repeat
                TmpServiceHeader := inTmpServiceHeader;
                TmpServiceHeader.Insert();
            until inTmpServiceHeader.Next() = 0;

        if inTmpServShipHeader.FindSet(false, false) then
            repeat
                TmpServShipHeader := inTmpServShipHeader;
                TmpServShipHeader.Insert();
            until inTmpServShipHeader.Next() = 0;
    end;

    procedure AlwaysExportPEC(CustNo: Code[20]; header: RecordRef) RetValue: Boolean
    var
    begin
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        RetValue :=
          OutbElectrDocSetupGroup."EOS Hook Group Code" in [
            'EOS_AMAZON'
          ];
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeAddCodiceArticolo', '', true, false)]
    local procedure OnBefore_CodiceArticolo(header: RecordRef; line: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var handled: Boolean)
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        DocumentLineTMP: Record "Sales Invoice Line" temporary;
        CompanyInfoPA: Record "EOS Outb. Electr. Doc. Setup";
        TempItemReference: Record "Item Reference" temporary;
        FldRef: FieldRef;
        DummyText: Text[20];
        CustNo: Code[20];
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        Handled := false;
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                AMAZON_OnBefore_CodiceArticolo(header, line, XmlWriter, handled);
            'EOS_BRICO_CENT':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'INTERNALCODE');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();

                            //CrossReference
                            if DocumentLineTMP."Item Reference No." <> '' then begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'articolobrico');
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."Item Reference No.");
                                XmlWriter.WriteEndElement();
                            end;
                        end;
                    end;
                    Handled := true;
                end;

            'EOS_CANOVA':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();

                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'INTERNALCODE');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_CARREFOUR':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            EOS066OptionalFeatureMgt.GetItemReferenceSet(DocumentLineTMP."No.", TempItemReference);
                            TempItemReference.SetFilter("Reference Type", '%1|%2',
                                TempItemReference."Reference Type"::"Bar Code", TempItemReference."Reference Type"::Customer);
                            if DocumentLineTMP."Item Reference No." <> '' then
                                TempItemReference.SetRange("Reference No.", DocumentLineTMP."Item Reference No.");
                            if TempItemReference.FindSet(false, false) then
                                repeat
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    case TempItemReference."Reference Type" of
                                        TempItemReference."Reference Type"::Customer:
                                            XmlWriter.WriteElementValue('CodiceTipo', 'BP');
                                        TempItemReference."Reference Type"::"Bar Code":
                                            XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                    end;
                                    XmlWriter.WriteElementValue('CodiceValore', TempItemReference."Reference No.");
                                    XmlWriter.WriteEndElement();

                                until TempItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_CHEF':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', '99');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();

                            EOS066OptionalFeatureMgt.GetItemReferenceSet(DocumentLineTMP."No.", TempItemReference);
                            TempItemReference.SetFilter("Reference Type", '%1|%2',
                                TempItemReference."Reference Type"::"Bar Code", TempItemReference."Reference Type"::Customer);
                            if DocumentLineTMP."Item Reference No." <> '' then
                                TempItemReference.SetRange("Reference No.", DocumentLineTMP."Item Reference No.");
                            if TempItemReference.FindSet(false, false) then
                                repeat
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    case TempItemReference."Reference Type" of
                                        TempItemReference."Reference Type"::Customer:
                                            XmlWriter.WriteElementValue('CodiceTipo', '01');
                                        TempItemReference."Reference Type"::"Bar Code":
                                            XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                    end;

                                    XmlWriter.WriteElementValue('CodiceValore', TempItemReference."Reference No.");
                                    XmlWriter.WriteEndElement();

                                until TempItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_UNICOOPTIR':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            EOS066OptionalFeatureMgt.GetItemReferenceSet(DocumentLineTMP."No.", TempItemReference);
                            TempItemReference.SetFilter("Reference Type", '%1', TempItemReference."Reference Type"::"Bar Code");
                            if DocumentLineTMP."Item Reference No." <> '' then
                                TempItemReference.SetRange("Reference No.", DocumentLineTMP."Item Reference No.");
                            if TempItemReference.FindSet(false, false) then
                                repeat
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                    XmlWriter.WriteElementValue('CodiceValore', TempItemReference."Reference No.");
                                    XmlWriter.WriteEndElement();
                                until TempItemReference.Next() = 0
                            else begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'Codice Uso Fornitore');
                                if DocumentLineTMP."Variant Code" <> '' then
                                    XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                                else
                                    XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                                XmlWriter.WriteEndElement();

                            end;
                        end;
                    end;
                    Handled := true;
                end;

            'EOS_CONAD_SIC', 'EOS_IGES', 'EOS_GS1':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin

                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'SA');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();

                            EOS066OptionalFeatureMgt.GetItemReferenceSet(DocumentLineTMP."No.", TempItemReference);
                            TempItemReference.SetFilter("Reference Type", '%1|%2',
                                TempItemReference."Reference Type"::"Bar Code", TempItemReference."Reference Type"::Customer);
                            if DocumentLineTMP."Item Reference No." <> '' then
                                TempItemReference.SetRange("Reference No.", DocumentLineTMP."Item Reference No.");
                            if TempItemReference.FindSet(false, false) then
                                repeat
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    case TempItemReference."Reference Type" of
                                        TempItemReference."Reference Type"::Customer:
                                            XmlWriter.WriteElementValue('CodiceTipo', 'IN');
                                        TempItemReference."Reference Type"::"Bar Code":
                                            XmlWriter.WriteElementValue('CodiceTipo', 'EN');
                                    end;
                                    XmlWriter.WriteElementValue('CodiceValore', TempItemReference."Reference No.");
                                    XmlWriter.WriteEndElement();
                                until TempItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_COOPALL3':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin

                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'Codice Art. Fornitore');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();


                            EOS066OptionalFeatureMgt.GetItemReferenceSet(DocumentLineTMP."No.", TempItemReference);
                            TempItemReference.SetFilter("Reference Type", '%1|%2',
                                TempItemReference."Reference Type"::"Bar Code", TempItemReference."Reference Type"::Customer);
                            if DocumentLineTMP."Item Reference No." <> '' then
                                TempItemReference.SetRange("Reference No.", DocumentLineTMP."Item Reference No.");
                            if TempItemReference.FindSet(false, false) then
                                repeat
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    XmlWriter.WriteElementValue('CodiceTipo', 'articolobrico');
                                    case TempItemReference."Reference Type" of
                                        TempItemReference."Reference Type"::Customer:
                                            XmlWriter.WriteElementValue('CodiceTipo', 'Codice Art. Cliente');
                                        TempItemReference."Reference Type"::"Bar Code":
                                            XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                    end;

                                    XmlWriter.WriteElementValue('CodiceValore', TempItemReference."Reference No.");
                                    XmlWriter.WriteEndElement();

                                until TempItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_METRO':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'cod');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();
                        end;
                    end;
                    Handled := true;
                end;

            'EOS_AUTOGRILL':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'GDS');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();
                        end;
                    end;
                    Handled := true;
                end;

            'EOS_RIALTO':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'SA');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();


                            EOS066OptionalFeatureMgt.GetItemReferenceSet(DocumentLineTMP."No.", TempItemReference);
                            TempItemReference.SetFilter("Reference Type", '%1|%2',
                                TempItemReference."Reference Type"::"Bar Code", TempItemReference."Reference Type"::Customer);
                            if DocumentLineTMP."Item Reference No." <> '' then
                                TempItemReference.SetRange("Reference No.", DocumentLineTMP."Item Reference No.");
                            if TempItemReference.FindSet(false, false) then
                                repeat
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    case TempItemReference."Reference Type" of
                                        TempItemReference."Reference Type"::Customer:
                                            XmlWriter.WriteElementValue('CodiceTipo', 'BP');
                                        TempItemReference."Reference Type"::"Bar Code":
                                            XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                    end;
                                    XmlWriter.WriteElementValue('CodiceValore', TempItemReference."Reference No.");
                                    XmlWriter.WriteEndElement();

                                until TempItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_FERRARI':
                // CodiceValore:
                // Commessa primi 9 caratteri + codice articolo ordine Ferrari. Nei 9 caratteri riservati alla commessa
                // il valore deve essere allineato a sinistra, riempiendo i campi vuoti di commessa con BLANK. Commessa di riga fattura
                // Creare routine custom per gestire stringa

                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Job No."));
                        DocumentLineTMP."Job No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
                        DocumentLineTMP."Item Reference No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin

                            // Create string following Ferrari request
                            DummyText := CopyStr(PadStr(DocumentLineTMP."Job No.", 9, ' ') + DocumentLineTMP."Item Reference No.", 1, 20);

                            if DummyText <> '' then begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'CODICE');
                                XmlWriter.WriteElementValue('CodiceValore', DummyText);
                                XmlWriter.WriteEndElement();
                            end;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_OBI', 'EOS_BRICO_SELF':
                if line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(DocumentTMP);
                        Clear(DocumentLineTMP);

                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                        DocumentTMP."No." := FldRef.Value();

                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
                        DocumentLineTMP."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
                        DocumentLineTMP.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
                        DocumentLineTMP."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
                        DocumentLineTMP."No." := FldRef.Value();

                        if DocumentLineTMP.Type = DocumentLineTMP.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'SA');
                            if DocumentLineTMP."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No." + ' ' + DocumentLineTMP."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
                            XmlWriter.WriteEndElement();
                        end;
                    end;
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeAddElementText', '', true, false)]
    local procedure OnFillCommConvDatiOdA(header: RecordRef; line: RecordRef; var elementName: Text[250]; id: Text; var Value: Text; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        BufferTMP: Record "EOS RifLineNo Buffer" temporary;
        headerOrder: Record "Sales Header";
        ShiptoAddress: Record "Ship-to Address";
        Customer: Record Customer;
        FldRef: FieldRef;
        NotDirectShip: Boolean;
        CustNo: Code[20];
        orderNo: code[20];
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        if id = '2.1.2.5' then begin
            if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
                exit;
            NotDirectShip := line.Number() = Database::"EOS RifLineNo Buffer";
            case OutbElectrDocSetupGroup."EOS Hook Group Code" of

                'EOS_OTTIMAX':
                    begin
                        orderNo := line.Field(BufferTMP.FieldNo("EOS Order No.")).Value();
                        headerOrder.SetRange("No.", orderNo);
                        if (not NotDirectShip) or headerOrder.IsEmpty then begin
                            DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No."));
                            DocumentTMP."Sell-to Customer No." := FldRef.Value();
                            DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code"));
                            DocumentTMP."Ship-to Code" := FldRef.Value();
                        end else begin
                            headerOrder.FindSet();

                            DocumentTMP."Sell-to Customer No." := headerOrder."Sell-to Customer No.";
                            DocumentTMP."Ship-to Code" := headerOrder."Ship-to Code";
                        end;
                        if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                            Clear(ShiptoAddress);
                        if ShiptoAddress."EOS Store Code" <> '' then
                            Value := ShiptoAddress."EOS Store Code"
                        else begin
                            Customer.get(DocumentTMP."Sell-to Customer No.");
                            Value := Customer."EOS Store Code";
                        end;
                    end;

            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnFillElectrDocRelatedDocsBuffer', '', true, false)]
    local procedure OnFillElectrDocRelatedDocsBuffer(header: RecordRef; var ElectrDocRelatedDocsTMP: Record "EOS Outb. EDoc. Related Docs." temporary)
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
        FldRef: FieldRef;
        CustNo: Code[20];
        LineNo: Integer;
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;
        if not ElectrDocRelatedDocsTMP.FindLast() then
            LineNo := 10000
        else
            LineNo := ElectrDocRelatedDocsTMP."EOS Line No.";

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_METRO':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                    DocumentTMP."No." := FldRef.Value();

                    // Codice o ILN fornitore
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Bill-to Customer No."));
                    DocumentTMP."Bill-to Customer No." := FldRef.Value();
                    Customer.Get(DocumentTMP."Bill-to Customer No.");

                    // Codice o ILN store
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No."));
                    DocumentTMP."Sell-to Customer No." := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code"));
                    DocumentTMP."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        LineNo += 10000;
                        ElectrDocRelatedDocsTMP.Init();
                        ElectrDocRelatedDocsTMP."EOS Table ID" := header.Number();
                        ElectrDocRelatedDocsTMP."EOS Document Type" := 0;
                        ElectrDocRelatedDocsTMP."EOS Document No." := DocumentTMP."No.";
                        ElectrDocRelatedDocsTMP."EOS Document RecordID" := header.RecordId();
                        ElectrDocRelatedDocsTMP."EOS Type" := ElectrDocRelatedDocsTMP."EOS Type"::DatiRicezione;
                        ElectrDocRelatedDocsTMP."EOS IdDocumento" := ShiptoAddress."EOS Store Code";
                        ElectrDocRelatedDocsTMP."EOS NumItem" := 'store';
                        ElectrDocRelatedDocsTMP."EOS Line No." := LineNo;
                        ElectrDocRelatedDocsTMP.Insert(true);
                    end;
                end;

            'EOS_AGRINTESA':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                    DocumentTMP."No." := FldRef.Value();

                    LineNo += 10000;
                    ElectrDocRelatedDocsTMP.Init();
                    ElectrDocRelatedDocsTMP."EOS Table ID" := header.Number();
                    ElectrDocRelatedDocsTMP."EOS Document Type" := 0;
                    ElectrDocRelatedDocsTMP."EOS Document No." := DocumentTMP."No.";
                    ElectrDocRelatedDocsTMP."EOS Document RecordID" := header.RecordId();
                    ElectrDocRelatedDocsTMP."EOS Type" := ElectrDocRelatedDocsTMP."EOS Type"::DatiRicezione;
                    ElectrDocRelatedDocsTMP."EOS IdDocumento" := DocumentTMP."No.";
                    ElectrDocRelatedDocsTMP."EOS Line No." := LineNo;
                    ElectrDocRelatedDocsTMP.Insert(true);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnAddAltriDatiGestionali_2_2_1_16', '', true, false)]
    local procedure OnFillAltriDatiGestionaliTag(header: RecordRef; line: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        DocumentLineTMP: Record "Sales Invoice Line" temporary;
        ShiptoAddress: Record "Ship-to Address";
        Customer: Record Customer;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        DimensionManagement: Codeunit DimensionManagement;
        FldRef: FieldRef;
        HeaderDone: Boolean;
        CustNo: Code[20];
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;


        case OutbElectrDocSetupGroup."EOS Hook Group Code" of

            'EOS_LEROY':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Description" := Customer."EOS Store Description";
                    end;

                    if ShiptoAddress."EOS Store Description" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'Negozio');
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Description" <> '', 'RiferimentoTesto', ShiptoAddress."EOS Store Description");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_BRICO_IO':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        exit;

                    XmlWriter.WriteStartElement('AltriDatiGestionali');
                    XmlWriter.WriteElementValue('TipoDato', 'CDC');
                    XmlWriter.WriteElementValueIf(ShiptoAddress.Name <> '', 'RiferimentoTesto', ShiptoAddress.Name);
                    XmlWriter.WriteEndElement();
                end;

            'EOS_CANOVA', 'EOS_CARREFOUR', 'EOS_RIALTO':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Code" <> '', 'RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_ESSELUNGA':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();

                    if Line.Number() = DATABASE::"Sales Invoice Line" then begin
                        DataTypeManagement.FindFieldByName(Line, FldRef, SalesInvoiceLine.FieldName("Shipment No."));
                        DocumentTMP."Order No." := FldRef.Value();
                        if SalesShipmentHeader.Get(DocumentTMP."Order No.") then
                            if SalesShipmentHeader."Ship-to Code" <> '' then
                                DocumentTMP."Ship-to Code" := SalesShipmentHeader."Ship-to Code";
                    end else
                        if Line.Number() = DATABASE::"Sales Cr.Memo Line" then begin
                            DataTypeManagement.FindFieldByName(Line, FldRef, SalesCrMemoLine.FieldName("Return Receipt No."));
                            DocumentTMP."Order No." := FldRef.Value();
                            if ReturnReceiptHeader.Get(DocumentTMP."Order No.") then
                                if ReturnReceiptHeader."Ship-to Code" <> '' then
                                    DocumentTMP."Ship-to Code" := ReturnReceiptHeader."Ship-to Code";
                        end;

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Code" <> '', 'RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_CAMST':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(Line, FldRef, DocumentLineTMP.FieldName("Dimension Set ID")) then
                        DocumentTMP."Dimension Set ID" := FldRef.Value();
                    if DocumentTMP."Dimension Set ID" = 0 then
                        exit;

                    DimensionManagement.GetDimensionSet(TempDimSetEntry, DocumentTMP."Dimension Set ID");
                    TempDimSetEntry.SetRange("Dimension Code", 'CDCCAMST'); // Centro di Costo fornito da CAMST
                    if TempDimSetEntry.FindFirst() then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'PLANT');
                        XmlWriter.WriteElementValue('RiferimentoTesto', TempDimSetEntry."Dimension Value Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_CONAD_SIC', 'EOS_IGES':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();
                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" + ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                        ShiptoAddress."EOS Store Description" := Customer."EOS Store Description";
                    end;

                    if ShiptoAddress."EOS Store Description" + ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'PCONSEGNA');
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Code" <> '', 'RiferimentoNumero', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Description" <> '', 'RiferimentoTesto', ShiptoAddress."EOS Store Description");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_COOPALL3':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();
                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" + ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                        ShiptoAddress."EOS Store Description" := Customer."EOS Store Description";
                    end;

                    // GLN code
                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        if not HeaderDone then begin
                            XmlWriter.WriteStartElement('AltriDatiGestionali');
                            HeaderDone := true;
                        end;
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Code");
                    end;

                    // Store Description
                    if ShiptoAddress."EOS Store Description" <> '' then begin
                        if not HeaderDone then begin
                            XmlWriter.WriteStartElement('AltriDatiGestionali');
                            HeaderDone := true;
                        end;
                        XmlWriter.WriteElementValue('TipoDato', 'DEST.MERCI');
                        XmlWriter.WriteElementValue('RiferimentoTesto', CopyStr(ShiptoAddress."EOS Store Description", 1, 60));

                    end;

                    // Store Address
                    if ShiptoAddress.Address <> '' then begin
                        if not HeaderDone then begin
                            XmlWriter.WriteStartElement('AltriDatiGestionali');
                            HeaderDone := true;
                        end;
                        XmlWriter.WriteElementValue('TipoDato', 'INDIRIZZO');
                        XmlWriter.WriteElementValue('RiferimentoTesto', CopyStr(ShiptoAddress.Address + ' ' + ShiptoAddress."Post Code" + ' ' + ShiptoAddress.County, 1, 60));
                    end;
                    if HeaderDone then
                        XmlWriter.WriteEndElement();
                end;

            'EOS_UNICOOPTIR':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();
                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress.Address + ShiptoAddress.City + ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'CPV');
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Code" <> '', 'RiferimentoNumero', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteElementValueIf(((ShiptoAddress.Address <> '') or (ShiptoAddress.City <> '')), 'RiferimentoTesto', ShiptoAddress.Address + ' ' + ShiptoAddress.City);
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_AUTOGRILL':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'PV');
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Code" <> '', 'RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_CHEF':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" + ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                        ShiptoAddress."EOS Store Description" := Customer."EOS Store Description";
                    end;

                    if ShiptoAddress."EOS Store Description" + ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValueIf((ShiptoAddress."EOS Store Description" + ShiptoAddress."EOS Store Code") <> '', 'RiferimentoTesto', ShiptoAddress."EOS Store Description" + ' - ' + ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_OBI':
                if Line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"] then begin
                    Clear(DocumentTMP);
                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Sell-to Customer No.")) then
                        DocumentTMP."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Code")) then
                        DocumentTMP."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(DocumentTMP."Sell-to Customer No.", DocumentTMP."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.get(DocumentTMP."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValueIf(ShiptoAddress."EOS Store Code" <> '', 'RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeAddCausaleTags', '', true, false)]
    local procedure OnFillCausaleTag(header: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var handled: Boolean)
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        ReasonCode: Record "Reason Code";
        FldRef: FieldRef;
        CustNo: Code[20];
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                IF header.NUMBER() IN [DATABASE::"Sales Cr.Memo Header"] THEN begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FIELDNAME("Reason Code"));
                    DocumentTMP."Reason Code" := FldRef.VALUE();
                    IF DocumentTMP."Reason Code" <> '' THEN
                        IF ReasonCode.GET(DocumentTMP."Reason Code") THEN
                            XmlWriter.WriteElementValueIf(ReasonCode."EOS AMZ Exp. To EDoc.", 'Causale', ReasonCode.Code);
                END;
            'EOS_CARREFOUR':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Reason Code"));
                    DocumentTMP."Reason Code" := FldRef.Value();

                    // Check reasons mapped as "MERCI", "FRANCHISING", "EXTRAFATTURA" or customize
                    XmlWriter.WriteElementValueIf(ReasonCode.Get(DocumentTMP."Reason Code"), 'Causale', ReasonCode.Description);
                end;

            'EOS_CONAD_SIC', 'EOS_IGES':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Reason Code"));
                    DocumentTMP."Reason Code" := FldRef.Value();

                    // Check reasons mapped as "MAGAZZINO", "RIFATTURAZIONE", "SERVIZI" or customize
                    XmlWriter.WriteElementValueIf(ReasonCode.Get(DocumentTMP."Reason Code"), 'Causale', ReasonCode.Description);
                end;

            'EOS_UNICOOPTIR':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Reason Code"));
                    DocumentTMP."Reason Code" := FldRef.Value();

                    // Check reasons mapped as "M" (merci), "S" (servizi) or customize
                    XmlWriter.WriteElementValueIf(ReasonCode.Get(DocumentTMP."Reason Code"), 'Causale', ReasonCode.Description);
                end;

            'EOS_COOPALL3':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Reason Code"));
                    DocumentTMP."Reason Code" := FldRef.Value();

                    XmlWriter.WriteElementValueIf(ReasonCode.Get(DocumentTMP."Reason Code"), 'Causale', ReasonCode.Description);

                end;

            'EOS_STEFF':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Reason Code"));
                    DocumentTMP."Reason Code" := FldRef.Value();

                    // Check reasons mapped as "DANNI_", "GEN_" or customize
                    XmlWriter.WriteElementValueIf(ReasonCode.Get(DocumentTMP."Reason Code"), 'Causale', ReasonCode.Description);
                end;

            'EOS_ASCA', 'EOS_MARR':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Name"));
                    DocumentTMP."Ship-to Name" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Name 2"));
                    DocumentTMP."Ship-to Name 2" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Address"));
                    DocumentTMP."Ship-to Address" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Address 2"));
                    DocumentTMP."Ship-to Address 2" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to City"));
                    DocumentTMP."Ship-to City" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to County"));
                    DocumentTMP."Ship-to County" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Country/Region Code"));
                    DocumentTMP."Ship-to Country/Region Code" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Post Code"));
                    DocumentTMP."Ship-to Post Code" := FldRef.Value();

                    if DocumentTMP."Ship-to Name" + DocumentTMP."Ship-to Name 2" <> '' then
                        XmlWriter.WriteElementValue('Causale', DocumentTMP."Ship-to Name" + ' ' + DocumentTMP."Ship-to Name 2");

                    if DocumentTMP."Ship-to Address" + DocumentTMP."Ship-to Address 2" <> '' then
                        XmlWriter.WriteElementValue('Causale', DocumentTMP."Ship-to Address" + ' ' + DocumentTMP."Ship-to Address 2");

                    if DocumentTMP."Ship-to Post Code" + DocumentTMP."Ship-to City" +
                      DocumentTMP."Ship-to County" + DocumentTMP."Ship-to Country/Region Code" <> '' then
                        XmlWriter.WriteElementValue('Causale', DocumentTMP."Ship-to Post Code" + ' ' + DocumentTMP."Ship-to City" + ' ' +
                        DocumentTMP."Ship-to County" + ' ' + DocumentTMP."Ship-to Country/Region Code");

                end;

        end;
    end;

    //endElement('DettaglioPagamento', '2.4.2', true);//DettaglioPagamento
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeWriteEndTag', '', true, false)]
    local procedure OnFillCodicePagamento(header: RecordRef; line: RecordRef; var elementName: Text[250]; id: Text; var insert: Boolean; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        PaymentMethod: Record "Payment Method";
        PaymentTerms: Record "Payment Terms";
        FldRef: FieldRef;
        CodicePagamentoStr: Text[60];
        CustNo: Code[20];
    begin
        if id = '2.4.2' then begin
            CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
            if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
                exit;
            case OutbElectrDocSetupGroup."EOS Hook Group Code" of
                'EOS_BRICO_IO':
                    begin
                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Payment Method Code"));
                        DocumentTMP."Payment Method Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Payment Terms Code"));
                        DocumentTMP."Payment Terms Code" := FldRef.Value();

                        if PaymentMethod.Get(DocumentTMP."Payment Method Code") then
                            CodicePagamentoStr += PaymentMethod.Description;
                        if PaymentTerms.Get(DocumentTMP."Payment Terms Code") then
                            CodicePagamentoStr += ' ' + PaymentTerms.Description;

                        CodicePagamentoStr := DelChr(CodicePagamentoStr, '<', ' ');
                        XmlWriter.WriteElementValueIf(CodicePagamentoStr <> '', 'CodicePagamento', CopyStr(CodicePagamentoStr, 1, 60));
                    end;
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnAfterWriteDatiDDT_2_1_8', '', true, false)]
    local procedure OnAfterWriteDatiDDT_2_1_8(header: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        FldRef: FieldRef;
        CustNo: Code[20];
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;
        case OutbElectrDocSetupGroup."EOS Hook Group Code" of

            'EOS_BRICO_CENT', 'EOS_LEROY':
                if header.Number() in [DATABASE::"Sales Invoice Header", DATABASE::"Sales Cr.Memo Header"] then begin
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("No."));
                    DocumentTMP."No." := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Address"));
                    DocumentTMP."Ship-to Address" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Post Code"));
                    DocumentTMP."Ship-to Post Code" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to County"));
                    DocumentTMP."Ship-to County" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to Country/Region Code"));
                    DocumentTMP."Ship-to Country/Region Code" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Ship-to City"));
                    DocumentTMP."Ship-to City" := FldRef.Value();

                    if (DocumentTMP."Ship-to Address" <> '') and (DocumentTMP."Ship-to Post Code" <> '') and
                     (DocumentTMP."Ship-to City" <> '') and (DocumentTMP."Ship-to Country/Region Code" <> '') then begin
                        XmlWriter.WriteStartElement('DatiTrasporto');
                        XmlWriter.WriteStartElement('IndirizzoResa');
                        XmlWriter.WriteElementValue('Indirizzo', DocumentTMP."Ship-to Address");
                        XmlWriter.WriteElementValue('CAP', DocumentTMP."Ship-to Post Code");
                        XmlWriter.WriteElementValue('Comune', DocumentTMP."Ship-to City");
                        XmlWriter.WriteElementValueIf(DocumentTMP."Ship-to County" <> '', 'Provincia', CopyStr(DocumentTMP."Ship-to County", 1, 2));
                        XmlWriter.WriteElementValue('Nazione', CopyStr(DocumentTMP."Ship-to Country/Region Code", 1, 2));

                        XmlWriter.WriteEndElement();//IndirizzoResa
                        XmlWriter.WriteEndElement();//DatiTrasporto
                    end;
                end;

        end;
    end;

    local procedure getLineFromheaderHdr(var Lineheader: RecordRef; header: RecordRef)
    var
    begin
        case header.Number() of
            Database::"Sales Invoice Header":
                Lineheader.Open(Database::"Sales Invoice Line");
            Database::"Service Invoice Header":
                Lineheader.Open(Database::"Service Invoice Line");
            Database::"Sales Cr.Memo Header":
                Lineheader.Open(Database::"Sales Cr.Memo Line");
            Database::"Service Cr.Memo Header":
                Lineheader.Open(Database::"Service Cr.Memo Line");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeAddElementText', '', true, true)]
    local procedure "EOS FE Writer_OnBeforeAddElementText"
    (
        header: RecordRef;
        line: RecordRef;
        var elementName: Text[250];
        id: Text;
        var Value: Text;
        var XmlWriter: Codeunit "EOS Xml Writer"
    )
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        FldRef: FieldRef;
        CustNo: code[20];
    begin
        case id of
            '2.2.1.15':
                begin
                    CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
                    if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
                        exit;
                    CASE OutbElectrDocSetupGroup."EOS Hook Group Code" OF
                        'EOS_AMAZON':

                            IF header.NUMBER() IN [DATABASE::"Sales Invoice Header", DATABASE::"Sales Cr.Memo Header"] THEN BEGIN
                                DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FIELDNAME("External Document No."));
                                DocumentTMP."External Document No." := FldRef.VALUE();

                                IF DocumentTMP."External Document No." <> '' THEN
                                    Value := COPYSTR(DocumentTMP."External Document No.", 1, 20)

                            END;

                    end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnCheckDatiBeniServizi', '', true, true)]
    local procedure OnCheckDatiBeniServizi(header: RecordRef; line: RecordRef)
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        CustNo: code[20];
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                AMAZON_OnCheckDatiBeniServizi(header, line);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnCheckDatiGenerali', '', true, true)]
    local procedure OnCheckDatiGenerali(header: RecordRef; var OrderNoBuffer: Record "EOS RifLineNo Buffer" temporary)
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        CustNo: code[20];
    begin
        CustNo := header.Field(DocumentTMP.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                AMAZON_OnCheckDatiGenerali(header, OrderNoBuffer);
        end;
    end;

    //#region AMAZON

    local procedure AMAZON_OnCheckDatiGenerali(header: RecordRef; var OrderNoBuffer: Record "EOS RifLineNo Buffer" temporary)
    var
        ElectrDocRelatedDocsTMP: Record "EOS Outb. EDoc. Related Docs." temporary;
        DocumentReason: code[10];
        NumeroOrd: Text;
        DataOrd: Date;
        CIG: Code[15];
        CUP: Code[15];
        IsHandled: Boolean;
        NoPurchOrderErr: Label 'AMAZON: DatiOrdineAcquisto mandatory for %1 document.';
        NoReasonCodeErr: Label 'AMAZON: Reason code mandatory for document %1.';
        NoAppliesToDocErr: Label 'AMAZON: DatiFattureCollegate mandatory for %1 document.';
    begin
        EOSFEData.setHeader(header);
        DocumentReason := GetAMAZONReasonCode(header);
        EOSFEData.getRelDocsTagsForCurrDoc(ElectrDocRelatedDocsTMP);
        EOSFEData.hasDirectOrder(NumeroOrd, DataOrd, CIG, CUP);
        case header.Number() of
            database::"Sales Invoice Header":
                case DocumentReason of
                    '':
                        begin
                            if not EOSFEData.insertOrderData() then
                                Error(NoPurchOrderErr, 'Invoice');
                            if NumeroOrd <> '' then
                                exit;
                            ElectrDocRelatedDocsTMP.SetRange("EOS Type", ElectrDocRelatedDocsTMP."EOS Type"::DatiOrdineAcquisto);
                            if not ElectrDocRelatedDocsTMP.IsEmpty() then
                                exit;
                            OrderNoBuffer.SetFilter("EOS Doc No.", '<>%1', '');
                            if OrderNoBuffer.IsEmpty() then
                                Error(NoPurchOrderErr, 'Invoice');
                            if not OutbElectrDocSetupGroup."EOS Exp. DatiOrdAcq Sales Inv." then
                                Error(NoPurchOrderErr, 'Invoice');
                        end;
                    'NDEB':
                        begin
                            ElectrDocRelatedDocsTMP.SetRange("EOS Type", ElectrDocRelatedDocsTMP."EOS Type"::DatiFattureCollegate);
                            if ElectrDocRelatedDocsTMP.IsEmpty() then
                                Error(NoAppliesToDocErr, DocumentReason);
                        end;
                end;
            database::"Sales Cr.Memo Header":
                begin
                    IsHandled := false;
                    OnBeforeCheckAmazonDocumentReasonSalesCrMemo(header, DocumentReason, IsHandled);
                    case DocumentReason of
                        '':
                            if not IsHandled then
                                Error(NoReasonCodeErr, header.Caption());
                        'NCSTT',
                        'QPD':
                            begin
                                ElectrDocRelatedDocsTMP.SetRange("EOS Type", ElectrDocRelatedDocsTMP."EOS Type"::DatiOrdineAcquisto);
                                if ElectrDocRelatedDocsTMP.IsEmpty() then
                                    if NumeroOrd = '' then
                                        Error(NoPurchOrderErr, DocumentReason);

                                ElectrDocRelatedDocsTMP.SetRange("EOS Type", ElectrDocRelatedDocsTMP."EOS Type"::DatiFattureCollegate);
                                if ElectrDocRelatedDocsTMP.IsEmpty() then
                                    Error(NoAppliesToDocErr, DocumentReason);
                            end;
                        'NCDIF',
                        'CCOGS':
                            begin
                                ElectrDocRelatedDocsTMP.SetRange("EOS Type", ElectrDocRelatedDocsTMP."EOS Type"::DatiFattureCollegate);
                                if ElectrDocRelatedDocsTMP.IsEmpty() then
                                    Error(NoAppliesToDocErr, DocumentReason);
                            end;
                    end;
                end;
        end;
    end;

    local procedure AMAZON_OnCheckDatiBeniServizi(header: RecordRef; line: RecordRef)
    var
        DocumentLineTMP: Record "Sales Invoice Line" temporary;
        DocumentTMP: Record "Sales Invoice Header" temporary;
        EOSEDocRelDocLines: Record "EOS EDoc. Rel. Doc. Lines";
        EOSOutbElectrDocSetup: Record "EOS Outb. Electr. Doc. Setup";
        FldRef: FieldRef;
        DocumentReason: Code[10];
        NoItemCodeErr: Label 'AMAZON: CodiceArticolo mandatory for document %1 line %2.';
        NoRiferimentoAmministrazioneErr: Label 'AMAZON: RiferimentoAmministrazione mandatory for %1 document line %2.';
    begin
        EOSFEData.setHeader(header);
        DocumentReason := GetAMAZONReasonCode(header);
        EOSFEData.setLineRecRef(line);
        EOSFEData.getRelDocsLineTagsForCurrDoc(EOSEDocRelDocLines);
        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
        DocumentLineTMP.Type := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
        DocumentLineTMP."Line No." := FldRef.Value();
        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("External Document No."));
        DocumentTMP."External Document No." := FldRef.Value();
        case header.Number() of
            database::"Sales Invoice Header":
                case DocumentReason of
                    'NDEB':
                        if DocumentTMP."External Document No." = '' then begin
                            EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::RiferimentoAmministrazione);
                            if EOSEDocRelDocLines.IsEmpty() then
                                error(NoRiferimentoAmministrazioneErr, DocumentReason, DocumentLineTMP."Line No.");
                        end;
                end;
            database::"Sales Cr.Memo Header":
                case DocumentReason of
                    'VRET',
                    'NCDIF':
                        begin
                            EOSOutbElectrDocSetup.get();
                            if not EOSOutbElectrDocSetup."EOS Add Item Code" then
                                Error(NoItemCodeErr, DocumentReason, DocumentLineTMP."Line No.");
                            if DocumentLineTMP.Type <> DocumentLineTMP.Type::Item then begin
                                EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::CodiceArticolo);
                                if EOSEDocRelDocLines.IsEmpty() then
                                    Error(NoItemCodeErr, DocumentReason, DocumentLineTMP."Line No.");
                            end;

                            if DocumentTMP."External Document No." = '' then begin
                                EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::RiferimentoAmministrazione);
                                if EOSEDocRelDocLines.IsEmpty() then
                                    error(NoRiferimentoAmministrazioneErr, DocumentReason, DocumentLineTMP."Line No.");
                            end;
                        end;
                    'QPD',
                    'NCSTT',
                    'COGS':
                        if DocumentTMP."External Document No." = '' then begin
                            EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::RiferimentoAmministrazione);
                            if EOSEDocRelDocLines.IsEmpty() then
                                error(NoRiferimentoAmministrazioneErr, DocumentReason, DocumentLineTMP."Line No.");
                        end;
                end;
        end;
    end;

    local procedure GetAMAZONReasonCode(header: RecordRef) Reason: Code[10]
    var
        DocumentTMP: Record "Sales Invoice Header" temporary;
        ReasonCode: Record "Reason Code";
        FldRef: FieldRef;
        CausaleList: List of [Text];
        CausaleConai: Text;
        CausaleDutyStamp: Text;
        Causale: Text;
    begin
        EOSFEData.getCausaleTags(CausaleList, CausaleConai, CausaleDutyStamp);

        DataTypeManagement.FindFieldByName(header, FldRef, DocumentTMP.FieldName("Reason Code"));
        DocumentTMP."Reason Code" := FldRef.Value();
        if ReasonCode.get(DocumentTMP."Reason Code") then
            CausaleList.Add(ReasonCode.Description);

        case header.Number() of
            database::"Sales Invoice Header":
                begin
                    Causale := 'NDEB';
                    if CausaleList.Contains(Causale) then
                        Reason := copystr(Causale, 1, 10);
                end;
            database::"Sales Cr.Memo Header":
                begin
                    Causale := 'NCSTT';
                    if CausaleList.Contains(Causale) then
                        Reason := copystr(Causale, 1, 10);
                    Causale := 'NCDIF';
                    if CausaleList.Contains(Causale) then
                        Reason := copystr(Causale, 1, 10);
                    Causale := 'QPD';
                    if CausaleList.Contains(Causale) then
                        Reason := copystr(Causale, 1, 10);
                    Causale := 'VRET';
                    if CausaleList.Contains(Causale) then
                        Reason := copystr(Causale, 1, 10);
                    Causale := 'CCOGS';
                    if CausaleList.Contains(Causale) then
                        Reason := copystr(Causale, 1, 10);
                end;
        end;
    end;

    local procedure AMAZON_OnBefore_CodiceArticolo(header: RecordRef; line: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var handled: Boolean)
    var
        DocumentLineTMP: Record "Sales Invoice Line" temporary;
        TempItemReference: Record "Item Reference" temporary;
        FldRef: FieldRef;
    begin
        if not (line.Number() in [DATABASE::"Sales Invoice Line", DATABASE::"Sales Cr.Memo Line"]) then
            exit;

        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Line No."));
        DocumentLineTMP."Line No." := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName(Type));
        DocumentLineTMP.Type := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Variant Code"));
        DocumentLineTMP."Variant Code" := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("No."));
        DocumentLineTMP."No." := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Unit of Measure Code"));
        DocumentLineTMP."Unit of Measure Code" := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, DocumentLineTMP.FieldName("Item Reference No."));
        DocumentLineTMP."Item Reference No." := FldRef.Value();

        IF DocumentLineTMP.Type = DocumentLineTMP.Type::Item THEN begin
            EOS066OptionalFeatureMgt.GetItemReferenceSet(DocumentLineTMP."No.", TempItemReference);
            TempItemReference.SETRANGE("Item No.", DocumentLineTMP."No.");
            TempItemReference.SETRANGE("Variant Code", DocumentLineTMP."Variant Code");
            TempItemReference.SETRANGE("Reference Type", TempItemReference."Reference Type"::"Bar Code");
            TempItemReference.SETRANGE("Unit of Measure", DocumentLineTMP."Unit of Measure Code");
            TempItemReference.SETRANGE("Reference Type No.", OutbElectrDocSetupGroup."EOS Hook Group Code");
            //TempItemReference.SETRANGE("Discontinue Bar Code", false);
            if not TempItemReference.FindFirst() then
                TempItemReference.SETRANGE("Unit of Measure");
            IF TempItemReference.FINDFIRST() THEN BEGIN
                XmlWriter.WriteStartElement('CodiceArticolo');
                XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                XmlWriter.WriteElementValue('CodiceValore', TempItemReference."Reference No.");
                XmlWriter.WriteEndElement();
            end;

            XmlWriter.WriteStartElement('CodiceArticolo');
            XmlWriter.WriteElementValue('CodiceTipo', 'SKU');
            XmlWriter.WriteElementValue('CodiceValore', DocumentLineTMP."No.");
            XmlWriter.WriteEndElement();
        END;
        Handled := TRUE;
    end;

    //#endregion AMAZON

    /// <summary>
    /// Raised during the General Data check for Amazon, before checking the Reason Code, while generating an electronic document for a Sales Cr.Memo for AMAZON
    /// </summary>
    /// <param name="header">Document header</param>
    /// <param name="DocumentReason">Reason Code, if empty an error will be raised after the event</param>
    /// <param name="IsHandled">if true, the error will be skipped</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAmazonDocumentReasonSalesCrMemo(header: RecordRef; var DocumentReason: Code[10]; var IsHandled: Boolean)
    begin
    end;

}
