FROM alpine:latest AS base
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /srv/app
ARG COMMON_DEPENDENCIES=ca-certificates
RUN apk --no-cache add python3 ${COMMON_DEPENDENCIES} && \
    rm -rf /var/cache/apk/*

FROM base AS builder
ARG BUILD_DEPENDENCIES="build-base musl-dev"
RUN apk --no-cache add python3-dev ${BUILD_DEPENDENCIES} && \
    python3 -m venv /opt/venv && \
    pip3 install --ignore-installed --no-cache-dir --upgrade --disable-pip-version-check pip setuptools wheel
COPY requirements.txt .
RUN pip3 install --ignore-installed --no-cache-dir -r requirements.txt && \
    rm -rf /var/cache/apk/*

FROM base AS runtime
ARG RUNTIME_DEPENDENCIES
RUN apk --no-cache add ${RUNTIME_DEPENDENCIES} && \
    rm -rf /var/cache/apk/* && \
    mkdir -p dba
COPY --from=builder /opt/venv /opt/venv
COPY . .
CMD [ "python3", "-u", "main.py" ]
