FROM vllm/vllm-openai:latest

ENV HF_HOME=/models
ENV VLLM_WORKER_MULTIPROC_METHOD=spawn

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
