page 50100 "EOS004 DB TestPage"
{

    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Integer;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                field(ServiceConfigCodeField; ServiceConfigCode)
                {
                    Caption = 'Service Config. Code', Locked = true;
                    TableRelation = "EOS004 Service Config.".Code;
                    ApplicationArea = All;
                }
                field(DbConfigCodeField; DbConfigCode)
                {
                    Caption = 'DB Config. Code', Locked = true;
                    TableRelation = "EOS004 DB Connection Setup".Code;
                    ApplicationArea = All;
                }
                field(CommandTextField; CommandText)
                {
                    Caption = 'Command Text', Locked = true;
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
            repeater(Main)
            {
                field(Field1Field; FieldValue[1])
                {
                    CaptionClass = '' + GetCaption(1);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field2Field; FieldValue[2])
                {
                    CaptionClass = '' + GetCaption(2);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field3Field; FieldValue[3])
                {
                    CaptionClass = '' + GetCaption(3);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field4Field; FieldValue[4])
                {
                    CaptionClass = '' + GetCaption(4);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field5Field; FieldValue[5])
                {
                    CaptionClass = '' + GetCaption(5);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field6Field; FieldValue[6])
                {
                    CaptionClass = '' + GetCaption(6);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field7Field; FieldValue[7])
                {
                    CaptionClass = '' + GetCaption(7);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field8Field; FieldValue[8])
                {
                    CaptionClass = '' + GetCaption(8);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field9Field; FieldValue[9])
                {
                    CaptionClass = '' + GetCaption(9);
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Field10Field; FieldValue[10])
                {
                    CaptionClass = '' + GetCaption(10);
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ExecuteDataReader)
            {
                ApplicationArea = All;
                Caption = 'Execute DataReader';

                trigger OnAction();
                begin
                    TestDataReader();
                end;
            }
            action(ExecuteNonQuery)
            {
                ApplicationArea = All;
                Caption = 'Execute NonQuery';

                trigger OnAction();
                begin
                    TestNonQuery();
                end;
            }
        }
    }

    var
        DbConfigCode, ServiceConfigCode : Code[20];
        Columns: List of [Text];
        FieldValue: array[10] of Text;
        CommandText: Text;
        Rows: List of [JsonArray];

    trigger OnAfterGetRecord()
    var
        i: Integer;
        Row: JsonArray;
        jt: JsonToken;
    begin
        Clear(FieldValue);
        if (not Rows.Get(Rec.Number, Row)) then exit;
        for i := 1 to ArrayLen(FieldValue) do
            if Row.Get(i - 1, jt) then
                if (jt.IsValue() and (not jt.AsValue().IsNull())) then
                    FieldValue[i] := jt.AsValue().AsText();
    end;

    local procedure GetCaption(Index: Integer): Text
    var
        FieldName: Text;
    begin
        if (Columns.Get(Index, FieldName)) then
            exit(FieldName);
        exit('');
    end;

    local procedure TestDataReader()
    var
        DbConnSetup: Record "EOS004 DB Connection Setup";
        cl: Codeunit "EOS004 DB API Client";
        ResultSet: Codeunit "EOS004 DB ResultSet";
        ConnectionId: Guid;
    begin
        // Read the database configuration
        DbConnSetup.Get(DbConfigCode);

        // Configure the client using the service connection
        cl.Initialize(ServiceConfigCode);
        // Create a DB connection using the selected DB connection setup
        cl.CreateConnection(DbConnSetup, ConnectionId);
        // Execute a query that creates a resultset for reading date
        cl.ExecuteReader(ConnectionId, CommandText, ResultSet);
        // Get the names of the columns from the dataset
        Columns := ResultSet.Columns();

        // We read 2 records at a time from the API
        // This is for performance/latency reasons only. The ResultSet codeunit automatically pages and makes requests
        // as required.
        ResultSet.BatchSize(2);

        Clear(Rows);
        Rec.DeleteAll();
        Rec.Number := 0;
        while (ResultSet.Read()) do begin
            Rec.Number += 1;
            Rec.Insert();
            Rows.Add(ResultSet.Row());
        end;

        // Close the data reader.
        // This is kind of optional.
        // An open data reader will automatically be closed when all rows have been reader.
        // Also all data readers that are older than 5min will automatically be closed on the API.
        ResultSet.Close();

        // Close the connectoon.
        // This is kind of optional.
        // All connections that are older than 5min will automatically be closed on the API.
        cl.CloseConnection(ConnectionId);
    end;

    local procedure TestNonQuery()
    var
        DbConnSetup: Record "EOS004 DB Connection Setup";
        cl: Codeunit "EOS004 DB API Client";
        ConnectionId: Guid;
        AffectedRows: Integer;
    begin
        // Read the database configuration
        DbConnSetup.Get(DbConfigCode);

        // Note that we are not explicitly calling "Initialize" here.
        // That's because if your "DB Connection Setup" has specified a "Service Config. Code", 'CreateConnection' will do that 
        // for you using the service config. code on the DB connection before creating the connection.
        cl.CreateConnection(DbConnSetup, ConnectionId);

        // Run the query as one with no resultset.
        cl.ExecuteNonQuery(ConnectionId, CommandText, AffectedRows);
        // Get the number of records that were affected.
        Message('%1 records affected', AffectedRows);

        // Close the connectoon.
        cl.CloseConnection(ConnectionId);
    end;

}