#!/bin/bash
# Launch Informix in the background
cd "$(dirname "$0")/.." || exit 1
docker compose up -d
echo "Informix started. View logs with: docker compose logs -f informix"
