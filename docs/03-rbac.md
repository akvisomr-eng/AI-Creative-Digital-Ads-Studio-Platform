# 03 — RBAC Matrix: Action and Data Scope

**Version:** 0.1 Draft  
Authorization is a combination of permission (`module.resource.action`) and data scope. A role does not automatically imply organization-wide access.

## 1. Scope vocabulary
| Scope | Meaning |
|---|---|
| `own` | Records created by or explicitly owned by the user |
| `assigned` | Records assigned to the user as owner, assignee, reviewer, or collaborator |
| `department` | Records within the user's active department |
| `branch` | Records within an authorized branch |
| `organization` | All records in the active tenant |
| `agency_client` | Only customer records assigned to the agency |
| `reseller_attributed` | Customers/orders attributed to that reseller |
| `platform` | Cross-tenant platform administration; never granted by tenant roles |
| `none` | No access |

Scopes are intersected with tenant boundary. `platform` is a separate privilege and cannot be inherited from tenant membership.

## 2. Standard actions
`view`, `list`, `create`, `update`, `delete/archive`, `assign`, `approve`, `reject`, `export`, `publish`, `post`, `reverse`, `refund`, `manage_settings`, `manage_permissions`.

## 3. Role catalogue
- `platform_super_admin`: platform-level lifecycle, feature entitlements, security; no routine access to tenant content unless break-glass grant is logged.
- `tenant_owner`: organization-wide business owner; can delegate tenant roles, cannot grant platform permissions.
- `tenant_admin`: organization settings and user administration within tenant; sensitive finance/payroll actions remain separately permissioned.
- `operations_manager`: CRM/sales/order/production organization scope; no accounting posting by default.
- `sales_manager`: sales pipeline, quotations, discounts within approval limit.
- `sales_agent`: own/assigned leads, opportunities, quotes and customer interactions.
- `creative_lead`: production jobs, task assignment, QC and deliverable approval within department.
- `creative_operator`: assigned production tasks and authorized assets only.
- `finance_manager`: invoices, payments, accounting and reconciliation; dual approval for refunds/period close.
- `finance_staff`: create drafts, allocate receipts, prepare journals; cannot approve own sensitive transactions.
- `hr_manager`: employee records and HR workflows; payroll access requires separate grant.
- `payroll_officer`: payroll preparation and payslips; cannot change own compensation or approve own run.
- `support_agent`: assigned tickets and customer-visible messages.
- `customer`: own profile, quotes, orders, invoices, tickets and approved assets.
- `reseller`: own attributed customers/orders, reseller pricing, commission statement.
- `agency_admin`: agency membership and explicitly assigned client portfolio.
- `agency_operator`: assigned client projects and deliverables.
- `auditor`: read-only, organization scope with sensitive field masking and export restrictions.

## 4. Action matrix (default role grants)
Legend: `O` organization, `D` department, `B` branch, `A` assigned, `W` own, `C` agency-client, `R` reseller-attributed, `P` platform, `—` deny. `*` requires approval/step-up; exact permissions remain independently configurable.

| Module/resource | Owner | Tenant admin | Ops mgr | Sales mgr/agent | Creative lead/operator | Finance mgr/staff | HR/payroll | Support | Customer | Reseller | Agency | Auditor | Platform admin |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Organization settings | O | O | — | — | — | — | — | — | — | — | — | — | P |
| Users/roles | O* | O* | — | — | — | — | — | — | — | — | Agency only | — | P* |
| CMS content | O | O | O | — | — | — | — | — | Public | — | — | O read | P |
| Catalog/prices | O | O | O | O | — | — | — | — | Public read | R read | C read | O read | P |
| CRM customers/leads | O | O | O | A/O | — | — | — | A | W | R | C | O read | P* |
| Quotations/sales | O | O | O | A/O | — | — | — | — | W accept | R | C | O read | P* |
| Orders/subscriptions | O | O | O | A | D/A | O read | — | A | W | R | C | O read | P* |
| Production jobs/tasks | O | O | O | A read | D/A | — | — | A read | W status | R read | C | O read | P* |
| AI credit ledger | O | O | O read | — | D consume view | O* | — | — | — | — | — | O read | P* |
| Customer portal data | O | O | O | A | A | O | — | A | W | R | C | O read | P* |
| Reseller/commission | O | O | O | O read | — | O* | — | — | — | R | — | O read | P* |
| Agency/client portfolio | O | O | O | — | A | O read | — | — | — | — | C | O read | P* |
| Project/contracts | O | O | O | A | D/A | O read | — | A read | W sign | R read | C | O read | P* |
| Invoice/payment/refund | O* | O* | O read | A read | — | O/A* | — | — | W pay | R read | C read | O read | P* |
| Procurement/inventory | O | O | O | — | D request | O/A* | — | — | — | — | — | O read | P* |
| Accounting/GL | O* | O* | — | — | — | O/A* | — | — | — | — | — | O read | P* |
| HR employee data | O* | O* | — | — | — | — | O/A | — | — | — | — | O masked | P* |
| Payroll | O* | — | — | — | — | O read | O/A* | — | Own payslip | — | — | O masked | P* |
| Support tickets | O | O | O | A read | A read | A read | — | A/O | W | R | C | O read | P* |
| Reports/export | O | O | O | A | D | O/A | D | A | W | R | C | O restricted | P* |
| Audit/security | O read | O read | — | — | — | O read | — | — | — | — | — | O read | P |

## 5. Sensitive-action separation of duties
- Refund: requester cannot be sole approver; amount threshold and reason required.
- Journal posting: preparer and approver separated above configured threshold.
- Payroll: payroll preparer cannot approve own run; owner/authorized approver signs off.
- Role escalation: user cannot grant a permission they do not possess; platform permissions never tenant-grantable.
- Bank reconciliation and period close: require dedicated permission and audit evidence.
- AI credit adjustment: reason, evidence, approver and ledger reversal/adjustment entry required.
- Tenant export: export permission plus row scope; sensitive fields masked by default.

## 6. Enforcement model
1. Resolve authenticated user and active tenant.
2. Load membership status and effective role grants.
3. Evaluate requested permission.
4. Apply tenant filter and scope predicate on the server.
5. Apply field-level masking and action-specific approval constraints.
6. Log privileged mutations and export events.
7. Re-check authorization for download URLs and background jobs.

## 7. Minimum authorization test suite
- Cross-tenant read/update/delete denial.
- Own vs assigned vs department vs branch vs organization scope tests.
- Direct-object-ID/UUID guessing tests.
- Export and report scope parity.
- Signed file URL access and expiry tests.
- Role revocation/session invalidation.
- Self-approval prevention for refunds, payroll, journal posting and role escalation.
- Agency user cannot traverse to an unassigned client.
- Reseller cannot inspect another reseller's customer/order/commission.
