"""Turns a validated assessment into a quality-of-life risk classification.

The sequence below is not negotiable and is the reason this logic lives in one
place rather than in the endpoint:

    raw input -> DataFrame -> preprocessor.transform() -> model -> probabilities

The model was trained on scaled and encoded values. Passing raw input straight
to it does not raise an error -- it returns a confident, meaningless answer.
Keeping the transform inside this function means no caller can skip it.

Adapted from `deploy/predict_example.py`, which is the reference implementation
shipped with the bundle.
"""

from __future__ import annotations

from typing import Any

import pandas as pd

from app.services.artifacts import Bundle, load_bundle


class UnknownDrugError(LookupError):
    """The requested medication is not in the drug reference table."""


class DoseOutOfRangeError(ValueError):
    """The dose is outside the range recorded for that specific drug."""

    def __init__(self, drug: str, dose: float, minimum: float, maximum: float, unit: str):
        self.drug = drug
        self.dose = dose
        self.minimum = minimum
        self.maximum = maximum
        self.unit = unit
        super().__init__(
            f"{dose:g} {unit} is outside the permitted range for {drug} "
            f"({minimum:g}–{maximum:g} {unit})."
        )


def validate_dose(drug_name: str, dose: float, bundle: Bundle | None = None) -> None:
    """Check the dose against the limits for this particular drug.

    The schema's global `Dosage_mg` range spans every drug at once (2.5 to
    4000), so it cannot catch 500 mg of atorvastatin -- a value that is
    plausible for paracetamol and dangerous nonsense for a statin. The
    per-drug limits in the reference table are the meaningful check.
    """
    bundle = bundle or load_bundle()
    info = bundle.drugs.get(drug_name)
    if info is None:
        raise UnknownDrugError(drug_name)

    minimum, maximum = info["dose_min"], info["dose_max"]
    if not minimum <= dose <= maximum:
        raise DoseOutOfRangeError(
            drug_name, dose, minimum, maximum, info.get("dose_unit", "mg/day")
        )


def assemble_feature_row(payload: dict[str, Any], bundle: Bundle) -> pd.DataFrame:
    """Build the single-row frame the preprocessor expects.

    Fills the four drug-derived features from the reference table, then orders
    the columns exactly as the model was trained on. Column order matters: the
    fitted pipeline addresses columns positionally once transformed.
    """
    drug_name = payload["Drug_Name"]
    info = bundle.drugs.get(drug_name)
    if info is None:
        raise UnknownDrugError(drug_name)

    row = {key: value for key, value in payload.items() if key != "Drug_Name"}
    for field in bundle.derived_fields():
        row[field] = info[field]

    missing = [column for column in bundle.columns if column not in row]
    if missing:
        # Reaching here means the request model and the schema have diverged,
        # which is a programming error rather than bad user input.
        raise RuntimeError(f"Assembled row is missing required columns: {missing}")

    return pd.DataFrame([row])[bundle.columns]


def predict(payload: dict[str, Any]) -> dict[str, Any]:
    """Classify one assessment as Low, Medium or High risk.

    Deterministic by construction: no state is carried between calls, so the
    same input always produces the same output (NFR-02).
    """
    bundle = load_bundle()

    validate_dose(payload["Drug_Name"], payload["Dosage_mg"], bundle)
    frame = assemble_feature_row(payload, bundle)

    matrix = bundle.preprocessor.transform(frame)
    probabilities = bundle.model.inplace_predict(matrix)[0]

    index = int(probabilities.argmax())
    classes = bundle.class_order
    return {
        "risk_category": classes[index],
        "confidence": round(float(probabilities[index]), 4),
        "probabilities": {
            name: round(float(value), 4)
            for name, value in zip(classes, probabilities)
        },
        "model_version": model_version(bundle),
    }


def model_version(bundle: Bundle | None = None) -> str:
    """A short identifier for the bundle currently loaded.

    Recorded on every prediction so a stored result can later be traced back to
    the model that produced it.
    """
    bundle = bundle or load_bundle()
    return (
        f"xgboost-{len(bundle.class_order)}class-"
        f"{bundle.model.num_features()}f-"
        f"{bundle.model.num_boosted_rounds()}r"
    )
