tableextension 50100 "EOS046 ACL Agent Summary" extends "EOS108 AAL Agent Summary"
{
    fields
    {
        field(18123250; "EOS046 Total X Created by"; Integer)
        {
            Caption = '<CODE> created';
            FieldClass = FlowField;
            CalcFormula = count("EOS Purch. Request Header" where(SystemCreatedBy = field("User Security ID"))); //CHANGEME
        }
    }
}