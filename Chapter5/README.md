# Chapter 5 – Oracle AI Vector Search with ONNX Embeddings

This chapter introduces Oracle AI Vector Search: loading a pre-trained ONNX sentence-embedding model into the database and using it to generate and query vector embeddings for semantic similarity search.

## Environment

Tested on **Oracle Database 23ai Free** running locally on Docker.
Setup guide: https://www.oracle.com/database/free/get-started/

## Prerequisites

- Chapter 3 scripts executed (`ORA_AI_ENG` user and `ONNX_IMPORT` directory object created).
- Download the `all_MiniLM_L12_v2.onnx` model from the Oracle-provided ONNX model pack:
  https://docs.oracle.com/en/database/oracle/oracle-database/26/vecse/import-pretrained-models-onnx-format-vector-generation-database.html
- Copy the model file into `/tmp` inside the Docker container:

```bash
docker cp all_MiniLM_L12_v2.onnx oracle-26ai-free:/tmp/
```

## Scripts

| # | File | Run as | Purpose |
|---|------|--------|---------|
| 1 | `01_support_incidents_setup.sql` | ORA_AI_ENG | Creates and populates the SUPPORT_INCIDENTS table |
| 2 | `02_vector_embeddings.sql` | ORA_AI_ENG | Loads the ONNX model, generates embeddings, and runs cosine-similarity searches |

## Execution

```sql
sqlplus ora_ai_eng/password123@localhost:1521/FREEPDB1
@01_support_incidents_setup.sql
@02_vector_embeddings.sql
```

## Notes

- `DBMS_VECTOR.LOAD_ONNX_MODEL` requires the `metadata` JSON parameter to map the model's input/output tensors — the `file_name` parameter (not `model_data`) is used to reference the file in the directory object.
- `VECTOR_EMBEDDING` runs the loaded model entirely inside the database; no external service is called.
- `VECTOR_DISTANCE(..., COSINE)` measures semantic similarity; `FETCH APPROXIMATE FIRST N ROWS ONLY` uses a vector index (IVF or HNSW) when one exists.
