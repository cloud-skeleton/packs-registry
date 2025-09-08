FROM ghcr.io/cloud-skeleton/nomad-job-watchdog:latest
ENV IMAGES_VARIABLE_NAME=images
ENV PARAMS_VAR_ROOT_PATH=params
RUN pip install --no-cache-dir python-dxf==12.1.1 semver==3.0.4
COPY ./script /bin/script
