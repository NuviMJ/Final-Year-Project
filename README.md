# QoLGuard

**A Machine Learning-Powered Mobile Application for Early Detection of
Quality-of-Life Decline in Long-Term Medication Users**

QoLGuard helps people on long-term medication monitor how their treatment may be
affecting their quality of life. Rather than waiting for symptoms to become
severe, it analyses medication information, side-effect severity, treatment
burden, and lifestyle factors to produce an early warning.

> **Important:** QoLGuard is an intelligent decision-support system. It does not
> diagnose disease and does not replace a healthcare professional. It encourages
> timely medical consultation when risk indicators rise.

---

## Repository layout

```
.
├── mobile/      Flutter application (Dart 3.8, Material 3)
├── backend/     FastAPI service (Python 3.11+)
├── docs/        Specifications and design documents
├── ROADMAP.md   Stage-by-stage delivery plan
└── Mobile Application Specification.pdf
```

## Quick start

### Backend

```
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload
```

Then open http://localhost:8000/docs. Full instructions, including the PyCharm
run configuration, are in [`backend/README.md`](backend/README.md).

### Mobile

```
cd mobile
flutter pub get
flutter run
```

The app resolves its API host automatically: `10.0.2.2:8000` on the Android
emulator (which is how the emulator reaches the host machine's `localhost`) and
`localhost:8000` elsewhere. Override it with:

```
flutter run --dart-define=API_BASE_URL=https://your-host
```

## Architecture

```
Flutter app  ──HTTPS/JSON──►  FastAPI backend  ──►  SQLite / PostgreSQL
                                     │
                                     └──►  Prediction engine
                                           • rule_based (default)
                                           • sklearn (trained model)
```

The quality-of-life model is developed as a separate workstream. The backend
selects its prediction engine at runtime from the `PREDICTOR_BACKEND` setting,
and both engines implement the same interface — so the trained model can be
dropped in without changing the API or the mobile application. `/health` reports
which engine is active.

## Technology

| Layer | Stack |
|---|---|
| Mobile | Flutter, Riverpod, go_router, dio, freezed, sqflite, fl_chart |
| Backend | FastAPI, SQLAlchemy, Alembic, Pydantic, JWT authentication |
| ML | scikit-learn, NumPy, joblib |
| Database | SQLite (development), PostgreSQL (production) |

## Development status

Delivery follows [`ROADMAP.md`](ROADMAP.md). Current position:

- [x] **Stage 0** — Foundations: project structure, configuration, theming, health endpoint
- [ ] **Stage 1** — ML feature contract and rule-based baseline predictor
- [ ] **Stage 2** — Backend authentication and database
- [ ] **Stage 3** — Mobile app shell and authentication screens
- [ ] Stages 4–11 — see roadmap

## Testing

```
cd backend && pytest
cd mobile  && flutter test
```

---

*Final-year research project. Scope for Version 1 is defined in section 12 of
the specification.*
