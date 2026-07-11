#!/usr/bin/env bash

set -euo pipefail

# Materialize the demo app's Secrets.swift into DerivedData so the decrypted
# credentials never land in the repo checkout (AINFRA-2640). Source, in order:
#
#   1. ~/.configure/Gravatar-SDK-iOS/secrets/Secrets.swift — internal
#      contributors, decrypted by `configure_apply` outside the repo.
#   2. Demo/Demo/Secrets.external-contributors.swift — seeded from the template on
#      first build and gitignored, so external contributors can paste their own
#      credentials into a clearly named file that can't be committed.
#   3. Demo/Demo/Secrets.template.swift — committed template with nil/empty
#      defaults, so the demo always builds without any secrets.

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

# The decrypted secret is absent — warn every time, even when a fallback exists,
# so internal contributors notice a missing/undecrypted secret.
echo "warning: decrypted demo secrets not found under ~/.configure. Internal contributors: run 'make setup-secrets'."

# Seed the external-contributors file from the template on first build. It is
# gitignored, so edits persist across builds and can't be committed.
if [ ! -f "$EXTERNAL" ]; then
    echo "Seeding ${EXTERNAL} from the template — external contributors: add your own credentials there."
    cp "$TEMPLATE" "$EXTERNAL"
fi

cp "$EXTERNAL" "$DESTINATION"
