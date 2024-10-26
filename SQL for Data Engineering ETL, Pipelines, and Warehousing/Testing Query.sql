-- Note run transfomration values testion code before loading testing data

-- #####################################################
-- ########### TRANSFORMATION VALUES TESTING ###########
-- #####################################################
 
-- Check if our transformation on the czech to english translation worked, you should see english words in every query
SELECT DISTINCT account_statement_issuance FROM bankingdata;	
SELECT DISTINCT loan_status FROM bankingdata;
SELECT DISTINCT order_details FROM bankingdata;
SELECT DISTINCT transaction_type FROM bankingdata;
SELECT DISTINCT transaction_mode FROM bankingdata;
SELECT DISTINCT transaction_details FROM bankingdata;



-- #####################################################
-- ########### VIEW DATA MART TESTING/VIEWING ##########
-- #####################################################

SELECT * FROM account_summary_view;
SELECT * FROM loan_summary_view;
SELECT * FROM gold_card_summary_view;
SELECT * FROM transaction_summary_view;


-- #####################################################
-- ################# TRIGGER TESTING ###################
-- #####################################################

-- NOTE: I am using the insert values in the specific order for the table as per constraints. 


-- Start by running this query
 
SELECT * FROM trigger_logs;

-- There is no logs here since we have not inserted any data 

-- Now run these queries, these load data into the tables

INSERT INTO districts VALUES (129,'Quellenstrasse','Vienna',123456,1,1,1,1,1,100,12345,0.99,0.99,12345,12345,12345);
INSERT INTO accounts VALUES (123456,129,'Testing','2023-11-12');
INSERT INTO clients VALUES (654321,'M','2023-11-12',129);
INSERT INTO dispositions VALUES (987654,654321,123456,'OWNER');
INSERT INTO cards VALUES (654321,987654,'gold','2023-11-12');
INSERT INTO loans VALUES (112233,123456,'2023-11-12',9999,30,9999.00,'Contract Finished (Paid)');
INSERT INTO orders VALUES (332211,123456,'YZ',87144583,2452.0,'Testing Payment');
INSERT INTO transactions VALUES (123321,123456,'2023-11-12','Credit','Received from Other Bank',9999,99999,"Other",'AB',123456789);


-- Check if data was actually loaded

SELECT * FROM accounts where account_id = 123456;

-- you should see the output from accounts table with account_id = 123456, and statement_issuance = "Testing"


-- Now check if your trigger worked, first let's check the trigger logs.

SELECT * FROM trigger_logs;

-- There should be a new message with account id and timestamp of the update.

-- Now check if the datawarehouse was updated

SELECT * FROM bankingdata where account_id = 123456;

-- There should be an output with the new account_id we just entered



-- #####################################################
-- ############# STORED PROCEDURES TESTING #############
-- #####################################################


-- Example Regions:
-- "north Bohemia"
-- "east Bohemia"
-- "west Bohemia"

CALL get_accounts_by_region('region');

-- Example DISTRICTS:
-- "Tabor"
-- "Liberec"
-- "Teplice"
-- replace the string with the values above

CALL get_accounts_by_district('district');


-- Example acounts:
-- 97
-- 105
-- 110
-- enter the value between () with the values above

CALL get_last_transaction_date();
