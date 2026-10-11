import { describe, expect, it } from "vitest";
import { createDatabase } from "../src";

describe("esquema", () => {
  it("aplica todas las migraciones y la semilla", async () => {
    const db = await createDatabase();
    const { rows } = await db.query<{ n: number }>("select count(*)::int as n from public.offers where status = 'open'");
    expect(rows[0]!.n).toBe(1);
  });
});
