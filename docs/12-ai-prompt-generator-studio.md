# 12 — AI Prompt Generator Studio

**Status:** Product specification proposal.  
**Purpose:** Make prompt creation a first-class product capability for customers and internal creative teams.

## 1. Prompt Studio modes

- Image prompt: product photography, lifestyle, fashion, poster, mockup, avatar.
- Video prompt: text-to-video, image-to-video, reference-to-video, scene-by-scene ads.
- UGC prompt: creator brief, hook, spoken script, shot list, product demonstration and CTA.
- Avatar/fashion prompt: character sheet, wardrobe, pose, scene and consistency constraints.
- Audio prompt: voice-over, narration, dubbing, original music and sound design.
- Design prompt: poster, banner, brochure, carousel, packaging and merchandise.
- Marketing prompt: audience, campaign angle, headline, copy, offer, CTA and variants.
- Editing prompt: retouch, background replacement, clipping, subtitle, reframing and enhancement.

## 2. Input experience

Allow a user to:
- Start from a service template or blank brief.
- Describe the desired result in natural Indonesian or another supported language.
- Upload product/reference/brand files.
- Select output type, count, aspect ratio, resolution, duration, language and platform.
- Set style, mood, audience, offer, CTA and brand constraints.
- Mark fixed elements that must not change (logo, packaging, product label, face/character identity where permitted).
- Add negative constraints and prohibited content.
- Choose manual prompt editing or AI-assisted prompt generation.

## 3. Prompt compiler pipeline

1. Parse the user brief and linked order context.
2. Retrieve only authorized brand kit, product facts, and approved references.
3. Detect missing/contradictory details and ask for clarification when material.
4. Select prompt template by service and target capability.
5. Generate a provider-neutral creative specification.
6. Compile to provider/model-specific prompt syntax and parameter constraints.
7. Validate prompt length, supported parameters, prohibited content and required references.
8. Produce preview, alternatives and explanation of major creative choices.
9. Save immutable prompt version with author, model, instruction version, source brief version and provider target.
10. After generation, associate output, QC findings and prompt effectiveness metrics.

## 4. Structured prompt schema

A normalized prompt record should support:
- prompt_type and service_category.
- objective, audience, platform and message.
- subject/product identity and immutable product attributes.
- scene/environment, composition and framing.
- visual style, color palette, lighting, mood and art direction.
- camera/lens/movement where relevant.
- action and temporal sequence for video.
- character/wardrobe/voice consistency instructions.
- script, dialogue, voice style, language and pronunciation notes.
- on-screen text, subtitle, headline and CTA.
- aspect ratio, resolution, duration, frame rate if supported.
- negative_prompt and avoid_list.
- reference_asset_ids with role and weight where supported.
- provider/model target and adapter-specific parameters.
- safety/rights flags and prompt validation results.

Provider-specific fields are validated by adapters; never assume every model supports negative prompts, seed, camera controls, reference weights, lip-sync or audio generation.

## 5. Video and UGC scene builder

For video ads, generate:
- Campaign concept and single-minded message.
- Hook in first 1–3 seconds.
- Scene list with scene number, duration, visual action, product visibility, camera direction, dialogue/VO, on-screen text, transition and sound.
- Total duration validation.
- Platform-safe text areas and aspect ratio.
- CTA/end card.
- Continuity constraints for product, character, clothing, location and lighting.
- Separate generation prompt per scene if provider workflow requires it.
- Assembly/editing notes and audio/subtitle plan.

UGC must be clearly framed as a creative format. Do not fabricate a real customer's experience, review, or endorsement. If a synthetic actor/avatar is used, capture the required consent and follow applicable disclosure rules and customer/platform requirements.

## 6. Template library

Seed template families:
- 15-second product ad (9:16).
- 30-second product ad (9:16 and 16:9).
- UGC unboxing/demo.
- Problem → solution → proof supplied by customer → CTA.
- Fashion lookbook and apparel showcase.
- Product hero shot and lifestyle photo.
- Marketplace white-background product image.
- Promotional poster with editable text specification.
- Podcast-to-shorts clip selection.
- AI presenter explainer.
- Multilingual dubbing/subtitle.
- Brand launch campaign kit.

Templates are versioned, categorized, searchable, tenant-aware, and support platform-wide curated templates plus tenant-private templates. Each template includes required inputs, output schema, sample prompts, provider capability requirements and evaluation cases.

## 7. Prompt quality and evaluation

Score prompt readiness on:
- Brief coverage.
- Product/brand fidelity.
- Clarity and unambiguous scene instructions.
- Model/provider compatibility.
- Duration and composition constraints.
- Safety and rights compliance.
- Text/CTA accuracy.
- Character/product continuity.

The score is advisory, not a guarantee of image/video quality. Store test outcomes by provider/model/version so the team can compare which prompt strategy works best.

## 8. Prompt editing and version control

- Prompt versions are immutable; edits create a new version.
- Diff view highlights changed instructions.
- Allow duplicate, branch, restore-as-new-version, tag and favorite.
- Link prompts to order, campaign, creative plan, generation job and resulting assets.
- Support private drafts and customer-approved prompt snapshots.
- Never overwrite a prompt version already used for a paid generation.

## 9. Customer and operator experience

Customer mode: guided simple fields, examples, preview and approval; hide technical provider parameters unless advanced mode is enabled.

Operator mode: full structured prompt, model capability, parameter schema, cost estimate, test variations, prompt diff and QC feedback.

Admin mode: template governance, prompt instruction versions, model-specific compiler rules, evaluation datasets and access policy.

## 10. Acceptance criteria

- Every supported service category has at least one usable prompt template.
- A prompt can be generated from a text brief and from authorized uploaded references.
- The same provider-neutral specification can compile to more than one compatible provider adapter.
- Unsupported provider parameters are rejected or omitted with explanation, not silently passed.
- Prompt version, source brief, model/instruction version and generated asset are traceable.
- UGC scripts do not invent real customer testimonials or unverifiable claims.
