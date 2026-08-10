#!/usr/bin/env bash
set -euo pipefail

source .ovhrc

REGION="${REGION:-WAW1}"
USER_NAME="$(whoami)"
NAME="${NAME:-streamx-sandbox-${USER_NAME}}"
FLAVOR="${FLAVOR:-b3-64}"
IMAGE="${IMAGE:-Ubuntu 24.04}"

SSH_KEY_NAME="${SSH_KEY_NAME:-streamx-sandbox}"
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/$SSH_KEY_NAME}"

command -v ovhcloud >/dev/null 2>&1 || {
  echo "Missing required command: ovhcloud" >&2
  exit 1
}

command -v ssh-keygen >/dev/null 2>&1 || {
  echo "Missing required command: ssh-keygen" >&2
  exit 1
}

scalar() {
  sed -e 's/^"//' -e 's/"$//'
}

# Create local SSH key if needed.
if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "Creating SSH key '$SSH_KEY_PATH'..."

  mkdir -p "$(dirname "$SSH_KEY_PATH")"

  ssh-keygen \
    -t ed25519 \
    -N "" \
    -C "$SSH_KEY_NAME" \
    -f "$SSH_KEY_PATH"
fi

# Recreate public key if only the private key exists.
if [ ! -f "$SSH_KEY_PATH.pub" ]; then
  ssh-keygen -y \
    -f "$SSH_KEY_PATH" \
    > "$SSH_KEY_PATH.pub"
fi

# Register SSH key in OVHcloud if needed.
SSH_KEY_ID="$(
  ovhcloud cloud ssh-key list \
    --filter "name==\"$SSH_KEY_NAME\"" \
    -o id \
    | head -n 1 \
    | scalar
)"

if [ -z "$SSH_KEY_ID" ]; then
  echo "Registering SSH key '$SSH_KEY_NAME' in OVHcloud..."

  ovhcloud cloud ssh-key create \
    --name "$SSH_KEY_NAME" \
    --public-key "$(cat "$SSH_KEY_PATH.pub")" \
    --region "$REGION"
else
  echo "SSH key '$SSH_KEY_NAME' already registered"
fi

echo "Resolving flavor '$FLAVOR' in '$REGION'..."

FLAVOR_ID="$(
  ovhcloud cloud reference list-flavors \
    --region "$REGION" \
    --filter "name==\"$FLAVOR\"" \
    -o id \
    | head -n 1 \
    | scalar
)"

if [ -z "$FLAVOR_ID" ]; then
  echo "Flavor '$FLAVOR' not found in '$REGION'" >&2
  exit 1
fi

echo "Resolving image '$IMAGE' in '$REGION'..."

IMAGE_ID="$(
  ovhcloud cloud reference list-images \
    --region "$REGION" \
    --os-type linux \
    --filter "name==\"$IMAGE\"" \
    -o id \
    | head -n 1 \
    | scalar
)"

if [ -z "$IMAGE_ID" ]; then
  echo "Image '$IMAGE' not found in '$REGION'" >&2
  exit 1
fi

echo
echo "Creating OVHcloud instance:"
echo "  Name:      $NAME"
echo "  Region:    $REGION"
echo "  Flavor:    $FLAVOR"
echo "  Flavor ID: $FLAVOR_ID"
echo "  Image:     $IMAGE"
echo "  Image ID:  $IMAGE_ID"
echo "  SSH key:   $SSH_KEY_NAME"
echo

echo "Checking for existing instance '$NAME'..."

INSTANCE_ID="$(
  ovhcloud cloud instance list \
    --filter "name==\"$NAME\"" \
    -o id \
    | head -n 1 \
    | scalar
)"

if [ -n "$INSTANCE_ID" ]; then
  echo "Instance '$NAME' already exists ($INSTANCE_ID)"
  exit 0
fi

ovhcloud cloud instance create "$REGION" \
  --name "$NAME" \
  --flavor "$FLAVOR_ID" \
  --boot-from.image "$IMAGE_ID" \
  --ssh-key.name "$SSH_KEY_NAME" \
  --network.public \
  --billing-period hourly \
  --wait

echo
echo "Instance created."
echo "SSH private key: $SSH_KEY_PATH"