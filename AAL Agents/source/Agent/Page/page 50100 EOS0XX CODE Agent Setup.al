#pragma warning disable AL0906
page 50100 "<EOS0XX CODE> Agent Setup"
#pragma warning restore AL0906
{
    PageType = ConfigurationDialog;
    Extensible = false;
    IsPreview = true;
    SourceTable = "EOS108 AAL Setup";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Caption = 'Configure <Name> Agent';

    layout
    {
        area(Content)
        {
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }

            group(MonitorIncomingCard)
            {
                Caption = 'Monitor incoming information';

                field("Incoming Monitoring"; Rec."Incoming Monitoring")
                {
                    ApplicationArea = All;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        ConfigUpdated();
                    end;
                }
                group(MailboxGroup)
                {
                    Caption = 'Mailbox';

                    field("Email Monitoring"; Rec."Email Monitoring")
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                    }
                    field("Mailbox Name"; MailboxName)
                    {
                        ApplicationArea = All;
                        Caption = 'Account';
                        Editable = false;
                        ShowMandatory = true;

                        trigger OnAssistEdit()
                        begin
                            ACLSetupUI.AssistEditMailbox(Rec, MailboxName, MailboxChanged);
                            if MailboxChanged then begin
                                Clear(MailboxFolder);
                                ConfigUpdated();
                            end;
                            CurrPage.Update(true);
                        end;
                    }
                    field("Mailbox Folder"; MailboxFolder)
                    {
                        ApplicationArea = All;
                        Caption = 'Folder';
                        ToolTip = 'Specifies the email folder that the agent monitors. Leave empty to use the root inbox.';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            FolderChanged: Boolean;
                        begin
                            ACLSetupUI.AssistEditMailboxFolder(Rec, MailboxFolder, FolderChanged);
                            if FolderChanged then
                                ConfigUpdated();
                            CurrPage.Update(true);
                        end;
                    }
                    field("Analyze Attachments"; Rec."Analyze Attachments")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                    field("Message Limit"; Rec."Message Limit")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            ConfigUpdated();
                        end;
                    }
                    field("Last Sync At"; Rec."Last Sync At")
                    {
                        ApplicationArea = All;
                        Visible = ShowLastSync;
                        Editable = false;
                    }
                }
            }

            group(InstructionsGroup)
            {
                Caption = 'Agent behavior';

                group(FirstInstructionsGroup)
                {
                    Caption = 'Agent instructions';
                    InstructionalText = 'Use everyday words to describe what the agent should do.';

                    field(EditInstructions; EditInstructionsLbl)
                    {
                        Caption = 'Edit instructions';
                        ShowCaption = false;
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Open the instructions editor for the current custom prompt.';

                        trigger OnDrillDown()
                        begin
                            if ACLSetupUI.EditCustomPrompt(Rec."Agent Capability", Rec."User Security ID") then begin
                                UpdatePromptControls();
                                CurrPage.Update(false);
                            end;
                            ConfigUpdated();
                        end;
                    }

                    field(InstructionSource; InstructionSourceTxt)
                    {
                        ApplicationArea = All;
                        Caption = 'Source';
                        Editable = false;
                        ToolTip = 'Shows which instructions are currently active for the agent.';
                    }
                    group(VersionGroup)
                    {
                        ShowCaption = false;
                        Visible = HasCustomInstructions;

                        field(InstructionVersion; InstructionVersionTxt)
                        {
                            ApplicationArea = All;
                            Caption = 'Version';
                            Editable = false;
                            ToolTip = 'Shows the current version of the custom instructions.';
                        }

                        field(ViewPromptHistory; ViewPromptHistoryLbl)
                        {
                            Caption = 'View history';
                            ShowCaption = false;
                            ApplicationArea = All;
                            Editable = false;
                            ToolTip = 'View the history of instruction changes and restore an earlier version.';

                            trigger OnDrillDown()
                            var
                                CustomPrompts: Record "EOS108 AAL Custom Prompts";
                                PromptLog: Page "EOS108 AAL Prompt Log";
                            begin
                                if not CustomPrompts.Get(Rec."Agent Capability") then
                                    exit;

                                PromptLog.SetAgentCapability(Rec."Agent Capability");
                                PromptLog.RunModal();
                                if PromptLog.GetRestoredPreviousVersion() then begin
                                    UpdatePromptControls();
                                    CurrPage.Update(false);
                                end;
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(OK)
            {
                Caption = 'Update';
                Enabled = IsConfigUpdated;
                ToolTip = 'Apply the changes to the agent setup.';
            }
            systemaction(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Discards the changes and closes the setup page.';
            }
        }
    }

    var
        utils: Codeunit "<EOS0XX CODE> Agent Utilities";

    trigger OnOpenPage()
    var
        UserSecurityIDFilter: Text;
        UserSecurityID: Guid;
    begin
        if not AzureOpenAI.IsEnabled(utils.GetAgentCapability()) then
            Error(CapabilityNotEnabledErr);

        IsConfigUpdated := false;
        UserSecurityIDFilter := Rec.GetFilter("User Security ID");
        if not Evaluate(UserSecurityID, UserSecurityIDFilter) then
            Clear(UserSecurityID);

        CurrPage.AgentSetupPart.Page.Initialize(
            UserSecurityID,
            utils.GetAgentMetadataProvider(),
            utils.GetUsername(),
            utils.GetUserDisplayName(),
            utils.GetAgentSummary());
        UpdateAgentSetupBuffer();

        InitialState := AgentSetupBuffer.State;
        UpdateControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
        IsConfigUpdated := IsConfigUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateAgentSetupBuffer();
        IsConfigUpdated := IsConfigUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        UpdateAgentSetupBuffer();
        if AgentSetupBuffer.State = AgentSetupBuffer.State::Enabled then
            ACLSetupUI.ValidateBeforeSave(Rec, MailboxChanged, StateChanged());

        ACLSetupCU.UpdateAgent(AgentSetupBuffer, Rec, ShouldScheduleTask());
        exit(true);
    end;

    var
        AgentSetupBuffer: Record "Agent Setup Buffer";
        ACLSetupCU: Codeunit "EOS108 AAL Setup";
        ACLSetupUI: Codeunit "EOS108 AAL Setup UI";
        AzureOpenAI: Codeunit "Azure OpenAI";
        EditInstructionsLbl: Label 'Edit instructions';
        ViewPromptHistoryLbl: Label 'View history';
        HasCustomInstructions: Boolean;
        InstructionSourceTxt: Text;
        InstructionVersionTxt: Text;
        MailboxName: Text;
        MailboxFolder: Text;
        IsConfigUpdated: Boolean;
        ShowLastSync: Boolean;
        MailboxChanged: Boolean;
        InitialState: Option;
        CapabilityNotEnabledErr: Label 'The <Name> Agent capability is not enabled in Copilot capabilities.\\Please enable the capability before setting up the agent.';

    local procedure UpdateControls()
    begin
        if Rec.IsEmpty() or (Rec."User Security ID" <> AgentSetupBuffer."User Security ID") then begin
            ACLSetupCU.GetSetup(Rec, utils.GetAgentCapability(), AgentSetupBuffer."User Security ID");
            MailboxName := Rec."Email Address";
            MailboxFolder := Rec."Email Folder";
            ShowLastSync := Rec.CheckIsValidConfig() and (Rec."Last Sync At" <> 0DT);
        end;

        UpdatePromptControls();
    end;

    local procedure ConfigUpdated()
    begin
        IsConfigUpdated := true;
    end;

    local procedure UpdateAgentSetupBuffer()
    begin
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
    end;

    local procedure StateChanged(): Boolean
    begin
        exit((AgentSetupBuffer.State <> InitialState) or IsFirstConfig());
    end;

    local procedure ShouldScheduleTask(): Boolean
    begin
        exit((AgentSetupBuffer.State = AgentSetupBuffer.State::Enabled) and (StateChanged() or MailboxChanged));
    end;

    local procedure IsFirstConfig(): Boolean
    begin
        exit(IsNullGuid(Rec."User Security ID"));
    end;

    local procedure UpdatePromptControls()
    var
        CustomPrompts: Record "EOS108 AAL Custom Prompts";
    begin
        if Format(Rec."Agent Capability") = '' then begin
            Clear(InstructionSourceTxt);
            Clear(InstructionVersionTxt);
            HasCustomInstructions := false;
            exit;
        end;

        InstructionSourceTxt := ACLSetupCU.GetEffectivePromptSource(Rec."Agent Capability");
        HasCustomInstructions := ACLSetupCU.HasEnabledCustomPrompt(Rec."Agent Capability");

        if HasCustomInstructions then begin
            if CustomPrompts.Get(Rec."Agent Capability") then
                InstructionVersionTxt := CustomPrompts."Instructions Version"
            else
                Clear(InstructionVersionTxt);
        end else
            Clear(InstructionVersionTxt);
    end;
}