report 50350 "EOI Expense Print"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.\Source\Report\ExpensePrint.rdlc';
    ApplicationArea = All;
    Caption = 'Resource - Expenses';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Resource; Resource)
        {
            DataItemTableView = sorting("No.");
            column(ActNo_Resource; "No.")
            {
            }
            column(ActName_Resource; ResHeader + ' ' + Name)
            {
            }
            column(MonthKm; MonthKmAct)
            {
            }
            column(KmCaption; KmCaption + Format(MonthKm))
            {
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(TodayFormatted; Format(Today, 0, 4))
                {
                }
                column(CompanyName; CompanyName)
                {
                }
                column(ResTableCaptResFilter; Resource.TableCaption + ': ' + ResFilter)
                {
                }
                column(ResFilter; ResFilter)
                {
                }
                column(ResLedEntrytableCaptFilt; "Time Sheet Detail".TableCaption + ': ' + ResLedgEntryFilter)
                {
                }
                column(ResLedgerEntryFilter; ResLedgEntryFilter)
                {
                }
                column(ResCostBreakdownCaption; ResCostBreakdownCaptionLbl)
                {
                }
                column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
                {
                }
                column(TextFooter1; StrSubstNo(TextFooter1, CompanyName))
                {
                }
                column(TextFooter3; StrSubstNo(TextFooter3, WorkDate()))
                {
                }
                column(TextFooter2; TextFooter2)
                {
                }
                column(Titolo2; StrSubstNo(Titolo2, DateFilter))
                {
                }
                dataitem(CC; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = filter(1 .. 2));
                    column(CC_Number; CC.Number)
                    {
                    }
                    column(CreditCard; CreditCard)
                    {
                    }
                    column(gen_TotalEXPCaption; TotalEXPCaptionLbl)
                    {
                    }
                    dataitem("Time Sheet Detail"; "Time Sheet Detail")
                    {
                        DataItemLink = "Resource No." = field("No.");
                        DataItemLinkReference = Resource;
                        DataItemTableView = sorting("Resource No.", Date) where("EOS095 Work Type" = filter(Expenses | Distance), Status = filter(<> Rejected), "EOS095 Credit Card" = const(false), "EOS095 Invoicing Type" = filter(<> "Fixed Price"));
                        column(Name_Resource; Resource.Name)
                        {
                        }
                        column(No1_Resource; Resource."No.")
                        {
                        }
                        column(Desc_ResLedgEntry; "EOS095 Description")
                        {
                            IncludeCaption = true;
                        }
                        column(WorkTypeCode_ResLedgEntry; "EOS095 Work Type Code")
                        {
                            IncludeCaption = true;
                        }
                        column(Qty_ResLedgEntry; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(DirectUnitCost_ResLedgEntry; "EOS095 Unit Cost (LCY)")
                        {
                            IncludeCaption = true;
                        }
                        column(TotalCost_ResLedgEntry; "EOS095 Cost Amount (LCY)")
                        {
                            IncludeCaption = true;
                        }
                        column(Chargeable_ResLedgEntry; "EOS095 Chargeable")
                        {
                        }
                        column(TotalDirectCostCaption; TotalDirectCostCaptionLbl)
                        {
                        }
                        column(TotalCaption; TotalCaptionLbl)
                        {
                        }
                        column(TotalKMCaption; TotalKMCaptionLbl)
                        {
                        }
                        column(TotalEXPCaption; TotalEXPCaptionLbl)
                        {
                        }
                        column(JobNo; "Job No.")
                        {
                            IncludeCaption = true;
                        }
                        column(TimeSheetNo; "Time Sheet No.")
                        {
                            IncludeCaption = true;
                        }
                        column(TotalCost_KM; TotalCost_KM)
                        {
                        }
                        column(TotalCost_EXP; TotalCost_EXP)
                        {
                        }
                        column(Date; Date)
                        {
                            IncludeCaption = true;
                        }
                        column(WorkTypeCode; "EOS095 Work Type Code")
                        {
                            IncludeCaption = true;
                        }
                        column(DestinationCity; DestinationCity)
                        {
                        }
                        column(KM; KM)
                        {
                        }
                        column(TotalKM2CaptionLbl; TotalKM2CaptionLbl)
                        {
                        }
                        column(Status; Status)
                        {
                            IncludeCaption = true;
                        }
                        column(ResourceExp; ResourceExp)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if lRecTravelAgreement.Get("EOS095 Travel Agr. Entry No.") then
                                if lRecTravelAgreement."Invoicing Type" = lRecTravelAgreement."Invoicing Type"::Forfait then
                                    CurrReport.Skip();

                            if "EOS095 Work Type" = "EOS095 Work Type"::Expenses then begin
                                TotalCost_KM := 0;
                                TotalCost_EXP := "EOS095 Cost Amount (LCY)";
                            end else begin
                                TotalCost_KM := "EOS095 Cost Amount (LCY)";
                                TotalCost_EXP := 0;
                            end;

                            //Start TDAG01068/dc
                            DestinationCity := '';
                            KM := 0;
                            TotalCost_KMValue := 0;

                            if not Job.Get("Job No.") then
                                Job.Init();

                            if not JobType.Get(Job."KVSPSAJob Type") then
                                JobType.Init();

                            if not JobType."Internal Job" then begin
                                if not Customer.Get(Job."Sell-to Customer No.") then
                                    Customer.Init();
                                DestinationCity := Customer.City;
                                //Start TDAG26074/dc
                                //IF "Ship-to Code" <> '' THEN
                                //  IF ShiptoAddress.GET("Customer No.","Ship-to Code") THEN
                                //    DestinationCity := ShiptoAddress.City;
                                if TimeSheetLine.Get("Time Sheet No.", "EOS095 Applies-to Line No.") then
                                    if TimeSheetLine."EOS095 Ship-to Code" <> '' then
                                        if ShiptoAddress.Get(TimeSheetLine."EOS095 Customer No.", TimeSheetLine."EOS095 Ship-to Code") then
                                            DestinationCity := ShiptoAddress.City;
                                //Stop TDAG26074/dc
                            end;

                            if "EOS095 Work Type" = "EOS095 Work Type"::Distance then begin
                                //Start TDAG03012/dc
                                //KM := "Cost Amount (LCY)" / 0.4;
                                JobsSetup.Get();
                                JobsSetup.TestField("EOI KM Cost");
                                KM := "EOS095 Cost Amount (LCY)" / JobsSetup."EOI KM Cost";
                                //Stop TDAG03012/dc
                                TotalCost_KMValue := KM;
                            end;
                            //Stop TDAG01068/dc

                            //Start TDAG21920/dc
                            ResourceExp := '';
                            TimeSheetExpAddResource.Reset();
                            TimeSheetExpAddResource.SetRange("Time Sheet No.", "Time Sheet No.");
                            TimeSheetExpAddResource.SetRange("Time Sheet Line No.", "Time Sheet Line No.");
                            if TimeSheetExpAddResource.FindFirst() then
                                repeat
                                    if ResourceExp = '' then
                                        ResourceExp := TimeSheetExpAddResource."Resource No."
                                    else
                                        ResourceExp += '|' + TimeSheetExpAddResource."Resource No.";
                                until TimeSheetExpAddResource.Next() = 0;

                            if ResourceExp <> '' then
                                ResourceExp := Text012 + ResourceExp;
                            //Stop TDAG21920/dc
                        end;

                        trigger OnPreDataItem()
                        begin
                            //Start TDAG03919/dc
                            if CC.Number <> 1 then
                                CurrReport.Break();
                            //Stop TDAG03919/dc

                            if DateFilter <> '' then
                                SetFilter(Date, DateFilter);

                            //Start TDAG01068/dc
                            //CurrReport.CREATETOTALS(Quantity,"Cost Amount (LCY)",TotalCost_KM,TotalCost_EXP);
                            CurrReport.CreateTotals(Quantity, "EOS095 Cost Amount (LCY)", TotalCost_KM, TotalCost_EXP, TotalCost_KMValue);
                            //Start TDAG01068/dc
                        end;
                    }
                    dataitem("Time Sheet Detail Archive"; "Time Sheet Detail Archive")
                    {
                        DataItemLink = "Resource No." = field("No.");
                        DataItemLinkReference = Resource;
                        DataItemTableView = sorting("Resource No.", Date) where("EOS095 Work Type" = filter(Expenses | Distance), Status = filter(<> Rejected), "EOS095 Credit Card" = const(false), "EOS095 Invoicing Type" = filter(<> "Fixed Price"));
                        column(Name_Resource2; Resource.Name)
                        {
                        }
                        column(No1_Resource2; Resource."No.")
                        {
                        }
                        column(Desc_ResLedgEntry2; "EOS095 Description")
                        {
                            IncludeCaption = true;
                        }
                        column(WorkTypeCode_ResLedgEntry2; "EOS095 Work Type Code")
                        {
                            IncludeCaption = true;
                        }
                        column(Qty_ResLedgEntry2; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(DirectUnitCost_ResLedgEntry2; "EOS095 Unit Cost (LCY)")
                        {
                            IncludeCaption = true;
                        }
                        column(TotalCost_ResLedgEntry2; "EOS095 Cost Amount (LCY)")
                        {
                            IncludeCaption = true;
                        }
                        column(Chargeable_ResLedgEntry2; "EOS095 Chargeable")
                        {
                        }
                        column(TotalDirectCostCaption2; TotalDirectCostCaptionLbl)
                        {
                        }
                        column(TotalCaption2; TotalCaptionLbl)
                        {
                        }
                        column(TotalKMCaption2; TotalKMCaptionLbl)
                        {
                        }
                        column(TotalEXPCaption2; TotalEXPCaptionLbl)
                        {
                        }
                        column(JobNo2; "Job No.")
                        {
                            IncludeCaption = true;
                        }
                        column(TimeSheetNo2; "Time Sheet No.")
                        {
                            IncludeCaption = true;
                        }
                        column(TotalCost_KM2; TotalCost_KM)
                        {
                        }
                        column(TotalCost_EXP2; TotalCost_EXP)
                        {
                        }
                        column(Date2; Date)
                        {
                            IncludeCaption = true;
                        }
                        column(WorkTypeCode2; "EOS095 Work Type Code")
                        {
                            IncludeCaption = true;
                        }
                        column(DestinationCity2; DestinationCity)
                        {
                        }
                        column(KM2; KM)
                        {
                        }
                        column(TotalKM2CaptionLbl2; TotalKM2CaptionLbl)
                        {
                        }
                        column(Status2; Status)
                        {
                            IncludeCaption = true;
                        }
                        column(ResourceExpArc; ResourceExpArc)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if lRecTravelAgreement.Get("EOS095 Travel Agr. Entry No.") then
                                if lRecTravelAgreement."Invoicing Type" = lRecTravelAgreement."Invoicing Type"::Forfait then
                                    CurrReport.Skip();

                            if "EOS095 Work Type" = "EOS095 Work Type"::Expenses then begin
                                TotalCost_KM := 0;
                                TotalCost_EXP := "EOS095 Cost Amount (LCY)";
                            end else begin
                                TotalCost_KM := "EOS095 Cost Amount (LCY)";
                                TotalCost_EXP := 0;
                            end;

                            //Start TDAG01068/dc
                            DestinationCity := '';
                            KM := 0;
                            TotalCost_KMValue := 0;

                            if not Job.Get("Job No.") then
                                Job.Init();

                            if not JobType.Get(Job."KVSPSAJob Type") then
                                JobType.Init();

                            if not JobType."Internal Job" then begin
                                if not Customer.Get(Job."Sell-to Customer No.") then
                                    Customer.Init();
                                DestinationCity := Customer.City;
                                if "EOS095 Ship-to Code" <> '' then
                                    if ShiptoAddress.Get("EOS095 Customer No.", "EOS095 Ship-to Code") then
                                        DestinationCity := ShiptoAddress.City;
                            end;

                            if "EOS095 Work Type" = "EOS095 Work Type"::Distance then begin
                                //Start TDAG03012/dc
                                //KM := "Cost Amount (LCY)" / 0.4;
                                JobsSetup.Get();
                                JobsSetup.TestField("EOI KM Cost");
                                KM := "EOS095 Cost Amount (LCY)" / JobsSetup."EOI KM Cost";
                                //Stop TDAG03012/dc
                                TotalCost_KMValue := KM;
                            end;
                            //Stop TDAG01068/dc

                            //Start TDAG21920/dc
                            ResourceExpArc := '';
                            TimeSheetExpAddResource.Reset();
                            TimeSheetExpAddResource.SetRange("Time Sheet No.", "Time Sheet No.");
                            TimeSheetExpAddResource.SetRange("Time Sheet Line No.", "Time Sheet Line No.");
                            if TimeSheetExpAddResource.FindFirst() then
                                repeat
                                    if ResourceExpArc = '' then
                                        ResourceExpArc := TimeSheetExpAddResource."Resource No."
                                    else
                                        ResourceExpArc += '|' + TimeSheetExpAddResource."Resource No.";
                                until TimeSheetExpAddResource.Next() = 0;

                            if ResourceExpArc <> '' then
                                ResourceExpArc := Text012 + ResourceExpArc;
                            //Stop TDAG21920/dc
                        end;

                        trigger OnPreDataItem()
                        begin
                            //Start TDAG03919/dc
                            if CC.Number <> 1 then
                                CurrReport.Break();
                            //Stop TDAG03919/dc

                            if DateFilter <> '' then
                                SetFilter(Date, DateFilter);

                            //Start TDAG01068/dc
                            //CurrReport.CREATETOTALS(Quantity,"Cost Amount (LCY)",TotalCost_KM,TotalCost_EXP);
                            CurrReport.CreateTotals(Quantity, "EOS095 Cost Amount (LCY)", TotalCost_KM, TotalCost_EXP, TotalCost_KMValue);
                            //Start TDAG01068/dc
                        end;
                    }
                    dataitem(TimeSheetDetailCreditCard; "Time Sheet Detail")
                    {
                        DataItemLink = "Resource No." = field("No.");
                        DataItemLinkReference = Resource;
                        DataItemTableView = sorting("Resource No.", Date) where("EOS095 Work Type" = filter(Expenses | Distance), Status = filter(<> Rejected), "EOS095 Credit Card" = const(true), "EOS095 Invoicing Type" = filter(<> "Fixed Price"));
                        column(CC_Name_Resource; Resource.Name)
                        {
                        }
                        column(CC_No1_Resource; Resource."No.")
                        {
                        }
                        column(CC_Desc_ResLedgEntry; "EOS095 Description")
                        {
                            IncludeCaption = true;
                        }
                        column(CC_WorkTypeCode_ResLedgEntry; "EOS095 Work Type Code")
                        {
                            IncludeCaption = true;
                        }
                        column(CC_Qty_ResLedgEntry; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(CC_DirectUnitCost_ResLedgEntry; "EOS095 Unit Cost (LCY)")
                        {
                            IncludeCaption = true;
                        }
                        column(CC_TotalCost_ResLedgEntry; "EOS095 Cost Amount (LCY)")
                        {
                            IncludeCaption = true;
                        }
                        column(CC_Chargeable_ResLedgEntry; "EOS095 Chargeable")
                        {
                        }
                        column(CC_TotalDirectCostCaption; TotalDirectCostCaptionLbl)
                        {
                        }
                        column(CC_TotalCaption; TotalCaptionLbl)
                        {
                        }
                        column(CC_TotalKMCaption; TotalKMCaptionLbl)
                        {
                        }
                        column(CC_TotalEXPCaption; TotalEXPCaptionLbl)
                        {
                        }
                        column(CC_JobNo; "Job No.")
                        {
                            IncludeCaption = true;
                        }
                        column(CC_TimeSheetNo; "Time Sheet No.")
                        {
                            IncludeCaption = true;
                        }
                        column(CC_TotalCost_KM; TotalCost_KM)
                        {
                        }
                        column(CC_TotalCost_EXP; TotalCost_EXP)
                        {
                        }
                        column(CC_Date; Date)
                        {
                            IncludeCaption = true;
                        }
                        column(CC_WorkTypeCode; "EOS095 Work Type Code")
                        {
                            IncludeCaption = true;
                        }
                        column(CC_DestinationCity; DestinationCity)
                        {
                        }
                        column(CC_KM; KM)
                        {
                        }
                        column(CC_TotalKM2CaptionLbl; TotalKM2CaptionLbl)
                        {
                        }
                        column(CC_Status; Status)
                        {
                            IncludeCaption = true;
                        }
                        column(ResourceExpCC; ResourceExpCC)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            //Start TDAG03919/dc
                            if lRecTravelAgreement.Get("EOS095 Travel Agr. Entry No.") then
                                if lRecTravelAgreement."Invoicing Type" = lRecTravelAgreement."Invoicing Type"::Forfait then
                                    CurrReport.Skip();

                            if "EOS095 Work Type" = "EOS095 Work Type"::Expenses then begin
                                TotalCost_KM := 0;
                                TotalCost_EXP := "EOS095 Cost Amount (LCY)";
                            end else begin
                                TotalCost_KM := "EOS095 Cost Amount (LCY)";
                                TotalCost_EXP := 0;
                            end;

                            DestinationCity := '';
                            KM := 0;
                            TotalCost_KMValue := 0;

                            if not Job.Get("Job No.") then
                                Job.Init();

                            if not JobType.Get(Job."KVSPSAJob Type") then
                                JobType.Init();

                            if not JobType."Internal Job" then begin
                                if not Customer.Get(Job."Sell-to Customer No.") then
                                    Customer.Init();
                                DestinationCity := Customer.City;
                                //Start TDAG26074/dc
                                //IF "Ship-to Code" <> '' THEN
                                //  IF ShiptoAddress.GET("Customer No.","Ship-to Code") THEN
                                //    DestinationCity := ShiptoAddress.City;
                                if TimeSheetLine.Get("Time Sheet No.", "EOS095 Applies-to Line No.") then
                                    if TimeSheetLine."EOS095 Ship-to Code" <> '' then
                                        if ShiptoAddress.Get(TimeSheetLine."EOS095 Customer No.", TimeSheetLine."EOS095 Ship-to Code") then
                                            DestinationCity := ShiptoAddress.City;
                                //Stop TDAG26074/dc
                            end;

                            if "EOS095 Work Type" = "EOS095 Work Type"::Distance then begin
                                JobsSetup.Get();
                                JobsSetup.TestField("EOI KM Cost");
                                KM := "EOS095 Cost Amount (LCY)" / JobsSetup."EOI KM Cost";
                                TotalCost_KMValue := KM;
                            end;
                            //Stop TDAG03919/dc

                            //Start TDAG21920/dc
                            ResourceExpCC := '';
                            TimeSheetExpAddResource.Reset();
                            TimeSheetExpAddResource.SetRange("Time Sheet No.", "Time Sheet No.");
                            TimeSheetExpAddResource.SetRange("Time Sheet Line No.", "Time Sheet Line No.");
                            if TimeSheetExpAddResource.FindFirst() then
                                repeat
                                    if ResourceExpCC = '' then
                                        ResourceExpCC := TimeSheetExpAddResource."Resource No."
                                    else
                                        ResourceExpCC += '|' + TimeSheetExpAddResource."Resource No.";
                                until TimeSheetExpAddResource.Next() = 0;

                            if ResourceExpCC <> '' then
                                ResourceExpCC := Text012 + ResourceExpCC;
                            //Stop TDAG21920/dc
                        end;

                        trigger OnPreDataItem()
                        begin
                            //Start TDAG03919/dc
                            if CC.Number <> 2 then
                                CurrReport.Break();

                            if DateFilter <> '' then
                                SetFilter(Date, DateFilter);

                            CurrReport.CreateTotals(Quantity, "EOS095 Cost Amount (LCY)", TotalCost_KM, TotalCost_EXP, TotalCost_KMValue);
                            //Stop TDAG03919/dc
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        //Start TDAG03919/dc
                        if (not PrintCreditCard) and (CC.Number = 2) then
                            CurrReport.Break();
                        //Stop TDAG03919/dc
                    end;
                }
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.PageNo := 1;
                FirstGroupTotal := true;
                //Start TDAG06031/dc
                if not "EOS095 Company Car" then begin
                    MonthKmAct := 0
                end else begin
                    MonthKmAct := MonthKm;
                    if MonthKmAct = 0 then
                        Error(StrSubstNo(Text50000, Resource."No."));
                    //Start TDAG20548/dc
                    InsertKm();
                    //Stop TDAG20548/dc
                end;
                //Stop TDAG06031/dc
            end;

            trigger OnPreDataItem()
            begin
                SetRange("No.", ResFilterGlobal);
            end;

        }
    }

    requestpage
    {
        //SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartingDate)
                    {
                        Caption = 'Starting Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the "Starting Date" field';

                        trigger OnValidate()
                        var
                            i: Integer;
                        begin
                            //Start TDAG20548/dc
                            i := Date2DMY(StartingDate, 1);
                            if i <> 1 then
                                Error(Text010);

                            if Data.Get(Data."Period Type"::Month, StartingDate) then
                                if Data.Find('>') then begin
                                    EndingDate := Data."Period Start" - 1;
                                end;
                            //Stop TDAG20548/dc
                            //Stop TDAG20548/dc
                            CalcKm();
                            //Stop TDAG20548/dc
                        end;
                    }
                    field(EndingDate; EndingDate)
                    {
                        Caption = 'Ending Date';
                        Editable = ResFilterGlobalEdit;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the "Ending Date" field';
                    }
                    field(PrintCreditCard; PrintCreditCard)
                    {
                        Caption = 'Print Credit Card';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the "Print Credit Card" field';
                    }
                    field(MonthKm; MonthKm)
                    {
                        BlankNumbers = BlankZero;
                        Caption = 'Car Km:';
                        DrillDown = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the "Car Km:" field';

                        trigger OnDrillDown()
                        var
                            ResourceMonthKmList: Page "EOI Resource Month Km List";
                        begin
                            //Start TDAG20548/dc
                            Clear(ResourceMonthKmList);
                            if ResFilterGlobal = '' then
                                Error(Text011);
                            if GlobalResource.Get(ResFilterGlobal) then
                                if not GlobalResource."EOS095 Company Car" then
                                    exit;
                            ResourceMonthKm.Reset();
                            ResourceMonthKm.SetRange(Year, Date2DMY(StartingDate, 3));
                            if not ResFilterGlobalEdit then
                                ResourceMonthKm.FilterGroup(2);
                            ResourceMonthKm.SetRange("Resource No.", ResFilterGlobal);
                            ResourceMonthKmList.SetTableView(ResourceMonthKm);
                            ResourceMonthKmList.RunModal();
                            //Stop TDAG20548/dc
                            //Stop TDAG20548/dc
                            CalcKm();
                            //Stop TDAG20548/dc
                        end;

                        trigger OnValidate()
                        begin
                            //Start TDAG20548/dc
                            if GlobalResource.Get(ResFilterGlobal) then
                                if not GlobalResource."EOS095 Company Car" then
                                    MonthKm := 0;

                            if MonthKm <> 0 then begin
                                ResourceMonthKm.SetCurrentKey("Resource No.", Year, Month);
                                ResourceMonthKm.SetRange("Resource No.", ResFilterGlobal);
                                ResourceMonthKm.SetFilter(Year, '<=%1', Date2DMY(StartingDate, 3));
                                ResourceMonthKm.SetFilter(Month, '<%1', Date2DMY(StartingDate, 2));
                                if ResourceMonthKm.FindLast() then
                                    if ResourceMonthKm."Km Value" > MonthKm then
                                        Message(KmError);
                            end;
                            //Start TDAG20548/dc
                        end;
                    }
                    field(ResFilterGlobal; ResFilterGlobal)
                    {
                        Caption = 'Resource filter';
                        Editable = ResFilterGlobalEdit;
                        TableRelation = Resource;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the "Resource filter" field';

                        trigger OnValidate()
                        begin
                            //Stop TDAG20548/dc
                            CalcKm();
                            //Stop TDAG20548/dc
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            //Start TDAG18282/dc
            ResFilterGlobalEdit := false;
            if UserSetup.Get(UserId) then begin
                ResFilterGlobalEdit := UserSetup."Time Sheet Admin.";
                ResFilterGlobal := UserSetup."KVSPSAResource No.";
            end;
            //Stop TDAG18282/dc

            SetInitDate();

            //Stop TDAG20548/dc
            //CalcKm;
            //Stop TDAG20548/dc
        end;
    }

    labels
    {
        CustCityCaptionLbl = 'Customer City';
        KMCaptionLbl = 'KM';
    }

    trigger OnPreReport()
    begin
        ResFilter := Resource.GetFilters;
        ResLedgEntryFilter := "Time Sheet Detail".GetFilters;
        DateFilter := TimeSheetMgt.GetDateFilter(StartingDate, EndingDate);
    end;

    var
        Customer: Record Customer;
        Data: Record Date;
        ResourceMonthKm: Record "EOI Resource Month Km";
        lRecTravelAgreement: Record "EOS Customer Travel Agreement";
        TimeSheetExpAddResource: Record "EOS Time Sheet Exp. Add. Res";
        Job: Record Job;
        JobsSetup: Record "Jobs Setup";
        JobType: Record "KVSPSAJob Type";
        GlobalResource: Record Resource;
        ShiptoAddress: Record "Ship-to Address";
        TimeSheetLine: Record "Time Sheet Line";
        UserSetup: Record "User Setup";
        TimeSheetMgt: Codeunit "Time Sheet Management";
        FirstGroupTotal: Boolean;
        PrintCreditCard: Boolean;
        [InDataSet]
        ResFilterGlobalEdit: Boolean;
        ResFilterGlobal: Code[20];
        EndingDate: Date;
        StartingDate: Date;
        KM: Decimal;
        TotalCost_EXP: Decimal;
        TotalCost_KM: Decimal;
        TotalCost_KMValue: Decimal;
        MonthKm: Integer;
        MonthKmAct: Integer;
        CreditCard: Label 'CREDIT CARD';
        CurrReportPageNoCaptionLbl: Label 'Page';
        KmCaption: Label 'Company car month km: ';
        KmError: Label 'Warning! in the previous period the km were greater than the current period';
        ResCostBreakdownCaptionLbl: Label 'Resource - Expense';
        ResHeader: Label 'List reported to';
        Text010: Label 'Starting Date must be the first day of the month.';
        Text011: Label 'Select a resource filter';
        Text012: Label 'Additional exp Res.: ';
        Text50000: Label 'You must specify end month km for company car for resource %1';
        TextFooter1: Label 'The subscribed declare that all the expenses described here are strictly dependent on the accomplishment of the received and authorizes the %1 reimbursement of expenses total';
        TextFooter2: Label 'payroll, applying the exemptions provided for by law.';
        TextFooter3: Label 'Bolzano, %1';
        Titolo2: Label 'Reference period from %1';
        TotalCaptionLbl: Label 'Total';
        TotalDirectCostCaptionLbl: Label 'Total Direct Cost';
        TotalEXPCaptionLbl: Label 'Total Exp.';
        TotalKM2CaptionLbl: Label 'Total KM';
        TotalKMCaptionLbl: Label 'Total value KM';
        ResFilter: Text;
        ResLedgEntryFilter: Text;
        ResourceExp: Text;
        ResourceExpArc: Text;
        ResourceExpCC: Text;
        DateFilter: Text[30];
        DestinationCity: Text[30];

    local procedure CalcKm()
    begin
        //Start TDAG20548/dc
        MonthKm := 0;
        if (GlobalResource.Get(ResFilterGlobal)) then
            if not GlobalResource."EOS095 Company Car" then
                exit;
        if StartingDate = 0D then
            exit;
        ResourceMonthKm.Reset();
        ResourceMonthKm.SetRange(Year, Date2DMY(StartingDate, 3));
        ResourceMonthKm.SetRange(Month, Date2DMY(StartingDate, 2));
        ResourceMonthKm.SetRange("Resource No.", ResFilterGlobal);
        if ResourceMonthKm.FindFirst() then
            MonthKm := ResourceMonthKm."Km Value";
        //Stop TDAG20548/dc
    end;

    local procedure InsertKm()
    begin
        //Start TDAG20548/dc
        ResourceMonthKm.Reset();
        ResourceMonthKm.SetRange(Year, Date2DMY(StartingDate, 3));
        ResourceMonthKm.SetRange(Month, Date2DMY(StartingDate, 2));
        ResourceMonthKm.SetRange("Resource No.", ResFilterGlobal);
        if ResourceMonthKm.FindFirst() then begin
            ResourceMonthKm."Km Value" := MonthKm;
            ResourceMonthKm.Modify();
        end else begin
            ResourceMonthKm.Init();
            ResourceMonthKm."Entry No." := 0;
            ResourceMonthKm.Year := Date2DMY(StartingDate, 3);
            ResourceMonthKm.Month := Date2DMY(StartingDate, 2);
            ResourceMonthKm."Resource No." := ResFilterGlobal;
            ResourceMonthKm."Km Value" := MonthKm;
            ResourceMonthKm.Insert(true);
        end;
        Commit();
        //Stop TDAG20548/dc
    end;

    local procedure SetInitDate()
    var
        i: Integer;
    begin

        if Date2DMY(WorkDate(), 1) < 10 then begin
            if Date2DMY(WorkDate(), 2) = 1 then
                StartingDate := DMY2Date(1, 12, Date2DMY(WorkDate(), 3) - 1)
            else
                StartingDate := DMY2Date(1, Date2DMY(WorkDate(), 2) - 1, Date2DMY(WorkDate(), 3));
        end else
            StartingDate := DMY2Date(1, Date2DMY(WorkDate(), 2), Date2DMY(WorkDate(), 3));
        i := Date2DMY(StartingDate, 1);
        if i <> 1 then
            Error(Text010);

        if Data.Get(Data."Period Type"::Month, StartingDate) then
            if Data.Find('>') then begin
                EndingDate := Data."Period Start" - 1;
            end;
        CalcKm();
    end;

}

