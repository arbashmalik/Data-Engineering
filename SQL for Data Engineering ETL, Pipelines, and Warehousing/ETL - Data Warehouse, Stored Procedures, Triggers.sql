


-- ##############################################################
-- ############ CREATING DATAWAREHOUSE & TRIGGER  ###############
-- ##############################################################


-- Creating the data warehouse, a denormalize structure for the whole dataset

DROP PROCEDURE IF EXISTS CreateBankingDataWarehouse;

DELIMITER //

CREATE PROCEDURE CreateBankingDataWarehouse()
BEGIN

	DROP TABLE IF EXISTS bankingdata;
    
    CREATE TABLE bankingdata AS
    SELECT 
    accounts.account_id 							 AS account_id,
    accounts.date_created 							 AS account_creation_date,
    floor(datediff(now(),accounts.date_created)/365) AS account_age,
    accounts.statement_issuance 					 AS account_statement_issuance,
    clients.client_id 								 AS client_id,
    clients.gender 									 AS client_gender,
    clients.birth_date 								 AS client_birthdate,
    cards.card_type 								 AS creditcard_type,
    dispositions.disposition_type      				 AS disposition_type,
    districts.district 								 AS district,
    districts.region 								 AS region,
    orders.order_id 								 AS order_id,
    ROUND(Orders.amount,0) 							 AS orders_amount,
    orders.transaction_type 						 AS order_details,
    orders.recipient_acc 							 AS recipient_account,
    orders.recipient_bank 							 AS recipient_bank,
    transactions.trans_id 							 AS transaction_id,
    transactions.trans_date   						 AS transaction_date, 
    transactions.trans_type 		 				 AS transaction_type,
    transactions.trans_mode 						 AS transaction_mode,
    transactions.amount 							 AS transaction_amount,
    CASE 
    WHEN transactions.trans_type = 'Credit' 
		THEN (transactions.balance_after - transactions.amount)
    WHEN transactions.trans_type = 'Debit' 
		THEN (transactions.balance_after + transactions.amount)
    END 											 AS balance_before,
    transactions.balance_after 						 AS balance_remaining,
    transactions.trans_details 						 AS transaction_details,
    loans.loan_id									 AS loan_id,
    loans.loan_amount 								 AS loan_amount,
    loans.loan_date									 			AS loan_start_date,
    date_add(loans.loan_date, INTERVAL loans.duration_days DAY) AS loan_end_date,
    loans.duration_days											AS loan_duration_days,
    ROUND(((loans.monthly_payment/30) * loans.duration_days),2) AS overall_amount_due,
    loans.monthly_payment							    	 	AS loan_monthly_payment_due,
    loans.status									 AS loan_status
    FROM ACCOUNTS 
	INNER JOIN TRANSACTIONS USING (account_id)
	INNER JOIN ORDERS 		USING (account_id)
	INNER JOIN LOANS 		USING (account_id)
	INNER JOIN DISTRICTS 	USING (district_id)
	INNER JOIN CLIENTS  	USING (district_id)
	INNER JOIN DISPOSITIONS USING (account_id)
	INNER JOIN CARDS  	 	USING (disp_id)
    ORDER BY account_id;
        
END //

DELIMITER ;

CALL CreateBankingDataWarehouse();



-- Creating a log table to check what new row (account_id)was added, gives the account id

DROP TABLE IF EXISTS trigger_logs;
CREATE TABLE trigger_logs (
    message VARCHAR(100) NOT NULL,
    updated_on TIMESTAMP
);
TRUNCATE trigger_logs ;


-- Creating the trigger to automatically update the DATAWAREHOUSE, and log the changes in the `trigger_logs` table`


DROP TRIGGER IF EXISTS refreshing_bankingdatawarehouse_transactions;
DELIMITER $$
CREATE TRIGGER refreshing_bankingdatawarehouse_transactions
AFTER INSERT
ON Transactions FOR EACH ROW
BEGIN
	
	-- Adding a log message for any new insertions in data
    INSERT INTO trigger_logs VALUES (CONCAT('accounts update, new account_id : ', NEW.account_id), CURRENT_TIMESTAMP);

    INSERT INTO bankingdata
    SELECT 
        accounts.account_id 								 AS account_id,
        accounts.date_created 								 AS account_creation_date,
        FLOOR(DATEDIFF(NOW(), accounts.date_created) / 365)  AS account_age,
        accounts.statement_issuance 						 AS account_statement_issuance,
        clients.client_id 									 AS client_id,
        clients.gender 									     AS client_gender,
        clients.birth_date 								     AS client_birthdate,
        cards.card_type 									 AS creditcard_type,
        dispositions.disposition_type      				     AS disposition_type,
        districts.district 								 	 AS district,
        districts.region 								 	 AS region,
        orders.order_id 								     AS order_id,
        ROUND(Orders.amount, 0) 							 AS orders_amount,
        orders.transaction_type 							 AS order_details,
        orders.recipient_acc 							     AS recipient_account,
        orders.recipient_bank 							     AS recipient_bank,
        transactions.trans_id 							 	 AS transaction_id,
        transactions.trans_date   							 AS transaction_date, 
        transactions.trans_type 							 AS transaction_type,
        transactions.trans_mode 						     AS transaction_mode,
        transactions.amount 								 AS transaction_amount,
        CASE 
            WHEN transactions.trans_type = 'Credit' 
                THEN (transactions.balance_after - transactions.amount)
            WHEN transactions.trans_type = 'Debit' 
                THEN (transactions.balance_after + transactions.amount)
        END 												 AS balance_before,
        transactions.balance_after 						 	 AS balance_remaining,
        transactions.trans_details 						 	 AS transaction_details,
        loans.loan_id									     AS loan_id,
        loans.loan_amount 								     AS loan_amount,
        loans.loan_date								 	     AS loan_start_date,
        DATE_ADD(loans.loan_date, INTERVAL loans.duration_days DAY) AS loan_end_date,
        loans.duration_days								     AS loan_duration_days,
        ROUND(((loans.monthly_payment / 30) * loans.duration_days), 2) AS overall_amount_due,
        loans.monthly_payment								 AS loan_monthly_payment_due,
        loans.status									     AS loan_status
    FROM ACCOUNTS
    LEFT  JOIN TRANSACTIONS USING (account_id)
    INNER JOIN ORDERS 		USING (account_id)
    INNER JOIN LOANS 		USING (account_id)
    INNER JOIN DISTRICTS 	USING (district_id)
    INNER JOIN CLIENTS  	USING (district_id)
    INNER JOIN DISPOSITIONS USING (account_id)
    INNER JOIN CARDS  	 	USING (disp_id)
    WHERE account_id = NEW.account_id
	ORDER BY account_id;
    
END $$
DELIMITER ;




-- ##############################################################
-- ########### CREATING USEFUL STORED PROCEDURES  ###############
-- ##############################################################


DROP PROCEDURE IF EXISTS get_accounts_by_region;

DELIMITER //

CREATE PROCEDURE get_accounts_by_region(
	IN regionname VARCHAR(255)
)
BEGIN
	SELECT DISTINCT account_id, account_age, account_statement_issuance
 		FROM bankingdata
			WHERE region = regionname;
END //
DELIMITER ;


DROP PROCEDURE IF EXISTS get_accounts_by_district;

DELIMITER //

CREATE PROCEDURE get_accounts_by_district(
	IN districtname VARCHAR(255)
)
BEGIN
	SELECT DISTINCT account_id, account_creation_date, account_statement_issuance
 		FROM bankingdata
			WHERE district = districtname;
END //
DELIMITER ;



DROP PROCEDURE IF EXISTS get_last_transaction_date;

DELIMITER //

CREATE PROCEDURE get_last_transaction_date(
	IN account_no INT
)
BEGIN
	SELECT max(transaction_date) as Latest_transaction_date , balance_remaining
 		FROM bankingdata
			WHERE account_id = account_no;
END //
DELIMITER ;

