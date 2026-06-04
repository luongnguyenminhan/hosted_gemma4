FROM ghcr.io/ggml-org/llama.cpp:server-cuda

ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8000
ENV LLAMA_CACHE=/models

EXPOSE 8000
