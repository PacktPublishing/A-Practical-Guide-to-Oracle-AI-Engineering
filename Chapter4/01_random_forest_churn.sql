/* ============================================================
   Chapter 4 – Random Forest Churn Model
   Run as: ORA_AI_ENG on FREEPDB1
   Purpose: Trains a Random Forest classification model on the
            CUSTOMERS_V view, scores all customers for churn risk,
            and demonstrates Oracle partitioned models (one
            sub-model per MARITAL_STATUS value).
   Prerequisite: Chapter 3 scripts must be executed first.
   Tested on: Oracle Database 23ai Free (Docker)
   ============================================================ */


/* ============================================================
   Drop the model if it already exists before recreating
   ============================================================ */
BEGIN
    DBMS_DATA_MINING.DROP_MODEL('churn_model');
END;
/

/* ============================================================
   Train a Random Forest classification model.
   PREP_AUTO handles normalization and missing-value imputation.
   TARGET: BUY_TRAVEL_INSURANCE (0 = did not buy / churned,
                                  1 = purchased)
   ============================================================ */
DECLARE
 v_setlst DBMS_DATA_MINING.SETTING_LIST;
BEGIN
 v_setlst('ALGO_NAME') := 'ALGO_RANDOM_FOREST';
 v_setlst('PREP_AUTO') := 'ON';
 DBMS_DATA_MINING.CREATE_MODEL2(
 MODEL_NAME => 'churn_model',
 MINING_FUNCTION => 'CLASSIFICATION',
 DATA_QUERY => 'SELECT * FROM CUSTOMERS_V',
 SET_LIST => v_setlst,
 CASE_ID_COLUMN_NAME => 'CUST_ID',
 TARGET_COLUMN_NAME => 'BUY_TRAVEL_INSURANCE');
END;
/


/* ============================================================
   Score all customers — quick churn risk scan
   ============================================================ */
SELECT cust_id,
 PREDICTION_PROBABILITY(churn_model USING *) AS churn_risk
FROM customers;


/* ============================================================
   Full scoring with predicted label and churn probability,
   ordered by highest churn risk first
   ============================================================ */
SELECT * FROM
  (SELECT CUST_ID,
          PREDICTION(churn_model USING C.*)                          AS WILL_CHURN,
          ROUND(PREDICTION_PROBABILITY(churn_model, 0 USING C.*), 6) AS PROB_CHURN
   FROM customers C)
ORDER BY PROB_CHURN DESC;


/* ============================================================
   Targeted churn scoring: higher-income segment only.
   Predict churn: class 0 = churned (did not buy)
   ============================================================ */
-- Predict churn: class 0 = churned (did not buy)
SELECT cust_id,
  PREDICTION(churn_model USING *)                AS churn_prediction,
  PREDICTION_PROBABILITY(churn_model, 0 USING *) AS churn_probability
FROM customers
WHERE ANNUAL_INCOME >= 50000
ORDER BY churn_probability DESC;


/* ============================================================
   Partitioned model example
   Add the ODMS_PARTITION_COLUMNS setting — that's the only
   addition needed. Oracle trains one sub-model per distinct
   value of the partition column.
   ============================================================ */

/*
Add the ODMS_PARTITION_COLUMNS setting — that's the only addition needed. Oracle trains one sub-model per distinct value of the partition column:
*/

DECLARE
  v_setlst DBMS_DATA_MINING.SETTING_LIST;
BEGIN
  v_setlst('ALGO_NAME')              := 'ALGO_RANDOM_FOREST';
  v_setlst('PREP_AUTO')              := 'ON';
  v_setlst('ODMS_PARTITION_COLUMNS') := 'MARITAL_STATUS';  -- one sub-model per: MARRIED, SINGLE, DIVORCED, WIDOWED

  DBMS_DATA_MINING.CREATE_MODEL2(
    MODEL_NAME          => 'churn_model_part',
    MINING_FUNCTION     => 'CLASSIFICATION',
    DATA_QUERY          => 'SELECT * FROM CUSTOMERS_V',
    SET_LIST            => v_setlst,
    CASE_ID_COLUMN_NAME => 'CUST_ID',
    TARGET_COLUMN_NAME  => 'BUY_TRAVEL_INSURANCE'
  );
END;
/


/*
Key rules for partitioned models:

The partition column must be in the DATA_QUERY (it is — via SELECT *)
It cannot be the CASE_ID or TARGET column
Each partition needs enough rows to train — with only 10 rows in CUSTOMERS_V, EMPLOYMENT_STATUS (fewer distinct values) may be safer than MARITAL_STATUS
You can also partition by multiple columns: 'MARITAL_STATUS, EMPLOYMENT_STATUS'.

MAX(account_open_date) acts as "now" for the dataset — the subquery returns the most recent date in the 2020 data, then subtracts 5 minutes. This preserves the exact wording of the text ("last five minutes") while returning actual rows regardless of when the query runs.
*/

/* ============================================================
   Score recently opened accounts using the partitioned model.
   The GROUPING hint routes each row to its correct sub-model.
   PARALLEL(4) illustrates in-database parallel scoring.
   ============================================================ */
SELECT /*+ PARALLEL(4) */
  PREDICTION(/*+ GROUPING */ churn_model_part USING *)          AS predicted_label,
  PREDICTION_PROBABILITY(/*+ GROUPING */ churn_model_part, 0
    USING *)                                                     AS churn_probability,
  cust_id,
  account_open_date
FROM customers
WHERE account_open_date >= (SELECT MAX(account_open_date) FROM customers) - INTERVAL '5' MINUTE;
