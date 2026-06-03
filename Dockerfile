# Career Counselling backend — Flask + Gemini + Playwright (PDF) on MongoDB Atlas.
# Playwright needs a real Chromium + its system libraries; installing them is
# only reliable as root, so we use a Docker build (works on Render's Docker env).
FROM python:3.11-slim

WORKDIR /app

# Install Python deps first (better layer caching).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install the Chromium browser + OS dependencies used for PDF generation.
RUN python -m playwright install --with-deps chromium

# App source.
COPY . .

ENV PORT=8080
EXPOSE 8080

# One worker (so the in-process pdf_data_store + Gemini model are shared across
# the report-template round-trip), multiple threads for concurrent requests, and
# a long timeout because AI generation / PDF rendering can take a while.
CMD gunicorn app:app --bind 0.0.0.0:${PORT} --workers 1 --threads 4 --timeout 300
