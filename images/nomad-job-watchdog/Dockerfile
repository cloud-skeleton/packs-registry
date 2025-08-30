FROM python:3.13.7-alpine
ENTRYPOINT ["/bin/watchdog"]
ENV PARAMS_VAR_ROOT_PATH=params
ENV PARAMS_META_PREFIX=params
ENV VOLUMES_META_PREFIX=volumes
# RUN pip install --no-cache-dir python-nomad
RUN pip install --no-cache-dir https://github.com/masterjg/python-nomad/archive/refs/heads/volumes.zip
COPY ./watchdog /bin/watchdog
