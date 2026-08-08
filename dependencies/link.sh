get_link() {
  LABEL="$1"
  DOMAIN="$2"
  CONTAINER_PORT="${3:-80}"

  case "$CONTAINER_PORT" in
    443) SCHEME=https ;;
    *)   SCHEME=http ;;
  esac

  CONTAINER=$(docker ps \
    --filter "label=$LABEL" \
    --format '{{.ID}}' \
    | head -n 1)

  if [ -z "$CONTAINER" ]; then
    echo "Container not found for label: $LABEL" >&2
    return 1
  fi

  HOST_PORT=$(docker inspect \
    --format "{{(index (index .NetworkSettings.Ports \"${CONTAINER_PORT}/tcp\") 0).HostPort}}" \
    "$CONTAINER")

  if [ -z "$HOST_PORT" ]; then
    echo "No host port mapped for ${CONTAINER_PORT}/tcp" >&2
    return 1
  fi

  echo "${SCHEME}://${DOMAIN}:${HOST_PORT}"
}

get_link "$@"