import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // Levantar Postgres embebido y aplicar todas las migraciones toma unos segundos.
    testTimeout: 60_000,
    hookTimeout: 120_000,
  },
});
