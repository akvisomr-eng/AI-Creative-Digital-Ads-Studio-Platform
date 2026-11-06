CREATE TABLE "account" (
	"id" text PRIMARY KEY NOT NULL,
	"account_id" text NOT NULL,
	"provider_id" text NOT NULL,
	"user_id" text NOT NULL,
	"access_token" text,
	"refresh_token" text,
	"id_token" text,
	"access_token_expires_at" timestamp,
	"refresh_token_expires_at" timestamp,
	"scope" text,
	"password" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "session" (
	"id" text PRIMARY KEY NOT NULL,
	"expires_at" timestamp NOT NULL,
	"token" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"ip_address" text,
	"user_agent" text,
	"user_id" text NOT NULL,
	CONSTRAINT "session_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "user" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean DEFAULT false NOT NULL,
	"image" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "user_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "verification" (
	"id" text PRIMARY KEY NOT NULL,
	"identifier" text NOT NULL,
	"value" text NOT NULL,
	"expires_at" timestamp NOT NULL,
	"created_at" timestamp DEFAULT now(),
	"updated_at" timestamp DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "ai_credit_accounts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"provider_id" uuid NOT NULL,
	"account_code" varchar(64) NOT NULL,
	"period_start" date NOT NULL,
	"period_end" date NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ai_credit_ledger" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"account_id" uuid NOT NULL,
	"entry_type" varchar(24) NOT NULL,
	"credits_delta" numeric(18, 6) NOT NULL,
	"source_ref" varchar(160),
	"reason" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "ai_providers" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"code" varchar(64) NOT NULL,
	"name" varchar(120) NOT NULL,
	"integration_status" varchar(24) DEFAULT 'manual_unverified' NOT NULL,
	CONSTRAINT "ai_providers_code_unique" UNIQUE("code")
);
--> statement-breakpoint
CREATE TABLE "branches" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"code" varchar(40) NOT NULL,
	"name" varchar(160) NOT NULL,
	"status" varchar(20) DEFAULT 'active' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "customers" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"customer_type" varchar(20) DEFAULT 'individual' NOT NULL,
	"display_name" varchar(200) NOT NULL,
	"email" varchar(254),
	"phone" varchar(40),
	"status" varchar(20) DEFAULT 'active' NOT NULL,
	"owner_user_id" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "departments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"branch_id" uuid,
	"parent_id" uuid,
	"name" varchar(160) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "leads" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"customer_id" uuid,
	"source" varchar(80),
	"stage" varchar(32) DEFAULT 'new' NOT NULL,
	"owner_user_id" text,
	"notes" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "membership_roles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"membership_id" uuid NOT NULL,
	"role_id" uuid NOT NULL,
	"branch_id" uuid,
	"department_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "order_items" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"order_id" uuid NOT NULL,
	"service_version_id" uuid,
	"description_snapshot" text NOT NULL,
	"quantity" numeric(18, 4) NOT NULL,
	"unit_price" numeric(18, 2) NOT NULL,
	"hpp_snapshot" numeric(18, 2) DEFAULT '0' NOT NULL
);
--> statement-breakpoint
CREATE TABLE "orders" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"order_no" varchar(40) NOT NULL,
	"customer_id" uuid NOT NULL,
	"quotation_id" uuid,
	"status" varchar(24) DEFAULT 'draft' NOT NULL,
	"currency" varchar(3) DEFAULT 'IDR' NOT NULL,
	"total_amount" numeric(18, 2) DEFAULT '0' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "permissions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"code" varchar(160) NOT NULL,
	"module" varchar(64) NOT NULL,
	"action" varchar(64) NOT NULL,
	"description" text,
	CONSTRAINT "permissions_code_unique" UNIQUE("code")
);
--> statement-breakpoint
CREATE TABLE "price_lists" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"code" varchar(64) NOT NULL,
	"channel" varchar(24) DEFAULT 'retail' NOT NULL,
	"currency" varchar(3) DEFAULT 'IDR' NOT NULL,
	"valid_from" date NOT NULL,
	"valid_to" date,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "production_jobs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"order_id" uuid NOT NULL,
	"job_no" varchar(40) NOT NULL,
	"status" varchar(24) DEFAULT 'queued' NOT NULL,
	"priority" varchar(16) DEFAULT 'normal' NOT NULL,
	"due_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quotations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"quote_no" varchar(40) NOT NULL,
	"customer_id" uuid NOT NULL,
	"status" varchar(24) DEFAULT 'draft' NOT NULL,
	"currency" varchar(3) DEFAULT 'IDR' NOT NULL,
	"subtotal" numeric(18, 2) DEFAULT '0' NOT NULL,
	"total_amount" numeric(18, 2) DEFAULT '0' NOT NULL,
	"valid_until" date,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "role_permissions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid,
	"role_id" uuid NOT NULL,
	"permission_id" uuid NOT NULL,
	"scope_policy" varchar(32) DEFAULT 'organization' NOT NULL
);
--> statement-breakpoint
CREATE TABLE "roles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid,
	"code" varchar(64) NOT NULL,
	"name" varchar(120) NOT NULL,
	"is_system" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "service_prices" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"price_list_id" uuid NOT NULL,
	"service_version_id" uuid NOT NULL,
	"unit_price" numeric(18, 2) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "service_versions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"service_id" uuid NOT NULL,
	"version_no" varchar(20) NOT NULL,
	"spec" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"effective_from" date NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "services" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"sku" varchar(64) NOT NULL,
	"name" varchar(180) NOT NULL,
	"service_type" varchar(30) NOT NULL,
	"status" varchar(20) DEFAULT 'draft' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tenant_memberships" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"tenant_id" uuid NOT NULL,
	"user_id" text NOT NULL,
	"status" varchar(20) DEFAULT 'invited' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tenants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" varchar(80) NOT NULL,
	"name" varchar(200) NOT NULL,
	"status" varchar(20) DEFAULT 'active' NOT NULL,
	"default_currency" varchar(3) DEFAULT 'IDR' NOT NULL,
	"timezone" varchar(64) DEFAULT 'Asia/Jakarta' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "tenants_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
ALTER TABLE "account" ADD CONSTRAINT "account_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "session" ADD CONSTRAINT "session_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "ai_credit_accounts" ADD CONSTRAINT "ai_credit_accounts_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "ai_credit_accounts" ADD CONSTRAINT "ai_credit_accounts_provider_id_ai_providers_id_fk" FOREIGN KEY ("provider_id") REFERENCES "public"."ai_providers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "ai_credit_ledger" ADD CONSTRAINT "ai_credit_ledger_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "ai_credit_ledger" ADD CONSTRAINT "ai_credit_ledger_account_id_ai_credit_accounts_id_fk" FOREIGN KEY ("account_id") REFERENCES "public"."ai_credit_accounts"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "branches" ADD CONSTRAINT "branches_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "customers" ADD CONSTRAINT "customers_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "customers" ADD CONSTRAINT "customers_owner_user_id_user_id_fk" FOREIGN KEY ("owner_user_id") REFERENCES "public"."user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "departments" ADD CONSTRAINT "departments_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "departments" ADD CONSTRAINT "departments_branch_id_branches_id_fk" FOREIGN KEY ("branch_id") REFERENCES "public"."branches"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "leads" ADD CONSTRAINT "leads_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "leads" ADD CONSTRAINT "leads_customer_id_customers_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "leads" ADD CONSTRAINT "leads_owner_user_id_user_id_fk" FOREIGN KEY ("owner_user_id") REFERENCES "public"."user"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_membership_id_tenant_memberships_id_fk" FOREIGN KEY ("membership_id") REFERENCES "public"."tenant_memberships"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_role_id_roles_id_fk" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_branch_id_branches_id_fk" FOREIGN KEY ("branch_id") REFERENCES "public"."branches"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "membership_roles" ADD CONSTRAINT "membership_roles_department_id_departments_id_fk" FOREIGN KEY ("department_id") REFERENCES "public"."departments"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "order_items" ADD CONSTRAINT "order_items_service_version_id_service_versions_id_fk" FOREIGN KEY ("service_version_id") REFERENCES "public"."service_versions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "orders" ADD CONSTRAINT "orders_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "orders" ADD CONSTRAINT "orders_customer_id_customers_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "orders" ADD CONSTRAINT "orders_quotation_id_quotations_id_fk" FOREIGN KEY ("quotation_id") REFERENCES "public"."quotations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "price_lists" ADD CONSTRAINT "price_lists_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "production_jobs" ADD CONSTRAINT "production_jobs_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "production_jobs" ADD CONSTRAINT "production_jobs_order_id_orders_id_fk" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quotations" ADD CONSTRAINT "quotations_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quotations" ADD CONSTRAINT "quotations_customer_id_customers_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_roles_id_fk" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_permissions_id_fk" FOREIGN KEY ("permission_id") REFERENCES "public"."permissions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "roles" ADD CONSTRAINT "roles_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "service_prices" ADD CONSTRAINT "service_prices_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "service_prices" ADD CONSTRAINT "service_prices_price_list_id_price_lists_id_fk" FOREIGN KEY ("price_list_id") REFERENCES "public"."price_lists"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "service_prices" ADD CONSTRAINT "service_prices_service_version_id_service_versions_id_fk" FOREIGN KEY ("service_version_id") REFERENCES "public"."service_versions"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "service_versions" ADD CONSTRAINT "service_versions_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "service_versions" ADD CONSTRAINT "service_versions_service_id_services_id_fk" FOREIGN KEY ("service_id") REFERENCES "public"."services"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "services" ADD CONSTRAINT "services_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tenant_memberships" ADD CONSTRAINT "tenant_memberships_tenant_id_tenants_id_fk" FOREIGN KEY ("tenant_id") REFERENCES "public"."tenants"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tenant_memberships" ADD CONSTRAINT "tenant_memberships_user_id_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "ai_credit_account_uq" ON "ai_credit_accounts" USING btree ("tenant_id","account_code","period_start");--> statement-breakpoint
CREATE INDEX "ai_credit_ledger_account_created_idx" ON "ai_credit_ledger" USING btree ("tenant_id","account_id","created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "branches_tenant_code_uq" ON "branches" USING btree ("tenant_id","code");--> statement-breakpoint
CREATE INDEX "customers_tenant_created_idx" ON "customers" USING btree ("tenant_id","created_at");--> statement-breakpoint
CREATE INDEX "departments_tenant_idx" ON "departments" USING btree ("tenant_id");--> statement-breakpoint
CREATE INDEX "leads_tenant_stage_idx" ON "leads" USING btree ("tenant_id","stage");--> statement-breakpoint
CREATE UNIQUE INDEX "membership_roles_uq" ON "membership_roles" USING btree ("membership_id","role_id","branch_id","department_id");--> statement-breakpoint
CREATE UNIQUE INDEX "orders_tenant_no_uq" ON "orders" USING btree ("tenant_id","order_no");--> statement-breakpoint
CREATE INDEX "orders_tenant_created_idx" ON "orders" USING btree ("tenant_id","created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "price_lists_tenant_code_uq" ON "price_lists" USING btree ("tenant_id","code");--> statement-breakpoint
CREATE UNIQUE INDEX "production_jobs_tenant_no_uq" ON "production_jobs" USING btree ("tenant_id","job_no");--> statement-breakpoint
CREATE UNIQUE INDEX "quotations_tenant_no_uq" ON "quotations" USING btree ("tenant_id","quote_no");--> statement-breakpoint
CREATE UNIQUE INDEX "role_permissions_uq" ON "role_permissions" USING btree ("role_id","permission_id");--> statement-breakpoint
CREATE UNIQUE INDEX "roles_tenant_code_uq" ON "roles" USING btree ("tenant_id","code");--> statement-breakpoint
CREATE UNIQUE INDEX "service_prices_version_uq" ON "service_prices" USING btree ("price_list_id","service_version_id");--> statement-breakpoint
CREATE UNIQUE INDEX "service_versions_uq" ON "service_versions" USING btree ("tenant_id","service_id","version_no");--> statement-breakpoint
CREATE UNIQUE INDEX "services_tenant_sku_uq" ON "services" USING btree ("tenant_id","sku");--> statement-breakpoint
CREATE UNIQUE INDEX "tenant_memberships_tenant_user_uq" ON "tenant_memberships" USING btree ("tenant_id","user_id");