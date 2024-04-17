codeunit 50100 HowToTelemetry
{

    var
        OtherDict: Dictionary of [Text, Text];
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        otherApp: ModuleInfo;

    trigger OnRun()
    var
        Builder: Codeunit "EOS004 Telem. Payload Builder";
    begin
        // always call the Init() method before using the codeunit
        Builder.Init();

        // add a value by key and value
        Builder.Add('SomeKey', 'SomeValue');

        // add values from another dictionary
        Builder.Add(OtherDict);

        // add values from a name value buffer
        Builder.Add(TempNameValueBuffer);

        // add the current app as a caller
        // this is totally optional and adds the app name, publisher, version and ID as a prooerty to the telemetry set
        // note that these values are typically already added to every message by the service
        Builder.AddCaller();

        // add the given app as a caller
        // this is totally optional and adds the app name, publisher, version and ID as a prooerty to the telemetry set
        // note that these values are typically already added to every message by the service
        Builder.AddCaller(otherApp);

        Session.LogMessage(
            'EX???-00001', // specify a unique identifier for each event that you log
            'Fischers Fritz fischt frische Fische.', // specify a human-readable name for the event
            Verbosity::Normal, // specify the verbosity of the event. Remember (by default) only 'Normal' and above are logged. This depends on the configuration of the service.
            DataClassification::ToBeClassified, // specify a data classification
            TelemetryScope::All, // who receives the event? the service and the app publisher (=All) or only the app publisher (=ExtensionPublisher)
            Builder.Build() // build the telemetry set
        );
    end;

}