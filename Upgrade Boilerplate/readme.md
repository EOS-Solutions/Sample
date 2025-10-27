# Upgrade boilerplate example

This is a basic example of how upgrade code for an app should look like. When adding an upgrade to an app, there are several things to keep in mind. The first is all the different scenarios that your upgrade code must consider:

| Doing what?         | Where?            | Why?                  |
|---------------------|-------------------|-----------------------|
| The upgrade itself  | Upgrade Codeunit  | This is where your actual upgrade code lives.|
| Creating tags on new companies | Upgrade Codeunit | Because for every new company that is created, all existing upgrade tags must also be created. Otherwise your upgrade code will run in these companies the next time the app is updated.
| Creating tags on fresh installs | Install Codeunit | Because when you install your app for the first time on an environment, all previous upgrade tags must be created. Otherwise your upgrade code will run the next time the app is updated.

## How?

Whenever you have an upgrade to make you will therefore have:

- 1 upgrade codeunit (`Upgrade.Codeunit.al`): this will deal with step 1 and 2 above.
- 1 install codeunit (`Install.Codeunit.al`): this will deal with step 3 above.

For both codeunits find the example here.

## What do I need to do for a new upgrade procedure?

1. You will obviously need to write a method that handles your code in your upgrade codeunit. Look at the examples at the bottom in in `Upgrade.Codeunit.al`.
2. Call this new method from `OnUpgradePerCompany` and/or `OnUpgradePerDatabase`.
3. Add your tag in `GetCompanyUpgradeTags` and/or `GetDatabaseUpgradeTags`.
4. The End.