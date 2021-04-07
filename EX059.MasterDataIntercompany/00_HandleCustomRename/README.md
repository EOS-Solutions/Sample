# What is "Handle Custom Rename" 
"MDI master data management" handles rename of records in all companies, but the global rename trigger runs before the record rename on the database. Usually it enough, but for some tables, renaming executes many cheks increasing the risk of raising an error.

The "Handle Custom Rename" is an example of how to manage the rename in the "OnAfterCustomRename" of the table, avoiding almost all problems.