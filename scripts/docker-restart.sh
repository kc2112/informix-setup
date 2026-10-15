#!/bin/bash
# Restart Informix
cd "$(dirname "$0")/.." || exit 1
docker compose restart
echo "Informix restarted."
