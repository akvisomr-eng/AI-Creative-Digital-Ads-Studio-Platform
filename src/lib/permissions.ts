import { and, eq, isNull, or } from "drizzle-orm";
import { getDb } from "@/db";
import {
  membershipRoles,
  permissions,
  rolePermissions,
  roles,
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
 * Resolve a permission only through a role that is valid for the active tenant.
 *
 * membership_roles.tenant_id and role_permissions.tenant_id are both checked,
 * and the role itself must either belong to this tenant or be a global system
 * role (tenant_id IS NULL AND is_system = true). This prevents a malformed
 * cross-tenant role assignment from granting permissions in another tenant.
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
        eq(rolePermissions.tenantId, context.tenant.id),
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
