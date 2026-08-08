#!/usr/bin/env bash

PACKS="$(find packs/ -mindepth 1 -maxdepth 1 -type d)"
for PACK in ${PACKS}; do
    ln -sf ../../../templates/_vars.tpl "${PACK}/templates/_vars.tpl"
done
