# Handlebars Multi-File Template Example

This example demonstrates how to use Handlebars with multiple template files to create a complete HTML document. The example shows a practical approach to organizing templates for better maintainability and reusability.

## Template Structure

The example uses a multi-file template approach with the following structure:

### 1. Main Layout Template (`templates/layout.html`)
- Contains the base HTML structure
- Includes CSS styling
- References other templates using partials (`{{> template-name}}`)

### 2. Header Template (`templates/header.html`)
- Company information and branding
- Order confirmation header
- Customer and date information

### 3. Order Details Template (`templates/order-details.html`)
- Order number and line items
- Detailed product information with quantities and prices
- Total amount calculation

### 4. Footer Template (`templates/footer.html`)
- Company contact information
- Thank you message
- Document generation notice

## Implementation Details

The AL codeunit `HandlebarsTest` demonstrates three different approaches:

### 1. Single Template (`RenderFromSingleTemplate`)
Basic template rendering with all content in one template string.

### 2. Simple Partials (`RenderWithPartials`)
Uses Handlebars partials to separate header and line templates.

### 3. Multi-File Template (`RenderFromMultiFileTemplate`)
**NEW**: Demonstrates a complete multi-file template approach:
- Loads multiple template files as partials
- Combines them into a complete HTML document
- Uses enhanced data payload with company information
- Produces a professional-looking order confirmation document

## Key Features

- **Separation of Concerns**: Each template file handles a specific part of the document
- **Reusability**: Templates can be reused across different document types
- **Maintainability**: Easy to update individual sections without affecting others
- **Professional Output**: Generates complete HTML documents with proper styling
- **Rich Data Binding**: Demonstrates complex data structures with nested objects and arrays

## Usage

The `RenderFromMultiFileTemplate` test method shows how to:

1. Initialize the Handlebars renderer
2. Load multiple template files as partials
3. Set the main layout template
4. Create a comprehensive data payload
5. Render the complete HTML document
6. Validate the output

## Data Structure

The enhanced payload includes:
- **Document Properties**: Title, date
- **Company Information**: Name, address, phone
- **Order Information**: Number, customer, date
- **Line Items**: Product details with pricing
- **Calculations**: Total amounts

This example provides a foundation for creating complex, multi-file template systems in Business Central using the EOS Handlebars integration.