/// <summary>
/// Report EOS Rolled-up Cost Share Cost (ID 18123489).
/// </summary>
report 18123489 "EOS Rolled-up Cost Share Cost"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/RolledupCostSharesIVC.rdlc';
    ApplicationArea = All;
    Caption = 'Rolled-up Cost Shares (IVC)';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Item Cost History"; "EOS Item Cost History")
        {
            DataItemTableView = SORTING("Period Code", "Item No.");
            RequestFilterFields = "Period Code", "Item No.", "Inventory Posting Group";
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(ItemTableCaptionFilter; TableCaption() + ': ' + ItemFilter)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(No_Item; "Item No.")
            {
            }
            column(Description_Item; Description)
            {
            }
            column(RolledupCostSharesCapt; RolledupCostSharesCaptLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(TotalCostCaption; TotalCostCaptionLbl)
            {
            }
            column(OverheadCostCaption; OverheadCostCaptionLbl)
            {
            }
            column(CapacityCostCaption; CapacityCostCaptionLbl)
            {
            }
            column(SubcCostCaption; SubcCostCaptionLbl)
            {
            }
            column(MaterialCostCaption; MaterialCostCaptionLbl)
            {
            }
            column(BOMCompQtyBaseCapt; BOMCompQtyBaseCaptLbl)
            {
            }
            column(ProdBOMLineIndexDescCapt; ProdBOMLineIndexDescCaptLbl)
            {
            }
            column(ProdBOMLineIndexNoCapt; ProdBOMLineIndexNoCaptLbl)
            {
            }
            column(FormatLevelCapt; FormatLevelCaptLbl)
            {
            }
            column(CompItemBaseUOMCapt; CompItemBaseUOMCaptLbl)
            {
            }
            column(Item_Cost_History_NP_Period_Code; "Period Code")
            {
            }
            dataitem(BOMLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(RolledupMaterialCost_Item; ItemRUMatCost)
                {
                    AutoFormatType = 2;
                    DecimalPlaces = 2 : 5;
                }
                column(ItemRoldupCptyCst; ItemRUCapCost)
                {
                    AutoFormatType = 2;
                    DecimalPlaces = 2 : 5;
                }
                column(ItemRoldupSbcntrctCst; ItemRUSubcCost)
                {
                    AutoFormatType = 2;
                    DecimalPlaces = 2 : 5;
                }
                column(ItemRoldupMfgOvhdOvrHdCst; ItemRUMfgOvhdCost + ItemRUCapOvhdCost)
                {
                    AutoFormatType = 2;
                    DecimalPlaces = 2 : 5;
                }
                column(UnitCost_Item; ItemUnitCost)
                {
                    AutoFormatType = 2;
                    DecimalPlaces = 2 : 5;
                }
                column(CostShareItemCapt; CostShareItemCaptLbl)
                {
                }
                column(BOMLoop_Number; Number)
                {
                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    column(ProdBOMLineIndexNo; ProdBOMLine[Index]."No.")
                    {
                    }
                    column(ProdBOMLineIndexDesc; ProdBOMLine[Index].Description)
                    {
                    }
                    column(BOMCompQtyBase; BOMCompQtyBase)
                    {
                        AutoFormatType = 2;
                        DecimalPlaces = 0 : 5;
                    }
                    column(PADSTRLevelFormatLevel; PadStr('', Level, ' ') + Format(Level))
                    {
                    }
                    column(MaterialCost; MaterialCost)
                    {
                        AutoFormatType = 2;
                        DecimalPlaces = 2 : 5;
                    }
                    column(CapacityCost; CapacityCost)
                    {
                        AutoFormatType = 2;
                        DecimalPlaces = 2 : 5;
                    }
                    column(SubcCost; SubcCost)
                    {
                        AutoFormatType = 2;
                        DecimalPlaces = 2 : 5;
                    }
                    column(OverheadCost; OverheadCost)
                    {
                        AutoFormatType = 2;
                        DecimalPlaces = 2 : 5;
                    }
                    column(TotalCost; TotalCost)
                    {
                        AutoFormatType = 2;
                        DecimalPlaces = 2 : 5;
                    }
                    column(CompItemBaseUOM; CompItem."Base Unit of Measure")
                    {
                    }
                    column(ShowLine1; ProdBOMLine[Index].Type = ProdBOMLine[Index].Type::Item)
                    {
                    }
                    column(Integer_Number; Number)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        BOMCompQtyBase := Quantity[Index] * CompItemQtyBase / LotSize[Index];

                        // Cost Components:
                        // 1 = Material Direct
                        // 2 = Capacity (Only internal)
                        // 3 = Subcontracting
                        // 4 = Material Overhead
                        // 5 = Capacity Overhead
                        // 6 = Other Cost
                        TotalCost := CostCalcMgt.GetCostComponents(CompItem, CostType, SingleLevelCost, RolledUpCost);

                        MaterialCost :=
                          Round(
                            BOMCompQtyBase * (RolledUpCost[1] + RolledUpCost[6]),
                            GLSetup."Unit-Amount Rounding Precision");
                        CapacityCost :=
                          Round(
                            BOMCompQtyBase * (RolledUpCost[2]),
                            GLSetup."Unit-Amount Rounding Precision");
                        SubcCost :=
                          Round(
                            BOMCompQtyBase * (RolledUpCost[3]),
                            GLSetup."Unit-Amount Rounding Precision");
                        OverheadCost :=
                          Round(
                            BOMCompQtyBase * (RolledUpCost[4] + RolledUpCost[5]),
                            GLSetup."Unit-Amount Rounding Precision");

                        TotalCost := MaterialCost + CapacityCost + OverheadCost;
                    end;

                    trigger OnPostDataItem()
                    begin
                        Index := NextIndex;

                        if CompItem.IsMfgItem() and (CompItem."Production BOM No." <> '') then begin
                            MfgItem := CompItem;
                            Level := Level + 1;
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    while ProdBOMLine[Index].Next() = 0 do begin
                        if NoListType[Index] = NoListType[Index] ::Item then
                            Level := Level - 1;
                        Index := Index - 1;
                        if Index < 1 then
                            CurrReport.Break();
                        if NoListType[Index] = NoListType[Index] ::Item then
                            MfgItem.Get(ProdBOMLine[Index]."Period Code", NoList[Index])
                        else
                            MfgItem."Production BOM No." := NoList[Index];
                        ProdBOMLine[Index].SetRange("Period Code", MfgItem."Period Code");
                        ProdBOMLine[Index].SetRange("Item No.", MfgItem."Item No.");
                        ProdBOMLine[Index].SetRange("Production BOM No.", MfgItem."Production BOM No.");
                    end;

                    NextIndex := Index;

                    CompItemQtyBase :=
                      CostCalcMgt.CalcCompItemQtyBase(
                        ProdBOMLine[Index], MfgItemQtyBase[Index], MfgItem."Routing No.",
                        NoListType[Index] = NoListType[Index] ::Item);

                    Clear(CompItem);

                    case ProdBOMLine[Index].Type of
                        ProdBOMLine[Index].Type::Item:
                            begin
                                CompItem.Get(ProdBOMLine[Index]."Period Code", ProdBOMLine[Index]."No.");
                                if CompItem.IsMfgItem() and (CompItem."Production BOM No." <> '') then begin
                                    NextIndex := Index + 1;

                                    NoListType[NextIndex] := NoListType[NextIndex] ::Item;
                                    NoList[NextIndex] := CompItem."Item No.";

                                    Clear(ProdBOMLine[NextIndex]);
                                    ProdBOMLine[NextIndex].SetRange("Period Code", CompItem."Period Code");
                                    ProdBOMLine[NextIndex].SetRange("Item No.", CompItem."Item No.");
                                    ProdBOMLine[NextIndex].SetRange("Production BOM No.", CompItem."Production BOM No.");

                                    LotSize[NextIndex] := GetLotSize(CompItem);
                                    MfgItemQtyBase[NextIndex] := CalcMfgItemQtyBase(CompItem, ProdBOMLine[NextIndex]."Unit of Measure Code", LotSize[NextIndex]);
                                    Quantity[NextIndex] := Quantity[Index] * CompItemQtyBase / LotSize[Index];
                                end;
                            end;
                        ProdBOMLine[Index].Type::"Production BOM":
                            Error(UnpredictableSituationErr);
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    Index := 1;
                    Level := 1;

                    NoListType[Index] := NoListType[Index] ::Item;
                    NoList[Index] := "Item Cost History"."Item No.";

                    Clear(ProdBOMLine);
                    ProdBOMLine[Index].SetRange("Period Code", "Item Cost History"."Period Code");
                    ProdBOMLine[Index].SetRange("Item No.", "Item Cost History"."Item No.");
                    ProdBOMLine[Index].SetRange("Production BOM No.", "Item Cost History"."Production BOM No.");

                    LotSize[Index] := GetLotSize("Item Cost History");
                    MfgItemQtyBase[Index] := CalcMfgItemQtyBase("Item Cost History", ProdBOMLine[Index]."Unit of Measure Code", LotSize[Index]);
                    Quantity[Index] := 1;

                    MfgItem := "Item Cost History";
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if not IsMfgItem() or ("Production BOM No." = '') then
                    CurrReport.Skip();

                // Cost Components:
                // 1 = Material Direct
                // 2 = Capacity (Only internal)
                // 3 = Subcontracting
                // 4 = Material Overhead
                // 5 = Capacity Overhead
                // 6 = Other Cost
                ItemUnitCost := CostCalcMgt.GetCostComponents("Item Cost History", CostType, SingleLevelCost, RolledUpCost);
                ItemRUMatCost := RolledUpCost[1] + RolledUpCost[6];
                ItemRUCapCost := RolledUpCost[2];
                ItemRUSubcCost := RolledUpCost[3];
                ItemRUMfgOvhdCost := RolledUpCost[4];
                ItemRUCapOvhdCost := RolledUpCost[5];
            end;

            trigger OnPreDataItem()
            begin
                ItemFilter := GetFilters();
                GLSetup.Get();
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
                        Caption = 'Cost Type';
                        OptionCaption = 'Standard,Average,Weighed Average,LIFO,FIFO,Last';
                        ToolTip = 'Specifies the cost type to use.';
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

    var
        GLSetup: Record "General Ledger Setup";
        ProdBOMLine: array[99] of Record "EOS Production BOM History";
        MfgItem: Record "EOS Item Cost History";
        CompItem: Record "EOS Item Cost History";
        UOMMgt: Codeunit "EOS History UoM Mgt.";
        CostCalcMgt: Codeunit "EOS History Calc. Cost Mgt.";
        ItemFilter: Text;
        //Title: Text[250];
        //FirstTitle: Text[250];
        Level: Integer;
        Index: Integer;
        NextIndex: Integer;
        NoListType: array[99] of Option Item,"Production BOM";
        NoList: array[99] of Code[20];
        LotSize: array[99] of Decimal;
        MfgItemQtyBase: array[99] of Decimal;
        Quantity: array[99] of Decimal;
        BOMCompQtyBase: Decimal;
        MaterialCost: Decimal;
        CapacityCost: Decimal;
        SubcCost: Decimal;
        OverheadCost: Decimal;
        TotalCost: Decimal;
        CompItemQtyBase: Decimal;
        UnpredictableSituationErr: Label 'Unpredictable situation';
        ItemRUMatCost: Decimal;
        ItemRUCapCost: Decimal;
        ItemRUSubcCost: Decimal;
        ItemRUMfgOvhdCost: Decimal;
        ItemRUCapOvhdCost: Decimal;
        ItemUnitCost: Decimal;
        SingleLevelCost: array[6] of Decimal;
        RolledUpCost: array[6] of Decimal;
        CostType: Option Standard,"Average","Weighed Average",LIFO,FIFO,Last;
        RolledupCostSharesCaptLbl: Label 'Rolled-up Cost Shares';
        PageCaptionLbl: Label 'Page';
        TotalCostCaptionLbl: Label 'Total Cost';
        OverheadCostCaptionLbl: Label 'Overhead Cost';
        CapacityCostCaptionLbl: Label 'Capacity Cost';
        SubcCostCaptionLbl: Label 'Subcontracting Cost';
        MaterialCostCaptionLbl: Label 'Material Cost';
        BOMCompQtyBaseCaptLbl: Label 'Quantity (Base)';
        ProdBOMLineIndexDescCaptLbl: Label 'Description';
        ProdBOMLineIndexNoCaptLbl: Label 'No.';
        FormatLevelCaptLbl: Label 'Level';
        CompItemBaseUOMCaptLbl: Label 'UoM';
        CostShareItemCaptLbl: Label 'Cost Shares for this Item';

    local procedure GetLotSize(ItemHistory: Record "EOS Item Cost History"): Decimal
    begin
        if ItemHistory."Lot Size" <> 0 then
            exit(ItemHistory."Lot Size");

        exit(1);
    end;

    local procedure CalcMfgItemQtyBase(ItemHistory: Record "EOS Item Cost History"; BOMUomCode: Code[10]; LotSize: Decimal): Decimal
    begin
        exit(
          CostCalcMgt.CalcQtyAdjdForBOMScrap(LotSize, ItemHistory."Scrap %") /
          UOMMgt.GetQtyPerUnitOfMeasure(ItemHistory, BOMUomCode));
    end;
}
