codeunit 50100 "<EOS0XX CODE> Agent Utilities"
{
    var
        AgentNameLbl: Label '<CODE> AGENT', MaxLength = 18;
        AgentInitialsLbl: Label '<CODE>', MaxLength = 4, Locked = true;
        DefaultDisplayNameLbl: Label '<Name> Agent (EOS)';
        AgentSummaryLbl: Label 'Monitors incoming emails for the agent and creates  X'; //CHANGEME
        DefaultPermissionSetTok: Label '<EOS0XX CODE> Agent', Locked = true, MaxLength = 20;
        DefaultProfileTok: Label '<EOS0XX CODE> Agent', Locked = true, MaxLength = 30;
        AgentInstructionResourceName: Label 'AgentInstruction.md', Locked = true;
        LearnMoreUrlTok: Label 'https://docs.eos-solutions.it/en/docs/apps-func/ex046-purchase-request.html', Locked = true; //CHANGEME


    internal procedure GetSetupPageId(): Integer
    begin
        exit(Page::"<EOS0XX CODE> Agent Setup");
    end;

    internal procedure GetSummaryPageId(): Integer
    begin
        exit(Page::"EOS108 AAL Agent Summary");
    end;

    internal procedure GetAgentCapability(): Enum "Copilot Capability"
    begin
        exit(Enum::"Copilot Capability"::"<EOS0XX CODE> Agent");
    end;

    internal procedure GetAgentMetadataProvider(): Enum "Agent Metadata Provider"
    begin
        exit(Enum::"Agent Metadata Provider"::"<EOS0XX CODE> Agent");
    end;


    internal procedure GetAgentInstructionResourceName(): Text
    begin
        exit(AgentInstructionResourceName);
    end;

    internal procedure GetUserDisplayName(): Text[80]
    begin
        exit(DefaultDisplayNameLbl);
    end;

    internal procedure GetUsername(): Text[50]
    begin
        exit(AgentNameLbl + ' - ' + CompanyName());
    end;

    internal procedure GetAgentSummary(): Text
    begin
        exit(AgentSummaryLbl);
    end;

    internal procedure GetInitials(): Text[4]
    begin
        exit(AgentInitialsLbl);
    end;

    internal procedure AllowCreateNewAgent(): Boolean
    var
        Setup: Record "EOS108 AAL Setup";
    begin
        Setup.SetRange("Agent Capability", GetAgentCapability());
        exit(Setup.IsEmpty());
    end;


    internal procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Agent.PopulateDefaultProfile(DefaultProfileTok, CurrentModuleInfo.Id, TempAllProfile);
    end;

    internal procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Clear(TempAccessControlBuffer);
        TempAccessControlBuffer."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TempAccessControlBuffer."Company Name"));
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer."App ID" := CurrentModuleInfo.Id;
        TempAccessControlBuffer."Role ID" := DefaultPermissionSetTok;
        TempAccessControlBuffer.Insert();
    end;

    internal procedure RegisterAgentCapability()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        CopilotCapability: Codeunit "Copilot Capability";
        mi: ModuleInfo;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;
        NavApp.GetCallerModuleInfo(mi);
        if CopilotCapability.IsCapabilityRegistered(GetAgentCapability()) then
            CopilotCapability.ModifyCapability(
                GetAgentCapability(),
                Enum::"Copilot Availability"::Preview,
                Enum::"Copilot Billing Type"::"Microsoft Billed",
                LearnMoreUrlTok)
        else
            CopilotCapability.RegisterCapability(
                GetAgentCapability(),
                Enum::"Copilot Availability"::Preview,
                Enum::"Copilot Billing Type"::"Microsoft Billed",
                LearnMoreUrlTok);
    end;

    var
        Agent: Codeunit Agent;
}