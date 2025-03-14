/// <summary>
/// This codeunit contains examples of how to use the external configuration.
/// The steps are:
/// 1. Insert the characteristics with their values in the "EOS028 CFG Doc. Line Charac." table.
/// 2. Run the external configuration
/// 3. The Product Configurator creates the configuration tables
/// 4. The Product Configurator creates a new item or variant, wiht production BOM and routing.
/// 5. The Product Configurator deletes the configuration tables
/// 
/// The configuration tables are:
/// Record "EOS028 CFG Configurator Line"; is the header
/// Record "EOS028 CFG Config. Charac."; contains the characteristics and their values
/// Record "EOS028 CFG Conf. Charac. Value"; contains the possible values ​​that the characteristic can assume, according to the Relations of type "Filter".
/// </summary>
codeunit 60000 "EOS028 CFG External Config"
{
    trigger OnRun()
    var
        TempInputCharac: Record "EOS028 CFG Doc. Line Charac." temporary;
        TempOutputCharac: Record "EOS028 CFG Doc. Line Charac." temporary;
        TempInputCharac2: Record "EOS028 CFG Doc. Line Charac." temporary;
        TempOutputCharac2: Record "EOS028 CFG Doc. Line Charac." temporary;
        ConfigLine: Record "EOS028 CFG Configurator Line";
        CFGSetup: Record "EOS028 CFG Configurator Setup";
        NoSeries: Codeunit "No. Series";
        ConfiguratorMgt: Codeunit "EOS028 CFG Configurator Mgt.";
        NeutralItemNo: Code[20];
    begin
        CFGSetup.Get();
        // 1 Example: Run external configuration and create a new item
        ExtConfigNo := NoSeries.GetNextNo(CFGSetup."External Configuration Nos.", WorkDate());
        NeutralItemNo := 'PILLOW';

        //Save the characteristic with their values
        InsertCharac(TempInputCharac, NeutralItemNo, 'FABRIC', 'C');
        InsertCharac(TempInputCharac, NeutralItemNo, 'COLOR', '02');
        InsertCharac(TempInputCharac, NeutralItemNo, 'H', '40');
        InsertCharac(TempInputCharac, NeutralItemNo, 'L', '40');

        //Run the external configuration
        RunProductConfigExt(TempInputCharac, TempOutputCharac, NeutralItemNo, '');
        //the configuration tables have been deleted
        //end example


        // 2 Example
        //It's possible to save the configuration tables and then run the configuration at another time
        //with the guid and the EventSubscriber OnAfterMakeLineWithOutputCharac_ExtConfig_Process 
        //the configurator doesn't create a new item but only the configuration tables
        NewConfigID := CreateGuid();
        NeutralItemNo := 'PILLOW';
        ExtConfigNo := NoSeries.GetNextNo(CFGSetup."External Configuration Nos.", WorkDate());
        InsertCharac(TempInputCharac, NeutralItemNo, 'FABRIC', 'C');
        InsertCharac(TempInputCharac, NeutralItemNo, 'COLOR', '03');
        InsertCharac(TempInputCharac, NeutralItemNo, 'H', '50');
        InsertCharac(TempInputCharac, NeutralItemNo, 'L', '50');
        RunProductConfigExt(TempInputCharac, TempOutputCharac, NeutralItemNo, '');

        // Then with the "ExtConfigNo" you can run the configuration at another time
        Clear(NewConfigID); //clear it to unlock the configuration
        ConfigLine.Get(0, ExtConfigNo, 0, '001');
        ConfiguratorMgt.SaveDocLineCharacFromConfigCharac(ConfigLine); //it is similar to the procedure InsertCharac
        RunProductConfigExt(TempInputCharac2, TempOutputCharac2, NeutralItemNo, '');
        // the configuration tables have been deleted
        // then delete the Record "EOS028 CFG Doc. Line Charac."
        ConfiguratorMgt.DeleteDocCharacTable(Enum::"EOS028 CFG Source Type"::"External Configuration".AsInteger(), 0, ExtConfigNo, 0);
        //end example
    end;

    var
        ExtConfigNo: Code[20];
        NewConfigID: Guid;

    local procedure RunProductConfigExt(var InputCharac: Record "EOS028 CFG Doc. Line Charac."; var OutputCharac: Record "EOS028 CFG Doc. Line Charac."; NeutralItemNo: Code[20]; VariantCode: Code[10])
    var
        Item: Record "Item";
        BatchItemConfig: Codeunit "EOS028 CFG Batch Item Config.";
        ExternalConfig: Codeunit "EOS028 CFG External Config.";
        NewItemNo: Code[20];
        NewCode: Code[10];
    begin
        BatchItemConfig.SetTable(InputCharac);

        Commit();

        Item.Get(NeutralItemNo);

        ExternalConfig.SetOutputCharac(NewConfigID, OutputCharac);
        ExternalConfig.SetParameters(ExtConfigNo, Item."No.", VariantCode);
        if ExternalConfig.Run() then begin
            NewItemNo := ExternalConfig.GetGeneratedItemNo();
            // ExternalConfig.GetGeneratedVariantCode(NewItemNo, NewCode);  //for variant

            //it's possible to skip the deletion of the configuration tables after the creation of the new item
            //ExternalConfig.SetSkipDeleteCharacTablesExternalConfig(true);
            ExtConfigNo := ExternalConfig.GetExtConfigNo();
            Message('%1', ExtConfigNo);
        end
        else
            Message(GetLastErrorText());
    end;

    local procedure InsertCharac(var TempDocLineCharac: Record "EOS028 CFG Doc. Line Charac."; NeutralItemNo: Code[20]; CharacCode: Code[10]; CharacValue: Code[50])
    var
        Characteristic: Record "EOS028 CFG Characteristic";
    begin
        Characteristic.Get(CharacCode);

        TempDocLineCharac.Init();
        TempDocLineCharac."Source Type" := TempDocLineCharac."Source Type"::"External Configuration";
        TempDocLineCharac."Document No." := ExtConfigNo;
        TempDocLineCharac."Item No." := NeutralItemNo;
        TempDocLineCharac."Characteristic Code" := Characteristic.Code;
        TempDocLineCharac."Characteristic Value" := CharacValue;
        TempDocLineCharac.CalcFields("Decoding Type");
        TempDocLineCharac."Characteristic Value" := GetNewValueXMLFormat(TempDocLineCharac);
        if Characteristic."Decoding Type" = Characteristic."Decoding Type"::Measure then
            evaluate(TempDocLineCharac."Numeric Value", CharacValue);
        TempDocLineCharac.Insert();
    end;

    local procedure GetNewValueXMLFormat(DocLineCharac: Record "EOS028 CFG Doc. Line Charac."): Code[50]
    begin
        if DocLineCharac."Decoding Type" <> DocLineCharac."Decoding Type"::Measure then
            exit(DocLineCharac."Characteristic Value");

        exit(Format(DocLineCharac."Numeric Value", MaxStrLen(DocLineCharac."Characteristic Value"), 1));
    end;


    [EventSubscriber(Objecttype::Codeunit, Codeunit::"EOS028 CFG Configurator Mgt.", 'OnAfterMakeLineWithOutputCharac_ExtConfig_Process', '', false, false)]
    local procedure T18091261_OnAfterMakeLineWithOutputCharac_Process(ConfigID: Guid; var StopConfig: Boolean)
    begin
        //Stop the configuration if there is a guid, but save the configuration tables
        StopConfig := not ISNULLGUID(ConfigID);
    end;
}