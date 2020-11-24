report 18123251 "EOS Purch. Req. - Create Doc."
{

    Caption = 'Purch. Request - Create Doc.';
    ProcessingOnly = true;
    UsageCategory = None;

    dataset
    {
        dataitem(TmpPurchReqHeader; "EOS Purch. Request Header")
        {
            UseTemporary = true;
            trigger OnPreDataItem()
            begin
                if MultipleDoc then begin
                    FillMatrix(TmpPurchReqHeader);
                    if not (Page.RunModal(page::"EOS Purch. Req. Multi Vendor", PurchReqMultiVendor) = Action::LookupOK) then
                        CurrReport.Break();
                end;
            end;

            trigger OnAfterGetRecord()
            var
                PurchHeader: Record "Purchase Header";
                PurchLine: Record "Purchase Line";
                PurchReqHeader: Record "EOS Purch. Request Header";
                PurchReqLine: Record "EOS Purch. Request Line";
                TmpPurchReqLine: Record "EOS Purch. Request Line" temporary;
                PurchReqMgt: Codeunit "EOS Purch. Request Management";
                IsFirstLine: Boolean;
            begin
                if MultipleDoc then begin
                    BuildTempReqLine(TmpPurchReqLine, TmpPurchReqHeader);
                    if TmpPurchReqLine.FindSet(true) then begin
                        IsFirstLine := true;
                        repeat
                            FindOrCreatePurchHeader(TmpPurchReqHeader, TmpPurchReqLine, IsFirstLine, PurchHeader);
                            IsFirstLine := false;
                            PurchReqMgt.CreatePurchLineFromReqLine(TmpPurchReqLine, PurchHeader, PurchLine, true);

                            OnAfterModifyPurchReqLine_AddDCSMetadata(TmpPurchReqLine, PurchHeader);
                        until TmpPurchReqLine.Next() = 0;
                    end;
                end else begin
                    PurchReqLine.SetRange("EOS Purch. Requisition No.", TmpPurchReqHeader."EOS No.");
                    if PurchReqLine.FindSet(true) then begin
                        IsFirstLine := true;
                        repeat
                            FindOrCreatePurchHeader(TmpPurchReqHeader, PurchReqLine, IsFirstLine, PurchHeader);
                            IsFirstLine := false;
                            PurchReqMgt.CreatePurchLineFromReqLine(PurchReqLine, PurchHeader, PurchLine, false);
                            PurchReqLine.Modify();

                            OnAfterModifyPurchReqLine_AddDCSMetadata(PurchReqLine, PurchHeader);
                        until PurchReqLine.Next() = 0;
                    end;
                end;
                if ClosePurchRequest then begin
                    PurchReqHeader.Get("EOS No.");
                    PurchReqHeader.Validate("EOS Status", PurchReqHeader."EOS Status"::Closed);
                    PurchReqHeader.Modify();
                end;

                if ArchivePurchRequest then begin
                    PurchReqHeader.Get("EOS No.");
                    PurchReqMgt.ArchivePurchRequest(PurchReqHeader);
                end;
            end;

            trigger OnPostDataItem()
            var
                PurchHeader: Record "Purchase Header";
                PageMgt: Codeunit "Page Management";
            begin
                if not GuiAllowed() then exit;
                if TmpPurchHeader.IsEmpty() then exit;

                Commit();

                if not Confirm(PurchDocCreatedQst, true, Counter) then
                    exit;

                TmpPurchHeader.Reset();
                TmpPurchHeader.FindFirst();
                repeat
                    PurchHeader.Get(TmpPurchHeader."Document Type", TmpPurchHeader."No.");
                    PurchHeader.Mark(true);
                until TmpPurchHeader.Next() = 0;

                PurchHeader.MarkedOnly(true);
                if PurchHeader.Count() > 1 then
                    PAGE.RunModal(PAGE::"Purchase List", PurchHeader)
                else begin
                    PurchHeader.FindLast();
                    PageMgt.PageRunModal(PurchHeader);
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DocumentType; DocType)
                    {
                        Caption = 'Document Type';
                        OptionCaption = 'Quote,Order,Blanket Order';
                        ApplicationArea = all;
                    }
                    field(ArchivePurchReq; ArchivePurchRequest)
                    {
                        Caption = 'Arch. Purch. Request';
                        ApplicationArea = all;
                    }
                    field(ClosePurchReq; ClosePurchRequest)
                    {
                        Caption = 'Close Purch. Request';
                        Enabled = CanClosePurchReq;
                        ApplicationArea = all;
                    }
                    field("Multiple Doc"; MultipleDoc)
                    {
                        ApplicationArea = All;
                        Caption = 'Preview item vendors';
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

    trigger OnInitReport()
    begin
        PlatformSetup.Read();
        ClosePurchRequest := PlatformSetup."EOS Close Purch. Request";
        ArchivePurchRequest := PlatformSetup."EOS Arch. Purch. Request";
        CanClosePurchReq := true;
        OnInitReport_CanClosePurchReq(CanClosePurchReq);
        if not CanClosePurchReq then
            ClosePurchRequest := false;
    end;

    var
        PlatformSetup: Record "EOS Purch. Request Setup";
        TmpPurchHeader: Record "Purchase Header" temporary;
        PurchReqMultiVendor: Record "EOS Purch. Req. Multi Vendor" temporary;
        DocType: Option Quote,"Order","Blanket Order";
        Counter: Integer;
        PurchDocCreatedQst: Label '%1 purchase documents have been created.\Do you want to open the created documents?';
        ArchivePurchRequest: Boolean;
        ClosePurchRequest: Boolean;
        [InDataSet]
        CanClosePurchReq: Boolean;
        MultipleDoc: Boolean;

    local procedure FindOrCreatePurchHeader(PurchReqHeader: Record "EOS Purch. Request Header"; PurchReqLine: Record "EOS Purch. Request Line"; CopyComments: Boolean; var PurchHeader: Record "Purchase Header")
    begin
        TmpPurchHeader.SetRange("Buy-from Vendor No.", PurchReqLine."EOS Vendor No.");
        TmpPurchHeader.SetRange("Currency Code", PurchReqLine."EOS Currency Code");
        if TmpPurchHeader.FindLast() then
            PurchHeader.Get(TmpPurchHeader."Document Type", TmpPurchHeader."No.")
        else begin
            PurchHeader.Init();
            IF DocType = DocType::"Blanket Order" then
                PurchHeader."Document Type" := PurchHeader."Document Type"::"Blanket Order"
            else
                PurchHeader."Document Type" := DocType;
            PurchHeader."No." := '';
            PurchHeader.Insert(true);
            PurchHeader.Validate("Buy-from Vendor No.", PurchReqLine."EOS Vendor No.");
            if (PurchHeader."Currency Code" <> PurchReqLine."EOS Currency Code") then
                PurchHeader.Validate("Currency Code", PurchReqLine."EOS Currency Code");
            PurchHeader.Validate("Location Code", PurchReqLine."EOS Location Code");
            PurchHeader.Modify();

            TmpPurchHeader := PurchHeader;
            TmpPurchHeader.Insert();

            Counter += 1;
        end;

        if CopyComments then
            CopyHeaderComments(PurchReqHeader, PurchHeader);
    end;

    procedure InitRequest(var PurchReqHeader: Record "EOS Purch. Request Header")
    begin
        if PurchReqHeader.FindSet() then
            repeat
                PurchReqHeader.TestField("EOS Status", PurchReqHeader."EOS Status"::Approved);
                TmpPurchReqHeader := PurchReqHeader;
                TmpPurchReqHeader.Insert();
            until PurchReqHeader.Next() = 0;
    end;


    local procedure CopyHeaderComments(PurchReqHeader: Record "EOS Purch. Request Header"; PurchHeader: Record "Purchase Header")
    var
        PurchCommentLine: Record "EOS Purch. Comment Line";
        NewPurchCommentLine: Record "EOS Purch. Comment Line";
        NextCommentLineNo: Integer;
    begin
        PurchCommentLine.SetRange("EOS Document Type", PurchHeader."Document Type");
        PurchCommentLine.SetRange("EOS No.", PurchHeader."No.");
        if PurchCommentLine.FindLast() then;
        NextCommentLineNo := PurchCommentLine."EOS Line No.";

        PurchCommentLine.SetRange("EOS Document Type", PurchCommentLine."EOS Document Type"::"Purch. Request");
        PurchCommentLine.SetRange("EOS No.", TmpPurchReqHeader."EOS No.");
        if PurchCommentLine.FindSet() then
            repeat
                NextCommentLineNo += 10000;
                NewPurchCommentLine.Init();
                NewPurchCommentLine."EOS Document Type" := PurchHeader."Document Type";
                NewPurchCommentLine."EOS No." := PurchHeader."No.";
                NewPurchCommentLine."EOS Line No." := NextCommentLineNo;
                NewPurchCommentLine."EOS Comment" := PurchCommentLine."EOS Comment";
                NewPurchCommentLine.Insert();
            until PurchCommentLine.Next() = 0;
    end;

    local procedure FillMatrix(PurchReqHeader: Record "EOS Purch. Request Header")
    var
        ItemVendor: Record "Item Vendor";
        PurchReqLine: Record "EOS Purch. Request Line";
    begin
        PurchReqLine.SetRange("EOS Purch. Requisition No.", PurchReqHeader."EOS No.");
        PurchReqLine.SetRange("EOS Type", PurchReqLine."EOS Type"::"G/L Account", PurchReqLine."EOS Type"::Item);
        if PurchReqLine.FindSet(true) then
            repeat
                if PurchReqLine."EOS Vendor No." <> '' then
                    with PurchReqMultiVendor do
                        if not Get(PurchReqLine."EOS Vendor No.") then begin
                            Init();
                            Validate("Vendor No.", PurchReqLine."EOS Vendor No.");
                            "Purch. Req. No." := PurchReqHeader."EOS No.";
                            Insert();
                        end else begin
                            "Purch. Req. No." := PurchReqHeader."EOS No.";
                            Modify();
                        end;

                ItemVendor.SetRange("Item No.", PurchReqLine."EOS No.");
                ItemVendor.SetRange("Variant Code", PurchReqLine."EOS Variant Code");
                if ItemVendor.FindSet() then
                    repeat
                        InsertOrModifyMatrix(ItemVendor, PurchReqHeader);
                    until ItemVendor.Next() = 0;
            until PurchReqLine.Next() = 0;
        Commit();
    end;

    local procedure InsertOrModifyMatrix(ItemVendor: Record "Item Vendor"; PurchReqHeader: Record "EOS Purch. Request Header")
    begin
        with PurchReqMultiVendor do
            if not Get(ItemVendor."Vendor No.") then begin
                Init();
                Validate("Vendor No.", ItemVendor."Vendor No.");
                "No. Available items" := 1;
                "Purch. Req. No." := PurchReqHeader."EOS No.";
                Insert();
            end else begin
                "No. Available items" += 1;
                "Purch. Req. No." := PurchReqHeader."EOS No.";
                Modify();
            end;
    end;

    local procedure BuildTempReqLine(var TmpPurchReqLine: Record "EOS Purch. Request Line"; PurchReqHeader: Record "EOS Purch. Request Header")
    var
        PurchReqLine2: Record "EOS Purch. Request Line";
        ItemVendor: Record "Item Vendor";
        lineNo: Integer;
    begin
        lineNo := 10000;
        PurchReqLine2.SetRange("EOS Purch. Requisition No.", PurchReqHeader."EOS No.");
        //PurchReqLine2.SetRange("EOS Type", PurchReqLine2."EOS Type"::"G/L Account", PurchReqLine2."EOS Type"::Item);
        TmpPurchReqLine.DeleteAll();
        if PurchReqLine2.FindSet() then
            repeat
                PurchReqMultiVendor.Reset();
                PurchReqMultiVendor.SetRange("Create Document", true);
                if PurchReqMultiVendor.FindSet() then
                    repeat
                        if PurchReqLine2."EOS Type" in [PurchReqLine2."EOS Type"::"G/L Account", PurchReqLine2."EOS Type"::" "] then
                            with TmpPurchReqLine do begin
                                Init();
                                TmpPurchReqLine := PurchReqLine2;
                                "EOS Line No." := lineNo;
                                "EOS Vendor No." := PurchReqMultiVendor."Vendor No.";
                                "EOS Document Line No." := PurchReqLine2."EOS Line No.";
                                Insert();
                                lineNo += 10000;
                            end
                        else
                            if not PurchReqMultiVendor."Insert all items" then begin
                                ItemVendor.SetRange("Item No.", PurchReqLine2."EOS No.");
                                ItemVendor.SetRange("Variant Code", PurchReqLine2."EOS Variant Code");
                                ItemVendor.SetFilter("Vendor No.", PurchReqMultiVendor."Vendor No.");
                                if ItemVendor.FindSet() then
                                    repeat
                                        with TmpPurchReqLine do begin
                                            Init();
                                            TmpPurchReqLine := PurchReqLine2;
                                            "EOS Line No." := lineNo;
                                            "EOS Vendor No." := ItemVendor."Vendor No.";
                                            "EOS Document Line No." := PurchReqLine2."EOS Line No.";
                                            Insert();
                                            lineNo += 10000;
                                        end;
                                    until ItemVendor.Next() = 0;
                            end else
                                with TmpPurchReqLine do begin
                                    Init();
                                    TmpPurchReqLine := PurchReqLine2;
                                    "EOS Line No." := lineNo;
                                    "EOS Vendor No." := PurchReqMultiVendor."Vendor No.";
                                    "EOS Document Line No." := PurchReqLine2."EOS Line No.";
                                    Insert();
                                    lineNo += 10000;
                                end;

                    until PurchReqMultiVendor.Next() = 0;

            until PurchReqLine2.Next() = 0;
    end;


    [IntegrationEvent(true, false)]
    procedure OnAfterModifyPurchReqLine_AddDCSMetadata(
        PurchReqLine: Record "EOS Purch. Request Line";
        PurchHeader: Record "Purchase Header"
    )
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitReport_CanClosePurchReq(var CanClose: Boolean)
    begin
    end;
}
