/// <summary>
/// Factory codeunit that implements the IAgentFactory interface to create and configure agent instances.
/// Provides metadata and configuration logic required during agent setup.
/// </summary>
/// <remarks>
/// Handles agent creation lifecycle, including initial setup pages and capability validation.
/// Integrates with Copilot Capability system for permission management and feature availability.
/// Used by the agent framework to instantiate and configure new agent instances.
/// </remarks>
codeunit 50102 "<EOS0XX CODE> Agent Factory" implements IAgentFactory
{
    // DO NOT EDIT
    Access = Internal;

    /// <summary>
    /// Returns the initials to be displayed on the icon triggering the agent setup.
    /// </summary>
    /// <returns>The initials.</returns>
    procedure GetDefaultInitials(): Text[4]
    begin
        exit(AgentUtilities.GetInitials());
    end;

    /// <summary>
    /// Returns the ID of the page that is used to configure the agent the first time.
    /// </summary>
    /// <remarks>
    /// The source table of the page must contain a field named "User Security ID" of type Guid.
    /// This field is used by the runtime to provide the agent user ID when the page is opened.
    /// </remarks>
    /// <returns>The first time setup page ID.</returns>
    procedure GetFirstTimeSetupPageId(): Integer
    begin
        exit(AgentUtilities.GetSetupPageId());
    end;

    /// <summary>
    /// Specifies whether the capability to create new agents should be shown in the UI.
    /// </summary>
    /// <remarks>
    /// This does not prevent new agents from being created programmatically.
    /// </remarks>
    /// <returns>True if the agent creation capability should be shown in the UI, false otherwise.</returns>
    procedure ShowCanCreateAgent(): Boolean
    begin
        exit(AgentUtilities.AllowCreateNewAgent());
    end;

    /// <summary>
    /// Returns the Copilot Capability value for the agent.
    /// The capability is used to determine whether agents of this type are allowed to run.
    /// </summary>
    /// <returns>The copilot capability value.</returns>
    procedure GetCopilotCapability(): Enum "Copilot Capability"
    begin
        exit(AgentUtilities.GetAgentCapability());
    end;

    /// <summary>
    /// Get the agent default profile used when a new agent is created.
    /// </summary>
    /// <param name="TempAllProfile">The default profile.</param>
    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        AgentUtilities.GetDefaultProfile(TempAllProfile);
    end;

    /// <summary>
    /// Get the agent default access controls to be used when a new agent is created.
    /// </summary>
    /// <param name="TempAccessControlTemplate">The default access controls.</param>
    procedure GetDefaultAccessControls(var TempAccessControlTemplate: Record "Access Control Buffer" temporary)
    begin
        AgentUtilities.GetDefaultAccessControls(TempAccessControlTemplate);
    end;

    var
        AgentUtilities: Codeunit "<EOS0XX CODE> Agent Utilities";
}