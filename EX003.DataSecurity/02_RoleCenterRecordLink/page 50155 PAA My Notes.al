page 50155 "EOS My Notes"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Record Link";
    Caption = 'My Notes';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(MyNotification)
            {
                field(Created; Created)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Notes; Notes)
                {
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        ShowLink();
                    end;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    Caption = 'Page';
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(Details)
    //         {
    //             ApplicationArea = All;
    //             Image = ViewDetails;
    //             trigger OnAction()
    //             begin
    //                 ShowLink();
    //             end;
    //         }
    //     }
    // }

    trigger OnOpenPage()
    begin
        SetRange("To User ID", UserId);
        SetRange(Notify, true);
        SetRange(Company, CompanyName);
    end;

    trigger OnAfterGetRecord()
    var
        RecLink: Record "Record Link";
        NoteText: BigText;
        iStream: InStream;
    begin
        CalcFields(Note);
        if Note.HasValue then begin
            clear(Notes);
            Note.CreateInStream(iStream);
            NoteText.Read(iStream);
            Notes := DelStr(Format(NoteText), 1, 1);
        end;
    end;

    local procedure ShowLink()
    var
        RecRef: RecordRef;
        RecVar: Variant;
    begin
        RecRef := "Record Id".GetRecord();
        RecVar := RecRef;
        Page.Run(0, RecVar);
    end;

    var
        Notes: Text;
}