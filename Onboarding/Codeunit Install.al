codeunit 70491923 "EOS055 Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InsertAssistedSetup();
    end;

    local procedure InsertAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        GuidedExperienceType: Enum "Guided Experience Type";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        Title1Txt: Label 'Set up Packing List (PCK)';
        SmallTitle1Txt: Label 'Set up Packing List (PCK)';
        Description1Txt: Label 'Follow along this guide to set up the Packing List.';
    begin
        //Assisted Setup
        if not GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"EOS055 ONB Packing List") then
            GuidedExperience.InsertAssistedSetup(
                Title1Txt,
                SmallTitle1Txt,
                Description1Txt,
                10,
                ObjectType::Page,
                Page::"EOS055 ONB Packing List",
                AssistedSetupGroup::"EOS PCK",
                '',
                VideoCategory::GettingStarted,
                'https://docs.eos-solutions.it/en/docs/apps-func/packing-list-pck.html');


        //Examples Tour and Learn and Remove() function
        if GuidedExperience.Exists(GuidedExperienceType::Tour, ObjectType::Page, Page::"EOS055 Packaging Setup") then
            GuidedExperience.Remove(GuidedExperienceType::Tour, ObjectType::Page, Page::"EOS055 Packaging Setup");
        GuidedExperience.InsertTour('Packaging Setup (PCK)', 'Packaging Setup (PCK)', 'Packaging Setup (PCK)', 2, Page::"EOS055 Packaging Setup");

        if GuidedExperience.Exists(GuidedExperienceType::Learn,
                    'https://docs.eos-solutions.it/en/docs/apps-func/packing-list-pck.html') then
            GuidedExperience.Remove(GuidedExperienceType::Learn, 'https://docs.eos-solutions.it/en/docs/apps-func/packing-list-pck.html');
        GuidedExperience.InsertLearnLink('Learn (PCK)', 'Learn (PCK)', 'Learn (PCK)',
                        10, 'https://docs.eos-solutions.it/en/docs/apps-func/packing-list-pck.html');

        //end Examples

        InsertChecklistItems();
    end;

    local procedure InsertChecklistItems()
    var
        TempProfile: Record "All Profile" temporary;
        UserPersonalization: Record "User Personalization";
        Checklist: Codeunit Checklist;
        GuidedExperienceType: Enum "Guided Experience Type";
        UserId: Code[30];
    begin
        Evaluate(UserId, Database.UserId());
        UserPersonalization.SetRange("User ID", UserId);
        if UserPersonalization.FindFirst() then
            if UserPersonalization."Profile ID" <> '' then
                AddRoleToList(TempProfile, UserPersonalization."Profile ID");

        AddRolesForEvaluationCompany(TempProfile);
        AddDefaultRoleCenter(TempProfile);

        Checklist.Insert(
            GuidedExperienceType::"Assisted Setup",
            ObjectType::Page,
            Page::"EOS055 ONB Packing List",
            550, //ID APP x 10
            TempProfile,
            false);


        //Examples Tour and Learn
        Checklist.Insert(GuidedExperienceType::Tour, ObjectType::Page, Page::"EOS055 Packaging Setup",
            551, TempProfile, false);

        Checklist.Insert(GuidedExperienceType::Learn,
            'https://docs.eos-solutions.it/en/docs/apps-func/packing-list-pck.html',
            552, TempProfile, false);

        //end Examples

        Checklist.SetChecklistVisibility(true);
    end;

    local procedure AddRoleToList(var TempAllProfile: Record "All Profile" temporary; ProfileID: Code[30])
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Profile ID", ProfileID);
        if AllProfile.FindFirst() then begin
            TempAllProfile.TransferFields(AllProfile);
            if not TempAllProfile.Insert() then;
        end;
    end;

    local procedure AddRolesForEvaluationCompany(var TempAllProfile: Record "All Profile" temporary)
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Role Center ID", Page::"Business Manager Role Center");
        if AllProfile.FindSet() then
            repeat
                TempAllProfile.TransferFields(AllProfile);
                if not TempAllProfile.Insert() then;
            until AllProfile.Next() = 0;
    end;

    local procedure AddDefaultRoleCenter(var TempAllProfile: Record "All Profile" temporary)
    var
        AllProfile: Record "All Profile";
    begin
        AllProfile.SetRange("Default Role Center", true);
        if AllProfile.FindSet() then
            repeat
                TempAllProfile.TransferFields(AllProfile);
                if not TempAllProfile.Insert() then;
            until AllProfile.Next() = 0;
    end;
}