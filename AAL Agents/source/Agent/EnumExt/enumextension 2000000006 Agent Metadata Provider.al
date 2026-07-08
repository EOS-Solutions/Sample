enumextension 50101 "EOS EnumExt18123251" extends "Agent Metadata Provider" //2000000006
{
    value(18123250; "<EOS0XX CODE> Agent")
    {
        Caption = '<Name> Agent (EOS)';
        Implementation = IAgentFactory = "<EOS0XX CODE> Agent Factory", IAgentMetadata = "<EOS0XX CODE> Agent Metadata", IAgentTaskExecution = "EOS108 AAL Agent Task Exec.";

    }
}