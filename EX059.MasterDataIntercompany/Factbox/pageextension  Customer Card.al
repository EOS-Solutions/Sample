pageextension 18008110 "EOS PageExt18008110" extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(FactBoxes)
        {
            part(EOSMDIIntercompany; "EOS MDI Record FactBox")
            {
                ApplicationArea = All;
                Caption = 'MDI Intercompany';
                SubPageView = sorting("Table ID", "Document Type", "No.", "Line No.", "No. 2", "Factbox Line No.");
                SubPageLink = "Table ID" = const(18), "No." = field("No.");
                Editable = false;
            }
        }
    }
}
