# 06 — Architecture Decision Records

**Version:** 0.1 | **Status:** Accepted for development unless marked as a release gate.

## ADR-001 — Modular monolith
**Decision:** Start with one Next.js application and PostgreSQL database, with explicit domain boundaries and service-layer APIs.  
**Reason:** Lowest operational complexity for the owner-operated launch while preserving the option to split high-load domains later.  
**Consequences:** No microservices, message broker, or separate API fleet in Foundation. Long-running media work must be queued/asynchronous when implemented.

## ADR-002 — Runtime and framework
**Decision:** Next.js 15.5.x, React 19, TypeScript, Node.js 22.  
**Reason:** App Router, server rendering, API routes, typed application surface, and supported Vercel runtime.  
**Deployment region:** Singapore (Vercel `sin1`) to remain close to Neon `aws-ap-southeast-1`.

## ADR-003 — Database and migrations
**Decision:** Neon PostgreSQL 18, Drizzle ORM 0.45.x, migration-as-code.  
**Development branch:** `specification-dev` (`br-noisy-meadow-aotl7lts`).  
**Production branch:** `br-muddy-meadow-ao4bob10`; do not use for development.  
**Rules:** Generate migrations from reviewed schema; replay on an empty development database; verify rollback/restore plan; only then plan production migration. No production DDL has been applied.

## ADR-004 — Authentication
**Decision:** Better Auth 1.7.x with PostgreSQL/Drizzle adapter; email/password; public registration blocked at the route layer.  
**Initial owner:** Created through a one-time bootstrap endpoint requiring `BOOTSTRAP_SECRET`; bootstrap refuses to run after the first tenant exists.  
**Release requirements:** Set a strong `BETTER_AUTH_SECRET`, configure trusted origins, enable email verification/reset delivery before public customer onboarding, and test session revocation/MFA for privileged roles.

## ADR-005 — Tenant isolation and RBAC
**Decision:** Shared PostgreSQL schema with tenant-owned rows carrying `tenant_id`; server-side tenant context and action permission checks are mandatory.  
**Scope vocabulary:** own, assigned, department, branch, organization, agency-client, reseller-attributed, platform, none.  
**Additional hardening:** Add and test PostgreSQL RLS policies, composite tenant-consistency constraints, and negative cross-tenant tests before production data is introduced. UI navigation is not an authorization boundary.

## ADR-006 — Financial and usage ledgers
**Decision:** Money uses fixed-precision decimal values and explicit ISO currency. Posted accounting entries and AI credit movements are append-only; corrections use reversal/adjustment entries.  
**AI cost model:** Track monthly provider subscription fee once per accounting period; record per-generation credit usage separately; allocate actual usage to orders only when supported by provider records or reviewed manual evidence.

## ADR-007 — AI provider integrations
**Decision:** Provider registry and manual/unverified state first.  
**Release gate:** No API integration is marked live until official API availability, credentials, commercial-use rights, cost basis, error handling, and end-to-end reconciliation are verified. UGCVideo.ai plan/credits are not assumed to imply API access.

## ADR-008 — File storage
**Decision:** Keep a storage adapter boundary; do not couple business records to a single vendor-specific public URL. Assets are private by default, tenant-scoped, versioned, and accessed through short-lived authorized URLs.  
**Provider selection:** Pending comparison of Neon Object Storage and S3-compatible storage, including regional location, egress, retention, malware scanning, lifecycle, and total cost. Do not enable a paid bucket before this review.

## ADR-009 — Payments and tax
**Decision:** Payment provider adapter, idempotent webhook event store, immutable payment allocation ledger, refund approvals.  
**Provider:** Not selected. Midtrans and Xendit are candidates for Indonesia; select after merchant account availability, fee schedule, settlement, refund, and recurring payment requirements are checked.  
**Tax:** Indonesian tax configuration must be effective-dated and configurable; never hard-code a tax rate in application logic.

## ADR-010 — Hosting and commercial terms
**Decision:** Vercel project created as `ai-creative-digital-ads-studio-platform` in team `akvisio-autohost`, Node 22, region `sin1`. GitHub connection is not yet installed for this repository; project currently has no deployment or domain.
**Commercial release gate:** The connected Vercel team is on the Hobby plan. Vercel terms restrict Hobby to personal/non-commercial use. This is a commercial services platform, so do not deploy production on Hobby. Use Vercel Pro or approve an alternative commercial host before go-live.
**Protection:** Vercel SSO protection is enabled for all deployment URLs except custom domains. Keep previews protected; expose the public custom domain only after security and launch checks pass.

## ADR-011 — Observability and operations
**Decision:** Health endpoint, structured server logs, correlation IDs, redaction, CI checks, preview smoke tests, backup/restore runbook, and incident response checklist.  
**Release gate:** Configure alert destinations and test database restore before accepting live customer data.

## Go-live checklist (must all pass)
- [ ] Owner bootstrap completed; bootstrap secret removed from deployment environment.
- [ ] Vercel commercial plan or alternative commercial host approved and active.
- [ ] GitHub repository connected to the deployment project.
- [ ] Neon development compute enabled and schema migration replayed successfully.
- [ ] RLS/composite tenant isolation tests pass.
- [ ] Email sender and domain authentication configured.
- [ ] Custom domain and DNS/HTTPS verified.
- [ ] Payment provider and webhook verification tested, or manual-payment workflow explicitly selected.
- [ ] Storage provider, access controls, backup/retention and malware scanning verified.
- [ ] AI provider rights, credentials and reconciliation verified or provider remains clearly manual.
- [ ] UAT, security review, restore drill, monitoring, and rollback plan signed off.
- [ ] Production migration and deployment approved; post-deploy smoke tests pass.
