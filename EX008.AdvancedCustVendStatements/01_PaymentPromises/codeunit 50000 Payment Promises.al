codeunit 50000 "Payment Promises"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS AdvCustVendStat Engine", 'OnAfterAddLevel3Entries', '', false, false)]
    local procedure OnAfterAddLevel3Entries(var TempAssetsDetail: array[10] of Record "EOS Statem. Assets Detail EXT" temporary;
                                            var EntryNo: Integer;
                                            var AssetsBuffer: array[10] of Record "EOS Statem. Assets Buffer EXT";
                                            DateFilterType: Option "Posting Date","Document Date";
                                            StartingDate: Date;
                                            EndingDate: Date;
                                            PostingStartingDateFilter: Date;
                                            PostingEndingDateFilter: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Clear(GenJournalLine);
        // GenJournalLine.SetRange(Promised, true); //Adding as a table extension? 
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.SetRange("Account No.", AssetsBuffer[2]."EOS Source No.");
        GenJournalLine.SetRange("Applies-to Doc. Type", AssetsBuffer[2]."EOS Document Type"::Invoice);
        GenJournalLine.SetRange("Applies-to Occurrence No.", AssetsBuffer[2]."EOS Occurence No.");
        GenJournalLine.SetRange("Applies-to Doc. No.", AssetsBuffer[2]."EOS Document No.");
        GenJournalLine.SetRange("Document Type", GenJournalLine."Document Type"::Payment);

        if GenJournalLine.FindSet() then
            repeat
                EntryNo += 1;
                Clear(AssetsBuffer[3]);
                AssetsBuffer[3].Init();
                AssetsBuffer[3]."EOS Level No." := 3;
                AssetsBuffer[3]."EOS Source Type" := AssetsBuffer[2]."EOS Source Type";
                AssetsBuffer[3]."EOS Source No." := AssetsBuffer[2]."EOS Source No.";
                AssetsBuffer[3]."EOS Entry No." := EntryNo;
                AssetsBuffer[3]."EOS Level 1 Node" := AssetsBuffer[1]."EOS Entry No.";
                AssetsBuffer[3]."EOS Level 2 Node" := AssetsBuffer[2]."EOS Entry No.";
                AssetsBuffer[3]."EOS Level 3 Node" := AssetsBuffer[3]."EOS Entry No.";
                AssetsBuffer[3]."EOS Node Linked To" := AssetsBuffer[2]."EOS Entry No.";

                AssetsBuffer[3]."EOS Document Date" := GenJournalLine."Document Date";
                AssetsBuffer[3]."EOS Posting Date" := GenJournalLine."Posting Date";
                AssetsBuffer[3]."EOS Document Type" := AssetsBuffer[3]."EOS Document Type"::Payment;
                AssetsBuffer[3]."EOS Description" := 'PromisedPaymentText';
                AssetsBuffer[3]."EOS Document No." := GenJournalLine."Document No.";
                AssetsBuffer[3]."EOS Occurence No." := GenJournalLine."Applies-to Occurrence No.";
                AssetsBuffer[3]."EOS External Document No." := GenJournalLine."External Document No.";
                AssetsBuffer[3]."EOS Due Date" := GenJournalLine."Due Date";
                AssetsBuffer[3]."EOS Applied Amount" := GenJournalLine.Amount;
                AssetsBuffer[3]."EOS Applied Amount (LCY)" := GenJournalLine."Amount (LCY)";
                AssetsBuffer[3]."EOS Original Amount" := GenJournalLine.Amount;
                AssetsBuffer[3]."EOS Original Amount (LCY)" := GenJournalLine."Amount (LCY)";
                AssetsBuffer[3]."EOS Remaining Amount" := 0;
                AssetsBuffer[3]."EOS Remaining Amount (LCY)" := 0;
                AssetsBuffer[3]."EOS Payment Method" := GenJournalLine."Payment Method Code";
                // AssetsBuffer[3]."EOS Promised Payment" := true; //Adding as a table extension? 

                AssetsBuffer[2]."EOS Remaining Amount" += GenJournalLine.Amount;
                AssetsBuffer[2]."EOS Remaining Amount (LCY)" += GenJournalLine."Amount (LCY)";
                AssetsBuffer[2]."EOS Bank Receipt Status" := AssetsBuffer[3]."EOS Bank Receipt Status";
                AssetsBuffer[2]."EOS Customer Bill No." := AssetsBuffer[3]."EOS Customer Bill No.";
                // AssetsBuffer[2]."Promised Payment" := true; //Adding as a table extension? 
                AssetsBuffer[2].Modify();

                // AssetsBuffer[1]."Promised Payment" := true; //Adding as a table extension? 
                AssetsBuffer[1].Modify();

                AssetsBuffer[3].Insert();

            until GenJournalLine.Next() = 0;
    end;
}