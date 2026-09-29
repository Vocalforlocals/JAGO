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
    # Startup: ensure tables and seed data if enabled
    Base.metadata.create_all(bind=engine)
    if os.getenv("SEED_DEMO_DATA", "true").lower() in ("true", "1", "yes"):
        seed_database()
    yield
    # Shutdown

app = FastAPI(
    title="JAGO — National Unified Scholarship Platform",
    description="Unified Scholarship Access & Multi-Source Verification Orchestrator for Students",
    version="1.0.0",
    lifespan=lifespan
)

# CORS setup
allowed_origins_env = os.getenv("ALLOWED_ORIGINS", "*")
allowed_origins = [o.strip() for o in allowed_origins_env.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins if allowed_origins else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security Headers & Request Guard Middleware
@app.middleware("http")
async def add_security_headers_and_guards(request, call_next):
    # Enforce maximum body size protection (10MB)
    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > 10 * 1024 * 1024:
        from starlette.responses import JSONResponse
        return JSONResponse(
            status_code=413,
            content={"detail": "Payload Too Large. Maximum allowed size is 10MB."}
        )

    response = await call_next(request)
    
    # Standard National Informatics & OWASP Security Headers
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Server"] = "JAGO-GovSec-Engine"
    return response

# Include Routers
app.include_router(auth.router)
app.include_router(student.router)
app.include_router(admin.router)

@app.get("/")
def root():
    return {
        "project": "JAGO",
        "tagline": "One Student. One Verified Profile. One Dashboard. Multiple Scholarship Schemes.",
        "portal": "National Scholarship Verification & Sanction Portal",
        "status": "online",
        "docs_url": "/docs"
    }

@app.get("/health")
@app.get("/api/health")
def health_check():
    db_type = "PostgreSQL" if "postgresql" in os.getenv("DATABASE_URL", "") else "SQLite"
    return {
        "status": "healthy",
        "service": "JAGO Unified Scholarship Engine",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "database": db_type,
        "version": "1.0.0"
    }
