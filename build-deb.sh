#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-$(git describe --tags --abbrev=7 --dirty 2>/dev/null || echo "0.0.0")}"
OUTPUT="netgate_${VERSION}_amd64.deb"

echo "==> Building frontend"
(cd ui/html && npm install && npm run build)

echo "==> Building Go binary"
./build.sh -o netgate

echo "==> Building deb package ($OUTPUT)"
fpm -t deb \
  -v "$VERSION" \
  -p "$OUTPUT" \
  --architecture amd64 \
  -f \
  netgate=/usr/bin/netgate

echo "==> Done: $OUTPUT"
