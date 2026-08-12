"""
Reference implementation of a single prediction. Copy this into the backend.

CRITICAL: the preprocessor and the model must be applied together, in this
order. The model was trained on scaled and encoded values, so passing raw
patient input straight to the model produces meaningless output without
raising any error.
"""

import json
from pathlib import Path

import joblib
import pandas as pd
import xgboost as xgb

BUNDLE = Path(__file__).parent

schema = json.loads((BUNDLE / "feature_schema.json").read_text())
drugs = json.loads((BUNDLE / "drug_reference.json").read_text())
preprocessor = joblib.load(BUNDLE / "preprocessor.joblib")

# Native format is preferred: it survives xgboost version changes, whereas a
# joblib pickle may not load on a different version than it was written with.
booster = xgb.Booster()
booster.load_model(str(BUNDLE / "model.json"))

CLASS_ORDER = schema["class_order"]           # ["Low", "Medium", "High"]
COLUMNS = schema["model_input_columns"]       # exact order the model expects


def predict(payload: dict) -> dict:
    """payload = the 16 fields the patient filled in, plus Drug_Name."""
    drug = payload["Drug_Name"]
    if drug not in drugs:
        raise ValueError(f"Unknown drug: {drug}")

    # Fill the four drug-derived features from the reference table.
    row = {k: v for k, v in payload.items() if k != "Drug_Name"}
    info = drugs[drug]
    row["Drug_Class"] = info["Drug_Class"]
    row["Known_Side_Effect_Count"] = info["Known_Side_Effect_Count"]
    row["Severe_Side_Effect_Count"] = info["Severe_Side_Effect_Count"]
    row["Drug_Rating"] = info["Drug_Rating"]

    missing = [c for c in COLUMNS if c not in row]
    if missing:
        raise ValueError(f"Missing required fields: {missing}")

    frame = pd.DataFrame([row])[COLUMNS]
    matrix = preprocessor.transform(frame)
    probabilities = booster.inplace_predict(matrix)[0]

    index = int(probabilities.argmax())
    return {
        "risk_category": CLASS_ORDER[index],
        "confidence": round(float(probabilities[index]), 4),
        "probabilities": {
            name: round(float(p), 4)
            for name, p in zip(CLASS_ORDER, probabilities)
        },
    }


if __name__ == "__main__":
    print(json.dumps(predict({
        "Age": 62,
        "Gender": "Female",
        "Drug_Name": "Atorvastatin",
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
    }), indent=2))
