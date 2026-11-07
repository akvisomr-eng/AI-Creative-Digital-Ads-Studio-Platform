import test from "node:test";
import assert from "node:assert/strict";
import { analyzeOrder, generateCreativePrompt } from "../src/lib/creative-assist.ts";

test("classifies a TikTok product video brief", () => {
  const result = analyzeOrder("Buat video iklan 15 detik untuk kopi kemasan di TikTok.");
  assert.equal(result.classification.key, "video_ads");
  assert.equal(result.recommendedNextStep, "clarification");
  assert.ok(result.questions.length > 0);
});

test("flags real-person likeness and regulated advertising claims", () => {
  const result = analyzeOrder("Buat video influencer mirip artis untuk obat yang menyembuhkan semua penyakit.");
  assert.ok(result.riskFlags.length >= 2);
  assert.equal(result.recommendedNextStep, "human_review");
});

test("rejects a brief that is too short", () => {
  assert.throws(() => analyzeOrder("hi"), /minimal 12 karakter/);
});

test("generates image, video, negative prompt and storyboard without provider calls", () => {
  const result = generateCreativePrompt({
    serviceType: "video_ads", product: "Kopi Nusantara", audience: "Pekerja muda",
    platform: "TikTok", objective: "Awareness", tone: "Hangat", details: "Kopi arabika 100%",
    language: "Bahasa Indonesia",
  });
  assert.match(result.videoPrompt, /15 seconds/);
  assert.match(result.imagePrompt, /Kopi Nusantara/);
  assert.match(result.negativePrompt, /Do not alter product shape/);
  assert.equal(result.storyboard.length, 4);
  assert.equal(result.externalProviderUsed, false);
});

test("requires a product name before prompt generation", () => {
  assert.throws(() => generateCreativePrompt({ product: " ", serviceType: "video_ads" }), /wajib diisi/);
});
