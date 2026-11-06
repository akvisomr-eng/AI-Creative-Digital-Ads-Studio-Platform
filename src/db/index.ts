import { Pool } from "pg";
import { drizzle } from "drizzle-orm/node-postgres";
import * as authSchema from "./schema/auth";
import * as coreSchema from "./schema/core";
let pool: Pool | undefined;
export function getDb(){const connectionString=process.env.DATABASE_URL;if(!connectionString)throw new Error("DATABASE_URL is not configured.");pool??=new Pool({connectionString,max:5,idleTimeoutMillis:10000,connectionTimeoutMillis:5000,ssl:{rejectUnauthorized:true}});return drizzle(pool,{schema:{...authSchema,...coreSchema}});}
