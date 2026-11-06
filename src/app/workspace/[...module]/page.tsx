import Link from "next/link";
import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { getAuth } from "@/lib/auth";
type Props={params:Promise<{module:string[]}>};
const labels:Record<string,string>={crm:"CRM & Customer Management",catalog:"Katalog Layanan",orders:"Order Management",production:"Creative Production","ai-usage":"AI Provider & Credit Ledger",finance:"Finance & Accounting",reports:"Business Intelligence & Reports"};
export const dynamic="force-dynamic";
export default async function ModulePage({params}:Props){const session=await getAuth().api.getSession({headers:await headers()});if(!session)redirect("/login");const {module}=await params;const title=labels[module.join("/")]||"Workspace Module";return <main className="workspace"><aside className="sidebar"><Link href="/" className="brand"><span className="brand-mark">A</span><span>CREATIVE STUDIO</span></Link><nav><Link href="/workspace">Ringkasan</Link></nav><div style={{marginTop:32,color:"var(--muted)",fontSize:12}}>{session.user.email}</div></aside><section className="main-area"><div className="eyebrow">Workspace / Module</div><h1 style={{fontSize:34}}>{title}</h1><div className="table-panel"><h3>Modul sedang disiapkan</h3><p className="section-copy">Fitur operasional akan diaktifkan setelah skema database, otorisasi, dan alur kerja modul selesai diuji.</p><Link className="btn" href="/workspace">Kembali ke dashboard</Link></div></section></main>}
