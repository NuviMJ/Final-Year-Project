"""Request and response models for the prediction endpoint.

The request model is *generated* from `feature_schema.json` rather than written
by hand. Hand-writing it would create a second copy of the model's input
contract, and the two would eventually disagree -- at which point the API would
happily accept values the model was never trained on. Generating it means the
exported schema is the single source of truth, and FastAPI's interactive docs
show the real ranges and allowed values automatically.
"""

from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field, create_model

from app.services.artifacts import load_bundle


def _field_definition(name: str, spec: dict[str, Any]) -> tuple[Any, Any]:
    """Translate one entry of feature_schema.json into a Pydantic field."""
    description = spec.get("description") or name.replace("_", " ")

    if spec.get("type") == "number":
        return (
            float,
            Field(
                ...,
                ge=spec["min"],
                le=spec["max"],
                description=f"{description} ({spec['min']:g}–{spec['max']:g})",
            ),
        )

    allowed = tuple(spec["allowed_values"])
    # Literal accepts a tuple, so the permitted values come straight from the
    # schema and appear as an enum in the OpenAPI document.
    return (Literal[allowed], Field(..., description=description))


def _build_request_model() -> type[BaseModel]:
    bundle = load_bundle()

    definitions: dict[str, tuple[Any, Any]] = {
        "Drug_Name": (
            Literal[tuple(sorted(bundle.drugs))],
            Field(..., description="Medication being taken"),
        )
    }
    for name, spec in bundle.user_fields().items():
        definitions[name] = _field_definition(name, spec)

    return create_model(
        "PredictionRequest",
        __doc__=(
            "One patient assessment. Field names and ranges are taken directly "
            "from the model's exported feature schema."
        ),
        **definitions,
    )


# Built at import time so the contract is validated when the service starts,
# not on the first request a patient makes.
PredictionRequest = _build_request_model()


class PredictionResponse(BaseModel):
    """The model's verdict on one assessment."""

    risk_category: str = Field(description="Low, Medium or High")
    confidence: float = Field(description="Probability assigned to the predicted class")
    probabilities: dict[str, float] = Field(
        description="Probability for every class, keyed by class name"
    )
    model_version: str = Field(description="Identifies the deployment bundle in use")

    model_config = {
        "json_schema_extra": {
            "example": {
                "risk_category": "High",
                "confidence": 0.9997,
                "probabilities": {"Low": 0.0, "Medium": 0.0003, "High": 0.9997},
                "model_version": "xgboost-3class",
            }
        }
    }


class DrugInfo(BaseModel):
    """A supported medication and the dose limits that apply to it."""

    name: str
    drug_class: str
    dose_unit: str
    dose_min: float
    dose_max: float
    typical_doses: list[float]


class FieldSpec(BaseModel):
    """One input field, as the mobile client should present it."""

    name: str
    type: str
    required: bool
    description: str | None = None
    min: float | None = None
    max: float | None = None
    allowed_values: list[str] | None = None


class SchemaResponse(BaseModel):
    """The input contract, so the client derives its form from the model.

    Exposing this means the mobile application never hard-codes a range or a
    category list. When the model is retrained with wider ranges, the app picks
    them up without a release.
    """

    fields: list[FieldSpec]
    class_order: list[str]
