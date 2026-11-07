# Tenant Data Integrity Audit

**Baseline:** `main` after PR #3 (tenant-role isolation)  
**Scope:** Static review of `src/db/schema/core.ts`, the initial Drizzle migration, and tenant-context / permission resolution.  
**Safety:** This document is an audit artifact only. It does not apply SQL to any Neon branch or production database.

## Summary

Application permission resolution now filters membership-role assignments and role-permission grants by the active tenant, and accepts a role only when it belongs to that tenant or is explicitly a system role. This is a useful authorization-layer guard.

The database schema still models many tenant-owned relationships as independent single-column foreign keys. A normal foreign key proves that the referenced row exists; it does not prove that the referenced row has the same `tenant_id` as the source row. A cross-tenant reference can therefore remain representable if an application write path is defective or bypassed.

## Relationships requiring tenant-consistent constraints

Review and protect these relationships with composite candidate keys and composite foreign keys (typically `(tenant_id, id)`), or an equivalent database-enforced design:

| Child relationship | Referenced relationship | Risk |
| --- | --- | --- |
| `departments(tenant_id, branch_id)` | `branches(tenant_id, id)` | Department may reference another tenant's branch |
| `departments(tenant_id, parent_id)` | `departments(tenant_id, id)` | Department hierarchy may cross tenants |
| `membership_roles(tenant_id, membership_id)` | `tenant_memberships(tenant_id, id)` | Assignment may point to another tenant's membership |
| `membership_roles(tenant_id, role_id)` | `roles(tenant_id, id)` | Assignment may point to another tenant's role |
| `membership_roles(tenant_id, branch_id)` | `branches(tenant_id, id)` | Role scope may reference another tenant's branch |
| `membership_roles(tenant_id, department_id)` | `departments(tenant_id, id)` | Role scope may reference another tenant's department |
| `role_permissions(tenant_id, role_id)` | tenant-owned `roles(tenant_id, id)` | Tenant grant may attach to another tenant's role |
| `service_versions(tenant_id, service_id)` | `services(tenant_id, id)` | Version may reference another tenant's service |
| `service_prices(tenant_id, price_list_id)` | `price_lists(tenant_id, id)` | Price may reference another tenant's list |
| `service_prices(tenant_id, service_version_id)` | `service_versions(tenant_id, id)` | Price may reference another tenant's service version |
| `leads(tenant_id, customer_id)` | `customers(tenant_id, id)` | Lead may reference another tenant's customer |
| `quotations(tenant_id, customer_id)` | `customers(tenant_id, id)` | Quote may reference another tenant's customer |
| `orders(tenant_id, customer_id)` | `customers(tenant_id, id)` | Order may reference another tenant's customer |
| `orders(tenant_id, quotation_id)` | `quotations(tenant_id, id)` | Order may reference another tenant's quote |
| `order_items(tenant_id, order_id)` | `orders(tenant_id, id)` | Order item may belong to a different tenant than its order |
| `order_items(tenant_id, service_version_id)` | `service_versions(tenant_id, id)` | Item may snapshot a service version from another tenant |
| `production_jobs(tenant_id, order_id)` | `orders(tenant_id, id)` | Production job may point to another tenant's order |
| `ai_credit_ledger(tenant_id, account_id)` | `ai_credit_accounts(tenant_id, id)` | Ledger may debit/credit another tenant's account |

**System-role exception:** `roles.tenant_id IS NULL AND roles.is_system = true` is intentional. Do not force system roles through a tenant-owned composite FK. Keep system-role handling explicit in the permission query and add tests for both valid system roles and rejected non-system global roles. Consider a separate assignment design or a database trigger/checking function for this exception rather than weakening tenant-role constraints.

## Required remediation sequence

1. Add composite unique keys on referenced tenant-owned tables, for example `UNIQUE (tenant_id, id)`.
2. Add composite foreign keys on tenant-owned child relationships. Preserve existing single-column primary keys and useful delete behavior.
3. Handle nullable references correctly: a null optional reference should remain allowed; a non-null reference must match the same tenant.
4. Before enforcing constraints, run read-only orphan/cross-tenant preflight queries against a **development Neon branch**. Do not silently rewrite or delete existing records.
5. Add negative integration tests that attempt cross-tenant inserts/updates and expect database rejection.
6. Add permission/API tests: Tenant A cannot read or mutate Tenant B's customers, quotes, orders, jobs, credits, roles, or assignments by changing IDs or `x-tenant-id`.
7. Generate and review the Drizzle migration; run it only on a confirmed development branch first. Production migration requires a separate explicit approval.

## Read-only preflight query pattern

Use the following pattern for each relationship before adding a composite constraint:

```sql
SELECT child.id, child.tenant_id AS child_tenant_id,
       parent.tenant_id AS parent_tenant_id, child.parent_id
FROM child_table AS child
JOIN parent_table AS parent ON parent.id = child.parent_id
WHERE child.parent_id IS NOT NULL
  AND child.tenant_id <> parent.tenant_id;
```

Replace table and key names for each relationship. For the current schema, inspect nullable and required relationships separately. Also inspect duplicate candidate keys before adding unique indexes.

## Additional application-layer checks

- `requireTenantContext` correctly resolves membership from the authenticated session and checks any requested tenant against active memberships.
- Every data API must derive tenant ID from this context, not trust a request body/query tenant ID.
- Every lookup by resource ID must include the active tenant in the query predicate, even after database constraints are added.
- Keep authorization checks on both read and write endpoints; UI hiding is not authorization.
- Ensure system-role creation and role-permission assignment paths cannot mark arbitrary user-created roles as system roles.

## Current conclusion

PR #3 improves role-resolution isolation, but the static schema review identifies database-level cross-tenant reference gaps. The platform should not be described as fully tenant-isolated until the composite constraints, negative database tests, and tenant-scoped API tests have passed. No production data or database was changed during this audit.
