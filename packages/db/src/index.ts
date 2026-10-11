/**
 * Postgres embebido (PGlite, sin Docker) con el esquema real de supabase/migrations.
 * Sirve para probar migraciones, RLS y RPC como los ejecuta Supabase.
 */
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { PGlite } from "@electric-sql/pglite";

export function repoRoot(): string {
  return process.env.TRANSPORTE_ROOT ?? join(import.meta.dirname, "..", "..", "..");
}

export function migrationFiles(root: string = repoRoot()): Array<{ name: string; sql: string; skip: boolean }> {
  const dir = join(root, "supabase", "migrations");
  return readdirSync(dir)
    .filter((f) => f.endsWith(".sql"))
    .sort()
    .map((name) => {
      const sql = readFileSync(join(dir, name), "utf8");
      return { name, sql, skip: sql.trimStart().startsWith("-- pglite:skip") };
    });
}

/** Imitación mínima de Supabase (roles, auth.uid(), auth.users) para correr las migraciones. */
export function shimSql(root: string = repoRoot()): string {
  return readFileSync(join(root, "packages", "db", "sql", "supabase-shim.sql"), "utf8");
}

export function seedSql(root: string = repoRoot()): string {
  return readFileSync(join(root, "supabase", "seed.sql"), "utf8");
}

/** Base nueva con el shim + todas las migraciones (+ semilla, por defecto). */
export async function createDatabase(options: { seed?: boolean; root?: string } = {}): Promise<PGlite> {
  const root = options.root ?? repoRoot();
  const db = new PGlite();
  await db.exec(shimSql(root));
  for (const migration of migrationFiles(root)) {
    if (migration.skip) continue;
    try {
      await db.exec(migration.sql);
    } catch (error) {
      throw new Error(`Falló la migración ${migration.name}: ${(error as Error).message}`);
    }
  }
  if (options.seed ?? true) await db.exec(seedSql(root));
  return db;
}

export type Role = "anon" | "authenticated" | "service_role";

/** Ejecuta `fn` con el rol y el usuario indicados (como lo haría PostgREST con el JWT). */
export async function as<T>(db: PGlite, role: Role, userId: string | null, fn: () => Promise<T>): Promise<T> {
  await db.exec(`set role ${role}`);
  await db.query("select set_config('request.jwt.claims', $1, false)", [userId ? JSON.stringify({ sub: userId }) : ""]);
  try {
    return await fn();
  } finally {
    await db.exec("reset role");
    await db.query("select set_config('request.jwt.claims', '', false)");
  }
}

/** Llama una RPC como un usuario autenticado y devuelve su resultado. */
export async function rpc<T = unknown>(db: PGlite, userId: string, fn: string, args: Record<string, unknown> = {}): Promise<T> {
  const names = Object.keys(args);
  const params = names.map((name, i) => `${name} => $${i + 1}`).join(", ");
  const values = names.map((name) => {
    const value = args[name];
    return value !== null && typeof value === "object" && !(value instanceof Date) && !Array.isArray(value)
      ? JSON.stringify(value)
      : value;
  });
  return as(db, "authenticated", userId, async () => {
    const { rows } = await db.query<{ result: T }>(`select public.${fn}(${params}) as result`, values);
    return rows[0]!.result;
  });
}

/** Consulta como un usuario autenticado (RLS activa). */
export async function select<T>(db: PGlite, userId: string, sql: string, params: unknown[] = []): Promise<T[]> {
  return as(db, "authenticated", userId, async () => (await db.query<T>(sql, params)).rows);
}

export async function createUser(db: PGlite, opts: { email?: string; phone?: string; name?: string }): Promise<string> {
  const { rows } = await db.query<{ id: string }>(
    "insert into auth.users (email, phone, raw_user_meta_data) values ($1, $2, $3) returning id",
    [opts.email ?? null, opts.phone ?? null, JSON.stringify({ full_name: opts.name ?? "Prueba" })],
  );
  return rows[0]!.id;
}

/** Identificadores fijos de supabase/seed.sql. */
export const DEMO = {
  carrier: "c0000000-0000-4000-8000-000000000001",
  shipper: "50000000-0000-4000-8000-000000000001",
  ops: "a0000000-0000-4000-8000-000000000001",
  client: "a0000000-0000-4000-8000-000000000002",
  driver: "a0000000-0000-4000-8000-000000000003",
  pendingDriver: "a0000000-0000-4000-8000-000000000004",
  holder: "b0000000-0000-4000-8000-000000000001",
  vehicle: "7e000000-0000-4000-8000-000000000001",
  origin: "5e000000-0000-4000-8000-000000000001",
  destination: "5e000000-0000-4000-8000-000000000002",
  publishedLoad: "10ad0000-0000-4000-8000-000000000001",
  requestedLoad: "10ad0000-0000-4000-8000-000000000002",
  offer: "0ff00000-0000-4000-8000-000000000001",
} as const;

/** Coordenadas de las sedes demo (para pasar la geocerca). */
export const SITES = {
  origin: { lat: 4.7163, lng: -74.211 },
  destination: { lat: 6.1719, lng: -75.611 },
} as const;
