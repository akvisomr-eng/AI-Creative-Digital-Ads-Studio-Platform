# Tenant composite-integrity rollout

## Scope
Migration `0001_tenant_composite_integrity.sql` adds composite tenant-scoped foreign keys for tenant-owned relationships and guard triggers for role exceptions. It does not alter application data, rewrite records, or provision infrastructure.

## Important role exception
- A tenant-owned role may only be assigned and granted inside its own tenant.
- A global role is valid only when `tenant_id IS NULL AND is_system = TRUE`.
- Global system-role permission rows must also have `role_permissions.tenant_id IS NULL`.
- A non-system global role is rejected.
- Membership, branch and department references always remain tenant-scoped.

## Rollout gate (not performed by this PR)
1. Confirm a development-only Neon branch and its compute endpoint.
2. Run `drizzle/preflight/tenant-integrity.sql` read-only on that development branch. All result rows must be empty.
3. Review any returned rows manually; do not auto-repair, delete, or reassign data.
4. Apply migration `0001_tenant_composite_integrity.sql` on development only, after separate approval.
5. Run negative tests for every relationship, including null optional references and global system-role exceptions.
6. Verify application/API tests and deployment preview.
7. Production rollout requires a separate explicit approval.

## Safety
This PR only adds source and migration files in GitHub. It does not enable Neon compute, connect to a database, run SQL, execute Drizzle migrations, or change production.
