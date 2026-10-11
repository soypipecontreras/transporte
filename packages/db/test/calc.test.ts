import type { PGlite } from "@electric-sql/pglite";
import { beforeAll, describe, expect, it } from "vitest";
import { createDatabase } from "../src";

describe("cálculos de negocio", () => {
  let db: PGlite;
  beforeAll(async () => {
    db = await createDatabase({ seed: false });
  });

  async function addBusinessDays(day: string, n: number): Promise<string> {
    const { rows } = await db.query<{ d: string }>("select private.add_business_days($1::date, $2)::text as d", [day, n]);
    return rows[0]!.d;
  }

  it("el pago vence a 5 días hábiles, sin fines de semana ni festivos", async () => {
    expect(await addBusinessDays("2026-10-05", 5)).toBe("2026-10-13"); // lunes 12 de octubre es festivo
    expect(await addBusinessDays("2026-11-13", 5)).toBe("2026-11-23"); // lunes 16 de noviembre es festivo
    expect(await addBusinessDays("2026-12-23", 5)).toBe("2026-12-31"); // 25 de diciembre es festivo
    expect(await addBusinessDays("2026-03-31", 5)).toBe("2026-04-09"); // Jueves y Viernes Santo
  });

  it("cuenta cada hora o fracción por encima de 8", async () => {
    const { rows } = await db.query<{ a: number; b: number; c: number }>(`
      select private.extra_hours('2026-10-10 08:00-05', '2026-10-10 16:00-05') as a,
             private.extra_hours('2026-10-10 08:00-05', '2026-10-10 16:01-05') as b,
             private.extra_hours('2026-10-10 08:00-05', '2026-10-10 18:30-05') as c`);
    expect(rows[0]).toEqual({ a: 0, b: 1, c: 3 });
  });

  it("toma el salario mínimo del año y distingue rígido de articulado", async () => {
    const { rows } = await db.query<{ wage: number; rigid: boolean; articulated: boolean }>(`
      select private.monthly_wage_cop('2026-06-01') as wage,
             private.is_articulated('C3') as rigid,
             private.is_articulated('3S2') as articulated`);
    expect(rows[0]).toEqual({ wage: 1750905, rigid: false, articulated: true });
  });
});
