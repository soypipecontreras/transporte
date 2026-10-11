import type { PGlite } from "@electric-sql/pglite";
import { beforeAll, describe, expect, it } from "vitest";
import { DEMO, createDatabase, createUser, rpc, select } from "../src";

describe("permisos y reglas", () => {
  let db: PGlite;
  let outsider: string;
  let otherShipper: string;

  beforeAll(async () => {
    db = await createDatabase();
    outsider = await createUser(db, { email: "otra@empresa.co", name: "Otra empresa" });
    otherShipper = await rpc<string>(db, outsider, "organization_create", { p_kind: "shipper", p_name: "Otra Empresa S.A.S.", p_nit: "901111111-1" });
  });

  it("una empresa ajena no ve cargas, sedes, viajes ni organizaciones de otros", async () => {
    expect(await select(db, outsider, "select id from public.loads")).toHaveLength(0);
    expect(await select(db, outsider, "select id from public.sites")).toHaveLength(0);
    expect(await select(db, outsider, "select id from public.trips")).toHaveLength(0);
    const orgs = await select<{ id: string }>(db, outsider, "select id from public.organizations");
    expect(orgs.map((o) => o.id)).toEqual([otherShipper]);
  });

  it("nadie escribe directo en las tablas: todo pasa por las RPC", async () => {
    await expect(
      select(db, DEMO.ops, "update public.offers set pay_cop = 1 where id = $1", [DEMO.offer]),
    ).rejects.toThrow(/permission denied/);
    await expect(
      select(db, DEMO.driver, "insert into public.positions (trip_id, lat, lng, recorded_at) values (gen_random_uuid(), 4, -74, now())"),
    ).rejects.toThrow(/permission denied/);
  });

  it("no se publica sin flete ni por debajo del SICE-TAC", async () => {
    await expect(
      rpc(db, DEMO.ops, "load_publish", { p_load_id: DEMO.requestedLoad, p_pay_cop: 5_000_000, p_sicetac_floor_cop: 4_800_000 }),
    ).rejects.toThrow(/freight_missing/);
    await rpc(db, DEMO.ops, "load_set_freight", { p_load_id: DEMO.requestedLoad, p_freight_cop: 9_000_000 });
    await expect(
      rpc(db, DEMO.ops, "load_publish", { p_load_id: DEMO.requestedLoad, p_pay_cop: 7_000_000, p_sicetac_floor_cop: 7_200_000 }),
    ).rejects.toThrow(/below_sicetac/);
  });

  it("el generador pide cargas pero no fija flete ni publica", async () => {
    const tomorrow = new Date(Date.now() + 86_400_000);
    const args = {
      p_carrier_org_id: DEMO.carrier,
      p_shipper_org_id: DEMO.shipper,
      p_origin_site_id: DEMO.origin,
      p_destination_site_id: DEMO.destination,
      p_cargo_description: "Harina en bultos",
      p_weight_kg: 10_000,
      p_declared_value_cop: 40_000_000,
      p_pickup_at: tomorrow.toISOString(),
      p_delivery_at: new Date(tomorrow.getTime() + 86_400_000).toISOString(),
    };
    const loadId = await rpc<string>(db, DEMO.client, "load_create", args);
    await expect(rpc(db, DEMO.client, "load_create", { ...args, p_freight_cop: 5_000_000 })).rejects.toThrow(/forbidden/);
    await expect(
      rpc(db, DEMO.client, "load_publish", { p_load_id: loadId, p_pay_cop: 5_000_000, p_sicetac_floor_cop: 4_000_000 }),
    ).rejects.toThrow(/forbidden/);
    // Y no puede crearle cargas a una transportadora de la que no es cliente.
    await expect(rpc(db, outsider, "load_create", { ...args, p_shipper_org_id: otherShipper })).rejects.toThrow(/forbidden|invalid/);
  });

  it("un camionero sin aprobar no ve ofertas ni las toma", async () => {
    expect(await select(db, DEMO.pendingDriver, "select * from public.driver_offer_feed()")).toHaveLength(0);
    expect(await select(db, DEMO.pendingDriver, "select id from public.offers")).toHaveLength(0);
    await expect(
      rpc(db, DEMO.pendingDriver, "offer_take", { p_offer_id: DEMO.offer, p_vehicle_id: DEMO.vehicle }),
    ).rejects.toThrow(/not_approved/);
  });

  it("un camionero no manda GPS ni ve viajes de otro", async () => {
    const tripId = await rpc<string>(db, DEMO.driver, "offer_take", { p_offer_id: DEMO.offer, p_vehicle_id: DEMO.vehicle });
    await rpc(db, DEMO.driver, "trip_start", { p_trip_id: tripId });
    await expect(
      rpc(db, DEMO.pendingDriver, "trip_ping", { p_trip_id: tripId, p_points: [{ lat: 4.7, lng: -74.2, recorded_at: new Date().toISOString() }] }),
    ).rejects.toThrow(/forbidden/);
    expect(await select(db, DEMO.pendingDriver, "select id from public.trips")).toHaveLength(0);
    expect(await select(db, outsider, "select * from public.trip_events")).toHaveLength(0);
    await expect(rpc(db, outsider, "trip_logistics", { p_trip_id: tripId })).rejects.toThrow(/forbidden/);
  });

  it("el camionero no ve los datos de otros camioneros ni los fletes", async () => {
    const drivers = await select<{ id: string }>(db, DEMO.driver, "select id from public.drivers");
    expect(drivers.map((d) => d.id)).toEqual([DEMO.driver]);
    expect(await select(db, DEMO.driver, "select * from public.load_pricing")).toHaveLength(0);
  });

  it("solo operaciones aprueba conductores", async () => {
    await expect(
      rpc(db, DEMO.client, "carrier_review_driver", { p_carrier_org_id: DEMO.carrier, p_driver_id: DEMO.pendingDriver, p_status: "approved" }),
    ).rejects.toThrow(/forbidden/);
    await rpc(db, DEMO.ops, "carrier_review_driver", { p_carrier_org_id: DEMO.carrier, p_driver_id: DEMO.pendingDriver, p_status: "approved" });
    const [row] = await select<{ status: string }>(db, DEMO.pendingDriver, "select status from public.carrier_drivers");
    expect(row!.status).toBe("approved");
  });

  it("registro de un camionero nuevo desde la app", async () => {
    const newDriver = await createUser(db, { phone: "573109998877", name: "Pedro" });
    await rpc(db, newDriver, "driver_upsert_me", {
      p_full_name: "Pedro Rojas",
      p_document_number: "1012345678",
      p_license_category: "C3",
      p_license_expires_on: "2028-01-01",
    });
    const holderId = await rpc<string>(db, newDriver, "holder_upsert", {
      p_name: "Pedro Rojas", p_document_number: "1012345678", p_is_me: true,
      p_bank_name: "Nequi", p_bank_account_type: "savings", p_bank_account_number: "3109998877",
    });
    const vehicleId = await rpc<string>(db, newDriver, "vehicle_upsert", {
      p_plate: "xyz 987", p_configuration: "C3", p_body_type: "stake", p_payload_kg: 17_000,
      p_soat_expires_on: "2027-05-01", p_holder_id: holderId,
    });
    await expect(
      rpc(db, outsider, "vehicle_upsert", {
        p_plate: "XYZ987", p_configuration: "C3", p_body_type: "stake", p_payload_kg: 17_000,
        p_soat_expires_on: "2027-05-01", p_holder_id: holderId,
      }),
    ).rejects.toThrow(/forbidden|conflict/);
    await rpc(db, newDriver, "carrier_apply", { p_carrier_org_id: DEMO.carrier, p_vehicle_id: vehicleId });
    const pending = await select<{ driver_id: string }>(db, DEMO.ops, "select driver_id from public.carrier_drivers where status = 'pending'");
    expect(pending.map((p) => p.driver_id)).toContain(newDriver);
    const [vehicle] = await select<{ plate: string }>(db, DEMO.ops, "select plate from public.vehicles where id = $1", [vehicleId]);
    expect(vehicle!.plate).toBe("XYZ987");
  });
});
