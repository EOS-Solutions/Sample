/// <summary>Crated from Standard report 99000768. Added Barcode part</summary>
report 50003 "EOS 070 MES ProdOrderDetCalc"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Source/LayoutReport/ProdOrderDetailedCalc.rdlc';
    ApplicationArea = Manufacturing;
    Caption = 'Prod. Order - Detailed Calc.';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Production Order"; "Production Order")
        {
            DataItemTableView = SORTING(Status, "No.");
            RequestFilterFields = Status, "No.", "Source Type", "Source No.";
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(CompanyName; COMPANYPROPERTY.DisplayName())
            {
            }
            column(ProdOrderTableCaptionFilter; TableCaption + ':' + ProdOrderFilter)
            {
            }
            column(ProdOrderFilter; ProdOrderFilter)
            {
            }
            column(No_ProdOrder; "No.")
            {
            }
            column(Desc_ProdOrder; Description)
            {
            }
            column(SourceNo_ProdOrder; "Source No.")
            {
                IncludeCaption = true;
            }
            column(Qty_ProdOrder; Quantity)
            {
                IncludeCaption = true;
            }
            column(ProdOrderDetailedCalcCaption; ProdOrderDetailedCalcCaptionLbl)
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            dataitem("Prod. Order Line"; "Prod. Order Line")
            {
                DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("No.");
                DataItemTableView = SORTING(Status, "Prod. Order No.", "Line No.") WHERE("Planning Level Code" = CONST(0));
                column(LineNo_ProdOrderLine; "Line No.")
                {
                }
                column(ItemNo; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(Item_Description; Description + "Description 2")
                {
                }
                dataitem("Prod. Order Routing Line"; "Prod. Order Routing Line")
                {
                    //DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("Prod. Order No."), "Routing Reference No." = FIELD("Line No.");
                    DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("Prod. Order No.");
                    DataItemTableView = SORTING(Status, "Prod. Order No.", "Routing Reference No.", "Routing No.", "Operation No.");
                    column(OPNo_ProdOrderRtngLine; "Operation No.")
                    {
                        IncludeCaption = false;
                    }
                    column(OPNo_ProdOrderRtngLineCaption; FieldCaption("Operation No."))
                    {
                    }
                    column(Type_ProdOrderRtngLine; Type)
                    {
                        IncludeCaption = true;
                    }
                    column(No_ProdOrderRtngLine; "No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Desc_ProdOrderRtngLine; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(InputQty_ProdOrderRtngLine; "Input Quantity")
                    {
                        IncludeCaption = true;
                    }
                    column(ExpecOPCostAmt_ProdOrderRtngLine; "Expected Operation Cost Amt.")
                    {
                        IncludeCaption = true;
                    }
                    column(TotalProductionCostCaption; TotalProductionCostCaptionLbl)
                    {
                    }
                    column(Barcode_ProdOrderRtngLine; RoutingLineBarcodeTenantMedia.Content)
                    {

                    }
                    column(ShowBarcode; EOS070MESSetup."Show Barcode in Prod. Reports")
                    {
                    }

                    trigger OnPreDataItem()
                    var
                    begin
                        SetRange("Routing Reference No.", "Prod. Order Line"."Line No.");
                        if "Production Order"."Source Type" = "Production Order"."Source Type"::Family then
                            SetRange("Routing Reference No.", 0);
                    end;


                    trigger OnAfterGetRecord()
                    var
                        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
                        EOSMESReportingManagement: Codeunit "EOS MES Reporting Management";
                    begin
                        ProdOrderRoutingLine.Init();
                        ProdOrderRoutingLine.TransferFields("Prod. Order Routing Line");
                        if ProdOrderRoutingLine."Routing Reference No." = 0 then
                            ProdOrderRoutingLine."Routing Reference No." := "Prod. Order Line"."Line No.";
                        EOSMESReportingManagement.FormatBarcodeRoutingLine(ProdOrderRoutingLine, RoutingLineBarcodeTenantMedia);
                    end;
                }
                dataitem("Prod. Order Component"; "Prod. Order Component")
                {
                    DataItemLink = Status = FIELD(Status), "Prod. Order No." = FIELD("Prod. Order No."), "Prod. Order Line No." = FIELD("Line No.");
                    DataItemTableView = SORTING(Status, "Prod. Order No.", "Prod. Order Line No.", "Line No.");
                    column(ItemNo_ProdOrderComp; "Item No.")
                    {
                        IncludeCaption = false;
                    }
                    column(ItemNo_ProdOrderCompCaption; FieldCaption("Item No."))
                    {
                    }
                    column(Desc_ProdOrderComp; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(RtngLinkCode_ProdOrderComp; "Routing Link Code")
                    {
                        IncludeCaption = true;
                    }
                    column(ExpectedQty_ProdOrderComp; "Expected Quantity")
                    {
                        IncludeCaption = true;
                    }
                    column(CostAmt_ProdOrderComp; "Cost Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(UnitCost_ProdOrderComp; "Unit Cost")
                    {
                        IncludeCaption = true;
                    }
                    column(TotalMaterialCostCaption; TotalMaterialCostCaptionLbl)
                    {
                    }
                }
                dataitem("Integer"; "Integer")
                {
                    DataItemTableView = SORTING(Number);
                    MaxIteration = 1;
                    column(ProdOrderCompOPCostAmt; "Prod. Order Component"."Cost Amount" + "Prod. Order Routing Line"."Expected Operation Cost Amt.")
                    {
                        AutoFormatType = 1;
                    }
                    column(TotalProdCostCaption; TotalProdCostCaptionLbl)
                    {
                    }
                    column(TotalMterlCostCaption; TotalMterlCostCaptionLbl)
                    {
                    }
                    column(TotalCostCaption; TotalCostCaptionLbl)
                    {
                    }
                }
            }

            trigger OnPreDataItem()
            begin
                ProdOrderFilter := GetFilters;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    var
    begin
        EOS070MESSetup.Get();
    end;

    var
        EOS070MESSetup: Record "EOS 070 MES Setup";
        RoutingLineBarcodeTenantMedia: Record "Tenant Media" temporary;
        ProdOrderFilter: Text;
        ProdOrderDetailedCalcCaptionLbl: Label 'Prod. Order - Detailed Calc.';
        CurrReportPageNoCaptionLbl: Label 'Page';
        TotalProductionCostCaptionLbl: Label 'Total Production Cost';
        TotalMaterialCostCaptionLbl: Label 'Total Material Cost';
        TotalProdCostCaptionLbl: Label 'Total Production Cost';
        TotalMterlCostCaptionLbl: Label 'Total Material Cost';
        TotalCostCaptionLbl: Label 'Total Cost';
}

