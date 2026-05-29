/* ============================================================
   Chapter 5 – ONNX Vector Embedding Model and Similarity Search
   Run as: ORA_AI_ENG on FREEPDB1
   Purpose: Loads the all-MiniLM-L12-v2 ONNX sentence-embedding
            model into the database, generates vector embeddings
            for the SUPPORT_INCIDENTS corpus, and demonstrates
            cosine-similarity search with optional category filtering.
   Prerequisite: 01_support_incidents_setup.sql must be executed first.
                 The .onnx file must be present in the ONNX_IMPORT
                 directory (/tmp inside the Docker container).
   Tested on: Oracle Database 23ai Free (Docker)
   ============================================================ */


/* ============================================================
   Incorrect approach — load_onnx_model with the legacy
   model_data parameter does not include the required metadata
   JSON that maps the model's input/output tensor names.
   This form will fail or produce unusable results.
   ============================================================ */
BEGIN
 DBMS_VECTOR.load_onnx_model(
 directory => 'ONNX_IMPORT',
 model_data => 'all-MiniLM-L12-v2.onnx',
 model_name => 'ALL_MINILM_L12_V2'
 );
END;
/

/* ============================================================
   Correct approach — drop any existing model first, then load
   with the file_name parameter and the metadata JSON that
   declares the embedding function and maps the DATA input tensor.
   ============================================================ */

BEGIN
    DBMS_VECTOR.DROP_ONNX_MODEL(model_name => 'ALL_MINILM_L12_V2', force => true);
end;
/

BEGIN
   DBMS_VECTOR.LOAD_ONNX_MODEL(
        directory => 'ONNX_IMPORT',
		file_name => 'all_MiniLM_L12_v2.onnx',
        model_name => 'ALL_MINILM_L12_V2',
        metadata => JSON('{"function" : "embedding", "embeddingOutput" : "embedding", "input": {"input": ["DATA"]}}'));
END;
/

/* ============================================================
   Verify the model was loaded successfully
   ============================================================ */
select model_name, algorithm, mining_function from user_mining_models
where model_name='ALL_MINILM_L12_V2';


/* ============================================================
   Quick smoke test — embed a single sentence inline
   ============================================================ */
SELECT VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 'The quick brown fox jumped' as DATA) AS embedding;


/* ============================================================
   Preview: embed each incident text without persisting results
   ============================================================ */
SELECT
  incident_text,
  VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING incident_text AS DATA) AS incident_vector
FROM support_incidents;

/* ============================================================
   Persist embeddings in a dedicated table for efficient search
   ============================================================ */
drop table support_incidents_vecs;

CREATE TABLE support_incidents_vecs AS
SELECT id, category, incident_text,
VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING incident_text as data) as incident_vector
FROM support_incidents;

select * from  support_incidents_vecs;


/* ============================================================
   Semantic similarity search — top 5 most relevant incidents
   for a free-text query, ranked by cosine distance
   ============================================================ */
SELECT id, incident_text
FROM support_incidents_vecs
ORDER BY VECTOR_DISTANCE(
  incident_vector,
  VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 'ETL issue with json files encoded in utf-8.' AS data),
  COSINE
)
FETCH APPROXIMATE FIRST 5 ROWS ONLY;

/* ============================================================
   Filtered similarity search — restricts candidates to a
   specific category before ranking by vector distance
   ============================================================ */
SELECT id, incident_text
FROM support_incidents_vecs
WHERE category = 'Connectivity'
ORDER BY VECTOR_DISTANCE(
  incident_vector,
  VECTOR_EMBEDDING(ALL_MINILM_L12_V2 USING 'Network issue with DNS servers outage' AS data),
  COSINE
)
FETCH APPROXIMATE FIRST 5 ROWS ONLY;
