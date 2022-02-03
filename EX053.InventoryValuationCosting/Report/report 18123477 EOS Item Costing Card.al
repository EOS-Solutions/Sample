report 18123477 "EOS Item Costing Card"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/ItemCostingCard.rdlc';
    Caption = 'Item Costing Card (IVC)';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem("Item Cost History"; "EOS Item Cost History")
        {
            DataItemTableView = SORTING("Period Code", "Low-Level Code", "Item No.");
            RequestFilterFields = "Period Code", "Item No.";
            column(Item_Cost_History_NP_COMPANYNAME; CompanyName())
            {
            }
            column(Item_Cost_History_NP_USERID; UserId())
            {
            }
            column(Item_Cost_History_NP_Date__; AsOfLbl + Format("Calc.Date"))
            {
            }
            column(Item_Cost_History_NP_TODAY_; Format(Today(), 0, 4))
            {
            }
            column(Item_Cost_History_NP__ItemFilter; "Item Cost History".TableCaption() + ': ' + ItemFilter)
            {
            }
            column(Item_Cost_History_NP__Item_No__; "Item No.")
            {
                IncludeCaption = true;
            }
            column(Item_Cost_History_NP_Description; Description)
            {
                IncludeCaption = true;
            }
            column(Item_Cost_History_NP__Production_BOM_No__; "Production BOM No.")
            {
                IncludeCaption = true;
            }
            column(Item_Cost_History_NP__Routing_No__; "Routing No.")
            {
                IncludeCaption = true;
            }
            column(Item_Cost_History_NP__Lot_Size_; "Lot Size")
            {
                IncludeCaption = true;
            }
            column(Item_Cost_History_NP__Base_Unit_of_Measure_; "Base Unit of Measure")
            {
            }
            column(Item_Cost_History_NP_Period_Code; "Period Code")
            {
            }
            dataitem(RoutingLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(Routing_History__Operation_No__; TempRoutingHistory."Operation No.")
                {
                }
                column(Routing_History_Type; format(TempRoutingHistory.Type))
                {
                }
                column(Routing_History__No__; TempRoutingHistory."No.")
                {
                }
                column(Routing_History_Description; TempRoutingHistory.Description)
                {
                }
                column(Routing_History__Setup_Time_; TempRoutingHistory."Setup Time")
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Routing_History__Run_Time_; TempRoutingHistory."Run Time")
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Routing_History_CostTime; CostTime)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Routing_History_ProdUnitCost; ProdUnitCost)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Routing_History_ProdTotalCost; ProdTotalCost)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Routing_History_Total_Cost; ProdTotalCost)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Routing_History_Period_Code; TempRoutingHistory."Period Code")
                {
                }
                column(Routing_History_Item_No_; TempRoutingHistory."Item No.")
                {
                }
                column(Routing_History_Routing_No_; TempRoutingHistory."Routing No.")
                {
                }
                column(Routing_History_InRouting; InRouting)
                {
                }

                trigger OnAfterGetRecord()
                var
                    UnitCostCalculation: Option Time,Unit;
                    DirUnitCost: Decimal;
                    IndirCostPct: Decimal;
                    OvhdRate: Decimal;
                begin
                    if RoutingLoop.Number = 1 then
                        TempRoutingHistory.FindSet()
                    else
                        TempRoutingHistory.Next();

                    ProdUnitCost := HistoryCostCalcMgt.GetRoutingHistoryUnitCost(TempRoutingHistory);
                    StandardCostCalc.CalcRtngCostPerUnit(TempRoutingHistory, DirUnitCost, IndirCostPct, OvhdRate, ProdUnitCost, UnitCostCalculation);

                    if ActualQtyFlg then
                        CostTime := TempRoutingHistory."Run Time"
                    else
                        CostTime :=
                    HistoryCostCalcMgt.CalcCostTime(TempRoutingHistory."Item No.",
                      MfgItemQtyBase,
                      TempRoutingHistory."Setup Time", TempRoutingHistory."Setup Time Unit of Meas. Code",
                      TempRoutingHistory."Run Time", TempRoutingHistory."Run Time Unit of Meas. Code", TempRoutingHistory."Lot Size",
                      TempRoutingHistory."Scrap Factor % (Accumulated)", TempRoutingHistory."Fixed Scrap Qty. (Accum.)",
                      TempRoutingHistory."Work Center No.", UnitCostCalculation, MfgSetup."Cost Incl. Setup",
                      TempRoutingHistory."Concurrent Capacities") / "Item Cost History"."Lot Size";

                    ProdTotalCost := CostTime * ProdUnitCost;
                    ProdTotalCostRpt += ProdTotalCost;
                end;

                trigger OnPostDataItem()
                begin
                    InRouting := false;
                end;

                trigger OnPreDataItem()
                begin
                    InRouting := true;
                    ProdTotalCostRpt := 0;

                    BuildRoutingHistoryTmp();
                    RoutingLoop.SetRange(Number, 1, TempRoutingHistory.Count());
                end;
            }
            dataitem(BOMLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(BOMLoop_Number; Number)
                {
                }
                column(BOMLoop_InBOM; InBOM)
                {
                }
                dataitem(BOMComponentLine; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    column(BOMComponentLine_ProdBOMLine_Level__Type_; Format(TempProductionBOMLine.Type))
                    {
                    }
                    column(BOMComponentLine_ProdBOMLine_Level___No__; TempProductionBOMLine."No.")
                    {
                    }
                    column(BOMComponentLine_ProdBOMLine_Level__Description; TempProductionBOMLine.Description)
                    {
                    }
                    column(BOMComponentLine_ProdBOMLine_Level__Quantity; TempProductionBOMLine.Quantity)
                    {
                        DecimalPlaces = 2 : 5;
                    }
                    column(BOMComponentLine_CompUnitCost; CompUnitCost)
                    {
                        DecimalPlaces = 2 : 5;
                    }
                    column(BOMComponentLine_CostTotal; CostTotal)
                    {
                        DecimalPlaces = 2 : 5;
                    }
                    column(BOMComponentLine_CompItemHistory__Base_Unit_of_Measure_; CompItemHistory."Base Unit of Measure")
                    {
                    }
                    column(BOMComponentLine_Number; Number)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        /*
                        IF (ProdBOMLine[Level].Type <> ProdBOMLine[Level].Type::Item) THEN
                          CurrReport.SKIP
                        */
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    Item: Record Item;
                //UOMFactor: Decimal;
                begin
                    if BOMLoop.Number = 1 then
                        TempProductionBOMLine.FindSet()
                    else
                        TempProductionBOMLine.Next();
                    Item.Get("Item Cost History"."Item No.");
                    //UOMFactor := 1 /
                    //  HistoryUOMMgt.GetQtyPerUnitOfMeasure("Item Cost History", TempProductionBOMLine."Header Unit of Measure Code");

                    CompItemQtyBase := StandardCostCalc.CalcCompItemQtyBase(TempProductionBOMLine, "Calc.Date", Quantity[Level], "Item Cost History"."Routing No.", true);
                    CompItemHistory.Get("Item Cost History"."Period Code", TempProductionBOMLine."No.");
                    TempProductionBOMLine.Quantity := CompItemQtyBase / "Item Cost History"."Lot Size";
                    CompUnitCost := ItemCostMgt.MaterialAverageCost(CompItemHistory."Period Code", CompItemHistory."Item No.", '', '', '', '', 0D, CostingPeriod."Ending Date");
                    CostTotal := Round(TempProductionBOMLine.Quantity * CompUnitCost, Currency."Unit-Amount Rounding Precision");
                    CostTotalRpt += CostTotal;
                end;

                trigger OnPostDataItem()
                begin
                    InBOM := false;
                end;

                trigger OnPreDataItem()
                begin
                    CostTotalRpt := 0;

                    Level := 1;

                    BuildProductionBOMHistoryTmp();
                    BOMLoop.SetRange(Number, 1, TempProductionBOMLine.Count());

                    Quantity[Level] := MfgItemQtyBase;

                    InBOM := true;
                end;
            }
            dataitem(Footer; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                column(Footer_CostTotal_Control64; CostTotal)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Footer_Number; Number)
                {
                }
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                column(Total_ProdTotalCost; ProdTotalCostRpt)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Total_Item_Cost_History_NP___Average_Cost_; "Item Cost History"."Average Cost")
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Total_CostTotal; CostTotalRpt)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Total_SingleLevelMfgOvhd; SingleLevelMfgOvhd)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Total_ProdTotalCost_CostTotal; ProdTotalCostRpt + CostTotalRpt)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Total_Number; Number)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                if "Lot Size" = 0 then
                    "Lot Size" := 1;

                if not IsMfgItem() then
                    CurrReport.Skip();

                MfgItemQtyBase := HistoryCostCalcMgt.CalcQtyAdjdForBOMScrap("Lot Size", "Scrap %");

                PBOMNoList[1] := "Production BOM No.";

                SingleLevelMfgOvhd := "Average SL Mfg. Ovhd Cost";
            end;

            trigger OnPreDataItem()
            begin
                if "Item Cost History".GetFilter("Period Code") = '' then
                    Error(PeriodCodeMissingErr, "Item Cost History".FieldCaption("Period Code"));
                CostingPeriod.Get("Item Cost History".GetFilter("Period Code"));
                ItemFilter := GetFilters();
                ItemCostingSetup.Get(CostingPeriod."Item Costing Setup Code");
                if ItemCostingSetup."BOM/Routing Reference Date" =
                    ItemCostingSetup."BOM/Routing Reference Date"::"Start Period Date" then begin
                    PrevPeriodCode := ItemCostMgt.GetPrevYearPeriodCode(CostingPeriod."Period Code");
                    if PrevPeriodCode <> '' then begin
                        PrevCostingPeriod.Get(PrevPeriodCode);
                        "Calc.Date" := CalcDate('<+1D>', PrevCostingPeriod."Ending Date")
                    end else
                        "Calc.Date" := CalcDate('<-1Y+1D>', CostingPeriod."Ending Date");
                end else
                    "Calc.Date" := CostingPeriod."Ending Date";
                if ItemCostingSetup."Capacity Cost Calculation" = ItemCostingSetup."Capacity Cost Calculation"::"Entry Actual Cost" then
                    ActualQtyFlg := true;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ReqPageActualQtyFlg; ActualQtyFlg)
                    {
                        Caption = 'Actual quantity';
                        tooltip = 'Specifies to show also the actual quantities.';
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        PageNoCaptionLbl = 'Page';
        Detailed_CalculationCaptionLbl = 'Detailed Calculation';
        CostTimeCaptionLbl = 'Cost Time';
        ProdUnitCostCaptionLbl = 'Unit Cost';
        ProdTotalCostCaptionLbl = 'Total Cost';
        Total_CostCaptionLbl = 'Total Cost';
        ProdBOMLine_Level___No__CaptionLbl = 'No.';
        ProdBOMLine_Level__DescriptionCaptionLbl = 'Description';
        ProdBOMLine_Level__QuantityCaptionLbl = 'Quantity (Base)';
        CompUnitCostCaptionLbl = 'Unit Cost (calculated)';
        ItemUnitCostCaptionLbl = 'Unit Cost (from table)';
        CostTotalCaptionLbl = 'Total Cost';
        ProdBOMLine_Level__Type_CaptionLbl = 'Type';
        CompItemHistory__Base_Unit_of_Measure_CaptionLbl = 'Base Unit of Measure Code';
        Item_Cost_History_NP___Average_Cost_CaptionLbl = 'Unit Cost';
        Cost_Of_ProductionCaptionLbl = 'Cost of Production';
        Cost_Of_ComponentsCaptionLbl = 'Cost of Components';
        SingleLevelMfgOvhdCaptionLbl = 'Single-Level Mfg. Overhead Cost';
        Routing_History__Operation_NoLbl = 'Operation No.';
        Routing_History_TypeLbl = 'Type';
        Routing_History__NoLbl = 'No.';
        Routing_History_DescriptionLbl = 'Description';
        Routing_History__Setup_TimeLbl = 'Setup Time';
        Routing_History__Run_TimeLbl = 'Run Time';
    }

    trigger OnInitReport()
    begin
        MfgSetup.Get();
    end;

    trigger OnPreReport()
    begin
        Currency.InitRoundingPrecision();
    end;

    var
        MfgSetup: Record "Manufacturing Setup";
        CompItemHistory: Record "EOS Item Cost History";
        ItemCostingSetup: Record "EOS Item Costing Setup";
        TempProductionBOMLine: Record "EOS Production BOM History" temporary;
        CostingPeriod: Record "EOS Costing Period";
        PrevCostingPeriod: Record "EOS Costing Period";
        TempRoutingHistory: Record "EOS Routing History" temporary;
        Currency: Record Currency;
        //HistoryUOMMgt: Codeunit "EOS History UoM Mgt.";
        ItemCostMgt: Codeunit "EOS Item Cost Management";
        StandardCostCalc: Codeunit "EOS Standard Cost Calculation";
        HistoryCostCalcMgt: Codeunit "EOS History Calc. Cost Mgt.";
        PeriodCodeMissingErr: Label '%1 mandatory', comment = '%1 = Costing period code';
        CompUnitCost: Decimal;
        AsOfLbl: Label 'As of ';
        ItemFilter: Text;
        PBOMNoList: array[99] of Code[20];
        CompItemQtyBase: Decimal;
        Quantity: array[99] of Decimal;
        "Calc.Date": Date;
        //TotalRunTime: Decimal;
        CostTotal: Decimal;
        ProdUnitCost: Decimal;
        ProdTotalCost: Decimal;
        CostTime: Decimal;
        InBOM: Boolean;
        InRouting: Boolean;
        Level: Integer;
        SingleLevelMfgOvhd: Decimal;
        PrevPeriodCode: Code[20];
        CostTotalRpt: Decimal;
        ProdTotalCostRpt: Decimal;
        ActualQtyFlg: Boolean;
        MfgItemQtyBase: Decimal;

    local procedure BuildProductionBOMHistoryTmp()
    var
        ProdBOMLineL: Record "EOS Production BOM History";
    begin
        TempProductionBOMLine.Reset();
        TempProductionBOMLine.DeleteAll();

        ProdBOMLineL.SetRange("Period Code", "Item Cost History"."Period Code");
        ProdBOMLineL.SetRange("Item No.", "Item Cost History"."Item No.");
        ProdBOMLineL.SetRange(Type, ProdBOMLineL.Type::Item);
        if not ActualQtyFlg then begin
            ProdBOMLineL.SetRange("Production BOM No.", "Item Cost History"."Production BOM No.");
            ProdBOMLineL.SetRange("Not Standard Line", false);
        end;
        if ProdBOMLineL.FindSet() then
            repeat
                if ActualQtyFlg then
                    ProdBOMLineL.Quantity := ProdBOMLineL."Actual Quantity per";
                TempProductionBOMLine.Reset();
                TempProductionBOMLine.SetRange(Type, ProdBOMLineL.Type);
                TempProductionBOMLine.SetRange("No.", ProdBOMLineL."No.");
                if not TempProductionBOMLine.FindFirst() then begin
                    TempProductionBOMLine := ProdBOMLineL;
                    TempProductionBOMLine.Insert();
                end else begin
                    TempProductionBOMLine.Quantity += ProdBOMLineL.Quantity;
                    TempProductionBOMLine.Modify();
                end;
            until ProdBOMLineL.Next() = 0;
        TempProductionBOMLine.Reset();
    end;

    local procedure BuildRoutingHistoryTmp()
    var
        RoutingHistory2: Record "EOS Routing History";
    begin
        TempRoutingHistory.Reset();
        TempRoutingHistory.DeleteAll();

        RoutingHistory2.SetRange("Period Code", "Item Cost History"."Period Code");
        RoutingHistory2.SetRange("Item No.", "Item Cost History"."Item No.");
        if not ActualQtyFlg then begin
            RoutingHistory2.SetRange("Routing No.", "Item Cost History"."Routing No.");
            RoutingHistory2.SetRange("Not Standard Line", false);
        end;
        if RoutingHistory2.FindSet() then
            repeat
                if ActualQtyFlg then begin
                    RoutingHistory2."Setup Time" := 0;
                    RoutingHistory2."Run Time" := RoutingHistory2."Actual Run Time";
                end;
                TempRoutingHistory.Reset();
                /*
                if RoutingHistory2.Type = RoutingHistory2.Type::Resource then begin
                    TempRoutingHistory.SetRange(Type, RoutingHistory2.Type);
                    TempRoutingHistory.SetRange("No.", RoutingHistory2."No.");
                end else
                    TempRoutingHistory.SetRange("Operation No.", RoutingHistory2."Operation No.");
                if not TempRoutingHistory.FindFirst() then begin
                */
                TempRoutingHistory := RoutingHistory2;
                if TempRoutingHistory."Actual Total Time" <> 0 then
                    TempRoutingHistory."Actual Unit Cost." := Round(TempRoutingHistory."Actual Amount" / TempRoutingHistory."Actual Total Time", Currency."Unit-Amount Rounding Precision")
                else
                    TempRoutingHistory."Actual Unit Cost." := 0;
                TempRoutingHistory.Insert();
            /*
            end else begin
                TempRoutingHistory."Setup Time" += RoutingHistory2."Setup Time";
                TempRoutingHistory."Run Time" += RoutingHistory2."Run Time";
                TempRoutingHistory."Actual Total Time" += RoutingHistory2."Actual Total Time";
                TempRoutingHistory."Actual Amount" += RoutingHistory2."Actual Amount";
                if TempRoutingHistory."Actual Total Time" <> 0 then
                    TempRoutingHistory."Actual Unit Cost." := Round(TempRoutingHistory."Actual Amount" / TempRoutingHistory."Actual Total Time", Currency."Unit-Amount Rounding Precision")
                else
                    TempRoutingHistory."Actual Unit Cost." := 0;
                TempRoutingHistory.Modify();
            end;
            */
            until RoutingHistory2.Next() = 0;
        TempRoutingHistory.Reset();
    end;
}

