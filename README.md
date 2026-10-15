# Informix Developer Edition – Docker Setup

A ready-to-run local Informix Developer Edition using the official IBM container image, with custom username/password and database seeding controlled by a `.env` file. Includes a TypeScript unit/integration test suite.

## Prerequisites

- Docker Engine (or Docker Desktop) with Compose support
- Node.js 18+ (for the TypeScript tests)
- At least 4 GB free RAM recommended
- Ports 9088 and 9089 available on your host

## Quick Start

1. Unzip this archive.
2. Edit `.env` and set your desired credentials and database name:
   ```env
   INFORMIX_USER=myappuser
   INFORMIX_PASSWORD=MySecurePassword123
   INFORMIX_DATABASE=mydb
   ```
3. Start the container (creates the database and seeds it automatically):
   ```bash
   docker compose up -d
   ```
4. Wait for the health check to pass (first start can take 1–2 minutes):
   ```bash
   docker compose logs -f informix
   ```
5. (Optional) Run the TypeScript tests against the seeded database:
   ```bash
   cd tests
   npm install
   npm test
   ```

## Seeding

The file `init/seed.sql` is executed automatically by `init/post_init.sh` after the database named in `.env` (`INFORMIX_DATABASE`) is created. It creates sample tables (`customers`, `products`, `orders`, `order_items`) and inserts seed data. Edit `seed.sql` to match your schema.

## Connection Details

| Protocol | Port | Typical Use |
|----------|------|-------------|
| SQLI     | 9088 | Native Informix clients, `dbaccess` |
| DRDA     | 9089 | `ibm_db` (Node.js), JDBC, ODBC |
| Mongo    | 27017| Mongo wire protocol |
| REST     | 27018| REST listener |

**Example connection string (Node.js with `ibm_db`):**
```
DATABASE=mydb;HOSTNAME=localhost;PORT=9088;PROTOCOL=TCPIP;UID=informix;PWD=in4mix;AUTHENTICATION=SERVER;DB_LOCALE=en_US.819;CLIENT_LOCALE=en_US.819;
```

**Default built-in account** (recommended):
- User: `informix`
- Password: `in4mix`

## Connecting with DBeaver

External connections from DBeaver (Windows / Docker Desktop) work with the settings below.

### Working connection settings

| Field | Value |
|-------|--------|
| Host | `127.0.0.1` |
| Port | `9088` |
| Server | `informix` |
| Database | `mydb` (or value of `INFORMIX_DATABASE`) |
| Username | `informix` |
| Password | `in4mix` |

### Driver properties (required)

| Property | Value |
|----------|--------|
| `INFORMIXSERVER` | `informix` |
| `DB_LOCALE` | `en_US.819` |
| `CLIENT_LOCALE` | `en_US.819` |

### JDBC URL

```
jdbc:informix-sqli://127.0.0.1:9088/mydb:INFORMIXSERVER=informix;DB_LOCALE=en_US.819;CLIENT_LOCALE=en_US.819
```

### Steps

1. In DBeaver: **Database → New Database Connection**.
2. Search for **Informix** and select it.
3. Download the Informix JDBC driver if prompted.
4. Enter the values from the table above.
5. Open the **Driver properties** tab and set `DB_LOCALE` and `CLIENT_LOCALE` to `en_US.819`.
6. Click **Test Connection**.

### Notes

- Use port **9088** (SQLI). Port 9089 is not started by default.
- Locale must be `en_US.819` to match the database (created with the default ISO-8859-1 locale).
- Use the built-in account `informix` / `in4mix`. Custom OS users are not created by the official image.

## TypeScript Tests

The `tests/` directory contains a Jest + TypeScript suite (`informix.test.ts`) that connects to the running Informix instance with the `ibm_db` driver and verifies the data created by `init/seed.sql`.

### Prerequisites for the tests

- Informix container is running and healthy (`docker compose up -d` and logs show the server is online).
- Node.js 18 or newer is installed on the host.

### Run the tests

```bash
# From the project root (after Informix is up)
cd tests
npm install
npm test
```

### What the tests check

- Connectivity to the database named in `.env`
- Presence of seeded customers, products, orders, and order items
- Ability to insert a new row and read it back

### Useful test commands

```bash
npm test            # run once
npm run test:watch  # re-run on file changes
npm run test:ci     # CI mode with coverage report
```

### Connection configuration

The tests build a connection string from environment variables (or fall back to the defaults that match the working configuration):

- `INFORMIX_DATABASE` (default: `mydb`)
- `INFORMIX_HOST` (default: `localhost`)
- `INFORMIX_PORT` (default: `9088`)
- `INFORMIX_USER` (default: `informix`)
- `INFORMIX_PASSWORD` (default: `in4mix`)
- Locale is fixed to `en_US.819` in the connection string

You can override any of them before running the tests:

```bash
INFORMIX_USER=informix INFORMIX_PASSWORD=in4mix npm test
```

Or set a full connection string:

```bash
INFORMIX_CONN="DATABASE=mydb;HOSTNAME=localhost;PORT=9088;PROTOCOL=TCPIP;UID=informix;PWD=in4mix;AUTHENTICATION=SERVER;DB_LOCALE=en_US.819;CLIENT_LOCALE=en_US.819;" npm test
```

### Troubleshooting

- **Connection refused / timeout**: Wait longer for Informix to finish starting (`docker compose logs -f informix`). First start can take 1–2 minutes.
- **Authentication failed**: Confirm the user and password in `.env` match what you pass to the tests, and that `post_init.sh` completed successfully.
- **ibm_db install issues**: The native driver needs a C++ toolchain. On Debian/Ubuntu: `sudo apt install build-essential`. On macOS the Xcode command-line tools are usually sufficient.

## Useful Commands

```bash
# Start in background
docker compose up -d

# View logs
docker compose logs -f informix

# Open a shell inside the container
docker compose exec informix bash

# Stop
docker compose down

# Stop and remove the data volume (fresh start)
docker compose down -v
```

## How It Works

- Uses the official image: `icr.io/informix/informix-developer-database:latest`
- The `RUN_FILE_POST_INIT` mechanism runs `init/post_init.sh` after the Informix server finishes initialization.
- That script creates the database named in `.env` and runs `init/seed.sql`.
- Data is stored in the named Docker volume `informix-data`.
- External clients (including DBeaver) connect on port 9088 with locale `en_US.819` using the built-in `informix` / `in4mix` account.

## Notes

- The container must run in privileged mode (required by the official image).
- First startup is slower because Informix performs disk initialization.
- For CI, you can pin a specific image tag instead of `latest`.
- The official image does not support changing the `informix` password via environment variable; the post-init script is the supported way to add custom users.

## Files

- `.env` — credentials, database name, and sizing options
- `docker-compose.yml` — service definition
- `init/post_init.sh` — runs after initialization (creates user + database + seeds)
- `init/seed.sql` — schema and seed data for the database named in `.env`
- `tests/` — TypeScript + Jest unit/integration tests against the seeded database
