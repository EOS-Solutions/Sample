/// <summary>
/// Gather all functions that handles specific hook code (i.e. GDO) specified in group setup
/// </summary>
codeunit 18123040 "EOS Outb. EDoc. Hook Handler"
{

    var
        OutbElectrDocSetupGroup: Record "EOS Outb. EDoc. Group Setup";
        EOSEDocSetupMgt: Codeunit "EOS EDoc. Setup Management";
        DataTypeManagement: Codeunit "Data Type Management";
        EOSFEData: Codeunit "EOS FE Data";

    [Obsolete('Not Used.', '27.0')]
    procedure SetSalesInvoiceTmpBuffer(var inTmpSalesHeader: Record "Sales Header" temporary; var inTmpShipHeader: Record "Sales Shipment Header" temporary)
    begin
    end;

    [Obsolete('Not Used.', '27.0')]
    procedure SetSalesCrMemoTmpBuffer(var inReturnReceiptHeaderTMP: Record "Return Receipt Header" temporary)
    begin
    end;

    [Obsolete('Not Used.', '27.0')]
    procedure SetServiceInvoiceTmpBuffer(var inTmpServiceHeader: Record "Service Header" temporary; var inTmpServShipHeader: Record "Service Shipment Header" temporary)
    begin
    end;

    /// <summary>
    /// Determines whether the PEC (Posta Elettronica Certificata) address should always be exported for the given customer.
    /// Returns true if the customer belongs to a hook group that requires mandatory PEC export (e.g., AMAZON).
    /// </summary>
    /// <param name="CustNo">The Customer No. to check</param>
    /// <param name="header">The document header RecordRef (Sales/Service Invoice or Credit Memo)</param>
    /// <returns>True if PEC should always be exported, false otherwise</returns>
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

    /// <summary>
    /// Retrieves the Reason Code from the document header.
    /// Raises OnBeforeGetReasonCode event to allow customization before retrieving the standard value.
    /// </summary>
    /// <param name="header">The document header RecordRef (Sales/Service Invoice or Credit Memo)</param>
    /// <returns>The Reason Code associated with the document</returns>
    procedure GetDocumentReasonCode(header: RecordRef) Result: Code[10];
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        FldRef: FieldRef;
        isHandled: Boolean;
    begin
        isHandled := false;
        OnBeforeGetReasonCode(OutbElectrDocSetupGroup, header, Result, isHandled);
        if not isHandled then begin
            DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Reason Code"));
            Result := FldRef.Value();
        end;
    end;

    /// <summary>
    /// Event subscriber that handles the CodiceArticolo (Item Code) XML element generation for various GDO (Grande Distribuzione Organizzata) hook groups.
    /// Each hook group has specific requirements for how item codes should be formatted and exported in the electronic invoice.
    /// Supported hook groups include: AMAZON, BRICO_CENT, CANOVA, CARREFOUR, CHEF, UNICOOPTIR, CONAD_SIC, IGES, GS1, COOPALL3, METRO, AUTOGRILL, RIALTO, FERRARI, OBI, BRICO_SELF.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    /// <param name="handled">Set to true to indicate that the CodiceArticolo has been handled and default processing should be skipped</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeAddCodiceArticolo', '', true, false)]
    local procedure OnBefore_CodiceArticolo(header: RecordRef; line: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var handled: Boolean)
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        TempDocumentLine: Record "Sales Invoice Line" temporary;
        CompanyInfoPA: Record "EOS Outb. Electr. Doc. Setup";
        ItemReference: Record "Item Reference";
        FldRef: FieldRef;
        DummyText: Text[20];
        CustNo: Code[20];
        isHandled: Boolean;
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        Handled := false;
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                AMAZON_OnBefore_CodiceArticolo(header, line, XmlWriter, handled);
            'EOS_BRICO_CENT':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();

                        isHandled := false;
                        OnBeforeExport_CodiceArticolo(OutbElectrDocSetupGroup, header, line, XmlWriter, isHandled);

                        if not isHandled then
                            if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'INTERNALCODE');
                                if TempDocumentLine."Variant Code" <> '' then
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                                else
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                                XmlWriter.WriteEndElement();

                                //CrossReference
                                if TempDocumentLine."Item Reference No." <> '' then begin
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    XmlWriter.WriteElementValue('CodiceTipo', 'articolobrico');
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."Item Reference No.");
                                    XmlWriter.WriteEndElement();
                                end;
                            end;
                    end;
                    Handled := true;
                end;

            'EOS_CANOVA':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();

                        isHandled := false;
                        OnBeforeExport_CodiceArticolo(OutbElectrDocSetupGroup, header, line, XmlWriter, isHandled);

                        if not isHandled then
                            if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'INTERNALCODE');
                                if TempDocumentLine."Variant Code" <> '' then
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                                else
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                                XmlWriter.WriteEndElement();

                            end;
                    end;
                    Handled := true;
                end;

            'EOS_CARREFOUR':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Sell-to Customer No."));
                        TempDocumentLine."Sell-to Customer No." := FldRef.Value();

                        if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                            ItemReference.SetRange("Item No.", TempDocumentLine."No.");
                            ItemReference.SetFilter("Reference Type", '%1|%2',
                                ItemReference."Reference Type"::"Bar Code", ItemReference."Reference Type"::Customer);
                            if TempDocumentLine."Item Reference No." <> '' then
                                ItemReference.SetRange("Reference No.", TempDocumentLine."Item Reference No.");

                            isHandled := false;
                            OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);

                            if not isHandled then
                                if ItemReference.FindSet() then
                                    repeat
                                        isHandled := false;
                                        OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                                        if not isHandled then
                                            if not ((ItemReference."Reference Type" = ItemReference."Reference Type"::Customer) and (ItemReference."Reference Type No." <> TempDocumentLine."Sell-to Customer No.")) then begin
                                                XmlWriter.WriteStartElement('CodiceArticolo');
                                                case ItemReference."Reference Type" of
                                                    ItemReference."Reference Type"::Customer:
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'BP');
                                                    ItemReference."Reference Type"::"Bar Code":
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                                end;
                                                XmlWriter.WriteElementValue('CodiceValore', ItemReference."Reference No.");
                                                XmlWriter.WriteEndElement();
                                            end;
                                    until ItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_CHEF':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Sell-to Customer No."));
                        TempDocumentLine."Sell-to Customer No." := FldRef.Value();

                        if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', '99');
                            if TempDocumentLine."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                            XmlWriter.WriteEndElement();

                            ItemReference.SetRange("Item No.", TempDocumentLine."No.");
                            ItemReference.SetFilter("Reference Type", '%1|%2',
                                ItemReference."Reference Type"::"Bar Code", ItemReference."Reference Type"::Customer);
                            if TempDocumentLine."Item Reference No." <> '' then
                                ItemReference.SetRange("Reference No.", TempDocumentLine."Item Reference No.");

                            isHandled := false;
                            OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                            if not isHandled then
                                if ItemReference.FindSet() then
                                    repeat
                                        isHandled := false;
                                        OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                                        if not isHandled then
                                            if not ((ItemReference."Reference Type" = ItemReference."Reference Type"::Customer) and (ItemReference."Reference Type No." <> TempDocumentLine."Sell-to Customer No.")) then begin
                                                XmlWriter.WriteStartElement('CodiceArticolo');
                                                case ItemReference."Reference Type" of
                                                    ItemReference."Reference Type"::Customer:
                                                        XmlWriter.WriteElementValue('CodiceTipo', '01');
                                                    ItemReference."Reference Type"::"Bar Code":
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                                end;
                                                XmlWriter.WriteElementValue('CodiceValore', ItemReference."Reference No.");
                                                XmlWriter.WriteEndElement();
                                            end;
                                    until ItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_UNICOOPTIR':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();

                        if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                            ItemReference.SetRange("Item No.", TempDocumentLine."No.");
                            ItemReference.SetFilter("Reference Type", '%1', ItemReference."Reference Type"::"Bar Code");
                            if TempDocumentLine."Item Reference No." <> '' then
                                ItemReference.SetRange("Reference No.", TempDocumentLine."Item Reference No.");

                            isHandled := false;
                            OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                            if not isHandled then
                                if ItemReference.FindSet() then
                                    repeat
                                        isHandled := false;
                                        OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                                        if not isHandled then begin
                                            XmlWriter.WriteStartElement('CodiceArticolo');
                                            XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                            XmlWriter.WriteElementValue('CodiceValore', ItemReference."Reference No.");
                                            XmlWriter.WriteEndElement();
                                        end;
                                    until ItemReference.Next() = 0
                                else begin
                                    XmlWriter.WriteStartElement('CodiceArticolo');
                                    XmlWriter.WriteElementValue('CodiceTipo', 'Codice Uso Fornitore');
                                    if TempDocumentLine."Variant Code" <> '' then
                                        XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                                    else
                                        XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                                    XmlWriter.WriteEndElement();
                                end;
                        end;
                    end;
                    Handled := true;
                end;

            'EOS_CONAD_SIC', 'EOS_IGES', 'EOS_GS1':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Sell-to Customer No."));
                        TempDocumentLine."Sell-to Customer No." := FldRef.Value();

                        if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin

                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'SA');
                            if TempDocumentLine."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                            XmlWriter.WriteEndElement();

                            ItemReference.SetRange("Item No.", TempDocumentLine."No.");
                            ItemReference.SetFilter("Reference Type", '%1|%2',
                                ItemReference."Reference Type"::"Bar Code", ItemReference."Reference Type"::Customer);
                            if TempDocumentLine."Item Reference No." <> '' then
                                ItemReference.SetRange("Reference No.", TempDocumentLine."Item Reference No.");

                            isHandled := false;
                            OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);

                            if not isHandled then
                                if ItemReference.FindSet() then
                                    repeat
                                        isHandled := false;
                                        OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                                        if not isHandled then
                                            if not ((ItemReference."Reference Type" = ItemReference."Reference Type"::Customer) and (ItemReference."Reference Type No." <> TempDocumentLine."Sell-to Customer No.")) then begin
                                                XmlWriter.WriteStartElement('CodiceArticolo');
                                                case ItemReference."Reference Type" of
                                                    ItemReference."Reference Type"::Customer:
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'IN');
                                                    ItemReference."Reference Type"::"Bar Code":
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'EN');
                                                end;
                                                XmlWriter.WriteElementValue('CodiceValore', ItemReference."Reference No.");
                                                XmlWriter.WriteEndElement();
                                            end;
                                    until ItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_COOPALL3':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Sell-to Customer No."));
                        TempDocumentLine."Sell-to Customer No." := FldRef.Value();

                        if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin

                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'Codice Art. Fornitore');
                            if TempDocumentLine."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                            XmlWriter.WriteEndElement();

                            ItemReference.SetRange("Item No.", TempDocumentLine."No.");
                            ItemReference.SetFilter("Reference Type", '%1|%2',
                                ItemReference."Reference Type"::"Bar Code", ItemReference."Reference Type"::Customer);
                            if TempDocumentLine."Item Reference No." <> '' then
                                ItemReference.SetRange("Reference No.", TempDocumentLine."Item Reference No.");

                            isHandled := false;
                            OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);

                            if not isHandled then
                                if ItemReference.FindSet() then
                                    repeat
                                        isHandled := false;
                                        OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                                        if not isHandled then
                                            if not ((ItemReference."Reference Type" = ItemReference."Reference Type"::Customer) and (ItemReference."Reference Type No." <> TempDocumentLine."Sell-to Customer No.")) then begin
                                                XmlWriter.WriteStartElement('CodiceArticolo');
                                                case ItemReference."Reference Type" of
                                                    ItemReference."Reference Type"::Customer:
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'Codice Art. Cliente');
                                                    ItemReference."Reference Type"::"Bar Code":
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                                end;
                                                XmlWriter.WriteElementValue('CodiceValore', ItemReference."Reference No.");
                                                XmlWriter.WriteEndElement();
                                            end;
                                    until ItemReference.Next() = 0;

                        end;
                    end;
                    Handled := true;
                end;

            'EOS_METRO':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();

                        isHandled := false;
                        OnBeforeExport_CodiceArticolo(OutbElectrDocSetupGroup, header, line, XmlWriter, isHandled);

                        if not isHandled then
                            if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'cod');
                                if TempDocumentLine."Variant Code" <> '' then
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                                else
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                                XmlWriter.WriteEndElement();
                            end;
                    end;
                    Handled := true;
                end;

            'EOS_AUTOGRILL':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();

                        isHandled := false;
                        OnBeforeExport_CodiceArticolo(OutbElectrDocSetupGroup, header, line, XmlWriter, isHandled);

                        if not isHandled then
                            if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'GDS');
                                if TempDocumentLine."Variant Code" <> '' then
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                                else
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                                XmlWriter.WriteEndElement();
                            end;
                    end;
                    Handled := true;
                end;

            'EOS_RIALTO':
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Sell-to Customer No."));
                        TempDocumentLine."Sell-to Customer No." := FldRef.Value();

                        if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                            XmlWriter.WriteStartElement('CodiceArticolo');
                            XmlWriter.WriteElementValue('CodiceTipo', 'SA');
                            if TempDocumentLine."Variant Code" <> '' then
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                            else
                                XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                            XmlWriter.WriteEndElement();

                            ItemReference.SetRange("Item No.", TempDocumentLine."No.");
                            ItemReference.SetFilter("Reference Type", '%1|%2',
                                ItemReference."Reference Type"::"Bar Code", ItemReference."Reference Type"::Customer);
                            if TempDocumentLine."Item Reference No." <> '' then
                                ItemReference.SetRange("Reference No.", TempDocumentLine."Item Reference No.");

                            isHandled := false;
                            OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);

                            if not isHandled then
                                if ItemReference.FindSet() then
                                    repeat
                                        isHandled := false;
                                        OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                                        if not isHandled then
                                            if not ((ItemReference."Reference Type" = ItemReference."Reference Type"::Customer) and (ItemReference."Reference Type No." <> TempDocumentLine."Sell-to Customer No.")) then begin
                                                XmlWriter.WriteStartElement('CodiceArticolo');
                                                case ItemReference."Reference Type" of
                                                    ItemReference."Reference Type"::Customer:
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'BP');
                                                    ItemReference."Reference Type"::"Bar Code":
                                                        XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                                                end;
                                                XmlWriter.WriteElementValue('CodiceValore', ItemReference."Reference No.");
                                                XmlWriter.WriteEndElement();
                                            end;
                                    until ItemReference.Next() = 0;
                        end;
                    end;
                    Handled := true;
                end;

            'EOS_FERRARI':
                // CodiceValore:
                // Commessa primi 9 caratteri + codice articolo ordine Ferrari. Nei 9 caratteri riservati alla commessa
                // il valore deve essere allineato a sinistra, riempiendo i campi vuoti di commessa con BLANK. Commessa di riga fattura
                // Creare routine custom per gestire stringa

                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Job No."));
                        TempDocumentLine."Job No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
                        TempDocumentLine."Item Reference No." := FldRef.Value();

                        isHandled := false;
                        OnBeforeExport_CodiceArticolo(OutbElectrDocSetupGroup, header, line, XmlWriter, isHandled);

                        if not isHandled then
                            if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin

                                // Create string following Ferrari request
                                DummyText := CopyStr(PadStr(TempDocumentLine."Job No.", 9, ' ') + TempDocumentLine."Item Reference No.", 1, 20);

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
                if line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    CompanyInfoPA.Get();
                    if CompanyInfoPA."EOS Add Item Code" then begin
                        Clear(TempDocumentLine);

                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
                        TempDocumentLine."Line No." := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
                        TempDocumentLine.Type := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
                        TempDocumentLine."Variant Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
                        TempDocumentLine."No." := FldRef.Value();

                        isHandled := false;
                        OnBeforeExport_CodiceArticolo(OutbElectrDocSetupGroup, header, line, XmlWriter, isHandled);

                        if not isHandled then
                            if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
                                XmlWriter.WriteStartElement('CodiceArticolo');
                                XmlWriter.WriteElementValue('CodiceTipo', 'SA');
                                if TempDocumentLine."Variant Code" <> '' then
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No." + ' ' + TempDocumentLine."Variant Code")
                                else
                                    XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
                                XmlWriter.WriteEndElement();
                            end;
                    end;
                    Handled := true;
                end;
        end;
    end;

    /// <summary>
    /// Event subscriber that handles the CodiceCommessaConvenzione element (ID 2.1.2.5) for specific hook groups.
    /// Fills the Store Code value from Ship-to Address or Customer for OTTIMAX hook group.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef or RifLineNo Buffer</param>
    /// <param name="elementName">The name of the XML element being processed</param>
    /// <param name="id">The FatturaPA element ID (e.g., '2.1.2.5' for CodiceCommessaConvenzione)</param>
    /// <param name="Value">The value to be written to the XML element</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeAddElementText', '', true, false)]
    local procedure OnFillCommConvDatiOdA(header: RecordRef; line: RecordRef; var elementName: Text[250]; id: Text; var Value: Text; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        TempBuffer: Record "EOS RifLineNo Buffer" temporary;
        headerOrder: Record "Sales Header";
        ShiptoAddress: Record "Ship-to Address";
        Customer: Record Customer;
        FldRef: FieldRef;
        NotDirectShip: Boolean;
        CustNo: Code[20];
        orderNo: Code[20];
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        if id = '2.1.2.5' then begin
            if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
                exit;
            NotDirectShip := line.Number() = Database::"EOS RifLineNo Buffer";
            case OutbElectrDocSetupGroup."EOS Hook Group Code" of

                'EOS_OTTIMAX':
                    begin
                        orderNo := line.field(TempBuffer.FieldNo("EOS Order No.")).Value();
                        headerOrder.SetRange("No.", orderNo);
                        if (not NotDirectShip) or headerOrder.IsEmpty() then begin
                            DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No."));
                            TempDocument."Sell-to Customer No." := FldRef.Value();
                            DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code"));
                            TempDocument."Ship-to Code" := FldRef.Value();
                        end else begin
                            headerOrder.FindFirst();

                            TempDocument."Sell-to Customer No." := headerOrder."Sell-to Customer No.";
                            TempDocument."Ship-to Code" := headerOrder."Ship-to Code";
                        end;
                        if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                            Clear(ShiptoAddress);
                        if ShiptoAddress."EOS Store Code" <> '' then
                            Value := ShiptoAddress."EOS Store Code"
                        else begin
                            Customer.Get(TempDocument."Sell-to Customer No.");
                            Value := Customer."EOS Store Code";
                        end;
                    end;

            end;
        end;
    end;


    /// <summary>
    /// Event subscriber that populates the Related Documents buffer with additional data for specific hook groups.
    /// For METRO: Adds DatiRicezione with Store Code (ILN code).
    /// For AGRINTESA: Adds DatiRicezione with Document No.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="ElectrDocRelatedDocsTMP">Temporary buffer containing related document information for the electronic invoice</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnFillElectrDocRelatedDocsBuffer', '', true, false)]
    local procedure OnFillElectrDocRelatedDocsBuffer(header: RecordRef; var ElectrDocRelatedDocsTMP: Record "EOS Outb. EDoc. Related Docs." temporary)
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
        FldRef: FieldRef;
        CustNo: Code[20];
        LineNo: Integer;
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;
        if not ElectrDocRelatedDocsTMP.FindLast() then
            LineNo := 10000
        else
            LineNo := ElectrDocRelatedDocsTMP."EOS Line No.";

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_METRO':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("No."));
                    TempDocument."No." := FldRef.Value();

                    // Codice o ILN fornitore
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Bill-to Customer No."));
                    TempDocument."Bill-to Customer No." := FldRef.Value();
                    Customer.Get(TempDocument."Bill-to Customer No.");

                    // Codice o ILN store
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No."));
                    TempDocument."Sell-to Customer No." := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code"));
                    TempDocument."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        LineNo += 10000;
                        ElectrDocRelatedDocsTMP.Init();
                        ElectrDocRelatedDocsTMP."EOS Table ID" := header.Number();
                        ElectrDocRelatedDocsTMP."EOS Document Type" := 0;
                        ElectrDocRelatedDocsTMP."EOS Document No." := TempDocument."No.";
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
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("No."));
                    TempDocument."No." := FldRef.Value();

                    LineNo += 10000;
                    ElectrDocRelatedDocsTMP.Init();
                    ElectrDocRelatedDocsTMP."EOS Table ID" := header.Number();
                    ElectrDocRelatedDocsTMP."EOS Document Type" := 0;
                    ElectrDocRelatedDocsTMP."EOS Document No." := TempDocument."No.";
                    ElectrDocRelatedDocsTMP."EOS Document RecordID" := header.RecordId();
                    ElectrDocRelatedDocsTMP."EOS Type" := ElectrDocRelatedDocsTMP."EOS Type"::DatiRicezione;
                    ElectrDocRelatedDocsTMP."EOS IdDocumento" := TempDocument."No.";
                    ElectrDocRelatedDocsTMP."EOS Line No." := LineNo;
                    ElectrDocRelatedDocsTMP.Insert(true);
                end;
        end;
    end;

    /// <summary>
    /// Event subscriber that handles the AltriDatiGestionali (Other Management Data) XML element (ID 2.2.1.16) for various hook groups.
    /// Each hook group has specific requirements for additional data to be included at the line level.
    /// Supported hook groups: LEROY (Negozio), BRICO_IO (CDC), CANOVA/CARREFOUR/RIALTO (DP), ESSELUNGA (DP with shipment info),
    /// CAMST (PLANT from dimension), CONAD_SIC/IGES (PCONSEGNA), COOPALL3 (DP, DEST.MERCI, INDIRIZZO),
    /// UNICOOPTIR (CPV), AUTOGRILL (PV), CHEF (DP), OBI (DP).
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnAddAltriDatiGestionali_2_2_1_16', '', true, false)]
    local procedure OnFillAltriDatiGestionaliTag(header: RecordRef; line: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        TempDocumentLine: Record "Sales Invoice Line" temporary;
        ShiptoAddress: Record "Ship-to Address";
        Customer: Record Customer;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        DimensionManagement: Codeunit DimensionManagement;
        FldRef: FieldRef;
        CustNo: Code[20];
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of

            'EOS_LEROY':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Description" := Customer."EOS Store Description";
                    end;

                    if ShiptoAddress."EOS Store Description" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'Negozio');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Description");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_BRICO_IO':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        exit;

                    XmlWriter.WriteStartElement('AltriDatiGestionali');
                    XmlWriter.WriteElementValue('TipoDato', 'CDC');
                    XmlWriter.WriteElementValueIf(ShiptoAddress.Name <> '', 'RiferimentoTesto', ShiptoAddress.Name);
                    XmlWriter.WriteEndElement();
                end;

            'EOS_CANOVA', 'EOS_CARREFOUR', 'EOS_RIALTO':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_ESSELUNGA':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();

                    if Line.Number() = Database::"Sales Invoice Line" then begin
                        DataTypeManagement.FindFieldByName(Line, FldRef, SalesInvoiceLine.FieldName("Shipment No."));
                        TempDocument."Order No." := FldRef.Value();
                        if SalesShipmentHeader.Get(TempDocument."Order No.") then
                            if SalesShipmentHeader."Ship-to Code" <> '' then
                                TempDocument."Ship-to Code" := SalesShipmentHeader."Ship-to Code";
                    end else
                        if Line.Number() = Database::"Sales Cr.Memo Line" then begin
                            DataTypeManagement.FindFieldByName(Line, FldRef, SalesCrMemoLine.FieldName("Return Receipt No."));
                            TempDocument."Order No." := FldRef.Value();
                            if ReturnReceiptHeader.Get(TempDocument."Order No.") then
                                if ReturnReceiptHeader."Ship-to Code" <> '' then
                                    TempDocument."Ship-to Code" := ReturnReceiptHeader."Ship-to Code";
                        end;

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_CAMST':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(Line, FldRef, TempDocumentLine.FieldName("Dimension Set ID")) then
                        TempDocument."Dimension Set ID" := FldRef.Value();
                    if TempDocument."Dimension Set ID" = 0 then
                        exit;

                    DimensionManagement.GetDimensionSet(TempDimSetEntry, TempDocument."Dimension Set ID");
                    TempDimSetEntry.SetRange("Dimension Code", 'CDCCAMST'); // Centro di Costo fornito da CAMST
                    if TempDimSetEntry.FindFirst() then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'PLANT');
                        XmlWriter.WriteElementValue('RiferimentoTesto', TempDimSetEntry."Dimension Value Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_CONAD_SIC', 'EOS_IGES':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();
                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" + ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
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
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();
                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" + ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                        ShiptoAddress."EOS Store Description" := Customer."EOS Store Description";
                    end;

                    // GLN code
                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;

                    // Store Description
                    if ShiptoAddress."EOS Store Description" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DEST.MERCI');
                        XmlWriter.WriteElementValue('RiferimentoTesto', CopyStr(ShiptoAddress."EOS Store Description", 1, 60));
                        XmlWriter.WriteEndElement();
                    end;

                    // Store Address
                    if ShiptoAddress.Address <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'INDIRIZZO');
                        XmlWriter.WriteElementValue('RiferimentoTesto', CopyStr(ShiptoAddress.Address + ' ' + ShiptoAddress."Post Code" + ' ' + ShiptoAddress.County, 1, 60));
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_UNICOOPTIR':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();
                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
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
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'PV');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_CHEF':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" + ShiptoAddress."EOS Store Description" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                        ShiptoAddress."EOS Store Description" := Customer."EOS Store Description";
                    end;

                    if ShiptoAddress."EOS Store Description" + ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Description" + ' - ' + ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            'EOS_OBI':
                if Line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"] then begin
                    Clear(TempDocument);
                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Sell-to Customer No.")) then
                        TempDocument."Sell-to Customer No." := FldRef.Value();

                    if DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Code")) then
                        TempDocument."Ship-to Code" := FldRef.Value();

                    if not ShiptoAddress.Get(TempDocument."Sell-to Customer No.", TempDocument."Ship-to Code") then
                        Clear(ShiptoAddress);
                    if ShiptoAddress."EOS Store Code" = '' then begin
                        Customer.Get(TempDocument."Sell-to Customer No.");
                        ShiptoAddress."EOS Store Code" := Customer."EOS Store Code";
                    end;

                    if ShiptoAddress."EOS Store Code" <> '' then begin
                        XmlWriter.WriteStartElement('AltriDatiGestionali');
                        XmlWriter.WriteElementValue('TipoDato', 'DP');
                        XmlWriter.WriteElementValue('RiferimentoTesto', ShiptoAddress."EOS Store Code");
                        XmlWriter.WriteEndElement();
                    end;
                end;
        end;
    end;


    /// <summary>
    /// Event subscriber that handles the Causale (Reason) XML element for various hook groups.
    /// Each hook group has specific requirements for how the reason/cause should be formatted.
    /// Supported hook groups: AMAZON (exports Reason Code for Credit Memos), CARREFOUR (MERCI/FRANCHISING/EXTRAFATTURA),
    /// CONAD_SIC/IGES (MAGAZZINO/RIFATTURAZIONE/SERVIZI), UNICOOPTIR (M/S), COOPALL3, STEFF (DANNI_/GEN_),
    /// ASCA/MARR (Ship-to address information).
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    /// <param name="handled">Set to true to indicate that default Causale processing should be skipped</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeAddCausaleTags', '', true, false)]
    local procedure OnFillCausaleTag(header: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var handled: Boolean)
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        ReasonCode: Record "Reason Code";
        FldRef: FieldRef;
        CustNo: Code[20];
        SkipHookHandling: Boolean;
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        Clear(SkipHookHandling);
        OnBeforeOnFillCausaleTag(header, XmlWriter, OutbElectrDocSetupGroup, SkipHookHandling);

        if SkipHookHandling then
            exit;

        TempDocument."Reason Code" := GetDocumentReasonCode(header);

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                if header.NUMBER() in [Database::"Sales Cr.Memo Header"] then
                    if TempDocument."Reason Code" <> '' then
                        if ReasonCode.Get(TempDocument."Reason Code") then
                            XmlWriter.WriteElementValueIf(ReasonCode."EOS AMZ Exp. To EDoc.", 'Causale', ReasonCode.Code);
            'EOS_CARREFOUR':
                // Check reasons mapped as "MERCI", "FRANCHISING", "EXTRAFATTURA" or customize
                XmlWriter.WriteElementValueIf(ReasonCode.Get(TempDocument."Reason Code"), 'Causale', ReasonCode.Description);

            'EOS_CONAD_SIC', 'EOS_IGES':
                // Check reasons mapped as "MAGAZZINO", "RIFATTURAZIONE", "SERVIZI" or customize
                XmlWriter.WriteElementValueIf(ReasonCode.Get(TempDocument."Reason Code"), 'Causale', ReasonCode.Description);

            'EOS_UNICOOPTIR':
                // Check reasons mapped as "M" (merci), "S" (servizi) or customize
                XmlWriter.WriteElementValueIf(ReasonCode.Get(TempDocument."Reason Code"), 'Causale', ReasonCode.Description);

            'EOS_COOPALL3':
                XmlWriter.WriteElementValueIf(ReasonCode.Get(TempDocument."Reason Code"), 'Causale', ReasonCode.Description);

            'EOS_STEFF':
                // Check reasons mapped as "DANNI_", "GEN_" or customize
                XmlWriter.WriteElementValueIf(ReasonCode.Get(TempDocument."Reason Code"), 'Causale', ReasonCode.Description);

            'EOS_ASCA', 'EOS_MARR':
                begin
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Name"));
                    TempDocument."Ship-to Name" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Name 2"));
                    TempDocument."Ship-to Name 2" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Address"));
                    TempDocument."Ship-to Address" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Address 2"));
                    TempDocument."Ship-to Address 2" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to City"));
                    TempDocument."Ship-to City" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to County"));
                    TempDocument."Ship-to County" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Country/Region Code"));
                    TempDocument."Ship-to Country/Region Code" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Post Code"));
                    TempDocument."Ship-to Post Code" := FldRef.Value();

                    if TempDocument."Ship-to Name" + TempDocument."Ship-to Name 2" <> '' then
                        XmlWriter.WriteElementValue('Causale', TempDocument."Ship-to Name" + ' ' + TempDocument."Ship-to Name 2");

                    if TempDocument."Ship-to Address" + TempDocument."Ship-to Address 2" <> '' then
                        XmlWriter.WriteElementValue('Causale', TempDocument."Ship-to Address" + ' ' + TempDocument."Ship-to Address 2");

                    if TempDocument."Ship-to Post Code" + TempDocument."Ship-to City" +
                      TempDocument."Ship-to County" + TempDocument."Ship-to Country/Region Code" <> '' then
                        XmlWriter.WriteElementValue('Causale', TempDocument."Ship-to Post Code" + ' ' + TempDocument."Ship-to City" + ' ' +
                        TempDocument."Ship-to County" + ' ' + TempDocument."Ship-to Country/Region Code");

                end;

        end;
    end;

    /// <summary>
    /// Event subscriber that handles the CodicePagamento (Payment Code) XML element within DettaglioPagamento (ID 2.4.2) for specific hook groups.
    /// For BRICO_IO: Combines Payment Method Description and Payment Terms Description into the CodicePagamento field.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="elementName">The name of the XML element being processed</param>
    /// <param name="id">The FatturaPA element ID (e.g., '2.4.2' for DettaglioPagamento)</param>
    /// <param name="insert">Indicates whether the end tag should be inserted</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnBeforeWriteEndTag', '', true, false)]
    local procedure OnFillCodicePagamento(header: RecordRef; line: RecordRef; var elementName: Text[250]; id: Text; var Insert: Boolean; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        PaymentMethod: Record "Payment Method";
        PaymentTerms: Record "Payment Terms";
        FldRef: FieldRef;
        CodicePagamentoStr: Text[60];
        CustNo: Code[20];
    begin
        if id = '2.4.2' then begin
            CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
            if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
                exit;
            case OutbElectrDocSetupGroup."EOS Hook Group Code" of
                'EOS_BRICO_IO':
                    begin
                        DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Payment Method Code"));
                        TempDocument."Payment Method Code" := FldRef.Value();
                        DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Payment Terms Code"));
                        TempDocument."Payment Terms Code" := FldRef.Value();

                        if PaymentMethod.Get(TempDocument."Payment Method Code") then
                            CodicePagamentoStr += PaymentMethod.Description;
                        if PaymentTerms.Get(TempDocument."Payment Terms Code") then
                            CodicePagamentoStr += ' ' + PaymentTerms.Description;

                        CodicePagamentoStr := DelChr(CodicePagamentoStr, '<', ' ');
                        XmlWriter.WriteElementValueIf(CodicePagamentoStr <> '', 'CodicePagamento', CopyStr(CodicePagamentoStr, 1, 60));
                    end;
            end;
        end;
    end;

    /// <summary>
    /// Event subscriber that handles additional transport data (DatiTrasporto) after DatiDDT (ID 2.1.8) for specific hook groups.
    /// For BRICO_CENT and LEROY: Adds IndirizzoResa (Delivery Address) element with Ship-to Address information.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnAfterWriteDatiDDT_2_1_8', '', true, false)]
    local procedure OnAfterWriteDatiDDT_2_1_8(header: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer")
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        FldRef: FieldRef;
        CustNo: Code[20];
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;
        case OutbElectrDocSetupGroup."EOS Hook Group Code" of

            'EOS_BRICO_CENT', 'EOS_LEROY':
                if header.Number() in [Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header"] then begin
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("No."));
                    TempDocument."No." := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Address"));
                    TempDocument."Ship-to Address" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Post Code"));
                    TempDocument."Ship-to Post Code" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to County"));
                    TempDocument."Ship-to County" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to Country/Region Code"));
                    TempDocument."Ship-to Country/Region Code" := FldRef.Value();
                    DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("Ship-to City"));
                    TempDocument."Ship-to City" := FldRef.Value();

                    if (TempDocument."Ship-to Address" <> '') and (TempDocument."Ship-to Post Code" <> '') and
                     (TempDocument."Ship-to City" <> '') and (TempDocument."Ship-to Country/Region Code" <> '') then begin
                        XmlWriter.WriteStartElement('DatiTrasporto');
                        XmlWriter.WriteStartElement('IndirizzoResa');
                        XmlWriter.WriteElementValue('Indirizzo', TempDocument."Ship-to Address");
                        XmlWriter.WriteElementValue('CAP', TempDocument."Ship-to Post Code");
                        XmlWriter.WriteElementValue('Comune', TempDocument."Ship-to City");
                        XmlWriter.WriteElementValueIf(TempDocument."Ship-to County" <> '', 'Provincia', CopyStr(TempDocument."Ship-to County", 1, 2));
                        XmlWriter.WriteElementValue('Nazione', CopyStr(TempDocument."Ship-to Country/Region Code", 1, 2));

                        XmlWriter.WriteEndElement();//IndirizzoResa
                        XmlWriter.WriteEndElement();//DatiTrasporto
                    end;
                end;

        end;
    end;

    /// <summary>
    /// Opens the corresponding line table based on the header table type.
    /// Maps Sales/Service Invoice/Credit Memo headers to their respective line tables.
    /// </summary>
    /// <param name="Lineheader">Output RecordRef that will be opened to the appropriate line table</param>
    /// <param name="header">Input header RecordRef used to determine the line table to open</param>
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

    /// <summary>
    /// Event subscriber that handles the RiferimentoAmministrazione element (ID 2.2.1.15) for specific hook groups.
    /// For AMAZON: Fills the External Document No. as the administrative reference for Sales Invoice and Credit Memo documents.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="elementName">The name of the XML element being processed</param>
    /// <param name="id">The FatturaPA element ID (e.g., '2.2.1.15' for RiferimentoAmministrazione)</param>
    /// <param name="Value">The value to be written to the XML element</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
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
        TempDocument: Record "Sales Invoice Header" temporary;
        FldRef: FieldRef;
        CustNo: Code[20];
    begin
        case id of
            '2.2.1.15':
                begin
                    CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
                    if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
                        exit;
                    case OutbElectrDocSetupGroup."EOS Hook Group Code" of
                        'EOS_AMAZON':

                            if header.NUMBER() in [Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header"] then begin
                                DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FIELDNAME("External Document No."));
                                TempDocument."External Document No." := FldRef.VALUE();

                                if TempDocument."External Document No." <> '' then
                                    Value := CopyStr(TempDocument."External Document No.", 1, 20)

                            end;

                    end;
                end;
        end;
    end;

    /// <summary>
    /// Event subscriber that validates DatiBeniServizi (Goods and Services Data) section for specific hook groups.
    /// Performs hook-specific validation before generating the electronic invoice.
    /// For AMAZON: Delegates to AMAZON_OnCheckDatiBeniServizi for specific validation rules.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnCheckDatiBeniServizi', '', true, true)]
    local procedure OnCheckDatiBeniServizi(header: RecordRef; line: RecordRef)
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        CustNo: Code[20];
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                AMAZON_OnCheckDatiBeniServizi(header, line);
        end;
    end;


    /// <summary>
    /// Event subscriber that validates DatiGenerali (General Data) section for specific hook groups.
    /// Performs hook-specific validation of order references and related documents before generating the electronic invoice.
    /// For AMAZON: Delegates to AMAZON_OnCheckDatiGenerali for specific validation rules.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="OrderNoBuffer">Temporary buffer containing order number references</param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS FE Writer", 'OnCheckDatiGenerali', '', true, true)]
    local procedure OnCheckDatiGenerali(header: RecordRef; var OrderNoBuffer: Record "EOS RifLineNo Buffer" temporary)
    var
        TempDocument: Record "Sales Invoice Header" temporary;
        CustNo: Code[20];
    begin
        CustNo := header.field(TempDocument.FieldNo("Bill-to Customer No.")).Value();
        if not EOSEDocSetupMgt.GetCustGroupSetup(CustNo, OutbElectrDocSetupGroup, header) then
            exit;

        case OutbElectrDocSetupGroup."EOS Hook Group Code" of
            'EOS_AMAZON':
                AMAZON_OnCheckDatiGenerali(header, OrderNoBuffer);
        end;
    end;

    //#region AMAZON

    /// <summary>
    /// Validates the General Data section for AMAZON electronic invoices.
    /// Performs specific validations based on document type and reason code:
    /// - Sales Invoice: Validates DatiOrdineAcquisto (Purchase Order Data) is present, or validates DatiFattureCollegate for NDEB reason.
    /// - Sales Credit Memo: Validates reason code is present and validates related documents based on reason code (NCSTT, QPD, NCDIF, CCOGS).
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="OrderNoBuffer">Temporary buffer containing order number references</param>
    local procedure AMAZON_OnCheckDatiGenerali(header: RecordRef; var OrderNoBuffer: Record "EOS RifLineNo Buffer" temporary)
    var
        TempElectrDocRelatedDocs: Record "EOS Outb. EDoc. Related Docs." temporary;
        DocumentReason: Code[10];
        NumeroOrd: Text;
        DataOrd: Date;
        CIG: Code[15];
        CUP: Code[15];
        CodiceCommessaConvenzione: Text[100];
        IsHandled: Boolean;
        NoPurchOrderErr: Label 'AMAZON: DatiOrdineAcquisto mandatory for %1 document.';
        NoReasonCodeErr: Label 'AMAZON: Reason code mandatory for document %1.';
        NoAppliesToDocErr: Label 'AMAZON: DatiFattureCollegate mandatory for %1 document.';
    begin
        EOSFEData.setHeader(header);
        DocumentReason := GetAMAZONReasonCode(header);
        EOSFEData.getRelDocsTagsForCurrDoc(TempElectrDocRelatedDocs);
        EOSFEData.hasDirectOrder(NumeroOrd, DataOrd, CIG, CUP, CodiceCommessaConvenzione);
        case header.Number() of
            Database::"Sales Invoice Header":
                case DocumentReason of
                    '':
                        begin
                            if not EOSFEData.insertOrderData() then
                                Error(NoPurchOrderErr, 'Invoice');
                            if NumeroOrd <> '' then
                                exit;
                            TempElectrDocRelatedDocs.SetRange("EOS Type", TempElectrDocRelatedDocs."EOS Type"::DatiOrdineAcquisto);
                            if not TempElectrDocRelatedDocs.IsEmpty() then
                                exit;
                            OrderNoBuffer.SetFilter("EOS Doc No.", '<>%1', '');
                            if OrderNoBuffer.IsEmpty() then
                                Error(NoPurchOrderErr, 'Invoice');
                            if not OutbElectrDocSetupGroup."EOS Exp. DatiOrdAcq Sales Inv." then
                                Error(NoPurchOrderErr, 'Invoice');
                        end;
                    'NDEB':
                        begin
                            TempElectrDocRelatedDocs.SetRange("EOS Type", TempElectrDocRelatedDocs."EOS Type"::DatiFattureCollegate);
                            if TempElectrDocRelatedDocs.IsEmpty() then
                                Error(NoAppliesToDocErr, DocumentReason);
                        end;
                end;
            Database::"Sales Cr.Memo Header":
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
                                TempElectrDocRelatedDocs.SetRange("EOS Type", TempElectrDocRelatedDocs."EOS Type"::DatiOrdineAcquisto);
                                if TempElectrDocRelatedDocs.IsEmpty() then
                                    if NumeroOrd = '' then
                                        Error(NoPurchOrderErr, DocumentReason);

                                TempElectrDocRelatedDocs.SetRange("EOS Type", TempElectrDocRelatedDocs."EOS Type"::DatiFattureCollegate);
                                if TempElectrDocRelatedDocs.IsEmpty() then
                                    Error(NoAppliesToDocErr, DocumentReason);
                            end;
                        'NCDIF',
                        'CCOGS':
                            begin
                                TempElectrDocRelatedDocs.SetRange("EOS Type", TempElectrDocRelatedDocs."EOS Type"::DatiFattureCollegate);
                                if TempElectrDocRelatedDocs.IsEmpty() then
                                    Error(NoAppliesToDocErr, DocumentReason);
                            end;
                    end;
                end;
        end;
    end;

    /// <summary>
    /// Validates the Goods and Services Data section for AMAZON electronic invoices at line level.
    /// Performs specific validations based on document type and reason code:
    /// - Sales Invoice with NDEB: Validates RiferimentoAmministrazione is present.
    /// - Sales Credit Memo with VRET/NCDIF: Validates CodiceArticolo and RiferimentoAmministrazione are present.
    /// - Sales Credit Memo with QPD/NCSTT/COGS: Validates RiferimentoAmministrazione is present.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef</param>
    local procedure AMAZON_OnCheckDatiBeniServizi(header: RecordRef; line: RecordRef)
    var
        TempDocumentLine: Record "Sales Invoice Line" temporary;
        TempDocument: Record "Sales Invoice Header" temporary;
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
        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
        TempDocumentLine.Type := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
        TempDocumentLine."Line No." := FldRef.Value();
        DataTypeManagement.FindFieldByName(header, FldRef, TempDocument.FieldName("External Document No."));
        TempDocument."External Document No." := FldRef.Value();
        case header.Number() of
            Database::"Sales Invoice Header":
                case DocumentReason of
                    'NDEB':
                        if TempDocument."External Document No." = '' then begin
                            EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::RiferimentoAmministrazione);
                            if EOSEDocRelDocLines.IsEmpty() then
                                Error(NoRiferimentoAmministrazioneErr, DocumentReason, TempDocumentLine."Line No.");
                        end;
                end;
            Database::"Sales Cr.Memo Header":
                case DocumentReason of
                    'VRET',
                    'NCDIF':
                        begin
                            EOSOutbElectrDocSetup.Get();
                            if not EOSOutbElectrDocSetup."EOS Add Item Code" then
                                Error(NoItemCodeErr, DocumentReason, TempDocumentLine."Line No.");
                            if TempDocumentLine.Type <> TempDocumentLine.Type::Item then begin
                                EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::CodiceArticolo);
                                if EOSEDocRelDocLines.IsEmpty() then
                                    Error(NoItemCodeErr, DocumentReason, TempDocumentLine."Line No.");
                            end;

                            if TempDocument."External Document No." = '' then begin
                                EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::RiferimentoAmministrazione);
                                if EOSEDocRelDocLines.IsEmpty() then
                                    Error(NoRiferimentoAmministrazioneErr, DocumentReason, TempDocumentLine."Line No.");
                            end;
                        end;
                    'QPD',
                    'NCSTT',
                    'COGS':
                        if TempDocument."External Document No." = '' then begin
                            EOSEDocRelDocLines.SetRange(Type, EOSEDocRelDocLines.Type::RiferimentoAmministrazione);
                            if EOSEDocRelDocLines.IsEmpty() then
                                Error(NoRiferimentoAmministrazioneErr, DocumentReason, TempDocumentLine."Line No.");
                        end;
                end;
        end;
    end;

    /// <summary>
    /// Retrieves the AMAZON-specific reason code from the document header.
    /// Evaluates the Causale tags and Reason Code description to determine the appropriate AMAZON reason code.
    /// Valid reason codes for Sales Invoice: NDEB.
    /// Valid reason codes for Sales Credit Memo: NCSTT, NCDIF, QPD, VRET, CCOGS.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <returns>The AMAZON-specific reason code, or empty if no matching reason is found</returns>
    local procedure GetAMAZONReasonCode(header: RecordRef) Reason: Code[10]
    var
        ReasonCode: Record "Reason Code";
        ReasonCodeValue: Code[10];
        CausaleList: List of [Text];
        CausaleConai: Text;
        CausaleDutyStamp: Text;
    begin
        EOSFEData.getCausaleTags(CausaleList, CausaleConai, CausaleDutyStamp);

        ReasonCodeValue := GetDocumentReasonCode(header);

        if ReasonCode.Get(ReasonCodeValue) then
            CausaleList.Add(ReasonCode.Description);

        case header.Number() of
            Database::"Sales Invoice Header":
                begin
                    ReasonCodeValue := 'NDEB';
                    if CausaleList.Contains(ReasonCodeValue) then
                        Reason := ReasonCodeValue;
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    ReasonCodeValue := 'NCSTT';
                    if CausaleList.Contains(ReasonCodeValue) then
                        Reason := ReasonCodeValue;
                    ReasonCodeValue := 'NCDIF';
                    if CausaleList.Contains(ReasonCodeValue) then
                        Reason := ReasonCodeValue;
                    ReasonCodeValue := 'QPD';
                    if CausaleList.Contains(ReasonCodeValue) then
                        Reason := ReasonCodeValue;
                    ReasonCodeValue := 'VRET';
                    if CausaleList.Contains(ReasonCodeValue) then
                        Reason := ReasonCodeValue;
                    ReasonCodeValue := 'CCOGS';
                    if CausaleList.Contains(ReasonCodeValue) then
                        Reason := ReasonCodeValue;
                end;
        end;
    end;

    /// <summary>
    /// Handles the CodiceArticolo (Item Code) XML element generation specifically for AMAZON hook group.
    /// Generates two CodiceArticolo elements for items:
    /// 1. EAN code from Item Reference (Bar Code type with Hook Group Code as Reference Type No.)
    /// 2. SKU code with the Item No.
    /// </summary>
    /// <param name="header">The document header RecordRef</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    /// <param name="handled">Set to true to indicate that the CodiceArticolo has been handled</param>
    local procedure AMAZON_OnBefore_CodiceArticolo(header: RecordRef; line: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var handled: Boolean)
    var
        TempDocumentLine: Record "Sales Invoice Line" temporary;
        ItemReference: Record "Item Reference";
        FldRef: FieldRef;
        isHandled: Boolean;
    begin
        if not (line.Number() in [Database::"Sales Invoice Line", Database::"Sales Cr.Memo Line"]) then
            exit;

        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Line No."));
        TempDocumentLine."Line No." := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName(Type));
        TempDocumentLine.Type := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Variant Code"));
        TempDocumentLine."Variant Code" := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("No."));
        TempDocumentLine."No." := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Unit of Measure Code"));
        TempDocumentLine."Unit of Measure Code" := FldRef.Value();
        DataTypeManagement.FindFieldByName(line, FldRef, TempDocumentLine.FieldName("Item Reference No."));
        TempDocumentLine."Item Reference No." := FldRef.Value();

        if TempDocumentLine.Type = TempDocumentLine.Type::Item then begin
            ItemReference.SetRange("Item No.", TempDocumentLine."No.");
            ItemReference.SetRange("Variant Code", TempDocumentLine."Variant Code");
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetRange("Unit of Measure", TempDocumentLine."Unit of Measure Code");
            ItemReference.SetRange("Reference Type No.", OutbElectrDocSetupGroup."EOS Hook Group Code");
            //TempItemReference.SETRANGE("Discontinue Bar Code", false);
            if not ItemReference.FindFirst() then
                ItemReference.SetRange("Unit of Measure");
            isHandled := false;
            OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);

            if not isHandled then
                if ItemReference.FindFirst() then begin
                    isHandled := false;
                    OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup, header, line, ItemReference, XmlWriter, isHandled);
                    if not isHandled then begin
                        XmlWriter.WriteStartElement('CodiceArticolo');
                        XmlWriter.WriteElementValue('CodiceTipo', 'EAN');
                        XmlWriter.WriteElementValue('CodiceValore', ItemReference."Reference No.");
                        XmlWriter.WriteEndElement();
                    end;
                end;

            XmlWriter.WriteStartElement('CodiceArticolo');
            XmlWriter.WriteElementValue('CodiceTipo', 'SKU');
            XmlWriter.WriteElementValue('CodiceValore', TempDocumentLine."No.");
            XmlWriter.WriteEndElement();
        end;
        Handled := true;
    end;


    //#endregion AMAZON

    /// <summary>
    /// Raised during the General Data validation for AMAZON, before checking the Reason Code, while generating an electronic document for a Sales Credit Memo.
    /// Use this event to provide a custom reason code or to skip the reason code validation.
    /// </summary>
    /// <param name="header">The Sales Credit Memo header RecordRef</param>
    /// <param name="DocumentReason">The Reason Code value. If empty after the event and IsHandled is false, an error will be raised</param>
    /// <param name="IsHandled">Set to true to skip the default reason code validation error</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAmazonDocumentReasonSalesCrMemo(header: RecordRef; var DocumentReason: Code[10]; var IsHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before the Causale (Reason) XML tag is filled, allowing customization of the tag content.
    /// Use this event to implement custom Causale logic for specific hook groups or customers.
    /// </summary>
    /// <param name="header">The document header RecordRef (Sales/Service Invoice or Credit Memo)</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    /// <param name="OutbElectrDocSetupGroup">The Outbound Electronic Document Group Setup record containing hook configuration</param>
    /// <param name="Handled">Set to true to skip the default Causale tag filling behavior</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnFillCausaleTag(var header: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var OutbElectrDocSetupGroup: Record "EOS Outb. EDoc. Group Setup"; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised after applying default filters to the Item Reference record during CodiceArticolo processing.
    /// Use this event to apply additional filters, modify existing filters, or implement custom Item Reference lookup logic.
    /// </summary>
    /// <param name="OutbElectrDocSetupGroup">The Outbound Electronic Document Group Setup record containing hook configuration</param>
    /// <param name="header">The document header RecordRef (Sales/Service Invoice or Credit Memo)</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="ItemReference">The Item Reference record with default filters applied. Modify this to change lookup behavior</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    /// <param name="isHandled">Set to true to skip the default Item Reference processing and CodiceArticolo XML generation</param>
    [IntegrationEvent(false, false)]
    local procedure OnAfterItemReferenceFilters_CodiceArticolo(OutbElectrDocSetupGroup: Record "EOS Outb. EDoc. Group Setup"; header: RecordRef; line: RecordRef;
                                                                var ItemReference: Record "Item Reference"; var XmlWriter: Codeunit "EOS Xml Writer"; var isHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before creating the CodiceArticolo XML node for each Item Reference during the loop.
    /// Use this event to customize how individual Item References are exported or to skip specific references.
    /// </summary>
    /// <param name="OutbElectrDocSetupGroup">The Outbound Electronic Document Group Setup record containing hook configuration</param>
    /// <param name="header">The document header RecordRef (Sales/Service Invoice or Credit Memo)</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="ItemReference">The current Item Reference record being processed</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    /// <param name="isHandled">Set to true to skip the default CodiceArticolo XML generation for this Item Reference</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportItemReference_CodiceArticolo(OutbElectrDocSetupGroup: Record "EOS Outb. EDoc. Group Setup"; header: RecordRef; line: RecordRef;
                                                                var ItemReference: Record "Item Reference"; var XmlWriter: Codeunit "EOS Xml Writer"; var isHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before creating any CodiceArticolo XML node for the document line.
    /// Use this event to completely customize the CodiceArticolo generation or to add custom item codes before the default processing.
    /// This event is raised for hook groups that do not use Item Reference lookup (e.g., METRO, AUTOGRILL, FERRARI, OBI, BRICO_SELF).
    /// </summary>
    /// <param name="OutbElectrDocSetupGroup">The Outbound Electronic Document Group Setup record containing hook configuration</param>
    /// <param name="header">The document header RecordRef (Sales/Service Invoice or Credit Memo)</param>
    /// <param name="line">The document line RecordRef</param>
    /// <param name="XmlWriter">The XML Writer used to generate the electronic invoice XML</param>
    /// <param name="isHandled">Set to true to skip the default CodiceArticolo XML generation for this line</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExport_CodiceArticolo(OutbElectrDocSetupGroup: Record "EOS Outb. EDoc. Group Setup"; header: RecordRef; line: RecordRef; var XmlWriter: Codeunit "EOS Xml Writer"; var isHandled: Boolean)
    begin
    end;

    /// <summary>
    /// Raised before retrieving the standard Reason Code value from the document header.
    /// Use this event to provide a custom Reason Code value based on document data or external logic.
    /// </summary>
    /// <param name="OutbElectrDocSetupGroup">The Outbound Electronic Document Group Setup record containing hook configuration</param>
    /// <param name="header">The document header RecordRef (Sales/Service Invoice or Credit Memo)</param>
    /// <param name="ReasonCode">The Reason Code value. Set this to provide a custom value</param>
    /// <param name="isHandled">Set to true to use the custom ReasonCode value and skip the default field retrieval</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReasonCode(OutbElectrDocSetupGroup: Record "EOS Outb. EDoc. Group Setup"; header: RecordRef; var ReasonCode: Code[10]; var isHandled: Boolean)
    begin
    end;

}
