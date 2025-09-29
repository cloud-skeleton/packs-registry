FROM ghcr.io/cloud-skeleton/nomad-job-watchdog:latest
ENV IMAGES_VARIABLE_NAME=images
ENV DO_NOT_ALLOW_UPDATE_MAJOR_VERSION=true
ENV DO_NOT_ALLOW_UPDATE_MINOR_VERSION=false
ENV DO_NOT_ALLOW_UPDATE_PATCH_VERSION=false
ENV DO_NOT_ALLOW_UPDATE_PRERELEASE_VERSION=true
ENV DO_NOT_ALLOW_UPDATE_BUILD_VERSION=true
ENV INGRESS_WORKER_IPS="[]"
ENV MAIN_WORKER_IPS="[]"
RUN pip install --no-cache-dir python-dxf==12.1.1 semantic-version==2.10.0 cryptography==46.0.1
COPY ./script /bin/script
