report 18123482 "EOS Cost Deviation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './source/report/Cost Deviation.rdlc';
    Caption = 'Cost Deviation (IVC)';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Inventory Posting Group", "EOS Product Family Code";
            column(COMPANYNAME; CompanyName())
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today(), 0, 4))
            {
            }
            column(TxtTitle; TxtTitle)
            {
            }
            column(Item_GETFILTERS; Item.GetFilters())
            {
            }
            column(HighLights; HighLights)
            {
            }
            column(Hide100; Hide100)
            {
            }
            column(TxtInitial; InitialText)
            {
            }
            column(TxtFinal; FinalText)
            {
            }
            column(Threshold; Threshold)
            {
                DecimalPlaces = 2 : 5;
            }
            column(Item_No_; "No.")
            {
            }
            dataitem("Item Cost History"; "EOS Item Cost History")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Period code", "Item No.") ORDER(Ascending);
                column(DeviationPerc; DeviationPerc)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(Item_Cost_History_Item_No_; "Item No.")
                {
                }
                column(Item_Cost_History_Description; Description)
                {
                }
                column(Item_Cost_History_Weighed_Average_Cost_; "Weighed Average Cost")
                {
                    DecimalPlaces = 5 : 5;
                }
                column(PrevWAC; PrevWAC)
                {
                    DecimalPlaces = 5 : 5;
                }
                column(Deviation; Deviation)
                {
                    DecimalPlaces = 5 : 5;
                }
                column(Item_Cost_History_Period_Code; "Period Code")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(PrevWAC);
                    Clear(Deviation);
                    Clear(DeviationPerc);

                    if PrevItemHistory.GET(PrevPeriodList."Period Code", "Item No.") then
                        PrevWAC := PrevItemHistory."Weighed Average Cost";

                    if PrevWAC > 0 then begin
                        Deviation := ("Weighed Average Cost" - PrevWAC);
                        DeviationPerc := ("Weighed Average Cost" - PrevWAC) / PrevWAC * 100;
                    end;

                    if (Abs(DeviationPerc) = 100) and (Hide100) then
                        CurrReport.Skip();

                    if ("Weighed Average Cost" = 0) and (PrevWAC = 0) then
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    SETRANGE("Period Code", PeriodCode);
                end;
            }

            trigger OnPreDataItem()
            begin
                PeriodList.GET(PeriodCode);
                PrevPeriodList.GET(PrevPeriodCode);

                case CostType of
                    0:
                        begin  //Standard
                            TxtTitle := StrSubstNo(Text002Lbl, Text005Lbl);
                            TxtTitle2 := Text005Lbl;
                        end;
                    1:
                        begin  //Average Cost
                            TxtTitle := StrSubstNo(Text002Lbl, Text006Lbl);
                            TxtTitle2 := Text006Lbl;
                        end;
                    2:
                        begin  //Weighed Average Cost
                            TxtTitle := StrSubstNo(Text002Lbl, Text007Lbl);
                            TxtTitle2 := Text007Lbl;
                        end;
                    3:
                        begin  //LIFO Cost
                            TxtTitle := StrSubstNo(Text002Lbl, Text008Lbl);
                            TxtTitle2 := Text008Lbl;
                        end;
                    4:
                        begin  //FIFO Cost
                            TxtTitle := StrSubstNo(Text002Lbl, Text009Lbl);
                            TxtTitle2 := Text009Lbl;
                        end;
                    5:
                        begin  //Last Cost
                            TxtTitle := StrSubstNo(Text002Lbl, Text010Lbl);
                            TxtTitle2 := Text010Lbl;
                        end;
                end;

                InitialText := StrSubstNo(Text001Lbl, TxtTitle2) + Format(PrevPeriodList."Ending Date");
                FinalText := StrSubstNo(Text001Lbl, TxtTitle2) + Format(PeriodList."Ending Date");
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
                    field(ReqPeriodCode; PeriodCode)
                    {
                        Caption = 'Analysis period';
                        TableRelation = "EOS Costing Period";
                        ApplicationArea = All;
                    }
                    field(ReqPrevPeriodCode; PrevPeriodCode)
                    {
                        Caption = 'Comparison period';
                        TableRelation = "EOS Costing Period";
                        ApplicationArea = All;
                    }
                    field(ReqCostType; CostType)
                    {
                        Caption = 'Standard Cost';
                        OptionCaption = 'Standard Cost,Average Cost,Weighed Average Cost,Continous LIFO Cost,Continous FIFO Cost,Last Cost';
                        ApplicationArea = All;
                    }
                    field(ReqThreshold; Threshold)
                    {
                        Caption = '% Threshold Deviation';
                        ApplicationArea = All;
                    }
                    field(ReqHighLights; HighLights)
                    {
                        Caption = 'Show Only Deviations';
                        ApplicationArea = All;
                    }
                    field(ReqHide100; Hide100)
                    {
                        Caption = 'Hide 100 % Deviation';
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
        ThresholdCaptionLbl = '% Threshold Deviation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .';
        HighLightsCaptionLbl = 'Show Only Deviations . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .';
        Hide100CaptionLbl = 'Hide 100% Deviat. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .';
        FiltersCaptionLbl = 'Filters . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .';
        Dev_CaptionLbl = '% Dev.';
        DescriptionCaptionLbl = 'Description';
        Item_No_CaptionLbl = 'Item No.';
        DeviationCaptionLbl = 'Deviation';
        Deviation___CaptionLbl = 'Deviation >=';
        Percent_Symbol_CaptionLbl = '%';
    }

    trigger OnInitReport()
    begin

    end;

    trigger OnPreReport()
    begin
        if (PeriodCode = '') or (PrevPeriodCode = '') then
            Error(Text003Lbl);
        if PeriodCode = PrevPeriodCode then
            Error(Text004Lbl);
    end;

    var
        PeriodList: Record "EOS Costing Period";
        PrevPeriodList: Record "EOS Costing Period";
        PrevItemHistory: Record "EOS Item Cost History";
        //ItemCostingSetup: Record "EOS Item Costing Setup";
        PrevPeriodCode: Code[20];
        PeriodCode: Code[20];
        InitialText: Text[50];
        FinalText: Text[50];
        PrevWAC: Decimal;
        Deviation: Decimal;
        Threshold: Decimal;
        DeviationPerc: Decimal;
        HighLights: Boolean;
        Hide100: Boolean;
        TxtTitle: Text[100];
        TxtTitle2: Text[100];
        CostType: Option;
        Text001Lbl: Label '%1 at ';
        Text002Lbl: Label '%1  Deviations';
        Text003Lbl: Label 'Select analysis period and comparison period';
        Text004Lbl: Label 'The analysis period cannot be equal to the comparison period.';
        Text005Lbl: Label 'Standard Cost';
        Text006Lbl: Label 'Average Cost';
        Text007Lbl: Label 'Weighed Average Cost';
        Text008Lbl: Label 'Continous LIFO Cost';
        Text009Lbl: Label 'Continous FIFO Cost';
        Text010Lbl: Label 'Last Cost';

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
        end;
    end;
}

