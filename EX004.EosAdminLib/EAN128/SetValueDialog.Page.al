page 50102 SetValueDialog
{

    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Options';

                field(DecimalValueField; DecimalValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Visible = DataType = DataType::Numeric;
                }
                field(DecimalPlacesField; DecimalPlaces)
                {
                    ApplicationArea = All;
                    Caption = 'Decimal Places';
                    Visible = DataType = DataType::Numeric;
                }
                field(DateValueField; DateValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Visible = DataType = DataType::Date;
                }
                field(TextValueField; TextValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Visible = DataType = DataType::"Alphanumeric Text";
                }
                field(NumericTextValueField; TextValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Visible = DataType = DataType::"Numeric Text";
                }
            }
        }
    }

    var
        DataType: Enum EOS004_EAN128DataType;
        DecimalPlaces, IntegerValue : Integer;
        DecimalValue: Decimal;
        DateValue: Date;
        TextValue: Text;

    procedure GetValue(): Variant
    begin
        case DataType of
            DataType::Numeric:
                exit(DecimalValue);
            DataType::Date:
                exit(DateValue);
            DataType::"Alphanumeric Text",
            dataType::"Numeric Text":
                exit(TextValue);
        end;
    end;

    procedure GetDecimalPlaces(): Integer
    begin
        exit(DecimalPlaces);
    end;

    procedure Initialize(NewDataType: Enum EOS004_EAN128DataType; NewValue: Text)
    begin
        DataType := NewDataType;
        TextValue := NewValue;
    end;

    procedure Initialize(NewValue: Decimal; NewDecimalPlaces: Integer)
    begin
        DataType := DataType::Numeric;
        DecimalValue := NewValue;
        DecimalPlaces := NewDecimalPlaces;
    end;

    procedure Initialize(NewValue: Date)
    begin
        DataType := DataType::Date;
        DateValue := NewValue;
    end;

}