# QoLGuard Backend

FastAPI service for the QoLGuard mobile application. Serves quality-of-life
risk predictions from the trained XGBoost model.

> This service provides decision support only. It does not diagnose disease and
> does not replace a healthcare professional.

## Requirements

- Python 3.11 or newer
- PyCharm (recommended) or any editor

## Setup (PyCharm)

Open the **`backend/` folder** as the PyCharm project root — not the repository
root. This makes `app` an importable package and lets the bundled run
configuration work without adjustment.

1. **Create the interpreter** — *Settings → Project → Python Interpreter → Add →
   Virtualenv Environment → New*, base interpreter Python 3.11+, location
   `backend/venv`.
2. **Install dependencies** — PyCharm offers to install from `requirements.txt`
   when you open it. Otherwise, in the terminal:
   ```
   pip install -r requirements.txt
   ```
3. **Create your environment file**:
   ```
   copy .env.example .env
   ```
4. **Run** — pick the **QoLGuard API** run configuration (shipped in `.run/`)
   and press Run.

## Setup (command line)

```
cd backend
python -m venv venv
venv\Scripts\activate          # Windows
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload
```

## Verify it is running

| URL | What it shows |
|---|---|
| http://localhost:8000/health | Liveness probe — status, version, environment |
| http://localhost:8000/docs | Interactive Swagger UI |
| http://localhost:8000/redoc | ReDoc API reference |

## Tests

```
pytest
```

## Project structure

```
app/
├── main.py            FastAPI app, CORS, router mounting
├── core/config.py     Settings loaded from .env
├── api/v1/            Versioned endpoint routers
├── schemas/           Pydantic request/response models
└── services/          Prediction logic
deploy/                Trained model bundle (tracked — see below)
tests/                 pytest suite
```

## The model bundle

`deploy/` holds the frozen artefacts exported from the separate ML training
project. They are committed to git so a fresh clone reproduces the exact model
behind the reported evaluation results.

| File | Purpose |
|---|---|
| `model.json` | The trained XGBoost model, native format — **use this** |
| `model.joblib` | Pickled fallback; only if the native format fails to load |
| `preprocessor.joblib` | Fitted scaling and encoding pipeline |
| `feature_schema.json` | Input contract: fields, types, ranges, allowed values, class order |
| `drug_reference.json` | Per-drug values derived automatically after drug selection |
| `predict_example.py` | Reference implementation of a single prediction |

Prediction must always follow this order:

```
raw input → DataFrame → preprocessor.transform() → XGBoost → Low / Medium / High
```

Passing raw input straight to the model produces meaningless output **without
raising any error**, because the model was trained on scaled and encoded values.

### Version pinning is not optional

`preprocessor.joblib` was fitted under scikit-learn **1.9.0**. Loading it under
a different version raises `InconsistentVersionWarning` and may transform
features differently, invalidating every prediction with no visible failure.
The pin in `requirements.txt` exists for this reason — do not relax it.

Retraining the model is done in the ML project, never here. If predictions look
wrong, first establish whether the cause is backend code, input validation,
preprocessing, or the model itself.
