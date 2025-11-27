codeunit 50100 "EOS009 Cat Facts" implements "EOS009 ILayoutExtension"
{

    // This will be called automatically by ADR, once you register your layout extension to the enum
    procedure Register(var Section: Record "EOS Adv Reporting Sections");
    var
        DescriptionTxt: Label 'Print random cat facts after each line', MaxLength = 50;
    begin
        // Give your extension a code and a name.
        // Add also a help URL that explains how and what is done.
        Section.Init();
        Section."EOS Code" := 'FACTS';
        Section."EOS Description" := CopyStr(DescriptionTxt, 1, 50);
        Section."Help URL" := 'https://github.com/wh-iterabb-it/meowfacts/';

        // Decide where your section will be placed.
        // If you want your extension to be available on multiple positions, you must
        // insert one record into `Section` for each position.
        Section."EOS Position" := Section."EOS Position"::AfterLine;

        // Set if your extension is enabled by default and its default sorting.
        Section."EOS Default Enabled" := false;
        Section."EOS Default Sort" := 45000;

        // Set the handler that processes this section. This will most probably be the same enum/codeunit.
        Section."Handler" := Section.Handler::"Cat Facts";
        // Use 'CopyFromModuleInfoCaller' to copy some metadata from the current app to the section.
        Section.CopyFromModuleInfoCaller();
        Section.Insert(true);

        // for safety. there are other handlers around that don't Init the record properly and therefore this makes sure
        // that 'Handler' doesn't get propagated to other records.
        Clear(Section.Handler);
    end;

    // This will get called by ADR to let your handler do it's things.
    procedure Execute(Position: Enum "EOS AdvRpt Layout Position"; DocumentHeader: RecordRef; DocumentLine: RecordRef; var Header: Record "EOS Report Buffer Header"; var Line: Record "EOS Report Buffer Line")
    var
        rc: codeunit "EOS004 REST Client";
        IsAllowed: Enum "EOS066 TriState Boolean";
        obj: JsonObject;
        arr: JsonArray;
        jt: JsonToken;
    begin
        rc.BaseUri('https://meowfacts.herokuapp.com/');
        rc.Method('GET');
        rc.SendRequest('');
        rc.ThrowIfNotSuccessStatus();
        obj := rc.ResponseBodyAsJsonObject();
        arr := obj.GetArray('data');
        foreach jt in arr do begin
            // prepare the line
            Line.Init();
            Line."EOS Line No." := 0;
            Line."EOS Description" := CopyStr(jt.AsValue().AsText(), 1, MaxStrLen(Line."EOS Description"));

            // this is not strictly necessary, but useful because you can use this field on your layout
            // to identify the lines that have been created by your extension and print them accordingly.
            Line."Layout Extension" := Line."Layout Extension"::"Cat Facts";

            // insert the line
            Line.Appendline(Header);
        end;
    end;

}