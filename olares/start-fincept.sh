#!/bin/sh
# Wait for Xvfb on $DISPLAY, then exec the upstream entrypoint that resolves
# the per-arch Qt prefix and execs FinceptTerminal.
set -e

: "${DISPLAY:=:0}"
DISPLAY_NUM="${DISPLAY#:}"
DISPLAY_NUM="${DISPLAY_NUM%%.*}"
SOCKET="/tmp/.X11-unix/X${DISPLAY_NUM}"

# Give Xvfb up to ~30s to publish its socket. supervisord starts xvfb at
# priority 10 so this is normally near-instant; the loop just guards against
# slow cold starts on tiny nodes.
i=0
while [ ! -S "$SOCKET" ]; do
  i=$((i + 1))
  if [ "$i" -ge 60 ]; then
    echo "[start-fincept] X server socket $SOCKET never appeared" >&2
    exit 1
  fi
  sleep 0.5
done

exec /usr/local/bin/fincept-entrypoint.sh "$@"
