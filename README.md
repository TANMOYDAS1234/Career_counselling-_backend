# Career Counselling — Backend

Flask API powering the EduBot career-counselling app (web + Flutter). Uses
**Google Gemini** for AI generation, **Playwright** for PDF reports, and
**MongoDB Atlas** for storage.

## Endpoints (unchanged contract)

Auth: `/signup`, `/login`, `/api/update-profile` · Onboarding: `/api/save-onboarding`,
`/api/get-onboarding` · Assessment: `/api/save-questionnaire`,
`/api/generate-module-feedback` · Recommendations: `/api/get-top-3-careers` ·
Job detail: `/api/career-details`, `/api/save-job-role`, `/api/load-job-role`,
`/api/get-recent-job-role` · Report: `/api/get-mindset-report` · PDF: `/api/generate-pdf` ·
i18n: `/api/translate`, `/api/translate-batch`.

## Data model (MongoDB)

One document per user, keyed by a unique `username`, across five collections:
`users`, `user_session`, `job_role_details`, `onboarding_data`,
`career_recommendations`. Indexes are created automatically on startup.

## Environment variables

| Variable | Required | Notes |
|----------|----------|-------|
| `MONGODB_URI` | ✅ | `mongodb+srv://…` Atlas connection string (with the real password) |
| `MONGODB_DB` | – | Database name (default `career_counselling`) |
| `GEMINI_API_KEY_1/2/3` | ✅ (≥1) | Gemini keys; rotated on failure/rate-limit |
| `PORT` | – | Render injects this; defaults to 8080 locally |

Copy `.env.example` → `.env` for local development. **Never commit `.env`.**

## Run locally

```bash
pip install -r requirements.txt
python -m playwright install chromium
python app.py            # http://localhost:8080
```

## Deploy on Render

This repo ships a **Dockerfile** (Playwright needs system Chromium libs, which
install cleanly only in a Docker build) and a **render.yaml** Blueprint.

1. Push this repo to GitHub.
2. Render → **New → Blueprint** → select the repo (it reads `render.yaml`).
3. When prompted, set the secret env vars: `MONGODB_URI` (with your real DB
   password) and `GEMINI_API_KEY_1/2/3`.
4. In **MongoDB Atlas → Network Access**, allow Render's egress (or `0.0.0.0/0`
   for a quick start) so the service can connect.
5. Deploy. Your API base URL will be `https://<service>.onrender.com`.
6. Rebuild the Flutter app against it:
   `flutter run --dart-define=API_BASE_URL=https://<service>.onrender.com`

### Notes
- **Single worker** is intentional: `/api/generate-pdf` renders the report by
  having Playwright load `/report-template`, which reads an in-process cache, so
  both requests must hit the same worker.
- The free plan has 512 MB RAM; Chromium + Flask can be tight under load. If PDF
  generation OOMs, bump the plan.
- Atlas free tier (M0) is fine for this workload.
