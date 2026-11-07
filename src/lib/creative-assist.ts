export type CreativeInput = {
  serviceType: string;
  product: string;
  audience: string;
  platform: string;
  objective: string;
  tone: string;
  details: string;
  language: string;
};

const serviceCatalog = [
  { key: "video_ads", label: "Video Ads", terms: ["video", "iklan", "ads", "reels", "tiktok", "youtube", "shorts"] },
  { key: "ugc_ads", label: "UGC Ads", terms: ["ugc", "review", "testimoni", "creator", "unboxing"] },
  { key: "product_photo", label: "Foto Produk AI", terms: ["foto produk", "product photo", "packshot", "katalog produk"] },
  { key: "poster", label: "Poster Promosi", terms: ["poster", "banner", "flyer", "feed", "desain grafis"] },
  { key: "ai_influencer", label: "AI Influencer", terms: ["influencer", "avatar", "virtual human", "host virtual"] },
  { key: "fashion", label: "Fashion Model AI", terms: ["fashion", "model", "busana", "outfit", "lookbook"] },
  { key: "mockup", label: "Mockup Merchandise", terms: ["mockup", "merchandise", "kaos", "mug", "kemasan"] },
  { key: "marketing_package", label: "Paket Marketing UMKM", terms: ["paket marketing", "campaign", "kampanye", "konten bulanan"] },
] as const;

const clean = (value: unknown, max = 1200) =>
  typeof value === "string" ? value.trim().replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, "").slice(0, max) : "";

export function analyzeOrder(raw: unknown) {
  const brief = clean(raw, 6000);
  if (brief.length < 12) throw new Error("Brief minimal 12 karakter agar dapat dianalisis.");
  const normalized = brief.toLocaleLowerCase("id-ID");
  const ranked = serviceCatalog.map((service) => ({
    ...service,
    score: service.terms.reduce((score, term) => score + (normalized.includes(term) ? 1 : 0), 0),
  })).sort((a, b) => b.score - a.score);
  const best = ranked[0];
  const selected = best.score > 0 ? best : null;
  const riskFlags: string[] = [];
  if (/selebrit|artis|influencer|wajah|foto orang|suara orang|mirip/i.test(brief)) riskFlags.push("Periksa izin penggunaan wajah, identitas, atau suara orang nyata.");
  if (/medis|obat|suplemen|menyembuhkan|investasi|pinjaman|hasil pasti/i.test(brief)) riskFlags.push("Klaim sensitif perlu pemeriksaan bukti dan persetujuan manusia.");
  if (/politik|pemilu|kampanye kandidat/i.test(brief)) riskFlags.push("Konten politik memerlukan peninjauan kebijakan dan persetujuan khusus.");
  if (/jamin|pasti berhasil|100%|nomor satu|terbaik di indonesia/i.test(brief)) riskFlags.push("Validasi klaim absolut sebelum materi iklan diproduksi.");

  const questions: string[] = [];
  if (!/rp\s?\d|harga|diskon|promo|gratis|hemat/i.test(brief)) questions.push("Apakah ada harga, promo, atau penawaran yang wajib ditampilkan?");
  if (!/target|audien|usia|wanita|pria|umkm|mahasiswa|orang tua/i.test(brief)) questions.push("Siapa target audiens utama?");
  if (!/instagram|tiktok|youtube|facebook|marketplace|website/i.test(brief)) questions.push("Materi akan dipublikasikan di platform mana?");
  if (!/detik|seconds|menit|rasio|9:16|16:9|1:1/i.test(brief)) questions.push("Berapa durasi dan rasio/aspek visual yang dibutuhkan?");
  if (!/logo|brand|merek|warna|font/i.test(brief)) questions.push("Apakah tersedia logo, panduan brand, atau referensi visual?");

  return {
    classification: selected ? { key: selected.key, label: selected.label, confidence: Math.min(0.98, 0.55 + selected.score * 0.12) } : { key: "custom", label: "Pesanan Kreatif Kustom", confidence: 0.35 },
    alternatives: ranked.filter((item) => item.score > 0 && item.key !== selected?.key).slice(0, 3).map(({ key, label, score }) => ({ key, label, score })),
    summary: brief.length > 240 ? brief.slice(0, 237) + "..." : brief,
    questions,
    riskFlags,
    recommendedNextStep: riskFlags.length ? "human_review" : questions.length ? "clarification" : "prepare_quote",
    autonomy: riskFlags.length ? "L1_human_review_required" : "L1_prepare_only",
    notice: "Analisis berbasis aturan lokal; bukan keputusan harga, verifikasi hak cipta, atau persetujuan produksi.",
  };
}

export function generateCreativePrompt(input: CreativeInput) {
  const serviceType = clean(input.serviceType, 40) || "video_ads";
  const service = serviceCatalog.find((item) => item.key === serviceType)?.label ?? "Konten Kreatif";
  const product = clean(input.product, 240);
  const audience = clean(input.audience, 240) || "calon pelanggan yang relevan";
  const platform = clean(input.platform, 80) || "Instagram Reels dan TikTok";
  const objective = clean(input.objective, 240) || "meningkatkan minat dan kunjungan";
  const tone = clean(input.tone, 120) || "modern, terpercaya, persuasif";
  const details = clean(input.details, 1200);
  const language = clean(input.language, 40) || "Bahasa Indonesia";
  if (product.length < 2) throw new Error("Nama produk atau layanan wajib diisi.");
  const base = `Create a premium ${service} campaign for ${product}. Target audience: ${audience}. Marketing objective: ${objective}. Platform: ${platform}. Creative tone: ${tone}. Language for visible copy and voice-over: ${language}. ${details ? `Verified product details: ${details}.` : ""} Preserve the exact product identity, packaging, proportions, logo and supplied reference assets. Use realistic materials, professional lighting, intentional composition, clear visual hierarchy and a strong first-second hook. Do not invent product features, prices, certifications, endorsements or performance claims. Keep text legible and reserve safe margins for platform UI. Deliver a coherent, commercially usable advertising concept subject to rights and human review.`;
  const imagePrompt = `${base} Still-image direction: hero product composition, deliberate focal point, clean background, natural contact shadows, balanced negative space, accurate color and premium commercial photography.`;
  const videoPrompt = `${base} Video direction: vertical 9:16 master, 15 seconds, 24 or 30 fps. 0-2s: visual hook; 2-6s: product and core benefit supported by supplied facts; 6-11s: use-case or demonstration; 11-15s: offer context and clear CTA. Use stable product continuity, purposeful camera movement, clean transitions, readable subtitles and a clear audio mix. Generate scenes as separate shots for review before assembly.`;
  return {
    service: { key: serviceType, label: service },
    imagePrompt,
    videoPrompt,
    negativePrompt: "Do not alter product shape, packaging, logo, label, brand colors or proportions. No fabricated claims, fake testimonials, unauthorized celebrity likeness, distorted hands, malformed text, watermark, extra products, misleading before-after results, unsafe demonstrations or cluttered composition.",
    storyboard: [
      { time: "00-02s", scene: "Hook visual yang langsung menarik perhatian; tampilkan produk secara jelas." },
      { time: "02-06s", scene: "Perkenalkan produk dan satu manfaat yang dapat dibuktikan." },
      { time: "06-11s", scene: "Tunjukkan konteks penggunaan atau detail produk." },
      { time: "11-15s", scene: "Tampilkan penawaran yang telah diverifikasi dan CTA." },
    ],
    suggestedCTA: "Pelajari selengkapnya dan hubungi kami untuk informasi produk.",
    productionNotes: ["Gunakan foto produk dan logo resmi sebagai reference input.", "Verifikasi seluruh harga, promo, klaim, dan hak penggunaan aset.", "Prompt ini merupakan draft; belum mengirim permintaan ke provider AI."],
    engine: "local-template-v1",
    externalProviderUsed: false,
  };
}
