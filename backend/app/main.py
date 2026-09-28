import os
from datetime import datetime
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import engine, Base
from .seed import seed_database
from .routes import auth, student, admin

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: ensure tables and seed data
    Base.metadata.create_all(bind=engine)
    seed_database()
    yield
    # Shutdown

app = FastAPI(
    title="JAGO Backend — Ministry of Tribal Affairs, Government of India",
    description="Unified Scholarship Access & Multi-Source Verification Orchestrator for Tribal Students",
    version="1.0.0",
    lifespan=lifespan
)

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(auth.router)
app.include_router(student.router)
app.include_router(admin.router)

@app.get("/")
def root():
    return {
        "project": "JAGO",
        "tagline": "One Student. One Verified Profile. One Dashboard. Five Scholarship Schemes.",
        "ministry": "Ministry of Tribal Affairs, Government of India",
        "portal": "National ST Scholarship Verification & Sanction Portal",
        "status": "online",
        "docs_url": "/docs"
    }

@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "service": "JAGO Unified Scholarship Engine",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "database": "SQLite (jago.db)",
        "version": "1.0.0"
    }
