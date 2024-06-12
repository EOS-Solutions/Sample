codeunit 50100 SemaphoreDemo
{

    // This codeunit demonstrates how to use the semaphore codeunit to prevent multiple instances of the same action to run at the same time.
    // This is useful for actions that should periodically, but only run once at a time, like a data synchronization, a report generation, etc.
    // The difference between a semaphore and the job queue is that a semaphore is not a queue, but a lock. Also, it is always available and does not depend on job queue configuration.

    // A semaphore can have three states:
    // Locked: the semaphore ha been locked, the action it is used for is currently executed. No one else can lock the semaphore.
    // Unlocked: the action it is used for has completed (successfully or not), but the semaphore is not yet released. No one else can lock the semaphore.
    // Released: the semaphore is unlocked and also the release time interval has passed. The semaphore is ready to be locked again.

    trigger OnRun()
    var
        semaphore: Codeunit EOS004Semaphore;
        ok: Boolean;
    begin
        // Create the semaphore.
        semaphore := CreateSemaphore();

        // Step 1: verify if the semaphore is released. If it is not, we do not do anything.
        if (not semaphore.IsReleased()) then exit;

        // Step 2: Lock the semaphore. This will raise an error if the semaphore is already locked 
        semaphore.Lock();

        // Step 3: Do your stuff
        // Everything you do here should never raise an error, as this will cause the semaphore to never unlock and thus never release.
        // However, a semaphore has a timeout mechanism (see ReleaseIfTimedOut) you can call to make sure it gets unlocked eventually.
        ok := DoStuff();

        // Step 4: Unlock the semaphore, specifying if the action was successful or not.
        // This parameter will determine the release time interval for the semaphore.
        semaphore.Unlock(ok);
    end;

    local procedure CreateSemaphore(): Codeunit EOS004Semaphore
    var
        semaphore: Codeunit EOS004Semaphore;
    begin
        // Initialize must always be called first
        semaphore.Initialize(
            '<insert-a-guid-here>', // provide a unique guid for your semaphore
            false); // should the semaphore be per company?

        // Set when semaphore releases after success
        semaphore.SetSuccessReleaseInterval(
            4 * 60 * 60 * 1000, // set the semaphore to release after 4h
            60 * 1000); // a random amount of +/- 1 minute

        // Set when semaphore releases after a failure
        semaphore.SetFailureReleaseInterval(
            5 * 60 * 1000, // set the semaphore to release after 5min
            60 * 1000); // a random amount of +/- 1 minute

        // Set the lock timeout to 10min.
        // The default is 5min.
        semaphore.SetLockTimeout(10 * 60 * 1000);

        // This is for safety only.
        // If there is a chance that your semaphore (due to forseen or unforseen errors) never unlocks, call this
        // to make sure it gets unlocked eventually, when it times out (as a failure) after a certain amount of time.
        semaphore.ReleaseIfTimedOut();

        // Return the semaphore
        exit(semaphore);
    end;

    local procedure DoStuff(): Boolean
    begin
        // Do your stuff here
        // If it fails, return false
        // If it succeeds, return true
    end;

}