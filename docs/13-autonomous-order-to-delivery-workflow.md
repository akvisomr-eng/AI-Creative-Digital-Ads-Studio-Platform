# 13 — Autonomous Order-to-Delivery Workflow

**Status:** Product workflow specification proposal.

## 1. End-to-end stages

| Stage | Owner | Exit condition |
|---|---|---|
| Lead/intake | Customer / Order Intelligence | Submission stored and acknowledged |
| Triage | Order Intelligence | Category, complexity, risk and confidence recorded |
| Clarification | Brief Analyst | Required facts answered or approved assumptions recorded |
| Scope/creative plan | Creative Strategist | Deliverables, concept and dependencies defined |
| Quote/HPP | Finance Agent + pricing rules | Versioned quote and margin check ready |
| Customer acceptance | Customer / Sales | Scope, price and terms accepted |
| Payment gate | Finance / payment verification | Required payment condition verified |
| Pre-production | Orchestrator + specialists | Brief, source media, rights and plan ready |
| Production | Production agents/workers | Required assets generated/edited |
| QC | QC Agent + human when required | All mandatory checks pass |
| Revision | Revision Agent / customer | Included revision allowance or approved change order |
| Final approval | Customer / authorized reviewer | Deliverables accepted |
| Delivery | Delivery Agent | Secure bundle and delivery evidence created |
| Closeout | Finance / operations | Actual HPP, invoice status, license and archive reconciled |

## 2. Order state model

Use explicit server-validated transitions:
- draft
- submitted
- triage
- needs_customer_input
- scope_review
- quote_pending
- quoted
- awaiting_acceptance
- awaiting_payment
- ready_for_production
- in_preproduction
- in_production
- internal_qc
- revision_in_progress
- awaiting_customer_approval
- approved_for_delivery
- delivered
- closed
- cancelled
- on_hold
- exception

Payment, production, customer approval, and delivery should be separate state dimensions where possible. An order can be in production while a later milestone invoice is pending; do not overload one status field with unrelated facts.

## 3. Production job/task state model

- planned
- blocked
- queued
- claimed
- running
- awaiting_provider
- succeeded
- qc_failed
- revision_required
- retry_wait
- needs_approval
- needs_input
- cancelled
- failed_terminal

Every transition stores actor/agent, reason, timestamp, workflow/task correlation ID and relevant evidence.

## 4. Quote and cost workflow

Estimate:
- Provider operation cost and credit consumption.
- Human creative/editing/QC labor.
- Storage, transfer, music/stock/license and external services.
- Overhead allocation and contingency.
- Included revision allowance.
- Tax/discount only from configured, effective-dated rules.

Show estimate confidence and unknown components. Do not quote a guaranteed fixed price when material costs or rights are unknown; route to custom quote. Final HPP uses actual provider records/invoices and actual labor/expense evidence, not estimates alone.

Pricing policy must define minimum gross margin, approval threshold for discounts, customer-specific price list, reseller/agency rates, deposit, cancellation and extra-revision fees.

## 5. Parallel production example: 15-second UGC product ad

After scope/payment/rights gates:
1. Parallel: product/reference analysis; campaign angle; brand-kit retrieval; claim verification against customer-supplied source; provider capability check.
2. Join: produce script, hook, CTA and scene plan.
3. Customer approval if contract requires creative-direction approval.
4. Parallel: scene prompts; voice script; subtitle; sound design; vertical end-card design.
5. Generate scene clips in parallel if provider and continuity constraints permit.
6. Join: select approved takes, assemble/edit, mix audio, render subtitles and end card.
7. Run technical and creative QC.
8. Revision loop only for identified defects or customer feedback within agreed scope.
9. Final human review for synthetic likeness, claims, brand accuracy and contract-required checks.
10. Package, checksum, license metadata and deliver.

## 6. Quality control layers

### Technical
- File opens and decodes.
- Correct file type, dimensions, aspect ratio, duration and audio channel.
- Export is complete; no corrupt/truncated file.
- No unexpected watermark where a watermark-free deliverable was sold.
- Subtitle timing and audio/video synchronization.
- No missing scene, blank frame, clipped text or broken link.

### Brief and brand
- Correct product, packaging, logo and brand colors.
- Required message, offer, CTA, language and platform format.
- No unauthorized change to product labels or material facts.
- Visual consistency across scenes and variants.

### Advertising and rights
- Claims trace to customer-approved sources.
- No fabricated testimonials or implied real endorsement.
- Likeness/voice consent recorded.
- Music, stock, font, image and model licenses support the intended usage.
- Required synthetic-content disclosure is handled according to applicable law, platform policy and contract.

### Scoring and decisions
QC returns pass, pass_with_warning, revise, or human_review. Numeric scores alone never override mandatory hard failures.

## 7. Revision policy

Separate:
- Internal rework caused by provider/agent defect (not counted against customer allowance).
- Included customer revisions within the agreed scope.
- Out-of-scope change request requiring new quote, timeline and approval.

Each revision has request source, category, annotated asset/timecode, requested change, included allowance count, cost/time impact, approval and resulting version. Never overwrite delivered or approved assets.

Limit automatic revision loops by attempts, time and budget. When the same defect repeats or the request conflicts with approved scope, pause and escalate.

## 8. Delivery package

Create a tenant-private delivery manifest containing:
- Order and deliverable IDs.
- Final asset names, file types, sizes, dimensions/duration and checksums.
- Version and approval record.
- Preview/thumbnail references.
- Usage/license note and known restrictions.
- Included editable/source files if contracted.
- Caption, script, prompt or posting copy when included.
- Download expiry/access policy.
- Delivery timestamp, recipient, notification event and acknowledgement.

Delivery links must be authorized, short-lived or revocable, and must not expose storage bucket paths. Keep internal drafts and provider raw outputs private unless contract permits their release.

## 9. Closeout and post-delivery

- Record proof of delivery and customer acknowledgement where required.
- Reconcile provider usage, failed-job charges and internal credit movements.
- Calculate actual HPP, gross profit and margin per order/deliverable.
- Issue final invoice/receipt or mark manual settlement only with evidence.
- Archive source, prompt, outputs, approvals and license snapshots under retention policy.
- Request feedback and record satisfaction.
- Offer repeat package/subscription only with customer consent.
- Close order only when required financial, delivery and compliance checks pass.

## 10. Exception handling

Pause and route to an authorized operator when:
- Payment verification is unavailable or disputed.
- Provider is down, out of credits, or charges differ from estimate.
- Rights or likeness consent is missing.
- Customer brief is contradictory or changes scope.
- Margin falls below configured threshold.
- QC repeats the same failure.
- Deadline cannot be met.
- Asset is corrupt or security scan fails.
- Customer disputes delivery or requests refund.

No silent failure, silent substitution, unapproved spend, or automatic order closure.
