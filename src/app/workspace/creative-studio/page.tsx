import Link from "next/link";
import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { getAuth } from "@/lib/auth";
import CreativeStudioClient from "./creative-studio-client";

export const dynamic = "force-dynamic";

export default async function CreativeStudioPage() {
  const session = await getAuth().api.getSession({ headers: await headers() });
  if (!session) redirect("/login");
  return <main className="workspace">
    <aside className="sidebar">
      <Link href="/" className="brand"><span className="brand-mark">A</span><span>CREATIVE STUDIO</span></Link>
      <p className="eyebrow" style={{ marginTop: 34 }}>Workspace</p>
      <nav><Link href="/workspace">Ringkasan</Link><Link href="/workspace/creative-studio" className="active">Creative Intelligence</Link><Link href="/workspace/orders">Pesanan</Link><Link href="/workspace/production">Produksi</Link></nav>
      <div style={{ marginTop: 32, color: "var(--muted)", fontSize: 12 }}>{session.user.email}</div>
    </aside>
    <section className="main-area">
      <div className="eyebrow">AI Creative Operations / Foundation</div>
      <div className="page-head"><div><h1 style={{ fontSize: 34, margin: "8px 0" }}>Creative Intelligence Studio</h1><p className="section-copy">Analisis brief dan penyusunan prompt terstruktur sebelum pekerjaan masuk ke proses produksi.</p></div><span className="rounded-full border border-cyan-300/20 px-3 py-2 text-xs text-cyan-200">Local engine · no provider spend</span></div>
      <CreativeStudioClient />
    </section>
  </main>;
}
