#!/bin/bash
# Stop Informix
cd "$(dirname "$0")/.." || exit 1
docker compose down
echo "Informix stopped."
