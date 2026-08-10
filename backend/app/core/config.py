"""Application configuration.

All settings are read from environment variables, falling back to the values in
`.env` (see `.env.example`). Nothing secret is hard-coded here.
"""

from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Typed application settings."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # --- Application ---
    app_name: str = "QoLGuard API"
    app_version: str = "0.1.0"
    api_v1_prefix: str = "/api/v1"
    environment: Literal["development", "testing", "production"] = "development"
    debug: bool = True

    # --- CORS ---
    # Stored as a string so it can be set from a plain environment variable
    # without JSON quoting. Use `cors_origin_list` to read it.
    cors_origins: str = "*"

    @property
    def cors_origin_list(self) -> list[str]:
        """CORS origins as a list, split from the comma-separated setting."""
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    """Return the cached settings instance.

    Cached so the `.env` file is parsed once per process, and so tests can
    override it via `get_settings.cache_clear()`.
    """
    return Settings()
