/* ============================================================
   Chapter 3 – Feature Engineering and OML4SQL Classification
   Run as: ORA_AI_ENG on FREEPDB1
   Purpose: Demonstrates SQL-based feature engineering patterns,
            creates a model-ready view, trains an SVM classification
            model with OML4SQL, and runs an inline prediction.
   Prerequisite: 02_customers_setup.sql must be executed first.
   Tested on: Oracle Database 23ai Free (Docker)
   ============================================================ */


-- Building features with Oracle SQL
-- e.g. Derived columns: Use date/time functions such as MONTHS_BETWEEN
-- to compute customer tenure or time since the last interaction:
 SELECT cust_id,
       MONTHS_BETWEEN(SYSDATE, account_open_date) AS tenure_months
FROM customers;


 -- Building features with Oracle SQL
 -- e.g. Rolling aggregates: Apply window functions such as COUNT(*) OVER (...) to derive metrics
 -- such as recent transaction frequency or average purchase amount over a defined period:
SELECT cust_id,
  COUNT(*) OVER (
    ORDER BY account_open_date
    RANGE BETWEEN INTERVAL '6' MONTH PRECEDING
              AND CURRENT ROW
  ) AS accounts_opened_last_6_months
FROM customers;


-- Create a view to select the relevant features for model training and inference.
-- DATE is not supported by OML4SQL, so account_open_date is cast to VARCHAR2.
-- OML4SQL supports standard Oracle data types except DATE, TIMESTAMP, RAW, and LONG.

CREATE OR REPLACE VIEW CUSTOMERS_V AS
SELECT
  CUST_ID,
  FIRST_NAME,
  LAST_NAME,
  MARITAL_STATUS,
  AGE,
  ANNUAL_INCOME,
  SAVINGS_BALANCE,
  CREDIT_SCORE,
  TO_CHAR(ACCOUNT_OPEN_DATE, 'YYYY-MM-DD') AS ACCOUNT_OPEN_DATE,
  EMPLOYMENT_STATUS,
  OWNS_HOME,
  NUMBER_OF_DEPENDENTS,
  ANNUAL_TRAVEL_SPEND,
  BUY_TRAVEL_INSURANCE
FROM ORA_AI_ENG.CUSTOMERS
WHERE CUST_ID BETWEEN 1001 AND 1010;


-- Drop existing model if present before recreating
BEGIN
    DBMS_DATA_MINING.DROP_MODEL('BUY_TRAVEL_INSUR');
END;
/

/* ============================================================
   Train an SVM classification model
   ALGO_SUPPORT_VECTOR_MACHINES with PREP_AUTO handles
   feature scaling and normalization automatically.
   TARGET: BUY_TRAVEL_INSURANCE (0/1 binary classification)
   ============================================================ */
DECLARE
 v_setlst DBMS_DATA_MINING.SETTING_LIST;
BEGIN
 v_setlst('ALGO_NAME') := 'ALGO_SUPPORT_VECTOR_MACHINES';
 v_setlst('PREP_AUTO') := 'ON';
 DBMS_DATA_MINING.CREATE_MODEL2(
 MODEL_NAME => 'BUY_TRAVEL_INSUR',
 MINING_FUNCTION => 'CLASSIFICATION',
 DATA_QUERY => 'SELECT * FROM CUSTOMERS_V',
 SET_LIST => v_setlst,
 CASE_ID_COLUMN_NAME => 'CUST_ID',
 TARGET_COLUMN_NAME => 'BUY_TRAVEL_INSURANCE');
END;
/


/* ============================================================
   Run an inline prediction against the trained model.
   Returns the probability that this customer (class=1)
   will purchase travel insurance.
   ============================================================ */
SELECT PREDICTION_PROBABILITY(BUY_TRAVEL_INSUR, 1
  USING
    3500          AS SAVINGS_BALANCE,
    (2026 - 1987) AS AGE,
    'Married'     AS MARITAL_STATUS,
    50000         AS ANNUAL_INCOME
)
FROM DUAL;
