codeunit 50201 PetEatersTest
{

    Subtype = Test;
    TestPermissions = Disabled;

    local procedure TotalEntries(): Integer
    begin
        exit(500);
    end;


    [Test]
    procedure WithActiveEosLogger()
    var
        Logger: Codeunit "EOS004 App Logger";
        i: Integer;
    begin
        // Initialize the logger for the calling app and a specific category
        Logger.InitializeFromCaller('dogs');
        // Instruct the logger to automatically flush the log messages to the log store after every 1000 messages
        Logger.AutoFlushLimit(1000);
        for i := 1 to TotalEntries() do begin
            // Log a message
            Logger.LogMessage('ETP001', 'msg');
        end;
        // Make sure to flush any remaining messages
        Logger.Flush();
    end;

    [Test]
    procedure WithInactiveEosLogger()
    var
        Logger: Codeunit "EOS004 App Logger";
        i: Integer;
    begin
        // Initialize the logger for the calling app and a category that does not exist.
        // Note that doing so will **not** throw an error, but will not log anything (= hence the "inactive" logger)
        Logger.InitializeFromCaller('dogsz');
        for i := 1 to TotalEntries() do begin
            Logger.LogMessage('ETP001', 'msg');
        end;
        Logger.Flush();
    end;

    [Test]
    procedure WithMicrosoftLogger()
    var
        i: Integer;
    begin
        for i := 1 to TotalEntries() do begin
            Session.LogMessage(
                'ETP001', 'msg',
                Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All,
                '', '');
        end;
    end;

    [Test]
    procedure WithoutAnyLogger()
    var
        i: Integer;
    begin
        for i := 1 to TotalEntries() do begin
            // do nothing
        end;
    end;

}