FROM lmsysorg/sglang:latest

ENV HF_HOME=/models
ENV HF_HUB_ENABLE_HF_TRANSFER=1

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
