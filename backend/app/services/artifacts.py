"""Loads the frozen deployment bundle produced by the ML training project.

The bundle in `deploy/` is the only interface between model training and this
service. Nothing here retrains, refits, or modifies it.

Artefacts are loaded once per process and cached. Loading them per request
would add roughly a second to every prediction for no benefit, since they never
change while the service is running.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

import joblib
import sklearn
import xgboost as xgb

from app.core.config import get_settings

# The preprocessing pipeline was fitted under this scikit-learn release.
# Loading it under a different one raises InconsistentVersionWarning and may
# apply different transformations -- silently. Predictions would still be
# returned, and would still look plausible, but would no longer correspond to
# the model that was evaluated. Refusing to start is the safer failure.
REQUIRED_SKLEARN_VERSION = "1.9.0"

_REQUIRED_FILES = (
    "model.json",
    "preprocessor.joblib",
    "feature_schema.json",
    "drug_reference.json",
)


class ArtifactError(RuntimeError):
    """Raised when the deployment bundle cannot be loaded safely."""


@dataclass(frozen=True)
class Bundle:
    """The loaded deployment bundle."""

    model: xgb.Booster
    preprocessor: Any
    schema: dict[str, Any]
    drugs: dict[str, dict[str, Any]]

    @property
    def columns(self) -> list[str]:
        """Input columns in the exact order the model expects them."""
        return self.schema["model_input_columns"]

    @property
    def class_order(self) -> list[str]:
        """Output classes in index order, i.e. ["Low", "Medium", "High"]."""
        return self.schema["class_order"]

    @property
    def fields(self) -> dict[str, dict[str, Any]]:
        """Per-field contract: type, range, allowed values, and origin."""
        return self.schema["fields"]

    def user_fields(self) -> dict[str, dict[str, Any]]:
        """Fields the patient supplies, excluding those derived from the drug."""
        return {
            name: spec
            for name, spec in self.fields.items()
            if spec.get("source") != "derived_from_drug"
        }

    def derived_fields(self) -> list[str]:
        """Fields resolved from the drug reference rather than asked of the user."""
        return [
            name
            for name, spec in self.fields.items()
            if spec.get("source") == "derived_from_drug"
        ]


def _deploy_dir() -> Path:
    settings = get_settings()
    path = Path(settings.deploy_dir)
    if not path.is_absolute():
        # Resolve relative to the backend package root so the service behaves
        # identically whether started from backend/ or from an IDE run config.
        path = Path(__file__).resolve().parents[2] / path
    return path


@lru_cache
def load_bundle() -> Bundle:
    """Load and cache the deployment bundle.

    Raises `ArtifactError` on anything that would make predictions unreliable,
    rather than degrading quietly.
    """
    directory = _deploy_dir()

    if not directory.is_dir():
        raise ArtifactError(f"Deployment bundle directory not found: {directory}")

    missing = [name for name in _REQUIRED_FILES if not (directory / name).is_file()]
    if missing:
        raise ArtifactError(
            f"Deployment bundle is incomplete. Missing from {directory}: "
            f"{', '.join(missing)}"
        )

    if sklearn.__version__ != REQUIRED_SKLEARN_VERSION:
        raise ArtifactError(
            f"preprocessor.joblib was fitted under scikit-learn "
            f"{REQUIRED_SKLEARN_VERSION} but this environment has "
            f"{sklearn.__version__}. Loading across versions can change how "
            f"features are transformed without raising an error, which would "
            f"invalidate every prediction. Install the pinned version from "
            f"requirements.txt."
        )

    schema = json.loads((directory / "feature_schema.json").read_text(encoding="utf-8"))
    drugs = json.loads((directory / "drug_reference.json").read_text(encoding="utf-8"))
    preprocessor = joblib.load(directory / "preprocessor.joblib")

    # The native format is preferred over model.joblib because it survives
    # xgboost version changes, whereas a pickle may not load at all.
    model = xgb.Booster()
    model.load_model(str(directory / "model.json"))

    bundle = Bundle(
        model=model, preprocessor=preprocessor, schema=schema, drugs=drugs
    )
    _verify_consistency(bundle)
    return bundle


def _verify_consistency(bundle: Bundle) -> None:
    """Check the artefacts agree with each other before serving any traffic.

    These are cheap checks against mistakes that would otherwise surface as
    wrong predictions rather than as errors.
    """
    declared = bundle.schema.get("n_features")
    actual = len(bundle.columns)
    if declared is not None and declared != actual:
        raise ArtifactError(
            f"feature_schema.json declares n_features={declared} but lists "
            f"{actual} input columns."
        )

    if not bundle.class_order:
        raise ArtifactError("feature_schema.json declares no class_order.")

    # Every drug must supply all four derived features, or a prediction would
    # be assembled with missing columns.
    derived = bundle.derived_fields()
    for name, info in bundle.drugs.items():
        absent = [field for field in derived if field not in info]
        if absent:
            raise ArtifactError(
                f"drug_reference.json entry '{name}' is missing derived "
                f"fields: {', '.join(absent)}"
            )
