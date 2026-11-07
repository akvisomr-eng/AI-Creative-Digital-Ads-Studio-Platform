# AI Provider Integration Architecture

**Status:** Proposed for implementation after the current tenant-integrity draft PR is resolved.  
**Architecture style:** Provider-independent adapters inside the existing modular monolith.

## 1. Objectives

- Keep the application independent from any single AI vendor.
- Separate discovery/catalog records from verified API integrations.
- Route generation jobs only to adapters whose credentials, rights, pricing, and health are approved.
- Track provider subscriptions separately from per-generation usage.
- Allocate actual usage to customer orders without inventing costs from estimated credits.
- Support a browser-only external tool when no approved API exists.

## 2. Provider lifecycle

discovered → researching → external_only | sandbox_eligible → commercial_review → production_eligible

Any provider can move to suspended if its API, rights, service health, or economics fail review.

Status is controlled by platform administrators. A provider must never become production-eligible merely because an API key has been entered.

## 3. Domain boundaries

### Provider catalog
Stores vendor identity, product URL, capabilities, category, supported input/output formats, regions, and current review status.

### Provider integration
Stores adapter type, API base URL, authentication scheme identifier, webhook support, rate limits, and secret reference. Secret values live only in deployment secret storage; never in PostgreSQL business rows, logs, browser code, or Git.

### Model catalog
Stores vendor model identifier, capability tags, input/output constraints, version, availability, and provider-specific parameter schema reference.

### Pricing and entitlements
Stores effective-dated plan price, included credits/minutes, per-operation price, currency, watermark, export limits, commercial-use flag, and evidence/source URL. Unknown values remain null or unverified, not zero.

### Generation jobs
Stores tenant, customer/order/project association, requested capability, selected provider/model, normalized request metadata, status, provider task ID, timestamps, retry count, and safe error classification. Prompt and uploaded media access must follow tenant privacy and retention policies.

### Usage ledger
Append-only records for reservation, actual charge, release, refund/credit, manual adjustment, and reconciliation. Corrections use compensating entries. Monthly subscription fees are recorded once per billing period and are not duplicated as per-generation cost.

### Output assets
Private tenant-scoped assets with provider attribution, model/version, generation job, license evidence snapshot, watermark status, and retention/deletion policy.

## 4. Adapter contract

Each approved provider adapter should implement a common server-side contract:

- capabilities(): supported operations and constraints.
- estimateCost(request): returns a range or explicit unknown; never fabricates a price.
- validateRequest(request): validates dimensions, duration, file type, and policy.
- submit(request, idempotencyKey): creates provider task.
- getStatus(providerTaskId): normalizes queued/running/succeeded/failed/cancelled.
- fetchResult(providerTaskId): returns result metadata and secure download reference.
- cancel(providerTaskId): optional, only when provider supports it.
- verifyWebhook(headers, body): optional signature verification.
- reconcileUsage(period): imports usage or invoice data when supported.

Adapters must not scrape private endpoints, automate browser sessions against provider terms, bypass paywalls, or reuse personal free accounts for multi-customer commercial service.

## 5. Routing policy

1. Filter providers by capability, input compatibility, tenant plan, legal rights, and production status.
2. Exclude providers with unknown commercial rights for customer-facing paid work.
3. Estimate cost using current effective-dated pricing; if unknown, require manual quote/approval.
4. Rank eligible providers by configured policy: cost, quality tier, latency, reliability, and region.
5. Reserve the tenant's internal credits or approved budget before submission.
6. Submit with idempotency key; store provider task ID.
7. Poll or receive signed webhook; normalize state.
8. On success, register private output asset and actual usage.
9. On failure, reconcile provider charge before releasing/refunding internal credits.
10. If no eligible provider exists, place job in needs_provider or needs_approval; do not silently switch to an unapproved provider.

Fallback is allowed only between providers that support the same requested capability and have passed the same legal, security, and quality gates.

## 6. External-tool mode

For providers without an approved API:
- Show vendor name, official URL, capability summary, free-tier limitations, and verification date.
- Launch the vendor's public product page in a new tab.
- Do not collect vendor passwords or API keys.
- Allow users to attach their completed output through the platform's authorized upload flow.
- Mark usage as manually declared / evidence-pending until a receipt, export record, or administrator review is attached.
- Do not advertise this as in-app generation.

## 7. Security and tenant isolation

- Resolve tenant and user permissions on the server for every provider, job, asset, and usage-ledger operation.
- Keep provider credentials in Vercel encrypted environment variables or a future approved secrets manager; use server-only access.
- Redact prompts, tokens, signed URLs, and customer media metadata from logs.
- Apply rate limits, per-tenant quotas, upload validation, file scanning, and request-size limits.
- Verify webhook signatures and enforce replay/idempotency protection.
- Do not send customer files or personal data to a provider until its privacy/retention terms are approved and the customer has been informed where required.
- Record a snapshot of commercial-use terms and provider pricing used for each customer deliverable.

## 8. Internal credit and cost model

Track these independently:
- Provider subscription fee (monthly/annual, one period-level expense).
- Provider included credits/minutes.
- Actual provider usage per generation.
- Internal customer credits or package entitlements.
- Actual cost allocation to order/project/deliverable.
- Failed-job charges, refunds, and manual corrections.

Never equate a vendor's credits with the platform's customer credits. Maintain a conversion/pricing rule with currency, effective dates, and evidence. Use decimal money values; do not use floating point.

## 9. Initial rollout slices

### Slice A — Documentation and catalog only
- Provider inventory and evidence register.
- Provider status vocabulary.
- Admin-only catalog records; no API credentials or generation execution.

### Slice B — Manual operations and ledger
- Manual job records, provider usage import, evidence attachment.
- Append-only usage ledger and cost allocation.
- No external API call.

### Slice C — First official API adapter
- Choose one sandbox-eligible provider after rights and account verification.
- Server-only credentials, idempotency, status polling/webhook, usage reconciliation.
- Automated tests with mocked provider responses; sandbox test only after explicit approval.

### Slice D — Multi-provider routing
- Capability-based routing, explicit fallback, cost comparison, approval gates.
- Enable only for production-eligible providers.

## 10. Release gates

No provider API is activated and no production migration is executed by this architecture document. Before code or schema rollout:
- Review current tenant-integrity PR and avoid overlapping schema changes.
- Agree on schema ownership and tenant composite constraints.
- Add migration files only in a dedicated PR, with preflight and tests.
- Keep Neon compute and migrations untouched until separately authorized.
- Keep Vercel production unchanged until commercial hosting and deployment gates are met.
