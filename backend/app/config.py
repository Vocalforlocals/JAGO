import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./jago.db")
SECRET_KEY = os.getenv("SECRET_KEY", "jago_national_tribal_mota_secure_secret_key_prod")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 hours
DEMO_OTP = "123456"
