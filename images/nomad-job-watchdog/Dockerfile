FROM python:3.13.7-alpine
ENTRYPOINT ["/bin/watchdog"]
ENV PARAMS_VAR_ROOT_PATH=params
ENV DEFAULTS_META_PREFIX=defaults
RUN pip install --no-cache-dir python-nomad requests-unixsocket
COPY ./watchdog /bin/watchdog
