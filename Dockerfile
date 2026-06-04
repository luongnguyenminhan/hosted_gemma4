FROM vllm/vllm-openai:latest

ENV HF_HOME=/models
ENV VLLM_WORKER_MULTIPROC_METHOD=spawn

RUN pip install --no-cache-dir bitsandbytes

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
