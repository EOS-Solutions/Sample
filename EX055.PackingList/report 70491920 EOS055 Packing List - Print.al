/// <summary>
/// Report EOS055 Packing List - Print (ID 70491920).
/// </summary>
report 70491920 "EOS055 Packing List - Print"
{

    DefaultLayout = RDLC;
    RDLCLayout = '.\Source\Report\report 70491920 EOS055 Packing List - Print.rdl';
    Caption = 'Packing List - Print';
    UsageCategory = None;

    dataset
    {
        dataitem(Doc; "EOS Record Ident. Buffer")
        {
            DataItemTableView = sorting("Entry No.");
            UseTemporary = true;

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }

        dataitem(TmpPackingListHeader; "EOS055 PackList Header Buffer")
        {
            DataItemTableView = sorting("Packing List No.");
            UseTemporary = true;

            column(HeaderImage; "Header Image") { }
            column(FooterImage; "Footer Image") { }
            column(BillToAddress; BillToAddress) { }
            column(ShipToAddress; ShipToAddress) { }
            column(AddressPosition; "Address Position") { }
            column(Header_No; Description) { }
            column(Withdrawal; "Withdrawal Date/Time") { }
            column(DocumentText; AssignedDocumentText) { }

            dataitem(TmpPackingListLine; "EOS055 PackList Line Buffer")
            {
                DataItemLink = "Packing List No." = field("Packing List No.");
                DataItemTableView = sorting("Packing List No.", "Line No.");
                UseTemporary = true;

                column(IsBold; IsBold) { }
                column(Indentation; Level) { }
                column(No; "No.")
                {
                    IncludeCaption = true;
                }
                column(Description; Description)
                {
                    IncludeCaption = true;
                }
                column(QuantityBase; "Quantity (Base)")
                {
                    IncludeCaption = true;
                }
                column(TotalWeight; "Gross Weight")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(TotalCubage; "Unit Volume")
                {
                    DecimalPlaces = 2 : 2;
                }

                trigger OnAfterGetRecord()
                begin
                    IsBold := PrintContents and (Type = Type::"Handling Unit");
                end;
            }

            dataitem(TmpPackagingMaterial; "EOS055 PackList Mat. Buffer")
            {
                DataItemTableView = sorting("Sorting Text");
                UseTemporary = true;

                column(IsParcelTypesSummary; true) { }
                column(PTS_Code; "Packaging Material No.") { }
                column(PTS_Description; Description) { }
                column(PTS_Cubage; Volume) { }
                column(PTS_Weight; "Gross Weight") { }
                column(PTS_Count; "Units No.") { }
            }

            dataitem(Footer; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

                column(IsFooter; true)
                {
                }
                column(PLTotalWeight; TotalGrossWeight)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(PLTotalNetWeight; TotalNetWeight)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(PLTotalCubage; TotalVolume)
                {
                    DecimalPlaces = 2 : 2;
                }
                column(PLParcelCount; NoOfParcels)
                {
                }
                column(PLPalletCount; NoOfLoadCarriers)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                TotalGrossWeight := "Total Gross Weight";
                TotalNetWeight := "Total Net Weight";
                TotalVolume := "Total Volume";
                NoOfLoadCarriers := "No. of Load Carrier";
                NoOfParcels := "No. of Parcels";

                BillToAddress := PackingListPrint.GetBillToAddress(TmpPackingListHeader);
                ShipToAddress := PackingListPrint.GetShipToAddress(TmpPackingListHeader);
                AssignedDocumentText := PackingListPrint.GetAssignedDocumentText(TmpPackingListHeader);
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
                    field(PrintContentsField; PrintContents)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Contents';
                        ToolTip = 'Specifies whether contents should be printed.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            PrintContents := true;
        end;
    }

    labels
    {
        Page_Caption = 'Page: ';
        ShipToAddress_Caption = ' ';
        BillToAddress_Caption = 'Ship-To Address';
        WithdrawalCaption = 'Withdrawal';
        DocumentTextCaption = 'Document';
        TotalWeightCaption = 'Weight (Total)';
        TotalCountCaption = 'Parcel Count (Total)';
        TotalCubageCaption = 'Cubage (Total)';
        TotalsPerParcelTypeCaption = 'Totals per packaging type';
    }

    trigger OnPreReport()
    var
        SourceDoc: Record "EOS Record Ident. Buffer";
        Language: Codeunit Language;
        flt: Text;
        SourceType: Integer;
        SourceSubtype: Integer;
        SourceID: Code[20];
    begin
        flt := Doc.GetFilter("Source Type");
        Evaluate(SourceType, flt);
        flt := Doc.GetFilter("Source Subtype");
        Evaluate(SourceSubtype, flt);
        flt := Doc.GetFilter("Source ID");
        SourceID := CopyStr(flt, 1, MaxStrLen(SourceID));

        SourceDoc."Source Type" := SourceType;
        SourceDoc."Source Subtype" := SourceSubtype;
        SourceDoc."Source ID" := SourceID;
        PackingListPrint.FillContent(SourceDoc, PrintContents, TmpPackingListHeader, TmpPackingListLine, TmpPackagingMaterial);

        CurrReport.Language := Language.GetLanguageIdOrDefault(PackingListPrint.GetReportLanguage(SourceDoc));
    end;

    var
        PackingListPrint: Codeunit "EOS055 Packing List Print";
        PrintContents: Boolean;
        NoOfLoadCarriers: Integer;
        NoOfParcels: Integer;
        TotalNetWeight: Decimal;
        TotalGrossWeight: Decimal;
        TotalVolume: Decimal;
        BillToAddress: Text;
        ShipToAddress: Text;
        AssignedDocumentText: Text;
        IsBold: Boolean;
}