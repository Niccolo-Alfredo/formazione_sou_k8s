# syntax=docker/dockerfile:1.4
FROM --platform=$BUILDPLATFORM python:3.10-alpine AS builder

WORKDIR /app

# Crea un utente non-root e passa a quell'utente
# UID/GID 1000 è comune per gli utenti non-root, ma puoi scegliere altro.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY requirements.txt ./
# Installa le dipendenze come utente non-root.
# Il mount di tipo cache è ancora utile per velocizzare le successive build.
RUN --mount=type=cache,target=/home/appuser/.cache/pip \
    pip3 install -r requirements.txt

COPY app.py ./ 
# Copia solo il file app.py
# Se ci fossero altri file necessari per l'esecuzione, li copieresti qui
# ad esempio: COPY templates/ ./templates/

EXPOSE 8000

ENTRYPOINT ["python3"]
CMD ["app.py"]


# La stage 'dev-envs' non è più rilevante per la build finale di Jenkins,
# ma la lascio commentata se volessi tenerla per usi di sviluppo locali.
# FROM builder as dev-envs
#
# RUN <<EOF
# apk update
# apk add git
# EOF
#
# RUN <<EOF
# addgroup -S docker
# adduser -S --shell /bin/bash --ingroup docker vscode
# EOF
# # install Docker tools (cli, buildx, compose)
# COPY --from=gloursdocker/docker / /