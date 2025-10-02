# EdTech Lead Management System (Scaffold)

## Setup (Windows PowerShell)

1) Create and activate venv (optional but recommended)
   - py -3 -m venv .venv
   - .\.venv\Scripts\Activate.ps1

2) Install dependencies
   - pip install -r requirements.txt

3) Configure environment
   - Copy .env.example to .env and fill values
     Copy-Item .env.example .env -Force
   - Copy .streamlit\secrets.example.toml to .streamlit\secrets.toml (optional)
     Copy-Item .streamlit\secrets.example.toml .streamlit\secrets.toml -Force

4) Run API (FastAPI/uvicorn)
   - $Env:API_AUTH_KEY = "your_key_here"   # optional in dev
   - uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 --reload
   - Visit http://localhost:8000/health

5) Run Dashboard (Streamlit)
   - streamlit run dashboard/streamlit_app.py

## Endpoints
- POST /predict                # single lead prediction
- POST /predict/batch          # batch prediction (JSON array)
- POST /leads                  # create a lead (minimal payload)
- GET  /leads?limit=50&offset=0  # list leads
- POST /leads/{lead_id}/predict # predict for a stored lead and update DB
- GET  /explain/global         # feature importance
- GET  /metrics/funnel         # funnel metrics
- GET  /metrics/channel        # channel metrics
- GET  /metrics/trends         # daily trend (count, hot_count)
- POST /jobs/send_followup_sms  # enqueue SMS follow-up via Redis + RQ
- GET  /health

Include header for auth if configured:
- X-API-Key: your_key_here

Example curl (Windows PowerShell use `\"` for quotes inside strings):
- curl -H "X-API-Key: your_key_here" -H "Content-Type: application/json" -d "{\"name\":\"Test\",\"channel\":\"Website\"}" http://localhost:8000/leads

## Notes
- Current prediction is a heuristic placeholder. ML integration will follow (LogReg + XGBoost, SHAP).
- Settings loader merges .env and Streamlit secrets.
- CORS origins configured via CORS_ALLOWED_ORIGINS in .env.

## Training pipeline
1) Generate synthetic training data
   - py -3 scripts/generate_synthetic_data.py

2) Train models (LogReg + XGBoost/RandomForest)
   - py -3 scripts/train_model.py
   - Artifacts saved to ./models (model_logreg.pkl, model_xgb.pkl or model_rf.pkl, preprocessor.pkl, metrics.json)

3) Start API and dashboard (as above). API will auto-load the best available model.

## Run tests
- pytest -q

## Docker quickstart
1) Ensure Docker Desktop is running
2) From the project folder:
   - docker compose up --build
3) Services exposed:
   - API: http://localhost:8000 (inside network: http://api:8000)
   - Dashboard: http://localhost:8501 (talks to API via http://api:8000)
   - Postgres: localhost:5432 (db: edtech, user: edtech, password: edtech)
   - Redis: localhost:6379
   - RQ Dashboard: http://localhost:9181

Migrations:
- The API service runs `alembic upgrade head` on startup. Locally, you can run:
  - set DATABASE_URL=postgresql+psycopg://edtech:edtech@localhost:5432/edtech
  - alembic upgrade head

Notes:
- The API service uses DATABASE_URL=postgresql+psycopg://edtech:edtech@db:5432/edtech and REDIS_URL=redis://redis:6379/0
- Background queue (RQ) worker runs as 'worker' service and listens to default queue
- To enqueue a test job:
  - curl -X POST -H "X-API-Key: your_key" "http://localhost:8000/jobs/send_followup_sms?to_number=+15551234567&message=Hello"
- To override env values for API, add them to .env; they’re merged in docker-compose
- To stop: docker compose down (add -v to remove volumes)

## Next Steps
- Connect Google Sheets: set GOOGLE_SERVICE_ACCOUNT_FILE or GOOGLE_SERVICE_ACCOUNT_BASE64, GOOGLE_SHEETS_SPREADSHEET_ID, GOOGLE_SHEETS_RANGE, then use backend.app.services.data.load_google_sheet in a sync job
- Configure SMTP/Twilio for real outreach
- Expand Streamlit dashboard with funnel visualization, channel trends, and SHAP per-lead explanations
