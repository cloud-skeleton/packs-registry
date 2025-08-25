FROM python:3.13.7-alpine
ENTRYPOINT ["/bin/watchdog"]
RUN pip install --no-cache-dir python-nomad requests-unixsocket
COPY ./watchdog /bin/watchdog
