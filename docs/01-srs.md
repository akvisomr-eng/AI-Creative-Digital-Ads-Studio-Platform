# 01 — Software Requirements Specification (SRS)

**Version:** 0.1 Draft | **Baseline:** Blueprint v1.0  
**Purpose:** Define product behavior, scope, requirements, and acceptance rules before Foundation coding.

## 1. Product overview

A multi-channel creative services business platform for AI-assisted video ads, product photography, promotional posters, AI influencers, fashion visuals, merchandise mockups, and UMKM marketing packages. The platform supports one-off orders, bundles, subscriptions, resellers, agencies, and future SaaS tenants.

### User-facing surfaces
- Public website and catalog
- Customer portal
- Reseller portal
- Agency portal
- Internal operations workspace
- Platform administration workspace

### Initial operating assumptions
- Single operating company initially; architecture is multi-tenant-ready.
- Owner-led operation initially; team and department permissions are supported.
- Indonesian locale and IDR default; timezone `Asia/Jakarta`.
- Sales channels can be configured; WhatsApp/contact details remain configurable content, not hard-coded.
- AI provider usage and credit cost must be reconciled against actual invoices and generation records.

## 2. Goals and measurable outcomes
- Publish services and packages with versioned prices and clear revision/delivery terms.
- Track a lead from first contact through quotation, payment, production, approval, and delivery.
- Measure gross margin per order, package, and creative output using configurable HPP rules.
- Reconcile AI provider credits, failed jobs, refunds, and unused capacity.
- Provide customers and partners with transparent order status and authorized assets.
- Preserve accounting auditability and tenant isolation.
- Support growth from owner-operated operations to teams, agencies, and SaaS tenants.

## 3. Out of scope for Foundation
- Building a proprietary image/video generation model.
- Assuming UGCVideo.ai or other providers have a public API before verification.
- Automatic tax filing or bank integration without approved providers.
- Fully autonomous payment refunds, payroll disbursements, legal approval, or high-risk editorial decisions.
- Native Android/iOS apps in the first web Foundation release.
- Microservices decomposition before scale justifies it.

## 4. Global functional requirements
- FR-GEN-001: Every business record must have a stable UUID primary key.
- FR-GEN-002: Tenant-owned records must carry `tenant_id`; cross-tenant access is denied by default.
- FR-GEN-003: User authorization must be checked on the server for every read and mutation.
- FR-GEN-004: Business documents must have unique, configurable human-readable numbers within the defined tenant/fiscal period.
- FR-GEN-005: Important state transitions must record actor, timestamp, previous state, new state, and reason.
- FR-GEN-006: Money values use fixed-precision decimal, never floating point; currency is explicit.
- FR-GEN-007: All timestamps are stored in UTC and rendered in the user's configured timezone.
- FR-GEN-008: Files are private by default; access requires an authorized, time-limited download URL.
- FR-GEN-009: List screens support pagination, search, filters, sorting, and empty/error/loading states.
- FR-GEN-010: Exports must apply the same authorization and row-scope rules as on-screen data.
- FR-GEN-011: Destructive operations require confirmation and are soft-delete/archive where legally appropriate.
- FR-GEN-012: Audit events must not store passwords, access tokens, or raw payment credentials.

## 5. Non-functional requirements
- NFR-SEC-001: Password/session/auth implementation follows the selected identity provider's current security guidance.
- NFR-SEC-002: MFA is supported for privileged roles; step-up verification for sensitive actions.
- NFR-SEC-003: Tenant isolation is tested at API, query, export, and file-download layers.
- NFR-SEC-004: Secrets are held in deployment secret stores, never committed to Git.
- NFR-SEC-005: Rate limits and abuse controls apply to login, public forms, upload, and generation requests.
- NFR-DATA-001: Database changes are migration files reviewed in pull requests.
- NFR-DATA-002: Posted journals, invoices, payments, and credit-ledger entries are immutable; corrections use compensating entries.
- NFR-OPS-001: Production deployment requires CI, migration review, backup/restore plan, and smoke tests.
- NFR-OPS-002: Errors are observable with correlation IDs and redacted metadata.
- NFR-PERF-001: Initial target: p95 under 500 ms for ordinary workspace reads under agreed baseline load; heavy reports are asynchronous.
- NFR-A11Y-001: Core flows are keyboard navigable, labeled, contrast-aware, and responsive.
- NFR-I18N-001: Indonesian is the initial interface language; data model supports locale/currency/timezone configuration.

## 6. Detailed module requirements and feature inventory

### M01 — Platform & Organization Management
- Organization profile, legal identity, brand, logo, contact, default locale/currency/timezone.
- Tenant lifecycle: create, suspend, activate, archive; plan and feature entitlements.
- Branches, departments, teams, fiscal years, cost centers, numbering sequences.
- Business settings: tax defaults, invoice terms, approval thresholds, working calendar.
- Organization switcher for users with multiple memberships.
- Acceptance: tenant A cannot view tenant B's organization or business records; settings changes are audited.

### M02 — Identity, Authentication & RBAC
- Sign-up/invitation policy, sign-in/out, password recovery, session management.
- User profile, account status, MFA, active sessions, trusted devices (provider-dependent).
- Role templates, custom roles, permissions, role assignment by tenant/branch/department.
- Scope rules: own, assigned, department, branch, organization, platform.
- Sensitive-action re-authentication and approval delegation.
- Acceptance: unauthorized API requests return deny regardless of UI visibility; role changes invalidate or refresh effective permissions.

### M03 — Website, CMS & SEO
- Pages, landing pages, navigation, reusable content blocks, blog/articles, portfolio.
- Media library with alt text, captions, focal point, license/usage metadata.
- Draft/review/publish/schedule/unpublish workflow and revision history.
- SEO title/description/canonical, OG metadata, sitemap, robots, redirects, structured data.
- Preview, slug collision validation, internal links, analytics integration settings.
- Acceptance: published pages render without workspace authentication; drafts are not publicly accessible.

### M04 — Product & Service Catalog
- Service categories, SKUs, variants, deliverable specifications, package composition.
- Retail, wholesale, reseller, agency, and tenant-specific price lists with effective dates.
- HPP rules: credit allocation, labor/QC, overhead allocation, external cost.
- Revision limits, delivery SLA, source-material requirements, licensing/commercial-use terms.
- Publish/unpublish and catalog version history.
- Acceptance: existing orders retain the exact price/specification snapshot at order time.

### M05 — CRM & Customer Management
- Leads, people, organizations, contacts, addresses, channels, tags, segments.
- Lead source, pipeline stage, owner, assignment, activities, notes, reminders.
- Duplicate detection and merge with audit trail.
- Customer timeline: quotations, orders, invoices, tickets, delivered assets.
- Consent and communication preference tracking.
- Acceptance: CRM lists and exports obey record scope and consent rules.

### M06 — Sales & Quotation
- Sales pipeline, opportunity value, probability, target, forecast.
- Quotation builder with versioned line items, discounts, tax, validity, terms.
- Approval thresholds for discounts and non-standard terms.
- Send/share PDF link, acceptance/rejection/expiry, convert to order.
- Sales activity and conversion reporting.
- Acceptance: accepted quote conversion preserves line-item snapshots and approval history.

### M07 — Order & Subscription Management
- One-off orders, bundles, recurring plans, renewals, pause/cancel, add-ons.
- Order items and package component expansion; customer brief and due dates.
- Deposits, payment milestones, cancellation/refund policy, order status history.
- Subscription cycle, invoice schedule, entitlement and usage window.
- Acceptance: order status cannot skip required payment/approval/production gates unless authorized override is audited.

### M08 — Creative Production Management
- Job cards, creative brief, script, storyboard, shot/scene references.
- Tasks, assignees, priority, due dates, dependencies, capacity/calendar.
- Asset intake, versioning, work-in-progress, QC checklist, revisions, approval.
- Delivery bundle, proof of delivery, final archive and license metadata.
- Acceptance: customer sees only approved deliverables for their own orders; internal drafts remain private.

### M09 — AI Provider & Credit Management
- Provider/model registry, service capability, pricing/cost rule effective dates.
- Provider subscription, invoice, credit pool, balance, usage ledger, manual adjustment approval.
- Generation request, model, parameters, prompt reference, output asset, job status, retries.
- Failed/cancelled job credit handling and provider reconciliation.
- Cost allocation to order, deliverable, project, and reporting period.
- Acceptance: ledger is append-only; balance is derived from entries; no double-counting of monthly subscription cost.

### M10 — Customer Portal
- Secure account, profile, order list/detail, quote acceptance, brief submission.
- File upload, payment instructions/status, production progress, revision request.
- Preview, approve/reject, download, invoice/receipt, support ticket.
- Notifications and communication preferences.
- Acceptance: customer A cannot access customer B's order, payment, or files even by guessing IDs/URLs.

### M11 — Reseller Management
- Application, verification, status, tier, agreement and validity.
- Reseller price list, customer referral/ownership, order attribution.
- Commission rules, eligible base, reversals, payout request and approval.
- Sales kit, campaign assets, performance dashboard.
- Acceptance: commission calculation is reproducible from immutable order/payment events and approved rules.

### M12 — Agency Management
- Agency profile, agreement, team members, client portfolio.
- Multi-client workspace, client-level permissions and project visibility.
- Wholesale price lists, credit limits, consolidated billing.
- White-label settings and branded delivery (feature-gated).
- Acceptance: agency users only see clients explicitly assigned to that agency and their granted scope.

### M13 — Project & Contract Management
- Project charter, scope, deliverables, milestones, budget and owner.
- Contract templates, parties, signature status, amendments, expiry.
- Tasks, risks, change requests, time/cost tracking.
- Project profitability and closeout.
- Acceptance: scope changes require versioned change request and approval.

### M14 — Invoice, Billing & Payment
- Invoice, pro forma, deposit invoice, recurring billing, credit note, refund.
- Payment records, allocations, partial payments, overpayments, payment method.
- Gateway integration adapter, webhook idempotency, reconciliation.
- Receipts, aging, reminders, customer statements.
- Acceptance: duplicate webhooks cannot duplicate payments; refunds require permission and audit trail.

### M15 — ERP, Procurement & Inventory
- Vendor directory, purchase requisition/order, goods receipt, vendor bill/payment.
- Inventory items, categories, units, warehouses, stock movements and adjustments.
- Creative equipment/assets, assignment, maintenance, depreciation handoff.
- Expenses, budgets, procurement approvals.
- Acceptance: stock balances reconcile to movement ledger; adjustments require reason and approval.

### M16 — Accounting & Finance
- Chart of accounts, journals, journal lines, general ledger, trial balance.
- AR/AP control accounts, cash/bank accounts, transfers, reconciliation.
- Cost centers, budgets, fixed assets, depreciation, tax codes and periods.
- Period close, lock, financial statements, audit trail.
- Acceptance: every posted journal balances by currency; closed periods reject ordinary posting; corrections use reversal.

### M17 — HRD & Payroll
- Employee profile, employment, contract, department, position, compensation.
- Attendance, shifts, leave, overtime, timesheets, performance and training.
- Payroll components, payroll run, approvals, payslips and accounting journal export.
- Confidential field access, separation of HR/payroll duties.
- Acceptance: payroll data is hidden from non-authorized roles; payroll runs are versioned and locked after approval.

### M18 — Customer Service & Quality
- Ticket, category, priority, SLA, assignment, status, internal/public messages.
- Complaint, revision, defect, root cause, resolution and satisfaction survey.
- QC templates by service, review checklist, rejection reason and rework.
- Escalation and service metrics.
- Acceptance: customer-facing messages are separated from internal notes; SLA clock and status changes are auditable.

### M19 — Business Intelligence & Reporting
- Executive dashboard, sales, CRM, production, AI usage/cost, partner, finance, HR, support.
- Saved filters, date range, comparison periods, drill-through with permission checks.
- PDF/XLSX/CSV export, scheduled reports (later phase), report definitions.
- Reconciliation between dashboard totals and source ledgers.
- Acceptance: report totals reconcile to source data and row-level security applies to exports.

### M20 — System Administration, Audit & Security
- Audit log, login/security events, feature flags, notification templates and delivery log.
- API keys, webhook endpoints, integration health, import/export jobs.
- Backup/restore operations, retention policies, monitoring and incident records.
- Platform admin controls separated from tenant admin.
- Acceptance: privileged actions are logged; secrets are masked; tenant admins cannot grant platform-level permissions.

## 7. Primary end-to-end workflows
1. Lead → opportunity → quotation → approval → accepted quote → order.
2. Order → invoice/deposit → payment allocation → production job → QC → customer approval → delivery → close.
3. AI generation request → provider job → output asset → credit ledger → cost allocation → reconciliation.
4. Reseller-attributed order → payment settled → commission accrual → approval → payout.
5. Procurement request → PO approval → goods receipt → vendor bill → payment → stock/GL posting.
6. Payroll preparation → validation → approval → locked payroll run → payslip → journal export.
7. Customer ticket → triage → production/QC resolution → customer confirmation → close.

## 8. State machine principles
- Status values are explicit enums/reference records; transitions are server-validated.
- Every transition has actor, timestamp, reason and correlation ID.
- Payment status is derived from allocations and reversals, not manually overwritten.
- Production status and customer approval are separate dimensions.
- Failed provider jobs do not silently consume or refund credits; reconciliation policy is explicit.

## 9. Foundation release acceptance gate
- Organization/tenant context, authentication, RBAC, CMS, catalog, CRM, sales, orders, and customer portal skeleton.
- Tenant isolation tests pass for API, queries, files, exports, and background jobs.
- Database migrations replay cleanly on an empty development database.
- Seed data is non-production and reproducible.
- CI lint/typecheck/unit/integration tests pass.
- No secrets in repository; deployment preview smoke tests pass.
- Product owner signs off on the final SRS, ERD, RBAC, UX, and backlog before production rollout.
