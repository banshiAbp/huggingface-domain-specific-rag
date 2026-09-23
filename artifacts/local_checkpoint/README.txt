RAG Checkpoint Contents
=======================

chunks.parquet
    Chunk text and complete source-lineage metadata.

bge_chunk_embeddings.npy
    Normalized BGE embeddings with shape (27434, 384).

rag_configuration.json
    Reproducibility parameters and model configuration.

hf_docs_milvus_clean.db
    Persistent Milvus Lite vector database.

Important:
The notebook, Python environment and Hugging Face model weights
are not stored in this checkpoint archive.