# App
EX037 Detailed Document Discounts

# Scenario: 
The customer manages seven types of customized discounts on the sales line: 
* "Customer Discount %"
* "Extra Discount %"
* "Logistic Discount %"
* "Sell-in Discount %"
* "Cash Desk Discount %"
* "Item Discount %"
* "Additional Discount %".

# Purpose: 
when validating one of these discounts online (either manually or automatically), BC must calculate the sum of the discounts by hooking up to the EOS app "EX037 Detailed Document Discounts".

# Example:
"Customer Discount %" = 0%
"Extra Discount %" = 5% 
"Logistic Discount %" = 10% 
"Sell-in Discount %" = 0% 
"Cash Desk Discount %" = 0% 
"Item Discount %" = 0% 
"Additional Discount %" = 7%
	
Upon validating one of the discounts above the field in the sales line of Platform "Detailed Line Discount" will have to become : 5 + 10 + 7
	
# App Dependencies:
"id": "4e2a89a2-9049-496c-8b3a-f4eee6399b0e",
"name": "Common Data Layer",
"publisher": "EOS Solutions",
"version": "15.0.0.0"

"id": "ef70c009-75ce-4075-9c31-463dd65c6e83",
"name": "Detailed Document Discounts",
"publisher": "EOS Solutions",
"version": "16.0.0.0"
