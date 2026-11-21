permissionset 50100 "<EOS0XX CODE> Agent"
{
    Assignable = true;
    IncludedPermissionSets = "EOS108 AAL Base", "<EOS0XX CODE>", SUPER;
    Permissions =
        codeunit "<EOS0XX CODE> Agent Delegation" = X,
        codeunit "<EOS0XX CODE> Agent Factory" = X,
        codeunit "<EOS0XX CODE> Agent Metadata" = X,
        codeunit "<EOS0XX CODE> Agent Utilities" = X,
        page "<EOS0XX CODE> Agent Setup" = X;
}