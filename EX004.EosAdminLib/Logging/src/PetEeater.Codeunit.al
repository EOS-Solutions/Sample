codeunit 50200 PetEeater
{

    TableNo = Customer;


    var
        Logger: Codeunit "EOS004 App Logger";


    trigger OnRun()
    begin
        if not EatTheDogs(Rec) then exit;
        if not EatTheCats(Rec) then exit;
        EatThePets(Rec);
    end;


    local procedure EatTheDogs(Customer: Record Customer): Boolean
    var
        msg: Text;
    begin
        msg := StrSubstNo('%1 is eating the dogs.', Customer.Name);
        if not Confirm(msg) then exit(false);

        Logger.InitializeFromCaller('dogs');
        Logger.LogMessage('ETP001', msg);

        exit(true);
    end;

    local procedure EatTheCats(Customer: Record Customer): Boolean
    var
        msg: Text;
    begin
        msg := StrSubstNo('%1 is eating the cats.', Customer.Name);
        if not Confirm(msg) then exit(false);

        Logger.InitializeFromCaller('cats');
        Logger.LogMessage('ETP001', msg);

        exit(true);
    end;

    local procedure EatThePets(Customer: Record Customer): Boolean
    var
        pb: Codeunit "EOS004 Telem. Payload Builder";
        msg: Text;
    begin
        msg := StrSubstNo('%1 is eating the pets of the people that live there.', Customer.Name);
        Message(msg);

        Logger.InitializeFromCaller('pets');
        pb.Init();
        pb.Add('CustomerNo', Customer."No.");
        Logger.LogMessage('ETP001', msg, pb.Build());
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS004 App Logger", OnCollectLogCategories, '', false, false)]
    local procedure "EOS004 App Diag. Logger_OnCollectLogCategories"(AppId: Guid; var TempLogCategory: Record "EOS004 App Log Category" temporary)
    var
        mi: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mi);
        if (AppId <> mi.Id) then exit;

        TempLogCategory.Add(mi.Id, 'cats', 'Cats');
        TempLogCategory.Add(mi.Id, 'dogs', 'Dogs');
        TempLogCategory.Add(mi.Id, 'pets', 'Pets');
    end;

}