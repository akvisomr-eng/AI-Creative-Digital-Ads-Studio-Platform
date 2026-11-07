# 11 — Order Intelligence, Intake and Service Taxonomy

**Status:** Product specification proposal.  
**Default locale:** Indonesian (id-ID), currency IDR, timezone Asia/Jakarta.

## 1. Intake channels

Accept orders and enquiries from:
- Customer portal form.
- Public service/product page.
- Operator-created order from WhatsApp, email, phone, or offline meeting.
- Reseller/agency portal.
- Approved API/webhook integrations.
- File upload: text/PDF/DOCX/XLSX/images/video/audio/reference links, subject to safe parsing and upload limits.

A channel is a source attribution, not proof of identity or payment. Record consent, communication preference, and the actor who submitted or transcribed the request.

## 2. Service taxonomy

### A. Video and motion
- Product video ads.
- UGC-style ads and creator-style product demos.
- Brand/company profile and cinematic commercial.
- Social short-form: TikTok, Reels, Shorts.
- Podcast-to-shorts and long-video repurposing.
- Explainer, tutorial, education and training video.
- Event highlight, invitation and recap.
- Motion graphics, animated poster and logo animation.
- Video editing, trimming, enhancement, subtitle and format adaptation.

### B. Image and design
- Product photography and lifestyle scenes.
- E-commerce catalog and marketplace images.
- Fashion model, lookbook and virtual try-on (subject to provider capability and rights).
- AI influencer/avatar stills.
- Promotional poster, flyer, banner, brochure and social carousel.
- Merchandise mockup and packaging visualization.
- Background removal, retouch, upscale and image restoration.
- Logo/brand asset concepts (final trademark/legal clearance is human-reviewed).

### C. Audio and language
- Voice-over and narration.
- Dubbing, translation and localization.
- Subtitle/caption generation.
- Original music/sound design where rights are clear.
- Audio cleanup and podcast editing.
- Lip-sync and avatar speech (with likeness/voice consent).

### D. Marketing and campaign
- Ad concept, creative strategy and campaign kit.
- Ad copy, hook, CTA, caption and landing-page copy.
- Multi-format campaign variants.
- Monthly UMKM marketing package.
- Brand storytelling and launch campaign.
- Creative testing variants (platform publication remains separately approved).

### E. Custom
- Multi-service campaigns.
- Custom creative briefs.
- Services outside the catalog, routed to manual scope review.

Each category has service_code, output specification, required inputs, optional inputs, standard turnaround, revision policy, default QC checklist, licensing requirements, and pricing/HPP rule version.

## 3. Intake extraction schema

The analyzer should produce a validated structured brief with:
- request_summary.
- customer_goal and business_context.
- service_category and service_subcategory.
- requested_deliverables[] with quantity, file_type, aspect_ratio, resolution, duration_seconds, language, platform, and version_count.
- product_or_brand details and product claims supplied by customer.
- target_audience, geography, offer, CTA, campaign objective.
- style references and forbidden styles.
- brand assets: logo, colors, fonts, packaging, product photos, brand guide.
- subject/character requirements and consent evidence.
- voice, accent, language, music and subtitle requirements.
- source media and reference links.
- intended usage: organic, paid ads, internal, broadcast, print, resale, white-label.
- rights declarations and missing rights.
- deadline, priority, delivery channel.
- budget range and payment terms.
- customer approvals and open questions.
- confidence per extracted field, source attachment/page/timecode, and ambiguity flags.

Do not fabricate missing details. Unknown values are null with a reason and confidence; do not turn an inference into a customer-confirmed fact.

## 4. Classification outputs

Return:
- Primary category and subcategory.
- Secondary categories for multi-deliverable work.
- Complexity: simple, standard, advanced, custom.
- Production mode: manual, AI-assisted, API-automated, hybrid, external-tool.
- Required agents and task dependencies.
- Required provider capabilities, not a vendor name initially.
- Estimated human minutes and AI operations.
- Risk tier: low, medium, high, restricted.
- Missing inputs/questions.
- Quote readiness and production readiness separately.
- Recommended service SKU or custom quote flag.

Classification confidence below a configurable threshold triggers a human review or customer clarification. Multi-service requests become one parent order with child production jobs and shared campaign/brand context.

## 5. Risk detection

Flag:
- Unsupported product performance/health/financial claims.
- Deceptive testimonial, fake review, undisclosed synthetic influencer, fabricated endorsement.
- Real-person likeness or voice without documented permission.
- Copyrighted characters, brands, music, footage, or style imitation concerns.
- Sensitive personal data, children, or biometric/identity material.
- Regulated or restricted products and services.
- Political persuasion or sensitive targeting.
- Missing commercial rights, unclear ownership, or provider terms that prohibit the intended use.
- Customer requests to impersonate a person or misrepresent an AI-generated endorsement.

Risk flags do not automatically accuse a customer. They route the order to clarification, rejection, or human compliance review according to policy.

## 6. Clarification engine

Ask only material questions needed to quote or produce:
- Required deliverable and quantity.
- Product/service facts and approved claims.
- Target audience and platform.
- Required dimensions/duration/language.
- Brand asset or product reference.
- Usage rights and consent.
- Budget and deadline if missing and material.

Group related questions in one concise customer message. Preserve answers and revision history. Do not repeatedly ask for information already present in the order or uploaded files.

## 7. Quote readiness vs production readiness

Quote-ready requires enough information to define scope, deliverables, estimated cost range, timeline and terms.

Production-ready additionally requires:
- Accepted scope and price.
- Required deposit/payment condition verified.
- Complete source materials and approved claims.
- Required consent/license evidence.
- Customer approval of creative direction if specified.
- Available capacity/provider route and budget.

Never start billable provider generation simply because the intake parser classified the request.

## 8. Acceptance criteria

- At least 95% of supported test briefs map to a valid taxonomy category or explicit custom/manual state.
- Every extracted field has provenance/confidence or is marked unknown.
- Multi-deliverable orders create parent-child work plans without duplicating customer/payment records.
- Low-confidence or risk-flagged requests route to clarification/review.
- No customer-facing price or delivery date is presented as final unless a versioned price/SLA rule supports it.
- All intake attachments are tenant-private and malware/type validated before processing.
