report 61300 "EXA05 My Custom Report"
{
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = '.\05_ManualRequestCreation\EXA005 My Custom Report.rdlc';
    PreviewMode = PrintLayout;
    DefaultLayout = RDLC;

    dataset
    {
        dataitem(EXA005MyCustomTable; "EXA005 My Custom Table")
        {
            column(Code; Code)
            {
            }
            column(Description; Description)
            {
            }
            column(SelltoCustomerNo; "Sell-to Customer No.")
            {
            }
            column(BilltoCustomerNo; "Bill-to Customer No.")
            {
            }
            column(SalesPersonCode; "SalesPerson Code")
            {
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
