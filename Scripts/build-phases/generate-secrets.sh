#!/usr/bin/env bash

set -euo pipefail

# Materialize the demo app's Secrets.swift into DerivedData so the decrypted
# credentials never land in the repo checkout.
#
# The compiled file comes from one of two sources, in order:
#
#   1. The a8c-secrets decrypted tree, for internal contributors. The phase runs
#      `a8c-secrets decrypt` itself so that a rotated .age cannot compile as the
#      secret it replaced. `a8c-secrets which <file>` fails when the file is absent.
#   2. Demo/Demo/Secrets.external-contributors.swift — gitignored, so external
#      contributors can copy Demo/Demo/Secrets.template.swift there and add
#      their credentials there with little-to-no-risk of them leaking.

TEMPLATE="${SRCROOT}/Demo/Secrets.template.swift"
EXTERNAL="${SRCROOT}/Demo/Secrets.external-contributors.swift"
DESTINATION="${SCRIPT_OUTPUT_FILE_0}"

mkdir -p "$(dirname "$DESTINATION")"

# Copy unconditionally: a git checkout can bump the tracked .age mtime without
# the secret changing, re-running this phase and recompiling Secrets.swift for
# nothing. Accepted over a `cmp` guard, which would skip the write and leave the
# output older than its input, keeping the phase permanently out of date.
apply() {
    echo "Applying demo secrets from ${1}"
    cp "$1" "$DESTINATION"
    exit 0
}

if command -v a8c-secrets >/dev/null 2>&1; then
    a8c-secrets decrypt --non-interactive >/dev/null \
        || echo "warning: 'a8c-secrets decrypt' failed; building with the secrets left by its last successful run"

    if SECRETS_FILE=$(a8c-secrets which Secrets.swift 2>/dev/null); then
        apply "$SECRETS_FILE"
    fi
fi

if [ -f "$EXTERNAL" ]; then
    apply "$EXTERNAL"
fi

echo "error: No secrets found! Internal contributors: run 'a8c-secrets decrypt'. External contributors: copy '${TEMPLATE}' to '${EXTERNAL}', fill in your own credentials, and build again."
exit 1
