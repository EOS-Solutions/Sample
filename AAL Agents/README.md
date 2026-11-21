# ALProject5 - Agent Sample

This README documents only the sample project contained in `ALProject5`.

The project is a technical scaffold for building a custom Business Central agent capability. It is not production-ready as generated: several placeholders are still present, some example objects contain temporary logic, and a few files need completion before the app can be built and published.

## Purpose Of The Sample

Use this sample when you want to create an agent extension that:

- registers a custom `Copilot Capability`
- exposes a first-time setup page
- ships packaged default instructions with the extension
- allows custom instruction overrides from the setup page
- supports mailbox-based monitoring
- provides a default permission/profile scaffold
- includes sample summary objects that can be replaced with app-specific KPIs

## Project Contents

The sample is built from these main parts:

- `app.json`: application metadata, runtime, dependencies, and packaged resource folders
- `Instructions/AgentInstruction.md`: packaged default instructions
- `source/Agent/EnumExt/enumextension 2000000003 Copilot Capability.al`: custom capability declaration
- `source/Agent/EnumExt/enumextension 2000000006 Agent Metadata Provider.al`: wiring between the capability and implementation objects
- `source/Agent/Codeunit/codeunit 50100 EOS0XX CODE Agent Utilities.al`: central utility and default-value codeunit
- `source/Agent/Codeunit/codeunit 50101 EOS0XX CODE Agent Delegation.al`: delegation bridge
- `source/Agent/Codeunit/codeunit 50102 EOS0XX CODE Agent Factory.al`: factory implementation
- `source/Agent/Codeunit/codeunit 50103 EOS0XX CODE Agent Metadata.al`: metadata implementation
- `source/Agent/Page/page 50100 EOS0XX CODE Agent Setup.al`: agent setup dialog
- `source/Agent/PermissionSet/permissionset 50100 EOS0XX CODE Agent.al`: default permission-set scaffold
- `source/Agent/Profile/profile EOS0XX CODE Agent.al`: default profile scaffold
- `source/Agent/TableExt/tableextension  EOS108 AAL Agent Summary.al`: example summary field extension
- `source/Agent/PageExt/pageextension  EOS108 AAL Agent Summary.al`: example summary page extension

## High-Level Structure

The sample follows this internal flow:

1. the capability is declared in the enum extension
2. the metadata-provider enum maps the capability to the implementation objects
3. the factory and metadata codeunits expose the setup and UI contract
4. the delegation codeunit forwards runtime operations and loads packaged instructions
5. the setup page lets the user configure mailbox behavior and prompt overrides
6. the utilities codeunit centralizes names, defaults, and capability registration

## Files That Should Not Be Changed

The following three codeunits should remain structurally unchanged:

- `source/Agent/Codeunit/codeunit 50101 EOS0XX CODE Agent Delegation.al`
- `source/Agent/Codeunit/codeunit 50102 EOS0XX CODE Agent Factory.al`
- `source/Agent/Codeunit/codeunit 50103 EOS0XX CODE Agent Metadata.al`

They define the bridge between the sample capability and the runtime contracts.

Keep these responsibilities intact:

- `Agent Delegation` stays the delegation bridge and packaged-instruction loader
- `Agent Factory` stays the factory implementation and delegates defaults to `Agent Utilities`
- `Agent Metadata` stays the metadata implementation for setup, summary, and message pages

Allowed changes:

- consistent object renaming during placeholder replacement
- caption cleanup
- naming cleanup that preserves the same contract shape

Avoid:

- moving business logic into these files
- rewriting their responsibility split
- changing their role in the registration chain

## Primary Customization Surface

Most real implementation work belongs in the files below.

### `codeunit 50100 "<EOS0XX CODE> Agent Utilities"`

This is the main customization point. It centralizes:

- agent name
- agent initials
- display name
- summary text
- default permission set token
- default profile token
- instruction resource name
- learn-more URL
- setup page lookup
- summary page lookup
- capability lookup
- metadata-provider lookup
- capability registration

If you are adapting the sample, start here first.

### `Instructions/AgentInstruction.md`

This file contains the packaged default instructions shipped with the extension.

The file is included because `app.json` contains:

```json
"resourceFolders": [
  "Instructions"
]
```

Keep that entry if you want the default instructions to remain packaged with the app.

### `page 50100 "<EOS0XX CODE> Agent Setup"`

This page is the main configuration surface for the sample.

It currently exposes:

- incoming monitoring toggle
- mailbox selection
- mailbox folder selection
- attachment analysis toggle
- message limit
- custom instruction editing
- instruction source display
- prompt history access

When changing the page, preserve the core structure:

- keep it as a `ConfigurationDialog`
- keep the temporary setup flow intact
- keep the `User Security ID` flow intact
- keep the prompt editing controls wired correctly
- keep the final save path routed through the existing update logic

### Permission, Profile, And Summary Objects

These objects are scaffolds and are expected to be completed or replaced:

- `source/Agent/PermissionSet/permissionset 50100 EOS0XX CODE Agent.al`
- `source/Agent/Profile/profile EOS0XX CODE Agent.al`
- `source/Agent/TableExt/tableextension  EOS108 AAL Agent Summary.al`
- `source/Agent/PageExt/pageextension  EOS108 AAL Agent Summary.al`

The summary objects are example code only. Replace them with real app-specific KPIs and drill-down behavior, or remove them if you do not need them.

## Placeholder Replacement

Before the first real build, replace all occurrences of:

- `<EOS0XX CODE>`
- `<CODE>`
- `<Name>`
- `CHANGEME`

These placeholders appear in:

- object names
- captions
- labels
- permission and profile tokens
- instruction text
- summary text
- example drill-down logic
- URLs

Recommended order:

1. replace capability and agent naming placeholders
2. replace permission and profile tokens
3. replace the summary example logic
4. replace the packaged instruction content
5. add install and upgrade wiring for capability registration

## Required Cleanup Before First Build

The generated scaffold is not build-clean yet. Fix at least the following:

- `source/Agent/Codeunit/codeunit 50100 EOS0XX CODE Agent Utilities.al`: rename `AgentInstructionResourceName` to a valid AL label suffix such as `AgentInstructionResourceNameTok`
- `source/Agent/Codeunit/codeunit 50100 EOS0XX CODE Agent Utilities.al`: replace the placeholder initials so they fit inside `MaxLength = 4`
- `source/Agent/Page/page 50100 EOS0XX CODE Agent Setup.al`: rename the temporary `Agent Setup Buffer` variable with a `Temp` prefix
- `source/Agent/Page/page 50100 EOS0XX CODE Agent Setup.al`: add the missing page field tooltips
- `source/Agent/PermissionSet/permissionset 50100 EOS0XX CODE Agent.al`: replace the placeholder included permission set with a real one
- `source/Agent/Profile/profile EOS0XX CODE Agent.al`: provide a real `RoleCenter`
- `source/Agent/TableExt/tableextension  EOS108 AAL Agent Summary.al`: replace or remove the example field logic
- `source/Agent/PageExt/pageextension  EOS108 AAL Agent Summary.al`: replace or remove the example drill-down logic and invalid placeholder-based identifier

Treat these as required scaffold-completion steps.

## Capability Registration

`codeunit 50100 "<EOS0XX CODE> Agent Utilities"` already contains `RegisterAgentCapability()`.

The scaffold does not yet include the install AND upgrade object that calls it, so add one before publishing a working app.

Example install codeunit:

```al
codeunit 50104 "<EOS0XX CODE> Agent Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AgentUtilities: Codeunit "<EOS0XX CODE> Agent Utilities";
    begin
        AgentUtilities.RegisterAgentCapability();
    end;
}
```

If the app will be upgraded in existing environments, add the equivalent upgrade codeunit as well.

## How To Adapt The Sample

Use this sequence when converting the scaffold into a working implementation:

1. replace all placeholders
2. update `Agent Utilities`
3. write real instruction content in `Instructions/AgentInstruction.md`
4. complete the setup page details and missing tooltips
5. fix the permission set and profile
6. replace or remove the summary example
7. add capability-registration install and upgrade codeunits
8. build and publish


## Suggested Ownership Rules

Usually edit:

- `source/Agent/Codeunit/codeunit 50100 EOS0XX CODE Agent Utilities.al`
- `source/Agent/Page/page 50100 EOS0XX CODE Agent Setup.al`
- `Instructions/AgentInstruction.md`
- enum captions and placeholder names
- permission set, profile, and summary objects
- new install and upgrade codeunits

Usually do not edit:

- `source/Agent/Codeunit/codeunit 50101 EOS0XX CODE Agent Delegation.al`
- `source/Agent/Codeunit/codeunit 50102 EOS0XX CODE Agent Factory.al`
- `source/Agent/Codeunit/codeunit 50103 EOS0XX CODE Agent Metadata.al`
