#!/usr/bin/env bash

set -euo pipefail

# Materialize the demo app's Secrets.swift into DerivedData so the decrypted
# credentials never land in the repo checkout.
#
# The compiled file comes from one of two sources, in order:
#
#   1. ${OUT_OF_REPO_SECRETS_ROOT}/Secrets.swift — internal
#      contributors, decrypted by `configure_apply` outside the repo.
#   2. Demo/Demo/Secrets.external-contributors.swift — gitignored, so external
#      contributors can copy Demo/Demo/Secrets.template.swift there and add
#      their credentials there with little-to-no-risk of them leaking.

SECRETS_FILE="${HOME}/.configure/Gravatar-SDK-iOS/secrets/Secrets.swift"
TEMPLATE="${SRCROOT}/Demo/Secrets.template.swift"
EXTERNAL="${SRCROOT}/Demo/Secrets.external-contributors.swift"
DESTINATION="${SCRIPT_OUTPUT_FILE_0}"

mkdir -p "$(dirname "$DESTINATION")"

if [ -f "$SECRETS_FILE" ]; then
    echo "Applying demo secrets from ${SECRETS_FILE}"
    cp "$SECRETS_FILE" "$DESTINATION"
    exit 0
fi

if [ -f "$EXTERNAL" ]; then
    echo "Applying demo secrets from ${EXTERNAL}"
    cp "$EXTERNAL" "$DESTINATION"
    exit 0
fi

echo "error: No secrets found! Internal contributors: run 'make setup-secrets'. External contributors: copy '${TEMPLATE}' to '${EXTERNAL}', fill in your own credentials, and build again."
exit 1
