# PR #5 technical review — follow-up

## Review result

The branch passes repository CI and Vercel produced a Ready preview deployment. These are useful source/build checks; neither proves migration compatibility with a live PostgreSQL schema or tenant constraints against real rows.

## Confirmed from repository source

- Tenant-owned tables use UUID identifiers and tenant UUIDs, so the composite (tenant_id, id) key design is type-compatible with the current schema.
- Existing single-column foreign keys are present for the relationships replaced by the migration.
- The global-role exception is represented by nullable roles.tenant_id and is_system; trigger guards are therefore used rather than a conventional composite FK for nullable global roles.
- The permission resolver now requires the membership row to match the authenticated user and active tenant, and requires tenant-local grants for tenant roles or global grants for global system roles.

## Required follow-up before merge

1. **Drizzle schema parity:** src/db/schema/core.ts currently declares the existing single-column references and does not yet declare the new composite foreign keys or composite unique indexes. The migration and Drizzle schema must be brought into parity before merging, otherwise future drizzle-kit generate output may not accurately represent the database constraints.
2. **Migration name verification:** the migration drops generated FK names. Keep these names aligned with the exact names in 0000_black_lionheart.sql; do not use guessed names.
3. **Global-role data compatibility:** the preflight must return no rows for tenant assignments to foreign roles, non-system global roles, or tenant-scoped permission rows attached to global roles. Existing data must not be auto-corrected.
4. **Database test matrix:** after compute is explicitly authorized, run positive and negative tests on development. Include cross-tenant parent references for every composite FK, valid same-tenant references, null optional references, global system-role assignment, tenant-role assignment, and rejected global/non-system role grants.
5. **Permission integration tests:** verify inactive membership, membership belonging to another user, cross-tenant role assignment, cross-tenant permission grant, valid tenant role, and valid global system role.
6. **Migration safety:** run the read-only preflight first; if it returns any rows, stop and review manually. Apply the migration only to development after separate approval.

## Important rollout note

A Vercel Preview marked Ready confirms the application build/deployment succeeded. It does not confirm database connectivity, migration execution, or tenant-isolation behavior.

## Actions deliberately not performed

- No Neon compute activation.
- No database connection or SQL execution.
- No migration execution.
- No production database changes.
- No merge to main.
