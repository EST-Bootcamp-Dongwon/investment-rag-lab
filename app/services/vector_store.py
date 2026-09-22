import time
import uuid

# from qdrant_client import QdrantClient
# from qdrant_client.models import Distance, VectorParams, PointStruct, Filter, FieldCondition, MatchValue

from app.core.config import settings


class VectorStore:
    def __init__(self):
        pass

    def upsert_chunks(self, chunks: list[dict], vectors: list[list[float]]):
        pass

    def search(self, query_vector: list[float], top_k: int = 4, domain: str | None = None):
        return []
