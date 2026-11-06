import { NextResponse } from "next/server";
export const dynamic = "force-dynamic";
export async function GET(){const configured=Boolean(process.env.DATABASE_URL);return NextResponse.json({status:configured?"ready_for_db_check":"degraded",checks:{app:"ok",database:configured?"configured":"not_configured"},timestamp:new Date().toISOString()},{status:configured?200:503});}
