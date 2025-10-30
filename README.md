# DataVisulaisationPlatform

A Flutter + Python system for **real-time machine data acquisition and visualization**.  
Edge (Raspberry Pi/PLC) → MQTT → Cloud subscriber → Firestore (live) + MongoDB (history) → Flutter dashboard.

---

## Overview

- **Edge**: PLC → Raspberry Pi publishes telemetry via **MQTT**.
- **Ingest**: Cloud **Python services** subscribe to topics and **dual-write** to Firestore (real-time) and MongoDB (historical).
- **UI**: **Flutter** web/app for live charts, alarms, and CSV exports.
- **(Optional)**: Small FastAPI helpers for API endpoints and CORS.

---

## Repository structure

```
DataVisulaisationPlatform/
├─ frontend_scripts/        # Flutter web/app (dashboards, charts, auth)
├─ aws_service_scripts/     # Python services: MQTT subscriber, writers, helpers
├─ PLC/                     # Edge publisher / PLC gateway scripts
├─ results/                 # Screens / output snapshots
├─ README.md
└─ LICENSE                  # MIT
```

---

## Features

- **Live monitoring** from Firestore (low-latency reads)
- **Historical trends** from MongoDB (long-term storage)
- **Multi-parameter plotting** with quick parameter selection
- **Threshold-based alarms** (client-side or server-side)
- **CSV export** for offline analysis
- **Role-based access** with Firebase Auth (admin/operator)

---

## Tech stack

- **Edge/Gateway**: Raspberry Pi, MQTT
- **Backend**: Python (MQTT subscriber, writers, optional FastAPI)
- **Data**: Firestore (real-time), MongoDB (history)
- **Frontend**: Flutter (Dart) web/app

---

## Prerequisites

- Flutter SDK installed (`flutter doctor` should pass)
- Python 3.10+
- Access to:
  - An **MQTT** broker
  - A **MongoDB** instance
  - A **Firebase** project (Auth + Firestore)

---

## Quick start

> Adjust names/scripts to match your local setup; this repo groups code by responsibility to keep it portable.

### 1) Clone

```bash
git clone https://github.com/quanta-guy/DataVisulaisationPlatform.git
cd DataVisulaisationPlatform
```

### 2) Frontend (Flutter)

```bash
cd frontend_scripts
# set API/base URLs and Firebase client config in your environment or config file
flutter pub get
# for web
flutter run -d chrome
# for mobile, pick your device
# flutter run
```

### 3) Cloud subscriber & writers (Python)

```bash
cd ../aws_service_scripts
python -m venv .venv
# Windows: .venv\Scripts\activate
# Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
# export environment variables (see Configuration below)
# then start your subscriber / writer entrypoint script
python path_to_your_subscriber.py
```

### 4) Edge publisher (Raspberry Pi)

- In `PLC/`, configure the publisher with your `MQTT_BROKER`, `MQTT_PORT`, credentials, and base topic.
- Point the script to your PLC and publish telemetry at your chosen interval.
- Run as a systemd service for resilience (optional).

---

## Configuration

Create a `.env` or use your runtime environment for secrets:

### MQTT (edge + cloud)
- `MQTT_BROKER`
- `MQTT_PORT`
- `MQTT_USERNAME`
- `MQTT_PASSWORD`
- `MQTT_TOPIC_BASE`

### MongoDB (history)
- `MONGODB_URI`
- `MONGODB_DB`
- `MONGODB_COLLECTION`

### Firestore / Firebase (real-time + auth)
- `GOOGLE_APPLICATION_CREDENTIALS` (service account JSON path for server components)
- Frontend Firebase config (apiKey, authDomain, projectId, etc.) via your Flutter config

### Backend (if using FastAPI helpers)
- `API_BASE_URL`
- `ALLOWED_ORIGINS`

> Keep secrets out of source control. Use `.gitignore` for `.env` and service account files.

---

## Data model (typical)

- **Topics**: `site/{site_id}/line/{line_id}/machine/{machine_id}/{signal}`
- **Payload**: JSON with timestamp, value, quality (example)
- **Firestore**: recent, frequently-read documents for live UI
- **MongoDB**: append-only timeseries collections for analytics

---

## Testing & linting

- **Flutter**: `flutter test`
- **Python**: add `pytest` and `ruff` (or `flake8`) to `requirements-dev.txt` and run locally or in CI

---

## Deployment notes

- **Edge**: run publisher as a systemd service on the Pi
- **Cloud**: run subscriber/writers as services (PM2, systemd, Docker, or your cloud’s app runner)
- **Frontend**: `flutter build web` and serve via any static host / CDN

---

## Roadmap

- Predictive maintenance models on MongoDB history
- Customizable dashboards by role
- Improved multi-tenant/topic configuration

---
## Contributor
Balaji Jayaprakash - @balajijp8 (https://github.com/balajijp8-boop)
---

## Contributing

PRs welcome. Keep commits focused and add a short rationale in the description.  
For issues, include repro steps, logs, and platform info.

---

## License


MIT — see `LICENSE`.
