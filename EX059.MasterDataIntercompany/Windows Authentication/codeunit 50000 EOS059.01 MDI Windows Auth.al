codeunit 50000 "EOS059.01 MDI Windows Auth"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"EOS MDI WebServices", 'OnWSAddAuthentication', '', false, false)]
    local procedure OnWSAddAuthentication(MDISynchCompanies: Record "EOS MDI Synch. Companies"; var client: HttpClient; var request: HttpRequestMessage; var handled: Boolean)
    var
        MDIAuthentications: Record "EOS MDI Authentications";
    begin
        if MDISynchCompanies.Type <> MDISynchCompanies.Type::WebService then exit;

        MDIAuthentications.Get(MDISynchCompanies."Authentication Code");

        client.UseWindowsAuthentication(
                MDIAuthentications."Server Username",
                MDIAuthentications.GetPassword(),
                MDIAuthentications."Server Domain");

        handled := true;
    end;
}