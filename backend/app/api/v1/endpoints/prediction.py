"""Prediction endpoints.

Three routes, and the order matters to the mobile client:

    GET  /drugs     what medications can be assessed, and their dose limits
    GET  /schema    what to ask the patient, with the ranges to enforce
    POST /predict   the assessment itself
"""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, status

from app.schemas.prediction import (
    DrugInfo,
    FieldSpec,
    PredictionRequest,
    PredictionResponse,
    SchemaResponse,
)
from app.services.artifacts import load_bundle
from app.services.predictor import DoseOutOfRangeError, UnknownDrugError, predict

router = APIRouter(tags=["prediction"])


@router.get("/drugs", response_model=list[DrugInfo], summary="List supported medications")
def list_drugs() -> list[DrugInfo]:
    """Return every medication the model can assess.

    The dose limits come with it, so the app can bound its own dose input
    per drug instead of relying on the schema's global range, which spans all
    drugs at once and is far too wide to be useful per medication.
    """
    bundle = load_bundle()
    return [
        DrugInfo(
            name=name,
            drug_class=info["Drug_Class"],
            dose_unit=info.get("dose_unit", "mg/day"),
            dose_min=info["dose_min"],
            dose_max=info["dose_max"],
            typical_doses=info.get("typical_doses", []),
        )
        for name, info in sorted(bundle.drugs.items())
    ]


@router.get("/schema", response_model=SchemaResponse, summary="Input contract")
def get_schema() -> SchemaResponse:
    """Return the fields the patient must supply, with their constraints.

    The mobile client builds its assessment form from this rather than
    hard-coding ranges, so a retrained model with wider limits does not require
    an app release.
    """
    bundle = load_bundle()
    fields = [
        FieldSpec(
            name=name,
            type=spec["type"],
            required=spec.get("required", True),
            description=spec.get("description") or None,
            min=spec.get("min"),
            max=spec.get("max"),
            allowed_values=spec.get("allowed_values"),
        )
        for name, spec in bundle.user_fields().items()
    ]
    return SchemaResponse(fields=fields, class_order=bundle.class_order)


@router.post(
    "/predict",
    response_model=PredictionResponse,
    summary="Predict quality-of-life decline risk",
    responses={
        404: {"description": "The requested medication is not supported"},
        422: {"description": "A value falls outside the model's trained range"},
    },
)
def create_prediction(request: PredictionRequest) -> PredictionResponse:  # type: ignore[valid-type]
    """Classify one assessment as Low, Medium or High risk.

    Values outside the trained ranges are rejected rather than clamped or
    passed through. A prediction made on out-of-distribution input carries none
    of the accuracy measured during evaluation, so returning one would
    misrepresent its reliability to a patient.
    """
    try:
        result = predict(request.model_dump())
    except UnknownDrugError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Unsupported medication: {exc.args[0]}",
        ) from exc
    except DoseOutOfRangeError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=[
                {
                    "loc": ["body", "Dosage_mg"],
                    "msg": str(exc),
                    "type": "value_error.dose_out_of_range",
                }
            ],
        ) from exc
    return PredictionResponse(**result)
