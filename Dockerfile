FROM lmsysorg/sglang:latest

ENV HF_HOME=/models
ENV HF_XET_HIGH_PERFORMANCE=1

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
