page 18123254 "EOS Purch. Request Cues"
{

    Caption = 'Purchase Request Cues';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = CardPart;
    SourceTable = "Purchase Cue";

    layout
    {
        area(content)
        {
            cuegroup("Purchase Requests")
            {
                Visible = AllVisible;
                Caption = 'Purchase Requests';
                field("All Open Purch. Requests"; Rec."EOS All Open Purch. Requests")
                {
                    Caption = 'Open';
                    DrillDownPageID = "EOS Purchase Request List";
                    ApplicationArea = all;
                }
                field("All Approved Purch. Requests"; Rec."EOS All Approved Purch. Req.")
                {
                    Caption = 'Approved';
                    DrillDownPageID = "EOS Purchase Request List";
                    ApplicationArea = all;
                }
                field("All Purch. Requests To Appr."; Rec."EOS All Purch. Req. To Appr.")
                {
                    Caption = 'To Approve';
                    ApplicationArea = all;
                }
            }
            cuegroup("My Purchase Requests")
            {
                Caption = 'My Purchase Requests';
                field("My Open Purch. Requests"; Rec."EOS My Open Purch. Requests")
                {
                    Caption = 'Open';
                    DrillDownPageID = "EOS Purchase Request List";
                    ApplicationArea = all;
                }
                field("My Approved Purch. Requests"; Rec."EOS My Approved Purch. Req.")
                {
                    Caption = 'Approved';
                    DrillDownPageID = "EOS Purchase Request List";
                    ApplicationArea = all;
                }
                field("My Purch. Requests To Appr."; Rec."EOS My Purch. Req. To Appr.")
                {
                    Caption = 'To Approve';
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        UserPersonalization: Record "User Personalization";
        Profile: Record "All Profile";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetRange("EOS User Filter", UserId());

        UserPersonalization.SetRange("User SID", UserSecurityId());
        if UserPersonalization.FindSet() then begin
            Profile.SetRange("Profile ID", UserPersonalization."Profile ID");
            if Profile.FindFirst() then begin
                if Profile."Role Center ID" in [9007, 9018, 18123263] then
                    AllVisible := true;
                if (Profile."Role Center ID" >= 50000) AND (Profile."Role Center ID" <= 99999) then
                    AllVisible := true;
            end;
        end;
    end;

    var
        AllVisible: Boolean;
}

