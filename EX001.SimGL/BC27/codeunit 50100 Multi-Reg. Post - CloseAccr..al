codeunit 50100 "Multi-Reg. Post - CloseAccr."
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeUpdateAndDeleteLines', '', true, false)]
    local procedure C13_PostSimBalancing(
            var GenJournalLine: Record "Gen. Journal Line"
        )
    var
        GlReg: Record "G/L Register";
        LastGlReg: Record "G/L Register";
        SimGlMgt: Codeunit "EOS Sim. G/L Management";
    begin
        GenJournalLine.TestField("Line No.");
        LastGlReg.Get(GenJournalLine."Line No.");

        // When journal lines span multiple fiscal years, some localizations
        // (e.g., ES) split the posting into multiple consecutive G/L Registers.
        // Walk backward from the last register to find all registers that belong to
        // the same batch posting session: contiguous entry ranges + matching identity fields.
        GlReg.SetRange("No.", FindFirstBatchRegNo(LastGlReg, GenJournalLine), LastGlReg."No.");
        if GlReg.FindSet() then
            repeat
                SimGlMgt.PostSimBalancing(GlReg);
            until GlReg.Next() = 0;
    end;

    /// <summary>
    /// Walks backward from the last G/L Register to find the first register
    /// that belongs to the same batch posting session. A predecessor register
    /// qualifies only when ALL of the following hold:
    /// 1. G/L entry ranges are contiguous (prev "To Entry No." + 1 = next "From Entry No.")
    /// 2. Same Journal Batch Name as the originating journal line
    /// 3. Same Source Code as the last register
    /// 4. Same User ID as the last register
    /// 5. Same Creation Date as the last register
    /// </summary>
    local procedure FindFirstBatchRegNo(LastGlReg: Record "G/L Register"; GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        PrevGlReg: Record "G/L Register";
        NextGlReg: Record "G/L Register";
        FirstRegNo: Integer;
    begin
        FirstRegNo := LastGlReg."No.";
        NextGlReg := LastGlReg;

        while PrevGlReg.Get(FirstRegNo - 1) do begin
            // Entry ranges must be contiguous
            if (PrevGlReg."To Entry No." = 0) or (NextGlReg."From Entry No." = 0) then
                break;
            if PrevGlReg."To Entry No." + 1 <> NextGlReg."From Entry No." then
                break;
            // Must match the journal batch that originated the posting
            if PrevGlReg."Journal Batch Name" <> GenJournalLine."Journal Batch Name" then
                break;
            // Must share identity with the last register
            if PrevGlReg."Source Code" <> LastGlReg."Source Code" then
                break;
            if PrevGlReg."User ID" <> LastGlReg."User ID" then
                break;
            if PrevGlReg."Creation Date" <> LastGlReg."Creation Date" then
                break;

            FirstRegNo -= 1;
            NextGlReg := PrevGlReg;
        end;

        exit(FirstRegNo);
    end;
}