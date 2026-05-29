SET SQLBLANKLINES ON

/* ============================================================
   Chapter 3 – Customer Training Data
   Run as: ORA_AI_ENG on FREEPDB1
   Purpose: Creates and populates the CUSTOMERS table used as
            the training and inference dataset throughout Chapter 3.
   Rows 1001–1010 : training set (used in CUSTOMERS_V)
   Rows 1011–1015 : holdout / inference set
   Tested on: Oracle Database 23ai Free (Docker)
   ============================================================ */


/* ============================================================
   Customer table
   ============================================================ */

CREATE TABLE customers (
  cust_id                 NUMBER        PRIMARY KEY,
  first_name              VARCHAR2(50),
  last_name               VARCHAR2(50),
  marital_status          VARCHAR2(20),
  age                     NUMBER,
  annual_income           NUMBER(12,2),
  savings_balance         NUMBER(12,2),
  credit_score            NUMBER,
  account_open_date       DATE,
  employment_status       VARCHAR2(30),
  owns_home               VARCHAR2(1),
  number_of_dependents    NUMBER,
  annual_travel_spend     NUMBER(12,2),
  buy_travel_insurance    NUMBER(1),

  CONSTRAINT chk_customers_target
    CHECK (buy_travel_insurance IN (0, 1)),

  CONSTRAINT chk_customers_owns_home
    CHECK (owns_home IN ('Y', 'N'))
);


/* ============================================================
   Populate customers
   Target column:
   1 = customer purchased / is likely to purchase travel insurance
   0 = customer did not purchase / is less likely
   ============================================================ */

INSERT INTO customers VALUES
(1001, 'James',   'Harrison',  'MARRIED',  42,  95000, 42000, 760, ADD_MONTHS(SYSDATE, -84),  'EMPLOYED',      'Y', 2,  6500, 1);

INSERT INTO customers VALUES
(1002, 'Ashley',  'Mitchell',  'SINGLE',   29,  52000,  9000, 690, ADD_MONTHS(SYSDATE, -30),  'EMPLOYED',      'N', 0,  1800, 0);

INSERT INTO customers VALUES
(1003, 'Robert',  'Sullivan',  'MARRIED',  51, 125000, 85000, 810, ADD_MONTHS(SYSDATE, -132), 'SELF_EMPLOYED', 'Y', 3,  9200, 1);

INSERT INTO customers VALUES
(1004, 'Karen',   'Dawson',    'DIVORCED', 47,  78000, 22000, 720, ADD_MONTHS(SYSDATE, -60),  'EMPLOYED',      'N', 1,  4100, 1);

INSERT INTO customers VALUES
(1005, 'Tyler',   'Brooks',    'SINGLE',   35,  61000, 12000, 675, ADD_MONTHS(SYSDATE, -26),  'EMPLOYED',      'N', 0,  2400, 0);

INSERT INTO customers VALUES
(1006, 'Jessica', 'Palmer',    'MARRIED',  39,  89000, 36000, 745, ADD_MONTHS(SYSDATE, -74),  'EMPLOYED',      'Y', 2,  5700, 1);

INSERT INTO customers VALUES
(1007, 'Brandon', 'Griffith',  'SINGLE',   26,  43000,  5000, 640, ADD_MONTHS(SYSDATE, -15),  'EMPLOYED',      'N', 0,   900, 0);

INSERT INTO customers VALUES
(1008, 'Linda',   'Whitfield', 'MARRIED',  55, 138000, 97000, 825, ADD_MONTHS(SYSDATE, -180), 'SELF_EMPLOYED', 'Y', 2, 11000, 1);

INSERT INTO customers VALUES
(1009, 'Sandra',  'Thornton',  'WIDOWED',  63,  72000, 68000, 790, ADD_MONTHS(SYSDATE, -210), 'RETIRED',       'Y', 0,  7200, 1);

INSERT INTO customers VALUES
(1010, 'Kevin',   'Garrett',   'SINGLE',   31,  48000,  7000, 655, ADD_MONTHS(SYSDATE, -20),  'CONTRACTOR',    'N', 0,  1300, 0);

INSERT INTO customers VALUES
(1011, 'Patricia','Caldwell',  'MARRIED',  44, 105000, 51000, 775, ADD_MONTHS(SYSDATE, -96),  'EMPLOYED',      'Y', 1,  7800, 1);

INSERT INTO customers VALUES
(1012, 'Dennis',  'Fowler',    'DIVORCED', 50,  67000, 16000, 700, ADD_MONTHS(SYSDATE, -48),  'EMPLOYED',      'N', 2,  3000, 0);

INSERT INTO customers VALUES
(1013, 'Stephanie','Norris',   'SINGLE',   28,  58000, 14000, 710, ADD_MONTHS(SYSDATE, -34),  'EMPLOYED',      'N', 0,  2500, 0);

INSERT INTO customers VALUES
(1014, 'Gregory', 'Lawson',    'MARRIED',  46, 115000, 62000, 800, ADD_MONTHS(SYSDATE, -120), 'SELF_EMPLOYED', 'Y', 3,  8900, 1);

INSERT INTO customers VALUES
(1015, 'Deborah', 'Fleming',   'MARRIED',  37,  83000, 31000, 735, ADD_MONTHS(SYSDATE, -66),  'EMPLOYED',      'Y', 1,  4900, 1);

COMMIT;
