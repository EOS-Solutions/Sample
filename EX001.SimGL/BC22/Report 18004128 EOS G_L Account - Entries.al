report 18004128 "EOS G/L Account - Entries"
{

    DefaultLayout = RDLC;
    RDLCLayout = 'source/Report/Report 18004128 EOS G_L Account - Entries.rdlc';
    Caption = 'G/L Account - Entries (SGL)';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(DataItem18000009; Integer)
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            column(COMPANYNAME; CompanyName())
            {
            }

            column(Filterstring; GetFilters())
            {
            }

        }

        dataitem(GlAccount; "G/L Account")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter";

            dataitem(EntryLoop; Integer)
            {
                DataItemTableView = SORTING(Number);
                column(RunningTotalStart; RunningTotalStart)
                {
                }
                column(GLEntry_GLAccountName; GlAccount.Name)
                {
                }
                column(GLEntry_GLAccountNo; TempGLEntry."G/L Account No.")
                {
                }
                column(GLEntry_DocumentType; Format(TempGLEntry."Document Type"))
                {
                }
                column(GLEntry_DocumentNo; TempGLEntry."Document No.")
                {
                }
                column(GLEntry_PostingDate; FORMAT(TempGLEntry."Posting Date"))
                {
                }
                column(GLEntry_Description; TempGLEntry.Description)
                {
                }
                column(GLEntry_DebitAmount; TempGLEntry."Debit Amount")
                {
                }
                column(GLEntry_CreditAmount; TempGLEntry."Credit Amount")
                {
                }
                column(GLEntry_EntryNo; TempGLEntry."Entry No.")
                {
                }
                column(EntrySource; EntrySource)
                {
                }
                column(RunningTotal; RunningTotal)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    IF Number = 1 THEN begin
                        TempGLEntry.FindFirst();
                        RunningTotal := RunningTotalStart;
                    end ELSE
                        TempGLEntry.Next();

                    RunningTotal := RunningTotal + TempGLEntry.Amount;

                    IF TempGLEntry."System-Created Entry" THEN
                        EntrySource := SimGlTok
                    ELSE
                        EntrySource := GlTok;
                end;

                trigger OnPreDataItem()
                begin
                    TempGLEntry.SETCURRENTKEY("G/L Account No.", "Posting Date");
                    SETRANGE(Number, 1, TempGLEntry.Count());
                end;
            }

            trigger OnAfterGetRecord()
            var
                GLAcc: Record "G/L Account";
                GLEntry: Record "G/L Entry";
                SimGLEntry: Record "EOS Sim. G/L Entry";
                LastEntryNo: Integer;
            begin
                GLAcc.GET("No.");
                GLAcc.SETFILTER("Date Filter", '<%1', GETRANGEMIN("Date Filter"));
                GLAcc.CALCFIELDS("Net Change", "EOS Net Change (Sim.)");

                RunningTotalStart := GLAcc."Net Change";
                IF IncludeSimGLEntries THEN
                    RunningTotalStart := RunningTotalStart + GLAcc."EOS Net Change (Sim.)";

                TempGLEntry.Reset();
                TempGLEntry.DeleteAll();

                GLEntry.SETRANGE("G/L Account No.", "No.");
                GLEntry.SETFILTER("Posting Date", GlAccount.GETFILTER("Date Filter"));
                IF GLEntry.FindSet() THEN
                    REPEAT
                        TempGLEntry := GLEntry;
                        TempGLEntry."System-Created Entry" := FALSE;
                        TempGLEntry.Insert();
                    UNTIL GLEntry.Next() = 0;

                TempGLEntry.Reset();
                IF TempGLEntry.FindLast() THEN;
                LastEntryNo := TempGLEntry."Entry No.";

                IF IncludeSimGLEntries THEN begin
                    SimGLEntry.SETRANGE("G/L Account No.", "No.");
                    SimGLEntry.SETFILTER("Posting Date", GlAccount.GETFILTER("Date Filter"));
                    IF SimGLEntry.FindSet() THEN
                        REPEAT
                            LastEntryNo += 1;
                            SimGLEntry.CopyToGlEntry(TempGLEntry);
                            TempGLEntry."System-Created Entry" := TRUE;
                            TempGLEntry."Entry No." := LastEntryNo;
                            TempGLEntry.Insert();
                        UNTIL SimGLEntry.Next() = 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                SETFILTER("Account Type", '<>%1&<>%2', "Account Type"::"Begin-Total", "Account Type"::"End-Total");
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Optionen)
                {
                    Caption = 'Options';
                    field(IncludeSimGLEntries; IncludeSimGLEntries)
                    {
                        ApplicationArea = All;
                        Caption = 'Incl. Sim. G/L Entries';
                    }
                }
            }
        }

    }

    labels
    {
        ReportTitle = 'G/L Account - Entries';
        PageCaption = 'Page';
        GLEntry_GLAccountNoCaption = 'G/L Account No.';
        GLEntry_DocumentTypeCaption = 'Document Type';
        GLEntry_DocumentNoCaption = 'Document No.';
        GLEntry_PostingDateCaption = 'Posting Date';
        GLEntry_DescriptionCaption = 'Description';
        GLEntry_DebitAmountCaption = 'Debit Amount';
        GLEntry_CreditAmountCaption = 'Credit Amount';
        RunningTotalCaption = 'Progr. Total';
        EntrySourceCaption = 'Source';
        BalanceCaption = 'Balance';
        StartingBalanceCaption = 'Starting Balance';
        EndingBalanceCaption = 'Ending Balance';
    }

    trigger OnPreReport()
    var
        SubscrMgt: Codeunit "EOS EX001 Subscription";
    begin
        SubscrMgt.TestSubscription();
    end;

    var
        TempGLEntry: Record "G/L Entry" temporary;
        RunningTotal: Decimal;
        GlTok: Label 'G/L';
        SimGlTok: Label 'Sim. G/L';
        RunningTotalStart: Decimal;
        EntrySource: Text;
        IncludeSimGLEntries: Boolean;
}