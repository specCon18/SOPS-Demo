#!/bin/sh
sops --encrypt --age $(cat $SOPS_AGE_KEY_FILE |grep -oP "public key: \K(.*)") --encrypted-regex '^(environment)$' --in-place ./secret.yaml