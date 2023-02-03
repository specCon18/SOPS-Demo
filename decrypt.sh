#!/bin/sh
sops --decrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(.*PASSWORD:)$' --in-place ./secret.yaml