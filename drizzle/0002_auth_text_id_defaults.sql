-- Ensure Better Auth text primary keys receive UUIDs from PostgreSQL when omitted.
-- This is safe for existing rows and only affects future inserts.
ALTER TABLE "user" ALTER COLUMN "id" SET DEFAULT (gen_random_uuid()::text);
--> statement-breakpoint
ALTER TABLE "session" ALTER COLUMN "id" SET DEFAULT (gen_random_uuid()::text);
--> statement-breakpoint
ALTER TABLE "account" ALTER COLUMN "id" SET DEFAULT (gen_random_uuid()::text);
--> statement-breakpoint
ALTER TABLE "verification" ALTER COLUMN "id" SET DEFAULT (gen_random_uuid()::text);
