report 18123475 "EOS Inventory Cost Analysis"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/Inventory Cost Analysis.rdlc';
    ApplicationArea = All;
    Caption = 'Inventory Cost Analysis (IVC)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item History"; "EOS Item Cost History")
        {
            DataItemTableView = SORTING("Period Code", "Item Category Code") ORDER(Ascending);
            RequestFilterFields = "Period Code", "Item No.", "Item Category Code", "Location Filter", "Date Filter";
            column(FORMAT_TODAY_0_4_; Format(Today(), 0, 4))
            {
            }
            column(USERID; UserId())
            {
            }
            column(COMPANYNAME; CompanyName())
            {
            }
            column(OtherFilter; OtherFilter)
            {
            }
            column(gTxtTitle; Title0)
            {
            }
            column(InventoryFilter; InventoryFilter)
            {
            }
            column(gTxtText; Text2)
            {
            }
            column(Item_History__Item_No__; "Item No.")
            {
            }
            column(Item_History_Description; Description)
            {
            }
            column(Item_History__Net_Change_; "Net Change")
            {
            }
            column(Item_History__Average_Cost_; "Average Cost")
            {
                AutoFormatType = 2;
            }
            column(Item_History__Weighed_Average_Cost_; "Weighed Average Cost")
            {
                AutoFormatType = 2;
            }
            column(Item_History__FIFO_Cost_; "FIFO Cost")
            {
                AutoFormatType = 2;
            }
            column(Item_History__Last_Direct_Cost_; "Last Direct Cost")
            {
                AutoFormatType = 2;
            }
            column(Item_History__Item_Category_Code_; "Item Category Code")
            {
            }
            column(Item_History__Gen__Prod__Posting_Group_; "Gen. Prod. Posting Group")
            {
            }
            column(Item_History__Base_Unit_of_Measure_; "Base Unit of Measure")
            {
            }
            column(Item_History__Standard_Cost_; "Standard Cost")
            {
                AutoFormatType = 2;
            }
            /*
            column(gDecLIFOAScatti; LIFOAScatti)
            {
                AutoFormatType = 2;
            }
            */
            column(Item_History__LIFO_Cost_; "LIFO Cost")
            {
                AutoFormatType = 2;
            }
            column(WACMark; WACMark)
            {
            }
            column(FIFOMark; FIFOMark)
            {
            }
            column(LastCostMark; LastCostMark)
            {
            }
            column(LIFOMark; LIFOMark)
            {
            }
            column(AverageMark; AverageMark)
            {
            }
            column(gDecValoreMedio; AmtAverage)
            {
                AutoFormatType = 1;
            }
            column(gDecValoreMedioPonderato; AmtWAC)
            {
                AutoFormatType = 1;
            }
            column(gDecValoreFIFO; AmtFIFO)
            {
                AutoFormatType = 1;
            }
            column(gDecValoreUltimoCostoDiretto; AmtLastDirectCost)
            {
                AutoFormatType = 1;
            }
            column(gTxtProductGroup; ProductGroupText)
            {
            }
            column(gDecValoreCostoStandard; AmtStandardCost)
            {
                AutoFormatType = 1;
            }
            column(gDecValoreLIFOContinuo; AmtLIFOContinuous)
            {
                AutoFormatType = 1;
            }
            /*
            column(gDecValoreLIFOAScatti; ValoreLIFOAScatti)
            {
                AutoFormatType = 1;
            }
            */
            column(gDecGiacenza; InventoryQty)
            {
            }
            column(gDecValoreMedio_Control21; AmtAverage)
            {
                AutoFormatType = 1;
            }
            column(Text011; TotalEvaluationInventoryLbl)
            {
            }
            column(gDecValoreCostoStandard_Control1000000041; AmtStandardCost)
            {
                AutoFormatType = 1;
            }
            column(gDecValoreUltimoCostoDiretto_Control1000000007; AmtLastDirectCost)
            {
                AutoFormatType = 1;
            }
            /*
            column(gDecValoreLIFOAScatti_Control1000000024; ValoreLIFOAScatti)
            {
                AutoFormatType = 1;
            }
            */
            column(gDecValoreLIFOContinuo_Control1000000025; AmtLIFOContinuous)
            {
                AutoFormatType = 1;
            }
            column(gDecValoreFIFO_Control1000000026; AmtFIFO)
            {
                AutoFormatType = 1;
            }
            column(gDecValoreMedioPonderato_Control1000000027; AmtWAC)
            {
                AutoFormatType = 1;
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Filters_Caption; Filters_CaptionLbl)
            {
            }
            column(Item_No_Caption; Item_No_CaptionLbl)
            {
            }
            column(Item_DescriptionCaption; Item_DescriptionCaptionLbl)
            {
            }
            column(Inventory_Caption; Inventory_CaptionLbl)
            {
            }
            column(Item_History__Average_Cost_Caption; FieldCaption("Average Cost"))
            {
            }
            column(Weig__Average_CostCaption; Weig__Average_CostCaptionLbl)
            {
            }
            column(Item_History__FIFO_Cost_Caption; FieldCaption("FIFO Cost"))
            {
            }
            column(Item_History__Last_Direct_Cost_Caption; FieldCaption("Last Direct Cost"))
            {
            }
            column(Item_History__Item_Category_Code_Caption; FieldCaption("Item Category Code"))
            {
            }
            column(Gen__Prod__Posting_GroupCaption; Gen__Prod__Posting_GroupCaptionLbl)
            {
            }
            column(UMCaption; UMCaptionLbl)
            {
            }
            column(Item_History__Standard_Cost_Caption; FieldCaption("Standard Cost"))
            {
            }
            column(LIFO_ContinuoCaption; LIFO_ContinuoCaptionLbl)
            {
            }
            /*
            column(LIFO_A_ScattiCaption; LIFO_A_ScattiCaptionLbl)
            {
            }
            */
            column(Item_History_Period_Code; "Period Code")
            {
            }
            column(CurrReportLanguage; LanguageLbl)
            {
            }
            column(Print_Only_Totals; OnlyTotals)
            {
            }
            column(Item_History_Product_Group_Code; ProductGroupText)
            {
            }

            trigger OnAfterGetRecord()
            var

                ItemCategory: Record "Item Category";
                ParentItemCategory: Record "Item Category";
                AverageCostSave: Decimal;
            begin
                if "Item History".GetFilter("Date Filter") = '' then
                    "Item History".SetRange("Date Filter", 0D, PeriodList."Ending Date");
                if "Item History".GetFilter("Location Filter") = '' then
                    if PeriodList."Location Filter" <> '' then
                        "Item History".SetFilter("Location Filter", PeriodList."Location Filter");
                ItemCostMgt.CalcInventory("Item History");

                if not PrintZeroLines and ("Item History"."Net Change" = 0) then
                    CurrReport.Skip();

                if ((CurrentProductGroupCode = '') and (ItemCategory.Get("Item Category Code"))) then
                    CurrentProductGroupCode := ItemCategory."Parent Category";

                AverageCostSave := "Average Cost";
                if OnlyForced and not CostForcedExist("Item History") then
                    CurrReport.Skip();
                /*
                gDecLIFOAScatti := gCduItemCostMgt.CalcItemLIFOCost("Period Code", "Item No.", AverageCostSave,
                          "End Period Inventory", gRecPeriodList."Ending Date");
                */
                if OnlyForced then
                    ClearNotForcedCost("Item History");

                if "Force Average Cost" <> "Force Average Cost"::" " then
                    AverageMark := '*'
                else
                    AverageMark := '';
                if "Force Weighed Average Cost" <> "Force Weighed Average Cost"::" " then
                    WACMark := '*'
                else
                    WACMark := '';
                if "Force LIFO Cost" <> "Force LIFO Cost"::" " then
                    LIFOMark := '*'
                else
                    LIFOMark := '';
                if "Force FIFO Cost" <> "Force FIFO Cost"::" " then
                    FIFOMark := '*'
                else
                    FIFOMark := '';
                if "Force Last Direct Cost" <> "Force Last Direct Cost"::" " then
                    LastCostMark := '*'
                else
                    LastCostMark := '';

                if ItemCategory.Get("Item Category Code") then begin
                    if not ParentItemCategory.Get(ItemCategory."Parent Category") then
                        ParentItemCategory.Init();
                end else
                    ItemCategory.Init();

                ProductGroupText := GroupTotalLbl + ' ' + ParentItemCategory.Code + ' ' + ParentItemCategory.Description;

                AmtAverage := ("Average Cost" * "Net Change");
                AmtWAC := ("Weighed Average Cost" * "Net Change");
                AmtFIFO := ("FIFO Cost" * "Net Change");
                AmtLastDirectCost := ("Last Direct Cost" * "Net Change");
                AmtStandardCost := ("Standard Cost" * "Net Change");
                AmtLIFOContinuous := ("LIFO Cost" * "Net Change");
                //ValoreLIFOAScatti := LIFOAScatti;

                /*
                InventoryGroup += "Item History"."Net Change";
                AmtAverageGroup += "Average Cost";
                AmtAWCGroup += "Weighed Average Cost";
                AmtFIFOGroup += "FIFO Cost";
                AmtLastDirectCostGroup += "Last Direct Cost";
                AmtStandardCostGroup += "Standard Cost";
                ValoreLIFOContinuoGroup += "LIFO Cost";
                */
                //ValoreLIFOAScattiGroup += LIFOAScatti;

                if ExportToExcel then
                    MakeExcelBody();
            end;

            trigger OnPostDataItem()
            var
                ItemCategory: Record "Item Category";
            begin
                if ItemCategory.Get("Item Category Code") then
                    CurrentProductGroupCode := ItemCategory."Parent Category";
                //if ExportToExcel then
                //    WriteGroupTotal();
                //if ExportToExcel then
                //    WriteTotal();
            end;

            trigger OnPreDataItem()
            var
                InventoryFilterCaption: Text;
            begin
                PeriodList.Get("Item History".GetFilter("Period Code"));
                ItemCostingSetup.Get(PeriodList."Item Costing Setup Code");
                EndDate := PeriodList."Ending Date";

                Clear(Text1);
                Clear(Title1);
                OtherFilter := "Item History".GetFilters();
                InventoryFilter := "Item History".GetFilter("Location Filter");
                InventoryFilterCaption := "Item History".FieldCaption("Location Filter");
                if InventoryFilter <> '' then
                    if StrPos(OtherFilter, InventoryFilterCaption) > 1 then
                        OtherFilter := CopyStr(OtherFilter, 1, StrPos(OtherFilter, InventoryFilterCaption) - 3) +
                                       CopyStr(OtherFilter, StrPos(OtherFilter, InventoryFilterCaption) + StrLen(InventoryFilter) +
                                           StrLen(InventoryFilterCaption) + 3)
                    else
                        OtherFilter := CopyStr(OtherFilter, StrPos(OtherFilter, InventoryFilter) + StrLen(InventoryFilter) +
                                           StrLen(InventoryFilterCaption) + 3);

                OtherFilter := DelChr(OtherFilter, '<>', ' ');
                InventoryFilter := InventoryFilterCaption + ': ' + DelChr(InventoryFilter, '<>', ' ');
                Title0 := InventoryMultiCostEvaluationLbl;
                Title1 := ProductFamily.FieldCaption("Inventory Valuation");
                Title2 := StandardCostLbl;

                if ExportToExcel then
                    MakeExcelHeader();
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
                    field(ReqPagePrintZeroLines; PrintZeroLines)
                    {
                        Caption = 'Print items without inventory';

                        ApplicationArea = All;
                    }
                    field(ReqPagePrintExcel; ExportToExcel)
                    {
                        Caption = 'Export to Excel';

                        ApplicationArea = All;
                    }
                    field(ReqPageOnlyTotals; OnlyTotals)
                    {
                        Caption = 'Only Totals';

                        ApplicationArea = All;
                    }
                    field(ReqPageOnlyForced; OnlyForced)
                    {
                        Caption = 'Only Forced';

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
    }

    trigger OnPostReport()
    begin
        if ExportToExcel then begin
            ExcelBuf.CreateNewBook(ExcelSheetNameLbl);
            ExcelBuf.WriteSheet(InventoryMultiCostEvaluationLbl, CompanyName(), UserId());
            ExcelBuf.CloseBook();
            ExcelBuf.OpenExcel();
        end;
    end;

    var
        ItemCostingSetup: Record "EOS Item Costing Setup";
        ProductFamily: Record "EOS Product Family";
        PeriodList: Record "EOS Costing Period";
        ExcelBuf: Record "Excel Buffer" temporary;
        ItemCostMgt: Codeunit "EOS Item Cost Management";
        EndDate: Date;
        Title0: Text;
        Title1: Text;
        Title2: Text;
        Text1: Text;
        PrintZeroLines: Boolean;
        AmtAverage: Decimal;
        AmtWAC: Decimal;
        AmtFIFO: Decimal;
        AmtLastDirectCost: Decimal;
        AmtStandardCost: Decimal;
        AmtLIFOContinuous: Decimal;
        //LIFOAScatti: Decimal;
        //ValoreLIFOAScatti: Decimal;
        InventoryQty: Decimal;
        Text2: Text[100];
        ProductGroupText: Text;
        OnlyForced: Boolean;
        OnlyTotals: Boolean;
        InventoryFilter: Text;
        OtherFilter: Text;
        ExportToExcel: Boolean;
        //Window: Dialog;
        //TotCount: Integer;
        //TotCounter: Integer;
        //RefDate: Date;
        RowNo: Integer;
        ColumnNo: Integer;
        StandardCostLbl: Label 'Standard Cost';
        TotalEvaluationInventoryLbl: Label 'Total Evaluation Inventory';
        InventoryMultiCostEvaluationLbl: Label 'Inventory MultiCost Evaluation';
        //ProgressLbl: Label 'No. #2################## @3@@@@@@@@@@@@@';
        //SalesPriceLbl: Label 'Base Agent Sales Price Calc...';
        GroupTotalLbl: Label 'Group Total';
        //FormulaText: Text[250];
        ContinuousLIFOLbl: Label 'Continuous LIFO';
        //IntermittentLIFOLbl: Label 'Intermittent LIFO';
        CurrentProductGroupCode: Code[20];
        AverageMark: Text[10];
        WACMark: Text[10];
        LastCostMark: Text[10];
        LIFOMark: Text[10];
        FIFOMark: Text[10];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Filters_CaptionLbl: Label 'Filters:';
        Item_No_CaptionLbl: Label 'Item No.';
        Item_DescriptionCaptionLbl: Label 'Item Description';
        Inventory_CaptionLbl: Label 'Net Change';
        Weig__Average_CostCaptionLbl: Label 'Weighed Average Cost';
        Gen__Prod__Posting_GroupCaptionLbl: Label 'Gen. Prod. Posting Group';
        UMCaptionLbl: Label 'UM';
        LIFO_ContinuoCaptionLbl: Label 'Continuous LIFO';
        //LIFO_A_ScattiCaptionLbl: Label 'Intermittent LIFO';
        LanguageLbl: Label 'en-US';
        ExcelSheetNameLbl: Label 'Inventory Cost Analysis';
    //AmtAverageGroup: Decimal;
    //AmtAWCGroup: Decimal;
    //AmtFIFOGroup: Decimal;
    //AmtLastDirectCostGroup: Decimal;
    //AmtStandardCostGroup: Decimal;
    //ValoreLIFOContinuoGroup: Decimal;
    //ValoreLIFOAScattiGroup: Decimal;
    //InventoryGroup: Decimal;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean; NumberFormat: Text[30]; CellType: Option)
    begin
        ExcelBuf.INIT;
        ExcelBuf.VALIDATE("Row No.", RowNo);
        ExcelBuf.VALIDATE("Column No.", ColumnNo);
        ExcelBuf."Cell Value as Text" := CellValue;
        ExcelBuf.Formula := '';
        ExcelBuf.Bold := Bold;
        ExcelBuf.Underline := UnderLine;
        ExcelBuf.NumberFormat := NumberFormat;
        ExcelBuf."Cell Type" := CellType;
        ExcelBuf.INSERT;
    end;

    local procedure MakeExcelHeader()
    //var
    begin
        //FormulaText := '';
        RowNo := 1;
        ColumnNo := 1;
        /*
        EnterCell(RowNo, ColumnNo, InventoryMultiCostEvaluationLbl, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(RefDate), true, false, false, '', ExcelBuf."Cell Type"::Date);
        RowNo += 1;
        ColumnNo := 1;
        EnterCell(RowNo, ColumnNo, CopyStr(OtherFilter, 1, 250), true, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        RowNo += 1;
        ColumnNo := 1;
        EnterCell(RowNo, ColumnNo, CopyStr(InventoryFilter, 1, 250), true, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        ColumnNo := 1;
        RowNo += 1;
        */
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Item No."), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History".Description), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Item Category Code"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Gen. Prod. Posting Group"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Base Unit of Measure"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Net Change"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Standard Cost"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Average Cost"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Weighed Average Cost"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."FIFO Cost"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, ContinuousLIFOLbl, true, false, true, '', ExcelBuf."Cell Type"::Text);
        /*
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, IntermittentLIFOLbl, true, false, true, '', ExcelBuf."Cell Type"::Text);
        */
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".FieldCaption("Item History"."Last Direct Cost"), true, false, true, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
    end;

    local procedure MakeExcelBody()
    //var
    begin
        //FormulaText := '';
        ColumnNo := 1;
        RowNo := RowNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History"."Item No.", false, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History".Description, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History"."Item Category Code", false, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History"."Gen. Prod. Posting Group", false, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, "Item History"."Base Unit of Measure", false, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format("Item History"."Net Change", 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format("Item History"."Standard Cost", 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format("Item History"."Average Cost", 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format("Item History"."Weighed Average Cost", 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format("Item History"."FIFO Cost", 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format("Item History"."LIFO Cost", 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        /*
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(LIFOAScatti, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        */
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format("Item History"."Last Direct Cost", 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
    end;

    /*
    local procedure WriteTotal()
    //var
    begin
        //FormulaText := '';
        ColumnNo := 3;
        RowNo := RowNo + 2;
        EnterCell(RowNo, ColumnNo, TotalEvaluationInventoryLbl, true, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 3;
        EnterCell(RowNo, ColumnNo, Format(InventoryQty, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtStandardCost, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtAverage, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtWAC, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtFIFO, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtLIFOContinuous, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        //ColumnNo := ColumnNo + 1;
        //EnterCell(RowNo, ColumnNo, Format(ValoreLIFOAScatti, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtLastDirectCost, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
    end;
    */

    /*
    local procedure WriteGroupTotal()
    begin
        //FormulaText := '';
        ColumnNo := 3;
        RowNo := RowNo + 2;
        EnterCell(RowNo, ColumnNo, CurrentProductGroupCode, false, false, false, '', ExcelBuf."Cell Type"::Text);
        ColumnNo := ColumnNo + 4;
        EnterCell(RowNo, ColumnNo, Format(AmtStandardCostGroup, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtAverageGroup, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtAWCGroup, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtFIFOGroup, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(ValoreLIFOContinuoGroup, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        //ColumnNo := ColumnNo + 1;
        //EnterCell(RowNo, ColumnNo, Format(ValoreLIFOAScattiGroup, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
        EnterCell(RowNo, ColumnNo, Format(AmtLastDirectCostGroup, 0, 0), false, false, false, '', ExcelBuf."Cell Type"::Number);
        ColumnNo := ColumnNo + 1;
    end;
    */

    /*
    procedure WriteGroupHeader(Text: Text[100])
    begin
        FormulaText := '';
        RowNo := RowNo + 2;
        ColumnNo := 3;

        EnterCell(RowNo, ColumnNo, Text, true, false, false, true, FormulaText);
    end;
*/
    local procedure CostForcedExist(ItemHistory: Record "EOS Item Cost History"): Boolean
    begin
        if ItemHistory."Force Weighed Average Cost" <> ItemHistory."Force Weighed Average Cost"::" " then
            exit(true);
        if ItemHistory."Force Average Cost" <> ItemHistory."Force Average Cost"::" " then
            exit(true);
        if ItemHistory."Force FIFO Cost" <> ItemHistory."Force FIFO Cost"::" " then
            exit(true);
        if ItemHistory."Force LIFO Cost" <> ItemHistory."Force LIFO Cost"::" " then
            exit(true);
        if ItemHistory."Force Last Direct Cost" <> ItemHistory."Force Last Direct Cost"::" " then
            exit(true);
    end;

    local procedure ClearNotForcedCost(var ItemHistory: Record "EOS Item Cost History")
    begin
        if ItemHistory."Force Weighed Average Cost" = ItemHistory."Force Weighed Average Cost"::" " then
            ItemHistory."Weighed Average Cost" := 0;
        if ItemHistory."Force Average Cost" = ItemHistory."Force Average Cost"::" " then
            ItemHistory."Average Cost" := 0;
        if ItemHistory."Force FIFO Cost" = ItemHistory."Force FIFO Cost"::" " then
            ItemHistory."FIFO Cost" := 0;
        if ItemHistory."Force LIFO Cost" = ItemHistory."Force LIFO Cost"::" " then
            ItemHistory."LIFO Cost" := 0;
        if ItemHistory."Force Last Direct Cost" = ItemHistory."Force Last Direct Cost"::" " then
            ItemHistory."Last Direct Cost" := 0;
        ItemHistory."Standard Cost" := 0;
        //LIFOAScatti := 0;
    end;
}

