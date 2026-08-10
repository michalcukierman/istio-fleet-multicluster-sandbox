#!/usr/bin/env bash
set -euo pipefail

source .ovhrc

USER_NAME="$(whoami)"

NAME="${NAME:-streamx-sandbox-${USER_NAME}}"
SSH_KEY_NAME="${SSH_KEY_NAME:-streamx-sandbox-${USER_NAME}}"

command -v ovhcloud >/dev/null 2>&1 || {
  echo "Missing required command: ovhcloud" >&2
  exit 1
}

scalar() {
  sed -e 's/^"//' -e 's/"$//'
}

echo "Looking for instance '$NAME'..."

INSTANCE_ID="$(
  ovhcloud cloud instance list \
    --filter "name==\"$NAME\"" \
    -o id \
    | head -n 1 \
    | scalar
)"

if [ -n "$INSTANCE_ID" ]; then
  echo "Deleting instance '$NAME' ($INSTANCE_ID)..."

  ovhcloud cloud instance delete "$INSTANCE_ID"

  echo "Instance deleted."
else
  echo "Instance '$NAME' does not exist."
fi

echo "Looking for SSH key '$SSH_KEY_NAME'..."

SSH_KEY_ID="$(
  ovhcloud cloud ssh-key list \
    --filter "name==\"$SSH_KEY_NAME\"" \
    -o id \
    | head -n 1 \
    | scalar
)"

if [ -n "$SSH_KEY_ID" ]; then
  echo "Deleting OVHcloud SSH key '$SSH_KEY_NAME' ($SSH_KEY_ID)..."

  ovhcloud cloud ssh-key delete "$SSH_KEY_ID"

  echo "SSH key deleted."
else
  echo "SSH key '$SSH_KEY_NAME' does not exist."
fi

echo
echo "Cleanup complete."