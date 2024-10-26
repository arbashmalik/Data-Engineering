# Data Engineering 1 - Term Project 1
Arbash Malik - MSBA 2023
This repository contains my materials for Term Project 1 for my Data Engineering 1 course.

# Introduction of the dataset
PKDD Financial is a relational dataset which has synthethic real world data of a banking institution in Czech Republic. The dataset has 8 tables;
  1. `ACCOUNTS`
  2. `CARDS`
  3. `CLIENTS`
  4. `DISPOSITIONS`
  5. `DISTRICS`
  6. `LOANS`
  7. `ORDERS`
  8. `TRANSACTIONS`

The dataset had .asc file types, and more than a million rows (five years of banking transactions data - `transactions` table), which I trimmed down to 50k


# 1. Operational Layer - Data Loading & Database creation
 1. An `Entity Relationship Digram` was made to make the data base structure and link the tables.
 2. Indexes of certain columns were also made for faster querying. (find the ERD and the indexes in the **ERD & Variable Description.PDF**. Using the ERD, an SQL script was generated using the forward-engineering tool in MySQL.
 3. Constraints were also added to ensure that data quality is maintained, and every linked table gets updated. 
 4. The query was run to create the database and then the data was loaded through `in file` method.
 5. Exploratory data queries were done to ensure database is working fine. The data was trimmed down as well.
 6. Database was dumped with `table structure` & `data` to make it reproducible.

# 2. Analytics Plan
  My goal for this dataset was to transform it in such a way that multiple departments can use it for their function for e.g loans department, customer service department, payment and order department etc. 
  Analysis I had in that identify accounts that are the most active `transactions` & `order` table, location analysis of accounts based on loan repayment with demographic as well as regional socio-economic indicators (`districts` table), streamlining process with partner banks that we have the most activity with (`transactions` table), and do the type of credit cards influnce your spending?

# 3. Analytical Layer and ETL
  I transformed almost all of the column names to better represent the information they contain, as well as added more transformed columns that can be used for further analysis such as `account_age`,`balance_before`,`overall_loan_amount_due`. 
  And create a denormalized database structure that combines all of the columns in the database. A trigger was also created to make sure any insertions in the data would update the analytical layer. 
  A trigger log table was also created that gives you the new `account_id` and the `timestamp` of the update.
  I also created some stored procedures for quick recall of data.

# 4. Data Marts as Views
  I created 4 Data Marts
  1. `account_summary_view` gives detailed information about accounts. 
  3. `loan_summary_view` gives detailed information about loans.
  4. `gold_card_summary_view` gives detailed information about gold credit cards members
  5. `transaction_summary_view` gives detailed information about transactions 
 


