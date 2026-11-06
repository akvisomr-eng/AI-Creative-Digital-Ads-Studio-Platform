import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: { default: "AI Creative & Digital Ads Studio", template: "%s | AI Creative Studio" }, description: "Platform produksi kreatif dan digital advertising berbasis AI untuk kreator, UMKM, perusahaan, reseller, dan agensi.", applicationName: "AI Creative & Digital Ads Studio", robots: { index: false, follow: false } };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="id"><body>{children}</body></html>; }
