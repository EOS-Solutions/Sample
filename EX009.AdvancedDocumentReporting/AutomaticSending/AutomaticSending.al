codeunit 50100 AutomaticSending
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SomeCodeunit, 'SomeEvent', '', false, false)]
    procedure SomeEvent(var Item: Record "Item")
    var
        Item2: Record Item;
        RecRef: RecordRef;
        DefSetup: Codeunit "EOS AdvRpt Def Setup";
        AdvDocMgt: Codeunit "EOS AdvDoc Mngt";
        AdvRptDefaultSetup: Record "EOS AdvRpt Default Setup";
    begin
        Item2 := Item;
        Item2.SetRecFilter();
        RecRef.GetTable(Item2);
        RecRef.SetRecFilter();
        if DefSetup.GetDefaultDocumentSetup(RecRef, AdvRptDefaultSetup) then
            if AdvRptDefaultSetup."EOS Auto Send" = AdvRptDefaultSetup."EOS Auto Send"::Yes then
                AdvDocMgt.AddAsAsynchExecution(Item2);
    end;

}