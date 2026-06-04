#!/usr/bin/env bash
set -euo pipefail

MODEL_REPO="${MODEL_REPO:-TrevorJS/gemma-4-E4B-it-uncensored}"
BASE_REPO="${BASE_REPO:-google/gemma-4-E4B}"
MERGED_DIR="${MERGED_DIR:-/models/merged}"

mkdir -p "${MERGED_DIR}"

echo "[entrypoint] downloading model: ${MODEL_REPO}"
MODEL_DIR="$(python3 -c "from huggingface_hub import snapshot_download; print(snapshot_download(repo_id='${MODEL_REPO}'))")"

echo "[entrypoint] downloading base preprocessor: ${BASE_REPO}"
BASE_DIR="$(python3 -c "from huggingface_hub import snapshot_download; print(snapshot_download(repo_id='${BASE_REPO}', allow_patterns=['preprocessor_config.json','processor_config.json','tokenizer*','special_tokens_map.json','chat_template*','generation_config.json']))")"

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
