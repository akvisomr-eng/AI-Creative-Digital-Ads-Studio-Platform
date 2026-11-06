import { toNextJsHandler } from "better-auth/next-js";
import { getAuth } from "@/lib/auth";
const handlers=()=>toNextJsHandler(getAuth());
export const GET=(request:Request)=>handlers().GET(request);
export async function POST(request:Request){const pathname=new URL(request.url).pathname;if(pathname.endsWith("/sign-up/email"))return new Response(null,{status:404});return handlers().POST(request);}
