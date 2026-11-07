import { and, eq, isNull, or } from "drizzle-orm";
import { getDb } from "@/db";
import {
  membershipRoles,
  permissions,
  rolePermissions,
  roles,
  tenantMemberships,
} from "@/db/schema/core";
import {
  requireTenantContext,
  TenantContextError,
} from "@/lib/tenant-context";

export type DataScope =
  | "own"
  | "assigned"
  | "department"
  | "branch"
  | "organization"
  | "agency_client"
  | "reseller_attributed"
  | "platform"
  | "none";

/**
 * Resolve a permission only through an active membership and a role/grant
 * pair whose tenant ownership is consistent.
 *
 * Tenant roles use tenant-scoped role_permissions rows. Global roles are
 * accepted only when roles.tenant_id IS NULL AND roles.is_system = true,
 * with a matching global role_permissions row (tenant_id IS NULL).
 */
export async function requirePermission(
  permissionCode: string,
  requestHeaders?: Headers,
) {
  const context = await requireTenantContext(requestHeaders);
  const db = getDb();

  const grants = await db
    .select({ scope: rolePermissions.scopePolicy })
    .from(membershipRoles)
    .innerJoin(
      tenantMemberships,
      and(
        eq(membershipRoles.membershipId, tenantMemberships.id),
        eq(membershipRoles.tenantId, tenantMemberships.tenantId),
        eq(tenantMemberships.status, "active"),
      ),
    )
    .innerJoin(
      roles,
      and(
        eq(membershipRoles.roleId, roles.id),
        or(
          eq(roles.tenantId, context.tenant.id),
          and(isNull(roles.tenantId), eq(roles.isSystem, true)),
        ),
      ),
    )
    .innerJoin(
      rolePermissions,
      and(
        eq(membershipRoles.roleId, rolePermissions.roleId),
        or(
          and(
            eq(roles.tenantId, context.tenant.id),
            eq(rolePermissions.tenantId, context.tenant.id),
          ),
          and(
            isNull(roles.tenantId),
            eq(roles.isSystem, true),
            isNull(rolePermissions.tenantId),
          ),
        ),
      ),
    )
    .innerJoin(
      permissions,
      eq(rolePermissions.permissionId, permissions.id),
    )
    .where(
      and(
        eq(membershipRoles.tenantId, context.tenant.id),
        eq(membershipRoles.membershipId, context.membershipId),
        eq(tenantMemberships.userId, context.user.id),
        eq(permissions.code, permissionCode),
      ),
    );

  if (!grants.length) {
    throw new TenantContextError("Permission denied.", 403);
  }

  const scopes = [...new Set(grants.map((grant) => grant.scope as DataScope))];
  if (scopes.includes("none") && !scopes.some((scope) => scope !== "none")) {
    throw new TenantContextError("Permission denied.", 403);
  }

  return {
    ...context,
    permission: permissionCode,
    scopes: scopes.filter((scope) => scope !== "none"),
  };
}
