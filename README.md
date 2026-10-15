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
DATABASE=mydb;HOSTNAME=localhost;PORT=9089;PROTOCOL=TCPIP;UID=myappuser;PWD=MySecurePassword123;AUTHENTICATION=SERVER;
```

**Default built-in account** (still available):
- User: `informix`
- Password: `in4mix`

## Connecting with DBeaver

DBeaver can connect to the container using the DRDA port (9089).

### Prerequisites
- Container is running and healthy (`docker compose up -d`).
- You know the values from your `.env` (or use the defaults).

### Steps

1. In DBeaver: **Database → New Database Connection**.
2. Search for **Informix**. If it is not listed, choose **DB2** (the IBM DB2 JDBC driver speaks DRDA and works with Informix).
3. If prompted to download a driver, accept the Informix JDBC or IBM DB2 driver.
4. Enter the connection details:

   | Field | Value |
   |-------|--------|
   | Host | `localhost` |
   | Port | `9089` |
   | Database | value of `INFORMIX_DATABASE` (default `mydb`) |
   | Username | value of `INFORMIX_USER` (default `myappuser`) |
   | Password | value of `INFORMIX_PASSWORD` |

5. Click **Test Connection**. If it succeeds, finish the wizard.

### JDBC URL (optional)

If DBeaver asks for a URL you can use either:

```
jdbc:informix-sqli://localhost:9089/mydb:INFORMIXSERVER=informix
```

or (DB2 driver):

```
jdbc:db2://localhost:9089/mydb
```

### Notes
- Always use port **9089** (DRDA), not 9088.
- The built-in account `informix` / `in4mix` also works if the custom user has not been created yet.
- After connecting you should see the tables created by `init/seed.sql` (`customers`, `products`, `orders`, `order_items`).

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

The tests build a connection string from environment variables (or fall back to the defaults that match `.env`):

- `INFORMIX_DATABASE` (default: `mydb`)
- `INFORMIX_HOST` (default: `localhost`)
- `INFORMIX_PORT` (default: `9089`)
- `INFORMIX_USER` (default: `myappuser`)
- `INFORMIX_PASSWORD` (default: `MySecurePassword123`)

You can override any of them before running the tests:

```bash
INFORMIX_USER=myappuser INFORMIX_PASSWORD=MySecurePassword123 npm test
```

Or set a full connection string:

```bash
INFORMIX_CONN="DATABASE=mydb;HOSTNAME=localhost;PORT=9089;PROTOCOL=TCPIP;UID=myappuser;PWD=MySecurePassword123;AUTHENTICATION=SERVER;" npm test
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
- That script creates the OS user, sets the password from `.env`, creates the database named in `.env`, grants DBA privileges, and runs `init/seed.sql`.
- Data is stored in the named Docker volume `informix-data`.

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
