# 15 — Autonomous Platform Implementation Backlog

**Status:** Proposed delivery plan; work must be reconciled with existing Foundation and tenant-integrity PRs before implementation.

## Delivery principles

- Keep the current modular monolith and existing auth/tenant boundaries.
- No overlapping schema changes while tenant-integrity work is under review.
- Every database change is a reviewed migration with replay and tenant-isolation tests.
- Provider integration is disabled until official API, rights, privacy, pricing and reconciliation are verified.
- Ship vertical slices with working UI/API/tests, not disconnected mock buttons.
- Feature-flag unfinished capabilities; production defaults remain disabled.
- Parallelize independent documentation, design, test, and adapter research; serialize shared schema and release integration.

## Workstreams

### WS0 — Foundation and release safety
- Reconcile open PRs, CI and deployment status.
- Confirm development database branch and backup/restore procedure.
- Resolve tenant-consistency constraints and permission coverage.
- Confirm commercial hosting plan before production use.
- Define object storage and queue strategy before media uploads/long-running generation.

### WS1 — Order Intelligence
- Order intake form and multi-file upload.
- Attachment parsing with safe file validation.
- Taxonomy and classification schema.
- Structured brief extraction with provenance/confidence.
- Missing-information and risk questions.
- Parent order / child production jobs.
- Operator override and classification feedback.

**Acceptance:** test brief corpus produces valid categories or explicit custom/manual state; no invented facts; tenant-scoped access.

### WS2 — Prompt Studio
- Prompt template registry and versions.
- Image/video/UGC/audio/design prompt modes.
- Structured provider-neutral creative spec.
- Provider-specific compiler/validator interface.
- Scene/storyboard builder and prompt variants.
- Prompt version history, diff, reuse and evaluation.
- Customer preview and approval.

**Acceptance:** prompt saved and traceable to brief, order, template/model/instruction versions and output assets.

### WS3 — Workflow and Agent Runtime
- Agent registry, role instructions and tool allowlists.
- Workflow definitions, runs, tasks, dependencies and event log.
- Durable queue/lease/heartbeat/claim model.
- Typed agent invocation contract and output validation.
- Retry, idempotency, checkpoint and recovery.
- Per-tenant and per-provider concurrency controls.
- Operator work queue and kill switch.

**Acceptance:** simulated workflow survives worker interruption and resumes without duplicate billable submissions.

### WS4 — Provider and Cost Control
- Provider/model capability catalog.
- Evidence and review status for API, rights, privacy and pricing.
- Adapter contract and mock provider.
- First sandbox adapter only after explicit account and rights approval.
- Credit reservation, append-only ledger and reconciliation.
- Provider health, rate limits, cost caps and fallback policy.

**Acceptance:** no unverified provider can be selected for paid customer work; actual usage reconciles to order cost.

### WS5 — Production and Quality
- Production job board and task timeline.
- Parallel task graph and progress.
- Asset versioning and private storage adapter.
- Technical/creative/brand/rights QC checklists.
- Revision requests, included revision counters and change orders.
- Human approval gates and exceptions.

**Acceptance:** one complete service workflow reaches QC with traceable assets and no skipped gates.

### WS6 — Delivery and Customer Success
- Delivery manifest, checksum and license snapshot.
- Authorized preview/download links.
- Customer approval/rejection and feedback.
- Delivery notification and proof of delivery.
- Order closeout, actual HPP, invoice/payment reconciliation.
- Customer archive and retention/deletion controls.

**Acceptance:** only approved assets are delivered to the correct customer; access is tenant-scoped and auditable.

### WS7 — Business Automation and Analytics
- Quote and pricing rules.
- Deadline/SLA manager and capacity planning.
- Notifications and escalation.
- Agent/provider performance dashboard.
- Per-service cost and gross-margin reports.
- Reseller/agency attribution and package entitlements.
- Scheduled reports after reliability and consent controls.

**Acceptance:** order profitability reconciles to source cost and financial ledgers.

## Parallel execution plan

| Stream | Can run in parallel with | Must wait for |
|---|---|---|
| Taxonomy and intake UX | Prompt template design, agent policy | Final service catalog alignment |
| Prompt Studio UX | Order taxonomy, provider capability research | Prompt schema contract |
| Agent instructions/evals | Workflow UX, security threat model | Tool permission contract |
| Provider due diligence | Workflow architecture, HPP rules | Commercial/legal approval before API use |
| Workflow engine | Agent roster, UI design | Tenant-safe schema and queue decision |
| Production/QC checklists | Delivery UX, service catalog | Deliverable definitions |
| Shared DB migrations | None when touching overlapping tables | Tenant-integrity baseline and schema review |

## Initial service pilot

Start with one low-risk, measurable service:
**15-second product social ad using customer-owned product images, 9:16 output, Indonesian copy, no real-person likeness by default.**

Pilot scope:
- One parent order, one production job.
- One creative concept, one script, storyboard and scene prompts.
- One approved image/video provider route or a mock provider in test.
- Two or three output variants only if budget allows.
- Technical and brand QC, one included revision, customer approval and secure delivery.
- Actual provider usage and HPP reconciliation.

Do not begin with all 18 agent roles executing live external calls. First prove the workflow with deterministic tasks and mocked providers, then enable the smallest set of agents needed for this pilot.

## Definition of done

A feature is done only when:
- UX, API, domain service and database ownership are clear.
- Server-side RBAC and tenant isolation are enforced and tested.
- Input/output schemas and state transitions are validated.
- Failure, retry, idempotency and audit behavior are tested.
- Cost and usage are measured where applicable.
- Accessibility, responsive layout and empty/error/loading states exist.
- Documentation and operator runbook are updated.
- CI lint, typecheck, tests and build pass.
- Feature flag and rollback path exist.
- Production rollout has explicit approval.
