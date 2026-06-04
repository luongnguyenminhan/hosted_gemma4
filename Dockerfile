FROM vllm/vllm-openai:latest

ENV HF_HOME=/models
ENV VLLM_WORKER_MULTIPROC_METHOD=spawn

EXPOSE 8000

ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
