#!/bin/bash
set -euo pipefail

echo ">>> Post-init: Creating database and seeding data..."

# Give the server a moment to fully settle
sleep 10

DB="${INFORMIX_DATABASE:-mydb}"
USER="${INFORMIX_USER:-myappuser}"
PASS="${INFORMIX_PASSWORD:-in4mix}"

# Create database if it does not exist
echo "CREATE DATABASE IF NOT EXISTS ${DB};" | dbaccess - - || true

# Try to create OS user (Informix authentication is OS-based).
# This often fails inside the official image even with privileged: true.
# We continue either way so the database and seed still work.
if id "${USER}" &>/dev/null; then
  echo ">>> User '${USER}' already exists."
else
  if useradd -m -s /bin/bash "${USER}" 2>/dev/null; then
    echo "${USER}:${PASS}" | chpasswd
    echo ">>> Created OS user '${USER}'."
  else
    echo ">>> WARNING: Could not create OS user '${USER}' (useradd permission denied)."
    echo ">>> Use the built-in account instead:"
    echo ">>>   Username: informix"
    echo ">>>   Password: in4mix"
    USER="informix"
  fi
fi

# Grant DBA privileges (works for both custom user and informix)
echo "GRANT DBA TO ${USER};" | dbaccess "${DB}" - || true

# Run seed script if present
SEED_FILE="/opt/ibm/config/seed.sql"
if [ -f "$SEED_FILE" ]; then
  echo ">>> Seeding database '${DB}' from seed.sql..."
  dbaccess "${DB}" "$SEED_FILE" || echo ">>> Warning: seed script returned non-zero (may be idempotent issues)"
else
  echo ">>> No seed.sql found, skipping seed."
fi

echo ">>> Done."
echo ">>> Database: ${DB}"
echo ">>> Recommended login: informix / in4mix"
echo ">>> Locale: en_US.819 (DB_LOCALE and CLIENT_LOCALE)"
echo ">>> Custom user '${INFORMIX_USER:-myappuser}' may not have been created."
