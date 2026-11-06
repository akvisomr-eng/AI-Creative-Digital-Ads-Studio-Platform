import { NextResponse } from "next/server";
import { TenantContextError } from "@/lib/tenant-context";
export function toHttpError(error:unknown){if(error instanceof TenantContextError)return NextResponse.json({error:error.message},{status:error.status});return NextResponse.json({error:"Internal server error."},{status:500});}
