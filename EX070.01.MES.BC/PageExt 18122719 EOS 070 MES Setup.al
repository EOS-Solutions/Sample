/// <summary>Pageextension that added action for print barcode in MES Setup page</summary>
pageextension 50000 EOS070Pageext1812219 extends "EOS 070 MES Setup"
{
    actions
    {
        addfirst(Processing)
        {
            action("EOS PrintEmployeeBadge")
            {
                ApplicationArea = All;
                Caption = 'Print Employee Badge';
                ToolTip = 'Print Badge Barcode for Employee';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = report "EOS 070 MES Employee Badge";
                Visible = false;
                Enabled = false;
            }
            action("EOS PrintBarcodeReasons")
            {
                ApplicationArea = All;
                Caption = 'Print Barcode Reason';
                ToolTip = 'Print Reasons Barcode';
                Image = PrintInstallment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = report "EOS 070 MES Barcode Reason";
                Visible = false;
                Enabled = false;
            }
        }
    }
}