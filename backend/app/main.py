"""QoLGuard API"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from app.api.v1.router import api_router
from app.core.config import get_settings
from app.services.artifacts import load_bundle
from app.services.predictor import model_version

settings = get_settings()

load_bundle()

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description=(
        "Backend for a machine learning-powered mobile application that gives "
        "long-term medication users an early warning of quality-of-life decline. "
        "This service is decision support only — it does not diagnose disease "
        "and does not replace a healthcare professional."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.api_v1_prefix)


class HealthResponse(BaseModel):
    status: str
    app: str
    version: str
    environment: str
    model_loaded: bool
    model_version: str
    supported_drugs: int
    class_order: list[str]


@app.get("/health", response_model=HealthResponse, tags=["system"])
def health() -> HealthResponse:
    """Liveness probe.

    The mobile app calls this on startup to confirm it can reach the backend,
    which turns "wrong base URL" into a clear message instead of a hang. It also
    reports which model is loaded, so a demo can never silently run against the
    wrong bundle.
    """
    bundle = load_bundle()
    return HealthResponse(
        status="ok",
        app=settings.app_name,
        version=settings.app_version,
        environment=settings.environment,
        model_loaded=True,
        model_version=model_version(bundle),
        supported_drugs=len(bundle.drugs),
        class_order=bundle.class_order,
    )


@app.get("/", include_in_schema=False)
def root() -> dict[str, str]:
    return {"message": f"{settings.app_name} v{settings.app_version}", "docs": "/docs"}


if __name__ == "__main__":
    # Importing this file only *defines* the application — it does not start a
    # server, which is why running it as a plain script exits immediately. This
    # block starts one, so PyCharm's green Run button on this file works.
    # Requires the working directory to be `backend/` so that "app.main"
    # resolves. Equivalent terminal command:
    #     uvicorn app.main:app --reload
    import uvicorn

    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)
