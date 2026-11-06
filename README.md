# AI Creative & Digital Ads Studio Platform

Modular platform for AI-assisted creative production, digital advertising services, customers, resellers, agencies, and internal business operations.

## Current status
- Specification pack: Draft v0.1 in [docs](./docs).
- Application foundation: in progress on `feat/foundation-bootstrap`.
- Production database: untouched; use Neon `specification-dev` for development only.
- Authentication: Better Auth + PostgreSQL adapter; account creation is invite-only by default.
- Database schema: Drizzle ORM; migrations must be generated and reviewed before applying.

## Local development
1. Use Node.js 22 or newer.
2. Copy `.env.example` to `.env.local`.
3. Set `DATABASE_URL` to the Neon `specification-dev` branch, never production.
4. Set a unique high-entropy `BETTER_AUTH_SECRET` and `BETTER_AUTH_URL`.
5. Run `npm install`, then `npm run dev`.

Do not run migrations until the database URL is verified to target the development branch and a reviewed migration exists.

## Quality checks
- `npm run lint`
- `npm run typecheck`
- `npm run build`

See [SRS](./docs/01-srs.md), [ERD](./docs/02-erd-data-dictionary.md), [RBAC](./docs/03-rbac.md), [UI/UX](./docs/04-ui-ux.md), and [backlog](./docs/05-backlog.md).
