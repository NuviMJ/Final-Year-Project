# QoLGuard Mobile

The Flutter app of QoLGuard. It helps people on long-term medication spot an
early decline in their quality of life, by asking about their medicines, side
effects and lifestyle and showing a Low, Medium or High risk result.

> Decision support only — it does not diagnose or replace a healthcare
> professional.

## Features

- **Assessment** — medicines and daily dose, personal details, side effects
  with severity, and daily life.
- **Multiple medicines** — each medicine gets its own risk result.
- **Risk result** — risk level, probabilities and a plain-language explanation.
- **History and trends** — past results saved on the phone, with a risk chart
  over time.
- **Share results** — send a result as a PDF or image to Gmail, WhatsApp or any
  other app.
- **Medication reminders** — weekly notifications on chosen days and times.
- **Learn** — articles and health tips.
- **English and Sinhala** — medicine names stay in English.
- **No account** — all data stays on the phone.

## Run

Start the backend first (see [`../backend/README.md`](../backend/README.md)), then:

```
flutter pub get
flutter run
```

On a physical phone, point the app at your computer:

```
flutter run --dart-define=API_BASE_URL=http://<your-computer-ip>:8000
```
