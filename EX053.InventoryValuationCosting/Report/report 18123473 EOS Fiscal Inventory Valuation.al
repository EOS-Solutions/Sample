report 18123473 "EOS Fiscal Inventory Valuation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/Fiscal Inventory Valuation.rdlc';
    ApplicationArea = All;
    Caption = 'Fiscal Inventory Valuation (IVC)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item Cost History"; "EOS Item Cost History")
        {
            RequestFilterFields = "Period Code", "Item No.";
            column(ExecutionTime; Format(Today(), 0, 4))
            {
            }
            column(COMPANYNAME; CompanyName())
            {
            }
            column(Item_Cost_History_NP__Filters; "Item Cost History".GetFilters())
            {
            }
            column(Title; Title)
            {
            }
            column(Title2; Title2)
            {
            }
            column(Item_Cost_History_NP__Item_No__; "Item No.")
            {
            }
            column(Item_Cost_History_NP_Description; Description)
            {
            }
            column(AverageValue; AverageValue)
            {
                AutoFormatType = 1;
            }
            column(Title3; Title3)
            {
            }
            column(Item_Cost_History_NP__Net_Change_; "Net Change")
            {
            }
            column(UnitCost; UnitCost)
            {
                AutoFormatType = 2;
                DecimalPlaces = 0 : 0;
            }
            column(Item_Cost_History_NP__Item_Cost_History_NP___Base_Unit_of_Measure_; "Item Cost History"."Base Unit of Measure")
            {
            }
            column(AverageValue_Control21; AverageValue)
            {
                AutoFormatType = 1;
            }
            column(Item_Cost_History_NP__Net_Change__Control19; "Net Change")
            {
            }
            column(Item_Cost_History_NP_Period_Code; "Period Code")
            {
            }
            column(Text3; Text3)
            {
            }
            column(ExcludedBinsTxt; ExcludedBinsTxt)
            {
            }

            trigger OnAfterGetRecord()
            begin
                UnitCost := GetCost("Item Cost History");

                if "Item Cost History".GetFilter("Date Filter") = '' then
                    "Item Cost History".SetRange("Date Filter", 0D, Period."Ending Date");
                if "Item Cost History".GetFilter("Location Filter") = '' then
                    if Period."Location Filter" <> '' then
                        "Item Cost History".SetFilter("Location Filter", Period."Location Filter");

                ItemCostMgt.CalcInventory("Item Cost History");
                if not PrintZeroLines and ("Item Cost History"."Net Change" = 0) then
                    CurrReport.Skip();
                AverageValue := "Item Cost History"."Net Change" * UnitCost;
            end;

            trigger OnPreDataItem()
            begin
                Period.Get("Item Cost History".GetFilter("Period Code"));
                EndDate := Period."Ending Date";
                ExcludedBinsTxt := GetExcludedBinsText();
                Title3 := '';
                Text3 := '';

                case CostType of
                    0:
                        begin  //Standard
                            Title := StrSubstNo(InventoryValuationOfLbl, StandardCostLbl, Format(EndDate));
                            Title2 := StandardCostLbl;
                        end;
                    1:
                        begin  //Average Cost
                            Title := StrSubstNo(InventoryValuationOfLbl, AverageCostLbl, Format(EndDate));
                            Title2 := AverageCostLbl;
                        end;
                    2:
                        begin  //Weighed Average Cost
                            Title := StrSubstNo(InventoryValuationOfLbl, WeighedAverageCostLbl, Format(EndDate));
                            Title2 := WeighedAverageCostLbl;
                        end;
                    3:
                        begin  //LIFO Cost
                            Title := StrSubstNo(InventoryValuationOfLbl, ContinuousLIFOCostLbl, Format(EndDate));
                            Title2 := ContinuousLIFOCostLbl;
                        end;
                    4:
                        begin  //FIFO Cost
                            Title := StrSubstNo(InventoryValuationOfLbl, ContinuousFIFOCostLbl, Format(EndDate));
                            Title2 := ContinuousFIFOCostLbl;
                        end;
                    5:
                        begin  //Last Cost
                            Title := StrSubstNo(InventoryValuationOfLbl, LastCostLbl, Format(EndDate));
                            Title2 := LastCostLbl;
                        end;
                    6:
                        begin  //Fiscal Cost
                            Title := StrSubstNo(InventoryValuationOfLbl, FiscalCostLbl, Format(EndDate));
                            Title2 := FiscalCostLbl;
                            Title3 := UsedCostLbl;
                        end;
                end;
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
                    field(ReqPageCostType; CostType)
                    {
                        Caption = 'Standard Cost';
                        OptionCaption = 'Standard Cost,Average Cost,Weighed Average Cost,Continuous LIFO Cost,Continuous FIFO Cost,Last Cost,Fiscal Cost';

                        ApplicationArea = All;
                    }
                    field(ReqPagePrintZeroLines; PrintZeroLines)
                    {
                        Caption = 'Print items without inventory';

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
        PageCaption = 'Page';
        Filters_Caption = 'Filters:';
        Item_No_Caption = 'Item No.';
        Item_DescriptionCaption = 'Item Description';
        ValueCaption = 'Value';
        Inventory_Caption = 'Inventory ';
        Inventory_ValueCaption = 'Inventory Value';
        Total_QuantityCaption = 'Total Quantity';
        Base_Unit_MeasureCaption = 'Base Unit of Measure';
        ExcludedBins_Caption = 'Excluded Bins';
    }

    trigger OnInitReport()
    begin
        CostType := 6;
    end;

    trigger OnPreReport()
    var
    begin
    end;

    var
        Period: Record "EOS Costing Period";
        ProductFamily: Record "EOS Product Family";
        ItemCostMgt: Codeunit "EOS Item Cost Management";
        InventoryValuationOfLbl: Label 'Inventory Valuation %1 as of %2';
        StandardCostLbl: Label 'Standard Cost';
        AverageCostLbl: Label 'Average Cost';
        WeighedAverageCostLbl: Label 'Weighed Average Cost';
        EndDate: Date;
        AverageValue: Decimal;
        UnitCost: Decimal;
        Title: Text[100];
        Title2: Text[100];
        Title3: Text[100];
        Text3: Text[100];
        CostType: Option;
        PrintZeroLines: Boolean;
        ContinuousLIFOCostLbl: Label 'Continuous LIFO Cost';
        ContinuousFIFOCostLbl: Label 'Continuous FIFO Cost';
        LastCostLbl: Label 'Last Cost';
        FiscalCostLbl: Label 'Fiscal Cost';
        UsedCostLbl: Label 'Used Cost';
        ExcludedBinsTxt: Text;

    local procedure GetCost(ItemCostHistory: Record "EOS Item Cost History"): Decimal
    var
    begin
        case CostType of
            0:
                //Standard
                exit(ItemCostHistory."Standard Cost");

            1:
                //Average Cost
                exit(ItemCostHistory."Average Cost");

            2:
                //Weighed Average Cost
                exit(ItemCostHistory."Weighed Average Cost");

            3:
                //LIFO Cost
                exit(ItemCostHistory."LIFO Cost");

            4:
                //FIFO Cost
                exit(ItemCostHistory."FIFO Cost");

            5:
                //Last Cost
                exit(ItemCostHistory."Last Direct Cost");

            6:
                begin  //Fiscal Cost
                    GetProductFamily(ItemCostHistory."Product Family Code");
                    Text3 := Format(ProductFamily."Inventory Valuation");
                    exit(ItemCostMgt.GetItemFiscalCost(
                         ItemCostHistory."Item No.", EndDate, ItemCostHistory));
                end;
        end;
    end;

    local procedure GetProductFamily(ProductFamilyCode: Code[20])
    begin
        if ProductFamilyCode = '' then
            Clear(ProductFamily)
        else
            if ProductFamilyCode <> ProductFamily.Code then
                if not ProductFamily.Get(ProductFamilyCode) then
                    Clear(ProductFamily);

    end;

    local procedure GetExcludedBinsText() ExcludedBinTxt: Text
    var
        ExcludedBin: Record "EOS Excluded Bin";
    begin
        if Period."Bin Exclusion Enabled" then
            if ExcludedBin.FindSet() then
                repeat
                    ExcludedBinTxt += ',' + StrSubstNo('%1-%2', ExcludedBin."Location Code", ExcludedBin."Bin Code");
                until ExcludedBin.Next() = 0;

        ExcludedBinTxt := DelChr(ExcludedBinTxt, '<', ',');
    end;
}

