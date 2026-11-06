import { toNextJsHandler } from "better-auth/next-js";
import { getAuth } from "@/lib/auth";
const handlers=()=>toNextJsHandler(getAuth());
export const GET=(request:Request)=>handlers().GET(request);
export const POST=(request:Request)=>handlers().POST(request);
