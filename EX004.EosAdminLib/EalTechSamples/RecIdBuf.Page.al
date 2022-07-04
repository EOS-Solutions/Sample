page 50100 "RecIdBuf Demo"
{

    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "EOS Record Ident. Buffer";
    SourceTableTemporary = true;

    InsertAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {

                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = All;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                }
                field("Source Batch Name"; Rec."Source Batch Name")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Source Prod. Order Line"; Rec."Source Prod. Order Line")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Source Ref. No."; Rec."Source Ref. No.")
                {
                    ApplicationArea = All;
                }
                field("Record ID"; Format(Rec."Record ID"))
                {
                    ApplicationArea = All;
                }
                field(TableType; GetCurrTableType())
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Encode)
            {
                action(CreateRecordRef)
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        RecRef: RecordRef;
                    begin
                        Rec.CreateRecRef(RecRef);
                        Message('%1', RecRef.RecordId);
                    end;
                }
                action(OpenCard)
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    begin
                        Rec.ShowCard();
                    end;
                }
            }
            group(Decode)
            {
                action(GetSalesHeader)
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        if (Page.RunModal(0, SalesHeader) = Action::LookupOK) then
                            Rec.GetTable(SalesHeader);
                    end;
                }
                action(GetSalesInvoiceHeader)
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                    begin
                        if (Page.RunModal(0, SalesInvoiceHeader) = Action::LookupOK) then
                            Rec.GetTable(SalesInvoiceHeader);
                    end;
                }
                action(GetVendor)
                {
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        Vendor: Record Vendor;
                    begin
                        if (Page.RunModal(0, Vendor) = Action::LookupOK) then
                            Rec.GetTable(Vendor);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec."Entry No." := 1;
        Rec.Insert();
    end;

    local procedure GetCurrTableType(): Text
    var
        TableType: Text;
    begin
        if TryGetCurrTableType(TableType) then;
        exit(TableType);
    end;

    [TryFunction]
    local procedure TryGetCurrTableType(var TableType: Text)
    var
        RecRef: RecordRef;
    begin
        Clear(TableType);
        Rec.CreateRecRef(RecRef);
        TableType := Format(Rec.GetTableType(RecRef));
    end;

}