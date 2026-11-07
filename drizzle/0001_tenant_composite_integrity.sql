-- Tenant data-integrity hardening.
-- This migration is intentionally committed but NOT executed by this change.
-- It fails closed if existing cross-tenant references are present.
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "branches_tenant_id_id_uq" ON "branches" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "departments_tenant_id_id_uq" ON "departments" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "tenant_memberships_tenant_id_id_uq" ON "tenant_memberships" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "roles_tenant_id_id_uq" ON "roles" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "customers_tenant_id_id_uq" ON "customers" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "services_tenant_id_id_uq" ON "services" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "service_versions_tenant_id_id_uq" ON "service_versions" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "price_lists_tenant_id_id_uq" ON "price_lists" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "quotations_tenant_id_id_uq" ON "quotations" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "orders_tenant_id_id_uq" ON "orders" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "ai_credit_accounts_tenant_id_id_uq" ON "ai_credit_accounts" ("tenant_id", "id");
--> statement-breakpoint
-- Replace single-column tenant-owned references with composite tenant-scoped FKs.
ALTER TABLE "departments" DROP CONSTRAINT IF EXISTS "departments_branch_id_branches_id_fk";
ALTER TABLE "departments" ADD CONSTRAINT "departments_branch_tenant_fk"
  FOREIGN KEY ("tenant_id", "branch_id") REFERENCES "branches" ("tenant_id", "id") ON DELETE NO ACTION;
ALTER TABLE "departments" ADD CONSTRAINT "departments_parent_tenant_fk"
  FOREIGN KEY ("tenant_id", "parent_id") REFERENCES "departments" ("tenant_id", "id") ON DELETE NO ACTION;
--> statement-breakpoint
ALTER TABLE "service_versions" DROP CONSTRAINT IF EXISTS "service_versions_service_id_services_id_fk";
ALTER TABLE "service_versions" ADD CONSTRAINT "service_versions_service_tenant_fk"
  FOREIGN KEY ("tenant_id", "service_id") REFERENCES "services" ("tenant_id", "id") ON DELETE RESTRICT;
--> statement-breakpoint
ALTER TABLE "service_prices" DROP CONSTRAINT IF EXISTS "service_prices_price_list_id_price_lists_id_fk";
ALTER TABLE "service_prices" DROP CONSTRAINT IF EXISTS "service_prices_service_version_id_service_versions_id_fk";
ALTER TABLE "service_prices" ADD CONSTRAINT "service_prices_price_list_tenant_fk"
  FOREIGN KEY ("tenant_id", "price_list_id") REFERENCES "price_lists" ("tenant_id", "id") ON DELETE CASCADE;
ALTER TABLE "service_prices" ADD CONSTRAINT "service_prices_version_tenant_fk"
  FOREIGN KEY ("tenant_id", "service_version_id") REFERENCES "service_versions" ("tenant_id", "id") ON DELETE RESTRICT;
--> statement-breakpoint
ALTER TABLE "leads" DROP CONSTRAINT IF EXISTS "leads_customer_id_customers_id_fk";
ALTER TABLE "leads" ADD CONSTRAINT "leads_customer_tenant_fk"
  FOREIGN KEY ("tenant_id", "customer_id") REFERENCES "customers" ("tenant_id", "id") ON DELETE NO ACTION;
--> statement-breakpoint
ALTER TABLE "quotations" DROP CONSTRAINT IF EXISTS "quotations_customer_id_customers_id_fk";
ALTER TABLE "quotations" ADD CONSTRAINT "quotations_customer_tenant_fk"
  FOREIGN KEY ("tenant_id", "customer_id") REFERENCES "customers" ("tenant_id", "id") ON DELETE NO ACTION;
--> statement-breakpoint
ALTER TABLE "orders" DROP CONSTRAINT IF EXISTS "orders_customer_id_customers_id_fk";
ALTER TABLE "orders" DROP CONSTRAINT IF EXISTS "orders_quotation_id_quotations_id_fk";
ALTER TABLE "orders" ADD CONSTRAINT "orders_customer_tenant_fk"
  FOREIGN KEY ("tenant_id", "customer_id") REFERENCES "customers" ("tenant_id", "id") ON DELETE NO ACTION;
ALTER TABLE "orders" ADD CONSTRAINT "orders_quotation_tenant_fk"
  FOREIGN KEY ("tenant_id", "quotation_id") REFERENCES "quotations" ("tenant_id", "id") ON DELETE NO ACTION;
--> statement-breakpoint
ALTER TABLE "order_items" DROP CONSTRAINT IF EXISTS "order_items_order_id_orders_id_fk";
ALTER TABLE "order_items" DROP CONSTRAINT IF EXISTS "order_items_service_version_id_service_versions_id_fk";
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_order_tenant_fk"
  FOREIGN KEY ("tenant_id", "order_id") REFERENCES "orders" ("tenant_id", "id") ON DELETE CASCADE;
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_version_tenant_fk"
  FOREIGN KEY ("tenant_id", "service_version_id") REFERENCES "service_versions" ("tenant_id", "id") ON DELETE NO ACTION;
--> statement-breakpoint
ALTER TABLE "production_jobs" DROP CONSTRAINT IF EXISTS "production_jobs_order_id_orders_id_fk";
ALTER TABLE "production_jobs" ADD CONSTRAINT "production_jobs_order_tenant_fk"
  FOREIGN KEY ("tenant_id", "order_id") REFERENCES "orders" ("tenant_id", "id") ON DELETE CASCADE;
--> statement-breakpoint
ALTER TABLE "ai_credit_ledger" DROP CONSTRAINT IF EXISTS "ai_credit_ledger_account_id_ai_credit_accounts_id_fk";
ALTER TABLE "ai_credit_ledger" ADD CONSTRAINT "ai_credit_ledger_account_tenant_fk"
  FOREIGN KEY ("tenant_id", "account_id") REFERENCES "ai_credit_accounts" ("tenant_id", "id") ON DELETE NO ACTION;
--> statement-breakpoint
-- Assignment tables need a controlled exception for global system roles.
-- Membership, branch and department references are fully tenant-scoped.
ALTER TABLE "membership_roles" DROP CONSTRAINT IF EXISTS "membership_roles_membership_id_tenant_memberships_id_fk";
ALTER TABLE "membership_roles" DROP CONSTRAINT IF EXISTS "membership_roles_branch_id_branches_id_fk";
ALTER TABLE "membership_roles" DROP CONSTRAINT IF EXISTS "membership_roles_department_id_departments_id_fk";
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_membership_tenant_fk"
  FOREIGN KEY ("tenant_id", "membership_id") REFERENCES "tenant_memberships" ("tenant_id", "id") ON DELETE CASCADE;
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_branch_tenant_fk"
  FOREIGN KEY ("tenant_id", "branch_id") REFERENCES "branches" ("tenant_id", "id") ON DELETE NO ACTION;
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_department_tenant_fk"
  FOREIGN KEY ("tenant_id", "department_id") REFERENCES "departments" ("tenant_id", "id") ON DELETE NO ACTION;
--> statement-breakpoint
CREATE OR REPLACE FUNCTION "enforce_membership_role_tenant_role"() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM "roles" r
    WHERE r.id = NEW.role_id
      AND (
        r.tenant_id = NEW.tenant_id
        OR (r.tenant_id IS NULL AND r.is_system = TRUE)
      )
  ) THEN
    RAISE EXCEPTION 'membership role must reference a role owned by this tenant or a global system role'
      USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER "membership_roles_tenant_role_guard"
  BEFORE INSERT OR UPDATE OF tenant_id, role_id ON "membership_roles"
  FOR EACH ROW EXECUTE FUNCTION "enforce_membership_role_tenant_role"();
--> statement-breakpoint
-- Tenant-scoped permission grants may reference tenant roles only.
-- Global system-role grants must remain global (tenant_id IS NULL).
CREATE OR REPLACE FUNCTION "enforce_role_permission_tenant_role"() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE role_tenant uuid; role_system boolean;
BEGIN
  SELECT r.tenant_id, r.is_system INTO role_tenant, role_system
  FROM "roles" r WHERE r.id = NEW.role_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'role permission references an unknown role' USING ERRCODE = '23503';
  END IF;
  IF role_tenant IS NULL THEN
    IF role_system IS NOT TRUE OR NEW.tenant_id IS NOT NULL THEN
      RAISE EXCEPTION 'global role permissions require a global system role and NULL tenant_id'
        USING ERRCODE = '23514';
    END IF;
  ELSIF NEW.tenant_id IS DISTINCT FROM role_tenant THEN
    RAISE EXCEPTION 'role permission tenant must match the role tenant'
      USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER "role_permissions_tenant_role_guard"
  BEFORE INSERT OR UPDATE OF tenant_id, role_id ON "role_permissions"
  FOR EACH ROW EXECUTE FUNCTION "enforce_role_permission_tenant_role"();
--> statement-breakpoint
-- Prevent changing a role's ownership/type in a way that invalidates existing grants.
CREATE OR REPLACE FUNCTION "guard_role_tenant_identity_change"() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF (NEW.tenant_id IS DISTINCT FROM OLD.tenant_id OR NEW.is_system IS DISTINCT FROM OLD.is_system)
     AND (
       EXISTS (SELECT 1 FROM "membership_roles" mr WHERE mr.role_id = OLD.id
         AND NOT (NEW.tenant_id = mr.tenant_id OR (NEW.tenant_id IS NULL AND NEW.is_system = TRUE)))
       OR EXISTS (SELECT 1 FROM "role_permissions" rp WHERE rp.role_id = OLD.id
         AND NOT (rp.tenant_id IS NULL AND NEW.tenant_id IS NULL AND NEW.is_system = TRUE)
         AND rp.tenant_id IS DISTINCT FROM NEW.tenant_id)
     ) THEN
    RAISE EXCEPTION 'role ownership change conflicts with existing assignments or grants'
      USING ERRCODE = '23514';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER "roles_tenant_identity_guard"
  BEFORE UPDATE OF tenant_id, is_system ON "roles"
  FOR EACH ROW EXECUTE FUNCTION "guard_role_tenant_identity_change"();
