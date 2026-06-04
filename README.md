# hosted_gemma4

vLLM server for `TrevorJS/gemma-4-E4B-it-uncensored`.

## Requirements

- NVIDIA GPU + drivers
- NVIDIA Container Toolkit (`nvidia-ctk`)
- Docker Compose v2
- ~12GB VRAM (E4B bf16). Lower `--max-model-len` or use `--quantization` if tight.

## Run

```bash
cp .env.example .env       # add HF token if gated
docker compose up -d
docker compose logs -f vllm
```

First boot downloads weights into `./models` (persisted).

## Test

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma-4-e4b-uncensored",
    "messages": [{"role":"user","content":"hello"}]
  }'
```

## Tuning

- `--max-model-len`: context window. Raise if GPU allows.
- `--gpu-memory-utilization`: 0.85–0.95.
- `--tensor-parallel-size N`: multi-GPU.
- `--quantization fp8|awq|gptq`: if VRAM-bound.
