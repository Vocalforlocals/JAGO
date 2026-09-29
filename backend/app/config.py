import os
from pathlib import Path
try:
    from dotenv import load_dotenv
    # Look for .env in backend/ or root
    backend_env = Path(__file__).resolve().parent.parent / ".env"
    root_env = Path(__file__).resolve().parent.parent.parent / ".env"
    if backend_env.exists():
        load_dotenv(dotenv_path=backend_env)
    elif root_env.exists():
        load_dotenv(dotenv_path=root_env)
    else:
        load_dotenv()
except ImportError:
    pass

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./jago.db")
SECRET_KEY = os.getenv("SECRET_KEY", "jago_national_scholarship_secure_secret_key_prod")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY") or ""
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 hours
DEMO_OTP = "123456"
