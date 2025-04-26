ARG PY_VERSION=3.13-slim

###########
# BUILDER #
###########

# Pull official base image
FROM python:${PY_VERSION} AS builder

# Set work directory
WORKDIR /usr/src/app

# Install dependencies
COPY ./requirements.txt .

# Install deps
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gettext gcc python3-dev musl-dev && \
    # pip install --upgrade pip && \
    pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt

#########
# Final #
#########

# Pull official base image
FROM python:${PY_VERSION} AS final

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="$PATH:/app/.local/bin" \
    HOME=/app

COPY --from=builder /usr/src/app/wheels /wheels

# Install distribution dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq5 curl gettext gettext-base && \
    rm -rf /var/lib/apt/lists/* && \
    # Install Python dependencies
    mkdir ${HOME} && \
    useradd --home-dir ${HOME} --shell /bin/bash --user-group app && \
    chown -R app:app ${HOME} && \
    pip install --upgrade pip && \
    pip install --user --no-cache /wheels/*

USER app
