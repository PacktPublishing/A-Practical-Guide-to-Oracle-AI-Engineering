/* ============================================================
   Chapter 5 – Support Incidents Table and Data
   Run as: ORA_AI_ENG on FREEPDB1
   Purpose: Creates and populates the SUPPORT_INCIDENTS table
            used as the text corpus for vector similarity search.
            The EMBEDDING column (VECTOR type) is populated by
            02_vector_embeddings.sql after the ONNX model is loaded.
   Tested on: Oracle Database 23ai Free (Docker)
   ============================================================ */


/* ============================================================
   Drop existing table if present
   ============================================================ */
begin
      execute immediate 'drop table support_incidents purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

/* ============================================================
   Create table
   The EMBEDDING column stores 384-dimensional float32 vectors
   produced by the all-MiniLM-L12-v2 ONNX model.
   ============================================================ */
create table support_incidents (
  id            number generated always as identity primary key,
  incident_no   varchar2(30),
  title         varchar2(200),
  severity      varchar2(20),
  category      varchar2(50),
  incident_text clob,
  embedding     vector(384, float32)
);

/* ============================================================
   Seed data — six representative IT support incidents
   covering database, IAM, integration, data engineering,
   service operations, and network categories.
   Embeddings are populated separately via VECTOR_EMBEDDING.
   ============================================================ */
insert into support_incidents (incident_no, title, severity, category, incident_text) values (
  'INC-1001',
  'Production database CPU spike after deployment',
  'Critical',
  'Database Performance',
  'Immediately after deployment, production Oracle database CPU usage exceeded 95 percent. Application response times increased significantly. Root cause was a missing composite index causing a full scan on a high-volume table.'
);

insert into support_incidents (incident_no, title, severity, category, incident_text) values (
  'INC-1002',
  'Authentication failures for internal HR portal',
  'High',
  'Identity and Access Management',
  'Employees were unable to log in to the HR portal. Investigation showed a certificate mismatch after SAML signing certificate rotation on the identity provider side.'
);

insert into support_incidents (incident_no, title, severity, category, incident_text) values (
  'INC-1003',
  'Payment API timeout affecting checkout transactions',
  'Critical',
  'Application Integration',
  'Checkout requests failed because outbound calls to the external payment provider returned repeated timeout responses. Retry configuration amplified the problem.'
);

insert into support_incidents (incident_no, title, severity, category, incident_text) values (
  'INC-1004',
  'Data load failure in nightly ETL pipeline',
  'Medium',
  'Data Engineering',
  'The nightly ETL pipeline failed when a source CSV arrived with an unexpected delimiter and malformed timestamps. The downstream dashboard displayed incomplete data.'
);

insert into support_incidents (incident_no, title, severity, category, incident_text) values (
  'INC-1005',
  'Customer support ticket backlog after email routing issue',
  'High',
  'Service Operations',
  'Incoming support emails were not converted into service tickets because a subject parsing regex excluded valid regional prefixes.'
);


insert into support_incidents (incident_no, title, severity, category, incident_text) values (
  'INC-1006',
  'Network DNS failures',
  'High',
  'Connectivity',
  'Network DNS failures because network provider outage, causing widespread connectivity issues across multiple applications.'
);
commit;
