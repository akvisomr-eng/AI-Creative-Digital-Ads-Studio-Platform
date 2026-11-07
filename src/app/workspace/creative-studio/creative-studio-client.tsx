"use client";

import { useState } from "react";

type Analysis = {
  classification: { key: string; label: string; confidence: number };
  alternatives: { key: string; label: string; score: number }[];
  summary: string;
  questions: string[];
  riskFlags: string[];
  recommendedNextStep: string;
  autonomy: string;
  notice: string;
};
type PromptResult = {
  service: { key: string; label: string };
  imagePrompt: string;
  videoPrompt: string;
  negativePrompt: string;
  storyboard: { time: string; scene: string }[];
  suggestedCTA: string;
  productionNotes: string[];
  engine: string;
  externalProviderUsed: boolean;
};

const fieldClass = "w-full rounded-xl border border-white/10 bg-[#0b111c] px-3 py-3 text-sm text-white outline-none focus:border-violet-400";
const panelClass = "rounded-2xl border border-white/10 bg-[#101622] p-5";

export default function CreativeStudioClient() {
  const [tab, setTab] = useState<"analyze" | "prompt">("analyze");
  const [brief, setBrief] = useState("");
  const [analysis, setAnalysis] = useState<Analysis | null>(null);
  const [serviceType, setServiceType] = useState("video_ads");
  const [product, setProduct] = useState("");
  const [audience, setAudience] = useState("Konsumen Indonesia usia 20-40 tahun");
  const [platform, setPlatform] = useState("TikTok dan Instagram Reels");
  const [objective, setObjective] = useState("Meningkatkan awareness dan permintaan");
  const [tone, setTone] = useState("Modern, autentik, persuasif");
  const [details, setDetails] = useState("");
  const [result, setResult] = useState<PromptResult | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  async function submit(action: "analyze" | "prompt") {
    setBusy(true); setError("");
    try {
      const response = await fetch("/api/creative/assist", {
        method: "POST", headers: { "content-type": "application/json" },
        body: JSON.stringify(action === "analyze" ? { action, brief } : {
          action, input: { serviceType, product, audience, platform, objective, tone, details, language: "Bahasa Indonesia" },
        }),
      });
      const payload = await response.json();
      if (!response.ok) throw new Error(payload.error || "Permintaan gagal diproses.");
      if (action === "analyze") setAnalysis(payload.data as Analysis);
      else setResult(payload.data as PromptResult);
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : "Terjadi kesalahan.");
    } finally { setBusy(false); }
  }

  async function copy(value: string) {
    try { await navigator.clipboard.writeText(value); setError(""); }
    catch { setError("Clipboard tidak tersedia. Pilih teks lalu salin secara manual."); }
  }

  return <div className="space-y-6">
    <div className="flex flex-wrap gap-2">
      <button onClick={() => setTab("analyze")} className={`rounded-xl px-4 py-3 text-sm font-semibold ${tab === "analyze" ? "bg-violet-600 text-white" : "border border-white/10 text-slate-300"}`}>01 · Analisis Pesanan</button>
      <button onClick={() => setTab("prompt")} className={`rounded-xl px-4 py-3 text-sm font-semibold ${tab === "prompt" ? "bg-violet-600 text-white" : "border border-white/10 text-slate-300"}`}>02 · Prompt Generator</button>
    </div>
    {error && <div role="alert" className="rounded-xl border border-rose-400/30 bg-rose-400/10 p-3 text-sm text-rose-200">{error}</div>}
    {tab === "analyze" ? <div className="grid gap-5 lg:grid-cols-[1fr_1fr]">
      <section className={panelClass}>
        <div className="text-xs font-bold uppercase tracking-widest text-violet-300">Order intelligence · v1</div>
        <h2 className="mt-2 text-xl font-bold">Pahami kebutuhan pelanggan</h2>
        <p className="mt-2 text-sm leading-6 text-slate-400">Masukkan brief bebas. Engine akan mengusulkan kategori, pertanyaan klarifikasi, dan penanda risiko.</p>
        <textarea value={brief} onChange={event => setBrief(event.target.value)} maxLength={6000} rows={9} className={`${fieldClass} mt-5 resize-y`} placeholder="Contoh: Saya ingin video iklan 15 detik untuk kopi kemasan, target pekerja muda, untuk TikTok..." />
        <div className="mt-2 text-right text-xs text-slate-500">{brief.length}/6000</div>
        <button disabled={busy || brief.trim().length < 12} onClick={() => submit("analyze")} className="mt-4 w-full rounded-xl bg-violet-600 px-4 py-3 font-semibold disabled:cursor-not-allowed disabled:opacity-50">{busy ? "Menganalisis..." : "Analisis brief"}</button>
      </section>
      <section className={panelClass}>
        <div className="text-xs font-bold uppercase tracking-widest text-cyan-300">Hasil analisis</div>
        {analysis ? <>
          <h3 className="mt-3 text-2xl font-bold">{analysis.classification.label}</h3>
          <p className="mt-1 text-sm text-slate-400">Kecocokan aturan: {Math.round(analysis.classification.confidence * 100)}% · {analysis.autonomy}</p>
          <p className="mt-4 rounded-xl bg-white/5 p-3 text-sm leading-6">{analysis.summary}</p>
          {analysis.questions.length > 0 && <><h4 className="mt-5 font-semibold">Informasi yang perlu dikonfirmasi</h4><ul className="mt-2 list-disc space-y-2 pl-5 text-sm text-slate-300">{analysis.questions.map(item => <li key={item}>{item}</li>)}</ul></>}
          {analysis.riskFlags.length > 0 && <><h4 className="mt-5 font-semibold text-amber-300">Perlu pemeriksaan manusia</h4><ul className="mt-2 list-disc space-y-2 pl-5 text-sm text-amber-100">{analysis.riskFlags.map(item => <li key={item}>{item}</li>)}</ul></>}
          <p className="mt-5 text-xs leading-5 text-slate-500">{analysis.notice}</p>
        </> : <div className="grid min-h-64 place-items-center text-center text-sm text-slate-500">Hasil analisis akan tampil di sini.</div>}
      </section>
    </div> : <div className="grid gap-5 lg:grid-cols-[.9fr_1.1fr]">
      <section className={panelClass}>
        <div className="text-xs font-bold uppercase tracking-widest text-violet-300">Prompt compiler · local</div>
        <h2 className="mt-2 text-xl font-bold">Rancang prompt kreatif</h2>
        <label className="mt-5 block text-sm text-slate-300">Jenis layanan</label>
        <select value={serviceType} onChange={event => setServiceType(event.target.value)} className={`${fieldClass} mt-2`}>
          <option value="video_ads">Video Ads</option><option value="ugc_ads">UGC Ads</option><option value="product_photo">Foto Produk AI</option><option value="poster">Poster Promosi</option><option value="ai_influencer">AI Influencer</option><option value="fashion">Fashion Model AI</option><option value="mockup">Mockup Merchandise</option><option value="marketing_package">Paket Marketing UMKM</option>
        </select>
        <label className="mt-4 block text-sm text-slate-300">Produk / layanan</label><input value={product} onChange={event => setProduct(event.target.value)} maxLength={240} className={`${fieldClass} mt-2`} placeholder="Nama dan jenis produk" />
        <label className="mt-4 block text-sm text-slate-300">Target audiens</label><input value={audience} onChange={event => setAudience(event.target.value)} maxLength={240} className={`${fieldClass} mt-2`} />
        <label className="mt-4 block text-sm text-slate-300">Platform</label><input value={platform} onChange={event => setPlatform(event.target.value)} maxLength={80} className={`${fieldClass} mt-2`} />
        <label className="mt-4 block text-sm text-slate-300">Tujuan kampanye</label><input value={objective} onChange={event => setObjective(event.target.value)} maxLength={240} className={`${fieldClass} mt-2`} />
        <label className="mt-4 block text-sm text-slate-300">Gaya komunikasi</label><input value={tone} onChange={event => setTone(event.target.value)} maxLength={120} className={`${fieldClass} mt-2`} />
        <label className="mt-4 block text-sm text-slate-300">Detail produk terverifikasi</label><textarea value={details} onChange={event => setDetails(event.target.value)} maxLength={1200} rows={3} className={`${fieldClass} mt-2`} placeholder="Bahan, ukuran, manfaat yang terbukti, harga/promo yang berlaku..." />
        <button disabled={busy || product.trim().length < 2} onClick={() => submit("prompt")} className="mt-5 w-full rounded-xl bg-violet-600 px-4 py-3 font-semibold disabled:cursor-not-allowed disabled:opacity-50">{busy ? "Menyusun prompt..." : "Generate prompt"}</button>
      </section>
      <section className={`${panelClass} space-y-5`}>
        <div><div className="text-xs font-bold uppercase tracking-widest text-cyan-300">Creative output</div><h2 className="mt-2 text-xl font-bold">Prompt dan arahan produksi</h2></div>
        {result ? <>
          <div><div className="mb-2 flex items-center justify-between gap-3"><h3 className="font-semibold">Image prompt</h3><button onClick={() => copy(result.imagePrompt)} className="text-xs text-cyan-300">Salin</button></div><pre className="whitespace-pre-wrap rounded-xl bg-black/20 p-3 text-xs leading-6 text-slate-300">{result.imagePrompt}</pre></div>
          <div><div className="mb-2 flex items-center justify-between gap-3"><h3 className="font-semibold">Video prompt</h3><button onClick={() => copy(result.videoPrompt)} className="text-xs text-cyan-300">Salin</button></div><pre className="whitespace-pre-wrap rounded-xl bg-black/20 p-3 text-xs leading-6 text-slate-300">{result.videoPrompt}</pre></div>
          <div><div className="mb-2 flex items-center justify-between gap-3"><h3 className="font-semibold">Negative prompt</h3><button onClick={() => copy(result.negativePrompt)} className="text-xs text-cyan-300">Salin</button></div><pre className="whitespace-pre-wrap rounded-xl bg-black/20 p-3 text-xs leading-6 text-slate-300">{result.negativePrompt}</pre></div>
          <div><h3 className="font-semibold">Storyboard 15 detik</h3><div className="mt-2 space-y-2">{result.storyboard.map(scene => <div key={scene.time} className="rounded-xl bg-white/5 p-3 text-sm"><b className="mr-3 text-cyan-300">{scene.time}</b>{scene.scene}</div>)}</div></div>
          <div><h3 className="font-semibold">CTA</h3><p className="mt-2 text-sm text-slate-300">{result.suggestedCTA}</p></div>
          <div className="rounded-xl border border-amber-300/20 bg-amber-300/5 p-3 text-xs leading-5 text-amber-100">Mode {result.engine}. Tidak ada provider eksternal yang dipanggil; ini adalah draft untuk direview sebelum produksi.</div>
        </> : <div className="grid min-h-64 place-items-center text-center text-sm text-slate-500">Lengkapi detail produk lalu generate prompt.</div>}
      </section>
    </div>}
  </div>;
}
