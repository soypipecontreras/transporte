import type { PGlite } from "@electric-sql/pglite";
import { beforeAll, describe, expect, it } from "vitest";
import { DEMO, SITES, createDatabase, rpc, select } from "../src";

/** Lo que falta de la ruta demo: Funza → Itagüí, camión ABC123 (3S2, articulado). */
describe("viaje de punta a punta", () => {
  let db: PGlite;
  let tripId: string;

  beforeAll(async () => {
    db = await createDatabase();
  });

  it("el camionero aprobado ve la oferta sin el flete del generador", async () => {
    const feed = await select<Record<string, unknown>>(db, DEMO.driver, "select * from public.driver_offer_feed($1)", [DEMO.vehicle]);
    expect(feed).toHaveLength(1);
    expect(feed[0]).toMatchObject({ offer_id: DEMO.offer, pay_cop: 6500000, fits_vehicle: true, carrier_name: "Transportes Demo S.A.S." });
    expect(feed[0]).not.toHaveProperty("freight_cop");
    const pricing = await select(db, DEMO.driver, "select * from public.load_pricing");
    expect(pricing).toHaveLength(0);
  });

  it("toma la oferta y nace el viaje", async () => {
    tripId = await rpc<string>(db, DEMO.driver, "offer_take", { p_offer_id: DEMO.offer, p_vehicle_id: DEMO.vehicle });
    const [trip] = await select<{ status: string; holder_id: string }>(db, DEMO.driver, "select status, holder_id from public.trips where id = $1", [tripId]);
    expect(trip).toEqual({ status: "assigned", holder_id: DEMO.holder });
    const [load] = await select<{ status: string }>(db, DEMO.client, "select status from public.loads where id = $1", [DEMO.publishedLoad]);
    expect(load!.status).toBe("assigned");
    await expect(rpc(db, DEMO.driver, "offer_take", { p_offer_id: DEMO.offer, p_vehicle_id: DEMO.vehicle })).rejects.toThrow(/offer_closed/);
  });

  it("no registra llegada fuera de la geocerca", async () => {
    await rpc(db, DEMO.driver, "trip_start", { p_trip_id: tripId });
    await expect(rpc(db, DEMO.driver, "trip_arrive", { p_trip_id: tripId, p_lat: 4.65, p_lng: -74.1 })).rejects.toThrow(/outside_geofence/);
    await expect(
      rpc(db, DEMO.driver, "trip_arrive", { p_trip_id: tripId, p_lat: 4.65, p_lng: -74.1, p_force: true }),
    ).rejects.toThrow(/forbidden/);
  });

  it("llega al cargue, pero sin manifiesto no puede salir", async () => {
    await rpc(db, DEMO.driver, "trip_arrive", { p_trip_id: tripId, p_lat: SITES.origin.lat + 0.001, p_lng: SITES.origin.lng });
    await expect(rpc(db, DEMO.driver, "trip_depart", { p_trip_id: tripId })).rejects.toThrow(/manifest_missing/);
    const [board] = await select<{ alerts: string[] }>(db, DEMO.ops, "select alerts from public.trip_board($1)", [DEMO.carrier]);
    expect(board!.alerts).toContain("manifest_missing");
  });

  it("operaciones registra remesa y manifiesto; el camionero sale y manda GPS", async () => {
    await rpc(db, DEMO.ops, "trip_set_documents", { p_trip_id: tripId, p_remesa_number: "R-0001", p_manifest_number: "M-0001" });
    await rpc(db, DEMO.driver, "trip_depart", { p_trip_id: tripId });
    const now = Date.now();
    const points = [0, 1, 2].map((i) => ({
      lat: 4.8 + i * 0.1,
      lng: -74.4 - i * 0.1,
      speed_kmh: 55,
      recorded_at: new Date(now - (2 - i) * 100).toISOString(),
    }));
    const inserted = await rpc<number>(db, DEMO.driver, "trip_ping", { p_trip_id: tripId, p_points: points });
    expect(inserted).toBe(3);
    // El generador sigue el camión.
    const [last] = await select<{ last_lat: number }>(db, DEMO.client, "select last_lat from public.trips where id = $1", [tripId]);
    expect(last!.last_lat).toBeCloseTo(5.0);
    const positions = await select(db, DEMO.client, "select id from public.positions where trip_id = $1", [tripId]);
    expect(positions).toHaveLength(3);
  });

  it("entrega solo con foto y el cumplido calcula recargos y vencimiento", async () => {
    await rpc(db, DEMO.driver, "trip_arrive", { p_trip_id: tripId, p_lat: SITES.destination.lat, p_lng: SITES.destination.lng });
    await expect(rpc(db, DEMO.driver, "trip_deliver", { p_trip_id: tripId })).rejects.toThrow(/proof_missing/);
    await rpc(db, DEMO.driver, "trip_add_document", { p_trip_id: tripId, p_kind: "delivery_photo", p_storage_path: `${tripId}/entrega.jpg` });
    await rpc(db, DEMO.driver, "trip_deliver", { p_trip_id: tripId, p_delivered_weight_kg: 18000 });

    // Simula 10,5 horas en el cargue (desde la cita) y 3 en el descargue.
    await db.query(
      `update public.trips t set
         arrived_pickup_at = l.pickup_at - interval '30 minutes',
         departed_pickup_at = l.pickup_at + interval '10 hours 30 minutes',
         arrived_delivery_at = l.delivery_at,
         delivered_at = l.delivery_at + interval '3 hours'
       from public.loads l where l.id = t.load_id and t.id = $1`,
      [tripId],
    );
    const logistics = await rpc<{ pickup: { extra_hours: number; hours: number }; surcharge_cop: number }>(
      db, DEMO.driver, "trip_logistics", { p_trip_id: tripId },
    );
    expect(logistics.pickup).toMatchObject({ hours: 10.5, extra_hours: 3 });
    expect(logistics.surcharge_cop).toBe(3 * 175091); // 3 SMLDV por hora (articulado), SMMLV 2026
    const shipperView = await rpc<{ surcharge_cop: number | null }>(db, DEMO.client, "trip_logistics", { p_trip_id: tripId });
    expect(shipperView.surcharge_cop).toBeNull();

    const due = await rpc<Date>(db, DEMO.ops, "trip_settle", { p_trip_id: tripId });
    const [payment] = await select<{ total_cop: number; surcharge_cop: number; advance_cop: number; due_on: string }>(
      db, DEMO.driver, "select total_cop, surcharge_cop, advance_cop, due_on::text from public.payments where trip_id = $1", [tripId],
    );
    expect(payment).toMatchObject({ surcharge_cop: 525273, advance_cop: 1500000, total_cop: 6500000 + 525273 - 1500000 });
    expect(due.toISOString().slice(0, 10)).toBe(payment!.due_on);
    const [load] = await select<{ status: string }>(db, DEMO.client, "select status from public.loads where id = $1", [DEMO.publishedLoad]);
    expect(load!.status).toBe("closed");
  });

  it("el generador no ve lo que se le paga al camionero", async () => {
    expect(await select(db, DEMO.client, "select * from public.payments")).toHaveLength(0);
    expect(await select(db, DEMO.client, "select * from public.offers")).toHaveLength(0);
    const [pricing] = await select<{ freight_cop: number }>(db, DEMO.client, "select freight_cop from public.load_pricing");
    expect(pricing!.freight_cop).toBe(7600000);
  });

  it("control de cumplidos y pago registrado", async () => {
    const compliance = await rpc<{ manifests_30d: number; unsettled: number; level: string }>(
      db, DEMO.ops, "carrier_compliance", { p_carrier_org_id: DEMO.carrier },
    );
    expect(compliance).toMatchObject({ manifests_30d: 1, unsettled: 0, level: "ok" });
    await rpc(db, DEMO.ops, "payment_mark_paid", { p_trip_id: tripId, p_reference: "TRF-123" });
    const [payment] = await select<{ status: string }>(db, DEMO.driver, "select status from public.payments where trip_id = $1", [tripId]);
    expect(payment!.status).toBe("paid");
  });
});
