#!/usr/bin/env sh

SHARED_HELPERS=($(find shared/ -mindepth 1))

for PACK in $(find packs/ -mindepth 1 -maxdepth 1 -type d); do
    for HELPER in "${SHARED_HELPERS[@]}"; do
        cp -f ${HELPER} ${PACK}/templates/
    done
done