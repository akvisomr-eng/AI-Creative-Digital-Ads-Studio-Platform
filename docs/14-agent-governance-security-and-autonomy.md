# 14 — Agent Governance, Security and Autonomy Controls

**Status:** Mandatory design controls for any agent implementation.

## 1. Autonomy levels

| Level | Name | Permitted behavior |
|---|---|---|
| L0 | Observe | Read authorized context, classify, summarize and recommend |
| L1 | Prepare | Draft brief, quote, prompt, storyboard and tasks; no external side effect |
| L2 | Execute sandbox | Run mock/sandbox generation with strict test budgets and non-customer data |
| L3 | Bounded production | Execute approved low-risk production tasks inside accepted order, provider, budget and rights limits |
| L4 | Supervised completion | Prepare delivery, notifications and closeout; authorized human confirms final release |
| L5 | Prohibited unrestricted autonomy | No unrestricted spending, payment/refund, legal commitment, public publishing or self-granted permissions |

Autonomy is configured per tenant, service, agent, action, risk class and budget. A single global "autonomous" switch is insufficient.

## 2. Approval matrix

Require authorized human approval for:
- Quote outside catalog or below minimum margin.
- Discounts above threshold and non-standard payment terms.
- Any paid provider use without a known estimate or beyond order cap.
- Provider with unverified commercial rights, privacy terms or API permissions.
- Use of real-person likeness/voice, synthetic endorsement, or customer identity data.
- Regulated/sensitive advertising claims and restricted product categories.
- Public posting, ad account spend, external campaign launch or mass communication.
- Refunds, payouts, bank transfers, tax/legal filing, contract signature or policy exceptions.
- Final delivery where the contract or risk policy requires human QC.

Approval records include requested action, exact payload/version, cost/impact, approver, decision, timestamp, expiry and reason. Approval applies only to the approved payload; material changes require a new approval.

## 3. Least privilege and tool policy

- Each agent has an explicit tool allowlist and permission scope.
- Read-only agents cannot mutate orders or financial data.
- Finance agent can prepare quote/cost proposals but cannot settle payments or issue refunds.
- Delivery agent can package approved assets but cannot approve its own QC.
- Orchestrator can dispatch tasks but cannot override RBAC or compliance policy.
- Provider adapters can submit only approved jobs and cannot access unrelated tenant files.
- Tools validate tenant_id, actor, order scope, state transition, budget and idempotency server-side.

Do not expose raw SQL, arbitrary shell, unrestricted HTTP, secret-store reads, or general-purpose admin tools to LLM agents.

## 4. Prompt injection and untrusted input

Customer briefs, documents, images, metadata, URLs, transcripts, provider responses and generated content are untrusted data, never system instructions.

- Keep system/developer policy separate from retrieved content.
- Treat embedded instructions in customer files and web pages as data.
- Allowlist domains and fetch methods; block private-network/metadata endpoints and unsafe redirects.
- Scan and validate files; do not execute uploaded content.
- Use structured extraction and schema validation.
- Require human review before external side effects when untrusted content could influence money, permissions, publication, or data disclosure.
- Do not send secrets, unrelated tenant records, or hidden instructions to providers.

## 5. Data privacy and retention

- Minimize data sent to LLMs and generation providers.
- Classify content: public, internal, customer-confidential, personal/sensitive, restricted.
- Obtain required consent for likeness, voice, personal data, and source media.
- Store uploaded and generated assets privately with tenant-scoped access.
- Apply retention, deletion, export and legal-hold policy.
- Redact credentials, tokens, signed URLs and sensitive prompt content from logs.
- Do not use customer assets to train or improve shared models unless explicit, separate consent and provider terms allow it.
- Record provider privacy/retention evidence before production use.

## 6. Cost, quota and spend guardrails

Before any paid generation:
- Verify order budget and remaining approved balance.
- Estimate operation cost from current provider price record.
- Reserve internal customer credits/budget atomically.
- Enforce per-task, per-order, per-tenant, per-provider and daily/monthly caps.
- Limit fan-out, concurrency, retries and maximum duration.
- Stop on unexpected price/credit change and request approval.
- Reconcile actual provider usage before final cost allocation.

Do not equate provider credits to platform customer credits. Track subscription expense, included provider credits, actual usage and customer entitlements separately. Unknown cost is not zero cost.

## 7. Audit and observability

Record:
- Agent name/version, model, instruction version and evaluation version.
- Input/output schema versions and authorized context references.
- Tool calls, permission decisions and redacted arguments.
- Workflow/task/attempt IDs and correlation IDs.
- Token, provider-credit, duration and cost metrics where available.
- Approval and policy decisions.
- State transitions, retry, fallback, pause and recovery reasons.

Metrics:
- Classification accuracy and confidence.
- Prompt acceptance and success rate.
- First-pass QC pass rate.
- Revision count and root causes.
- Cost per deliverable and gross margin.
- Provider failure/latency/rate-limit and effective cost.
- On-time delivery and customer satisfaction.
- Agent exception/escalation rate.

Provide kill switches at platform, tenant, provider, agent and workflow level. A kill switch stops new work and safely pauses queued work; it must not corrupt already-posted financial records.

## 8. Human override and appeal

Authorized operators can pause, resume, reassign, reject, cancel or manually complete tasks with a reason. Overrides are audited and cannot rewrite historical events. Customers can request clarification, correction, revision or dispute through the portal.

## 9. Evaluation before autonomy expansion

Maintain deterministic test cases for:
- Correct order classification.
- Missing-input detection.
- Unsupported claim and likeness/voice consent.
- Tenant boundary and authorization.
- Prompt schema and provider compatibility.
- Budget exceeded and unknown cost.
- Duplicate webhook/submission and retry idempotency.
- Provider outage and recovery.
- QC hard failures and revision limits.
- Correct delivery access and expiry.

Increase autonomy only after passing quality, security, cost and legal gates for the relevant service category. Roll out by feature flag and tenant cohort, with rollback and incident playbooks.
