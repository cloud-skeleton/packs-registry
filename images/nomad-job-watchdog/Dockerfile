FROM python:3.13.7-alpine
ENTRYPOINT ["/bin/watchdog"]
ENV PARAMS_VAR_BASE_PATH=params
RUN pip install --no-cache-dir python-nomad requests-unixsocket
COPY ./watchdog /bin/watchdog
