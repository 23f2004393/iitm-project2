FROM python:3.10-slim

# --- System deps required by Playwright browsers AND Tesseract ---
# Added 'tesseract-ocr' to the install list
RUN apt-get update && apt-get install -y \
    wget gnupg ca-certificates curl unzip \
    # Playwright dependencies
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 \
    libgtk-3-0 libgbm1 libasound2 libxcomposite1 libxdamage1 libxrandr2 \
    libxfixes3 libpango-1.0-0 libcairo2 \
    # Tesseract OCR engine
    tesseract-ocr \
    && rm -rf /var/lib/apt/lists/*

# --- Install Playwright + Chromium ---
RUN pip install playwright && playwright install --with-deps chromium

# --- Install uv package manager ---
RUN pip install uv

# --- Copy app to container ---
WORKDIR /app

COPY . .

ENV PYTHONUNBUFFERED=1
ENV PYTHONIOENCODING=utf-8

# Install project deps via uv

RUN uv sync --frozen

# Install missing deps inside uv environment
RUN uv pip install "langgraph>=0.1.0"

# Install FastAPI + Uvicorn + Dotenv
RUN uv pip install uvicorn fastapi python-dotenv

EXPOSE 7860

CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]


