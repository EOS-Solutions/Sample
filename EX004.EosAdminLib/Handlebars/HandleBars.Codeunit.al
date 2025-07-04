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

    [Test]
    procedure RenderFromMultiFileTemplate()
    var
        Handlebars: Codeunit "EOS004 Handlebars Renderer";
        Result: Text;
        MainTemplate: TextBuilder;
        Payload: JsonObject;
    begin
        // initialize the codeunit with a default service config 'TEST'
        ServiceConfig.Get(ServiceConfigCode);
        Handlebars.Initialize(ServiceConfig);

        // Load and set multiple template files as partials
        // In a real scenario, these would be loaded from actual files
        // Here we simulate loading from the template files we created
        Handlebars.SetPartial('header', GetHeaderTemplate());
        Handlebars.SetPartial('order-details', GetOrderDetailsTemplate());
        Handlebars.SetPartial('footer', GetFooterTemplate());

        // Load the main layout template
        MainTemplate.Append(GetLayoutTemplate());

        // create the payload with more comprehensive data
        Payload := CreateEnhancedPayload();

        // render the complete HTML document
        Handlebars.Template(MainTemplate.ToText());
        Handlebars.Render(Payload, Result);

        // validate the multi-file template rendered correctly
        Assert.IsTrue(Result.Contains('<!DOCTYPE html>'), 'Layout template should contain DOCTYPE');
        Assert.IsTrue(Result.Contains('<div class="header">'), 'Header partial should be included');
        Assert.IsTrue(Result.Contains('<div class="order-details">'), 'Order details partial should be included');
        Assert.IsTrue(Result.Contains('<div class="footer">'), 'Footer partial should be included');
        Assert.IsTrue(Result.Contains(jh.GetText(Payload, 'CompanyName')), 'Company name should be rendered');
        Assert.IsTrue(Result.Contains(jh.GetText(Payload, 'CustomerName')), 'Customer name should be rendered');
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

    local procedure CreateEnhancedPayload() Result: JsonObject
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CompanyInfo: Record "Company Information";
        jw: Codeunit "Json Text Reader/Writer";
        TotalAmount: Decimal;
    begin
        // Get company information
        CompanyInfo.Get();
        
        // Get a sales order
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.FindFirst();

        jw.WriteStartObject('');
        
        // Document properties
        jw.WriteStringProperty('DocumentTitle', 'Order Confirmation - ' + SalesHeader."No.");
        
        // Company information
        jw.WriteStringProperty('CompanyName', CompanyInfo.Name);
        jw.WriteStringProperty('CompanyAddress', CompanyInfo.Address + ', ' + CompanyInfo.City);
        jw.WriteStringProperty('CompanyPhone', CompanyInfo."Phone No.");
        
        // Order information
        jw.WriteStringProperty('OrderNumber', SalesHeader."No.");
        jw.WriteStringProperty('CustomerName', SalesHeader."Sell-to Customer Name");
        jw.WriteStringProperty('OrderDate', Format(SalesHeader."Order Date"));

        // Order lines with enhanced details
        jw.WriteStartArray('Lines');
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                jw.WriteStartObject('');
                jw.WriteStringProperty('No', SalesLine."No.");
                jw.WriteStringProperty('Description', SalesLine.Description);
                jw.WriteNumberProperty('Quantity', SalesLine.Quantity);
                jw.WriteStringProperty('UnitPrice', Format(SalesLine."Unit Price"));
                jw.WriteStringProperty('Amount', Format(SalesLine.Quantity * SalesLine."Unit Price"));
                TotalAmount += SalesLine.Quantity * SalesLine."Unit Price";
                jw.WriteEndObject();
            until SalesLine.Next() = 0;
        jw.WriteEndArray();
        
        // Total amount
        jw.WriteStringProperty('TotalAmount', Format(TotalAmount));
        
        jw.WriteEndObject();

        Result.ReadFrom(jw.GetJSonAsText());
    end;

    local procedure GetLayoutTemplate(): Text
    begin
        // In a real implementation, this would load from an actual file
        // This simulates the content of templates/layout.html
        exit('<!DOCTYPE html>' +
             '<html lang="en">' +
             '<head>' +
             '    <meta charset="UTF-8">' +
             '    <meta name="viewport" content="width=device-width, initial-scale=1.0">' +
             '    <title>{{DocumentTitle}}</title>' +
             '    <style>' +
             '        body { font-family: Arial, sans-serif; margin: 20px; }' +
             '        .header { background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 20px; }' +
             '        .content { margin: 20px 0; }' +
             '        .footer { background-color: #e9ecef; padding: 15px; border-radius: 5px; margin-top: 20px; text-align: center; }' +
             '        .order-lines { list-style-type: none; padding: 0; }' +
             '        .order-line { background-color: #f8f9fa; margin: 5px 0; padding: 10px; border-radius: 3px; }' +
             '    </style>' +
             '</head>' +
             '<body>' +
             '    {{> header}}' +
             '    <div class="content">' +
             '        {{> order-details}}' +
             '    </div>' +
             '    {{> footer}}' +
             '</body>' +
             '</html>');
    end;

    local procedure GetHeaderTemplate(): Text
    begin
        // In a real implementation, this would load from templates/header.html
        exit('<div class="header">' +
             '    <h1>{{CompanyName}}</h1>' +
             '    <h2>Order Confirmation</h2>' +
             '    <p><strong>Customer:</strong> {{CustomerName}}</p>' +
             '    <p><strong>Date:</strong> {{OrderDate}}</p>' +
             '</div>');
    end;

    local procedure GetOrderDetailsTemplate(): Text
    begin
        // In a real implementation, this would load from templates/order-details.html
        exit('<div class="order-details">' +
             '    <h3>Order #{{OrderNumber}}</h3>' +
             '    <p>Thank you for your order! Below are the details:</p>' +
             '    <h4>Order Lines:</h4>' +
             '    <ul class="order-lines">' +
             '        {{#each Lines}}' +
             '        <li class="order-line">' +
             '            <strong>{{No}}</strong> - {{Description}}' +
             '            <br>Quantity: {{Quantity}} | Unit Price: {{UnitPrice}} | Amount: {{Amount}}' +
             '        </li>' +
             '        {{/each}}' +
             '    </ul>' +
             '    <div style="text-align: right; margin-top: 20px;">' +
             '        <p><strong>Total Amount: {{TotalAmount}}</strong></p>' +
             '    </div>' +
             '</div>');
    end;

    local procedure GetFooterTemplate(): Text
    begin
        // In a real implementation, this would load from templates/footer.html
        exit('<div class="footer">' +
             '    <p>Thank you for your business!</p>' +
             '    <p>{{CompanyName}} | {{CompanyAddress}} | {{CompanyPhone}}</p>' +
             '    <p><small>This is an automatically generated document.</small></p>' +
             '</div>');
    end;

}