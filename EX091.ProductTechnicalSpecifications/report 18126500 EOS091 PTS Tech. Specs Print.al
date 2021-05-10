report 18126500 "EOS091 PTS Tech. Specs Print"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Source/Report/report 18126500 EOS091 PTS Tech. Specs Print.rdl';
    UsageCategory = None;

    dataset
    {
        dataitem("EOS091 PTS Technical Specs"; "EOS091 PTS Technical Specs")
        {
            DataItemTableView = sorting("No.") order(ascending);
            column(No_; "No.")
            {
            }
            column(Description; "Description")
            {
                IncludeCaption = true;
            }
            column(EAN_Code; "EAN Code")
            {
                IncludeCaption = true;
            }
            column(ITF_Code; "ITF Code")
            {
                IncludeCaption = true;
            }
            column(Tariff_No_; "Tariff No.")
            {
                IncludeCaption = true;
            }
            column(SystemModifiedAt; "Last Date Modified")
            {
            }

            dataitem("EOS091 PTS Group Template"; "EOS091 PTS Group Template")
            {
                DataItemLink = "Template No." = field("Specs Template No.");
                DataItemTableView = sorting("Position") order(ascending);

                column(Group_Code; "Group Code")
                {
                }
                column(Group_Description; GroupDescription)
                {
                }
                column(Group_Position; Position)
                {
                }

                dataitem("Item Attribute Value Mapping"; "Item Attribute Value Mapping")
                {
                    DataItemLink = "EOS091 Group Code" = field("Group Code");
                    DataItemTableView = sorting("EOS091 Position") order(ascending) where("EOS091 Print" = const(true));

                    column(ItemAttributeText; ItemAttributeText)
                    {
                    }
                    column(ItemAttributeValueText; ItemAttributeValueText)
                    {
                    }
                    column(Position; "EOS091 Position")
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange("Table ID", Database::"EOS091 PTS Technical Specs");
                        SetRange("No.", "EOS091 PTS Technical Specs"."No.");
                    end;

                    trigger OnAfterGetRecord()
                    var
                        ItemAttribute: Record "Item Attribute";
                        ItemAttributeValue: Record "Item Attribute Value";
                        AttributeMgt: Codeunit "EOS091 PTS Attribute Mgt.";
                        UoMTxt: Label '%1 (%2)';
                    begin
                        ItemAttribute.Get("Item Attribute ID");
                        ItemAttributeText := ItemAttribute.GetTranslatedName(LanguageID);
                        if "EOS091 Unit of Measure" <> '' then
                            ItemAttributeText := StrSubstNo(UoMTxt, ItemAttributeText, "EOS091 Unit of Measure");

                        if ItemAttribute."Type" = ItemAttribute."Type"::"Text" then
                            ItemAttributeValueText := AttributeMgt.GetTranslatedName("EOS091 PTS Technical Specs"."No.",
                                                            "Item Attribute ID", "Item Attribute Value ID", LanguageID)
                        else begin
                            ItemAttributeValue.Get("Item Attribute ID", "Item Attribute Value ID");
                            ItemAttributeValueText := ItemAttributeValue.GetTranslatedName(LanguageID);
                        end;

                        if "EOS091 Tolerance" <> '' then
                            ItemAttributeValueText := StrSubstNo(UoMTxt, ItemAttributeValueText, "EOS091 Tolerance");
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    AttributeGroup: Record "EOS091 PTS Group";
                begin
                    AttributeGroup.Get("Group Code");
                    GroupDescription := AttributeGroup.GetTranslatedName(LanguageID);
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(EOSLanguageCode; LanguageCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Language Code';
                        TableRelation = Language.Code;
                        ToolTip = 'Specifies the language the report should be printed in.';
                    }
                }
            }
        }
    }

    labels
    {
        ReportTitle = 'Product Technical Specs';
        TechSpecsNo = 'Technical Specs No.';
        LastDateModified = 'Last Date Modified';
    }

    var
        LanguageCode: Code[10];
        LanguageID: Integer;
        GroupDescription: Text;
        ItemAttributeText: Text;
        ItemAttributeValueText: Text;

    trigger OnPreReport()
    var
        Language: Record Language;
    begin
        if LanguageCode <> '' then begin
            LanguageID := Language.GetLanguageId(LanguageCode);
            CurrReport.Language := LanguageID;
        end;
    end;
}