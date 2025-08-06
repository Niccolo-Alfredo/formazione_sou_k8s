# syntax=docker/dockerfile:1.4
# Usa la piattaforma di build per garantire la compatibilità
FROM --platform=$BUILDPLATFORM python:3.10-alpine AS builder

# Imposta la directory di lavoro all'interno del container
WORKDIR /app

# Crea un gruppo e un utente non-root per l'applicazione
# È buona pratica non eseguire l'applicazione come 'root' per motivi di sicurezza
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Passa all'utente non-root appena creato
USER appuser

# Crea la directory per la cache di pip nella home dell'utente e imposta i permessi corretti
# Questo risolve il warning "The directory '/home/appuser/.cache/pip' ... is not owned or is not writable"
RUN mkdir -p /home/appuser/.cache/pip && chown -R appuser:appgroup /home/appuser/.cache

# Copia il file delle dipendenze Python nella directory di lavoro
COPY requirements.txt ./

# Installa le dipendenze usando pip.
# Il mount di tipo cache è usato per riutilizzare i pacchetti scaricati nelle build successive,
# velocizzando il processo e riducendo il traffico di rete.
RUN --mount=type=cache,target=/home/appuser/.cache/pip \
    pip3 install -r requirements.txt

# Copia il file dell'applicazione Python nella directory di lavoro
# Assicurati che tutti i file necessari all'applicazione siano copiati qui.
# Se ci fossero sottocartelle (es. templates, static), andrebbero copiate separatamente:
# COPY templates/ ./templates/
# COPY static/ ./static/
COPY app.py ./

# Espone la porta su cui l'applicazione Flask sarà in ascolto
EXPOSE 8000

# Definisce il comando predefinito per avviare l'applicazione
# ENTRYPOINT definisce il comando principale del container
ENTRYPOINT ["python3"]
# CMD definisce gli argomenti passati a ENTRYPOINT
CMD ["app.py"]