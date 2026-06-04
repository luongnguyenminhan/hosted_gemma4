#!/usr/bin/env bash
set -euo pipefail

MODEL_REPO="${MODEL_REPO:-TrevorJS/gemma-4-E4B-it-uncensored}"
BASE_REPO="${BASE_REPO:-google/gemma-4-E4B}"
MERGED_DIR="${MERGED_DIR:-/models/merged}"

export HF_XET_HIGH_PERFORMANCE="${HF_XET_HIGH_PERFORMANCE:-1}"
export PYTHONUNBUFFERED=1

mkdir -p "${MERGED_DIR}"

echo "[entrypoint] downloading model: ${MODEL_REPO}"
MODEL_DIR="$(huggingface-cli download "${MODEL_REPO}")"
echo "[entrypoint] model dir: ${MODEL_DIR}"

echo "[entrypoint] downloading base preprocessor: ${BASE_REPO}"
BASE_DIR="$(huggingface-cli download "${BASE_REPO}" \
  preprocessor_config.json processor_config.json \
  tokenizer.json tokenizer.model tokenizer_config.json \
  special_tokens_map.json chat_template.json generation_config.json \
  2>/dev/null || true)"

if [ -z "${BASE_DIR}" ] || [ ! -d "${BASE_DIR}" ]; then
  BASE_DIR="$(huggingface-cli download "${BASE_REPO}")"
fi
echo "[entrypoint] base dir: ${BASE_DIR}"

echo "[entrypoint] merging into ${MERGED_DIR}"
rm -rf "${MERGED_DIR}"
mkdir -p "${MERGED_DIR}"
cp -rL "${MODEL_DIR}/." "${MERGED_DIR}/"
for f in preprocessor_config.json processor_config.json; do
  if [ -f "${BASE_DIR}/${f}" ]; then
    cp -f "${BASE_DIR}/${f}" "${MERGED_DIR}/${f}"
    echo "[entrypoint] copied ${f}"
  fi
done

exec python3 -m vllm.entrypoints.openai.api_server --model "${MERGED_DIR}" "$@"
