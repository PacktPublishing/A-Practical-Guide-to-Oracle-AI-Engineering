/* ============================================================
   Chapter 3 – Lab User Setup
   Run as: SYSDBA on FREEPDB1
   Purpose: Creates the ORA_AI_ENG schema and grants the privileges
            required for OML4SQL model creation and ONNX imports.
   Tested on: Oracle Database 23ai Free (Docker)
   ============================================================ */

/* ============================================================
   Connect as admin to the PDB first
   Example:
   sqlplus sys/<password>@localhost:1521/FREEPDB1 as sysdba
   ============================================================ */


/* ============================================================
   Optional cleanup
   ============================================================ */

BEGIN
  EXECUTE IMMEDIATE 'DROP USER ora_ai_eng CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1918 THEN RAISE; END IF;
END;
/


/* ============================================================
   Create user
   ============================================================ */

CREATE USER ora_ai_eng
IDENTIFIED BY "password123"
DEFAULT TABLESPACE users
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON users;


/* ============================================================
   Core privileges for your script
   ============================================================ */

GRANT CREATE SESSION TO ora_ai_eng;

GRANT CREATE TABLE TO ora_ai_eng;

GRANT CREATE VIEW TO ora_ai_eng;

GRANT CREATE SEQUENCE TO ora_ai_eng;

GRANT CREATE PROCEDURE TO ora_ai_eng;


/* ============================================================
   Privileges for DBMS_DATA_MINING / OML4SQL model creation
   ============================================================ */

GRANT CREATE MINING MODEL TO ora_ai_eng;

GRANT EXECUTE ON DBMS_DATA_MINING TO ora_ai_eng;


/* ============================================================
   Privileges for ONNX model import via DBMS_VECTOR
   ONNX_IMPORT maps to /tmp inside the Docker container —
   copy .onnx files there before running Chapter 5 scripts.
   ============================================================ */


GRANT DB_DEVELOPER_ROLE TO ORA_AI_ENG;

CREATE OR REPLACE DIRECTORY ONNX_IMPORT AS '/tmp';

GRANT READ ON DIRECTORY ONNX_IMPORT TO ORA_AI_ENG;

GRANT WRITE ON DIRECTORY ONNX_IMPORT TO ORA_AI_ENG;


/* ============================================================
   Optional but useful during local labs
   Use for experimentation, not production
   ============================================================ */

GRANT CREATE SYNONYM TO ora_ai_eng;


/* ============================================================
   Verify
   ============================================================ */

SELECT username, account_status
FROM dba_users
WHERE username = 'ORA_AI_ENG';

SELECT privilege
FROM dba_sys_privs
WHERE grantee = 'ORA_AI_ENG'
ORDER BY privilege;
