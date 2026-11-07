# 10 — Autonomous Multi-Agent Production Architecture

**Status:** Product architecture proposal; implementation is staged behind the existing foundation and tenant-integrity release gates.  
**Architecture baseline:** Next.js modular monolith + Neon PostgreSQL + server-side domain services.  
**Operating model:** One orchestrator, specialist agents, durable jobs, explicit permissions, human approval at risk boundaries.

## 1. Product objective

Turn the platform into an AI Creative Business Operating System that can receive a customer request, understand and classify it, prepare a creative plan and quote, orchestrate specialist work, generate assets through approved providers, quality-check and revise outputs, and manage approval, delivery, billing evidence, cost allocation, and archival.

The platform must support:
- Human-operated work with AI assistance.
- AI-prepared work awaiting human approval.
- Bounded autonomous production after order, scope, payment, rights, and budget gates pass.
- Manual/external-provider workflows where no approved API exists.
- Parallel production tasks where dependencies permit.
- Resumable execution after worker, provider, or deployment failure.

"Autonomous" never means unrestricted. Each agent acts only within a tenant, order, task, tool, budget, and permission envelope.

## 2. Architecture decision

Retain the existing Next.js/TypeScript modular monolith and PostgreSQL domain model. Do not introduce a separate microservice fleet or a second agent framework during the foundation stage. The repository already uses Next.js, Drizzle, Better Auth, and Neon, and its ADR-001 explicitly selects a modular monolith.

Implement orchestration as server-side domain services plus durable database-backed workflow/job records and worker execution. Use an outbox/claim/lease pattern with idempotent handlers. A managed queue or durable agent framework can be evaluated later when measured workload, execution duration, and operational requirements justify it. Do not add a framework solely because it is fashionable.

Long-running video/image generation must never depend on a browser request remaining open. API routes create or inspect jobs; workers execute jobs asynchronously and persist state.

## 3. Logical architecture

1. **Experience layer:** public catalog, customer portal, reseller/agency portal, operator workspace, admin workspace.
2. **Order intelligence layer:** intake parser, attachment analyzer, taxonomy classifier, missing-information detector, risk detector.
3. **Orchestration layer:** master orchestrator, workflow planner, dependency graph, queue dispatcher, scheduler, retry/recovery manager.
4. **Agent layer:** specialist agents with versioned instructions, typed input/output schemas, tool allowlists, budgets, and evaluation suites.
5. **Creative layer:** prompt studio, brief, copy, script, storyboard, shot list, brand kit, creative variants.
6. **Provider layer:** provider/model catalog, capability registry, adapter contract, routing, credential references, health and cost.
7. **Production layer:** generation jobs, editing tasks, asset versions, QC, revisions, approvals, delivery package.
8. **Business layer:** quote, order, payment evidence, subscription/entitlements, HPP, invoice, usage ledger, margin.
9. **Control plane:** RBAC, tenant isolation, consent, policy, audit, observability, feature flags, human approvals.

## 4. Agent roster and responsibilities

| Agent | Primary responsibility | Allowed output |
|---|---|---|
| Master Orchestrator | Plan, dispatch, monitor, resume and close workflow | Task graph and state transitions |
| Order Intelligence | Extract intent and classify order | Structured order interpretation |
| Brief Analyst | Detect missing facts and normalize brief | Approved production brief or questions |
| Creative Strategist | Propose concept, angle and creative direction | Concept options with rationale |
| Marketing Strategist | Audience, channel, offer, hook and CTA | Campaign strategy |
| Copywriter | Headlines, captions, ad copy and scripts | Versioned copy assets |
| Prompt Engineer | Provider-specific prompts and negative constraints | Prompt versions and prompt tests |
| Image Production | Create/edit still images | Image generation jobs/assets |
| Video Production | Scene-based video and editing plan | Video jobs/assets |
| UGC Production | UGC-style scripts, shot plan, creator direction | UGC plan/assets |
| Avatar & Fashion | Avatar/model/fashion workflows | Character/model specs and assets |
| Audio Production | Voice, dubbing, music and subtitles | Audio jobs/assets |
| Design Production | Poster, banner, layout and merchandise mockup | Design assets |
| Provider Selection | Capability, rights, cost and health routing | Eligible provider shortlist |
| Quality Control | Evaluate output against brief and service checklist | Score, findings and pass/fail |
| Revision | Turn QC/customer feedback into bounded changes | Revision plan and new task graph |
| Finance | Quote support, cost estimate, actual HPP and margin | Cost proposal/ledger instructions |
| Delivery | Package, checksum, license metadata and delivery manifest | Delivery bundle and proof |

Agents are logical roles, not necessarily 18 separately deployed processes or 18 different models. The orchestrator may run several roles using one model with separate instructions and tool permissions. Use the smallest model/tool combination that meets quality and risk requirements.

## 5. Agent execution contract

Every agent invocation must receive:
- tenant_id, actor_id, order_id, workflow_id, task_id, correlation_id.
- Minimal authorized context; no unrelated customer records.
- Versioned role instructions and structured input schema.
- Allowed tools and permission scope.
- Maximum model/token/tool budget and deadline.
- Data classification and provider-sharing policy.
- Expected JSON/schema output and validation rules.

Every invocation returns:
- status: completed, needs_input, needs_approval, retryable_failure, terminal_failure.
- schema-validated output.
- evidence/source references for material claims.
- tool-call and token/credit usage summary.
- model, instruction version, timestamps and duration.
- safe error category and retry recommendation.

An agent cannot grant itself permissions, raise its own budget, mark a payment as settled, approve its own high-risk output, or bypass an order gate.

## 6. Parallel task graph

The orchestrator creates a dependency DAG rather than a fixed serial script.

Example for a 15-second product video:
- Intake analysis → brief normalization → customer clarification (if needed).
- After approved brief: parallel creative strategy, marketing angle, product/reference analysis, brand-kit retrieval.
- Join results → copy/script and storyboard.
- After storyboard approval: parallel scene prompt creation, voice script, subtitle plan, music brief.
- Provider selection → parallel scene generation where model/provider supports it.
- Join scene outputs → editing/assembly → audio mix → subtitle rendering.
- QC → bounded revision loop → approval → delivery.

Independent image variants, language adaptations, and platform crops can run concurrently. Tasks that need a stable character, product reference, approved script, or final edit must wait for their dependency.

## 7. Workflow durability and recovery

- Persist each workflow, task, dependency, attempt, lease, heartbeat, and event.
- Claim work atomically; use expiring leases so abandoned tasks can be reclaimed.
- Use idempotency keys for provider submissions, payments, webhook events, and delivery creation.
- Persist provider task IDs immediately after submission.
- Retry only transient errors with exponential backoff, jitter, maximum attempts, and budget checks.
- Do not retry policy rejection, invalid input, rights denial, or insufficient funds as if they were transient.
- Reconcile provider charge before refunding internal customer credits.
- Resume from the last durable checkpoint; never rerun completed billable tasks without explicit reason.
- Route exhausted tasks to a human exception queue with diagnostic context.

## 8. Provider routing and fallback

A provider is eligible only if it:
1. Supports requested capability, dimensions, duration, format, language, and reference mode.
2. Has verified API access for this application use case.
3. Has approved privacy/data handling for the submitted media.
4. Has verified commercial-use rights for the deliverable.
5. Is active, healthy, within rate/concurrency limits, and available in the required region.
6. Has known current price or an explicit human-approved cost cap.
7. Fits customer plan, order budget, and tenant credit rules.

Rank eligible providers by configured quality tier, estimated cost, reliability, latency, and customer preference. If no provider qualifies, pause for approval or use external-tool mode. Never silently route to a provider with unknown rights.

## 9. Data and domain boundaries

Use existing tenant-aware entities and extend them only through reviewed migrations. Proposed logical aggregates:
- Agent definitions and instruction versions.
- Agent runs and tool-call records.
- Workflow definitions, workflow runs, tasks, dependencies, events and checkpoints.
- Order intake submissions, extracted brief, clarification requests and attachments.
- Creative plans, prompt templates, prompt versions, prompt evaluations.
- Generation jobs, provider attempts, output assets and asset versions.
- QC evaluations, findings, revision requests and approvals.
- Delivery manifests and delivery acknowledgements.
- Cost estimates, provider usage evidence and order-level cost allocations.

All tenant-owned rows carry tenant_id. Cross-aggregate references must be tenant-consistent and enforced by composite foreign keys/constraints where supported. Do not put secrets or unrestricted provider payloads in agent memory or public records.

## 10. Performance and concurrency

- Separate queues by workload: interactive analysis, generation, media processing, notifications, and reconciliation.
- Apply per-tenant concurrency, provider concurrency, model rate limits, and global worker limits.
- Prioritize by SLA, promised delivery time, plan entitlement, and fairness; avoid starvation.
- Use bounded fan-out and join barriers for parallel tasks.
- Store media in private object storage; pass short-lived authorized references rather than embedding binary media in prompts.
- Large media transforms run in a suitable worker/runtime, not a short-lived serverless request if runtime limits make that unsafe.

## 11. Human oversight

Human approval is mandatory for:
- Ambiguous scope, missing rights, unclear product claims or unsupported promises.
- Non-standard pricing, discount beyond threshold, negative/low margin, or unapproved provider spend.
- Use of a real person's likeness/voice without documented permission.
- Sensitive, regulated, political, medical, financial, or otherwise high-risk advertising claims.
- Publication to external channels, public release, contract acceptance, refunds, payouts, or legal terms.
- Final delivery when the package or service requires human QC.

Low-risk internal drafts may be auto-generated and auto-QC'd within configured budgets. Customers must always be able to review and approve deliverables before the order is closed when the contract requires approval.

## 12. Non-goals

- Training proprietary foundation image/video models in the first release.
- Scraping private provider APIs or automating vendor browser accounts contrary to terms.
- Fully autonomous bank transfers, refunds, tax filings, contract signatures, or ad publication.
- Treating an LLM judgment as proof of payment, license, factual truth, or technical file integrity.

## 13. Release strategy

A: documentation and workflow simulation.  
B: manual order intake, classification and prompt generation with persisted versions.  
C: human-supervised workflow/task engine with mock provider adapters.  
D: first approved provider adapter in sandbox, with cost and rights checks.  
E: limited production automation for one service family.  
F: multi-agent parallel execution, revision and delivery automation.  
G: multi-provider routing, agency/reseller scale and advanced autonomy.

No production migration or external provider activation is authorized by this architecture document.
