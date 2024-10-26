
-- ##############################################################
-- ################# CREATING VIEWS/DATA MARTS ##################
-- ##############################################################

-- NOTE: I am using same name aliases for column, (although I do not need to), 
--  	 it is for anybody else if they want to reproduce views in their own view. Easier for reproducability




-- ACCOUNT SUMMARY VIEW
-- Gives import information of the accounts; can be used in identification as well as it has the creation_date as well as latest transaction date and amount

DROP VIEW IF EXISTS account_summary_view;
CREATE VIEW account_summary_view AS
(
SELECT 
    account_id 					AS account_id, 
    account_creation_date 		AS account_creation_date,
    account_age 				AS account_age,
    account_statement_issuance  AS account_statement_issuance,
    COUNT(DISTINCT client_id)   AS no_of_clients,
    disposition_type 			AS disposition_type,
	COUNT(DISTINCT loan_id)     AS no_of_loans_taken,
	COUNT(DISTINCT order_id)    AS no_of_orders,
	MAX(transaction_date) 		AS latest_trans_date,
    balance_remaining       	AS balance_remaining,
    district    				AS district,
    region                    	AS region
FROM bankingdata

GROUP BY account_id
ORDER BY account_id
);


-- LOAN SUMMARY VIEW
-- Gives import information of the loans for all the accounts; can be used by loan officers in identifying what accounts
-- are eligible for loans OR which accounts have defaulted/not paid the previous loans



DROP VIEW IF EXISTS loan_summary_view;
CREATE VIEW loan_summary_view AS
SELECT 
DISTINCT 
	account_id 				 AS account_id,
    loan_id 				 AS loan_id,
    loan_amount 			 AS loan_amount,
	loan_start_date 		 AS loan_start_date,
    loan_end_date			 AS loan_end_date,
    loan_duration_days		 AS loan_duration_days,
    overall_amount_due		 AS overall_amount_due,
    loan_monthly_payment_due AS loan_monthly_payment_due,
    loan_status				 AS loan_status
FROM bankingdata
ORDER BY account_id;


-- GOLD CARD SUMMARY VIEW
-- Gives information of the GOLD credit cards; can be used by customer service representatives in identifying what accounts
-- are eligible priority banking offers/discounts as well as give info that they may require.


DROP VIEW IF EXISTS gold_card_summary_view;
CREATE VIEW gold_card_summary_view AS
SELECT 
DISTINCT 
	account_id 				AS account_id,
    account_creation_date 	AS account_creation_date,
  	account_age				AS account_age,
    district                AS district,
    region                  AS region,
    transaction_type 		AS transaction_type,
    transaction_date   		AS transaction_date, 
    transaction_mode 		AS transaction_mode,
    transaction_details 	AS transaction_details,
    transaction_amount	 	AS transaction_amount
FROM bankingdata
WHERE creditcard_type = 'gold'
ORDER BY account_id;


-- TRANSACTION SUMMARY VIEW
-- Gives statistical information of the transactions of each account monthly and yearly; specifically monthly activities

DROP VIEW IF EXISTS transaction_summary_view;
CREATE VIEW transaction_summary_view AS

WITH ranked_transactions AS (
    SELECT
        account_id 					  AS account_id,
        YEAR(transaction_date) 		  AS transaction_year,
        MONTH(transaction_date) 	  AS transaction_month,
        COUNT(*) OVER(
			PARTITION BY account_id,
			YEAR(transaction_date), 
            MONTH(transaction_date) )  AS transaction_count,
        SUM(transaction_amount) OVER(
			PARTITION BY account_id,
			YEAR(transaction_date), 
            MONTH(transaction_date))  AS total_transaction_amount,
        transaction_details,
        DENSE_RANK() OVER (
			PARTITION BY account_id, 
            YEAR(transaction_date), 
            MONTH(transaction_date) 
            ORDER BY COUNT(*) DESC)   AS trans_detail_rank
    FROM
        bankingdata
    GROUP BY
        account_id, transaction_year, transaction_month, transaction_details
)
SELECT
    account_id 													AS account_id,
    transaction_year 											AS transaction_year,
    transaction_month 											AS transaction_month,
    ROUND(AVG(transaction_count),2) 							AS monthly_avg_transaction_count,
    ROUND(AVG(total_transaction_amount),0) 						AS monthly_avg_transaction_amount,
    MAX(CASE WHEN trans_detail_rank = 1 THEN transaction_details END) AS priority_transaction_reason
FROM
    ranked_transactions
GROUP BY
    account_id, transaction_year, transaction_month;

