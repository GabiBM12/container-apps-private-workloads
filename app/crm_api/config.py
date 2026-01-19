from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=None)

    # Storage
    AZURE_STORAGE_ACCOUNT_NAME: str
    AZURE_STORAGE_CONTAINER_NAME: str = "uploads"

    # Optional: public URL base if you want to return full URLs
    PUBLIC_BLOB_BASE_URL: str | None = None

    # Mailgun (comes from ACA env var -> Key Vault secret)
    MAILGUN_EMAIL_API_KEY: str
    MAILGUN_DOMAIN: str | None = None  # optional for nowif 


settings = Settings()