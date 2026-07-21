#!/usr/bin/env bash

set -euo pipefail

# Materialize the demo app's Secrets.swift into DerivedData so the decrypted
# credentials never land in the repo checkout.
#
# The compiled file comes from one of two sources, in order:
#
#   1. The a8c-secrets decrypted tree, for internal contributors who have run
#      `a8c-secrets decrypt`. `a8c-secrets which` fails when the file is absent.
#   2. Demo/Demo/Secrets.external-contributors.swift — gitignored, so external
#      contributors can copy Demo/Demo/Secrets.template.swift there and add
#      their credentials there with little-to-no-risk of them leaking.

TEMPLATE="${SRCROOT}/Demo/Secrets.template.swift"
EXTERNAL="${SRCROOT}/Demo/Secrets.external-contributors.swift"
DESTINATION="${SCRIPT_OUTPUT_FILE_0}"

mkdir -p "$(dirname "$DESTINATION")"

# Only rewrite the output when the content changed: a git checkout can bump the
# tracked .age mtime (re-running this phase) without the secret actually
# changing, and an unconditional copy would then recompile Secrets.swift.
apply() {
    echo "Applying demo secrets from ${1}"
    cmp -s "$1" "$DESTINATION" || cp "$1" "$DESTINATION"
    exit 0
}

if command -v a8c-secrets >/dev/null 2>&1 && SECRETS_FILE=$(a8c-secrets which Secrets.swift 2>/dev/null); then
    apply "$SECRETS_FILE"
fi

if [ -f "$EXTERNAL" ]; then
    apply "$EXTERNAL"
fi

echo "error: No secrets found! Internal contributors: run 'a8c-secrets decrypt'. External contributors: copy '${TEMPLATE}' to '${EXTERNAL}', fill in your own credentials, and build again."
exit 1
