import { NextResponse } from "next/server";
import { sql } from "drizzle-orm";
import { getDb } from "@/db";
export const dynamic="force-dynamic";
export async function GET(){const checks:Record<string,string>={app:"ok",database:"not_configured"};try{const db=getDb();await db.execute(sql`select 1`);checks.database="ok";return NextResponse.json({status:"ok",checks,timestamp:new Date().toISOString()});}catch{checks.database=process.env.DATABASE_URL?"unavailable":"not_configured";return NextResponse.json({status:"degraded",checks,timestamp:new Date().toISOString()},{status:503});}}
