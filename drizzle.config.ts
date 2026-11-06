import { defineConfig } from "drizzle-kit";
const databaseUrl=process.env.DATABASE_URL;
if(!databaseUrl&&process.env.DRIZZLE_GENERATE!=="true")throw new Error("DATABASE_URL is required for database migration commands.");
export default defineConfig({schema:"./src/db/schema/**/*.ts",out:"./drizzle",dialect:"postgresql",dbCredentials:{url:databaseUrl||"postgresql://placeholder:placeholder@localhost:5432/placeholder"},strict:true,verbose:true});
