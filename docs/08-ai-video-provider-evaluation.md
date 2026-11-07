# AI Video Provider Evaluation — Discovery Baseline

**Reviewed:** 2026-11-07  
**Scope:** 10 candidate tools discovered through the AITopTools free Video Generator directory and cross-checked against provider pages where available.  
**Decision status:** Research only. No provider is approved for production integration by this document.

## Executive decision

Use AITopTools as a discovery directory, not as proof that a service is free, commercially licensed, or API-integrable. A listing marked **Free** may mean a limited free tier, a one-time trial, a watermarked export, or a free browser tool with paid API access.

The first integration candidates are **Vidnoz (API trial)** and **Vizard/Klap (paid API after business validation)**. **Vmake** is a useful editing/creative utility candidate, subject to paid API terms. The remaining tools stay in the external-tool or manual-evaluation catalog until official API, rights, and quota evidence is recorded.

## Evaluation rules

A provider may be marked production_eligible only after all of these are verified:

1. Official provider identity and current product URL.
2. Official API documentation and permitted SaaS / multi-customer use.
3. Authentication method, rate limits, concurrency, webhook/polling behavior.
4. Current free quota, reset period, watermark, storage, export resolution, and queue limits.
5. Commercial-use rights for outputs and any restrictions on client work, resale, or white-label.
6. Pricing and unit cost per successful output, including failed jobs and retries.
7. Data handling, retention, deletion, privacy, and rights for uploaded reference media.
8. A successful sandbox test and reconciliation against provider usage/invoice records.

Until verified, credentials must not be requested from customers or stored in the platform, and no provider may be represented as an integrated generation engine.

## Candidate inventory

| # | Provider / tool | Main capability | Free-tier evidence | API / integration evidence | Commercial-use status | Initial disposition |
|---:|---|---|---|---|---|---|
| 1 | Vidnoz AI | Avatar presenter, text-to-video, voice, translation | Consumer free plan is advertised; plan page lists daily credits and limited features | Official Open API docs list a Free Trial tier of 30 API credits/month; usage varies by endpoint | Must verify rights by plan and API terms; do not assume free trial outputs are client-commercial | **API sandbox candidate** |
| 2 | Vizard AI | Long-video clipping, captions, reframing, social clips | Free plan lists 60 credits/month, 720p export, 3-day storage, watermark | Official API is included in paid Creator/Business plans; uploads consume plan minutes | Free exports are watermarked; confirm commercial rights on paid plan | **Paid API candidate** |
| 3 | Klap | Podcast/video repurposing into short clips | Directory lists free access; current account quota needs direct verification | Official API docs publish usage pricing: input video, generated short, and export are billed separately; OAuth is also documented | Confirm customer-content and commercial rights in current terms | **Paid API candidate** |
| 4 | Vmake | AI video editing, background removal, enhancement, creative ads | Official pricing page lists a $0 tier with limited features, limited models, and watermark | API access is advertised on Plus/Pro with usage-based pricing | Commercial use is not established for Free; paid plan rights need confirmation | **Paid API / utility candidate** |
| 5 | Genmo | Text/image-to-video generation | Official pricing lists 250 lifetime credits after adding a payment method; free outputs carry watermark | No public production API confirmed in this review | Free plan does not include commercial usage; paid Lite/Standard list commercial usage | **External trial only** |
| 6 | WOXO VidGPT | Script-to-video / faceless social video automation | Official pricing says Free is script mode only (image prompts and voice-over); full slideshow/download features are paid | No public API verified in this review; Zapier appears on paid Starter | Free plan is a testing tier, not an approved commercial delivery route | **External trial only** |
| 7 | Seedance 3.0 | Generative video from text and references | AITopTools listing labels it Free; quota and official free plan not independently confirmed | Official first-party API access and SaaS redistribution rights not verified; third-party API listings are not equivalent to vendor authorization | Unverified | **Research only** |
| 8 | Pexo | Prompt-led AI video creation / agent workflow | Directory listing indicates free entry; current quota and restrictions require account-level check | Public API and commercial SaaS integration not verified | Unverified | **Research only** |
| 9 | LipSync.video | Talking portrait / lip-sync video | Directory listing indicates free access; quota, export, and watermark need testing | Public API not verified | Unverified | **External tool candidate** |
| 10 | Video Background Remover | Video background removal | Directory listing indicates free access; export limits and watermark need testing | Public API not verified | Unverified | **External tool candidate** |

### What the evidence means

- **Free consumer account is not the same as free API.** Vizard's API documentation says API access requires a paid plan. Klap's API is usage-billed. Vmake lists API access on paid tiers.
- **Free API trial is not unlimited.** Vidnoz's API documentation lists 30 trial credits/month; a video-generation minute consumes credits, and other endpoints have different costs.
- **Free output is not automatically commercially usable.** Genmo explicitly separates free watermarked usage from paid commercial-use plans. Other providers require review of their current terms.
- **Directory claims are discovery hints.** Recheck the vendor's official pricing and terms before any integration or customer delivery.

## Suggested pilot order

1. **Vidnoz API sandbox** — verify a small avatar/TTS workflow using the published free API trial. Do not use customer data.
2. **Vizard** — test free web workflow for internal evaluation; separately price the paid API for podcast-to-shorts.
3. **Klap** — compare API unit economics against Vizard for the same source video and number of exported shorts.
4. **Vmake** — test editing/enhancement utility and establish paid API cost per successful asset.
5. **Genmo / WOXO** — test creative quality and export restrictions in browser; do not automate without approved API.
6. **Seedance / Pexo / LipSync.video / Background Remover** — obtain official API and licensing answers before deeper work.

## Provider status vocabulary

- discovered: found in a directory or vendor catalog.
- researching: current features, limits, or legal terms are being checked.
- external_only: usable only by a person through the vendor's own interface; no platform API integration approved.
- sandbox_eligible: official API exists and limited test credentials may be used after internal approval.
- commercial_review: API and rights evidence exists but commercial/legal review remains.
- production_eligible: all integration, cost, security, and rights gates pass.
- suspended: provider is unavailable, unsafe, non-compliant, or no longer economical.

## Source register

### Discovery directory
- AITopTools Free Video Generator directory: https://aitoptools.com/ai-tools/?pricing=Free&category=video-generator

### Official provider evidence
- Vidnoz pricing: https://www.vidnoz.com/pricing.html
- Vidnoz Open API limits: https://www.vidnoz.com/overview/limits.html
- Vizard pricing: https://vizard.ai/pricing
- Vizard API pricing: https://docs.vizard.ai/docs/pricing
- Vizard API quickstart: https://docs.vizard.ai/docs/quickstart
- Klap API documentation and usage pricing: https://docs.klap.app/
- Vmake pricing: https://vmake.ai/pricing
- Genmo pricing: https://www.genmo.ai/pricing
- WOXO plans: https://dev.woxo.tech/plans
- Seedance discovery listing: https://aitoptools.com/tool/seedance-3-0-4/
- Pexo: https://pexo.ai/
- LipSync.video: https://lipsync.video/

**Revalidation:** pricing, free credits, model availability, and licensing can change. Recheck before quoting customers or committing to a provider.
