# 04 — UI/UX Master Specification

**Version:** 0.1 Draft | **Design direction:** professional creative-tech SaaS, clear operations, low-friction ordering.

## 1. Global experience principles
- One domain with route-based surfaces; public pages and authenticated workspaces share design tokens but have distinct navigation.
- Desktop-first for operations; responsive mobile for customer/reseller/agency portal and quick approvals.
- Indonesian-first copy, clear IDR formatting, timezone-aware dates.
- Every page includes loading, empty, error, permission-denied, and success states.
- Avoid destructive primary actions; use confirmation and explain downstream effects.
- Status is communicated with text + icon + color, never color alone.
- Accessibility: keyboard navigation, visible focus, semantic headings, labeled controls, sufficient contrast.

## 2. Route map / information architecture
| Surface | Route | Primary navigation |
|---|---|---|
| Public website | `/` | Beranda, Layanan, Katalog, Paket, Portfolio, Artikel, Tentang, Kontak |
| Catalog detail | `/katalog/[slug]` | Service detail, deliverables, price from, revisions, CTA order |
| Customer portal | `/portal` | Ringkasan, Pesanan, Penawaran, Tagihan, File, Tiket, Profil |
| Reseller portal | `/reseller` | Dashboard, Pelanggan, Pesanan, Harga, Komisi, Payout, Materi Promosi |
| Agency portal | `/agency` | Dashboard, Klien, Proyek, Pesanan, Deliverables, Billing, Team |
| Internal workspace | `/workspace` | Overview, CRM, Sales, Orders, Production, AI Usage, Finance, HR, Support, Reports |
| Platform admin | `/platform-admin` | Tenants, Plans, Entitlements, Platform Users, Integrations, Audit, Health |

## 3. Shared application shell
- Left sidebar: collapsible, role-filtered navigation, tenant/branch switcher.
- Top bar: global search, quick create, notifications, help, profile.
- Breadcrumbs and page title with concise description.
- Main content: summary metrics, filter bar, data table/kanban/calendar, detail drawer.
- Right-side contextual panel for activity, audit, attachments, and related records.
- Global command palette (later enhancement).
- Responsive: sidebar becomes drawer; tables expose card view or horizontal scroll.

## 4. Screen specifications by portal

### Public website
- Homepage hero with clear value proposition and primary CTA.
- Service category cards and featured deliverables.
- Pricing/package comparison with explicit inclusions, revision policy, delivery assumptions.
- Portfolio/gallery with filters and consent/license checks.
- Trust section: process, FAQs, commercial-use terms, testimonials (verified only).
- Lead/order forms with spam protection and consent.

### Customer portal
- Dashboard: active orders, pending approvals, unpaid invoices, recent messages.
- Order detail: brief, milestones, status timeline, assigned contact, deliverables.
- Quote detail: line items, validity, terms, accept/reject.
- Upload center: file requirements, progress, validation, virus scan integration point.
- Review workspace: preview, version compare, comment, request revision, approve.
- Billing: invoices, receipts, payment status, download documents.
- Support: ticket create, message thread, attachments, SLA/status.

### Reseller portal
- Overview: attributed sales, pending commissions, paid commissions, conversion.
- Customer directory: only attributed customers, lead registration and duplicate warning.
- Order creation: reseller price list and customer attribution.
- Commission statement: eligible base, rule, accrual, reversal, payout status.
- Marketing kit: approved assets and usage conditions.

### Agency portal
- Client switcher with strong client context indicator.
- Client dashboard: active projects, pending approvals, spend, deliverables.
- Project workspace: scope, timeline, tasks, assets, comments.
- Bulk order/brief upload and consolidated invoice view.
- Team management with agency-scoped roles.

### Internal workspace — shared dashboard
- KPI cards: leads, open quotes, orders in production, overdue work, receivables, AI cost.
- Work queue: assigned tasks, approvals, tickets, exceptions.
- Activity feed and alerts.
- Quick actions: lead, quote, order, production job, invoice, ticket.

### Internal workspace — module screen patterns
- CRM: pipeline kanban + customer table + customer 360 detail.
- Sales: opportunity board, quote editor, approval queue.
- Orders: searchable table, status filters, order detail with financial and production tabs.
- Production: kanban by stage, task board, calendar/capacity, QC review screen.
- AI operations: provider/model health, credit pool, usage ledger, generation job queue, reconciliation.
- Finance: invoice aging, payment allocation, cash/bank, journals, reconciliation, close checklist.
- HR: employee directory, attendance calendar, leave approval, payroll preparation/approval.
- Support: ticket queue, SLA timer, customer-visible/internal message distinction.
- Reports: report catalog, filters, preview, export with scope warning.

### Platform admin
- Tenant lifecycle and subscription plan entitlements.
- Platform user/role controls separated from tenant roles.
- Integration health and provider configuration metadata (secrets never displayed).
- Audit/security events, system health and feature flags.
- Break-glass tenant access requires reason, expiry, and audit event.

## 5. Key interaction patterns
- Tables: server pagination, filter chips, column preferences, export only if authorized.
- Forms: grouped sections, inline validation, autosave only for safe drafts.
- Financial forms: currency, tax, discount and totals visible before submit.
- Approval: show requester, evidence, amount, impact and approve/reject reason.
- File preview: explicit version, status, owner, license and download permission.
- Status changes: show valid next states; do not offer impossible transitions.
- Empty states: explain why empty and provide next action based on permission.

## 6. Design system deliverables
- Tokens: color, typography, spacing, radius, elevation, breakpoints.
- Components: buttons, inputs, select, date range, badge, alert, modal, drawer, tabs, table, kanban card, timeline, file uploader, status stepper, metric card.
- Templates: list, detail, create/edit, approval queue, dashboard, report builder.
- Figma-ready screen inventory and clickable flow prototype before production UI implementation.

## 7. Core prototype flows to validate
1. Visitor → catalog → order inquiry.
2. Customer → submit brief → upload assets → track job → approve final.
3. Sales agent → lead → quote → approval → order.
4. Creative operator → task → generation asset → QC → handoff.
5. Finance staff → invoice → payment allocation → receipt.
6. Reseller → register customer → order → view commission.
7. Agency admin → select client → submit multi-item brief → review delivery.
8. Tenant owner → invite user → assign scoped role → verify access.
