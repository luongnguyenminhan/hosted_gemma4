#!/usr/bin/env bash
set -euo pipefail

GGUF_REPO="${GGUF_REPO:-HauhauCS/Gemma-4-E4B-Uncensored-HauhauCS-Aggressive}"
GGUF_FILE="${GGUF_FILE:-Gemma-4-E4B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/models/gguf}"

export PYTHONUNBUFFERED=1
mkdir -p "${DOWNLOAD_DIR}"

GGUF_PATH="${DOWNLOAD_DIR}/${GGUF_FILE}"

if [ ! -f "${GGUF_PATH}" ]; then
  echo "[entrypoint] downloading ${GGUF_REPO}/${GGUF_FILE} -> ${DOWNLOAD_DIR}"
  hf download "${GGUF_REPO}" "${GGUF_FILE}" \
    --local-dir "${DOWNLOAD_DIR}"
else
  echo "[entrypoint] reusing cached ${GGUF_PATH}"
fi

echo "[entrypoint] launching sglang"
exec python3 -m sglang.launch_server \
  --model-path "${GGUF_PATH}" \
  --served-model-name "${SERVED_MODEL_NAME:-gemma-4-e4b-uncensored}" \
  --host 0.0.0.0 \
  --port 8000 \
  "$@"
