codeunit 61200 "EXA04 Custom Fields"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnHeaderCustomFields', '', True, False)]
    local procedure OnHeaderCustomFields(var RBHeader: Record "EOS Report Buffer Header";
                                         HeaderRecRef: RecordRef;
                                         var TempAdvRptCustomFields: Record "EOS AdvRpt Custom Fields")
    begin
        if not TempAdvRptCustomFields.Get('CustomFieldLabel1') then begin
            TempAdvRptCustomFields.SetTextNameValue('CustomFieldLabel1', 'My Custom Label');
            TempAdvRptCustomFields.Insert(true);
            TempAdvRptCustomFields.SetTextNameValue('CustomFieldValue1', 'My Custom Value');
            TempAdvRptCustomFields.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS Advanced Reporting Mngt", 'OnLineCustomFields', '', false, true)]
    local procedure OnLineCustomFields(HeaderRecRef: RecordRef;
                                       CurrentLineRecRef: RecordRef;
                                       var RBHeader: Record "EOS Report Buffer Header";
                                       var RBLine: Record "EOS Report Buffer Line";
                                       var TempAdvRptCustomFields: Record "EOS AdvRpt Custom Fields")
    begin
        //same as Header custom fields:
        // column(CstmLneTxt1; LineLoop.GetCustomFieldTextValue('CustomText1')) { }
        // column(CstmLneTxt2; LineLoop.GetCustomFieldTextValue('CustomText2')) { }
        // column(CstmLneTxt3; LineLoop.GetCustomFieldTextValue('CustomText3')) { }
        // column(CstmLneTxt4; LineLoop.GetCustomFieldTextValue('CustomText4')) { }
        // column(CstmLneTxt5; LineLoop.GetCustomFieldTextValue('CustomText5')) { }
        // column(CstmLneTxt6; LineLoop.GetCustomFieldTextValue('CustomText6')) { }
        // column(CstmLneTxt7; LineLoop.GetCustomFieldTextValue('CustomText7')) { }
        // column(CstmLneTxt8; LineLoop.GetCustomFieldTextValue('CustomText8')) { }
        // column(CstmLneTxt9; LineLoop.GetCustomFieldTextValue('CustomText9')) { }
        // column(CstmLneTxt10; LineLoop.GetCustomFieldTextValue('CustomText10')) { }
        // column(CstmLneTxt11; LineLoop.GetCustomFieldTextValue('CustomText11')) { }
        // column(CstmLneTxt12; LineLoop.GetCustomFieldTextValue('CustomText12')) { }
        // column(CstmLneTxt13; LineLoop.GetCustomFieldTextValue('CustomText13')) { }
        // column(CstmLneTxt14; LineLoop.GetCustomFieldTextValue('CustomText14')) { }
        // column(CstmLneTxt15; LineLoop.GetCustomFieldTextValue('CustomText15')) { }
        // column(CstmLneTxt16; LineLoop.GetCustomFieldTextValue('CustomText16')) { }
        // column(CstmLneTxt17; LineLoop.GetCustomFieldTextValue('CustomText17')) { }
        // column(CstmLneTxt18; LineLoop.GetCustomFieldTextValue('CustomText18')) { }
        // column(CstmLneTxt19; LineLoop.GetCustomFieldTextValue('CustomText19')) { }
        // column(CstmLneTxt20; LineLoop.GetCustomFieldTextValue('CustomText20')) { }
        // column(CstmLneDec1; LineLoop.GetCustomFieldDecimalValue('CustomDecimal1')) { }
        // column(CstmLneDec2; LineLoop.GetCustomFieldDecimalValue('CustomDecimal2')) { }
        // column(CstmLneDec3; LineLoop.GetCustomFieldDecimalValue('CustomDecimal3')) { }
        // column(CstmLneDec4; LineLoop.GetCustomFieldDecimalValue('CustomDecimal4')) { }
        // column(CstmLneDec5; LineLoop.GetCustomFieldDecimalValue('CustomDecimal5')) { }
        // column(CstmLneInt1; LineLoop.GetCustomFieldIntegerValue('CustomInteger1')) { }
        // column(CstmLneInt2; LineLoop.GetCustomFieldIntegerValue('CustomInteger2')) { }
        // column(CstmLneInt3; LineLoop.GetCustomFieldIntegerValue('CustomInteger3')) { }
        // column(CstmLneInt4; LineLoop.GetCustomFieldIntegerValue('CustomInteger4')) { }
        // column(CstmLneInt5; LineLoop.GetCustomFieldIntegerValue('CustomInteger5')) { }        
        TempAdvRptCustomFields.SetTextNameValue('CustomText1', 'My Custom decimal');
        TempAdvRptCustomFields.Insert(true);

        TempAdvRptCustomFields.SetIntegerNameValue('CustomInteger1', 42);
        TempAdvRptCustomFields.Insert(true);

    end;
}