#!/usr/bin/env bash

SHARED_HELPERS=($(find shared/ -mindepth 1))

for PACK in $(find packs/ -mindepth 1 -maxdepth 1 -type d); do
    for HELPER in "${SHARED_HELPERS[@]}"; do
        HELPER_NAME="$(basename "${HELPER}")"
        ln -sf "../../../shared/${HELPER_NAME}" "${PACK}/templates/${HELPER_NAME}"
    done
done
