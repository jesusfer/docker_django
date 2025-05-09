ARG PY_VERSION=python3.13-bookworm-slim

FROM ghcr.io/astral-sh/uv:${PY_VERSION}

ENV UV_COMPILE_BYTECODE=1
ENV HOME=/app

COPY requirements.txt .

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl ca-certificates gettext && \
    # python3-dev musl-dev && \
    uv pip install --no-cache --system -r requirements.txt && \
    mkdir ${HOME} && \
    useradd --home-dir ${HOME} --shell /bin/bash --user-group app && \
    chown -R app:app ${HOME}

USER app
