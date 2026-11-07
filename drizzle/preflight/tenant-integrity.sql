-- READ-ONLY preflight for migration 0001_tenant_composite_integrity.sql.
-- Run manually against a DEVELOPMENT branch only. This file contains SELECTs only.
-- Every query must return zero rows before the migration is considered ready.
SELECT 'departments.branch_id' AS relation, c.id AS child_id, c.tenant_id AS child_tenant, p.tenant_id AS parent_tenant
FROM departments c JOIN branches p ON p.id=c.branch_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'departments.parent_id', c.id, c.tenant_id, p.tenant_id
FROM departments c JOIN departments p ON p.id=c.parent_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'service_versions.service_id', c.id, c.tenant_id, p.tenant_id
FROM service_versions c JOIN services p ON p.id=c.service_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'service_prices.price_list_id', c.id, c.tenant_id, p.tenant_id
FROM service_prices c JOIN price_lists p ON p.id=c.price_list_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'service_prices.service_version_id', c.id, c.tenant_id, p.tenant_id
FROM service_prices c JOIN service_versions p ON p.id=c.service_version_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'leads.customer_id', c.id, c.tenant_id, p.tenant_id
FROM leads c JOIN customers p ON p.id=c.customer_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'quotations.customer_id', c.id, c.tenant_id, p.tenant_id
FROM quotations c JOIN customers p ON p.id=c.customer_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'orders.customer_id', c.id, c.tenant_id, p.tenant_id
FROM orders c JOIN customers p ON p.id=c.customer_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'orders.quotation_id', c.id, c.tenant_id, p.tenant_id
FROM orders c JOIN quotations p ON p.id=c.quotation_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'order_items.order_id', c.id, c.tenant_id, p.tenant_id
FROM order_items c JOIN orders p ON p.id=c.order_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'order_items.service_version_id', c.id, c.tenant_id, p.tenant_id
FROM order_items c JOIN service_versions p ON p.id=c.service_version_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'production_jobs.order_id', c.id, c.tenant_id, p.tenant_id
FROM production_jobs c JOIN orders p ON p.id=c.order_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'ai_credit_ledger.account_id', c.id, c.tenant_id, p.tenant_id
FROM ai_credit_ledger c JOIN ai_credit_accounts p ON p.id=c.account_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'membership_roles.membership_id', c.id, c.tenant_id, p.tenant_id
FROM membership_roles c JOIN tenant_memberships p ON p.id=c.membership_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'membership_roles.role_id', c.id, c.tenant_id, p.tenant_id
FROM membership_roles c JOIN roles p ON p.id=c.role_id
WHERE NOT (p.tenant_id=c.tenant_id OR (p.tenant_id IS NULL AND p.is_system=TRUE))
UNION ALL
SELECT 'membership_roles.branch_id', c.id, c.tenant_id, p.tenant_id
FROM membership_roles c JOIN branches p ON p.id=c.branch_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'membership_roles.department_id', c.id, c.tenant_id, p.tenant_id
FROM membership_roles c JOIN departments p ON p.id=c.department_id WHERE c.tenant_id<>p.tenant_id
UNION ALL
SELECT 'role_permissions.role_id', c.id, c.tenant_id, p.tenant_id
FROM role_permissions c JOIN roles p ON p.id=c.role_id
WHERE NOT (
  (p.tenant_id IS NOT NULL AND c.tenant_id=p.tenant_id)
  OR (p.tenant_id IS NULL AND p.is_system=TRUE AND c.tenant_id IS NULL)
);
