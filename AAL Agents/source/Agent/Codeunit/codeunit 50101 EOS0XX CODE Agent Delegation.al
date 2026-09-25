codeunit 50101 "<EOS0XX CODE> Agent Delegation"
{
    // DO NOT EDIT

    var
        AgentUtilites: Codeunit "<EOS0XX CODE> Agent Utilities";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS108 AAL Agent Delegation", AgentSaveChanges, '', false, false)]
    local procedure "EOS108 AAL Setup_OnSaveAgentChanges"(var Setup: Record "EOS108 AAL Setup"; var AgentSetupBuffer: Record "Agent Setup Buffer"; var UserSecurityID: Guid; var IsHandled: Boolean)
    var
        AgentSetup: Codeunit "Agent Setup";
    begin
        if Setup."Agent Capability" = AgentUtilites.GetAgentCapability() then begin
            UserSecurityID := AgentSetup.SaveChanges(AgentSetupBuffer);
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS108 AAL Agent Delegation", AgentTaskCreate, '', false, false)]
    local procedure "EOS108 AAL Agent Delegation_OnCreateTask"(var Setup: Record "EOS108 AAL Setup"; var AgentTaskBuilder: Codeunit "Agent Task Builder"; var IsHandled: Boolean)
    begin
        if Setup."Agent Capability" = AgentUtilites.GetAgentCapability() then begin
            AgentTaskBuilder.Create();
            IsHandled := true;
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS108 AAL Agent Delegation", AgentTaskMessageCreate, '', false, false)]
    local procedure "EOS108 AAL Agent Delegation_OnCreateTaskMessage"(var Setup: Record "EOS108 AAL Setup"; var AgentTaskMessageBuilder: Codeunit "Agent Task Message Builder"; var AgentTaskMessage: Record "Agent Task Message"; var IsHandled: Boolean)
    begin
        if Setup."Agent Capability" = AgentUtilites.GetAgentCapability() then begin
            AgentTaskMessage := AgentTaskMessageBuilder.Create();
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS108 AAL Agent Delegation", AgentGetInstructions, '', false, false)]
    local procedure "EOS108 AAL Agent Delegation_OnGetInstructions"(Capability: Enum "Copilot Capability"; var Instructions: Text; var IsHandled: Boolean)
    begin
        if Capability = AgentUtilites.GetAgentCapability() then begin
            Instructions := NavApp.GetResourceAsText(AgentUtilites.GetAgentInstructionResourceName(), TextEncoding::UTF8);
            IsHandled := true;
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS108 AAL Agent Delegation", AgentSetOutputMessageSent, '', false, false)]
    local procedure "EOS108 AAL Agent Delegation_OnSetOutputMessageSent"(var Setup: Record "EOS108 AAL Setup"; var AgentTaskMessage: Record "Agent Task Message"; var IsHandled: Boolean)
    var
        AgentMessage: Codeunit "Agent Message";
    begin
        if Setup."Agent Capability" = AgentUtilites.GetAgentCapability() then begin
            AgentMessage.SetStatusToSent(AgentTaskMessage);
            IsHandled := true;
        end;
    end;

}