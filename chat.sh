#!/usr/bin/env bash
set -euo pipefail

URL="${URL:-http://localhost:8000}"
MODEL="${MODEL:-gemma-4-e4b-uncensored}"
PROMPT="${1:-Viết hàm Python kiểm tra số nguyên tố.}"
MAX_TOKENS="${MAX_TOKENS:-256}"
TEMPERATURE="${TEMPERATURE:-0.7}"
STREAM="${STREAM:-0}"

echo "[health] $URL/health"
curl -fsS "$URL/health" || { echo "health check failed"; exit 1; }
echo

body=$(cat <<EOF
{
  "model": "$MODEL",
  "messages": [{"role":"user","content":$(printf '%s' "$PROMPT" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')}],
  "max_tokens": $MAX_TOKENS,
  "temperature": $TEMPERATURE,
  "stream": $([ "$STREAM" = "1" ] && echo true || echo false)
}
EOF
)

echo "[chat] POST $URL/v1/chat/completions"
echo "body: $body"
echo

if [ "$STREAM" = "1" ]; then
  curl -sN -X POST "$URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    --data-binary "$body"
else
  resp=$(curl -fsS -X POST "$URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    --data-binary "$body")
  echo "[reply]"
  printf '%s\n' "$resp" | python3 -c 'import json,sys;d=json.load(sys.stdin);print(d["choices"][0]["message"]["content"]);print();print("[usage]",d.get("usage"))'
fi
