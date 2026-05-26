FROM python:3.12-slim

WORKDIR /app

# install uv
RUN pip install --no-cache-dir uv

# copy dependency files
COPY pyproject.toml uv.lock .python-version README.md ./

# install third-party dependencies only
RUN uv sync --frozen --no-install-project

# copy source code
COPY src/ ./src/

# install current project
RUN uv sync --frozen

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]