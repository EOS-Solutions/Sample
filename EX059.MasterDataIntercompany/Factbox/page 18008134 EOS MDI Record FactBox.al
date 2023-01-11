page 18008134 "EOS MDI Record FactBox"
{
    Caption = 'Record FactBox (MDI)';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "EOS MDI Factbox Buffer";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Table ID", "Document Type", "No.", "Line No.", "Factbox Line No.");
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("Synchronization Message Text"; MessageText)
            {
                ShowCaption = false;
                ApplicationArea = All;
                StyleExpr = MessageTextStyle;
                ToolTip = 'Specifies the value of the "MessageText" field.';
                trigger OnLookup(var Text: Text): Boolean
                begin
                    HandleClick();
                end;

                trigger OnDrillDown()
                begin
                    HandleClick();
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SynchOKAction)
            {
                Caption = 'Synch. OK';
                Enabled = ShowOKSynch;
                Image = Approval;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowOKSynch;
                ApplicationArea = All;
                PromotedOnly = true;
                ToolTip = 'Executes the "Synch. OK" action';

                trigger OnAction()
                begin
                    OpenEntries();
                end;
            }
            action(SynchFailedAction)
            {
                Caption = 'Synch. Errors';
                Enabled = ShowErrorSynch;
                Image = Warning;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowErrorSynch;
                ApplicationArea = All;
                PromotedOnly = true;
                ToolTip = 'Executes the "Synch. Errors" action';

                trigger OnAction()
                begin
                    OpenEntries();
                end;
            }
            action(ForceSynchAction)
            {
                Caption = 'Synchronize';
                Enabled = ShowForceSynch;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowForceSynch;
                ApplicationArea = All;
                ToolTip = 'Executes the "Synchronize" action';

                trigger OnAction()
                var
                    MDIManualSynchRoutines: Codeunit "EOS MDI Manual Synch. Routines";
                begin
                    if CurrRecRef.Find('=') then
                        if MDIManualSynchRoutines.ForceSynch(CurrRecRef) then
                            CurrPage.Update(false);
                end;
            }
            action(NotSynchronizableAction)
            {
                Caption = 'Not synchronizable';
                Enabled = NotSynchronizable;
                Image = Info;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = NotSynchronizable;
                ApplicationArea = All;
                ToolTip = 'Executes the "Not synchronizable" action';

                trigger OnAction()
                begin
                    Message(NotSynchronizableMsg);
                end;
            }
            action(SetupAction)
            {
                Caption = 'Setup';
                Enabled = ShowSetup;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowSetup;
                ApplicationArea = All;
                ToolTip = 'Executes the "Setup" action';

                trigger OnAction()
                var
                    MDIManualSynchRoutines: Codeunit "EOS MDI Manual Synch. Routines";
                begin
                    if CurrRecRef.Find('=') then
                        MDIManualSynchRoutines.ShowManualSynchronization(CurrRecRef, false);

                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        MoveVirtualRec();
        exit(true);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        MoveVirtualRec();
        exit(0);
    end;

    var
        CurrRecRef: RecordRef;
        ForcedRecRef: Boolean;
        NotSynchronizable: Boolean;
        ShowErrorSynch: Boolean;
        ShowForceSynch: Boolean;
        ShowOKSynch: Boolean;
        ShowSetup: Boolean;
        NotSynchronizableMsg: Label 'The synchronization module is not active or no valid synchronization profile has been found.';
        MessageText: Text;
        MessageTextStyle: Text;

    local procedure MoveVirtualRec()
    var
        MDIManualSynchRoutines: Codeunit "EOS MDI Manual Synch. Routines";
        MDISynchRoutines: Codeunit "EOS MDI Synch. Routines";
        Status: Text;
        ErrorLbl: Label 'Synchronization Error';
        OkLbl: Label 'Synchronized';
        DoSynchLbl: Label 'Synch. Pending';
        NotSynchronizableLbl: Label 'Not Synchronizable';
    begin
        if not ForcedRecRef then
            MDISynchRoutines.GetCurrentRecordRef(Rec, CurrRecRef);

        Status := MDISynchRoutines.GetCurrentRecordRefStatus(CurrRecRef);
        NotSynchronizable := Status in ['NOSETUP', 'NOLICENSE'];
        ShowErrorSynch := Status = 'ERRORS';
        ShowOKSynch := Status = 'OK';
        ShowForceSynch := Status = 'DOSYNCH';
        ShowSetup := not NotSynchronizable;
        if ShowSetup then
            ShowSetup := MDIManualSynchRoutines.ManualSynchAvailable(CurrRecRef);

        MessageText := '';
        MessageTextStyle := '';

        Case Status of
            'ERRORS':
                begin
                    MessageText := ErrorLbl;
                    MessageTextStyle := 'Attention';
                end;
            'OK':
                begin
                    MessageText := OkLbl;
                    MessageTextStyle := 'Favorable';
                end;
            'DOSYNCH':
                begin
                    MessageText := DoSynchLbl;
                    MessageTextStyle := 'Ambiguous';
                end;
            'NOSETUP',
            'NOLICENSE':
                begin
                    MessageText := NotSynchronizableLbl;
                    MessageTextStyle := '';
                end;
        end;

        if Rec.IsEmpty() then begin
            Rec.init();
            if Rec.Insert() then;
        end;
    end;

    procedure ForceCustomSourceRecord(SourceRecord: Variant)
    var
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        ForcedRecRef := true;
        DataTypeManagement.GetRecordRef(SourceRecord, CurrRecRef);
    end;

    local procedure OpenEntries()
    var
        MDISynchRoutines: Codeunit "EOS MDI Synch. Routines";
        EmptyGUID: Guid;
    begin
        MDISynchRoutines.OpenRecordSynchStatus(CurrRecRef, EmptyGUID);
    end;

    local procedure HandleClick()
    var
        MDISynchRoutines: Codeunit "EOS MDI Synch. Routines";
        MDIManualSynchRoutines: Codeunit "EOS MDI Manual Synch. Routines";
        Status: Text;
        NoLiceseErr: Label 'no valid license was found for the MDI app';
        NoSetupErr: Label 'No valid and active setup for synchronization.';
        SynchronizationOkMsg: Label 'Synchronization status is ok.';
    begin
        Status := MDISynchRoutines.GetCurrentRecordRefStatus(CurrRecRef);
        case Status of
            'NOLICENSE':
                Error(NoLiceseErr);
            'NOSETUP':
                Error(NoSetupErr);
            'OK':
                Message(SynchronizationOkMsg);
            'ERRORS':
                OpenEntries();
            'DOSYNCH':
                if CurrRecRef.Find('=') then
                    if MDIManualSynchRoutines.ForceSynch(CurrRecRef) then
                        CurrPage.Update(false);

        end;
    end;
}
