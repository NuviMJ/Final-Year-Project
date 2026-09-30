# QoLGuard

**A machine learning-powered mobile app for early detection of quality-of-life
decline in long-term medication users.**

People on long-term medication often get used to side effects that slowly wear
down their daily life. QoLGuard asks about their medicines, side effects and
lifestyle, and uses a trained model to estimate their risk of quality-of-life
decline — Low, Medium or High — so they can raise it with a doctor early.

> QoLGuard is decision support. It does not diagnose and does not replace a
> healthcare professional.

## Features

- **Assessment** — four short steps: medicines and daily dose, personal
  details, side effects with severity, and daily life (sleep, activity, diet,
  smoking, alcohol).
- **Multiple medicines** — each medicine is assessed separately and the result
  highlights the one of greatest concern.
- **Risk result** — Low, Medium or High risk for each medicine, with the
  probability behind it and a plain-language explanation.
- **History** — every assessment is saved on the phone to look back on.
- **Trends** — a chart of how risk changes over time.
- **Share results** — send any result as a PDF or image through Gmail,
  WhatsApp or any other app.
- **Medication reminders** — weekly reminders on chosen days and times.
- **Learn** — short articles and health tips on medicine safety, diabetes,
  blood pressure, heart health and daily habits.
- **English and Sinhala** — the whole app switches language; medicine names
  stay in English.
- **Private by design** — no account; data stays on the phone.

## Project structure

- `mobile/` — Flutter app
- `backend/` — FastAPI service that runs the prediction model

---

*Final-year research project.*
