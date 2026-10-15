# Informix Developer Edition – Docker Setup

A ready-to-run local Informix Developer Edition using the official IBM container image, with environment-specific configuration (`.env.local`, `.env.test`, `.env.prod`), automatic database seeding, and a TypeScript test suite.

## Prerequisites

- Docker Engine (or Docker Desktop) with Compose support
- Node.js 18+ (for the TypeScript app and tests)
- At least 4 GB free RAM recommended
- Port 9088 available on your host

## Quick Start

1. Unzip this archive.
2. Edit `.env.local` and set your credentials if needed:
   ```env
   NODE_ENV=development
   INFORMIX_USER=informix
   INFORMIX_PASSWORD=in4mix
   INFORMIX_DATABASE=mydb
   INFORMIX_HOST=127.0.0.1
   INFORMIX_PORT=9088
   ```
3. Start Informix:
   ```bash
   npm install
   npm run docker:up
   ```
4. Wait for the server to be ready (first start can take 1–2 minutes):
   ```bash
   docker compose logs -f informix
   ```
5. Run the local app:
   ```bash
   npm run dev
   ```
6. (Optional) Run the tests:
   ```bash
   npm test
   ```

## Environment Files

| File | Purpose | NODE_ENV |
|------|---------|----------|
| `.env.local` | Local development | `development` |
| `.env.test` | Automated tests / CI | `test` |
| `.env.prod` | Production settings | `production` |

## npm Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start the app with `.env.local` |
| `npm run build` | Compile TypeScript |
| `npm start` | Run the compiled app |
| `npm test` | Run tests with `.env.test` |
| `npm run test:ci` | CI-mode tests with coverage |
| `npm run docker:up` | Start Informix in the background |
| `npm run docker:down` | Stop Informix |

## Seeding

The file `init/seed.sql` is executed automatically by `init/post_init.sh` after the database named in the env file (`INFORMIX_DATABASE`) is created. It creates sample tables (`customers`, `products`, `orders`, `order_items`) and inserts seed data. Edit `seed.sql` to match your schema.

## Connection Details

| Protocol | Port | Typical Use |
|----------|------|-------------|
| SQLI     | 9088 | Native Informix clients, `dbaccess`, DBeaver, `ibm_db` |
| DRDA     | 9089 | Not started by default |
| Mongo    | 27017| Mongo wire protocol |
| REST     | 27018| REST listener |

**Example connection string (Node.js with `ibm_db`):**
```
DATABASE=mydb;HOSTNAME=localhost;PORT=9088;PROTOCOL=TCPIP;UID=informix;PWD=in4mix;AUTHENTICATION=SERVER;DB_LOCALE=en_US.819;CLIENT_LOCALE=en_US.819;
```

**Default built-in account:**
- User: `informix`
- Password: `in4mix`

## Connecting with DBeaver

External connections from DBeaver work with the settings below.

### Working connection settings

| Field | Value |
|-------|--------|
| Host | `127.0.0.1` |
| Port | `9088` |
| Server | `informix` |
| Database | `mydb` |
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

- Use port **9088** (SQLI).
- Locale must be `en_US.819` to match the database.
- Use the built-in account `informix` / `in4mix`.

## TypeScript Tests

The `tests/` directory contains a Jest + TypeScript suite that connects with the `ibm_db` driver and verifies the data created by `init/seed.sql`.

### Run the tests

```bash
npm test            # uses .env.test
npm run test:ci     # CI mode with coverage
```

### What the tests check

- Connectivity to the database
- Presence of seeded customers, products, orders, and order items
- Ability to insert a new row and read it back

## Useful Commands

```bash
npm run docker:up
docker compose logs -f informix
docker compose exec informix bash
npm run docker:down
docker compose down -v          # remove data volume (fresh start)
```

## How It Works

- Uses the official image: `icr.io/informix/informix-developer-database:latest`
- The `RUN_FILE_POST_INIT` mechanism runs `init/post_init.sh` after the Informix server finishes initialization.
- That script creates the database named in the env file and runs `init/seed.sql`.
- Data is stored in the named Docker volume `informix-data`.
- External clients (including DBeaver) connect on port 9088 with locale `en_US.819` using the built-in `informix` / `in4mix` account.

## Notes

- The container must run in privileged mode (required by the official image).
- First startup is slower because Informix performs disk initialization.
- For CI, you can pin a specific image tag instead of `latest`.

## Files

- `.env.local` — local development configuration
- `.env.test` — test / CI configuration
- `.env.prod` — production configuration
- `package.json` — npm scripts (`dev`, `test`, `docker:up`, etc.)
- `docker-compose.yml` — service definition
- `src/init.ts` — sample Node.js app
- `init/post_init.sh` — runs after initialization (creates database + seeds)
- `init/seed.sql` — schema and seed data
- `tests/` — TypeScript + Jest tests
- `.vscode/launch.json` — VS Code debug configuration
