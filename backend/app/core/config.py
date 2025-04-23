import os

class Settings:
    PROJECT_NAME: str = "eKiosk"
    API_VERSION: str = "v1"
    BACKEND_CORS_ORIGINS = ["*"]  # REMINDER: Cambiar esto en producción

settings = Settings()
