page 70491920 "EOS055 ONB Packing List"
{
    PageType = NavigatePage;
    SourceTable = "EOS055 Packaging Setup";
    Caption = 'Packing List Setup';
    ApplicationArea = all;
    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 1;
                group("Welcome")
                {
                    Caption = 'Welcome to the Packing List Assisted Setup';
                    group(group11)
                    {
                        Caption = '', Locked = true;
                        InstructionalText = 'We''re gonna set up default data to start using the Packing List.';
                    }

                    field(FollowThisGuide; FollowThisGuideTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            System.Hyperlink('https://docs.eos-solutions.it/en/docs/apps-func/packing-list-pck.html');
                        end;
                    }
                    field(CheckoutThisVideo; CheckoutThisVideoTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            System.Hyperlink('https://youtu.be/-o-ZBDblKlM');
                        end;
                    }

                    field(DemoVideo; DemoVideoTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            System.Hyperlink('https://youtu.be/-B7Sn10N-ZY');
                        end;
                    }
                }
                group("Let's go")
                {
                    Caption = 'Let''s go!';
                    group(group12)
                    {
                        Caption = '', Locked = true;
                        InstructionalText = 'Select Next to continue.';
                    }
                }
            }
            group(Step2)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 2;

                group(group21)
                {
                    Caption = 'Setup Wizard';
                    InstructionalText = 'Run the "New Setup Wizard" to create default data. It is recommended to use it in a Test Environment!';

                    field(NewSetupWizardLbl; NewSetupWizardLbl)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        var
                            NewSetupWizardQst: Label 'Do you want to run the Setup Wizard?\It is recommended to run it in a Test Environment!';
                            SetupWizardCompletedLbl: Label 'Setup wizard completed successfully!';
                        begin
                            if not Confirm(NewSetupWizardQst, false) then
                                exit;
                            SetupWizard.SetCreateSalesOrder(false);
                            SetupWizard.Run();
                            SetPackagingMaterialVisible();
                        end;
                    }

                    group(group22)
                    {
                        Caption = 'Create a Sales Order and the Packing List.';
                        Visible = SetupWizardCompleted;

                        field(NewSalesOrder; NewSalesOrderLbl)
                        {
                            ShowCaption = false;
                            Editable = false;
                            ApplicationArea = All;

                            trigger OnDrillDown()
                            var
                                SetupWizard: Codeunit "EOS055.01 Pack. Setup Wizard";
                                OrderNo: Code[20];
                                SalesOrdCompletedLbl: Label 'Sales Order %1 created successfully!', Comment = 'Sales Order No.';
                            begin
                                if not SetupWizardCompleted then
                                    Message('Please complete the Setup Wizard first!');

                                SalesOrdCreated := false;
                                SetupWizard.CreateSalesOrder(OrderNo, false);
                                if OrderNo <> '' then begin
                                    if SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo) then;
                                    SalesOrdCreated := true;
                                    Message(SalesOrdCompletedLbl, OrderNo);
                                end;
                            end;

                        }

                        group(group23)
                        {
                            ShowCaption = false;
                            Visible = SalesOrdCreated;
                            field(OpenSalesOrd; OpenSalesOrdLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = All;
                                Editable = false;

                                trigger OnDrillDown()
                                var
                                    HandlingUnitAssignment: Page "EOS055 Handling Units Assigned";
                                begin
                                    if SalesHeader."No." = '' then
                                        exit;
                                    Page.Run(Page::"Sales Order", SalesHeader);
                                    HandlingUnitAssignment.SetSourceDocument(SalesHeader);
                                    HandlingUnitAssignment.RunModal();
                                end;
                            }

                            field(PrintPackingList; PrintPackingListLbl)
                            {
                                ShowCaption = false;
                                ApplicationArea = All;
                                Editable = false;

                                trigger OnDrillDown()
                                var
                                    PackingListPrint: Codeunit "EOS055 Packing List Print";
                                begin
                                    if SalesHeader."No." <> '' then
                                        PackingListPrint.Print(SalesHeader);
                                end;
                            }
                        }
                    }
                }
            }

            group(Step3)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 3;

                group(group31)
                {
                    Caption = 'Step by Step';
                    InstructionalText = 'The Setup Wizard first sets the following fields in "Packaging Setup".';

                    field(PackagingSetupPage; PackagingSetupLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"EOS055 Packaging Setup");
                        end;
                    }

                    field("EOS055 Packing List Report No."; Rec."EOS055 Packing List Report No.")
                    {
                        ApplicationArea = All;
                        ToolTip = ' ', Locked = true;
                    }
                    field("Packaging Material Nos."; Rec."Packaging Material Nos.")
                    {
                        ApplicationArea = All;
                        ToolTip = ' ', Locked = true;
                    }
                    field("Packaging Instruction Nos."; Rec."Packaging Instruction Nos.")
                    {
                        ApplicationArea = All;
                        ToolTip = ' ', Locked = true;
                    }
                }
            }

            group(Step4)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 4;

                group(group41)
                {
                    Caption = 'Handling Unit Types';
                    group(group42)
                    {
                        Caption = 'Load Carrier (e.g. Pallet)';
                        InstructionalText = 'On the load carrier you can load packages and items.';
                        group(group43)
                        {
                            Caption = 'Package (e.g. Box)';
                            InstructionalText = 'On the packages you can load other packages and items.';
                        }
                    }

                }

                group(group44)
                {
                    Visible = SetupWizardCompleted;
                    Caption = 'Default Packaging Materials have been created';
                    field(PackMaterials; PackMaterialsLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"EOS055 Packaging Material List");
                        end;
                    }

                }
            }
            group(Step5)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 5;
                group(group51)
                {
                    Caption = 'Packaging Instructions';
                    InstructionalText = 'Define how items are packed into handling units.';
                    group(group52)
                    {
                        ShowCaption = false;
                        InstructionalText = 'The instructions are used to suggest the packing list for the document.';
                    }
                    field(PackInstruction; PackInstructionLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"EOS055 Packaging Instructions");
                        end;
                    }
                }
            }

            group(Step6)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 6;
                group(group61)
                {
                    Caption = 'Handling Units';
                    InstructionalText = 'Handling Units can be created from the packing list, from the journals and manually.';

                    field(ShowHandlingUnit; ShowHandlingUnitLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"EOS055 Handling Unit List");
                        end;
                    }
                }
            }
            group(Step7)
            {
                Caption = '', Locked = true;
                Visible = CurrentStep = 7;
                group(group71)
                {
                    Caption = 'Congrats!';
                    InstructionalText = 'You have finished this guide!';
                }
                group(group72)
                {
                    Caption = '', Locked = true;
                    InstructionalText = 'Click on the Finish button to complete this wizard.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Back)
            {
                ToolTip = 'Go back to the previous step';
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = ActionBackAllowed;
                InFooterBar = true;
                Image = PreviousRecord;
                trigger OnAction()
                begin
                    CurrentStep -= 1;
                    SetControls();
                    if CurrentStep = 2 then
                        SetPackagingMaterialVisible();
                end;
            }
            action(Next)
            {
                ToolTip = 'Procede with the next step';
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = ActionNextAllowed;
                InFooterBar = true;
                Image = NextRecord;
                trigger OnAction()
                begin
                    CurrentStep += 1;
                    SetControls();
                    if CurrentStep = 2 then
                        SetPackagingMaterialVisible();
                end;
            }
            action(Finish)
            {
                ToolTip = 'Finish this guide';
                Caption = 'Finish';
                ApplicationArea = All;
                Enabled = ActionFinishAllowed;
                InFooterBar = true;
                Image = Approve;
                trigger OnAction()
                var
                    GuidedExperience: Codeunit "Guided Experience";
                begin
                    GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"EOS055 ONB Packing List");
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrentStep := 1;
        SetControls();

        SetPackagingMaterialVisible();
    end;

    local procedure SetControls()
    begin
        ActionBackAllowed := CurrentStep > 1;
        ActionNextAllowed := CurrentStep < 7;
        ActionFinishAllowed := CurrentStep = 7;
    end;

    local procedure SetPackagingMaterialVisible()
    var
        PackagingInstruction: Record "EOS055 Packaging Instruction";
    begin
        SetupWizardCompleted := false;
        SetFilterPackagingInstruction(PackagingInstruction);
        if PackMaterialPallet.Get('PALLET01') and PackMaterialBOX.Get('BOX01') and (not PackagingInstruction.IsEmpty()) then
            SetupWizardCompleted := true;
    end;

    local procedure SetFilterPackagingInstruction(var PackagingInstruction: Record "EOS055 Packaging Instruction")
    begin
        PackagingInstruction.SetFilter("Item No.", '<>%1', '');
        PackagingInstruction.SetRange("Source Type", PackagingInstruction."Source Type"::Customer);
        PackagingInstruction.SetRange("Packaging Material No.", 'BOX01');
        PackagingInstruction.SetRange("Load Carrier No.", 'PALLET01');
        PackagingInstruction.SetRange(Quantity, 5);
        PackagingInstruction.SetRange("No. of Layers", 1);
        PackagingInstruction.SetRange("Qty. per Layer", 2);
        PackagingInstruction.SetRange(Disabled, false);
    end;


    var
        PackMaterialPallet: Record "EOS055 Packaging Material";
        PackMaterialBOX: Record "EOS055 Packaging Material";
        SalesHeader: Record "Sales Header";
        SetupWizard: Codeunit "EOS055.01 Pack. Setup Wizard";
        CurrentStep: Integer;
        ActionBackAllowed, ActionNextAllowed, ActionFinishAllowed : Boolean;
        SetupWizardCompleted: Boolean;
        SalesOrdCreated: Boolean;
        FollowThisGuideTxt: Label 'Follow this guide';
        CheckoutThisVideoTxt: Label 'Checkout this video';
        DemoVideoTxt: Label 'Video Demo';
        NewSetupWizardLbl: Label 'New Setup Wizard';
        PackMaterialsLbl: Label 'Packaging Materials';
        PackInstructionLbl: Label 'Packaging Instructions';
        NewSalesOrderLbl: Label 'New Sales Order';
        OpenSalesOrdLbl: Label 'Open Sales Order';
        PrintPackingListLbl: Label 'Print Packing List';
        ShowHandlingUnitLbl: Label 'Handling Units';
        PackagingSetupLbl: Label 'Packaging Setup';
}