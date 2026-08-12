"""Tests for the prediction pipeline and its API surface.

Two of these carry more weight than the rest:

* `test_matches_reference_implementation` proves this service reproduces
  `deploy/predict_example.py`. If the two ever diverge, the model being served
  is no longer the model that was evaluated -- and the failure would otherwise
  be silent, because a mis-transformed input still yields a confident answer.

* `test_identical_input_gives_identical_output` proves NFR-02. A clinical
  decision-support tool that answers the same question differently on different
  days is not usable.
"""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.services.artifacts import load_bundle
from app.services.predictor import predict

# The reference patient from deploy/predict_example.py, whose expected output
# is documented in the bundle.
REFERENCE_PATIENT = {
    "Drug_Name": "Atorvastatin",
    "Age": 62,
    "Gender": "Female",
    "Dosage_mg": 40,
    "Treatment_Duration_Days": 45,
    "Concomitant_Drug_Count": 3,
    "Smoker": "Yes",
    "Alcohol_Use": "Occasional",
    "Sleep_Quality": 4,
    "Physical_Activity_Level": "low",
    "Daily_Steps": 3200,
    "Dietary_Habits": "unhealthy",
    "Sleep_Disorders": "yes",
    "Side_Effect": "Muscle Pain",
    "Severity": "Severe",
    "Seriousness": "severe",
    "Onset_Days": 12,
}

LOW_RISK_PATIENT = {
    **REFERENCE_PATIENT,
    "Age": 30,
    "Concomitant_Drug_Count": 0,
    "Smoker": "No",
    "Alcohol_Use": "No_Alcohol",
    "Sleep_Quality": 9,
    "Physical_Activity_Level": "high",
    "Daily_Steps": 11000,
    "Dietary_Habits": "healthy",
    "Sleep_Disorders": "no",
    "Severity": "Mild",
    "Seriousness": "mild",
    "Onset_Days": 2,
}

PREDICT_URL = "/api/v1/predict"


# --------------------------------------------------------------- the pipeline


def test_bundle_loads_with_expected_shape() -> None:
    bundle = load_bundle()

    assert bundle.class_order == ["Low", "Medium", "High"]
    assert len(bundle.columns) == 20
    assert len(bundle.drugs) == 10
    assert sorted(bundle.derived_fields()) == [
        "Drug_Class",
        "Drug_Rating",
        "Known_Side_Effect_Count",
        "Severe_Side_Effect_Count",
    ]


def test_matches_reference_implementation() -> None:
    """This service must reproduce the bundle's own reference prediction."""
    result = predict(REFERENCE_PATIENT)

    assert result["risk_category"] == "High"
    assert result["confidence"] == pytest.approx(0.9997, abs=1e-3)
    assert sum(result["probabilities"].values()) == pytest.approx(1.0, abs=1e-3)


def test_identical_input_gives_identical_output() -> None:
    """NFR-02 — the service is stateless, so predictions must be reproducible."""
    first = predict(REFERENCE_PATIENT)

    for _ in range(25):
        assert predict(REFERENCE_PATIENT) == first


def test_model_discriminates_between_risk_levels() -> None:
    """A model that returned one class for everything would pass every other test."""
    assert predict(REFERENCE_PATIENT)["risk_category"] == "High"
    assert predict(LOW_RISK_PATIENT)["risk_category"] == "Low"


def test_derived_features_are_not_requested_from_the_user() -> None:
    """The four drug-level features are looked up, never asked for (FR-05)."""
    bundle = load_bundle()

    for field in bundle.derived_fields():
        assert field not in REFERENCE_PATIENT


# --------------------------------------------------------------- the endpoints


def test_predict_returns_a_classification(client: TestClient) -> None:
    response = client.post(PREDICT_URL, json=REFERENCE_PATIENT)

    assert response.status_code == 200
    body = response.json()
    assert body["risk_category"] in {"Low", "Medium", "High"}
    assert set(body["probabilities"]) == {"Low", "Medium", "High"}
    assert body["model_version"]


def test_drug_list_reports_per_drug_dose_limits(client: TestClient) -> None:
    response = client.get("/api/v1/drugs")

    assert response.status_code == 200
    drugs = response.json()
    assert len(drugs) == 10

    insulin = next(drug for drug in drugs if drug["name"] == "Insulin")
    assert insulin["dose_unit"] == "IU/day"
    assert insulin["dose_min"] < insulin["dose_max"]


def test_schema_endpoint_describes_only_user_supplied_fields(client: TestClient) -> None:
    response = client.get("/api/v1/schema")

    assert response.status_code == 200
    body = response.json()
    names = {field["name"] for field in body["fields"]}

    assert len(names) == 16
    assert "Drug_Class" not in names  # derived, so the app must not ask for it
    assert body["class_order"] == ["Low", "Medium", "High"]


def test_health_reports_the_loaded_model(client: TestClient) -> None:
    body = client.get("/health").json()

    assert body["model_loaded"] is True
    assert body["supported_drugs"] == 10
    assert body["class_order"] == ["Low", "Medium", "High"]


# --------------------------------------------------------------- validation


@pytest.mark.parametrize(
    ("field", "value"),
    [
        ("Age", 17),  # below the trained minimum of 18
        ("Age", 91),  # above the trained maximum of 90
        ("Treatment_Duration_Days", 2000),  # beyond the 1825-day maximum
        ("Concomitant_Drug_Count", 5),  # beyond the 0-3 range
        ("Sleep_Quality", 1),  # below the 4-9 range seen in training
        ("Onset_Days", 60),  # beyond the 31-day maximum
        ("Daily_Steps", 500),  # below the 3000 minimum
    ],
)
def test_out_of_range_values_are_rejected(
    client: TestClient, field: str, value: float
) -> None:
    """Out-of-distribution input is refused rather than clamped or passed through."""
    response = client.post(PREDICT_URL, json={**REFERENCE_PATIENT, field: value})

    assert response.status_code == 422
    assert field in str(response.json()["detail"])


@pytest.mark.parametrize(
    ("field", "value"),
    [
        ("Alcohol_Use", "sometimes"),
        ("Severity", "Extreme"),
        ("Seriousness", "catastrophic"),
        ("Physical_Activity_Level", "very high"),
        ("Side_Effect", "Sneezing"),
    ],
)
def test_invalid_categories_are_rejected(
    client: TestClient, field: str, value: str
) -> None:
    response = client.post(PREDICT_URL, json={**REFERENCE_PATIENT, field: value})

    assert response.status_code == 422
    assert field in str(response.json()["detail"])


def test_boundary_values_are_accepted(client: TestClient) -> None:
    """The limits themselves are valid — rejection must start beyond them."""
    bundle = load_bundle()
    numeric = {
        name: spec
        for name, spec in bundle.user_fields().items()
        if spec["type"] == "number"
    }

    for edge in ("min", "max"):
        payload = {**REFERENCE_PATIENT}
        for name, spec in numeric.items():
            payload[name] = spec[edge]
        payload["Dosage_mg"] = bundle.drugs["Atorvastatin"][
            "dose_min" if edge == "min" else "dose_max"
        ]

        response = client.post(PREDICT_URL, json=payload)
        assert response.status_code == 200, f"{edge} boundary rejected: {response.json()}"


def test_unknown_drug_is_rejected(client: TestClient) -> None:
    response = client.post(PREDICT_URL, json={**REFERENCE_PATIENT, "Drug_Name": "Warfarin"})

    assert response.status_code == 422  # Literal type rejects it before the service
    assert "Drug_Name" in str(response.json()["detail"])


def test_dose_outside_the_drugs_own_range_is_rejected(client: TestClient) -> None:
    """500 mg is fine for paracetamol and nonsense for atorvastatin (max 80)."""
    response = client.post(PREDICT_URL, json={**REFERENCE_PATIENT, "Dosage_mg": 500})

    assert response.status_code == 422
    assert "Atorvastatin" in str(response.json()["detail"])


def test_missing_field_is_rejected(client: TestClient) -> None:
    payload = {**REFERENCE_PATIENT}
    del payload["Sleep_Quality"]

    response = client.post(PREDICT_URL, json=payload)

    assert response.status_code == 422
    assert "Sleep_Quality" in str(response.json()["detail"])
