import { NextRequest, NextResponse } from "next/server";
import { requirePermission } from "@/lib/permissions";
import { toHttpError } from "@/lib/http-errors";
import { analyzeOrder, generateCreativePrompt, type CreativeInput } from "@/lib/creative-assist";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(request: NextRequest) {
  try {
    await requirePermission("orders.create", request.headers);
    const declaredLength = Number(request.headers.get("content-length") || 0);
    if (declaredLength > 12_000) return NextResponse.json({ error: "Payload terlalu besar." }, { status: 413 });
    const rawBody = await request.text();
    if (rawBody.length > 12_000) return NextResponse.json({ error: "Payload terlalu besar." }, { status: 413 });
    let body: { action?: unknown; brief?: unknown; input?: unknown };
    try { body = JSON.parse(rawBody) as typeof body; }
    catch { return NextResponse.json({ error: "Format JSON tidak valid." }, { status: 400 }); }
    if (body.action === "analyze") {
      if (typeof body.brief !== "string") return NextResponse.json({ error: "Brief harus berupa teks." }, { status: 400 });
      return NextResponse.json({ data: analyzeOrder(body.brief) });
    }
    if (body.action === "prompt") {
      if (!body.input || typeof body.input !== "object" || Array.isArray(body.input)) {
        return NextResponse.json({ error: "Data prompt tidak valid." }, { status: 400 });
      }
      return NextResponse.json({ data: generateCreativePrompt(body.input as CreativeInput) });
    }
    return NextResponse.json({ error: "Aksi tidak dikenal." }, { status: 400 });
  } catch (error) {
    if (error instanceof Error && (error.message.includes("Brief minimal") || error.message.includes("Nama produk"))) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }
    return toHttpError(error);
  }
}
