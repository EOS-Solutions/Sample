codeunit 50100 HandlebarsTest
{

    Subtype = Test;

    var
        ServiceConfig: Record "EOS004 Service Config.";
        jh: Codeunit "EOS JSON Helper";
        Assert: Codeunit Assert;
        ServiceConfigCode: Label 'TEST', Locked = true;

    [Test]
    procedure RenderFromSingleTemplate()
    var
        Handlebars: Codeunit "EOS004 Handlebars Renderer";
        Result: Text;
        Template: TextBuilder;
        Compr: Codeunit "Data Compression";
        Payload: JsonObject;
    begin
        // initialize the codeunit with a default service config 'TEST'
        ServiceConfig.Get(ServiceConfigCode);
        Handlebars.Initialize(ServiceConfig);

        // create the handlbars template
        Template.AppendLine('<h1>Hello {{CustomerName}}!</h1>');
        Template.AppendLine('<p>This is your order number {{No}}.</p>');
        Template.AppendLine('{{#each Lines}}');
        Template.AppendLine('  <li>{{ No }} - {{ Description }} - {{ Quantity }}</li>');
        Template.AppendLine('{{/each}}');

        // create the payload from a random sales order
        Payload := CreatePayload();

        // render the HTML
        Handlebars.Template(Template.ToText());
        Handlebars.Render(Payload, Result);

        // did it render correctly?
        Assert.IsTrue(Result.Contains('<h1>Hello ' + jh.GetText(Payload, 'CustomerName') + '!</h1>'), '');
    end;

    [Test]
    procedure RenderWithPartials()
    var
        Handlebars: Codeunit "EOS004 Handlebars Renderer";
        Result: Text;
        Template: TextBuilder;
        HeaderPartial, LinePartial : TextBuilder;
        Compr: Codeunit "Data Compression";
        Payload: JsonObject;
    begin
        // initialize the codeunit with a default service config 'TEST'
        ServiceConfig.Get(ServiceConfigCode);
        Handlebars.Initialize(ServiceConfig);

        // create a partial for the header
        HeaderPartial.AppendLine('<h1>Hello {{CustomerName}}!</h1>');
        HeaderPartial.AppendLine('<p>This is your order number {{No}}.</p>');
        Handlebars.SetPartial('header', HeaderPartial.ToText());

        // create a partial for the lines
        LinePartial.AppendLine('<li>{{ No }} - {{ Description }} - {{ Quantity }}</li>');
        Handlebars.SetPartial('line', LinePartial.ToText());

        // create the handlbars template
        Template.AppendLine('{{> header }}');
        Template.AppendLine('{{#each Lines}}');
        Template.AppendLine('{{> line }}');
        Template.AppendLine('{{/each}}');

        // create the payload from a random sales order
        Payload := CreatePayload();

        // render the HTML
        Handlebars.Template(Template.ToText());
        Handlebars.Render(Payload, Result);

        // did it render correctly?
        Assert.IsTrue(Result.Contains('<h1>Hello ' + jh.GetText(Payload, 'CustomerName') + '!</h1>'), '');
    end;

    local procedure CreatePayload() Result: JsonObject
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        jw: Codeunit "Json Text Reader/Writer";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.FindFirst();

        jw.WriteStartObject('');
        jw.WriteStringProperty('No', SalesHeader."No.");
        jw.WriteStringProperty('CustomerName', SalesHeader."Sell-to Customer Name");

        jw.WriteStartArray('Lines');
        if SalesLine.FindSet() then
            repeat
                jw.WriteStartObject('');
                jw.WriteStringProperty('No', SalesLine."No.");
                jw.WriteStringProperty('Description', SalesLine.Description);
                jw.WriteNumberProperty('Quantity', SalesLine.Quantity);
                jw.WriteEndObject();
            until SalesLine.Next() = 0;
        jw.WriteEndArray();
        jw.WriteEndObject();

        Result.ReadFrom(jw.GetJSonAsText());
    end;

}