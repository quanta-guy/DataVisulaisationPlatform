# DataVisulaisationPlatform

A Flutter + Python system for **real-time machine data acquisition and visualization**.  
It reads PLC data at the edge (Raspberry Pi), publishes via MQTT, streams to the cloud, and serves a web UI for live charts, alarms, and CSV exports. Firestore handles **real-time** reads; MongoDB stores **history**; a FastAPI layer exposes data/services to the UI. 

---

## Overview

- **Edge**: Siemens PLC → Raspberry Pi → MQTT publish.   
- **Ingest**: AWS EC2 subscriber processes topics and dual-writes to **Firestore (live)** and **MongoDB (historical)**.   
- **Backend**: Python **FastAPI** service for data access & actions.   
- **Frontend**: **Flutter** web/app for dashboards, multi-parameter charts, alarms, and downloads. 

---

## Repository structure

DataVisulaisationPlatform/
├─ frontend_scripts/ # Flutter web/app
├─ aws_service_scripts/ # Python services: MQTT subscriber, writers, helpers
├─ PLC/ # Edge publisher / PLC gateway scripts
├─ results/ # Screens / output snapshots
├─ README.md
└─ LICENSE (MIT)


Folders & license as per repo. :contentReference[oaicite:5]{index=5}

---

## Key features

- **Real-time monitoring** with 5-second Firestore updates; historical trend views from MongoDB.   
- **Alarms & notifications** on threshold breaches.   
- **Multi-parameter plotting**; quick parameter selection.   
- **CSV export** for offline analysis.   
- **Role-based access** (admin vs operator) via Firebase Auth. 

---

## Tech stack

- **Edge/Gateway**: Raspberry Pi, MQTT  
- **Data**: Firestore (real-time), MongoDB (history)   
- **Backend**: Python **FastAPI**   
- **Frontend**: **Flutter** (Dart) dashboard 

Language mix in this repo: mainly Dart with some Python. :contentReference[oaicite:14]{index=14}

---

## Quick start

> **Prerequisites**: Flutter SDK, Python 3.10+, access to a MongoDB instance, a Firebase project (Auth + Firestore), and an MQTT broker.

1) **Clone**
```bash
git clone https://github.com/quanta-guy/DataVisulaisationPlatform.git
cd DataVisulaisionPlatform
