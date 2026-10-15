#!/bin/bash
set -euo pipefail

echo ">>> Post-init: Creating custom Informix user, database, and seeding data..."

# Give the server a moment to fully settle
sleep 10

DB="${INFORMIX_DATABASE:-mydb}"
USER="${INFORMIX_USER:-myappuser}"
PASS="${INFORMIX_PASSWORD:-in4mix}"

# Create database if it does not exist
echo "CREATE DATABASE IF NOT EXISTS ${DB};" | dbaccess - - || true

# Create OS user (Informix authentication is OS-based)
if ! id "${USER}" &>/dev/null; then
  useradd -m -s /bin/bash "${USER}"
fi

echo "${USER}:${PASS}" | chpasswd

# Grant DBA privileges on the database
echo "GRANT DBA TO ${USER};" | dbaccess "${DB}" - || true

# Run seed script if present
SEED_FILE="/opt/ibm/config/seed.sql"
if [ -f "$SEED_FILE" ]; then
  echo ">>> Seeding database '${DB}' from seed.sql..."
  dbaccess "${DB}" "$SEED_FILE" || echo ">>> Warning: seed script returned non-zero (may be idempotent issues)"
else
  echo ">>> No seed.sql found, skipping seed."
fi

echo ">>> Done. User '${USER}' is ready on database '${DB}'."
echo ">>> Default informix/in4mix account still exists."
