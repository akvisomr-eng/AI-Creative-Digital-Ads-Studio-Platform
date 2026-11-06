import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { getDb } from "@/db";
import * as authSchema from "@/db/schema/auth";
export function getAuth(){const secret=process.env.BETTER_AUTH_SECRET;const baseURL=process.env.BETTER_AUTH_URL;if(!secret||!baseURL)throw new Error("Better Auth environment is not configured.");return betterAuth({appName:"AI Creative & Digital Ads Studio",baseURL,secret,database:drizzleAdapter(getDb(),{provider:"pg",schema:authSchema}),emailAndPassword:{enabled:true,disableSignUp:true},trustedOrigins:[baseURL,process.env.NEXT_PUBLIC_APP_URL||baseURL],advanced:{database:{generateId:"uuid"},useSecureCookies:process.env.NODE_ENV==="production"}});}
