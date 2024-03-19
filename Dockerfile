FROM python:3.13.0a3-alpine as base
ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1
RUN apk update && \
    apk upgrade && \
    apk add --no-cache libgcc
FROM python:3.13.0a3-alpine AS builder
ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1
WORKDIR /app
RUN apk update && \
    apk upgrade && \
    apk add gcc libc-dev libffi-dev cargo alpine-sdk bsd-compat-headers openssl-dev python3-dev && \
    python -m pip install --upgrade pip && \
    pip install poetry
RUN python -m venv /venv
COPY ["pyproject.toml", "./"]
COPY ["poetry.lock", "./"]
RUN poetry export -f requirements.txt | /venv/bin/pip install -r /dev/stdin
COPY . .
RUN poetry build && /venv/bin/pip install dist/*.whl

FROM base AS final
WORKDIR /app
COPY --from=builder /venv /venv
ENV PATH="/venv/bin:${PATH}"
# CMD [ "mitmproxy2swagger" ]

ENTRYPOINT [ "mitmproxy2swagger" ]
