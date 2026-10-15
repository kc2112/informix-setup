import * as ibmdb from "ibm_db";

const connectionString = process.env.INFORMIX_CONN
  ?? `DATABASE=${process.env.INFORMIX_DATABASE ?? "mydb"};HOSTNAME=${process.env.INFORMIX_HOST ?? "localhost"};PORT=${process.env.INFORMIX_PORT ?? "9088"};PROTOCOL=TCPIP;UID=${process.env.INFORMIX_USER ?? "informix"};PWD=${process.env.INFORMIX_PASSWORD ?? "in4mix"};AUTHENTICATION=SERVER;DB_LOCALE=en_US.819;CLIENT_LOCALE=en_US.819;`;

async function query<T = any>(sql: string, params: any[] = []): Promise<T[]> {
  const conn = await ibmdb.open(connectionString);
  try {
    const result = await conn.query(sql, params);
    return result as T[];
  } finally {
    await conn.close();
  }
}

describe("Informix seeded database (TypeScript)", () => {
  beforeAll(async () => {
    // Quick connectivity check
    await query("SELECT 1 FROM systables WHERE tabid = 1");
  }, 90000);

  it("should have the customers table seeded", async () => {
    const rows = await query<{ email: string }>(
      "SELECT email FROM customers ORDER BY customer_id"
    );
    expect(rows.length).toBeGreaterThanOrEqual(3);
    expect(rows.map(r => r.email)).toContain("alice@example.com");
  });

  it("should have products with correct prices", async () => {
    const rows = await query<{ name: string; price: number }>(
      "SELECT name, price FROM products WHERE name = 'Widget A'"
    );
    expect(rows).toHaveLength(1);
    expect(Number(rows[0].price)).toBeCloseTo(19.99);
  });

  it("should have orders and order items", async () => {
    const orders = await query("SELECT COUNT(*) AS cnt FROM orders");
    const items = await query("SELECT COUNT(*) AS cnt FROM order_items");
    expect(Number(orders[0].cnt)).toBeGreaterThanOrEqual(2);
    expect(Number(items[0].cnt)).toBeGreaterThanOrEqual(3);
  });

  it("should allow inserting and querying a new customer", async () => {
    const email = `test-${Date.now()}@example.com`;
    await query(
      "INSERT INTO customers (first_name, last_name, email) VALUES (?, ?, ?)",
      ["Test", "User", email]
    );

    const found = await query<{ email: string }>(
      "SELECT email FROM customers WHERE email = ?",
      [email]
    );
    expect(found).toHaveLength(1);
    expect(found[0].email).toBe(email);
  });
});
