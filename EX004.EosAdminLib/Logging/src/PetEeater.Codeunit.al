codeunit 50200 PetEeater
{

    TableNo = Customer;

    // Just some sample code.
    trigger OnRun()
    begin
        if not EatTheDogs(Rec) then exit;
        if not EatTheCats(Rec) then exit;
        EatThePets(Rec);
    end;

    local procedure EatTheDogs(Customer: Record Customer): Boolean
    var
        Logger: Codeunit "EOS004 App Logger";
        msg: Text;
    begin
        msg := StrSubstNo('%1 is eating the dogs.', Customer.Name);
        if not Confirm(msg) then exit(false);

        // This will initialize the logger instance from the app calling it for the category 'cats'.
        Logger.InitializeFromCaller('dogs');
        // Emit the message to the log.
        Logger.LogMessage('ETP001', msg);
        // This will flush all logs to the destination.
        Logger.Flush();

        exit(true);
    end;

    local procedure EatTheCats(Customer: Record Customer): Boolean
    var
        Logger: Codeunit "EOS004 App Logger";
        msg: Text;
    begin
        msg := StrSubstNo('%1 is eating the cats.', Customer.Name);
        if not Confirm(msg) then exit(false);

        // This will initialize the logger instance from the app calling it for the category 'cats'.
        Logger.InitializeFromCaller('cats');
        // Set the autoflush limit to 1 to flush the log after each message.
        Logger.AutoFlushLimit(1);
        // emit the message to the log.
        // We don't need to call Flush() here, because the autoflush will do it for us.
        Logger.LogMessage('ETP001', msg);

        exit(true);
    end;

    local procedure EatThePets(Customer: Record Customer): Boolean
    var
        Logger: Codeunit "EOS004 App Logger";
        pb: Codeunit "EOS004 Telem. Payload Builder";
        msg: Text;
    begin
        msg := StrSubstNo('%1 is eating the pets of the people that live there.', Customer.Name);
        Message(msg);

        // This will initialize the logger instance from the app calling it for the category 'pets'.
        Logger.InitializeFromCaller('pets');
        // We're using the handy PayloadBuilder here to build a log payload dictionary for us.
        pb.Init();
        pb.Add('CustomerNo', Customer."No.");
        // Emit the message to the log.
        Logger.LogMessage('ETP001', msg, pb.Build());
        // This will flush all logs to the destination.
        Logger.Flush();
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS004 App Logger", OnCollectLogCategories, '', false, false)]
    local procedure "EOS004 App Diag. Logger_OnCollectLogCategories"(AppId: Guid; var TempLogCategory: Record "EOS004 App Log Category" temporary)
    var
        mi: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mi);
        if (AppId <> mi.Id) then exit;

        // Provide some categories that our app can log to.
        // We need to provide at least one category, otherwise the logger will not be configurable.
        TempLogCategory.Add(mi.Id, 'cats', 'Cats');
        TempLogCategory.Add(mi.Id, 'dogs', 'Dogs');
        TempLogCategory.Add(mi.Id, 'pets', 'Pets');
    end;

}