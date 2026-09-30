# QoLGuard Backend

The FastAPI service behind the QoLGuard app. It runs the trained XGBoost model
that predicts a Low, Medium or High risk of quality-of-life decline from a
patient's medicine, side effects and lifestyle.

> Decision support only — it does not diagnose or replace a healthcare
> professional.

## Features

- **Prediction** — `POST /api/v1/predict` returns the risk level and the
  probability of each level.
- **Supported medicines** — `GET /api/v1/drugs` lists the medicines the model
  knows, with their dose limits.
- **Form definition** — `GET /api/v1/schema` tells the app which questions to
  ask and which answers are allowed, so the app follows the model automatically.
- **Health check** — `GET /health` shows the service is running.
- **Nothing stored** — answers are scored and returned; no patient data is kept.

## Run

```
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --host 0.0.0.0
```

API documentation: http://localhost:8000/docs

The trained model is in `deploy/`. Keep the scikit-learn version pinned in
`requirements.txt`, or predictions become silently wrong.
