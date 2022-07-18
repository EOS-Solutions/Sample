codeunit 18090629 "EOS038 Standard Param Calc." implements "EOS038 Shipp. Price Param Calculation"
{
    var
        Item: Record Item;
        Check000Msg: Label 'Unexpected %1 table';

    procedure CalcHeaderValues(SourceDoc: RecordRef; var TmpParamBuffer: Record "EOS Doc. Line Param. Buffer")
    var
        TempSalesHeader: Record "Sales Header" temporary;
        SalesLines: Record "Sales Line";
        TempPurchaseHeader: Record "Purchase Header" temporary;
        PurchaseLine: Record "Purchase Line";
        TempSalesShipmentHeader: Record "Sales Shipment Header" temporary;
        SalesShipmentLine: Record "Sales Shipment Line";
        TempPurchRcptHeader: Record "Purch. Rcpt. Header" temporary;
        PurchRcptLine: Record "Purch. Rcpt. Line";
        TempTransferHeader: Record "Transfer Header" temporary;
        TransferLine: Record "Transfer Line";
        TempTransferShipmentHeader: Record "Transfer Shipment Header" temporary;
        TransferShipmentLine: Record "Transfer Shipment Line";
        ItemDocLine: Record Item;
        DataTypeManagement: Codeunit "Data Type Management";
        TotalNetWeight: Decimal;
        TotalGrossWeight: Decimal;
        TotalVolume: Decimal;
        TotalParcels: Decimal;
        TotalPallets: Decimal;
    begin
        case SourceDoc.Number() of
            database::"Sales Header":
                begin
                    SourceDoc.SetTable(TempSalesHeader);
                    SalesLines.SetRange("Document No.", TempSalesHeader."No.");
                    SalesLines.SetRange("Document Type", TempSalesHeader."Document Type");
                    if SalesLines.FindSet() then
                        repeat
                            TotalNetWeight := TotalNetWeight + (SalesLines.Quantity * SalesLines."Net Weight");
                            TotalGrossWeight := TotalGrossWeight + (SalesLines.Quantity * SalesLines."Gross Weight");
                            TotalVolume := TotalVolume + (SalesLines.Quantity * SalesLines."Unit Volume");
                            if SalesLines."Units per Parcel" > 0 then
                                TotalParcels := TotalParcels + Round(SalesLines.Quantity / SalesLines."Units per Parcel", 1, '>');

                            if (SalesLines.Type = SalesLines.Type::Item) and (ItemDocLine.get(SalesLines."No.")) then
                                if ItemDocLine."EOS Units per Pallet" > 0 then
                                    TotalPallets := TotalPallets + Round(SalesLines.Quantity / ItemDocLine."EOS Units per Pallet", 1, '>');

                        until SalesLines.Next() = 0;
                end;
            database::"Purchase Header":
                begin
                    SourceDoc.SetTable(TempPurchaseHeader);
                    PurchaseLine.SetRange("Document No.", TempPurchaseHeader."No.");
                    PurchaseLine.SetRange("Document Type", TempPurchaseHeader."Document Type");
                    if PurchaseLine.FindSet() then
                        repeat
                            TotalNetWeight := TotalNetWeight + (PurchaseLine.Quantity * PurchaseLine."Net Weight");
                            TotalGrossWeight := TotalGrossWeight + (PurchaseLine.Quantity * PurchaseLine."Gross Weight");
                            TotalVolume := TotalVolume + (PurchaseLine.Quantity * PurchaseLine."Unit Volume");
                            if PurchaseLine."Units per Parcel" > 0 then
                                TotalParcels := TotalParcels + Round(PurchaseLine.Quantity / PurchaseLine."Units per Parcel", 1, '>');

                            if (PurchaseLine.Type = PurchaseLine.Type::Item) and (ItemDocLine.get(PurchaseLine."No.")) then
                                if ItemDocLine."EOS Units per Pallet" > 0 then
                                    TotalPallets := TotalPallets + Round(PurchaseLine.Quantity / ItemDocLine."EOS Units per Pallet", 1, '>');

                        until PurchaseLine.Next() = 0;
                end;
            database::"Sales Shipment Header":
                begin
                    SourceDoc.SetTable(TempSalesShipmentHeader);
                    SalesShipmentLine.SetRange("Document No.", TempSalesShipmentHeader."No.");
                    if SalesShipmentLine.FindSet() then
                        repeat
                            TotalNetWeight := TotalNetWeight + (SalesShipmentLine.Quantity * SalesShipmentLine."Net Weight");
                            TotalGrossWeight := TotalGrossWeight + (SalesShipmentLine.Quantity * SalesShipmentLine."Gross Weight");
                            TotalVolume := TotalVolume + (SalesShipmentLine.Quantity * SalesShipmentLine."Unit Volume");
                            if SalesShipmentLine."Units per Parcel" > 0 then
                                TotalParcels := TotalParcels + Round(SalesShipmentLine.Quantity / SalesShipmentLine."Units per Parcel", 1, '>');

                            if (SalesShipmentLine.Type = SalesShipmentLine.Type::Item) and (ItemDocLine.get(SalesShipmentLine."No.")) then
                                if ItemDocLine."EOS Units per Pallet" > 0 then
                                    TotalPallets := TotalPallets + Round(SalesShipmentLine.Quantity / ItemDocLine."EOS Units per Pallet", 1, '>');

                        until SalesShipmentLine.Next() = 0;
                end;
            database::"Purch. Rcpt. Header":
                begin
                    SourceDoc.SetTable(TempPurchRcptHeader);
                    PurchRcptLine.SetRange("Document No.", TempPurchRcptHeader."No.");
                    if PurchRcptLine.FindSet() then
                        repeat
                            TotalNetWeight := TotalNetWeight + (PurchRcptLine.Quantity * PurchRcptLine."Net Weight");
                            TotalGrossWeight := TotalGrossWeight + (PurchRcptLine.Quantity * PurchRcptLine."Gross Weight");
                            TotalVolume := TotalVolume + (PurchRcptLine.Quantity * PurchRcptLine."Unit Volume");
                            if PurchRcptLine."Units per Parcel" > 0 then
                                TotalParcels := TotalParcels + Round(PurchRcptLine.Quantity / PurchRcptLine."Units per Parcel", 1, '>');

                            if (PurchRcptLine.Type = PurchRcptLine.Type::Item) and (ItemDocLine.get(PurchRcptLine."No.")) then
                                if ItemDocLine."EOS Units per Pallet" > 0 then
                                    TotalPallets := TotalPallets + Round(PurchRcptLine.Quantity / ItemDocLine."EOS Units per Pallet", 1, '>');

                        until PurchRcptLine.Next() = 0;
                end;
            database::"Transfer Header":
                begin
                    SourceDoc.SetTable(TempTransferHeader);

                    TransferLine.SetRange("Document No.", TempTransferHeader."No.");
                    if TransferLine.FindSet() then
                        repeat
                            TotalNetWeight := TotalNetWeight + (TransferLine.Quantity * TransferLine."Net Weight");
                            TotalGrossWeight := TotalGrossWeight + (TransferLine.Quantity * TransferLine."Gross Weight");
                            TotalVolume := TotalVolume + (TransferLine.Quantity * TransferLine."Unit Volume");
                            if TransferLine."Units per Parcel" > 0 then
                                TotalParcels := TotalParcels + Round(TransferLine.Quantity / TransferLine."Units per Parcel", 1, '>');

                            if (ItemDocLine.get(TransferLine."Item No.")) then
                                if ItemDocLine."EOS Units per Pallet" > 0 then
                                    TotalPallets := TotalPallets + Round(TransferLine.Quantity / ItemDocLine."EOS Units per Pallet", 1, '>');

                        until TransferLine.Next() = 0;
                end;
            database::"Transfer Shipment Header":
                begin
                    SourceDoc.SetTable(TempTransferShipmentHeader);

                    TransferShipmentLine.SetRange("Document No.", TempTransferShipmentHeader."No.");
                    if TransferShipmentLine.FindSet() then
                        repeat
                            TotalNetWeight := TotalNetWeight + (TransferShipmentLine.Quantity * TransferShipmentLine."Net Weight");
                            TotalGrossWeight := TotalGrossWeight + (TransferShipmentLine.Quantity * TransferShipmentLine."Gross Weight");
                            TotalVolume := TotalVolume + (TransferShipmentLine.Quantity * TransferShipmentLine."Unit Volume");
                            if TransferShipmentLine."Units per Parcel" > 0 then
                                TotalParcels := TotalParcels + Round(TransferShipmentLine.Quantity / TransferShipmentLine."Units per Parcel", 1, '>');

                            if (ItemDocLine.get(TransferShipmentLine."Item No.")) then
                                if ItemDocLine."EOS Units per Pallet" > 0 then
                                    TotalPallets := TotalPallets + Round(TransferShipmentLine.Quantity / ItemDocLine."EOS Units per Pallet", 1, '>');

                        until TransferShipmentLine.Next() = 0;
                end;
        end;

        OnBeforeSetTotalValues(SourceDoc, TmpParamBuffer, TotalNetWeight, TotalGrossWeight, TotalVolume, TotalPallets, TotalParcels);
        TmpParamBuffer.SetValue(TmpParamBuffer.FieldNo("EOS Net Weight"), TotalNetWeight);
        TmpParamBuffer.SetValue(TmpParamBuffer.FieldNo("EOS Gross Weight"), TotalGrossWeight);
        TmpParamBuffer.SetValue(TmpParamBuffer.FieldNo("EOS Volume"), TotalVolume);
        TmpParamBuffer.SetValue(TmpParamBuffer.FieldNo("EOS No. of Pallets"), TotalPallets);
        TmpParamBuffer.SetValue(TmpParamBuffer.FieldNo("EOS No. of Parcels"), TotalParcels);

    end;

    procedure GetGeoParams(var RecRef: RecordRef; var City: Text[30]; var PostCode: Code[20]; var County: Text[30]; var CountryCode: Code[10]; var TerritoryCode: Code[10]; var ISTATCityCode: Code[10]; var GeoErrorMessage: Text[250]): Boolean;
    var
        SalesHeader: Record "Sales Header";
        SalesShptHeader: Record "Sales Shipment Header";
        TransferHeader: Record "Transfer Header";
        TransferShptHeader: Record "Transfer Shipment Header";
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        CountryRegion: Record "Country/Region";
        ShippingPriceMgt: Codeunit "EOS Shipping Price Mgt.";
        RecRef2: RecordRef;
        Result: Boolean;
    begin
        GeoErrorMessage := '';
        RecRef2 := RecRef.Duplicate();
        case RecRef2.Number() of
            DATABASE::"Sales Header":
                begin
                    RecRef2.SetTable(SalesHeader);
                    City := SalesHeader."Ship-to City";
                    PostCode := SalesHeader."Ship-to Post Code";
                    Result := ShippingPriceMgt.GetDataFromPostCode(SalesHeader."Ship-to Post Code", ISTATCityCode, County, TerritoryCode, GeoErrorMessage, city);
                    CountryCode := SalesHeader."Ship-to Country/Region Code";
                end;
            DATABASE::"Sales Shipment Header":
                begin
                    RecRef2.SetTable(SalesShptHeader);
                    City := SalesShptHeader."Ship-to City";
                    PostCode := SalesShptHeader."Ship-to Post Code";
                    Result := ShippingPriceMgt.GetDataFromPostCode(SalesShptHeader."Ship-to Post Code", ISTATCityCode, County, TerritoryCode, GeoErrorMessage, City);
                    CountryCode := SalesShptHeader."Ship-to Country/Region Code";
                end;
            DATABASE::"Transfer Header":
                begin
                    RecRef2.SetTable(TransferHeader);
                    City := TransferHeader."Transfer-to City";
                    PostCode := TransferHeader."Transfer-to Post Code";
                    Result := ShippingPriceMgt.GetDataFromPostCode(TransferHeader."Transfer-to Post Code", ISTATCityCode, County, TerritoryCode, GeoErrorMessage, City);
                    CountryCode := TransferHeader."Trsf.-to Country/Region Code";
                end;
            DATABASE::"Transfer Shipment Header":
                begin
                    RecRef2.SetTable(TransferShptHeader);
                    City := TransferShptHeader."Transfer-to City";
                    PostCode := TransferShptHeader."Transfer-to Post Code";
                    Result := ShippingPriceMgt.GetDataFromPostCode(TransferShptHeader."Transfer-to Post Code", ISTATCityCode, County, TerritoryCode, GeoErrorMessage, City);
                    CountryCode := TransferShptHeader."Trsf.-to Country/Region Code";
                end;
            DATABASE::"Purchase Header":
                begin
                    RecRef2.SetTable(PurchHeader);
                    City := PurchHeader."Buy-from City";
                    PostCode := PurchHeader."Buy-from Post Code";
                    Result := ShippingPriceMgt.GetDataFromPostCode(PurchHeader."Buy-from Post Code", ISTATCityCode, County, TerritoryCode, GeoErrorMessage, City);
                    CountryCode := PurchHeader."Buy-from Country/Region Code";
                end;
            DATABASE::"Purch. Rcpt. Header":
                begin
                    RecRef2.SetTable(PurchRcptHeader);
                    City := PurchRcptHeader."Buy-from City";
                    PostCode := PurchRcptHeader."Buy-from Post Code";
                    Result := ShippingPriceMgt.GetDataFromPostCode(PurchRcptHeader."Buy-from Post Code", ISTATCityCode, County, TerritoryCode, GeoErrorMessage, City);
                    CountryCode := PurchRcptHeader."Buy-from Country/Region Code";
                end;
            else
                Error(Check000Msg, RecRef2.Number());
        end;
        if CountryRegion.Get(CountryCode) then
            if CountryRegion."EOS038 Skip Post Code Errors" then begin
                Result := true;
                GeoErrorMessage := '';
            end;

        exit(Result);
    end;


    procedure GetDocParams(var RecRef: RecordRef; var CustNo: Code[20]; var ShipToCode: Code[20]; var ShippingAgentCode: Code[20]; var ShippingAgentServiceCode: Code[20]; var LocationCode: Code[10]; var ToLocationCode: Code[10]; var TourCode: Code[10]; var RefDate: Date; var DocAmount: Decimal; var DocParcelNumber: Decimal; var DocWeight: Decimal; var DocVolume: Decimal; var DocPalletNumber: Decimal; var DocKm: Decimal; var DocHours: Decimal; var DocTourAmount: Decimal; var DocGrossWeight: Decimal; SkipTourTotals: Boolean);
    var
        SalesHeader: Record "Sales Header";
        SalesShptHeader: Record "Sales Shipment Header";
        TransferHeader: Record "Transfer Header";
        TransferShptHeader: Record "Transfer Shipment Header";
        PurchHeader: Record "Purchase Header";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        TempParamBuffer: Record "EOS Doc. Line Param. Buffer" temporary;
        TransportCostSetup: Record "EOS038 Transport Cost Setup";
        EOSShippingPriceMgt: Codeunit "EOS Shipping Price Mgt.";
        ParamCalculation: interface "EOS038 Shipp. Price Param Calculation";
        RecRef2: RecordRef;
        TourShipAgentServiceCode: Code[10];
        TourKM: Decimal;
        TourHours: Decimal;
        TourAmount: Decimal;

    begin
        RecRef2 := RecRef.Duplicate();

        case RecRef2.Number() of

            DATABASE::"Sales Header":
                begin
                    RecRef2.SetTable(SalesHeader);
                    if not SkipTourTotals then
                        EOSShippingPriceMgt.CalcTourTotals(0, '', TourKM, TourHours, TourAmount, TourShipAgentServiceCode, TourCode);
                    CustNo := SalesHeader."Sell-to Customer No.";
                    ShipToCode := SalesHeader."Ship-to Code";
                    ShippingAgentCode := SalesHeader."Shipping Agent Code";
                    if TourShipAgentServiceCode <> '' then
                        ShippingAgentServiceCode := TourShipAgentServiceCode
                    else
                        ShippingAgentServiceCode := SalesHeader."Shipping Agent Service Code";

                    case SalesHeader."Document Type" of
                        SalesHeader."Document Type"::"Return Order":
                            begin
                                ToLocationCode := SalesHeader."Location Code";
                                LocationCode := '';
                            end;
                        else begin
                                LocationCode := SalesHeader."Location Code";
                                ToLocationCode := '';
                            end;
                    end;


                    RefDate := SalesHeaderRefDate(SalesHeader);
                    DocAmount := CalcSalesAmount(SalesHeader, 0);

                    if TourAmount <> 0 then begin
                        DocKm := Round(TourKM * DocAmount / TourAmount, 0.00001);
                        DocHours := Round(TourHours * DocAmount / TourAmount, 0.00001);
                        DocTourAmount := Round(DocAmount / TourAmount, 0.00001);
                    end else begin
                        DocKm := 0;
                        DocHours := 0;
                        DocTourAmount := 0;
                        DocKm := SalesHeader."EOS Mileage";
                        DocHours := SalesHeader."EOS Trip Hours";
                    end;
                end;

            DATABASE::"Sales Shipment Header":
                begin
                    RecRef2.SetTable(SalesShptHeader);
                    if not SkipTourTotals then
                        EOSShippingPriceMgt.CalcTourTotals(0, '', TourKM, TourHours, TourAmount, TourShipAgentServiceCode, TourCode);
                    CustNo := SalesShptHeader."Sell-to Customer No.";
                    ShipToCode := SalesShptHeader."Ship-to Code";
                    ShippingAgentCode := SalesShptHeader."Shipping Agent Code";
                    if TourShipAgentServiceCode <> '' then
                        ShippingAgentServiceCode := TourShipAgentServiceCode
                    else
                        ShippingAgentServiceCode := SalesShptHeader."Shipping Agent Service Code";
                    LocationCode := SalesShptHeader."Location Code";
                    ToLocationCode := '';
                    RefDate := SalesShptHeader."Posting Date";
                    DocAmount := CalcSalesShptAmount(SalesShptHeader);

                    if TourAmount <> 0 then begin
                        DocKm := Round(TourKM * DocAmount / TourAmount, 0.00001);
                        DocHours := Round(TourHours * DocAmount / TourAmount, 0.00001);
                        DocTourAmount := Round(DocAmount / TourAmount, 0.00001);
                    end else begin
                        DocKm := 0;
                        DocHours := 0;
                        DocTourAmount := 0;
                        DocKm := SalesShptHeader."EOS Mileage";
                        DocHours := SalesShptHeader."EOS Trip Hours";
                    end;
                end;
            DATABASE::"Transfer Header":
                begin
                    RecRef2.SetTable(TransferHeader);
                    if not SkipTourTotals then
                        EOSShippingPriceMgt.CalcTourTotals(0, '', TourKM, TourHours, TourAmount, TourShipAgentServiceCode, TourCode);
                    ShippingAgentCode := TransferHeader."Shipping Agent Code";
                    if TourShipAgentServiceCode <> '' then
                        ShippingAgentServiceCode := TourShipAgentServiceCode
                    else
                        ShippingAgentServiceCode := TransferHeader."Shipping Agent Service Code";
                    LocationCode := TransferHeader."Transfer-from Code";
                    ToLocationCode := TransferHeader."Transfer-to Code";
                    RefDate := TransferHeaderRefDate(TransferHeader);
                    DocAmount := CalcTransferAmount(TransferHeader, 0);

                    if TourAmount <> 0 then begin
                        DocKm := Round(TourKM * DocAmount / TourAmount, 0.00001);
                        DocHours := Round(TourHours * DocAmount / TourAmount, 0.00001);
                        DocTourAmount := Round(DocAmount / TourAmount, 0.00001);
                    end else begin
                        DocKm := 0;
                        DocHours := 0;
                        DocTourAmount := 0;
                        DocKm := TransferHeader."EOS Mileage";
                        DocHours := TransferHeader."EOS Trip Hours";
                    end;
                end;
            DATABASE::"Transfer Shipment Header":
                begin
                    RecRef2.SetTable(TransferShptHeader);
                    if not SkipTourTotals then
                        EOSShippingPriceMgt.CalcTourTotals(0, '', TourKM, TourHours, TourAmount, TourShipAgentServiceCode, TourCode);
                    ShippingAgentCode := TransferShptHeader."Shipping Agent Code";
                    if TourShipAgentServiceCode <> '' then
                        ShippingAgentServiceCode := TourShipAgentServiceCode
                    else
                        ShippingAgentServiceCode := TransferShptHeader."Shipping Agent Service Code";
                    LocationCode := TransferShptHeader."Transfer-from Code";
                    ToLocationCode := TransferShptHeader."Transfer-to Code";
                    RefDate := TransferShptHeader."Posting Date";
                    DocAmount := CalcTransfShptAmount(TransferShptHeader);

                    if TourAmount <> 0 then begin
                        DocKm := Round(TourKM * DocAmount / TourAmount, 0.00001);
                        DocHours := Round(TourHours * DocAmount / TourAmount, 0.00001);
                        DocTourAmount := Round(DocAmount / TourAmount, 0.00001);
                    end else begin
                        DocKm := 0;
                        DocHours := 0;
                        DocTourAmount := 0;
                        DocKm := TransferShptHeader."EOS Mileage";
                        DocHours := TransferShptHeader."EOS Trip Hours";
                    end;
                end;
            DATABASE::"Purchase Header":
                begin
                    RecRef2.SetTable(PurchHeader);
                    if not SkipTourTotals then
                        EOSShippingPriceMgt.CalcTourTotals(1, '', TourKM, TourHours, TourAmount, TourShipAgentServiceCode, TourCode);
                    CustNo := PurchHeader."Sell-to Customer No.";
                    ShipToCode := PurchHeader."Ship-to Code";
                    ShippingAgentCode := PurchHeader."EOS Shipping Agent Code";
                    if TourShipAgentServiceCode <> '' then
                        ShippingAgentServiceCode := TourShipAgentServiceCode
                    else
                        ShippingAgentServiceCode := PurchHeader."EOS Ship. Agent Service Code";
                    ToLocationCode := PurchHeader."Location Code";
                    if ToLocationCode = '' then begin
                        PurchLine.Reset();
                        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                        PurchLine.SetRange("Document No.", PurchHeader."No.");
                        PurchLine.SetFilter("Location Code", '<>%1', '');
                        if PurchLine.FindFirst() then
                            ToLocationCode := PurchLine."Location Code";
                    end;
                    LocationCode := '';

                    if PurchHeader."Document Type" = PurchHeader."Document Type"::"Return Order" then begin
                        LocationCode := ToLocationCode;
                        ToLocationCode := '';
                    end;


                    RefDate := PurchHeaderRefDate(PurchHeader);
                    DocAmount := CalcPurchAmount(PurchHeader, 0);

                    if TourAmount <> 0 then begin
                        DocKm := Round(TourKM * DocAmount / TourAmount, 0.00001);
                        DocHours := Round(TourHours * DocAmount / TourAmount, 0.00001);
                        DocTourAmount := Round(DocAmount / TourAmount, 0.00001);
                    end else begin
                        DocKm := 0;
                        DocHours := 0;
                        DocTourAmount := 0;
                        DocKm := PurchHeader."EOS Mileage";
                        DocHours := PurchHeader."EOS Trip Hours";
                    end;
                end;
            DATABASE::"Purch. Rcpt. Header":
                begin
                    RecRef2.SetTable(PurchRcptHeader);
                    if not SkipTourTotals then
                        EOSShippingPriceMgt.CalcTourTotals(1, '', TourKM, TourHours, TourAmount, TourShipAgentServiceCode, TourCode);
                    CustNo := PurchRcptHeader."Sell-to Customer No.";
                    ShipToCode := PurchRcptHeader."Ship-to Code";
                    ShippingAgentCode := PurchRcptHeader."EOS Shipping Agent Code";
                    if TourShipAgentServiceCode <> '' then
                        ShippingAgentServiceCode := TourShipAgentServiceCode
                    else
                        ShippingAgentServiceCode := PurchRcptHeader."EOS Ship. Agent Service Code";
                    ToLocationCode := PurchRcptHeader."Location Code";
                    if ToLocationCode = '' then begin
                        PurchRcptLine.Reset();
                        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
                        PurchRcptLine.SetFilter("Location Code", '<>%1', '');
                        if PurchRcptLine.FindFirst() then
                            ToLocationCode := PurchRcptLine."Location Code";
                    end;
                    LocationCode := '';
                    RefDate := PurchRcptHeader."Posting Date";
                    DocAmount := CalcPurchRcptAmount(PurchRcptHeader);

                    if TourAmount <> 0 then begin
                        DocKm := Round(TourKM * DocAmount / TourAmount, 0.00001);
                        DocHours := Round(TourHours * DocAmount / TourAmount, 0.00001);
                        DocTourAmount := Round(DocAmount / TourAmount, 0.00001);
                    end else begin
                        DocKm := 0;
                        DocHours := 0;
                        DocTourAmount := 0;
                        DocKm := PurchRcptHeader."EOS Mileage";
                        DocHours := PurchRcptHeader."EOS Trip Hours";
                    end;
                end;
            else
                Error(Check000Msg, RecRef2.Number());
        end;

        CalcHeaderValues(RecRef, TempParamBuffer);
        DocWeight := TempParamBuffer."EOS Net Weight";
        DocGrossWeight := TempParamBuffer."EOS Gross Weight";
        DocVolume := TempParamBuffer."EOS Volume";
        DocParcelNumber := TempParamBuffer."EOS No. of Parcels";
        DocPalletNumber := TempParamBuffer."EOS No. of Pallets";
    end;

    local procedure SalesHeaderRefDate(SalesHeader: Record "Sales Header"): Date
    begin
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::"Blanket Order", SalesHeader."Document Type"::Quote]) and
            (SalesHeader."Posting Date" = 0D)
            then
            exit(WorkDate());
        if (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) and
           (SalesHeader."Order Date" = 0D)
        then
            exit(WorkDate())
        else
            exit(SalesHeader."Order Date");
        exit(SalesHeader."Posting Date");

    end;

    local procedure CalcSalesAmount(SalesHeader: Record "Sales Header"; QtyType: Option General,Invoicing,Shipping): Decimal
    var
        SalesLine: Record "Sales Line";
        TempSalesLine: Record "Sales Line" temporary;
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
        VATAmount: Decimal;
        ProfitPct: Decimal;
        ProfitLCY: Decimal;
        TotalAdjCostLCY: Decimal;
        VATAmountText: Text[30];
    begin
        TempSalesLine.DeleteAll();
        Clear(TempSalesLine);
        Clear(SalesPost);
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, QtyType);
        Clear(SalesPost);
        SalesLine.CalcVATAmountLines(QtyType, SalesHeader, TempSalesLine, TempVATAmountLine1);

        SalesPost.SumSalesLinesTemp(
          SalesHeader, TempSalesLine, QtyType, TotalSalesLine, TotalSalesLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);
        exit(TotalSalesLineLCY.Amount);
    end;

    local procedure CalcSalesShptAmount(SalesShptHeader: Record "Sales Shipment Header"): Decimal
    var
        SalesShptLine: Record "Sales Shipment Line";
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        TotalAmount: Decimal;
    begin
        SalesShptLine.SetRange("Document No.", SalesShptHeader."No.");
        if SalesShptLine.FindSet() then
            repeat
                TotalAmount += SalesShptLine."Item Charge Base Amount";
            until SalesShptLine.Next() = 0;
        if SalesShptHeader."Currency Code" <> '' then begin
            Currency.InitRoundingPrecision();
            TotalAmount := Round(
              CurrExchRate.ExchangeAmtFCYToLCY(
                SalesShptHeader."Posting Date", SalesShptHeader."Currency Code",
                TotalAmount, SalesShptHeader."Currency Factor"),
                      Currency."Amount Rounding Precision");
        end;
        exit(TotalAmount);
    end;

    local procedure TransferHeaderRefDate(TransferHeader: Record "Transfer Header"): Date
    begin
        if TransferHeader."Posting Date" <> 0D then
            exit(TransferHeader."Posting Date");
        exit(WorkDate());

    end;

    local procedure CalcPurchRcptAmount(PurchRcptHeader: Record "Purch. Rcpt. Header"): Decimal
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        TotalAmount: Decimal;
    begin
        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        if PurchRcptLine.FindSet() then
            repeat
                TotalAmount += PurchRcptLine."Item Charge Base Amount";
            until PurchRcptLine.Next() = 0;
        if PurchRcptHeader."Currency Code" <> '' then begin
            Currency.InitRoundingPrecision();
            TotalAmount := Round(
              CurrExchRate.ExchangeAmtFCYToLCY(
                PurchRcptHeader."Posting Date", PurchRcptHeader."Currency Code",
                TotalAmount, PurchRcptHeader."Currency Factor"),
                      Currency."Amount Rounding Precision");
        end;
        exit(TotalAmount);
    end;

    local procedure CalcPurchAmount(PurchHeader: Record "Purchase Header"; QtyType: Option General,Invoicing,Shipping): Decimal
    var
        PurchLine: Record "Purchase Line";
        TempPurchLine: Record "Purchase Line" temporary;
        TotalPurchLine: Record "Purchase Line";
        TotalPurchLineLCY: Record "Purchase Line";
        TempVATAmountLine1: Record "VAT Amount Line" temporary;
        PurchPost: Codeunit "Purch.-Post";
        VATAmount: Decimal;
        VATAmountText: Text[30];
    begin
        TempPurchLine.DeleteAll();
        Clear(TempPurchLine);
        Clear(PurchPost);
        PurchPost.GetPurchLines(PurchHeader, TempPurchLine, QtyType);
        Clear(PurchPost);
        PurchLine.CalcVATAmountLines(QtyType, PurchHeader, TempPurchLine, TempVATAmountLine1);

        PurchPost.SumPurchLinesTemp(
          PurchHeader, TempPurchLine, QtyType, TotalPurchLine, TotalPurchLineLCY,
          VATAmount, VATAmountText);
        exit(TotalPurchLineLCY.Amount);
    end;

    local procedure PurchHeaderRefDate(PurchHeader: Record "Purchase Header"): Date
    begin
        if (PurchHeader."Document Type" in [PurchHeader."Document Type"::"Blanket Order", PurchHeader."Document Type"::Quote]) and
   (PurchHeader."Posting Date" = 0D)
then
            exit(WorkDate());
        if (PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order"]) and
           (PurchHeader."Order Date" = 0D)
        then
            exit(WorkDate())
        else
            exit(PurchHeader."Order Date");
        exit(PurchHeader."Posting Date");

    end;

    local procedure CalcTransfShptAmount(TransferShptHeader: Record "Transfer Shipment Header"): Decimal
    var
        TransferShptLine: Record "Transfer Shipment Line";
        TotalShptAmount: Decimal;
    begin
        TransferShptLine.SetRange(TransferShptLine."Document No.", TransferShptHeader."No.");
        if TransferShptLine.FindSet() then
            repeat
                GetItem(TransferShptLine."Item No.");
                TotalShptAmount += TransferShptLine."Quantity (Base)" * Item."Unit Cost";
            until TransferShptLine.Next() = 0;

        exit(TotalShptAmount);
    end;

    local procedure CalcTransferAmount(TransferHeader: Record "Transfer Header"; QtyType: Option General,Invoicing,Shipping): Decimal
    var
        TransferLine: Record "Transfer Line";
        TotalAmount: Decimal;
    begin
        TransferLine.SetRange(TransferLine."Document No.", TransferHeader."No.");
        if TransferLine.FindSet() then
            repeat
                GetItem(TransferLine."Item No.");
                TotalAmount += TransferLine."Quantity (Base)" * Item."Unit Cost";
            until TransferLine.Next() = 0;

        exit(TotalAmount);
    end;

    local procedure GetItem(ItemNo: Code[20])
    begin
        if ItemNo = '' then
            Clear(Item)
        else
            if ItemNo <> Item."No." then
                Item.Get(ItemNo);
    end;

    /// <summary>
    /// Raised in the procedure CalcHeaderValues(), before set the totals values on Doc. Line Param. Buffer.
    /// </summary>
    /// <param name="SourceDoc">Source Document</param>
    /// <param name="TmpParamBuffer">Record "EOS Doc. Line Param. Buffer"</param>
    /// <param name="TotalNetWeight">Total net weight value of the source document lines</param>
    /// <param name="TotalGrossWeight">Total gross weight value of the source document lines</param>
    /// <param name="TotalVolume">Total volume value of the source document lines</param>
    /// <param name="TotalPallets">Total pallets value of the source document lines</param>
    /// <param name="TotalParcels">Total parcels value of the source document lines</param>
    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetTotalValues(SourceDoc: RecordRef; var TmpParamBuffer: Record "EOS Doc. Line Param. Buffer"; var TotalNetWeight: Decimal; var TotalGrossWeight: Decimal; var TotalVolume: Decimal; var TotalPallets: Decimal; var TotalParcels: Decimal)
    begin
    end;
}